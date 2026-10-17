import 'package:flutter/services.dart';

class KeyboardShortcutService {
  const KeyboardShortcutService._();

  static String fromEvent(KeyEvent event) {
    final key = _keyName(event.logicalKey);
    final keyboard = HardwareKeyboard.instance;
    final parts = <String>[
      if (keyboard.isControlPressed) 'ctrl',
      if (keyboard.isAltPressed) 'alt',
      if (keyboard.isShiftPressed) 'shift',
      if (keyboard.isMetaPressed) 'meta',
      key,
    ];
    return parts.join('+');
  }

  static bool matches(String binding, KeyEvent event) =>
      _normalizeBinding(binding) == _normalizeBinding(fromEvent(event));

  static String display(String binding) {
    final parts = _normalizeBinding(binding).split('+');
    return parts
        .map((part) {
          if (part == 'ctrl') return 'Ctrl';
          if (part == 'alt') return 'Alt';
          if (part == 'shift') return 'Shift';
          if (part == 'meta') return 'Win';
          if (part == 'arrowleft') return '←';
          if (part == 'arrowright') return '→';
          if (part == 'arrowup') return '↑';
          if (part == 'arrowdown') return '↓';
          if (part == 'space') return 'Space';
          return part.length == 1 ? part.toUpperCase() : part;
        })
        .join(' + ');
  }

  static String _keyName(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.space) return 'space';
    if (key == LogicalKeyboardKey.arrowLeft) return 'arrowleft';
    if (key == LogicalKeyboardKey.arrowRight) return 'arrowright';
    if (key == LogicalKeyboardKey.arrowUp) return 'arrowup';
    if (key == LogicalKeyboardKey.arrowDown) return 'arrowdown';
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      return 'enter';
    }
    if (key == LogicalKeyboardKey.escape) return 'escape';
    if (key == LogicalKeyboardKey.tab) return 'tab';
    if (key == LogicalKeyboardKey.backspace) return 'backspace';
    if (key == LogicalKeyboardKey.delete) return 'delete';
    if (key == LogicalKeyboardKey.home) return 'home';
    if (key == LogicalKeyboardKey.end) return 'end';

    final label = key.keyLabel.trim().toLowerCase();
    final normalized = label.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.isEmpty
        ? 'key${key.keyId.toRadixString(16)}'
        : normalized;
  }

  static String _normalizeBinding(String binding) => binding
      .toLowerCase()
      .split('+')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList()
      .join('+');
}
