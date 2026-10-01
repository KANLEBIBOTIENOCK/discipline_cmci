import 'package:flutter/foundation.dart';
import '../models/daily_entry.dart';
import '../models/monthly_report.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

/// Gestionnaire d'état principal de l'application
class DisciplineState extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  UserProfile _userProfile = UserProfile();
  MonthlyReport? _currentReport;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  UserProfile get userProfile => _userProfile;
  MonthlyReport? get currentReport => _currentReport;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  /// Récupérer l'entrée du jour actuellement sélectionné
  DailyEntry get selectedDayEntry {
    if (_currentReport == null) {
      return DailyEntry(
        dateKey: _formatDateKey(_selectedDate),
        day: _selectedDate.day,
      );
    }
    final match = _currentReport!.entries.where((e) => e.day == _selectedDate.day);
    if (match.isNotEmpty) {
      return match.first;
    }
    return DailyEntry(
      dateKey: _formatDateKey(_selectedDate),
      day: _selectedDate.day,
    );
  }

  /// Initialisation de l'état au démarrage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _userProfile = await _storageService.loadUserProfile();
    await loadMonth(_selectedDate.year, _selectedDate.month);

    _isLoading = false;
    notifyListeners();
  }

  /// Charger les données d'un mois spécifique
  Future<void> loadMonth(int year, int month) async {
    _isLoading = true;
    notifyListeners();

    _currentReport = await _storageService.loadMonthlyReport(year, month);

    _isLoading = false;
    notifyListeners();
  }

  /// Changer la date sélectionnée
  void selectDate(DateTime date) {
    final bool monthChanged = date.year != _selectedDate.year || date.month != _selectedDate.month;
    _selectedDate = date;

    if (monthChanged) {
      loadMonth(date.year, date.month);
    } else {
      notifyListeners();
    }
  }

  void previousMonth() {
    final prev = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    selectDate(prev);
  }

  void nextMonth() {
    final next = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    selectDate(next);
  }

  // ---- ACTIONS D'AJOUT (+), DIMINUTION (-) ET DÉFINITION DIRECTE ----

  // PKL: Prière Faiseur de disciple
  Future<void> addPklMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.pklMinutes = (entry.pklMinutes + minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractPklMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.pklMinutes = (entry.pklMinutes - minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> setPklMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.pklMinutes = minutes.clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  // PSM: Prière Seule du Matin
  Future<void> addPsmMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.psmMinutes = (entry.psmMinutes + minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractPsmMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.psmMinutes = (entry.psmMinutes - minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> setPsmMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.psmMinutes = minutes.clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  // PAUT: Prières Autres
  Future<void> addPautMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.pautMinutes = (entry.pautMinutes + minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractPautMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.pautMinutes = (entry.pautMinutes - minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> setPautMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.pautMinutes = minutes.clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  // RDQD: Rendez-vous Quotidien avec Dieu
  Future<void> addRdqdMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.rdqdMinutes = (entry.rdqdMinutes + minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractRdqdMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.rdqdMinutes = (entry.rdqdMinutes - minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> setRdqdMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.rdqdMinutes = minutes.clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  // LB: Lecture Biblique (chapitres)
  Future<void> addLbChapters(int chapters) async {
    final entry = selectedDayEntry;
    entry.lbChapters = (entry.lbChapters + chapters).clamp(0, 150);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractLbChapters(int chapters) async {
    final entry = selectedDayEntry;
    entry.lbChapters = (entry.lbChapters - chapters).clamp(0, 150);
    await _saveCurrentEntry(entry);
  }

  Future<void> setLbChapters(int chapters) async {
    final entry = selectedDayEntry;
    entry.lbChapters = chapters.clamp(0, 150);
    await _saveCurrentEntry(entry);
  }

  // LC: Lecture Chrétienne
  Future<void> addLcMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.lcMinutes = (entry.lcMinutes + minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractLcMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.lcMinutes = (entry.lcMinutes - minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> setLcMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.lcMinutes = minutes.clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  // EVG: Évangélisation
  Future<void> addEvgMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.evgMinutes = (entry.evgMinutes + minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractEvgMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.evgMinutes = (entry.evgMinutes - minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> setEvgMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.evgMinutes = minutes.clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  // PG: Personnes Gagnées
  Future<void> addPgSouls(int count) async {
    final entry = selectedDayEntry;
    entry.pgSouls = (entry.pgSouls + count).clamp(0, 1000);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractPgSouls(int count) async {
    final entry = selectedDayEntry;
    entry.pgSouls = (entry.pgSouls - count).clamp(0, 1000);
    await _saveCurrentEntry(entry);
  }

  Future<void> setPgSouls(int count) async {
    final entry = selectedDayEntry;
    entry.pgSouls = count.clamp(0, 1000);
    await _saveCurrentEntry(entry);
  }

  // Jeûne
  Future<void> setFasting(FastingType fasting) async {
    final entry = selectedDayEntry;
    entry.fasting = fasting;
    await _saveCurrentEntry(entry);
  }

  // RS: Retraite Spirituelle
  Future<void> addRsMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.rsMinutes = (entry.rsMinutes + minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> subtractRsMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.rsMinutes = (entry.rsMinutes - minutes).clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  Future<void> setRsMinutes(int minutes) async {
    final entry = selectedDayEntry;
    entry.rsMinutes = minutes.clamp(0, 1440);
    await _saveCurrentEntry(entry);
  }

  // Réinitialiser le jour en cours
  Future<void> resetSelectedDay() async {
    final entry = DailyEntry(
      dateKey: _formatDateKey(_selectedDate),
      day: _selectedDate.day,
      fasting: FastingType.none,
    );
    await _saveCurrentEntry(entry);
  }

  // Réinitialiser tout le mois
  Future<void> resetEntireMonth() async {
    if (_currentReport == null) return;
    final daysInMonth = _currentReport!.daysInMonth;
    final cleanEntries = List<DailyEntry>.generate(daysInMonth, (i) {
      final day = i + 1;
      final dateKey = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      return DailyEntry(dateKey: dateKey, day: day, fasting: FastingType.none);
    });
    final cleanReport = MonthlyReport(
      year: _currentReport!.year,
      month: _currentReport!.month,
      entries: cleanEntries,
      booksRead: [],
      soulsIntegrated: 0,
      prayerRequests: '',
    );
    _currentReport = cleanReport;
    await _storageService.saveMonthlyReport(cleanReport);
    notifyListeners();
  }

  Future<void> updateEntry(DailyEntry entry) async {
    await _saveCurrentEntry(entry);
  }

  // ---- LIVRES & BESOINS ----

  Future<void> addBook(String title, String author) async {
    if (_currentReport == null) return;
    final newBook = BookEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: author.isNotEmpty ? author : 'ZTF',
    );
    final updatedBooks = List<BookEntry>.from(_currentReport!.booksRead)..add(newBook);
    final updatedReport = MonthlyReport(
      year: _currentReport!.year,
      month: _currentReport!.month,
      entries: _currentReport!.entries,
      booksRead: updatedBooks,
      soulsIntegrated: _currentReport!.soulsIntegrated,
      prayerRequests: _currentReport!.prayerRequests,
    );
    _currentReport = updatedReport;
    await _storageService.saveMonthlyReport(updatedReport);
    notifyListeners();
  }

  Future<void> removeBook(String id) async {
    if (_currentReport == null) return;
    final updatedBooks = _currentReport!.booksRead.where((b) => b.id != id).toList();
    final updatedReport = MonthlyReport(
      year: _currentReport!.year,
      month: _currentReport!.month,
      entries: _currentReport!.entries,
      booksRead: updatedBooks,
      soulsIntegrated: _currentReport!.soulsIntegrated,
      prayerRequests: _currentReport!.prayerRequests,
    );
    _currentReport = updatedReport;
    await _storageService.saveMonthlyReport(updatedReport);
    notifyListeners();
  }

  Future<void> updateSoulsIntegrated(int count) async {
    if (_currentReport == null) return;
    final updatedReport = MonthlyReport(
      year: _currentReport!.year,
      month: _currentReport!.month,
      entries: _currentReport!.entries,
      booksRead: _currentReport!.booksRead,
      soulsIntegrated: count,
      prayerRequests: _currentReport!.prayerRequests,
    );
    _currentReport = updatedReport;
    await _storageService.saveMonthlyReport(updatedReport);
    notifyListeners();
  }

  Future<void> updatePrayerRequests(String requests) async {
    if (_currentReport == null) return;
    final updatedReport = MonthlyReport(
      year: _currentReport!.year,
      month: _currentReport!.month,
      entries: _currentReport!.entries,
      booksRead: _currentReport!.booksRead,
      soulsIntegrated: _currentReport!.soulsIntegrated,
      prayerRequests: requests,
    );
    _currentReport = updatedReport;
    await _storageService.saveMonthlyReport(updatedReport);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storageService.saveUserProfile(profile);
    notifyListeners();
  }

  // ---- SAUVEGARDE & RESTAURATION (EXPORT / IMPORT JSON) ----

  Future<String> exportBackupJson() async {
    return await _storageService.exportAllDataAsJson();
  }

  Future<Map<String, dynamic>> importBackupJson(String jsonString) async {
    final result = await _storageService.importDataFromJson(jsonString);
    if (result['success'] == true) {
      await initialize();
    }
    return result;
  }

  // Mettre à jour et sauvegarder l'entrée d'un jour précis
  Future<void> updateDayEntry(DailyEntry entry) async {
    if (_currentReport == null) return;
    await _storageService.saveDailyEntry(_currentReport!.year, _currentReport!.month, entry);

    final index = _currentReport!.entries.indexWhere((e) => e.day == entry.day);
    if (index >= 0) {
      _currentReport!.entries[index] = entry;
    }
    notifyListeners();
  }

  Future<void> _saveCurrentEntry(DailyEntry entry) async {
    if (_currentReport == null) return;
    await _storageService.saveDailyEntry(_selectedDate.year, _selectedDate.month, entry);

    final index = _currentReport!.entries.indexWhere((e) => e.day == entry.day);
    if (index >= 0) {
      _currentReport!.entries[index] = entry;
    }
    notifyListeners();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
