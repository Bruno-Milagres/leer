import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
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
                  onEpubLoaded: () {
                    setState(() => _epubLoaded = true);
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
                  onTouchUp: (x, y) {
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
              ],
            ),
          ),
        );
      },
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
