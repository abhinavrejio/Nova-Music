import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/keyboard_shortcut_service.dart';

class ShortcutCaptureDialog extends StatefulWidget {
  const ShortcutCaptureDialog({super.key, required this.current});

  final String current;

  @override
  State<ShortcutCaptureDialog> createState() => _ShortcutCaptureDialogState();
}

class _ShortcutCaptureDialogState extends State<ShortcutCaptureDialog> {
  String? _captured;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _isModifier(event.logicalKey)) {
      return KeyEventResult.handled;
    }
    setState(() => _captured = KeyboardShortcutService.fromEvent(event));
    return KeyEventResult.handled;
  }

  bool _isModifier(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.shiftLeft ||
      key == LogicalKeyboardKey.shiftRight ||
      key == LogicalKeyboardKey.controlLeft ||
      key == LogicalKeyboardKey.controlRight ||
      key == LogicalKeyboardKey.altLeft ||
      key == LogicalKeyboardKey.altRight ||
      key == LogicalKeyboardKey.metaLeft ||
      key == LogicalKeyboardKey.metaRight;

  @override
  Widget build(BuildContext context) => Focus(
    autofocus: true,
    onKeyEvent: _onKey,
    child: AlertDialog(
      icon: const Icon(Icons.keyboard_rounded),
      title: const Text('Set keyboard shortcut'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Press your new key combination. Shortcut keys are disabled while typing in text fields.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary
                      .withValues(alpha: .45),
                ),
              ),
              child: Text(
                KeyboardShortcutService.display(_captured ?? widget.current),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _captured == null ? 'Current shortcut' : 'New shortcut',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _captured == null
              ? null
              : () => Navigator.pop(context, _captured),
          child: const Text('Save shortcut'),
        ),
      ],
    ),
  );
}
