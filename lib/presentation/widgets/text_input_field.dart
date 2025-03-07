import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

/// Поле введення тексту
class TextInputField extends StatelessWidget {
  /// Контролер тексту
  final TextEditingController controller;

  /// Підказка
  final String hintText;

  /// Заголовок
  final String? labelText;

  /// Іконка префіксу
  final IconData? prefixIcon;

  /// Іконка суфіксу
  final IconData? suffixIcon;

  /// Функція, яка викликається при натисканні на суфікс
  final VoidCallback? onSuffixPressed;

  /// Функція, яка викликається при зміні тексту
  final ValueChanged<String>? onChanged;

  /// Функція, яка викликається при завершенні редагування
  final ValueChanged<String>? onSubmitted;

  /// Кількість рядків
  final int? maxLines;

  /// Тип клавіатури
  final TextInputType keyboardType;

  /// Режим автокорекції
  final bool autocorrect;

  /// Капіталізація тексту
  final TextCapitalization textCapitalization;

  /// Режим тексту - пароль
  final bool obscureText;

  /// Текст помилки
  final String? errorText;

  /// Режим лише для читання
  final bool readOnly;

  /// Конструктор
  const TextInputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.errorText,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.paddingRegular),
            child: Text(
              labelText!,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeRegular,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            filled: true,
            fillColor: AppTheme.cardColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: maxLines! > 1 ? AppTheme.paddingMedium : AppTheme.paddingRegular,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.textLightColor)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
              icon: Icon(suffixIcon, color: AppTheme.textLightColor),
              onPressed: onSuffixPressed,
            )
                : null,
          ),
          style: const TextStyle(
            fontSize: AppTheme.fontSizeRegular,
            color: AppTheme.textColor,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          autocorrect: autocorrect,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          readOnly: readOnly,
        ),
      ],
    );
  }
}