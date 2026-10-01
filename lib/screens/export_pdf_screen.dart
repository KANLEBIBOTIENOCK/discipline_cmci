import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../providers/discipline_state.dart';
import '../services/pdf_generator_service.dart';
import '../theme/app_theme.dart';

class ExportPdfScreen extends StatefulWidget {
  final DisciplineState state;

  const ExportPdfScreen({super.key, required this.state});

  @override
  State<ExportPdfScreen> createState() => _ExportPdfScreenState();
}

class _ExportPdfScreenState extends State<ExportPdfScreen> {
  Uint8List? _pdfBytes;
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    final report = widget.state.currentReport;
    if (report != null) {
      final bytes = await PdfGeneratorService.generateMonthlyReportPdf(
        report: report,
        profile: widget.state.userProfile,
      );
      setState(() {
        _pdfBytes = bytes;
        _isGenerating = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;
    final report = widget.state.currentReport;
    final fileName =
        'Fiche_${widget.state.userProfile.discipleName}_${report?.monthNameUpper}_${report?.year}.pdf';

    await Printing.sharePdf(
      bytes: _pdfBytes!,
      filename: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.state.currentReport;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche Officielle CMCI 📄'),
        actions: [
          if (!_isGenerating && _pdfBytes != null)
            IconButton(
              onPressed: _sharePdf,
              icon: const Icon(Icons.share_rounded, color: AppTheme.primaryRose),
              tooltip: 'Partager le fichier PDF',
            ),
        ],
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryRose),
                  SizedBox(height: 16),
                  Text(
                    'Génération de la fiche PDF en cours...',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Bannière d'en-tête
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.rosePetalGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.roseGlowShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Compte-rendu prêt à exporter 🌸',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Destinataire : ${widget.state.userProfile.discipleMakerName}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _sharePdf,
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Exporter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryRoseDark,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                // Prévisualisation interactive du PDF
                Expanded(
                  child: PdfPreview(
                    build: (format) => _pdfBytes!,
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    pdfFileName:
                        'Fiche_${report?.monthNameUpper}_${report?.year}.pdf',
                  ),
                ),
              ],
            ),
    );
  }
}
