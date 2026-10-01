import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_entry.dart';
import '../providers/discipline_state.dart';
import '../theme/app_theme.dart';
import '../widgets/floral_decorations.dart';
import '../widgets/month_picker_dialog.dart';
import '../widgets/sigles_info_dialog.dart';

class TodayScreen extends StatefulWidget {
  final DisciplineState state;

  const TodayScreen({super.key, required this.state});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late ScrollController _calendarScrollController;

  @override
  void initState() {
    super.initState();
    _calendarScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedDate != widget.state.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDay(animate: true);
      });
    }
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDay({bool animate = true}) {
    if (!_calendarScrollController.hasClients) return;
    final dayIndex = widget.state.selectedDate.day - 1;
    final screenWidth = MediaQuery.of(context).size.width;
    // Chaque élément fait 52px de largeur + 8px de marge = 60px
    final targetOffset = (dayIndex * 60.0) - (screenWidth / 2) + 30.0;
    final maxScroll = _calendarScrollController.position.maxScrollExtent;
    final safeOffset = targetOffset.clamp(0.0, maxScroll);

    if (animate) {
      _calendarScrollController.animateTo(
        safeOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _calendarScrollController.jumpTo(safeOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final entry = state.selectedDayEntry;
    final selectedDate = state.selectedDate;
    final isToday = _isSameDay(selectedDate, DateTime.now());

    final formattedDateStr =
        DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate);
    final capitalizedDate = formattedDateStr.isNotEmpty
        ? formattedDateStr[0].toUpperCase() + formattedDateStr.substring(1)
        : '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- BANNIÈRE FLORALE INSPIRANTE AVEC ACTIONS ----
              FloralHeaderBanner(
                title: isToday
                    ? 'Aujourd’hui avec Dieu 🌸'
                    : 'Journée spirituelle 🌸',
                subtitle:
                    '« Cherchez premièrement le royaume et la justice de Dieu » - Matthieu 6:33',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => SiglesInfoDialog.show(context),
                      icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
                      tooltip: 'Guide des Sigles CMCI',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.userProfile.discipleName.isNotEmpty
                            ? state.userProfile.discipleName.split(' ').first
                            : 'Disciple',
                        style: const TextStyle(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ---- BARRE SÉLECTEUR DE MOIS & ANNÉE ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.dividerColor),
                        boxShadow: AppTheme.softCardShadow,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryRose, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMMM yyyy', 'fr_FR').format(selectedDate).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRoseDark,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryRose),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => SiglesInfoDialog.show(context),
                    icon: const Icon(Icons.help_outline_rounded, size: 16, color: AppTheme.primaryRose),
                    label: const Text(
                      'Sigles',
                      style: TextStyle(fontSize: 12, color: AppTheme.primaryRoseDark, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.dividerColor),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ---- SÉLECTEUR HORIZONTAL DES JOURS DU MOIS ----
              _buildHorizontalCalendar(context),
              const SizedBox(height: 12),

              // ---- BARRE D'INFOS DU JOUR ET RÉINITIALISATION ----
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dividerColor),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizedDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Total prière : ${DailyEntry.formatMinutesLong(entry.totalPrayerMinutes)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.primaryRose,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _confirmResetDay(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF8CFDC)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.rotate_left_rounded, size: 15, color: Color(0xFFC4436A)),
                            SizedBox(width: 4),
                            Text(
                              'Remise à zéro',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC4436A)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ---- SÉLECTEUR DE JEÛNE (INITIALISÉ À AUCUN PAR DÉFAUT) ----
              _buildFastingSelector(context, entry),
              const SizedBox(height: 14),

              // ---- CARTES DES DISCIPLINES AVEC AJOUT, DIMINUTION ET ÉDITION DIRECTE ----

              // 1. PSM: Prière pour moi
              FloralDisciplineCard(
                title: 'Prière pour moi',
                abbreviation: 'PSM',
                valueDisplay: DailyEntry.formatMinutes(entry.psmMinutes),
                icon: Icons.favorite_border_rounded,
                gradient: AppTheme.goldenSunbeamGradient,
                onAdd15m: () => state.addPsmMinutes(15),
                onAdd30m: () => state.addPsmMinutes(30),
                onAdd1h: () => state.addPsmMinutes(60),
                onSubtract15m: () => state.subtractPsmMinutes(15),
                onSubtract30m: () => state.subtractPsmMinutes(30),
                onClear: () => state.setPsmMinutes(0),
                onCustomTap: () => _showEditMinutesDialog(
                  context,
                  title: 'Prière pour moi (PSM)',
                  initialMinutes: entry.psmMinutes,
                  onSave: (m) => state.setPsmMinutes(m),
                ),
              ),

              // 2. RDQD: Rendez-vous Quotidien avec Dieu
              FloralDisciplineCard(
                title: 'Rendez-vous Quotidien avec Dieu',
                abbreviation: 'RDQD',
                valueDisplay: DailyEntry.formatMinutes(entry.rdqdMinutes),
                icon: Icons.favorite_rounded,
                gradient: AppTheme.rosePetalGradient,
                onAdd15m: () => state.addRdqdMinutes(15),
                onAdd30m: () => state.addRdqdMinutes(30),
                onAdd1h: () => state.addRdqdMinutes(60),
                onSubtract15m: () => state.subtractRdqdMinutes(15),
                onSubtract30m: () => state.subtractRdqdMinutes(30),
                onClear: () => state.setRdqdMinutes(0),
                onCustomTap: () => _showEditMinutesDialog(
                  context,
                  title: 'Rendez-vous Quotidien avec Dieu (RDQD)',
                  initialMinutes: entry.rdqdMinutes,
                  onSave: (m) => state.setRdqdMinutes(m),
                ),
              ),

              // 3. PKL: Prière pour le Faiseur de disciple
              FloralDisciplineCard(
                title: 'Prière pour le Faiseur de Disciple',
                abbreviation: 'PKL',
                valueDisplay: DailyEntry.formatMinutes(entry.pklMinutes),
                icon: Icons.volunteer_activism_rounded,
                gradient: AppTheme.lavenderBlossomGradient,
                onAdd15m: () => state.addPklMinutes(15),
                onAdd30m: () => state.addPklMinutes(30),
                onAdd1h: () => state.addPklMinutes(60),
                onSubtract15m: () => state.subtractPklMinutes(15),
                onSubtract30m: () => state.subtractPklMinutes(30),
                onClear: () => state.setPklMinutes(0),
                onCustomTap: () => _showEditMinutesDialog(
                  context,
                  title: 'Prière pour le Faiseur de disciple (PKL)',
                  initialMinutes: entry.pklMinutes,
                  onSave: (m) => state.setPklMinutes(m),
                ),
              ),

              // 4. PAUT: Prières Autres
              FloralDisciplineCard(
                title: 'Prières Autres (Combat, Intercession)',
                abbreviation: 'PAUT',
                valueDisplay: DailyEntry.formatMinutes(entry.pautMinutes),
                icon: Icons.shield_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C8DFB), Color(0xFF4A6FD4)],
                ),
                onAdd15m: () => state.addPautMinutes(15),
                onAdd30m: () => state.addPautMinutes(30),
                onAdd1h: () => state.addPautMinutes(60),
                onSubtract15m: () => state.subtractPautMinutes(15),
                onSubtract30m: () => state.subtractPautMinutes(30),
                onClear: () => state.setPautMinutes(0),
                onCustomTap: () => _showEditMinutesDialog(
                  context,
                  title: 'Prières Autres (PAUT)',
                  initialMinutes: entry.pautMinutes,
                  onSave: (m) => state.setPautMinutes(m),
                ),
              ),

              // 5. LB: Lecture Biblique (Chapitres)
              FloralDisciplineCard(
                title: 'Lecture Biblique',
                abbreviation: 'LB',
                valueDisplay: entry.lbChapters > 0
                    ? '${entry.lbChapters} chapitres'
                    : '',
                icon: Icons.menu_book_rounded,
                isChapterCount: true,
                gradient: const LinearGradient(
                  colors: [Color(0xFF5AB69F), Color(0xFF388E77)],
                ),
                onAdd15m: () => state.addLbChapters(1),
                onAdd30m: () => state.addLbChapters(5),
                onAdd1h: () => state.addLbChapters(10),
                onSubtract15m: () => state.subtractLbChapters(1),
                onSubtract30m: () => state.subtractLbChapters(5),
                onClear: () => state.setLbChapters(0),
                onCustomTap: () => _showEditCountDialog(
                  context,
                  title: 'Lecture Biblique (LB - Chapitres)',
                  initialCount: entry.lbChapters,
                  onSave: (c) => state.setLbChapters(c),
                ),
              ),

              // 6. LC: Lecture Chrétienne (Livres)
              FloralDisciplineCard(
                title: 'Lecture Chrétienne (Livres)',
                abbreviation: 'LC',
                valueDisplay: DailyEntry.formatMinutes(entry.lcMinutes),
                icon: Icons.auto_stories_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE587B3), Color(0xFFC45688)],
                ),
                onAdd15m: () => state.addLcMinutes(15),
                onAdd30m: () => state.addLcMinutes(30),
                onAdd1h: () => state.addLcMinutes(60),
                onSubtract15m: () => state.subtractLcMinutes(15),
                onSubtract30m: () => state.subtractLcMinutes(30),
                onClear: () => state.setLcMinutes(0),
                onCustomTap: () => _showEditMinutesDialog(
                  context,
                  title: 'Lecture Chrétienne (LC)',
                  initialMinutes: entry.lcMinutes,
                  onSave: (m) => state.setLcMinutes(m),
                ),
              ),

              // 7. EVG: Évangélisation
              FloralDisciplineCard(
                title: 'Évangélisation (Témoignage)',
                abbreviation: 'EVG',
                valueDisplay: DailyEntry.formatMinutes(entry.evgMinutes),
                icon: Icons.record_voice_over_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF39C6B), Color(0xFFD6733E)],
                ),
                onAdd15m: () => state.addEvgMinutes(15),
                onAdd30m: () => state.addEvgMinutes(30),
                onAdd1h: () => state.addEvgMinutes(60),
                onSubtract15m: () => state.subtractEvgMinutes(15),
                onSubtract30m: () => state.subtractEvgMinutes(30),
                onClear: () => state.setEvgMinutes(0),
                onCustomTap: () => _showEditMinutesDialog(
                  context,
                  title: 'Évangélisation (EVG)',
                  initialMinutes: entry.evgMinutes,
                  onSave: (m) => state.setEvgMinutes(m),
                ),
              ),

              // 8. RS: Retraite Spirituelle
              FloralDisciplineCard(
                title: 'Retraite Spirituelle',
                abbreviation: 'RS',
                valueDisplay: DailyEntry.formatMinutes(entry.rsMinutes),
                icon: Icons.nature_people_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E7AB5), Color(0xFF67518C)],
                ),
                onAdd15m: () => state.addRsMinutes(15),
                onAdd30m: () => state.addRsMinutes(30),
                onAdd1h: () => state.addRsMinutes(60),
                onSubtract15m: () => state.subtractRsMinutes(15),
                onSubtract30m: () => state.subtractRsMinutes(30),
                onClear: () => state.setRsMinutes(0),
                onCustomTap: () => _showEditMinutesDialog(
                  context,
                  title: 'Retraite Spirituelle (RS)',
                  initialMinutes: entry.rsMinutes,
                  onSave: (m) => state.setRsMinutes(m),
                ),
              ),

              // 9. PG: Personnes Gagnées (Âmes)
              FloralDisciplineCard(
                title: 'Personnes Gagnées à Christ',
                abbreviation: 'PG',
                valueDisplay: entry.pgSouls > 0 ? '${entry.pgSouls} âmes' : '',
                icon: Icons.person_add_alt_1_rounded,
                isChapterCount: true,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF16E8E), Color(0xFFC8466D)],
                ),
                onAdd15m: () => state.addPgSouls(1),
                onAdd30m: () => state.addPgSouls(5),
                onAdd1h: () => state.addPgSouls(10),
                onSubtract15m: () => state.subtractPgSouls(1),
                onSubtract30m: () => state.subtractPgSouls(5),
                onClear: () => state.setPgSouls(0),
                onCustomTap: () => _showEditCountDialog(
                  context,
                  title: 'Personnes Gagnées (PG)',
                  initialCount: entry.pgSouls,
                  onSave: (c) => state.setPgSouls(c),
                ),
              ),

              const SizedBox(height: 70), // Pour laisser de la place au FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCalendar(BuildContext context) {
    final state = widget.state;
    final now = DateTime.now();
    final currentMonth = state.selectedDate.month;
    final currentYear = state.selectedDate.year;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _calendarScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(currentYear, currentMonth, day);
          final isSelected = day == state.selectedDate.day;
          final isCurrentDay = _isSameDay(date, now);

          return GestureDetector(
            onTap: () => state.selectDate(date),
            child: Container(
              width: 52,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.rosePetalGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isCurrentDay
                          ? AppTheme.primaryRose
                          : AppTheme.dividerColor),
                  width: isCurrentDay && !isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryRose.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : AppTheme.softCardShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'fr_FR').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textMain,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFastingSelector(BuildContext context, DailyEntry entry) {
    final state = widget.state;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant_menu_rounded,
                  size: 18, color: AppTheme.primaryRose),
              SizedBox(width: 8),
              Text(
                'Jeûne du jour (JP / JC) :',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFastingChip(
                label: 'Aucun',
                isSelected: entry.fasting == FastingType.none,
                onTap: () => state.setFasting(FastingType.none),
              ),
              const SizedBox(width: 8),
              _buildFastingChip(
                label: 'JP (Partiel)',
                isSelected: entry.fasting == FastingType.partial,
                onTap: () => state.setFasting(FastingType.partial),
              ),
              const SizedBox(width: 8),
              _buildFastingChip(
                label: 'JC (Complet)',
                isSelected: entry.fasting == FastingType.complete,
                onTap: () => state.setFasting(FastingType.complete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFastingChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryRose : AppTheme.primaryRoseLight,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.primaryRoseDark,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmResetDay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Réinitialiser ce jour ?'),
        content: const Text(
            'Voulez-vous remettre toutes les valeurs de cette journée à zéro ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.state.resetSelectedDay();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC4436A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _showEditMinutesDialog(
    BuildContext context, {
    required String title,
    required int initialMinutes,
    required Function(int) onSave,
  }) {
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
            title: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Entrez la durée au clavier ou utilisez les boutons :',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Saisie directe Heures & Minutes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Heures
                      Expanded(
                        child: _buildDurationInputField(
                          label: 'Heures (h)',
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
                      const SizedBox(width: 12),
                      // Minutes
                      Expanded(
                        child: _buildDurationInputField(
                          label: 'Minutes (min)',
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
                  const SizedBox(height: 14),

                  // Total calculé
                  Builder(builder: (_) {
                    final h = int.tryParse(hoursCtrl.text) ?? 0;
                    final m = int.tryParse(minsCtrl.text) ?? 0;
                    final total = (h * 60) + m;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRoseLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Total : ${DailyEntry.formatMinutes(total)} ($total min)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRoseDark,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),

                  // Raccourcis rapides
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickPresetChip('+15 min', () => addMinutes(15)),
                      _buildQuickPresetChip('+30 min', () => addMinutes(30)),
                      _buildQuickPresetChip('+1 h', () => addMinutes(60)),
                      _buildQuickPresetChip('+2 h', () => addMinutes(120)),
                      _buildQuickPresetChip('Effacer (0)', () => setValues(0), isDanger: true),
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

  void _showEditCountDialog(
    BuildContext context, {
    required String title,
    required int initialCount,
    required Function(int) onSave,
  }) {
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
            title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Saisissez le nombre au clavier ou ajustez :',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),

                  // Champ de saisie clavier
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => adjust(-1),
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryRose, size: 28),
                      ),
                      Container(
                        width: 90,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryRoseDark),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryRose, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Raccourcis rapides
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickPresetChip('+1', () => adjust(1)),
                      _buildQuickPresetChip('+5', () => adjust(5)),
                      _buildQuickPresetChip('+10', () => adjust(10)),
                      _buildQuickPresetChip('Effacer (0)', () {
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

  Widget _buildDurationInputField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryRoseLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.remove_rounded, size: 20, color: AppTheme.primaryRose),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRoseDark,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.add_rounded, size: 20, color: AppTheme.primaryRose),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPresetChip(String label, VoidCallback onTap, {bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFFF0F2) : const Color(0xFFF7ECF0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDanger ? const Color(0xFFF8CFDC) : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isDanger ? const Color(0xFFC4436A) : AppTheme.primaryRoseDark,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
