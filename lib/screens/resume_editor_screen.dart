import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/section_definitions.dart';
import '../models/resume.dart';
import '../state/resume_provider.dart';
import '../widgets/completion_score_widget.dart';
import 'personal_info_screen.dart';
import 'summary_screen.dart';
import 'section_editor_screen.dart';
import 'live_preview_screen.dart';
import 'customize_template_screen.dart';
import 'pdf_export_screen.dart';

/// Feature #23: Resume Editor — each section as a card, drag-and-drop
/// reorder, add/hide/remove sections (feature #19).
class ResumeEditorScreen extends StatefulWidget {
  final String resumeId;
  const ResumeEditorScreen({super.key, required this.resumeId});

  @override
  State<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends State<ResumeEditorScreen> {
  Resume get resume =>
      context.read<ResumeProvider>().resumes.firstWhere((r) => r.id == widget.resumeId);

  void _save() => context.read<ResumeProvider>().notifyChangedAndSave(resume);

  void _editTitle() {
    final controller = TextEditingController(text: resume.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resume Title'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() => resume.title = controller.text.trim());
              _save();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleVisible(ResumeSection s) {
    setState(() => s.visible = !s.visible);
    _save();
  }

  void _removeSection(ResumeSection s) {
    setState(() => resume.sections.remove(s));
    _save();
  }

  void _reorder(int oldIndex, int newIndex) {
    final visible = resume.visibleSectionsSorted;
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    for (var i = 0; i < visible.length; i++) {
      visible[i].order = i;
    }
    setState(() {});
    _save();
  }

  void _addSection() {
    final addable = addableSectionTypes(resume);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: addable.length,
                itemBuilder: (context, i) {
                  final type = addable[i];
                  final cfg = kSectionConfigs[type]!;
                  return ListTile(
                    leading: Icon(cfg.icon),
                    title: Text(cfg.defaultTitle),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        resume.sections.add(ResumeSection(
                          type: type,
                          title: cfg.defaultTitle,
                          order: resume.sections.length,
                          visible: true,
                        ));
                      });
                      _save();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _manageSections() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child:
                    Text('Manage Sections', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: resume.sections.map((s) {
                    return SwitchListTile(
                      title: Text(s.title),
                      value: s.visible,
                      onChanged: (v) {
                        setSheetState(() => s.visible = v);
                        setState(() {});
                        _save();
                      },
                      secondary: s.type == SectionType.custom
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setSheetState(() => resume.sections.remove(s));
                                setState(() {});
                                _save();
                              },
                            )
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ResumeProvider>(); // rebuild on external changes
    final visibleSections = resume.visibleSectionsSorted;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _editTitle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(resume.title, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 15),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Customize',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CustomizeTemplateScreen(resume: resume))),
          ),
          IconButton(
            tooltip: 'Preview',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LivePreviewScreen(resume: resume))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        children: [
          CompletionScoreWidget(resume: resume),
          const SizedBox(height: 12),
          _FixedCard(
            icon: Icons.badge_outlined,
            title: 'Personal Information',
            subtitle: resume.personalInfo.fullName.isEmpty
                ? 'Add your name, contact & links'
                : resume.personalInfo.fullName,
            onTap: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => PersonalInfoScreen(resume: resume)));
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          _FixedCard(
            icon: Icons.notes_outlined,
            title: 'Summary',
            subtitle: resume.summary.isEmpty ? 'Add a professional summary' : resume.summary,
            onTap: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SummaryScreen(resume: resume)));
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Sections', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: _manageSections,
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Manage'),
              ),
            ],
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleSections.length,
            onReorder: _reorder,
            itemBuilder: (context, i) {
              final s = visibleSections[i];
              final cfg = kSectionConfigs[s.type]!;
              return Padding(
                key: ValueKey(s.id),
                padding: const EdgeInsets.only(bottom: 8),
                child: _SectionCard(
                  icon: cfg.icon,
                  title: s.title,
                  count: s.entries.length,
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SectionEditorScreen(resume: resume, section: s)));
                    setState(() {});
                  },
                  onHide: () => _toggleVisible(s),
                  onDelete: s.type == SectionType.custom ? () => _removeSection(s) : null,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addSection,
            icon: const Icon(Icons.add),
            label: const Text('Add Section'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => PdfExportScreen(resume: resume))),
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Export PDF'),
      ),
    );
  }
}

class _FixedCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _FixedCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon, size: 18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onHide;
  final VoidCallback? onDelete;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
    required this.onHide,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.drag_indicator, color: Colors.grey),
        title: Row(
          children: [
            Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        subtitle: Text('$count entr${count == 1 ? 'y' : 'ies'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onTap),
            IconButton(icon: const Icon(Icons.visibility_off_outlined, size: 20), onPressed: onHide),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: onDelete),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
