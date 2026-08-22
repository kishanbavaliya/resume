import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/section_definitions.dart';
import '../models/resume.dart';
import '../state/resume_provider.dart';

/// Feature #5: Professional Summary / Career Objective / About Me,
/// with character counter and predefined examples by profession.
class SummaryScreen extends StatefulWidget {
  final Resume resume;
  const SummaryScreen({super.key, required this.resume});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.resume.summary);
  }

  void _onChanged(String v) {
    widget.resume.summary = v;
    context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
    setState(() {});
  }

  void _useExample(String text) {
    _controller.text = text;
    _onChanged(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Write a short Professional Summary, Career Objective, or "About Me" — this appears near the top of your resume.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 6,
            maxLength: 600,
            decoration: const InputDecoration(
              labelText: 'Summary',
              alignLabelWithHint: true,
            ),
            onChanged: _onChanged,
          ),
          const SizedBox(height: 8),
          Text('Tip: keep it to 2-4 sentences focused on your strengths and goals.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          Text('Examples by profession', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...summaryExamples.entries.map((e) => Card(
                child: ListTile(
                  title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(e.value, style: const TextStyle(fontSize: 12)),
                  trailing: TextButton(onPressed: () => _useExample(e.value), child: const Text('Use')),
                ),
              )),
        ],
      ),
    );
  }
}
