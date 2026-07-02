import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/test_result_model.dart';

/// Membuat file PDF sertifikat kelulusan Tes IQ Professional.
/// Desain: border ganda navy/gold, judul serif besar, nama peserta dengan
/// font kaligrafi, ringkasan skor, tanda tangan bergaya tulisan tangan,
/// dan cap/stempel bundar "DIGITAL LEARNING INDONESIA".
class CertificateGenerator {
  static Future<Uint8List> generate({
    required UserModel user,
    required TestResultModel result,
    required DateTime tanggal,
  }) async {
    final doc = pw.Document();

    // Font kaligrafi untuk nama peserta & tanda tangan.
    // Kalau gagal diambil (mis. tidak ada internet saat itu), pakai font bawaan sebagai cadangan.
    pw.Font scriptFont;
    pw.Font scriptFontBold;
    try {
      scriptFont = await PdfGoogleFonts.dancingScriptRegular();
      scriptFontBold = await PdfGoogleFonts.dancingScriptBold();
    } catch (_) {
      scriptFont = pw.Font.helveticaBoldOblique();
      scriptFontBold = pw.Font.helveticaBoldOblique();
    }

    pw.Font serifFont;
    pw.Font serifBold;
    try {
      serifFont = await PdfGoogleFonts.robotoSlabRegular();
      serifBold = await PdfGoogleFonts.robotoSlabBold();
    } catch (_) {
      serifFont = pw.Font.times();
      serifBold = pw.Font.timesBold();
    }

    final navy = PdfColor.fromHex('#0A2647');
    final gold = PdfColor.fromHex('#D4AF37');
    final grey = PdfColor.fromHex('#6B7280');

    final certNumber =
        'DLI/CERT/${DateFormat('yyyyMM').format(tanggal)}/${result.historyId.split('-').last}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Stack(
            children: [
              // Border luar
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: navy, width: 3),
                ),
              ),
              // Border dalam (jarak dari border luar)
              pw.Positioned.fill(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: gold, width: 1.4),
                    ),
                  ),
                ),
              ),
              // Watermark diagonal tipis
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.4,
                    child: pw.Opacity(
                      opacity: 0.06,
                      child: pw.Text(
                        AppConfig.appName.toUpperCase(),
                        style: pw.TextStyle(font: serifBold, fontSize: 70, color: navy),
                      ),
                    ),
                  ),
                ),
              ),
              // Konten utama
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 34),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          AppConfig.certificateIssuer,
                          style: pw.TextStyle(font: serifBold, fontSize: 13, color: navy, letterSpacing: 2),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          AppConfig.certificateIssuerRole,
                          style: pw.TextStyle(font: serifFont, fontSize: 9, color: grey),
                        ),
                        pw.SizedBox(height: 18),
                        pw.Text(
                          'SERTIFIKAT',
                          style: pw.TextStyle(font: serifBold, fontSize: 34, color: navy, letterSpacing: 6),
                        ),
                        pw.Text(
                          'TES IQ PROFESIONAL',
                          style: pw.TextStyle(font: serifFont, fontSize: 13, color: gold, letterSpacing: 4),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Dengan bangga diberikan kepada:',
                            style: pw.TextStyle(font: serifFont, fontSize: 11, color: grey)),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          user.nama,
                          style: pw.TextStyle(font: scriptFontBold, fontSize: 38, color: navy),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(width: 260, height: 1, color: gold),
                        pw.SizedBox(height: 14),
                        pw.Text(
                          'Atas keberhasilannya menyelesaikan Tes IQ Profesional\n'
                          'yang diselenggarakan oleh ${AppConfig.certificateIssuer}',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: serifFont, fontSize: 11, color: grey, lineSpacing: 3),
                        ),
                        pw.SizedBox(height: 16),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            _scoreBox(label: 'Skor IQ', value: '${result.iq}', serifBold: serifBold, serifFont: serifFont, navy: navy, gold: gold),
                            pw.SizedBox(width: 26),
                            _scoreBox(label: 'Kategori', value: result.kategori, serifBold: serifBold, serifFont: serifFont, navy: navy, gold: gold),
                            pw.SizedBox(width: 26),
                            _scoreBox(label: 'Persentase Benar', value: '${result.persentase}%', serifBold: serifBold, serifFont: serifFont, navy: navy, gold: gold),
                          ],
                        ),
                      ],
                    ),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Tanggal Tes', style: pw.TextStyle(font: serifFont, fontSize: 9, color: grey)),
                            pw.Text(_formatTanggalIndonesia(tanggal),
                                style: pw.TextStyle(font: serifBold, fontSize: 11, color: navy)),
                            pw.SizedBox(height: 6),
                            pw.Text('No. Sertifikat', style: pw.TextStyle(font: serifFont, fontSize: 9, color: grey)),
                            pw.Text(certNumber, style: pw.TextStyle(font: serifBold, fontSize: 10, color: navy)),
                          ],
                        ),
                        pw.Stack(
                          alignment: pw.Alignment.center,
                          children: [
                            pw.Positioned(
                              right: 46,
                              bottom: -6,
                              child: _stamp(navy: navy, gold: gold, serifBold: serifBold),
                            ),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  AppConfig.certificateIssuer,
                                  style: pw.TextStyle(font: scriptFont, fontSize: 22, color: navy),
                                ),
                                pw.Container(width: 170, height: 1, color: navy, margin: const pw.EdgeInsets.only(top: 2, bottom: 4)),
                                pw.Text('Penyelenggara Tes',
                                    style: pw.TextStyle(font: serifFont, fontSize: 9, color: grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// Menampilkan preview PDF native (bisa Save / Print / Share dari sana).
  static Future<void> openPreview({
    required UserModel user,
    required TestResultModel result,
    required DateTime tanggal,
  }) async {
    final bytes = await generate(user: user, result: result, tanggal: tanggal);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Sertifikat_IQ_${user.nama.replaceAll(' ', '_')}.pdf',
    );
  }
}

/// Format tanggal ke Bahasa Indonesia tanpa bergantung pada inisialisasi
/// locale data dari package intl (menghindari error "Locale data has not
/// been initialized" yang bisa terjadi kalau initializeDateFormatting belum dipanggil).
String _formatTanggalIndonesia(DateTime date) {
  const bulanIndonesia = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  return '${date.day} ${bulanIndonesia[date.month]} ${date.year}';
}

/// Kotak kecil menampilkan satu ringkasan skor (IQ / Kategori / Persentase).
pw.Widget _scoreBox({
  required String label,
  required String value,
  required pw.Font serifBold,
  required pw.Font serifFont,
  required PdfColor navy,
  required PdfColor gold,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: gold, width: 0.8),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(font: serifBold, fontSize: 16, color: navy)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: pw.TextStyle(font: serifFont, fontSize: 8, color: navy)),
      ],
    ),
  );
}
pw.Widget _stamp({required PdfColor navy, required PdfColor gold, required pw.Font serifBold}) {
  return pw.Transform.rotate(
    angle: -0.18,
    child: pw.Opacity(
      opacity: 0.85,
      child: pw.Container(
        width: 92,
        height: 92,
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: gold, width: 2.2),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: navy, width: 1),
            ),
            child: pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('★', style: pw.TextStyle(font: serifBold, fontSize: 12, color: gold)),
                  pw.SizedBox(height: 1),
                  pw.Text('DIGITAL', style: pw.TextStyle(font: serifBold, fontSize: 7, color: navy)),
                  pw.Text('LEARNING', style: pw.TextStyle(font: serifBold, fontSize: 7, color: navy)),
                  pw.Text('INDONESIA', style: pw.TextStyle(font: serifBold, fontSize: 7, color: navy)),
                  pw.SizedBox(height: 2),
                  pw.Text('TERVERIFIKASI', style: pw.TextStyle(font: serifBold, fontSize: 5, color: gold)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
