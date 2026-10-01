import 'package:flutter/material.dart';
import '../models/daily_entry.dart';
import '../providers/discipline_state.dart';
import '../theme/app_theme.dart';
import '../widgets/month_picker_dialog.dart';
import '../widgets/sigles_info_dialog.dart';
import 'export_pdf_screen.dart';

class MonthlyGridScreen extends StatefulWidget {
  final DisciplineState state;

  const MonthlyGridScreen({super.key, required this.state});

  @override
  State<MonthlyGridScreen> createState() => _MonthlyGridScreenState();
}

class _MonthlyGridScreenState extends State<MonthlyGridScreen> {
  late ScrollController _headerScrollCtrl;
  late ScrollController _dataScrollCtrl;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _headerScrollCtrl = ScrollController();
    _dataScrollCtrl = ScrollController();

    // Synchronisation bidirectionnelle du défilement horizontal de l'en-tête et des données
    _headerScrollCtrl.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_dataScrollCtrl.hasClients && _dataScrollCtrl.offset != _headerScrollCtrl.offset) {
        _dataScrollCtrl.jumpTo(_headerScrollCtrl.offset);
      }
      _isSyncing = false;
    });

    _dataScrollCtrl.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_headerScrollCtrl.hasClients && _headerScrollCtrl.offset != _dataScrollCtrl.offset) {
        _headerScrollCtrl.jumpTo(_dataScrollCtrl.offset);
      }
      _isSyncing = false;
    });
  }

  @override
  void dispose() {
    _headerScrollCtrl.dispose();
    _dataScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final report = state.currentReport;
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Fiche Mensuelle ${report.monthNameUpper} ${report.year}'),
        actions: [
          IconButton(
            onPressed: () => SiglesInfoDialog.show(context),
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryRose),
            tooltip: 'Guide des Sigles CMCI',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExportPdfScreen(state: state),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryRose),
            tooltip: 'Aperçu & Partager PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- BARRE DE NAVIGATION DU MOIS AVEC POPUP SÉLECTEUR ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => state.previousMonth(),
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  tooltip: 'Mois précédent',
                ),
                InkWell(
                  onTap: () {
                    MonthPickerDialog.show(
                      context,
                      currentYear: state.selectedDate.year,
                      currentMonth: state.selectedDate.month,
                      onSelected: (year, month) {
                        state.selectDate(DateTime(year, month, 1));
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.rosePetalGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softCardShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${report.monthNameUpper} ${report.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => state.nextMonth(),
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  tooltip: 'Mois suivant',
                ),
              ],
            ),
          ),

          // ---- STATISTIQUES RÉSUMÉES DU HAUT ----
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.dividerColor),
              boxShadow: AppTheme.softCardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat(
                  label: 'Prière Seule',
                  value: DailyEntry.formatMinutes(report.totalPriereSeuleMinutes),
                  icon: Icons.access_time_rounded,
                ),
                _buildSummaryStat(
                  label: 'Moyenne/jr',
                  value: report.formattedDailyAverage.split('/')[0],
                  icon: Icons.trending_up_rounded,
                ),
                _buildSummaryStat(
                  label: 'Bible (LB)',
                  value: '${report.totalLbChapters} chap.',
                  icon: Icons.menu_book_rounded,
                ),
                _buildSummaryStat(
                  label: 'Âmes (PG)',
                  value: '${report.totalPgSouls}',
                  icon: Icons.person_add_alt_1_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Note d'aide cliquable
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, size: 14, color: AppTheme.primaryRose),
                const SizedBox(width: 5),
                Text(
                  'Cliquez sur n\'importe quelle case pour la modifier',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted.withOpacity(0.9), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ---- TABLEAU : EN-TÊTE FIXÉ EN HAUT + JOURS À GAUCHE + RESPONSIVE DESKTOP/MOBILE ----
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dayColWidth = 46.0;
                // Margins horizontal: 14 on left + 14 on right = 28
                final availableTableWidth = constraints.maxWidth - dayColWidth;
                const minTableWidth = 630.0;
                final tableWidth = availableTableWidth > minTableWidth ? availableTableWidth : minTableWidth;

                final colPkl = tableWidth * (63.0 / 630.0);
                final colPsm = tableWidth * (63.0 / 630.0);
                final colPaut = tableWidth * (63.0 / 630.0);
                final colRdqd = tableWidth * (63.0 / 630.0);
                final colLb = tableWidth * (58.0 / 630.0);
                final colLc = tableWidth * (62.0 / 630.0);
                final colEvg = tableWidth * (62.0 / 630.0);
                final colPg = tableWidth * (56.0 / 630.0);
                final colJp = tableWidth * (62.0 / 630.0);
                final colRs = tableWidth * (62.0 / 630.0);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.dividerColor),
                    boxShadow: AppTheme.softCardShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Column(
                      children: [
                        // 1. EN-TÊTE FIXÉ EN HAUT (J + DISCIPLINES PKL..RS)
                        Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryRoseLight,
                            border: Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 1.5)),
                          ),
                          child: Row(
                            children: [
                              // Coin haut-gauche : J
                              Container(
                                width: dayColWidth,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF6DDE6),
                                  border: Border(right: BorderSide(color: AppTheme.dividerColor, width: 1.5)),
                                ),
                                child: const Text(
                                  'J',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppTheme.primaryRoseDark,
                                  ),
                                ),
                              ),
                              // En-tête des disciplines défilable horizontalement
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _headerScrollCtrl,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: tableWidth,
                                    child: Row(
                                      children: [
                                        _buildHeaderCell('PKL', colPkl),
                                        _buildHeaderCell('PSM', colPsm),
                                        _buildHeaderCell('PAUT', colPaut),
                                        _buildHeaderCell('RDQD', colRdqd),
                                        _buildHeaderCell('LB', colLb),
                                        _buildHeaderCell('LC', colLc),
                                        _buildHeaderCell('EVG', colEvg),
                                        _buildHeaderCell('PG', colPg),
                                        _buildHeaderCell('JP/JC', colJp),
                                        _buildHeaderCell('RS', colRs),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. CORPS DU TABLEAU (DÉFILABLE VERTICALEMENT)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Colonne des Jours (J 1..31 + TOT) fixée à gauche
                                SizedBox(
                                  width: dayColWidth,
                                  child: Column(
                                    children: [
                                      ...report.entries.map((e) {
                                        final isToday = e.day == DateTime.now().day &&
                                            report.month == DateTime.now().month &&
                                            report.year == DateTime.now().year;
                                        return InkWell(
                                          onTap: () => _showDaySummary(context, e, report.year, report.month),
                                          child: Container(
                                            height: 34,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isToday
                                                  ? const Color(0xFFFFDDE6)
                                                  : (e.day % 2 == 0 ? Colors.white : const Color(0xFFFCF8FA)),
                                              border: const Border(
                                                bottom: BorderSide(color: AppTheme.dividerColor),
                                                right: BorderSide(color: AppTheme.dividerColor, width: 1.5),
                                              ),
                                            ),
                                            child: Text(
                                              '${e.day}',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: isToday ? AppTheme.primaryRoseDark : AppTheme.textMain,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      // Ligne TOT
                                      Container(
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEBD3DC),
                                          border: Border(
                                            right: BorderSide(color: AppTheme.dividerColor, width: 1.5),
                                          ),
                                        ),
                                        child: const Text(
                                          'TOT',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: AppTheme.primaryRoseDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Grille des valeurs des disciplines (défilable horizontalement et synchronisée)
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _dataScrollCtrl,
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: tableWidth,
                                      child: Column(
                                        children: [
                                          ...report.entries.map((e) {
                                            final isToday = e.day == DateTime.now().day &&
                                                report.month == DateTime.now().month &&
                                                report.year == DateTime.now().year;

                                            return Container(
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: isToday
                                                    ? AppTheme.primaryBlush.withOpacity(0.35)
                                                    : (e.day % 2 == 0 ? Colors.white : const Color(0xFFFCF8FA)),
                                                border: const Border(bottom: BorderSide(color: AppTheme.dividerColor)),
                                              ),
                                              child: Row(
                                                children: [
                                                  _buildDataCell(
                                                    DailyEntry.formatMinutes(e.pklMinutes),
                                                    colPkl,
                                                    onTap: () => _editDurationCell(
                                                      context, e, 'Prière Faiseur de disciple', 'PKL', e.pklMinutes,
                                                      (v) => e.pklMinutes = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    DailyEntry.formatMinutes(e.psmMinutes),
                                                    colPsm,
                                                    onTap: () => _editDurationCell(
                                                      context, e, 'Prière pour moi', 'PSM', e.psmMinutes,
                                                      (v) => e.psmMinutes = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    DailyEntry.formatMinutes(e.pautMinutes),
                                                    colPaut,
                                                    onTap: () => _editDurationCell(
                                                      context, e, 'Prières Autres', 'PAUT', e.pautMinutes,
                                                      (v) => e.pautMinutes = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    DailyEntry.formatMinutes(e.rdqdMinutes),
                                                    colRdqd,
                                                    onTap: () => _editDurationCell(
                                                      context, e, 'RDQD', 'RDQD', e.rdqdMinutes,
                                                      (v) => e.rdqdMinutes = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    e.lbChapters > 0 ? '${e.lbChapters}' : '',
                                                    colLb,
                                                    onTap: () => _editCountCell(
                                                      context, e, 'Lecture Biblique (Chap.)', 'LB', e.lbChapters,
                                                      (v) => e.lbChapters = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    DailyEntry.formatMinutes(e.lcMinutes),
                                                    colLc,
                                                    onTap: () => _editDurationCell(
                                                      context, e, 'Lecture Chrétienne', 'LC', e.lcMinutes,
                                                      (v) => e.lcMinutes = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    DailyEntry.formatMinutes(e.evgMinutes),
                                                    colEvg,
                                                    onTap: () => _editDurationCell(
                                                      context, e, 'Évangélisation', 'EVG', e.evgMinutes,
                                                      (v) => e.evgMinutes = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    e.pgSouls > 0 ? '${e.pgSouls}' : '',
                                                    colPg,
                                                    onTap: () => _editCountCell(
                                                      context, e, 'Personnes Gagnées', 'PG', e.pgSouls,
                                                      (v) => e.pgSouls = v,
                                                    ),
                                                  ),
                                                  _buildDataCell(
                                                    e.fasting.code,
                                                    colJp,
                                                    isBold: true,
                                                    onTap: () => _editFastingCell(context, e),
                                                  ),
                                                  _buildDataCell(
                                                    DailyEntry.formatMinutes(e.rsMinutes),
                                                    colRs,
                                                    onTap: () => _editDurationCell(
                                                      context, e, 'Retraite Spirituelle', 'RS', e.rsMinutes,
                                                      (v) => e.rsMinutes = v,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),

                                          // Ligne TOT
                                          Container(
                                            height: 36,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF2E6EB),
                                            ),
                                            child: Row(
                                              children: [
                                                _buildDataCell(DailyEntry.formatMinutes(report.totalPklMinutes), colPkl, isBold: true),
                                                _buildDataCell(DailyEntry.formatMinutes(report.totalPsmMinutes), colPsm, isBold: true),
                                                _buildDataCell(DailyEntry.formatMinutes(report.totalPautMinutes), colPaut, isBold: true),
                                                _buildDataCell('${report.rdqdDaysCount}/${report.daysInMonth}', colRdqd, isBold: true),
                                                _buildDataCell('${report.totalLbChapters}', colLb, isBold: true),
                                                _buildDataCell(DailyEntry.formatMinutes(report.totalLcMinutes), colLc, isBold: true),
                                                _buildDataCell(DailyEntry.formatMinutes(report.totalEvgMinutes), colEvg, isBold: true),
                                                _buildDataCell('${report.totalPgSouls}', colPg, isBold: true),
                                                _buildDataCell('${report.fastingDaysCount}j', colJp, isBold: true),
                                                _buildDataCell(DailyEntry.formatMinutes(report.totalRsMinutes), colRs, isBold: true),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---- DIALOGUES D'ÉDITION DIRECTE DANS LA GRILLE ----

  void _editDurationCell(
    BuildContext context,
    DailyEntry entry,
    String title,
    String abbreviation,
    int initialMinutes,
    Function(int) onSave,
  ) {
    int currentMinutes = initialMinutes;
    final hoursCtrl = TextEditingController(text: '${currentMinutes ~/ 60}');
    final minsCtrl = TextEditingController(text: '${currentMinutes % 60}');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void updateFromControllers() {
            final h = int.tryParse(hoursCtrl.text) ?? 0;
            final m = int.tryParse(minsCtrl.text) ?? 0;
            currentMinutes = (h * 60) + m;
          }

          void setValues(int totalMins) {
            currentMinutes = totalMins < 0 ? 0 : totalMins;
            final h = currentMinutes ~/ 60;
            final m = currentMinutes % 60;
            hoursCtrl.text = '$h';
            minsCtrl.text = '$m';
            setState(() {});
          }

          void addMinutes(int delta) {
            updateFromControllers();
            setValues(currentMinutes + delta);
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRoseLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    abbreviation,
                    style: const TextStyle(
                      color: AppTheme.primaryRoseDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title (Jour ${entry.day})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tapez la durée au clavier ou ajustez :',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),

                  // Saisie Heures & Minutes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Heures
                      Expanded(
                        child: _buildDurationField(
                          label: 'Heures',
                          controller: hoursCtrl,
                          onChanged: (_) {
                            updateFromControllers();
                            setState(() {});
                          },
                          onDecrement: () {
                            updateFromControllers();
                            final h = int.tryParse(hoursCtrl.text) ?? 0;
                            if (h > 0) {
                              hoursCtrl.text = '${h - 1}';
                              updateFromControllers();
                              setState(() {});
                            }
                          },
                          onIncrement: () {
                            updateFromControllers();
                            final h = int.tryParse(hoursCtrl.text) ?? 0;
                            hoursCtrl.text = '${h + 1}';
                            updateFromControllers();
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Minutes
                      Expanded(
                        child: _buildDurationField(
                          label: 'Minutes',
                          controller: minsCtrl,
                          onChanged: (_) {
                            updateFromControllers();
                            setState(() {});
                          },
                          onDecrement: () {
                            updateFromControllers();
                            final m = int.tryParse(minsCtrl.text) ?? 0;
                            if (m >= 5) {
                              minsCtrl.text = '${m - 5}';
                            } else {
                              minsCtrl.text = '0';
                            }
                            updateFromControllers();
                            setState(() {});
                          },
                          onIncrement: () {
                            updateFromControllers();
                            final m = int.tryParse(minsCtrl.text) ?? 0;
                            minsCtrl.text = '${m + 5}';
                            updateFromControllers();
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total
                  Builder(builder: (_) {
                    final h = int.tryParse(hoursCtrl.text) ?? 0;
                    final m = int.tryParse(minsCtrl.text) ?? 0;
                    final total = (h * 60) + m;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRoseLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Total : ${DailyEntry.formatMinutes(total)} ($total min)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRoseDark,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // Raccourcis rapides
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildChip('+15m', () => addMinutes(15)),
                      _buildChip('+30m', () => addMinutes(30)),
                      _buildChip('+1h', () => addMinutes(60)),
                      _buildChip('Effacer (0)', () => setValues(0), isDanger: true),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler', style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  final h = int.tryParse(hoursCtrl.text) ?? 0;
                  final m = int.tryParse(minsCtrl.text) ?? 0;
                  final total = (h * 60) + m;
                  onSave(total);
                  widget.state.updateDayEntry(entry);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Valider'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editCountCell(
    BuildContext context,
    DailyEntry entry,
    String title,
    String abbreviation,
    int initialCount,
    Function(int) onSave,
  ) {
    final controller = TextEditingController(text: initialCount > 0 ? '$initialCount' : '0');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void adjust(int delta) {
            final current = int.tryParse(controller.text) ?? 0;
            final updated = (current + delta).clamp(0, 9999);
            controller.text = '$updated';
            setState(() {});
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRoseLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    abbreviation,
                    style: const TextStyle(
                      color: AppTheme.primaryRoseDark,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title (Jour ${entry.day})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tapez la quantité au clavier ou ajustez :',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => adjust(-1),
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryRose, size: 26),
                      ),
                      Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryRoseDark),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            fillColor: AppTheme.primaryRoseLight,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        onPressed: () => adjust(1),
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryRose, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildChip('+1', () => adjust(1)),
                      _buildChip('+5', () => adjust(5)),
                      _buildChip('+10', () => adjust(10)),
                      _buildChip('Effacer (0)', () {
                        controller.text = '0';
                        setState(() {});
                      }, isDanger: true),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler', style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  final parsed = int.tryParse(controller.text) ?? 0;
                  onSave(parsed);
                  widget.state.updateDayEntry(entry);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Valider'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editFastingCell(BuildContext context, DailyEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Jeûne du Jour ${entry.day} (JP/JC)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Aucun jeûne'),
              leading: Radio<FastingType>(
                value: FastingType.none,
                groupValue: entry.fasting,
                onChanged: (v) {
                  entry.fasting = v!;
                  widget.state.updateDayEntry(entry);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('JP (Jeûne Partiel)'),
              leading: Radio<FastingType>(
                value: FastingType.partial,
                groupValue: entry.fasting,
                onChanged: (v) {
                  entry.fasting = v!;
                  widget.state.updateDayEntry(entry);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('JC (Jeûne Complet)'),
              leading: Radio<FastingType>(
                value: FastingType.complete,
                groupValue: entry.fasting,
                onChanged: (v) {
                  entry.fasting = v!;
                  widget.state.updateDayEntry(entry);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDaySummary(BuildContext context, DailyEntry entry, int year, int month) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jour ${entry.day} - Récapitulatif',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Total prière : ${DailyEntry.formatMinutesLong(entry.totalPrayerMinutes)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryRose),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.state.selectDate(DateTime(year, month, entry.day));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Jour ${entry.day} sélectionné dans l\'onglet Aujourd\'hui 🌸'),
                      backgroundColor: AppTheme.primaryRose,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                label: const Text('Ouvrir dans l\'onglet Aujourd\'hui'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryRose),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? '0' : value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryRoseDark,
        ),
      ),
    );
  }

  Widget _buildDataCell(String value, double width, {bool isBold = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: 34,
        child: Center(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: onTap != null && value.isNotEmpty ? AppTheme.primaryRoseDark : AppTheme.textMain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryRoseLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.remove_rounded, size: 18, color: AppTheme.primaryRose),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryRoseDark),
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 6), border: InputBorder.none),
                  onChanged: onChanged,
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryRose),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, VoidCallback onTap, {bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFFF0F2) : const Color(0xFFF7ECF0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDanger ? const Color(0xFFF8CFDC) : AppTheme.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDanger ? const Color(0xFFC4436A) : AppTheme.primaryRoseDark),
        ),
      ),
    );
  }
}
