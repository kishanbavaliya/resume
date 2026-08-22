import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resume.dart';
import '../state/resume_provider.dart';
import '../widgets/resume_preview_widget.dart';
import 'resume_editor_screen.dart';
import 'live_preview_screen.dart';
import 'template_selection_screen.dart';

/// Feature #24: Multiple Resumes — open / edit / duplicate / rename /
/// export / delete. Also serves as the "Home → My Resumes" flow (#2).
class MyResumesScreen extends StatelessWidget {
  final bool embedded;
  const MyResumesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final resumes = context.watch<ResumeProvider>().resumes;

    final body = resumes.isEmpty
        ? _EmptyState(embedded: embedded)
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: resumes.length,
            itemBuilder: (context, i) => _ResumeCard(resume: resumes[i]),
          );

    if (embedded) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Resumes')),
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const TemplateSelectionScreen())),
          child: const Icon(Icons.add),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Resumes')),
      body: body,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool embedded;
  const _EmptyState({required this.embedded});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No resumes yet', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Create your first resume to get started.',
                style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const TemplateSelectionScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Create Resume'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final Resume resume;
  const _ResumeCard({required this.resume});

  void _openEditor(BuildContext context) {
    context.read<ResumeProvider>().setCurrent(resume);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResumeEditorScreen(resumeId: resume.id)));
  }

  void _menu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              _openEditor(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('Preview'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => LivePreviewScreen(resume: resume)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('Duplicate'),
            onTap: () {
              Navigator.pop(ctx);
              context.read<ResumeProvider>().duplicateResume(resume);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Resume duplicated')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(ctx);
              _rename(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDelete(context);
            },
          ),
        ]),
      ),
    );
  }

  void _rename(BuildContext context) {
    final controller = TextEditingController(text: resume.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Resume'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<ResumeProvider>().renameResume(resume, controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: Text('"${resume.title}" will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ResumeProvider>().deleteResume(resume);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openEditor(context),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ResumePreview(resume: resume)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(resume.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        Text('${resume.completionScore()}% complete',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _menu(context),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.more_vert, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
