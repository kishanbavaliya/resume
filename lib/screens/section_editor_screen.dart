import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/section_definitions.dart';
import '../models/resume.dart';
import '../state/resume_provider.dart';

/// Generic editor for any repeatable section (Experience, Education,
/// Skills, Projects, Certifications, Languages, Achievements, Awards,
/// Volunteer, Publications, Interests, References, Custom).
/// One engine drives all of them via [kSectionConfigs], per feature #6-#18.
class SectionEditorScreen extends StatefulWidget {
  final Resume resume;
  final ResumeSection section;
  const SectionEditorScreen({super.key, required this.resume, required this.section});

  @override
  State<SectionEditorScreen> createState() => _SectionEditorScreenState();
}

class _SectionEditorScreenState extends State<SectionEditorScreen> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
  }

  void _save() => context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);

  void _addEntry() async {
    final cfg = kSectionConfigs[widget.section.type]!;
    final entry = SectionEntry();
    final result = await Navigator.of(context).push<SectionEntry>(
      MaterialPageRoute(builder: (_) => _EntryFormScreen(cfg: cfg, entry: entry, isNew: true)),
    );
    if (result != null) {
      setState(() => widget.section.entries.add(result));
      _save();
    }
  }

  void _editEntry(SectionEntry entry) async {
    final cfg = kSectionConfigs[widget.section.type]!;
    final result = await Navigator.of(context).push<SectionEntry>(
      MaterialPageRoute(builder: (_) => _EntryFormScreen(cfg: cfg, entry: entry, isNew: false)),
    );
    if (result != null) {
      setState(() {});
      _save();
    }
  }

  void _duplicateEntry(SectionEntry entry) {
    setState(() => widget.section.entries.add(entry.copy()));
    _save();
  }

  void _deleteEntry(SectionEntry entry) {
    setState(() => widget.section.entries.remove(entry));
    _save();
  }

  void _move(int index, int delta) {
    final entries = widget.section.entries;
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= entries.length) return;
    setState(() {
      final e = entries.removeAt(index);
      entries.insert(newIndex, e);
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = kSectionConfigs[widget.section.type]!;
    final isCustom = widget.section.type == SectionType.custom;

    return Scaffold(
      appBar: AppBar(
        title: isCustom
            ? SizedBox(
                width: 220,
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  onChanged: (v) {
                    widget.section.title = v;
                    _save();
                  },
                ),
              )
            : Text(widget.section.title),
      ),
      body: widget.section.entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cfg.icon, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No entries yet', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.section.entries.length,
              itemBuilder: (context, i) {
                final e = widget.section.entries[i];
                final primary = e.values[cfg.primaryField] ?? '(untitled)';
                final secondary =
                    cfg.secondaryField.isNotEmpty ? (e.values[cfg.secondaryField] ?? '') : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => _editEntry(e),
                    title: Text(primary.isEmpty ? '(untitled)' : primary,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: secondary.isNotEmpty ? Text(secondary) : null,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        switch (v) {
                          case 'edit':
                            _editEntry(e);
                            break;
                          case 'duplicate':
                            _duplicateEntry(e);
                            break;
                          case 'delete':
                            _deleteEntry(e);
                            break;
                          case 'up':
                            _move(i, -1);
                            break;
                          case 'down':
                            _move(i, 1);
                            break;
                        }
                      },
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                        PopupMenuItem(value: 'up', child: Text('Move Up')),
                        PopupMenuItem(value: 'down', child: Text('Move Down')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.add),
        label: Text('Add ${cfg.defaultTitle.replaceAll(RegExp(r's$'), '')}'),
      ),
    );
  }
}

class _EntryFormScreen extends StatefulWidget {
  final SectionConfig cfg;
  final SectionEntry entry;
  final bool isNew;
  const _EntryFormScreen({required this.cfg, required this.entry, required this.isNew});

  @override
  State<_EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<_EntryFormScreen> {
  final _controllers = <String, TextEditingController>{};
  final _checkboxValues = <String, bool>{};

  @override
  void initState() {
    super.initState();
    for (final f in widget.cfg.fields) {
      if (f.kind == FieldKind.checkbox) {
        _checkboxValues[f.key] = widget.entry.values[f.key] == 'true';
      } else {
        _controllers[f.key] = TextEditingController(text: widget.entry.values[f.key] ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(FieldDef f) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = DateFormat('MMM yyyy').format(picked);
      _controllers[f.key]!.text = formatted;
      setState(() {});
    }
  }

  void _submit() {
    for (final f in widget.cfg.fields) {
      if (f.required && f.kind != FieldKind.checkbox) {
        final v = _controllers[f.key]?.text.trim() ?? '';
        if (v.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('${f.label} is required')));
          return;
        }
      }
    }
    for (final f in widget.cfg.fields) {
      if (f.kind == FieldKind.checkbox) {
        widget.entry.values[f.key] = (_checkboxValues[f.key] ?? false).toString();
      } else {
        widget.entry.values[f.key] = _controllers[f.key]!.text.trim();
      }
    }
    Navigator.of(context).pop(widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    final currentCheckbox = widget.cfg.fields.firstWhere(
      (f) => f.kind == FieldKind.checkbox,
      orElse: () => const FieldDef(key: '', label: ''),
    );
    final isCurrentJob = currentCheckbox.key.isNotEmpty && (_checkboxValues[currentCheckbox.key] ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Add ${widget.cfg.defaultTitle}' : 'Edit ${widget.cfg.defaultTitle}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final f in widget.cfg.fields) ...[
            if (f.kind == FieldKind.checkbox)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(f.label),
                value: _checkboxValues[f.key] ?? false,
                onChanged: (v) => setState(() => _checkboxValues[f.key] = v),
              )
            else if (f.kind == FieldKind.date)
              if (f.key == 'endDate' && isCurrentJob)
                const SizedBox.shrink()
              else
                TextField(
                  controller: _controllers[f.key],
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: f.label + (f.required ? ' *' : ''),
                    suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  onTap: () => _pickDate(f),
                )
            else
              TextField(
                controller: _controllers[f.key],
                maxLines: f.kind == FieldKind.longText ? 5 : 1,
                decoration: InputDecoration(
                  labelText: f.label + (f.required ? ' *' : ''),
                  alignLabelWithHint: f.kind == FieldKind.longText,
                ),
              ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _submit, child: const Text('Save')),
          ),
        ],
      ),
    );
  }
}
