import 'dart:convert';

/// Profil du disciple CMCI
class UserProfile {
  String discipleName; // Ex: ASSEU ALINE
  String discipleMakerName; // Ex: PST KPO LOUA DANIEL
  String assemblyName; // Ex: CHEZ LES NGUESSAN
  String phoneNumber; // Optionnel pour le contact
  int dailyPrayerTargetMinutes; // Objectif de prière quotidienne (ex: 60 ou 120 min)
  int dailyBibleTargetChapters; // Objectif de chapitres bibliques par jour

  UserProfile({
    this.discipleName = '',
    this.discipleMakerName = '',
    this.assemblyName = '',
    this.phoneNumber = '',
    this.dailyPrayerTargetMinutes = 60,
    this.dailyBibleTargetChapters = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'discipleName': discipleName,
      'discipleMakerName': discipleMakerName,
      'assemblyName': assemblyName,
      'phoneNumber': phoneNumber,
      'dailyPrayerTargetMinutes': dailyPrayerTargetMinutes,
      'dailyBibleTargetChapters': dailyBibleTargetChapters,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      discipleName: map['discipleName'] ?? '',
      discipleMakerName: map['discipleMakerName'] ?? '',
      assemblyName: map['assemblyName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      dailyPrayerTargetMinutes: map['dailyPrayerTargetMinutes'] ?? 60,
      dailyBibleTargetChapters: map['dailyBibleTargetChapters'] ?? 10,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
