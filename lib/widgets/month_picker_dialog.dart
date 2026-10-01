import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dialogue sélecteur de Mois et Année élégant et floral
class MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final Function(int year, int month) onMonthSelected;

  const MonthPickerDialog({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.onMonthSelected,
  });

  static void show(
    BuildContext context, {
    required int currentYear,
    required int currentMonth,
    required Function(int year, int month) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => MonthPickerDialog(
        initialYear: currentYear,
        initialMonth: currentMonth,
        onMonthSelected: onSelected,
      ),
    );
  }

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _year;
  late int _month;

  static const List<String> _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre & Fermeture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: AppTheme.primaryRose),
                    SizedBox(width: 8),
                    Text(
                      'Choisir le Mois',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sélecteur d'année
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryRoseLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _year--),
                    icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryRose),
                  ),
                  Text(
                    '$_year',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRoseDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _year++),
                    icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryRose),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grille des 12 mois
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.0,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNum = index + 1;
                final isSelected = monthNum == _month;

                return InkWell(
                  onTap: () {
                    setState(() => _month = monthNum);
                    widget.onMonthSelected(_year, _month);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.rosePetalGradient : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppTheme.dividerColor,
                      ),
                      boxShadow: isSelected ? AppTheme.softCardShadow : null,
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _monthNames[index],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textMain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
