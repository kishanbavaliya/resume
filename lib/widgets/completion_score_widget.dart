import 'package:flutter/material.dart';
import '../models/resume.dart';

/// Feature #31: Resume Completion Score with suggestions.
class CompletionScoreWidget extends StatelessWidget {
  final Resume resume;
  final bool showSuggestions;
  const CompletionScoreWidget({super.key, required this.resume, this.showSuggestions = true});

  @override
  Widget build(BuildContext context) {
    final score = resume.completionScore();
    final suggestions = resume.completionSuggestions();
    final color = score >= 80
        ? Colors.green
        : score >= 50
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        color: color,
                        backgroundColor: color.withOpacity(0.15),
                        strokeWidth: 5,
                      ),
                      Center(
                        child: Text('$score', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Resume Completion: $score%',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (showSuggestions && suggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...suggestions.take(3).map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right, size: 18, color: Colors.grey),
                        Expanded(child: Text(s, style: const TextStyle(fontSize: 12.5))),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
