import 'package:ethiopian_date_picker/ethiopian_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leyu_mobile/core/localization/localization_controller.dart';

import '../theme/app_colors.dart';
import '../utils/screen_size.dart';

class DatePickerWidget extends StatefulWidget {
  final String label;
  final String? placeHolder;
  final TextEditingController controller;
  final FocusNode? focus;
  final FocusNode? focusNext;
  final EdgeInsets? padding;
  final VoidCallback? onEnter;
  final bool showLabel;
  final bool isOptional;
  final double borderRadius;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerWidget({
    super.key,
    required this.label,
    required this.controller,
    this.focus,
    this.focusNext,
    this.padding,
    this.onEnter,
    this.showLabel = false,
    this.placeHolder,
    this.isOptional = false,
    this.borderRadius = 18.0,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  Future<void> _onTap() async {
    final langCode = Get.find<LocalizationController>().locale.languageCode;
    DateTime? picked;

    if (langCode == 'en') {
      picked = await _showGregorianPicker();
    } else {
      picked = await _showEthiopianPicker(langCode);
    }

    if (picked != null) {
      widget.controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<DateTime?> _showGregorianPicker() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.darkGray,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<DateTime?> _showEthiopianPicker(String langCode) {
    final EthiopianDatePickerLocalization localization;
    switch (langCode) {
      case 'am':
        localization = EthiopianDatePickerLocalization.am;
        break;
      case 'om':
        localization = EthiopianDatePickerLocalization.or;
        break;
      default:
        localization = EthiopianDatePickerLocalization.us;
    }

    return showEthiopianDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      localization: localization,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.borderRadius;

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 3.0),
              child: Row(
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!widget.isOptional)
                    const Text(
                      " *",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.red,
                      ),
                    ),
                ],
              ),
            ),
          Container(
            width: getScreenWidth(context) < 500 ? double.infinity : 500,
            child: TextFormField(
              focusNode: widget.focus,
              controller: widget.controller,
              style: const TextStyle(fontSize: 15),
              textAlignVertical: TextAlignVertical.center,
              cursorColor: AppColors.primary,
              readOnly: true,
              onTap: _onTap,
              onFieldSubmitted: (_) {
                if (widget.focusNext != null) {
                  FocusScope.of(context).requestFocus(widget.focusNext);
                  Scrollable.ensureVisible(widget.focusNext!.context!,
                      alignment: 0.5);
                } else {
                  FocusScope.of(context).unfocus();
                  widget.onEnter?.call();
                }
              },
              validator: (value) =>
                  widget.isOptional ? null : _validateDate(value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBgColor,
                hintText: widget.placeHolder ??
                    'validation.enter_field'.trParams({'field': widget.label}),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                errorStyle: const TextStyle(fontSize: 10, color: AppColors.red),
                suffixIcon: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(radius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(radius),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.red),
                  borderRadius: BorderRadius.circular(radius),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(radius),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.red),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateDate(String? value) {
    print(value);
    if (value == null || value.isEmpty) {
      return 'validation.date_required'.trParams({'field': widget.label});
    }
    try {
      DateFormat('yyyy-MM-dd').parseStrict(value);
      return null;
    } catch (_) {
      return 'validation.date_invalid_format'.tr;
    }
  }
}
