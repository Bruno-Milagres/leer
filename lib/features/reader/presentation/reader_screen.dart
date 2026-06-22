import 'package:flutter/material.dart';

/// M05 — Leitor EPUB. Placeholder; viewer/controles/temas virão no módulo.
class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Leitor do livro #$bookId — em construção (M05)',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
