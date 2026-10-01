import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../providers/discipline_state.dart';
import '../theme/app_theme.dart';
import '../widgets/backup_restore_dialog.dart';
import '../widgets/floral_decorations.dart';

class ProfileScreen extends StatefulWidget {
  final DisciplineState state;

  const ProfileScreen({super.key, required this.state});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _discipleNameCtrl;
  late TextEditingController _discipleMakerNameCtrl;
  late TextEditingController _assemblyNameCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.state.userProfile;
    _discipleNameCtrl = TextEditingController(text: p.discipleName);
    _discipleMakerNameCtrl = TextEditingController(text: p.discipleMakerName);
    _assemblyNameCtrl = TextEditingController(text: p.assemblyName);
  }

  @override
  void dispose() {
    _discipleNameCtrl.dispose();
    _discipleMakerNameCtrl.dispose();
    _assemblyNameCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final current = widget.state.userProfile;
    final updated = UserProfile(
      discipleName: _discipleNameCtrl.text.trim(),
      discipleMakerName: _discipleMakerNameCtrl.text.trim(),
      assemblyName: _assemblyNameCtrl.text.trim(),
      dailyPrayerTargetMinutes: current.dailyPrayerTargetMinutes,
      dailyBibleTargetChapters: current.dailyBibleTargetChapters,
    );
    widget.state.updateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Profil mis à jour avec succès 🌸'),
          ],
        ),
        backgroundColor: AppTheme.primaryRose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Assemblée CMCI 🌸'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- BANNIÈRE FLORALE ----
            const FloralHeaderBanner(
              title: 'Mon Espace Spirituel 🕊️',
              subtitle:
                  '« Veille sur toi-même et sur ton enseignement; persévère dans ces choses » - 1 Timothée 4:16',
            ),
            const SizedBox(height: 24),

            // ---- INFORMATIONS OFFICIELLES CMCI ----
            const Row(
              children: [
                Icon(Icons.badge_rounded, color: AppTheme.primaryRose, size: 22),
                SizedBox(width: 8),
                Text(
                  'Informations de la Fiche',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dividerColor),
                boxShadow: AppTheme.softCardShadow,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _discipleNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mon Nom et Prénom(s)',
                      prefixIcon: Icon(Icons.person_rounded,
                          color: AppTheme.primaryRose),
                      hintText: 'Ex: ASSEU ALINE',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _discipleMakerNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mon Faiseur de Disciple',
                      prefixIcon: Icon(Icons.supervisor_account_rounded,
                          color: AppTheme.primaryRose),
                      hintText: 'Ex: PST KPO LOUA DANIEL',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _assemblyNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mon Assemblée / Église de maison',
                      prefixIcon: Icon(Icons.church_rounded,
                          color: AppTheme.primaryRose),
                      hintText: 'Ex: CHEZ LES NGUESSAN',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---- BOUTON ENREGISTRER ----
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text('Enregistrer le profil'),
              ),
            ),
            const SizedBox(height: 28),

            // ---- SAUVEGARDE & RESTAURATION DES DONNÉES ----
            const Row(
              children: [
                Icon(Icons.cloud_sync_rounded, color: AppTheme.primaryRose, size: 22),
                SizedBox(width: 8),
                Text(
                  'Sauvegarde & Restauration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dividerColor),
                boxShadow: AppTheme.softCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sauvegardez vos données et envoyez-les facilement via WhatsApp, Google Drive ou e-mail, ou restaurez une sauvegarde précédente.',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted, height: 1.35),
                  ),
                  const SizedBox(height: 16),

                  // Bouton Sauvegarder & Partager
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => BackupRestoreHelper.shareBackup(context, widget.state),
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: const Text('Sauvegarder & Partager (WhatsApp, Drive...)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton Restaurer
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => BackupRestoreHelper.pickAndRestore(context, widget.state),
                      icon: const Icon(Icons.folder_open_rounded, size: 20, color: AppTheme.primaryRose),
                      label: const Text('Restaurer une sauvegarde', style: TextStyle(color: AppTheme.primaryRoseDark, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryRose, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
