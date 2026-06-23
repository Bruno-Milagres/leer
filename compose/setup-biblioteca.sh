#!/usr/bin/env bash
#
# setup-biblioteca.sh
# Popula a biblioteca Calibre com EPUBs de dominio publico (Project Gutenberg)
# para voce ter livros de teste no Leer imediatamente.
#
# Pre-requisito: ter o "calibredb" instalado (vem com o Calibre desktop).
#   - Linux:   sudo apt install calibre
#   - Windows: instale o Calibre (https://calibre-ebook.com) e use o terminal dele
#   - Mac:     brew install --cask calibre
#
# Uso:  ./setup-biblioteca.sh
#
set -e

LIB_DIR="./calibre-library"
TMP_DIR="./_tmp_books"

echo ">> Criando pastas..."
mkdir -p "$LIB_DIR" "$TMP_DIR"

# Clássicos de domínio público — Project Gutenberg (formato .epub)
declare -A BOOKS=(
  ["frankenstein"]="https://www.gutenberg.org/ebooks/84.epub.images"
  ["dracula"]="https://www.gutenberg.org/ebooks/345.epub.images"
  ["sherlock"]="https://www.gutenberg.org/ebooks/1661.epub.images"
  ["pride-prejudice"]="https://www.gutenberg.org/ebooks/1342.epub.images"
  ["moby-dick"]="https://www.gutenberg.org/ebooks/2701.epub.images"
  ["alice"]="https://www.gutenberg.org/ebooks/11.epub.images"
  ["dorian-gray"]="https://www.gutenberg.org/ebooks/174.epub.images"
  ["war-worlds"]="https://www.gutenberg.org/ebooks/36.epub.images"
)

echo ">> Baixando EPUBs de exemplo do Project Gutenberg..."
for name in "${!BOOKS[@]}"; do
  url="${BOOKS[$name]}"
  echo "   - $name"
  curl -L -s -o "$TMP_DIR/$name.epub" "$url" || echo "     (falhou, pulando)"
done

echo ">> Importando para a biblioteca Calibre..."
# A primeira importacao cria o metadata.db automaticamente
for epub in "$TMP_DIR"/*.epub; do
  [ -f "$epub" ] || continue
  calibredb add "$epub" --library-path "$LIB_DIR" || true
done

echo ">> Limpando temporarios..."
rm -rf "$TMP_DIR"

echo ""
echo ">> Pronto! Biblioteca criada em $LIB_DIR"
echo ">> Agora rode:  docker compose up -d"
echo ">> Acesse:      http://localhost:8083"
echo ">> OPDS feed:   http://localhost:8083/opds"
