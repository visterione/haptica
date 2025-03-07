import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

/// Види кнопок
enum AppButtonType {
  /// Основна кнопка
  primary,

  /// Вторинна кнопка
  secondary,

  /// Кнопка з іконкою
  icon,

  /// Небезпечна кнопка
  danger,
}

/// Стани завантаження кнопки
enum AppButtonLoadingState {
  /// Звичайний стан
  idle,

  /// Стан завантаження
  loading,

  /// Стан успіху
  success,

  /// Стан помилки
  error,
}

/// Кнопка додатку
class AppButton extends StatelessWidget {
  /// Текст кнопки
  final String text;

  /// Функція, яка викликається при натисканні
  final VoidCallback? onPressed;

  /// Тип кнопки
  final AppButtonType type;

  /// Іконка
  final IconData? icon;

  /// Стан завантаження
  final AppButtonLoadingState loadingState;

  /// Розмір
  final Size? size;

  /// Радіус заокруглення
  final double? borderRadius;

  /// Конструктор
  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.loadingState = AppButtonLoadingState.idle,
    this.size,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Визначення стилів кнопки залежно від типу
    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = AppTheme.primaryColor;
        textColor = AppTheme.textColor;
        borderColor = null;
        break;
      case AppButtonType.secondary:
        backgroundColor = Colors.transparent;
        textColor = AppTheme.accentColor;
        borderColor = AppTheme.accentColor;
        break;
      case AppButtonType.icon:
        backgroundColor = AppTheme.primaryColor;
        textColor = AppTheme.textColor;
        borderColor = null;
        break;
      case AppButtonType.danger:
        backgroundColor = AppTheme.errorColor;
        textColor = Colors.white;
        borderColor = null;
        break;
    }

    // Якщо кнопка неактивна, змінюємо кольори
    if (onPressed == null) {
      backgroundColor = backgroundColor.withOpacity(0.3);
      textColor = textColor.withOpacity(0.7);
    }

    // Базовий віджет кнопки
    Widget buttonChild;

    // Залежно від стану завантаження, показуємо різний вміст
    switch (loadingState) {
      case AppButtonLoadingState.idle:
        if (type == AppButtonType.icon && icon != null) {
          buttonChild = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: AppTheme.paddingRegular),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        } else {
          buttonChild = Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        break;
      case AppButtonLoadingState.loading:
        buttonChild = SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        );
        break;
      case AppButtonLoadingState.success:
        buttonChild = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: textColor),
            const SizedBox(width: AppTheme.paddingRegular),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        break;
      case AppButtonLoadingState.error:
        buttonChild = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: textColor),
            const SizedBox(width: AppTheme.paddingRegular),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        break;
    }

    return Container(
      width: size?.width,
      height: size?.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.borderRadiusRegular),
        boxShadow: loadingState == AppButtonLoadingState.idle && onPressed != null
            ? AppTheme.lightShadow
            : null,
      ),
      child: ElevatedButton(
        onPressed: loadingState == AppButtonLoadingState.loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.borderRadiusRegular),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingRegular,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: buttonChild,
        ),
      ),
    );
  }
}