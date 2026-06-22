/// Representação pura de uma entrada (livro) de um feed OPDS, antes de ser
/// mapeada para o banco. Campos opcionais ausentes ficam nulos.
class OpdsEntry {
  const OpdsEntry({
    required this.calibreId,
    required this.title,
    this.author,
    this.series,
    this.seriesIndex,
    this.coverUrl,
    required this.downloadUrl,
    this.language,
    this.fileSizeKb,
    this.description,
    this.tags = const [],
  });

  final String calibreId;
  final String title;
  final String? author;
  final String? series;
  final double? seriesIndex;
  final String? coverUrl;
  final String downloadUrl;
  final String? language;
  final int? fileSizeKb;
  final String? description;
  final List<String> tags;
}
