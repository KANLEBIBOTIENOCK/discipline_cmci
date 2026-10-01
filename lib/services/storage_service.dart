import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_entry.dart';
import '../models/monthly_report.dart';
import '../models/user_profile.dart';

/// Service de stockage local pour sauvegarder toutes les données sans connexion internet
class StorageService {
  static const String _keyProfile = 'cmci_user_profile';
  static const String _keyMonthlyPrefix = 'cmci_month_'; // ex: cmci_month_2026_03

  /// Charger le profil utilisateur
  Future<UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return UserProfile.fromJson(jsonStr);
      } catch (e) {
        // En cas d'erreur de parsing, retourner un profil par défaut
      }
    }
    return UserProfile(
      discipleName: 'ASSEU ALINE',
      discipleMakerName: 'PST KPO LOUA DANIEL',
      assemblyName: 'CHEZ LES NGUESSAN',
    );
  }

  /// Sauvegarder le profil utilisateur
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, profile.toJson());
  }

  /// Charger le rapport d'un mois donné (ex: 2026, 3 pour Mars 2026)
  Future<MonthlyReport> loadMonthlyReport(int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyMonthlyPrefix${year}_${month.toString().padLeft(2, '0')}';
    final jsonStr = prefs.getString(key);

    final daysInMonth = DateTime(year, month + 1, 0).day;

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final report = MonthlyReport.fromJson(jsonStr);
        // S'assurer que tous les jours 1 à daysInMonth sont présents
        final existingDays = {for (var e in report.entries) e.day: e};
        final completeEntries = List<DailyEntry>.generate(daysInMonth, (i) {
          final day = i + 1;
          if (existingDays.containsKey(day)) {
            return existingDays[day]!;
          }
          final dateKey = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          return DailyEntry(dateKey: dateKey, day: day);
        });

        return MonthlyReport(
          year: year,
          month: month,
          entries: completeEntries,
          booksRead: report.booksRead,
          soulsIntegrated: report.soulsIntegrated,
          prayerRequests: report.prayerRequests,
        );
      } catch (e) {
        // Erreur de parsing, générer un mois vierge
      }
    }

    // Créer un rapport vide pour ce mois
    final initialEntries = List<DailyEntry>.generate(daysInMonth, (i) {
      final day = i + 1;
      final dateKey = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      return DailyEntry(dateKey: dateKey, day: day);
    });

    return MonthlyReport(
      year: year,
      month: month,
      entries: initialEntries,
    );
  }

  /// Sauvegarder le rapport d'un mois
  Future<void> saveMonthlyReport(MonthlyReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyMonthlyPrefix${report.year}_${report.month.toString().padLeft(2, '0')}';
    await prefs.setString(key, report.toJson());
  }

  /// Sauvegarder une entrée spécifique d'un jour
  Future<void> saveDailyEntry(int year, int month, DailyEntry entry) async {
    final report = await loadMonthlyReport(year, month);
    final index = report.entries.indexWhere((e) => e.day == entry.day);

    List<DailyEntry> updatedEntries = List.from(report.entries);
    if (index >= 0) {
      updatedEntries[index] = entry;
    } else {
      updatedEntries.add(entry);
      updatedEntries.sort((a, b) => a.day.compareTo(b.day));
    }

    final updatedReport = MonthlyReport(
      year: year,
      month: month,
      entries: updatedEntries,
      booksRead: report.booksRead,
      soulsIntegrated: report.soulsIntegrated,
      prayerRequests: report.prayerRequests,
    );

    await saveMonthlyReport(updatedReport);
  }

  // ===========================================================================
  // SAUVEGARDE & RESTAURATION COMPLÈTE (EXPORT / IMPORT JSON)
  // ===========================================================================

  /// Exporter toutes les données (Profil + tous les mois enregistrés) sous forme de String JSON
  Future<String> exportAllDataAsJson() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final userProfile = await loadUserProfile();

    final Map<String, dynamic> monthlyReportsMap = {};
    for (final key in allKeys) {
      if (key.startsWith(_keyMonthlyPrefix)) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          try {
            final decoded = json.decode(jsonStr);
            final monthSuffix = key.replaceFirst(_keyMonthlyPrefix, '');
            monthlyReportsMap[monthSuffix] = decoded;
          } catch (_) {}
        }
      }
    }

    final backupData = {
      'app': 'Aline',
      'version': '1.0.5',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': userProfile.toMap(),
      'monthlyReports': monthlyReportsMap,
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  /// Créer un fichier TXT temporaire prêt à être partagé ou enregistré
  Future<File> createBackupFile() async {
    final textString = await exportAllDataAsJson();
    final tempDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final dateFormatted = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final file = File('${tempDir.path}/Aline_Sauvegarde_$dateFormatted.txt');
    await file.writeAsString(textString, flush: true);
    return file;
  }

  /// Importer et restaurer les données depuis une chaîne JSON
  /// Retourne un résumé du contenu restauré
  Future<Map<String, dynamic>> importDataFromJson(String jsonString) async {
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;

      if (!decoded.containsKey('profile') && !decoded.containsKey('monthlyReports')) {
        throw const FormatException('Fichier de sauvegarde non reconnu ou invalide.');
      }

      final prefs = await SharedPreferences.getInstance();

      // 1. Restaurer le profil
      if (decoded.containsKey('profile')) {
        final profileMap = decoded['profile'] as Map<String, dynamic>;
        final profile = UserProfile.fromMap(profileMap);
        await saveUserProfile(profile);
      }

      // 2. Restaurer tous les mois
      int restoredMonthsCount = 0;
      if (decoded.containsKey('monthlyReports')) {
        final reportsMap = decoded['monthlyReports'] as Map<String, dynamic>;
        for (final entry in reportsMap.entries) {
          final monthKey = '$_keyMonthlyPrefix${entry.key}';
          final monthValueJson = json.encode(entry.value);
          await prefs.setString(monthKey, monthValueJson);
          restoredMonthsCount++;
        }
      }

      final profileObj = decoded['profile'] != null
          ? UserProfile.fromMap(decoded['profile'] as Map<String, dynamic>)
          : null;

      return {
        'success': true,
        'discipleName': profileObj?.discipleName ?? '',
        'monthsCount': restoredMonthsCount,
        'exportedAt': decoded['exportedAt'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
