import 'dart:convert';

/// Type de jeûne pour la journée
enum FastingType {
  none,
  partial, // JP: Jeûne Partiel
  complete, // JC: Jeûne Complet
}

extension FastingTypeExtension on FastingType {
  String get code {
    switch (this) {
      case FastingType.partial:
        return 'JP';
      case FastingType.complete:
        return 'JC';
      case FastingType.none:
        return '';
    }
  }

  String get label {
    switch (this) {
      case FastingType.partial:
        return 'Jeûne Partiel (JP)';
      case FastingType.complete:
        return 'Jeûne Complet (JC)';
      case FastingType.none:
        return 'Aucun jeûne';
    }
  }

  static FastingType fromCode(String? code) {
    if (code == 'JP') return FastingType.partial;
    if (code == 'JC') return FastingType.complete;
    return FastingType.none;
  }
}

/// Modèle représentant la saisie spirituelle d'une journée
class DailyEntry {
  final String dateKey; // Format: "YYYY-MM-DD"
  final int day; // 1 à 31

  // Prières (en minutes)
  int pklMinutes; // Prière pour le Faiseur de disciple
  int psmMinutes; // Prière Seule du Matin
  int pautMinutes; // Prières Autres (intercession, combat, etc.)
  int rdqdMinutes; // Rendez-vous Quotidien avec Dieu

  // Parole & Littérature
  int lbChapters; // Lecture Biblique (nombre de chapitres)
  int lcMinutes; // Lecture Chrétienne (durée en minutes)

  // Évangélisation & Âmes
  int evgMinutes; // Évangélisation (durée en minutes)
  int pgSouls; // Personnes Gagnées à Christ

  // Jeûne & Retraite
  FastingType fasting; // Aucun, JP ou JC
  int rsMinutes; // Retraite Spirituelle (en minutes)

  // Notes personnelles de la journée
  String notes;

  DailyEntry({
    required this.dateKey,
    required this.day,
    this.pklMinutes = 0,
    this.psmMinutes = 0,
    this.pautMinutes = 0,
    this.rdqdMinutes = 0,
    this.lbChapters = 0,
    this.lcMinutes = 0,
    this.evgMinutes = 0,
    this.pgSouls = 0,
    this.fasting = FastingType.none,
    this.rsMinutes = 0,
    this.notes = '',
  });

  /// Total de toutes les prières de la journée (PKL + PSM + PAUT + RDQD) en minutes
  int get totalPrayerMinutes => pklMinutes + psmMinutes + pautMinutes + rdqdMinutes;

  /// Total Prière Seule (PSM + RDQD) ou calcul selon la convention
  int get totalAlonePrayerMinutes => psmMinutes + rdqdMinutes;

  /// Formatage d'une durée en minutes vers une chaîne "1h30" ou "25m"
  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) {
      return '${h}h${m.toString().padLeft(2, '0')}';
    } else if (h > 0) {
      return '${h}h';
    } else {
      return '${m}m';
    }
  }

  /// Formatage long "1h 30min"
  static String formatMinutesLong(int minutes) {
    if (minutes <= 0) return '0 min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) {
      return '${h}h ${m}min';
    } else if (h > 0) {
      return '${h}h 00min';
    } else {
      return '${m}min';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'day': day,
      'pklMinutes': pklMinutes,
      'psmMinutes': psmMinutes,
      'pautMinutes': pautMinutes,
      'rdqdMinutes': rdqdMinutes,
      'lbChapters': lbChapters,
      'lcMinutes': lcMinutes,
      'evgMinutes': evgMinutes,
      'pgSouls': pgSouls,
      'fasting': fasting.code,
      'rsMinutes': rsMinutes,
      'notes': notes,
    };
  }

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      dateKey: map['dateKey'] ?? '',
      day: map['day'] ?? 1,
      pklMinutes: map['pklMinutes'] ?? 0,
      psmMinutes: map['psmMinutes'] ?? 0,
      pautMinutes: map['pautMinutes'] ?? 0,
      rdqdMinutes: map['rdqdMinutes'] ?? 0,
      lbChapters: map['lbChapters'] ?? 0,
      lcMinutes: map['lcMinutes'] ?? 0,
      evgMinutes: map['evgMinutes'] ?? 0,
      pgSouls: map['pgSouls'] ?? 0,
      fasting: FastingTypeExtension.fromCode(map['fasting']),
      rsMinutes: map['rsMinutes'] ?? 0,
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyEntry.fromJson(String source) => DailyEntry.fromMap(json.decode(source));

  DailyEntry copyWith({
    String? dateKey,
    int? day,
    int? pklMinutes,
    int? psmMinutes,
    int? pautMinutes,
    int? rdqdMinutes,
    int? lbChapters,
    int? lcMinutes,
    int? evgMinutes,
    int? pgSouls,
    FastingType? fasting,
    int? rsMinutes,
    String? notes,
  }) {
    return DailyEntry(
      dateKey: dateKey ?? this.dateKey,
      day: day ?? this.day,
      pklMinutes: pklMinutes ?? this.pklMinutes,
      psmMinutes: psmMinutes ?? this.psmMinutes,
      pautMinutes: pautMinutes ?? this.pautMinutes,
      rdqdMinutes: rdqdMinutes ?? this.rdqdMinutes,
      lbChapters: lbChapters ?? this.lbChapters,
      lcMinutes: lcMinutes ?? this.lcMinutes,
      evgMinutes: evgMinutes ?? this.evgMinutes,
      pgSouls: pgSouls ?? this.pgSouls,
      fasting: fasting ?? this.fasting,
      rsMinutes: rsMinutes ?? this.rsMinutes,
      notes: notes ?? this.notes,
    );
  }
}
