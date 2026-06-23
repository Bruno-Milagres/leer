# leer

Leitor de ebooks open source para Calibre-Web

## Setup

### 1. Configurar ambiente

```bash
cp .env.example .env
# Edite .env com o host/porta do seu Calibre-Web
```

### 2. Subir o Calibre-Web local (opcional)

```bash
cd compose
docker compose up -d
```

Veja [`compose/README.md`](compose/README.md) para detalhes.

### 3. Rodar o app

```bash
flutter run --dart-define-from-file=.env
```

O flag `--dart-define-from-file` injeta as variáveis do `.env` como compile-time constants. Sem ele, o app usa fallbacks para emulador (`10.0.2.2:8083`).
