import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Décoration florale en en-tête avec verset biblique inspirant
class FloralHeaderBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const FloralHeaderBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: AppTheme.rosePetalGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.roseGlowShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -20,
            child: Opacity(
              opacity: 0.15,
              child: const Icon(
                Icons.local_florist_rounded,
                size: 110,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.92),
                  fontSize: 13.5,
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte de discipline spirituelle florale avec ajout (+), suppression/diminution (-) et saisie manuelle directe
class FloralDisciplineCard extends StatelessWidget {
  final String title;
  final String abbreviation; // Ex: PSM, PKL, RDQD, LB
  final String valueDisplay;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onAdd15m;
  final VoidCallback onAdd30m;
  final VoidCallback onAdd1h;
  final VoidCallback onSubtract15m;
  final VoidCallback onSubtract30m;
  final VoidCallback onClear;
  final VoidCallback? onCustomTap;
  final bool isChapterCount; // Pour LB (chapitres au lieu de minutes)

  const FloralDisciplineCard({
    super.key,
    required this.title,
    required this.abbreviation,
    required this.valueDisplay,
    required this.icon,
    required this.gradient,
    required this.onAdd15m,
    required this.onAdd30m,
    required this.onAdd1h,
    required this.onSubtract15m,
    required this.onSubtract30m,
    required this.onClear,
    this.onCustomTap,
    this.isChapterCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.dividerColor, width: 1.2),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Haut de carte : Titre, Icône et Valeur cliquable pour saisie directe
            InkWell(
              onTap: onCustomTap,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.first.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRoseLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                abbreviation,
                                style: const TextStyle(
                                  color: AppTheme.primaryRoseDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          valueDisplay.isEmpty
                              ? (isChapterCount ? '0 chapitre' : '0 min')
                              : valueDisplay,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: valueDisplay.isEmpty
                                ? AppTheme.textMuted
                                : AppTheme.primaryRose,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onCustomTap,
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryRose,
                      size: 26,
                    ),
                    tooltip: 'Saisie manuelle directe',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.dividerColor, height: 1),
            const SizedBox(height: 8),

            // 1ère Rangée : Boutons d'Ajout (+)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: isChapterCount ? '+1 chap' : '+15m',
                    onTap: onAdd15m,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildActionButton(
                    label: isChapterCount ? '+5 chap' : '+30m',
                    onTap: onAdd30m,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildActionButton(
                    label: isChapterCount ? '+10 chap' : '+1h00',
                    onTap: onAdd1h,
                    isHighlight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // 2ème Rangée : Boutons de Diminution / Suppression (-)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: isChapterCount ? '-1 chap' : '-15m',
                    onTap: onSubtract15m,
                    isDanger: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildActionButton(
                    label: isChapterCount ? '-5 chap' : '-30m',
                    onTap: onSubtract30m,
                    isDanger: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildActionButton(
                    label: 'Effacer (0)',
                    onTap: onClear,
                    isDanger: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    bool isHighlight = false,
    bool isDanger = false,
  }) {
    Color bg = const Color(0xFFFCF8FA);
    Color text = AppTheme.textMain;
    Border border = Border.all(color: AppTheme.dividerColor);

    if (isHighlight) {
      bg = AppTheme.primaryRoseLight;
      text = AppTheme.primaryRoseDark;
      border = Border.all(color: AppTheme.primaryRose.withOpacity(0.3));
    } else if (isDanger) {
      bg = const Color(0xFFFFF0F2);
      text = const Color(0xFFC4436A);
      border = Border.all(color: const Color(0xFFF8CFDC));
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
      ),
    );
  }
}
