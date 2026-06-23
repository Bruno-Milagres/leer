# Leer — Ambiente de desenvolvimento local (Docker)

Sobe um **Calibre-Web** na sua máquina pra desenvolver o app Leer sem depender de Oracle, PC velho ou qualquer servidor externo. O app Flutter aponta pra `http://localhost:8083` (ou pro IP da sua máquina, quando testar no celular).

---

## Pré-requisitos

- **Docker** + **Docker Compose** instalados
  - Windows/Mac: Docker Desktop
  - Linux: `docker` + `docker compose`
- **`.env`** na raiz do projeto (veja seção abaixo)

---

## Configuração de ambiente (.env)

O Docker Compose lê o `.env` da raiz do projeto (`../.env` relativo a esta pasta). Ele define porta, timezone e credenciais.

```bash
# Na raiz do projeto (leer/), copie o exemplo:
cp .env.example .env

# Edite conforme seu ambiente:
# - Dev local:         CALIBRE_WEB_HOST=localhost
# - Emulador Android:  CALIBRE_WEB_HOST=10.0.2.2
# - Celular na rede:   CALIBRE_WEB_HOST=192.168.x.x
# - Servidor Oracle:   CALIBRE_WEB_HOST=<ip-do-oracle>
```

Para trocar de ambiente, basta editar o `.env` — nenhum arquivo de código precisa mudar.

---

## Passo 1 — Criar a biblioteca de exemplo

O Calibre-Web precisa de uma biblioteca Calibre existente (um `metadata.db`). Você tem **duas opções**:

### Opção A — Script automático (precisa do Calibre desktop instalado)

O `calibredb` vem junto com o Calibre desktop. Com ele instalado:

```bash
chmod +x setup-biblioteca.sh
./setup-biblioteca.sh
```

Isso baixa 8 clássicos de domínio público do Project Gutenberg e cria a biblioteca em `./calibre-library`.

### Opção B — Sem instalar nada (gerar a lib pelo próprio container)

Se não quiser instalar o Calibre desktop, o próprio container consegue criar a biblioteca:

```bash
# 1. Sobe o container primeiro (vai reclamar que não achou biblioteca, tudo bem)
docker compose up -d

# 2. Baixa um EPUB de exemplo pra dentro da pasta da biblioteca
mkdir -p calibre-library
curl -L -o calibre-library/frankenstein.epub https://www.gutenberg.org/ebooks/84.epub.images

# 3. Usa o calibredb de dentro do container pra criar a biblioteca
docker exec -it leer-calibre-web \
  calibredb add /books/frankenstein.epub --library-path /books

# 4. Reinicia
docker compose restart
```

### Opção C — Você já tem uma biblioteca Calibre

Se você já usa Calibre no PC, é só copiar sua pasta de biblioteca (a que tem o `metadata.db`) pra dentro de `./calibre-library` e subir o container.

---

## Passo 2 — Subir o Calibre-Web

```bash
# De dentro da pasta compose/:
docker compose up -d
```

O Docker Compose carrega automaticamente o `../.env` (configurado via `env_file` no `docker-compose.yml`). Aguarde uns 30s na primeira vez (ele baixa o mod de conversão).

---

## Passo 3 — Configuração inicial do Calibre-Web

1. Acesse **http://localhost:8083**
2. Login padrão: usuário `admin` / senha `admin123`
3. Na primeira tela, ele pede o **caminho da biblioteca**: digite `/books`
4. **Troque a senha** do admin nas configurações
5. Habilite o OPDS: já vem ligado por padrão

### Endpoints que o app vai usar

| O quê | URL |
|---|---|
| Interface web | http://localhost:8083 |
| **OPDS feed** (o que o Leer consome) | http://localhost:8083/opds |
| Login OPDS | mesmas credenciais do Calibre-Web |

---

## Passo 4 — Apontar o app Leer pra cá

### Testando no emulador Android
- O emulador não enxerga `localhost` da sua máquina diretamente.
- Use o IP especial **`10.0.2.2`** → `http://10.0.2.2:8083/opds`

### Testando no celular físico (mesma rede Wi-Fi)
- Descubra o IP da sua máquina:
  - Windows: `ipconfig` (procure IPv4, algo como `192.168.x.x`)
  - Linux/Mac: `ip addr` ou `ifconfig`
- Use `http://192.168.x.x:8083/opds`

---

## Comandos úteis

```bash
docker compose up -d        # sobe em background
docker compose logs -f      # acompanha os logs
docker compose restart      # reinicia
docker compose down         # para e remove o container (dados persistem em ./config e ./calibre-library)
```

---

## Adicionar mais livros

- Pela web: http://localhost:8083 → botão de upload (precisa habilitar "Enable Uploads" nas Admin settings)
- Por linha de comando:
  ```bash
  docker exec -it leer-calibre-web calibredb add /books/seu-livro.epub --library-path /books
  ```
- Testar conversão PDF→EPUB: faça upload de um PDF pela web e use a opção "Convert" — valida o fluxo que o Leer espera do Calibre.

---

## Estrutura

```
leer-dev/
├── docker-compose.yml      # o serviço Calibre-Web
├── setup-biblioteca.sh     # popula a lib com EPUBs de exemplo
├── README.md               # este arquivo
├── config/                 # config persistente do Calibre-Web (criado no 1º run)
└── calibre-library/        # a biblioteca Calibre (metadata.db + livros)
```

---

*Ambiente de dev do Leer · não usar em produção (senha fraca, sem HTTPS)*
