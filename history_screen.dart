import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = Provider.of<CalculatorProvider>(context);
    final history = provider.history;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${history.length} calculations', style: TextStyle(color: cs.onSurfaceVariant)),
          if (history.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context, provider),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(foregroundColor: cs.error),
            ),
        ]),
      ),
      Expanded(
        child: history.isEmpty
            ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.history_rounded, size: 72, color: cs.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No calculations yet', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                ]),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: history.length,
                itemBuilder: (_, i) {
                  final h = history[i];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + i * 30),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      color: cs.surfaceContainerLow,
                      child: ListTile(
                        title: Text(h.expression,
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                        trailing: Text(h.result,
                            style: TextStyle(color: cs.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          _formatDate(h.dateTime),
                          style: TextStyle(color: cs.outline, fontSize: 11),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          child: Text(h.type[0], style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12)),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _confirmClear(BuildContext ctx, CalculatorProvider provider) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('All calculation history will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () { provider.clear(); Navigator.pop(ctx); },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
