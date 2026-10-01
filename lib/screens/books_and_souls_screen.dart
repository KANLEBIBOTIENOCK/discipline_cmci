import 'package:flutter/material.dart';
import '../providers/discipline_state.dart';
import '../theme/app_theme.dart';
import '../widgets/floral_decorations.dart';

class BooksAndSoulsScreen extends StatefulWidget {
  final DisciplineState state;

  const BooksAndSoulsScreen({super.key, required this.state});

  @override
  State<BooksAndSoulsScreen> createState() => _BooksAndSoulsScreenState();
}

class _BooksAndSoulsScreenState extends State<BooksAndSoulsScreen> {
  late TextEditingController _prayerReqController;
  late TextEditingController _soulsIntegratedController;

  @override
  void initState() {
    super.initState();
    _prayerReqController = TextEditingController(
      text: widget.state.currentReport?.prayerRequests ?? '',
    );
    _soulsIntegratedController = TextEditingController(
      text: '${widget.state.currentReport?.soulsIntegrated ?? 0}',
    );
  }

  @override
  void didUpdateWidget(covariant BooksAndSoulsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_prayerReqController.text != (widget.state.currentReport?.prayerRequests ?? '')) {
      _prayerReqController.text = widget.state.currentReport?.prayerRequests ?? '';
    }
    if (_soulsIntegratedController.text != '${widget.state.currentReport?.soulsIntegrated ?? 0}') {
      _soulsIntegratedController.text = '${widget.state.currentReport?.soulsIntegrated ?? 0}';
    }
  }

  @override
  void dispose() {
    _prayerReqController.dispose();
    _soulsIntegratedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.state.currentReport;
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan & Livres Lus 📖'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- BANNIÈRE FLORALE ----
            const FloralHeaderBanner(
              title: 'Littérature & Âmes 🌸',
              subtitle:
                  '« Les sages brilleront comme la splendeur du ciel, et ceux qui auront enseigné la justice à la multitude brilleront comme les étoiles » - Daniel 12:3',
            ),
            const SizedBox(height: 20),

            // ---- SECTION 1 : LIVRES LUS DANS LE MOIS ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        color: AppTheme.primaryRose, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Livres Lus (${report.booksRead.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddBookDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (report.booksRead.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 38, color: AppTheme.textMuted),
                    SizedBox(height: 8),
                    Text(
                      'Aucun livre ajouté pour ce mois.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.booksRead.length,
                itemBuilder: (context, index) {
                  final book = report.booksRead[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerColor),
                      boxShadow: AppTheme.softCardShadow,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryRoseLight,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.primaryRoseDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        book.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Auteur: ${book.author}',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.redAccent, size: 22),
                        onPressed: () => widget.state.removeBook(book.id),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // ---- SECTION 2 : ÂMES GAGNÉES ET INTÉGRÉES ----
            const Row(
              children: [
                Icon(Icons.group_add_rounded,
                    color: AppTheme.primaryRose, size: 22),
                SizedBox(width: 8),
                Text(
                  'Âmes Gagnées & Intégrées',
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.dividerColor),
                boxShadow: AppTheme.softCardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Personnes gagnées à Christ (PG) :',
                          style: TextStyle(fontSize: 13.5, color: AppTheme.textMain),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRoseLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${report.totalPgSouls} âme(s)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRoseDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.dividerColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Âmes intégrées dans l’assemblée :',
                          style: TextStyle(fontSize: 13.5, color: AppTheme.textMain),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _soulsIntegratedController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            final count = int.tryParse(val) ?? 0;
                            widget.state.updateSoulsIntegrated(count);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---- SECTION 3 : BESOINS DE PRIÈRES ----
            const Row(
              children: [
                Icon(Icons.mark_chat_unread_rounded,
                    color: AppTheme.primaryRose, size: 22),
                SizedBox(width: 8),
                Text(
                  'Besoins de Prières',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Ces requêtes figureront en bas de la fiche PDF envoyée au Faiseur de disciple.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _prayerReqController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Ex: Croissance spirituelle, fardeau pour les âmes perdues, sanctification...',
              ),
              onChanged: (val) {
                widget.state.updatePrayerRequests(val);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    final titleController = TextEditingController();
    final authorController = TextEditingController(text: 'ZTF');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Ajouter un livre lu 📖',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titre du livre',
                hintText: 'Ex: Le secret du repos spirituel',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Auteur',
                hintText: 'Ex: ZTF',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                widget.state.addBook(
                  titleController.text.trim(),
                  authorController.text.trim(),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
