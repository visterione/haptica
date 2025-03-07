import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_theme.dart';
import '../../domain/entities/recognition_result.dart';

/// Картка результату розпізнавання
class RecognitionResultCard extends StatelessWidget {
  /// Результат розпізнавання
  final RecognitionResult result;

  /// Функція, яка викликається при натисканні
  final VoidCallback? onTap;

  /// Форматтер дати
  static final DateFormat _dateFormat = DateFormat('HH:mm:ss dd.MM.yyyy');

  /// Конструктор
  const RecognitionResultCard({
    Key? key,
    required this.result,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confidencePercentage = (result.confidence * 100).toStringAsFixed(1);
    final dateString = _dateFormat.format(result.timestamp);

    // Визначення кольору в залежності від впевненості
    Color confidenceColor;
    if (result.confidence >= 0.9) {
      confidenceColor = AppTheme.successColor;
    } else if (result.confidence >= 0.75) {
      confidenceColor = AppTheme.warningColor;
    } else {
      confidenceColor = AppTheme.errorColor;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.paddingRegular),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхній ряд: ім'я жесту та впевненість
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      result.gesture.name,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingRegular,
                      vertical: AppTheme.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      '$confidencePercentage%',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        fontWeight: FontWeight.bold,
                        color: confidenceColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.paddingRegular),

              // Категорія жесту
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingRegular,
                      vertical: AppTheme.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      result.gesture.category.name,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Час розпізнавання
                  Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                ],
              ),

              // Опис жесту, якщо є
              if (result.gesture.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.paddingRegular),
                  child: Text(
                    result.gesture.description!,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeRegular,
                      color: AppTheme.textLightColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}