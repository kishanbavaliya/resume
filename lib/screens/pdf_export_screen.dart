import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/resume.dart';
import '../pdf/pdf_generator.dart';
import '../state/settings_provider.dart';

/// Feature #28/#29: PDF Generation & Actions (paper size, file name,
/// Save / Share / Open / Print / Delete via Android share sheet).
class PdfExportScreen extends StatefulWidget {
  final Resume resume;
  const PdfExportScreen({super.key, required this.resume});

  @override
  State<PdfExportScreen> createState() => _PdfExportScreenState();
}

class _PdfExportScreenState extends State<PdfExportScreen> {
  late String _paperSize;
  late TextEditingController _fileNameController;
  File? _savedFile;

  @override
  void initState() {
    super.initState();
    _paperSize = context.read<SettingsProvider>().defaultPaperSize;
    final safeName = widget.resume.personalInfo.fullName.trim().isEmpty
        ? widget.resume.title
        : '${widget.resume.personalInfo.fullName}_Resume';
    _fileNameController = TextEditingController(text: safeName.replaceAll(' ', '_'));
  }

  String get _fileName {
    var name = _fileNameController.text.trim();
    if (name.isEmpty) name = 'Resume';
    if (!name.toLowerCase().endsWith('.pdf')) name = '$name.pdf';
    return name;
  }

  Future<Uint8List> _generateBytes() async {
    final doc = await PdfGenerator.build(widget.resume, paperSize: _paperSize);
    return doc.save();
  }

  Future<void> _saveToDevice() async {
    final bytes = await _generateBytes();
    final dir = await getApplicationDocumentsDirectory();
    final resumesDir = Directory('${dir.path}/Resumes');
    if (!await resumesDir.exists()) await resumesDir.create(recursive: true);
    final file = File('${resumesDir.path}/$_fileName');
    await file.writeAsBytes(bytes);
    setState(() => _savedFile = file);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
    }
  }

  Future<void> _share() async {
    final bytes = await _generateBytes();
    await Printing.sharePdf(bytes: bytes, filename: _fileName);
  }

  Future<void> _print() async {
    final bytes = await _generateBytes();
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  Future<void> _deleteSaved() async {
    if (_savedFile != null && await _savedFile!.exists()) {
      await _savedFile!.delete();
      setState(() => _savedFile = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export PDF')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Paper size'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'A4', label: Text('A4')),
                          ButtonSegment(value: 'Letter', label: Text('Letter')),
                        ],
                        selected: {_paperSize},
                        onSelectionChanged: (s) => setState(() => _paperSize = s.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fileNameController,
                  decoration: const InputDecoration(
                    labelText: 'File name',
                    suffixText: '.pdf',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              build: (format) async => _generateBytes(),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowSharing: true,
              allowPrinting: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _saveToDevice,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Save'),
                ),
                OutlinedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
                OutlinedButton.icon(
                  onPressed: _print,
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Print'),
                ),
                if (_savedFile != null)
                  OutlinedButton.icon(
                    onPressed: _deleteSaved,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
