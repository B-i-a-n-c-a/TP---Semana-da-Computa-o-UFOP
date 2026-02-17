# Semana da Computação DECSI — UFOP

Sistema de gerenciamento da Semana da Computação do DECSI/UFOP, com backend em **FastAPI** (Python) e frontend em **Flutter**.

---

## Pré-requisitos

- **Python 3.10+**
- **PostgreSQL** instalado e rodando
- **Flutter SDK** (canal stable)
- **Google Chrome** (para rodar o frontend web)

---

## 1. Banco de Dados (PostgreSQL)

### 1.1 Criar o banco

```bash
sudo -u postgres psql -c "CREATE DATABASE db_evento_decsi;"
```

### 1.2 Criar as tabelas

```bash
PGPASSWORD=postgres psql -h localhost -U postgres -d db_evento_decsi -f backend/database/init.sql
```

> Isso já cria todas as tabelas e insere o **admin padrão**.

---

## 2. Backend (FastAPI)

### 2.1 Criar e ativar o ambiente virtual

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 2.2 Instalar dependências

```bash
pip install -r backend/requirements.txt
```

### 2.3 Configurar variáveis de ambiente

O arquivo `backend/.env` já vem configurado. Ajuste se necessário:

```env
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
DB_NAME=db_evento_decsi
```

### 2.4 Rodar o servidor

```bash
uvicorn main:app --reload --app-dir backend
```

O backend estará disponível em: **http://127.0.0.1:8000**

A documentação da API (Swagger) pode ser acessada em: **http://127.0.0.1:8000/docs**

---

## 3. Frontend (Flutter)

### 3.1 Instalar dependências

```bash
cd frontend
flutter pub get
```

### 3.2 Rodar no Chrome

```bash
flutter run -d chrome
```

> **Importante:** O backend precisa estar rodando antes de iniciar o frontend.

---

## Credenciais Padrão

| Tipo  | E-mail              | Senha    |
| ----- | ------------------- | -------- |
| Admin | admin@decsi.ufop.br | admin123 |

Ao fazer login como **admin**, você terá acesso ao painel administrativo com as seguintes funcionalidades:

- Cadastrar palestrantes
- Cadastrar palestras
- Emitir certificados
- Gerenciar administradores
- Enviar notificações

Ao fazer login como **usuário normal** (registrado pela tela de cadastro), você terá acesso a:

- Cronograma de palestras
- Check-in em palestras
- Avaliar palestras
- Ver avaliações por palestra
- Meu certificado
- Notificações

---

## Estrutura do Projeto

```
├── backend/
│   ├── main.py                 # Entrada da API FastAPI
│   ├── dados_banco.py          # Modelos e conexão com PostgreSQL
│   ├── auth_utils.py           # Utilitários de autenticação (hash de senha)
│   ├── requirements.txt        # Dependências Python
│   ├── .env                    # Variáveis de ambiente do banco
│   ├── database/
│   │   └── init.sql            # Script de criação das tabelas
│   └── rotas/
│       ├── auth.py             # Rotas de login e registro
│       ├── admin.py            # Rotas administrativas
│       └── usuario.py          # Rotas de usuários normais
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart           # Entrada do app Flutter
│   │   ├── services/
│   │   │   └── api_service.dart # Comunicação com a API
│   │   └── pages/
│   │       ├── login_page.dart
│   │       ├── registro_page.dart
│   │       ├── admin_home_page.dart
│   │       ├── usuario_home_page.dart
│   │       ├── cadastro_palestrante_page.dart
│   │       ├── cadastro_palestra_page.dart
│   │       ├── certificado_page.dart
│   │       ├── gerenciar_admins_page.dart
│   │       ├── enviar_notificacao_page.dart
│   │       ├── cronograma_page.dart
│   │       ├── checkin_page.dart
│   │       ├── avaliacao_page.dart
│   │       ├── ver_avaliacoes_page.dart
│   │       ├── notificacoes_page.dart
│   │       └── meu_certificado_page.dart
│   └── pubspec.yaml
│
├── README.md
└── README2.md
```

---

## Rotas da API

### Autenticação (`/auth`)

| Método | Rota             | Descrição              |
| ------ | ---------------- | ---------------------- |
| POST   | `/auth/registro` | Registrar novo usuário |
| POST   | `/auth/login`    | Fazer login            |

### Administração (`/admin`)

| Método | Rota                              | Descrição              |
| ------ | --------------------------------- | ---------------------- |
| POST   | `/admin/palestrantes`             | Cadastrar palestrante  |
| GET    | `/admin/palestrantes`             | Listar palestrantes    |
| DELETE | `/admin/palestrantes/{id}`        | Remover palestrante    |
| POST   | `/admin/palestras`                | Cadastrar palestra     |
| DELETE | `/admin/palestras/{id}`           | Remover palestra       |
| GET    | `/admin/certificado/{id_usuario}` | Emitir certificado     |
| POST   | `/admin/administradores`          | Criar administrador    |
| GET    | `/admin/administradores`          | Listar administradores |
| DELETE | `/admin/administradores/{id}`     | Remover administrador  |
| GET    | `/admin/usuarios`                 | Listar usuários        |
| POST   | `/admin/notificacoes`             | Enviar notificação     |

### Usuário (`/usuario`)

| Método | Rota                                       | Descrição                         |
| ------ | ------------------------------------------ | --------------------------------- |
| GET    | `/usuario/palestras`                       | Cronograma (público)              |
| POST   | `/usuario/checkin`                         | Fazer check-in                    |
| GET    | `/usuario/checkins?id_usuario={id}`        | Listar meus check-ins             |
| POST   | `/usuario/avaliar`                         | Avaliar palestra                  |
| GET    | `/usuario/avaliacoes?id_usuario={id}`      | Minhas avaliações                 |
| GET    | `/usuario/avaliacoes-por-palestra`         | Avaliações agrupadas por palestra |
| GET    | `/usuario/notificacoes?id_usuario={id}`    | Minhas notificações               |
| PUT    | `/usuario/notificacoes/{id}/lida`          | Marcar notificação como lida      |
| GET    | `/usuario/perfil?id_usuario={id}`          | Meu perfil                        |
| GET    | `/usuario/meu-certificado?id_usuario={id}` | Meu certificado                   |
