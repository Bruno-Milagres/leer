import 'package:flutter/material.dart';

/// M04 — Detalhe do livro. Placeholder; paleta dinâmica/abas virão no módulo.
class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe')),
      body: Center(child: Text('Livro #$bookId — em construção (M04)')),
    );
  }
}
