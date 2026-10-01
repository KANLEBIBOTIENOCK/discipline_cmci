import 'dart:convert';
import 'daily_entry.dart';

/// Modèle pour un livre chrétien lu dans le mois
class BookEntry {
  String id;
  String title; // Ex: Le secret du repos spirituel
  String author; // Ex: ZTF (Zacharias Tanee Fomum)
  bool isCompleted;
  DateTime dateCompleted;

  BookEntry({
    required this.id,
    required this.title,
    this.author = 'ZTF',
    this.isCompleted = true,
    DateTime? dateCompleted,
  }) : dateCompleted = dateCompleted ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isCompleted': isCompleted,
      'dateCompleted': dateCompleted.toIso8601String(),
    };
  }

  factory BookEntry.fromMap(Map<String, dynamic> map) {
    return BookEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? 'ZTF',
      isCompleted: map['isCompleted'] ?? true,
      dateCompleted: map['dateCompleted'] != null
          ? DateTime.parse(map['dateCompleted'])
          : DateTime.now(),
    );
  }
}

/// Modèle pour le rapport mensuel complet (conforme à la fiche papier CMCI)
class MonthlyReport {
  final int year;
  final int month; // 1 à 12
  final List<DailyEntry> entries; // 1 entrée par jour du mois (28 à 31 jours)
  final List<BookEntry> booksRead;
  final int soulsIntegrated; // Âmes intégrées dans le mois
  final String prayerRequests; // Besoins de prière à transmettre

  MonthlyReport({
    required this.year,
    required this.month,
    required this.entries,
    this.booksRead = const [],
    this.soulsIntegrated = 0,
    this.prayerRequests = '',
  });

  /// Nombre total de jours dans le mois
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Nom du mois en français en majuscules (ex: "MARS", "SEPTEMBRE")
  String get monthNameUpper {
    const months = [
      'JANVIER',
      'FÉVRIER',
      'MARS',
      'AVRIL',
      'MAI',
      'JUIN',
      'JUILLET',
      'AOÛT',
      'SEPTEMBRE',
      'OCTOBRE',
      'NOVEMBRE',
      'DÉCEMBRE'
    ];
    return months[month - 1];
  }

  // ---- CUMULS & TOTAUX MENSUELS ----

  int get totalPklMinutes => entries.fold(0, (sum, e) => sum + e.pklMinutes);
  int get totalPsmMinutes => entries.fold(0, (sum, e) => sum + e.psmMinutes);
  int get totalPautMinutes => entries.fold(0, (sum, e) => sum + e.pautMinutes);
  int get totalRdqdMinutes => entries.fold(0, (sum, e) => sum + e.rdqdMinutes);
  int get totalLbChapters => entries.fold(0, (sum, e) => sum + e.lbChapters);
  int get totalLcMinutes => entries.fold(0, (sum, e) => sum + e.lcMinutes);
  int get totalEvgMinutes => entries.fold(0, (sum, e) => sum + e.evgMinutes);
  int get totalPgSouls => entries.fold(0, (sum, e) => sum + e.pgSouls);
  int get totalRsMinutes => entries.fold(0, (sum, e) => sum + e.rsMinutes);

  /// Nombre de jours où le RDQD a été fait
  int get rdqdDaysCount => entries.where((e) => e.rdqdMinutes > 0).length;

  /// Nombre de jours de jeûne
  int get fastingDaysCount =>
      entries.where((e) => e.fasting != FastingType.none).length;

  /// Total Prière Seule (PSM + RDQD ou toutes prières seules)
  int get totalPriereSeuleMinutes => totalPsmMinutes + totalRdqdMinutes;

  /// Total Prière Globale (PKL + PSM + PAUT + RDQD)
  int get totalAllPrayerMinutes =>
      totalPklMinutes + totalPsmMinutes + totalPautMinutes + totalRdqdMinutes;

  /// Moyenne de prière par jour (en minutes/jour)
  double get averagePrayerMinutesPerDay {
    if (daysInMonth == 0) return 0;
    return totalAllPrayerMinutes / daysInMonth;
  }

  /// Chaîne formatée de la moyenne quotidienne (ex: "01h 13 min/jour")
  String get formattedDailyAverage {
    final avgTotalMinutes = averagePrayerMinutesPerDay.round();
    final h = avgTotalMinutes ~/ 60;
    final m = avgTotalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')} min/jour';
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'entries': entries.map((e) => e.toMap()).toList(),
      'booksRead': booksRead.map((b) => b.toMap()).toList(),
      'soulsIntegrated': soulsIntegrated,
      'prayerRequests': prayerRequests,
    };
  }

  factory MonthlyReport.fromMap(Map<String, dynamic> map) {
    final year = map['year'] as int;
    final month = map['month'] as int;
    final rawEntries = (map['entries'] as List<dynamic>?) ?? [];
    final entries = rawEntries.map((e) => DailyEntry.fromMap(e)).toList();
    final rawBooks = (map['booksRead'] as List<dynamic>?) ?? [];
    final books = rawBooks.map((b) => BookEntry.fromMap(b)).toList();

    return MonthlyReport(
      year: year,
      month: month,
      entries: entries,
      booksRead: books,
      soulsIntegrated: map['soulsIntegrated'] ?? 0,
      prayerRequests: map['prayerRequests'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MonthlyReport.fromJson(String source) =>
      MonthlyReport.fromMap(json.decode(source));
}
