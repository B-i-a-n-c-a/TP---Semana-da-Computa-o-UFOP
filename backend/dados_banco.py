import os
from pathlib import Path
from typing import Optional
from dotenv import load_dotenv
from sqlmodel import Field, SQLModel, create_engine, Session

# Garante que o .env é lido a partir do diretório do backend
_env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(_env_path)

db_user = os.getenv("DB_USER", "postgres")
db_pass = os.getenv("DB_PASSWORD", "postgres")
db_host = os.getenv("DB_HOST", "localhost")
db_port = os.getenv("DB_PORT", "5432")
db_name = os.getenv("DB_NAME", "db_evento_decsi")

DATABASE_URL = f"postgresql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"


# ---- Modelos das Tabelas ----

class Usuario(SQLModel, table=True):
    """Tabela de usuários (admin e user)"""
    id_usuario: Optional[int] = Field(default=None, primary_key=True)
    nome: str = Field(nullable=False)
    email: str = Field(nullable=False, unique=True)
    senha_hash: str = Field(nullable=False)
    role: str = Field(default="user")  # "admin" ou "user"
    cpf: Optional[str] = None
    matricula: Optional[str] = None


class Palestrante(SQLModel, table=True):
    id_palestrante: Optional[int] = Field(default=None, primary_key=True)
    nome: Optional[str] = None
    formacao: Optional[str] = None


class Palestra(SQLModel, table=True):
    id_palestra: Optional[int] = Field(default=None, primary_key=True)
    titulo: Optional[str] = None
    descricao: Optional[str] = None
    data: Optional[str] = None
    horario_inicio: str = Field(nullable=False)
    horario_fim: str = Field(nullable=False)
    local: Optional[str] = None
    id_palestrante: int = Field(nullable=False, foreign_key="palestrante.id_palestrante")


class Presenca(SQLModel, table=True):
    id_presenca: Optional[int] = Field(default=None, primary_key=True)
    id_usuario: Optional[int] = Field(default=None, foreign_key="usuario.id_usuario")
    id_palestra: Optional[int] = Field(default=None, foreign_key="palestra.id_palestra")
    horario_checkin: Optional[float] = None


class Avaliacao(SQLModel, table=True):
    """Avaliação de palestra feita por um usuário"""
    id_avaliacao: Optional[int] = Field(default=None, primary_key=True)
    id_usuario: int = Field(foreign_key="usuario.id_usuario")
    id_palestra: int = Field(foreign_key="palestra.id_palestra")
    nota: int = Field(ge=1, le=5)
    comentario: Optional[str] = None


class Notificacao(SQLModel, table=True):
    """Notificações enviadas para usuários"""
    id_notificacao: Optional[int] = Field(default=None, primary_key=True)
    id_usuario: Optional[int] = Field(default=None, foreign_key="usuario.id_usuario")
    titulo: str = Field(nullable=False)
    mensagem: str = Field(nullable=False)
    lida: bool = Field(default=False)


# ---- Funções de Conexão ----

engine = None


def cria_conexao_postgre():
    """Cria e retorna a engine de conexão com o PostgreSQL."""
    global engine
    if engine is None:
        engine = create_engine(DATABASE_URL, echo=True)
    return engine


def cria_tabela():
    """Cria todas as tabelas no banco de dados."""
    eng = cria_conexao_postgre()
    SQLModel.metadata.create_all(eng)






