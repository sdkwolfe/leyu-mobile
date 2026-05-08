import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leyu_mobile/core/constants/screen_constants.dart';
import 'package:leyu_mobile/core/theme/app_colors.dart';
import 'package:leyu_mobile/core/utils/message.dart';
import 'package:leyu_mobile/core/widgets/button.dart';
import 'package:leyu_mobile/features/home/domain/entities/task_detail_entity.dart';
import 'package:leyu_mobile/features/home/presentation/controllers/home_controller.dart';
import 'package:leyu_mobile/features/home/presentation/widgets/submission_widget.dart';
import 'package:leyu_mobile/features/home/presentation/widgets/task_navigation_bar.dart';
import 'package:leyu_mobile/features/home/presentation/widgets/validated_text_input_widget.dart';
import 'package:leyu_mobile/core/utils/screen_size.dart';
import 'package:leyu_mobile/features/home/domain/entities/micro_task_entity.dart';
import 'package:leyu_mobile/features/home/domain/entities/micro_task_status_enum.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageToTextWidget extends StatefulWidget {
  final GlobalKey? imageViewKey;
  final GlobalKey? textInputKey;
  final GlobalKey? submitButtonKey;
  final GlobalKey? navigationKey;

  const ImageToTextWidget({
    super.key,
    this.imageViewKey,
    this.textInputKey,
    this.submitButtonKey,
    this.navigationKey,
  });

  @override
  _ImageToTextWidgetState createState() => _ImageToTextWidgetState();
}

class _ImageToTextWidgetState extends State<ImageToTextWidget> {
  final HomeController _controller = Get.find();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final PageController _pageController = PageController();
  bool _isNavigating = false;
  bool _isTextValid = true;

  @override
  void initState() {
    super.initState();
    _initializeTextForCurrentMicroTask();
    _setupPageControllerListener();
  }

  @override
  void dispose() {
    _saveCurrentTextBeforeDispose();
    _textFocusNode.dispose();
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _initializeTextForCurrentMicroTask() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final microTaskId = _getCurrentMicroTaskId();
      _textController.text = _controller.savedTextOutputs[microTaskId] ?? '';
      setState(() {});
    });
  }

  void _setupPageControllerListener() {
    _pageController.addListener(() {
      if (_isNavigating) return;

      final newIndex = _pageController.page?.round() ?? 0;
      // Only respond to settled pages (not mid-animation fractional values)
      final isSettled = (_pageController.page! - newIndex).abs() < 0.01;
      if (!isSettled) return;

      if (_controller.selectedMicroTaskIndex.value != newIndex) {
        _saveCurrentTextIfEligible();
        _updateToNewMicroTask(newIndex);
      }
    });
  }

  void _saveCurrentTextBeforeDispose() {
    final currentMicroTask = _getCurrentMicroTask();
    if (_isMicroTaskEligible(currentMicroTask)) {
      final currentText = _textController.text.trim();
      if (currentText.isNotEmpty) {
        _controller.saveTextOutput(currentText);
      }
    }
  }

  void _saveCurrentTextIfEligible() {
    final currentMicroTask = _getCurrentMicroTask();
    if (_isMicroTaskEligible(currentMicroTask)) {
      final currentText = _textController.text.trim();
      if (currentText.isNotEmpty) {
        _controller.saveTextOutput(currentText);
      }
    }
  }

  void _updateToNewMicroTask(int newIndex) {
    _controller.selectedMicroTaskIndex.value = newIndex;
    final newMicroTaskId =
        _controller.selectedTaskDetail.value!.microTasks[newIndex].id;
    setState(() {
      _textController.text = _controller.savedTextOutputs[newMicroTaskId] ?? '';
    });
  }

  bool _shouldAllowNavigationNext() {
    final task = _controller.selectedTaskDetail.value!;
    final currentMicroTask = _getCurrentMicroTask();

    if (!_isMicroTaskEligible(currentMicroTask)) {
      return true;
    }

    return _isTextValidForNavigation(task);
  }

  bool _shouldAllowNavigationPrevious() {
    return true;
  }

  bool _isTextValidForNavigation(TaskDetailEntity task) {
    final hasValidation =
        task.minCharacters != null || task.maxCharacters != null;

    if (!hasValidation) {
      return true;
    }

    final currentLength = _textController.text.trim().length;

    if (currentLength == 0) {
      return false;
    }
    if (task.minCharacters != null && currentLength < task.minCharacters!) {
      return false;
    }
    if (task.maxCharacters != null && currentLength > task.maxCharacters!) {
      return false;
    }

    return true;
  }

  bool _isMicroTaskEligible(MicroTaskEntity microTask) {
    return microTask.acceptanceStatus == MicroTaskStatus.NOT_STARTED ||
        (microTask.acceptanceStatus == MicroTaskStatus.REJECTED &&
            microTask.canRetry);
  }

  MicroTaskEntity _getCurrentMicroTask() {
    return _controller.selectedTaskDetail.value!
        .microTasks[_controller.selectedMicroTaskIndex.value!];
  }

  String _getCurrentMicroTaskId() {
    return _getCurrentMicroTask().id;
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
              _buildImageDisplay(context, microTask, useGlobalKey: true),
              _buildSubmissionInfo(),
              if (isEligible)
                _buildInputForm(context, task, microTask, useGlobalKeys: true),
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
    _saveCurrentTextIfEligible();

    if (_textFocusNode.hasFocus) {
      _textFocusNode.unfocus();
    }
    FocusScope.of(context).unfocus();

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ScreenConstants.isSmallScreen(screenHeight);

    // Set flag BEFORE animating so the listener ignores this transition
    _isNavigating = true;

    // Update index and text first
    _controller.selectedMicroTaskIndex.value = targetIndex;
    final newMicroTaskId = task.microTasks[targetIndex].id;
    setState(() {
      _textController.text = _controller.savedTextOutputs[newMicroTaskId] ?? '';
    });

    if (!isSmallScreen && _pageController.hasClients) {
      _pageController
          .animateToPage(
            targetIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          )
          .then((_) => _isNavigating = false);
    } else {
      _isNavigating = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _textFocusNode.canRequestFocus = true;
        setState(() {});
      }
    });
  }

  Widget _buildMicroTaskPage(
      BuildContext context, TaskDetailEntity task, int index) {
    final microTask = task.microTasks[index];
    final isEligible = _isMicroTaskEligible(microTask);
    final isCurrentPage = index == _controller.selectedMicroTaskIndex.value;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildImageDisplay(context, microTask, useGlobalKey: isCurrentPage),
        _buildSubmissionInfo(),
        const Spacer(),
        if (isEligible)
          _buildInputForm(context, task, microTask,
              useGlobalKeys: isCurrentPage),
      ],
    );
  }

  Widget _buildImageDisplay(BuildContext context, MicroTaskEntity microTask,
      {bool useGlobalKey = true}) {
    return Container(
      key: useGlobalKey ? widget.imageViewKey : null,
      width: double.infinity,
      height: getScreenHeight(context) * 0.35,
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

  Widget _buildSubmissionInfo() {
    return SubmissionWidget();
  }

  Widget _buildInputForm(
      BuildContext context, TaskDetailEntity task, MicroTaskEntity microTask,
      {bool useGlobalKeys = true}) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (microTask.acceptanceStatus == MicroTaskStatus.REJECTED)
            _buildAttemptsLeftText(microTask),
          SizedBox(height: getScreenHeight(context) * 0.005),
          _buildTextInput(task, useGlobalKey: useGlobalKeys),
          SizedBox(height: getScreenHeight(context) * 0.03),
          _buildActionButtons(context, task, useGlobalKeys: useGlobalKeys),
          SizedBox(height: getScreenHeight(context) * 0.03),
        ],
      ),
    );
  }

  Widget _buildAttemptsLeftText(MicroTaskEntity microTask) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'home.tasks.attempts_left'.trParams({
          'count': (microTask.allowedRetry - microTask.currentRetry).toString()
        }),
        style: const TextStyle(fontSize: 12, color: AppColors.primary),
      ),
    );
  }

  Widget _buildTextInput(TaskDetailEntity task, {bool useGlobalKey = true}) {
    return ValidatedTextInputWidget(
      key: useGlobalKey ? widget.textInputKey : null,
      label: 'common.text'.tr,
      controller: _textController,
      focus: _textFocusNode,
      placeHolder: 'home.tasks.type_text_placeholder'.tr,
      maxLines: 10,
      minCharacters: task.minCharacters,
      maxCharacters: task.maxCharacters,
      textInputAction: TextInputAction.done,
      onValidationChanged: (isValid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isTextValid != isValid) {
            setState(() => _isTextValid = isValid);
          }
        });
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, TaskDetailEntity task,
      {bool useGlobalKeys = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCancelButton(context),
        const SizedBox(width: 10),
        _buildSubmitButton(context, task, useGlobalKey: useGlobalKeys),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ButtonWidget(
      width: getScreenWidth(context) * 0.4,
      text: 'common.cancel'.tr,
      fontSize: 14,
      color: AppColors.darkGray,
      fill: false,
      onPressed: () => _textController.clear(),
    );
  }

  Widget _buildSubmitButton(BuildContext context, TaskDetailEntity task,
      {bool useGlobalKey = true}) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _textController,
      builder: (context, value, child) {
        final isButtonEnabled = _isSubmitButtonEnabled(task, value);

        return Obx(() => ButtonWidget(
              key: useGlobalKey ? widget.submitButtonKey : null,
              isLoading: _controller.isSubmittingTask.value,
              width: getScreenWidth(context) * 0.4,
              text: _getSubmitButtonText(task),
              loadingText: 'home.tasks.submitting'.tr,
              fontSize: 14,
              color: isButtonEnabled ? AppColors.primary : AppColors.darkGray,
              onPressed:
                  !isButtonEnabled ? null : () => _handleSubmit(context, task),
            ));
      },
    );
  }

  bool _isSubmitButtonEnabled(TaskDetailEntity task, TextEditingValue value) {
    final hasValidation =
        task.minCharacters != null || task.maxCharacters != null;
    return hasValidation
        ? (_isTextValid && value.text.trim().isNotEmpty)
        : value.text.trim().isNotEmpty;
  }

  String _getSubmitButtonText(TaskDetailEntity task) {
    final isLastTask =
        _controller.selectedMicroTaskIndex.value! < task.microTasks.length - 1;
    return isLastTask ? 'common.continue'.tr : 'common.submit'.tr;
  }

  Future<void> _handleSubmit(
      BuildContext context, TaskDetailEntity task) async {
    final inputText = _textController.text.trim();

    if (!_validateTextInput(inputText, task)) {
      return;
    }

    await _saveAndNavigate(context, task, inputText);
  }

  bool _validateTextInput(String inputText, TaskDetailEntity task) {
    if (inputText.isEmpty) {
      showErrorMessage('home.tasks.enter_text_error'.tr);
      return false;
    }

    if (task.minCharacters != null && inputText.length < task.minCharacters!) {
      showErrorMessage('home.tasks.text_too_short'
          .trParams({'min': task.minCharacters.toString()}));
      return false;
    }

    if (task.maxCharacters != null && inputText.length > task.maxCharacters!) {
      showErrorMessage('home.tasks.text_too_long'
          .trParams({'max': task.maxCharacters.toString()}));
      return false;
    }

    return true;
  }

  Future<void> _saveAndNavigate(
      BuildContext context, TaskDetailEntity task, String inputText) async {
    final currentIndex = _controller.selectedMicroTaskIndex.value!;
    final microTaskId = task.microTasks[currentIndex].id;

    _controller.savedTextOutputs[microTaskId] = inputText;
    await _controller.persistTextOutput(microTaskId, inputText);

    final nextEligibleIndex = _findNextEligibleIndex(task, currentIndex);

    if (nextEligibleIndex != null && mounted) {
      await _navigateToNextTask(context, task, nextEligibleIndex);
    } else {
      _submitFinalTask(inputText);
    }
  }

  int? _findNextEligibleIndex(TaskDetailEntity task, int currentIndex) {
    for (int i = currentIndex + 1; i < task.microTasks.length; i++) {
      final microTask = task.microTasks[i];
      if (_isMicroTaskEligible(microTask)) {
        return i;
      }
    }
    return null;
  }

  Future<void> _navigateToNextTask(
      BuildContext context, TaskDetailEntity task, int nextIndex) async {
    _textController.clear();

    if (_textFocusNode.hasFocus) {
      _textFocusNode.unfocus();
    }
    if (mounted) {
      FocusScope.of(context).unfocus();
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = ScreenConstants.isSmallScreen(screenHeight);

    if (isSmallScreen) {
      _controller.selectedMicroTaskIndex.value = nextIndex;
      final newMicroTaskId = task.microTasks[nextIndex].id;
      setState(() {
        _textController.text =
            _controller.savedTextOutputs[newMicroTaskId] ?? '';
      });
    } else {
      // Set flag BEFORE animating so the listener ignores this transition
      _isNavigating = true;

      _controller.selectedMicroTaskIndex.value = nextIndex;
      final newMicroTaskId = task.microTasks[nextIndex].id;
      setState(() {
        _textController.text =
            _controller.savedTextOutputs[newMicroTaskId] ?? '';
      });

      await _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      _isNavigating = false;
    }
  }

  void _submitFinalTask(String inputText) {
    final isSuccess = _controller.saveTextOutput(inputText);
    if (!isSuccess) {
      _textController.clear();
    }
  }
}
