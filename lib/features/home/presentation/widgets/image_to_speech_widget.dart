import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:leyu_mobile/core/constants/screen_constants.dart';
import 'package:leyu_mobile/core/services/audio_manager_service.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:leyu_mobile/core/widgets/loading.dart';
import 'package:leyu_mobile/features/home/domain/entities/task_detail_entity.dart';
import 'package:leyu_mobile/features/home/domain/entities/task_type_enum.dart';
import 'package:leyu_mobile/features/home/presentation/controllers/home_controller.dart';
import 'package:leyu_mobile/features/home/presentation/widgets/submission_widget.dart';
import 'package:leyu_mobile/features/home/presentation/widgets/task_navigation_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wave_blob/wave_blob.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/utils/screen_size.dart';
import '../../domain/entities/micro_task_entity.dart';
import '../../domain/entities/micro_task_status_enum.dart';

class ImageToSpeechWidget extends StatefulWidget {
  final GlobalKey? imageViewKey;
  final GlobalKey? micButtonKey;
  final GlobalKey? submitButtonKey;
  final GlobalKey? restartButtonKey;
  final GlobalKey? navigationKey;

  const ImageToSpeechWidget({
    super.key,
    this.imageViewKey,
    this.micButtonKey,
    this.submitButtonKey,
    this.restartButtonKey,
    this.navigationKey,
  });

  @override
  _ImageToSpeechWidgetState createState() => _ImageToSpeechWidgetState();
}

class _ImageToSpeechWidgetState extends State<ImageToSpeechWidget> {
  final HomeController _controller = Get.find();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final PageController _pageController = PageController();
  late AudioManagerService _audioManager;
  late String _playerId;

  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  String? _currentFilePath;
  Duration _recordingDuration = Duration.zero;

  List<double> _amplitudes = [];
  Timer? _amplitudeTimer;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _audioManager = Get.find<AudioManagerService>();
    _playerId = 'its_player_${DateTime.now().millisecondsSinceEpoch}';
    _setupPlayerStateListener();
    _initializeRecordingState();
    _setupPageControllerListener();
    _requestMicrophonePermission();
  }

  void _setupPlayerStateListener() {
    _player.playerStateStream.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlaying = state.playing;
      });

      if (state.processingState == ProcessingState.completed) {
        _player.stop();
        _player.seek(Duration.zero);
      }
    });
  }

  void _initializeRecordingState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _currentFilePath = _controller.getRecordedAudioPath();

      if (_currentFilePath != null) {
        final fileExists = File(_currentFilePath!).existsSync();
        _hasRecording = fileExists;
      } else {
        _hasRecording = false;
      }

      setState(() {});
    });
  }

  void _setupPageControllerListener() {
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? 0;
      if (_controller.selectedMicroTaskIndex.value != newIndex) {
        _handlePageChange(newIndex);
      }
    });
  }

  void _handlePageChange(int newIndex) async {
    if (_currentFilePath != null &&
        File(_currentFilePath!).existsSync() &&
        _controller.selectedMicroTaskIndex.value !=
            _controller.selectedTaskDetail.value!.microTasks.length - 1) {
      _controller.setRecordedAudio(File(_currentFilePath!));
    }

    _controller.selectedMicroTaskIndex.value = newIndex;

    if (_player.playing) {
      await _player.stop();
    }

    setState(() {
      _currentFilePath = _controller.getRecordedAudioPath();
      _hasRecording =
          _currentFilePath != null && File(_currentFilePath!).existsSync();
      _isRecording = false;
      _isPlaying = false;
      _isPaused = false;
      _recordingDuration = Duration.zero;
      _amplitudes.clear();
    });
  }

  void _startAmplitudeTracking() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_isRecording && mounted) {
        try {
          final amplitude = await _recorder.getAmplitude();
          final db = amplitude.current;
          final normalized = ((db + 20) / 20 * 100).clamp(0, 100);

          setState(() {
            _amplitudes.add(normalized.toDouble());
            if (_amplitudes.length > 50) {
              _amplitudes.removeAt(0);
            }
          });
        } catch (e) {
          // Ignore amplitude errors
        }
      }
    });
  }

  void _startDurationTracking() {
    _durationTimer?.cancel();
    final startTime = DateTime.now();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration = DateTime.now().difference(startTime);
        });
      }
    });
  }

  Future<bool> _requestMicrophonePermission() async {
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (micStatus.isPermanentlyDenied) {
          showErrorMessage(
              'Microphone permission permanently denied. Please enable it in app settings.');
        } else {
          showErrorMessage('Microphone access is required for recording');
        }
        return false;
      }
    }

    if (Platform.isAndroid) {
      try {
        final androidInfo = await Permission.storage.status;

        if (!androidInfo.isGranted && !androidInfo.isLimited) {
          final storageStatus = await Permission.storage.request();

          if (!storageStatus.isGranted && storageStatus.isPermanentlyDenied) {
            showErrorMessage(
                'Storage permission is required for saving recordings on this Android version.');
            return false;
          }
        }
      } catch (e) {
        // Continue anyway
      }
    }

    return true;
  }

  Future<void> _startRecording() async {
    if (await _recorder.isRecording()) return;

    try {
      if (!await _requestMicrophonePermission()) {
        return;
      }

      try {
        await _player.stop();
        await _player.seek(Duration.zero);
      } catch (e) {
        // Ignore
      }

      await _deleteExistingRecording();

      _currentFilePath = await _controller.getRecordingFilePath();
      if (_currentFilePath == null) {
        showErrorMessage('Failed to get recording file path');
        return;
      }

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _currentFilePath!,
      );

      _startAmplitudeTracking();
      _startDurationTracking();

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _hasRecording = false;
        _recordingDuration = Duration.zero;
        _amplitudes.clear();
      });
    } catch (e) {
      showErrorMessage('Failed to start recording: $e');
    }
  }

  Future<void> _deleteExistingRecording() async {
    if (_currentFilePath != null && await File(_currentFilePath!).exists()) {
      await File(_currentFilePath!).delete();
    }
  }

  Future<void> _stopRecording() async {
    try {
      _amplitudeTimer?.cancel();
      _durationTimer?.cancel();

      final path = await _recorder.stop();

      if (path == null || !await File(path).exists()) {
        showErrorMessage('Recording file not found');
        return;
      }

      _currentFilePath = path;

      if (!_validateRecordingDuration()) {
        await _deleteInvalidRecording();
        return;
      }

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _hasRecording = true;
      });
    } catch (e) {
      showErrorMessage('Failed to stop recording: $e');
    }
  }

  bool _validateRecordingDuration() {
    if (_controller.selectedTaskDetail.value!.task.type !=
        TaskType.Image_to_Speech) {
      return true;
    }

    final minSeconds = _controller.selectedTaskDetail.value!.minSeconds;
    final maxSeconds = _controller.selectedTaskDetail.value!.maxSeconds;
    final currentSeconds = _recordingDuration.inSeconds;

    if (minSeconds != null && currentSeconds < minSeconds) {
      showErrorMessage('home.tasks.recording_too_short'
          .trParams({'min': minSeconds.toString()}));
      return false;
    }

    if (maxSeconds != null && currentSeconds > maxSeconds) {
      showErrorMessage('home.tasks.recording_too_long'
          .trParams({'max': maxSeconds.toString()}));
      return false;
    }

    return true;
  }

  Future<void> _deleteInvalidRecording() async {
    if (_currentFilePath != null) {
      await File(_currentFilePath!).delete();
    }

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _hasRecording = false;
      _currentFilePath = null;
      _recordingDuration = Duration.zero;
    });
  }

  Future<void> _startPlaying() async {
    if (_player.playing || !_hasRecording || _currentFilePath == null) {
      if (!_hasRecording) {
        showErrorMessage('No recording available');
      }
      return;
    }

    try {
      final audioFile = File(_currentFilePath!);
      if (!await audioFile.exists()) {
        showErrorMessage('Audio file not found for playback');
        return;
      }

      _audioManager.registerPlayer(_player, _playerId);

      if (_player.processingState == ProcessingState.idle ||
          _player.duration == null) {
        await _player.setFilePath(_currentFilePath!);
      }

      await _player.play();
    } catch (e) {
      showErrorMessage('Failed to play recording: $e');
    }
  }

  Future<void> _stopPlaying() async {
    try {
      await _player.pause();
    } catch (e) {
      showErrorMessage('Failed to pause playback: $e');
    }
  }

  Future<void> _submitRecording() async {
    try {
      if (_currentFilePath == null) {
        showErrorMessage('No recording available');
        return;
      }

      final audioFile = File(_currentFilePath!);
      if (!await audioFile.exists()) {
        showErrorMessage('No recording found');
        return;
      }

      final isSuccess = _controller.setRecordedAudio(audioFile);
      if (isSuccess) {
        _resetRecordingState();
        await _navigateToNextMicroTask();
      }
    } catch (e) {
      showErrorMessage('Failed to save recording: $e');
    }
  }

  void _resetRecordingState() {
    setState(() {
      _hasRecording = false;
      _isRecording = false;
      _isPaused = false;
      _isPlaying = false;
      _currentFilePath = null;
      _recordingDuration = Duration.zero;
    });
  }

  Future<void> _navigateToNextMicroTask() async {
    final currentIndex = _controller.selectedMicroTaskIndex.value!;
    if (currentIndex <
        _controller.selectedTaskDetail.value!.microTasks.length) {
      final screenHeight = MediaQuery.of(context).size.height;
      final isSmallScreen = ScreenConstants.isSmallScreen(screenHeight);

      if (isSmallScreen) {
        _controller.selectedMicroTaskIndex.value = currentIndex + 1;
        setState(() {
          _currentFilePath = _controller.getRecordedAudioPath();
          _hasRecording =
              _currentFilePath != null && File(_currentFilePath!).existsSync();
          _isRecording = false;
          _isPlaying = false;
          _isPaused = false;
          _recordingDuration = Duration.zero;
          _amplitudes.clear();
        });
      } else {
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _toggleRecording() {
    _isRecording ? _stopRecording() : _startRecording();
  }

  void _togglePlayback() {
    _isPlaying ? _stopPlaying() : _startPlaying();
  }

  void _handleRestart() async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
    } catch (e) {
      // Ignore
    }

    if (_currentFilePath != null) {
      try {
        final file = File(_currentFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore
      }
    }

    setState(() {
      _hasRecording = false;
      _isRecording = false;
      _isPaused = false;
      _isPlaying = false;
      _currentFilePath = null;
      _recordingDuration = Duration.zero;
      _controller.deleteRecordedAudioForCurrentMicroTask();
    });
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _durationTimer?.cancel();
    _audioManager.unregisterPlayer(_playerId);
    _recorder.dispose();
    _player.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _shouldAllowNavigationNext() {
    if (_isRecording) return false;

    final currentMicroTask = _getCurrentMicroTask();
    if (!_isMicroTaskEligible(currentMicroTask)) {
      return true;
    }

    return _hasRecording;
  }

  bool _shouldAllowNavigationPrevious() {
    return !_isRecording;
  }

  MicroTaskEntity _getCurrentMicroTask() {
    return _controller.selectedTaskDetail.value!
        .microTasks[_controller.selectedMicroTaskIndex.value!];
  }

  bool _isMicroTaskEligible(MicroTaskEntity microTask) {
    return microTask.acceptanceStatus == MicroTaskStatus.NOT_STARTED ||
        (microTask.acceptanceStatus == MicroTaskStatus.REJECTED &&
            microTask.canRetry);
  }

  @override
  Widget build(BuildContext context) {
    final task = _controller.selectedTaskDetail.value!;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ScreenConstants.isSmallScreen(screenHeight);

    return Obx(() {
      final currentIndex = _controller.selectedMicroTaskIndex.value ?? 0;
      final currentMicroTask = task.microTasks[currentIndex];
      final isCurrentTaskEligible = _isMicroTaskEligible(currentMicroTask);

      if (isSmallScreen) {
        return _buildSmallScreenLayout(context, task, currentIndex);
      } else {
        final canSwipeForward = currentIndex < task.microTasks.length - 1 &&
            _shouldAllowNavigationNext();
        final canSwipeBackward =
            currentIndex > 0 && _shouldAllowNavigationPrevious();

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: canSwipeForward || canSwipeBackward
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: task.microTasks.length,
              onPageChanged: (index) {
                if (index > currentIndex && !canSwipeForward) {
                  _pageController.jumpToPage(currentIndex);
                } else if (index < currentIndex && !canSwipeBackward) {
                  _pageController.jumpToPage(currentIndex);
                }
              },
              itemBuilder: (context, index) =>
                  _buildMicroTaskPage(context, task, index),
            ),
            if (task.microTasks.length > 1 && !isCurrentTaskEligible)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavigationButtons(task, currentIndex,
                      useGlobalKey: true),
                ),
              ),
          ],
        );
      }
    });
  }

  Widget _buildSmallScreenLayout(
      BuildContext context, TaskDetailEntity task, int currentIndex) {
    final microTask = task.microTasks[currentIndex];
    final isEligible = _isMicroTaskEligible(microTask);

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildTopSection(context, task, currentIndex),
              if (isEligible)
                _buildRecordingSection(context, task, currentIndex,
                    useGlobalKeys: true),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (task.microTasks.length > 1)
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavigationButtons(task, currentIndex,
                  useGlobalKey: true),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons(TaskDetailEntity task, int currentIndex,
      {bool useGlobalKey = true}) {
    final microTask = task.microTasks[currentIndex];
    final showHistory =
        microTask.acceptanceStatus != MicroTaskStatus.NOT_STARTED;

    return TaskNavigationBar(
      navigationKey: useGlobalKey ? widget.navigationKey : null,
      currentIndex: currentIndex,
      totalCount: task.microTasks.length,
      canNavigatePrevious: currentIndex > 0 && _shouldAllowNavigationPrevious(),
      canNavigateNext: currentIndex < task.microTasks.length - 1 &&
          _shouldAllowNavigationNext(),
      onPrevious: () => _navigateToIndex(currentIndex - 1, task),
      onNext: () => _navigateToIndex(currentIndex + 1, task),
      onHistory: showHistory
          ? () => _controller.showSubmissionHistoryBottomSheet(microTask.id)
          : null,
    );
  }

  void _navigateToIndex(int targetIndex, TaskDetailEntity task) {
    if (_player.playing) {
      _player.stop();
    }

    if (_currentFilePath != null &&
        File(_currentFilePath!).existsSync() &&
        targetIndex !=
            _controller.selectedTaskDetail.value!.microTasks.length - 1) {
      _controller.setRecordedAudio(File(_currentFilePath!));
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ScreenConstants.isSmallScreen(screenHeight);

    if (!isSmallScreen && _pageController.hasClients) {
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    _controller.selectedMicroTaskIndex.value = targetIndex;

    setState(() {
      _currentFilePath = _controller.getRecordedAudioPath();
      _hasRecording =
          _currentFilePath != null && File(_currentFilePath!).existsSync();
      _isRecording = false;
      _isPlaying = false;
      _isPaused = false;
      _recordingDuration = Duration.zero;
      _amplitudes.clear();
    });
  }

  Widget _buildMicroTaskPage(
      BuildContext context, TaskDetailEntity task, int index) {
    final microTask = task.microTasks[index];
    final isEligible = _isMicroTaskEligible(microTask);
    final isCurrentPage = index == _controller.selectedMicroTaskIndex.value;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTopSection(context, task, index),
        if (isEligible)
          _buildRecordingSection(context, task, index,
              useGlobalKeys: isCurrentPage),
      ],
    );
  }

  Widget _buildTopSection(
      BuildContext context, TaskDetailEntity task, int index) {
    return Column(
      children: [
        _buildImageDisplay(context, task, index),
        SubmissionWidget(),
      ],
    );
  }

  Widget _buildImageDisplay(
      BuildContext context, TaskDetailEntity task, int index) {
    final microTask = task.microTasks[index];
    return Container(
      key: widget.imageViewKey,
      width: double.infinity,
      height: getScreenHeight(context) * 0.3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: microTask.imageUrl != null && microTask.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: microTask.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.inputBgColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.inputBgColor,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 40),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.inputBgColor,
                child: Center(
                  child: Text(
                    'home.tasks.no_image_available'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRecordingSection(
      BuildContext context, TaskDetailEntity task, int index,
      {bool useGlobalKeys = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0, top: 10),
      child: Column(
        children: [
          _buildWaveformOrPlayer(context),
          _buildRecordingControls(task, index, useGlobalKeys: useGlobalKeys),
          if (!_hasRecording) _buildRecordingInstructions(task, index),
        ],
      ),
    );
  }

  Widget _buildWaveformOrPlayer(BuildContext context) {
    if (_isRecording) {
      return _buildRecordingWaveform(context);
    } else if ((_isPlaying) && _recordingDuration > Duration.zero) {
      return _buildPlaybackProgress(context);
    }
    return Container();
  }

  Widget _buildRecordingWaveform(BuildContext context) {
    final task = _controller.selectedTaskDetail.value!.task;
    final minSeconds = _controller.selectedTaskDetail.value!.minSeconds;
    final maxSeconds = _controller.selectedTaskDetail.value!.maxSeconds;
    final currentSeconds = _recordingDuration.inSeconds;

    Color durationColor = AppColors.darkGray;
    String? warningText;

    if (task.type == TaskType.Image_to_Speech) {
      if (minSeconds != null && currentSeconds < minSeconds) {
        durationColor = Colors.orange;
        warningText = 'home.tasks.need_more_seconds'
            .trParams({'seconds': (minSeconds - currentSeconds).toString()});
      } else if (maxSeconds != null && currentSeconds > maxSeconds) {
        durationColor = Colors.red;
        warningText = 'home.tasks.exceeded_by_seconds'
            .trParams({'seconds': (currentSeconds - maxSeconds).toString()});
      } else if (maxSeconds != null && currentSeconds > (maxSeconds * 0.8)) {
        durationColor = Colors.orange;
        warningText = 'home.tasks.seconds_remaining'
            .trParams({'seconds': (maxSeconds - currentSeconds).toString()});
      }
    }

    final minutes = _recordingDuration.inMinutes.toString().padLeft(2, '0');
    final seconds =
        (_recordingDuration.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: getScreenWidth(context) - 30,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEDF1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              fontSize: 14,
              color: durationColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (warningText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                warningText,
                style: TextStyle(fontSize: 10, color: durationColor),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: CustomPaint(
              size: Size(getScreenWidth(context) - 60, 50),
              painter: WaveformPainter(
                amplitudes: _amplitudes,
                color: durationColor == Colors.red
                    ? Colors.red
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackProgress(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _player.duration ?? _recordingDuration;

        final totalMinutes = duration.inMinutes.toString().padLeft(2, '0');
        final totalSeconds =
            (duration.inSeconds % 60).toString().padLeft(2, '0');

        final currentMinutes = position.inMinutes.toString().padLeft(2, '0');
        final currentSeconds =
            (position.inSeconds % 60).toString().padLeft(2, '0');

        return Container(
          width: getScreenWidth(context) - 30,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEDF1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                'Current: $currentMinutes:$currentSeconds / Total: $totalMinutes:$totalSeconds',
                style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordingControls(TaskDetailEntity task, int index,
      {bool useGlobalKeys = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_hasRecording) _buildRestartButton(useGlobalKey: useGlobalKeys),
        _buildMainRecordingButton(useGlobalKey: useGlobalKeys),
        if (_hasRecording) _buildSubmitButton(useGlobalKey: useGlobalKeys),
      ],
    );
  }

  Widget _buildRestartButton({bool useGlobalKey = true}) {
    return _buildRecordingButton(
      key: useGlobalKey ? widget.restartButtonKey : null,
      icon: const Icon(Icons.restart_alt, color: AppColors.darkGray),
      onPressed: _handleRestart,
    );
  }

  Widget _buildMainRecordingButton({bool useGlobalKey = true}) {
    return GestureDetector(
      key: useGlobalKey ? widget.micButtonKey : null,
      onTap: _hasRecording ? _togglePlayback : _toggleRecording,
      child: SizedBox(
        width: 120,
        height: 120,
        child: _isRecording || _hasRecording
            ? _buildWaveBlob()
            : _buildMicrophoneButton(),
      ),
    );
  }

  Widget _buildWaveBlob() {
    return WaveBlob(
      blobCount: 2,
      amplitude: 15000,
      scale: 6,
      autoScale: true,
      centerCircle: true,
      overCircle: true,
      circleColors: const [AppColors.primary],
      colors: [
        AppColors.primary.withValues(alpha: 0.2),
        AppColors.primary.withValues(alpha: 0.1),
      ],
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Icon(
          _getWaveBlobIcon(),
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  IconData _getWaveBlobIcon() {
    if (_hasRecording && _isPlaying) return Icons.pause;
    if (_hasRecording && !_isPlaying) return Icons.play_arrow;
    return Icons.stop;
  }

  Widget _buildMicrophoneButton() {
    return Container(
      width: 75,
      height: 75,
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.mic,
        color: Colors.white,
        size: 34,
      ),
    );
  }

  Widget _buildSubmitButton({bool useGlobalKey = true}) {
    return Obx(() => _buildRecordingButton(
          key: useGlobalKey ? widget.submitButtonKey : null,
          icon: _controller.isSubmittingTask.value
              ? const Center(
                  child: LoadingWidget(
                    isTransparent: true,
                    size: 20,
                    height: 20,
                    width: 20,
                  ),
                )
              : const Icon(Icons.check, color: AppColors.primary),
          onPressed: _submitRecording,
        ));
  }

  Widget _buildRecordingInstructions(TaskDetailEntity task, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _isRecording
              ? 'home.tasks.recording'.tr
              : 'home.tasks.tap_to_record'.tr,
          style: TextStyle(
            color: (_isRecording && !_isPaused) || _isPlaying
                ? AppColors.primary
                : AppColors.grayText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (task.task.type == TaskType.Image_to_Speech &&
            (task.minSeconds != null || task.maxSeconds != null))
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _buildDurationText(task.minSeconds, task.maxSeconds),
              style: const TextStyle(fontSize: 12, color: AppColors.grayText),
            ),
          ),
        if (task.microTasks[index].acceptanceStatus == MicroTaskStatus.REJECTED)
          Text(
            'home.tasks.attempts_left'.trParams({
              'count': (task.microTasks[index].allowedRetry -
                      task.microTasks[index].currentRetry)
                  .toString()
            }),
            style: const TextStyle(fontSize: 10, color: AppColors.primary),
          ),
      ],
    );
  }

  Widget _buildRecordingButton(
          {Key? key, required Widget icon, required VoidCallback onPressed}) =>
      GestureDetector(
        key: key,
        onTap: onPressed,
        child: Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Color(0xFFE3EbF3),
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
      );

  String _buildDurationText(int? minSeconds, int? maxSeconds) {
    if (minSeconds != null && maxSeconds != null) {
      return 'home.tasks.duration_range'.trParams(
          {'min': minSeconds.toString(), 'max': maxSeconds.toString()});
    } else if (minSeconds != null) {
      return 'home.tasks.min_duration'.trParams({'min': minSeconds.toString()});
    } else if (maxSeconds != null) {
      return 'home.tasks.max_duration'.trParams({'max': maxSeconds.toString()});
    }
    return '';
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  WaveformPainter({required this.amplitudes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / amplitudes.length;
    final centerY = size.height / 2;

    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * barWidth;
      final amplitude = amplitudes[i];
      final barHeight = (amplitude / 100) * size.height * 0.8;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes;
  }
}
