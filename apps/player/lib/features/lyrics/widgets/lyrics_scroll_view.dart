import 'package:flutter/material.dart';

import '../../../models/lyric_line.dart';

class LyricsScrollView extends StatefulWidget {
  const LyricsScrollView({
    super.key,
    required this.lines,
    required this.position,
    required this.onSeek,
  });

  final List<LyricLine> lines;
  final Duration position;
  final ValueChanged<Duration> onSeek;

  @override
  State<LyricsScrollView> createState() => _LyricsScrollViewState();
}

class _LyricsScrollViewState extends State<LyricsScrollView> {
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _lineKeys = [];
  int _lastActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    _lineKeys = List.generate(widget.lines.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant LyricsScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lines.length != widget.lines.length) {
      _lineKeys = List.generate(widget.lines.length, (_) => GlobalKey());
      _lastActiveIndex = -1;
    }
  }

  int _activeIndex() {
    var low = 0;
    var high = widget.lines.length - 1;
    var active = -1;
    while (low <= high) {
      final middle = (low + high) >> 1;
      if (widget.lines[middle].time <= widget.position) {
        active = middle;
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    return active;
  }

  void _ensureVisible(int index) {
    if (index < 0 || index >= _lineKeys.length || index == _lastActiveIndex) {
      return;
    }
    _lastActiveIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lineContext = _lineKeys[index].currentContext;
      if (!mounted || lineContext == null || !_scrollController.hasClients) {
        return;
      }
      Scrollable.ensureVisible(
        lineContext,
        alignment: 0.46,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex();
    _ensureVisible(activeIndex);
    final theme = Theme.of(context);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
      itemCount: widget.lines.length,
      itemBuilder: (context, index) {
        final line = widget.lines[index];
        final active = index == activeIndex;
        return Padding(
          key: _lineKeys[index],
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Semantics(
            label: line.text.isEmpty ? 'Instrumental' : line.text,
            selected: active,
            child: TextButton(
              onPressed: () => widget.onSeek(line.time),
              style: TextButton.styleFrom(
                foregroundColor: active
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.68,
                      ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                alignment: Alignment.center,
                textStyle: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.35,
                ),
              ),
              child: _SynchronizedLyricText(
                line: line,
                position: widget.position,
                active: active,
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -0.35,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _SynchronizedLyricText extends StatelessWidget {
  const _SynchronizedLyricText({
    required this.line,
    required this.position,
    required this.active,
    required this.style,
  });

  final LyricLine line;
  final Duration position;
  final bool active;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseColor = active
        ? colors.onSurface
        : colors.onSurfaceVariant.withValues(alpha: 0.68);
    if (line.words.isEmpty) {
      return AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        textAlign: TextAlign.center,
        style: style.copyWith(color: baseColor),
        child: Text(line.text.isEmpty ? '♪' : line.text),
      );
    }

    var activeWord = -1;
    for (var i = 0; i < line.words.length; i++) {
      if (line.words[i].time <= position) {
        activeWord = i;
      } else {
        break;
      }
    }
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      textAlign: TextAlign.center,
      style: style.copyWith(color: baseColor),
      child: Text.rich(
        TextSpan(
          children: [
            for (var i = 0; i < line.words.length; i++)
              TextSpan(
                text: line.words[i].text,
                style: TextStyle(
                  color: i == activeWord && active
                      ? colors.primary
                      : baseColor.withValues(alpha: i < activeWord ? .72 : 1),
                  shadows: i == activeWord && active
                      ? [
                          Shadow(
                            color: colors.primary.withValues(alpha: .32),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
              ),
          ],
        ),
        key: const ValueKey('karaoke-lyric-text'),
      ),
    );
  }
}
