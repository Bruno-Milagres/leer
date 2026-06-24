import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/reader_providers.dart';
import 'reader_controls.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _epubController = EpubController();
  bool _controlsVisible = false;
  String _chapter = '';
  double _progress = 0.0;
  String? _currentCfi;
  Timer? _debounceTimer;
  bool _epubLoaded = false;

  String? _selectedText;
  String? _selectedCfi;
  Rect? _selectionRect;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _saveProgressSync();
    _debounceTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookDataAsync = ref.watch(readerBookProvider(widget.bookId));
    final settings = ref.watch(readerSettingsProvider);

    return bookDataAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Erro ao carregar livro',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        if (data == null || data.book.localEpubPath == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('EPUB não encontrado',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          );
        }

        final file = File(data.book.localEpubPath!);
        if (!file.existsSync()) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Arquivo EPUB não encontrado',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          );
        }

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) _saveProgressSync();
          },
          child: Scaffold(
            body: Stack(
              children: [
                EpubViewer(
                  epubController: _epubController,
                  epubSource: EpubSource.fromFile(file),
                  initialCfi: data.progress?.cfi,
                  displaySettings: settings.toDisplaySettings(),
                  suppressNativeContextMenu: true,
                  onEpubLoaded: () {
                    setState(() => _epubLoaded = true);
                    _restoreHighlights();
                  },
                  onChaptersLoaded: (chapters) {
                    if (chapters.isNotEmpty && _chapter.isEmpty) {
                      setState(() => _chapter = chapters.first.title);
                    }
                  },
                  onRelocated: (location) {
                    setState(() {
                      _progress = location.progress;
                      _currentCfi = location.startCfi;
                    });
                    _debouncedSaveProgress(location);
                  },
                  onSelection: (text, cfi, rect, viewRect) {
                    setState(() {
                      _selectedText = text;
                      _selectedCfi = cfi;
                      _selectionRect = rect;
                      _controlsVisible = false;
                    });
                  },
                  onDeselection: () {
                    setState(() {
                      _selectedText = null;
                      _selectedCfi = null;
                      _selectionRect = null;
                    });
                  },
                  onTouchUp: (x, y) {
                    if (_selectedText != null) return;
                    if (x > 0.25 && x < 0.75 && y > 0.2 && y < 0.8) {
                      setState(
                          () => _controlsVisible = !_controlsVisible);
                    }
                  },
                ),
                ReaderControls(
                  visible: _controlsVisible,
                  title: data.book.title,
                  chapter: _chapter,
                  progress: _progress,
                  onClose: () {
                    _saveProgressSync();
                    Navigator.of(context).pop();
                  },
                  onProgressChanged: (value) {
                    if (_epubLoaded) {
                      _epubController.toProgressPercentage(value);
                    }
                  },
                  onSettingsTap: () => _openSettings(settings),
                ),
                if (_selectedText != null && _selectionRect != null)
                  _SelectionMenu(
                    rect: _selectionRect!,
                    onHighlight: _onHighlight,
                    onAnnotate: _onAnnotate,
                    onCopy: _onCopy,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _restoreHighlights() async {
    final db = ref.read(databaseProvider);
    final annotations =
        await db.annotationsDao.watchForBook(widget.bookId).first;
    for (final a in annotations) {
      _epubController.addHighlight(
        cfi: a.cfi,
        color: Color(int.parse(a.color.replaceFirst('#', '0xFF'))),
        opacity: 0.3,
      );
    }
  }

  void _onHighlight(Color color) {
    if (_selectedText == null || _selectedCfi == null) return;
    final colorHex =
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    final db = ref.read(databaseProvider);
    db.annotationsDao.insertAnnotation(AnnotationsCompanion(
      bookId: Value(widget.bookId),
      cfi: Value(_selectedCfi!),
      selectedText: Value(_selectedText!),
      color: Value(colorHex),
    ));
    _epubController.addHighlight(
        cfi: _selectedCfi!, color: color, opacity: 0.3);
    _epubController.clearSelection();
    setState(() {
      _selectedText = null;
      _selectedCfi = null;
      _selectionRect = null;
    });
  }

  void _onAnnotate() {
    if (_selectedText == null || _selectedCfi == null) return;
    final text = _selectedText!;
    final cfi = _selectedCfi!;

    showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Adicionar nota'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration:
                const InputDecoration(hintText: 'Digite sua nota...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    ).then((note) {
      if (note == null) return;
      final db = ref.read(databaseProvider);
      db.annotationsDao.insertAnnotation(AnnotationsCompanion(
        bookId: Value(widget.bookId),
        cfi: Value(cfi),
        selectedText: Value(text),
        note: Value(note.isNotEmpty ? note : null),
        color: Value('#FFB300'),
      ));
      _epubController.addHighlight(
          cfi: cfi, color: AppColors.highlightYellow, opacity: 0.3);
      _epubController.clearSelection();
      setState(() {
        _selectedText = null;
        _selectedCfi = null;
        _selectionRect = null;
      });
    });
  }

  void _onCopy() {
    if (_selectedText == null) return;
    Clipboard.setData(ClipboardData(text: _selectedText!));
    _epubController.clearSelection();
    setState(() {
      _selectedText = null;
      _selectedCfi = null;
      _selectionRect = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Texto copiado')),
    );
  }

  void _openSettings(ReaderSettings current) {
    showReaderSettingsSheet(
      context,
      settings: current,
      onChanged: (newSettings) {
        ref.read(readerSettingsProvider.notifier).state = newSettings;
        if (_epubLoaded) {
          _epubController.setFontSize(
              fontSize: newSettings.fontSize.toDouble());
          _epubController.updateTheme(
              theme: newSettings.toDisplaySettings().theme!);
        }
      },
    );
  }

  void _debouncedSaveProgress(EpubLocation location) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _saveProgress(
        cfi: location.startCfi,
        percentage: (location.progress * 100).round(),
      );
    });
  }

  void _saveProgressSync() {
    _debounceTimer?.cancel();
    if (_currentCfi != null) {
      _saveProgress(
        cfi: _currentCfi!,
        percentage: (_progress * 100).round(),
      );
    }
  }

  void _saveProgress({required String cfi, required int percentage}) {
    final db = ref.read(databaseProvider);
    db.readingProgressDao.save(
      ReadingProgressCompanion(
        bookId: Value(widget.bookId),
        cfi: Value(cfi),
        percentage: Value(percentage),
        chapter: Value(_chapter.isNotEmpty ? _chapter : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

class _SelectionMenu extends StatelessWidget {
  const _SelectionMenu({
    required this.rect,
    required this.onHighlight,
    required this.onAnnotate,
    required this.onCopy,
  });

  final Rect rect;
  final ValueChanged<Color> onHighlight;
  final VoidCallback onAnnotate;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final menuTop = rect.top > 80 ? rect.top - 60 : rect.bottom + 8;

    return Positioned(
      left: (rect.left + rect.right) / 2 - 120,
      top: menuTop,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...AppColors.highlightColors.map((c) => _ColorDot(
                    color: c,
                    onTap: () => onHighlight(c),
                  )),
              const SizedBox(width: 4),
              _MenuButton(
                icon: Icons.edit_note_rounded,
                label: 'Anotar',
                onTap: onAnnotate,
              ),
              _MenuButton(
                icon: Icons.copy_rounded,
                label: 'Copiar',
                onTap: onCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.white70),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
