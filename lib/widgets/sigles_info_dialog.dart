import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal d'explication de tous les sigles officiels CMCI
class SiglesInfoDialog extends StatelessWidget {
  const SiglesInfoDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SiglesInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sigles = [
      {
        'sigle': 'PSM',
        'title': 'Prière pour moi',
        'desc': 'Temps de prière personnel pour sa propre sanctification, sa communion intime avec Dieu et sa transformation spirituelle.',
      },
      {
        'sigle': 'RDQD',
        'title': 'Rendez-vous Quotidien avec Dieu',
        'desc': 'Moment sacré et non négociable de tête-à-tête avec Dieu au début ou cours de la journée.',
      },
      {
        'sigle': 'PKL',
        'title': 'Prière pour le Faiseur de disciple',
        'desc': 'Intercession dédiée pour son Pasteur, Berger ou Faiseur de disciples (soutien spirituel de son ministère).',
      },
      {
        'sigle': 'PAUT',
        'title': 'Prières Autres',
        'desc': 'Combats spirituels, intercession pour l\'Église, la nation, les réunions de prière collectives et veillées.',
      },
      {
        'sigle': 'LB',
        'title': 'Lecture Biblique (Chapitres)',
        'desc': 'Nombre de chapitres de la Parole de Dieu lus et médités dans la journée.',
      },
      {
        'sigle': 'LC',
        'title': 'Lecture Chrétienne (Livres)',
        'desc': 'Temps consacré à l\'étude et la lecture d\'ouvrages d\'édification chrétienne.',
      },
      {
        'sigle': 'EVG',
        'title': 'Évangélisation',
        'desc': 'Temps passé sur le terrain ou en tête-à-tête pour partager l\'Évangile de Jésus-Christ.',
      },
      {
        'sigle': 'PG',
        'title': 'Personnes Gagnées (Âmes)',
        'desc': 'Nombre d\'âmes ayant donné leur vie au Seigneur Jésus ce jour-là.',
      },
      {
        'sigle': 'JP / JC',
        'title': 'Jeûne Partiel / Complet',
        'desc': 'JP = Jeûne partiel (abstinence jusqu\'à une heure donnée). JC = Jeûne complet (24h ou sans nourriture). Par défaut : Aucun.',
      },
      {
        'sigle': 'RS',
        'title': 'Retraite Spirituelle',
        'desc': 'Temps de mise à part prolongé pour chercher la face de Dieu dans le silence et le jeûne.',
      },
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRoseLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryRose, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Guide des Sigles CMCI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: sigles.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = sigles[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRoseLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryRose.withOpacity(0.3)),
                        ),
                        child: Text(
                          item['sigle']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppTheme.primaryRoseDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['desc']!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Compris', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
