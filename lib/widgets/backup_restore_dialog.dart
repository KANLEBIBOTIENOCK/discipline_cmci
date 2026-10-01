import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/discipline_state.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Gestionnaire épuré pour Partager et Restaurer les données via WhatsApp, Drive, etc.
class BackupRestoreHelper {
  /// Sauvegarder et ouvrir la feuille de partage (WhatsApp, Google Drive, etc.)
  static Future<void> shareBackup(BuildContext context, DisciplineState state) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      final storage = StorageService();
      final backupFile = await storage.createBackupFile();

      // Récupérer le nom du disciple pour personnaliser le message
      final discipleName = state.userProfile.discipleName;
      final discipleLabel = discipleName.trim().isNotEmpty
          ? ' de $discipleName'
          : '';

      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'Sauvegarde Disciplines Spirituelles$discipleLabel',
        text: 'Voici le fichier de sauvegarde des disciplines spirituelles$discipleLabel 🌸',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage de la sauvegarde : $e'),
            backgroundColor: const Color(0xFFC4436A),
          ),
        );
      }
    }
  }

  /// 1-Clic Restaurer : Ouvre directement le gestionnaire de fichiers pour sélectionner le fichier
  static Future<void> pickAndRestore(BuildContext context, DisciplineState state) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final path = result.files.first.path;
      if (path == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'accéder au fichier sélectionné.'),
              backgroundColor: Color(0xFFC4436A),
            ),
          );
        }
        return;
      }

      final file = File(path);
      final rawContent = await file.readAsString();

      // Décoder et vérifier le contenu
      final decoded = json.decode(rawContent) as Map<String, dynamic>;
      final profile = decoded['profile'] as Map<String, dynamic>?;
      final disciple = profile?['discipleName'] ?? 'Non spécifié';
      final reports = decoded['monthlyReports'] as Map<String, dynamic>?;
      final monthsCount = reports?.length ?? 0;
      final fileName = result.files.first.name;

      if (!context.mounted) return;

      // Dialogue épuré de confirmation
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: AppTheme.primaryRose),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Restaurer la sauvegarde',
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fichier : $fileName',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRoseLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👤 Disciple : $disciple',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📅 Données : $monthsCount mois inclus',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.textMain),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vos fiches actuelles seront actualisées avec ces données.',
                style: TextStyle(fontSize: 11.5, color: Color(0xFFC4436A)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Restaurer'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final restoreResult = await state.importBackupJson(rawContent);

      if (context.mounted) {
        if (restoreResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Données de ${restoreResult['discipleName']} restaurées (${restoreResult['monthsCount']} mois) ! 🌸',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.primaryRose,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(restoreResult['error'] ?? 'Échec de la restauration.'),
              backgroundColor: const Color(0xFFC4436A),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fichier de sauvegarde non reconnu : $e'),
            backgroundColor: const Color(0xFFC4436A),
          ),
        );
      }
    }
  }
}
