import 'package:flutter/material.dart';
import '../models/resume.dart';
import '../widgets/resume_preview_widget.dart';
import 'pdf_export_screen.dart';
import 'resume_editor_screen.dart';

/// Feature #22: Live Resume Preview — updates immediately as fields change
/// because it reads directly from the same [Resume] object the editor
/// mutates. Feature #23 note: "Edit | Preview" toggle for mobile screens.
class LivePreviewScreen extends StatelessWidget {
  final Resume resume;
  const LivePreviewScreen({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('Live Preview'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => ResumeEditorScreen(resumeId: resume.id)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
            ),
            child: ResumePreview(resume: resume),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfExportScreen(resume: resume))),
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Export PDF'),
      ),
    );
  }
}
