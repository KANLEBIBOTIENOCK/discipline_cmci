import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/daily_entry.dart';
import '../models/monthly_report.dart';
import '../models/user_profile.dart';

/// Service de génération du document PDF officiel CMCI
class PdfGeneratorService {
  /// Génère le document PDF complet conforme à la fiche originale
  static Future<Uint8List> generateMonthlyReportPdf({
    required MonthlyReport report,
    required UserProfile profile,
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---- EN-TÊTE OFFICIEL ----
              pw.Text(
                'FICHE DE COMPTE RENDU DE : ${profile.discipleName.toUpperCase()}',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'MOIS DE : ${report.monthNameUpper} ${report.year}',
                style: pw.TextStyle(font: fontBold, fontSize: 11),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'FAISEUR DE DISCIPLE : ${profile.discipleMakerName.toUpperCase()}',
                style: pw.TextStyle(font: fontBold, fontSize: 11),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'ASSEMBLÉE : ${profile.assemblyName.toUpperCase()}',
                style: pw.TextStyle(font: fontBold, fontSize: 11),
              ),
              pw.SizedBox(height: 8),

              // ---- TABLEAU DES DISCIPLINES (1 à 31 + TOTAL) ----
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
                columnWidths: {
                  0: const pw.FixedColumnWidth(24), // Jour
                  1: const pw.FlexColumnWidth(1.1), // PKL
                  2: const pw.FlexColumnWidth(1.1), // PSM
                  3: const pw.FlexColumnWidth(1.0), // PAUT
                  4: const pw.FlexColumnWidth(1.1), // RDQD
                  5: const pw.FlexColumnWidth(1.0), // LB
                  6: const pw.FlexColumnWidth(1.0), // LC
                  7: const pw.FlexColumnWidth(1.0), // EVG
                  8: const pw.FlexColumnWidth(1.0), // PG
                  9: const pw.FlexColumnWidth(1.0), // JP/JC
                  10: const pw.FlexColumnWidth(1.0), // RS
                },
                children: [
                  // Ligne d'en-tête du tableau
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildHeaderCell('', fontBold),
                      _buildHeaderCell('PKL', fontBold),
                      _buildHeaderCell('PSM', fontBold),
                      _buildHeaderCell('PAUT', fontBold),
                      _buildHeaderCell('RDQD', fontBold),
                      _buildHeaderCell('LB', fontBold),
                      _buildHeaderCell('LC', fontBold),
                      _buildHeaderCell('EVG', fontBold),
                      _buildHeaderCell('PG', fontBold),
                      _buildHeaderCell('JP/JC', fontBold),
                      _buildHeaderCell('RS', fontBold),
                    ],
                  ),

                  // Lignes des jours 1 à 31
                  ...report.entries.map((entry) {
                    return pw.TableRow(
                      children: [
                        _buildCell('${entry.day}', fontRegular, align: pw.Alignment.center),
                        _buildCell(DailyEntry.formatMinutes(entry.pklMinutes), fontRegular),
                        _buildCell(DailyEntry.formatMinutes(entry.psmMinutes), fontRegular),
                        _buildCell(DailyEntry.formatMinutes(entry.pautMinutes), fontRegular),
                        _buildCell(DailyEntry.formatMinutes(entry.rdqdMinutes), fontRegular),
                        _buildCell(entry.lbChapters > 0 ? '${entry.lbChapters}' : '', fontRegular, align: pw.Alignment.center),
                        _buildCell(DailyEntry.formatMinutes(entry.lcMinutes), fontRegular),
                        _buildCell(DailyEntry.formatMinutes(entry.evgMinutes), fontRegular),
                        _buildCell(entry.pgSouls > 0 ? '${entry.pgSouls}' : '', fontRegular, align: pw.Alignment.center),
                        _buildCell(entry.fasting.code, fontBold, align: pw.Alignment.center),
                        _buildCell(DailyEntry.formatMinutes(entry.rsMinutes), fontRegular),
                      ],
                    );
                  }),

                  // Ligne de TOTAL
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _buildHeaderCell('TOT', fontBold),
                      _buildCell(DailyEntry.formatMinutes(report.totalPklMinutes), fontBold),
                      _buildCell(DailyEntry.formatMinutes(report.totalPsmMinutes), fontBold),
                      _buildCell(DailyEntry.formatMinutes(report.totalPautMinutes), fontBold),
                      _buildCell(
                        '${report.rdqdDaysCount}/${report.daysInMonth}\n${DailyEntry.formatMinutes(report.totalRdqdMinutes)}',
                        fontBold,
                        align: pw.Alignment.center,
                      ),
                      _buildCell('${report.totalLbChapters}\nchap.', fontBold, align: pw.Alignment.center),
                      _buildCell(DailyEntry.formatMinutes(report.totalLcMinutes), fontBold),
                      _buildCell(DailyEntry.formatMinutes(report.totalEvgMinutes), fontBold),
                      _buildCell('${report.totalPgSouls} pers', fontBold, align: pw.Alignment.center),
                      _buildCell('${report.fastingDaysCount} jrs', fontBold, align: pw.Alignment.center),
                      _buildCell(DailyEntry.formatMinutes(report.totalRsMinutes), fontBold),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // ---- STATISTIQUES GLOBALES DU BAS ----
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL PRIÈRE SEULE : ${DailyEntry.formatMinutesLong(report.totalPriereSeuleMinutes)}',
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                  pw.Text(
                    'moyenne : ${report.formattedDailyAverage}',
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Text(
                'Âmes gagnées et intégrées : ${report.soulsIntegrated.toString().padLeft(2, '0')}',
                style: pw.TextStyle(font: fontRegular, fontSize: 10),
              ),

              pw.SizedBox(height: 6),
              pw.Text(
                'LIVRES LUS : ${report.booksRead.length.toString().padLeft(2, '0')}',
                style: pw.TextStyle(font: fontBold, fontSize: 10),
              ),
              ...List.generate(
                report.booksRead.isEmpty ? 3 : report.booksRead.length,
                (index) {
                  if (index < report.booksRead.length) {
                    final book = report.booksRead[index];
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 12, top: 1),
                      child: pw.Text(
                        '${index + 1}. ${book.title} (${book.author})',
                        style: pw.TextStyle(font: fontRegular, fontSize: 9),
                      ),
                    );
                  } else {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 12, top: 1),
                      child: pw.Text('${index + 1}. .......................................................................................',
                          style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                    );
                  }
                },
              ),

              pw.SizedBox(height: 6),
              pw.Text(
                'BESOINS DE PRIÈRES :',
                style: pw.TextStyle(font: fontBold, fontSize: 10),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, top: 2),
                child: pw.Text(
                  report.prayerRequests.isNotEmpty
                      ? report.prayerRequests
                      : '................................................................................................................................................',
                  style: pw.TextStyle(font: fontRegular, fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeaderCell(String text, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 1),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildCell(String text, pw.Font font,
      {pw.Alignment align = pw.Alignment.center}) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 1),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 7.5),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
