import 'package:flutter/material.dart';
import '../data/section_definitions.dart';

/// Feature #32: Offline Resume Tips section.
class ResumeTipsScreen extends StatelessWidget {
  final bool embedded;
  const ResumeTipsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final group in resumeTips) ...[
          Text(group.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: group.tips
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );

    if (embedded) {
      return Scaffold(appBar: AppBar(title: const Text('Resume Tips')), body: content);
    }
    return Scaffold(appBar: AppBar(title: const Text('Resume Tips')), body: content);
  }
}
