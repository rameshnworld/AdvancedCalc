import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tp = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Theme Mode', cs),
          const SizedBox(height: 8),
          _ThemeModeSelector(tp: tp, cs: cs),
          const SizedBox(height: 24),
          _sectionTitle('Accent Color', cs),
          const SizedBox(height: 8),
          _ColorPicker(tp: tp, cs: cs),
          const SizedBox(height: 24),
          _sectionTitle('Preview', cs),
          const SizedBox(height: 8),
          _Preview(cs: cs),
          const SizedBox(height: 24),
          _InfoCard(cs: cs),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme cs) {
    return Text(title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.primary));
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeProvider tp;
  final ColorScheme cs;
  const _ThemeModeSelector({required this.tp, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          _modeBtn(context, ThemeMode.light, Icons.light_mode_rounded, 'Light'),
          const SizedBox(width: 8),
          _modeBtn(context, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
          const SizedBox(width: 8),
          _modeBtn(context, ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
        ]),
      ),
    );
  }

  Widget _modeBtn(BuildContext ctx, ThemeMode mode, IconData icon, String label) {
    final selected = tp.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => tp.setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? cs.onPrimary : cs.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
          ]),
        ),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final ThemeProvider tp;
  final ColorScheme cs;
  const _ColorPicker({required this.tp, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppColors.names.map((name) {
            final color = AppColors.get(name);
            final selected = tp.selectedColor == name;
            return GestureDetector(
              onTap: () => tp.setColor(name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: selected ? Border.all(color: cs.onSurface, width: 3) : null,
                  boxShadow: selected
                      ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final ColorScheme cs;
  const _Preview({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Text('123 + 456 = 579',
                style: TextStyle(fontSize: 20, color: cs.onPrimaryContainer, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _previewBtn('7', cs.surfaceContainerHighest, cs.onSurface)),
            const SizedBox(width: 8),
            Expanded(child: _previewBtn('×', cs.primary, cs.onPrimary)),
            const SizedBox(width: 8),
            Expanded(child: _previewBtn('=', cs.primary, cs.onPrimary)),
          ]),
        ]),
      ),
    );
  }

  Widget _previewBtn(String label, Color bg, Color fg) {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 18))),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ColorScheme cs;
  const _InfoCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cs.surfaceContainerLow,
      child: ListTile(
        leading: Icon(Icons.info_outline_rounded, color: cs.primary),
        title: const Text('Advanced Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Version 1.0.0 • Built with Flutter'),
      ),
    );
  }
}
