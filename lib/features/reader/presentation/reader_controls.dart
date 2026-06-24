import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../providers/reader_providers.dart';

class ReaderControls extends StatelessWidget {
  const ReaderControls({
    super.key,
    required this.visible,
    required this.title,
    required this.chapter,
    required this.progress,
    required this.onClose,
    required this.onProgressChanged,
    required this.onSettingsTap,
  });

  final bool visible;
  final String title;
  final String chapter;
  final double progress;
  final VoidCallback onClose;
  final ValueChanged<double> onProgressChanged;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: AppTokens.animationDuration,
        curve: AppTokens.animationCurve,
        child: Column(
          children: [
            _TopBar(
              title: title,
              onClose: onClose,
              onSettingsTap: onSettingsTap,
            ),
            const Spacer(),
            _BottomBar(
              chapter: chapter,
              progress: progress,
              onProgressChanged: onProgressChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onClose,
    required this.onSettingsTap,
  });

  final String title;
  final VoidCallback onClose;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceSm,
            vertical: AppTokens.spaceXs,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.text_fields_rounded,
                    color: Colors.white),
                onPressed: onSettingsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.chapter,
    required this.progress,
    required this.onProgressChanged,
  });

  final String chapter;
  final double progress;
  final ValueChanged<double> onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMd,
            vertical: AppTokens.spaceSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chapter,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: onProgressChanged,
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showReaderSettingsSheet(
  BuildContext context, {
  required ReaderSettings settings,
  required ValueChanged<ReaderSettings> onChanged,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => _ReaderSettingsSheet(
      settings: settings,
      onChanged: onChanged,
    ),
  );
}

class _ReaderSettingsSheet extends StatefulWidget {
  const _ReaderSettingsSheet({
    required this.settings,
    required this.onChanged,
  });

  final ReaderSettings settings;
  final ValueChanged<ReaderSettings> onChanged;

  @override
  State<_ReaderSettingsSheet> createState() => _ReaderSettingsSheetState();
}

class _ReaderSettingsSheetState extends State<_ReaderSettingsSheet> {
  late ReaderSettings _current;

  @override
  void initState() {
    super.initState();
    _current = widget.settings;
  }

  void _update(ReaderSettings s) {
    setState(() => _current = s);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema de leitura', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTokens.spaceSm),
          Row(
            children: ReaderThemeType.values.map((t) {
              final colors = _themePreviewColors(t);
              final selected = t == _current.theme;
              return Padding(
                padding: const EdgeInsets.only(right: AppTokens.spaceSm),
                child: GestureDetector(
                  onTap: () => _update(_current.copyWith(theme: t)),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.$1,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'A',
                        style: TextStyle(color: colors.$2, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Text('Fonte', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTokens.spaceSm),
          Wrap(
            spacing: AppTokens.spaceSm,
            children: readerFontFamilies.map((f) {
              return ChoiceChip(
                label: Text(f),
                selected: f == _current.fontFamily,
                onSelected: (_) =>
                    _update(_current.copyWith(fontFamily: f)),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Text('Tamanho: ${_current.fontSize}px',
              style: theme.textTheme.titleSmall),
          Slider(
            value: _current.fontSize.toDouble(),
            min: 12,
            max: 28,
            divisions: 16,
            label: '${_current.fontSize}',
            onChanged: (v) =>
                _update(_current.copyWith(fontSize: v.round())),
          ),
          Text(
              'Espaçamento: ${_current.lineSpacing.toStringAsFixed(1)}',
              style: theme.textTheme.titleSmall),
          Slider(
            value: _current.lineSpacing,
            min: 1.0,
            max: 2.5,
            divisions: 15,
            label: _current.lineSpacing.toStringAsFixed(1),
            onChanged: (v) =>
                _update(_current.copyWith(lineSpacing: v)),
          ),
        ],
      ),
    );
  }

  (Color, Color) _themePreviewColors(ReaderThemeType t) {
    switch (t) {
      case ReaderThemeType.light:
        return (Colors.white, Colors.black);
      case ReaderThemeType.sepia:
        return (const Color(0xFFF5E6CA), const Color(0xFF5B4636));
      case ReaderThemeType.dark:
        return (const Color(0xFF1C1917), const Color(0xFFD4D0CB));
      case ReaderThemeType.amoled:
        return (Colors.black, const Color(0xFFB0B0B0));
    }
  }
}
