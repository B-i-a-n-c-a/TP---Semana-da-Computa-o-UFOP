import os
from typing import Optional
from dotenv import load_dotenv
from sqlmodel import Field, SQLModel, create_engine, Session


load_dotenv()

db_user = os.getenv("DB_USER")
db_pass = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")

DATABASE_URL = f"postgresql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"


# ---- Modelos das Tabelas ----

class Aluno(SQLModel, table=True):
    id_aluno: Optional[int] = Field(default=None, primary_key=True)
    nome: Optional[str] = None
    email: Optional[str] = None
    cpf: Optional[str] = None
    matricula: Optional[str] = None


class Palestrante(SQLModel, table=True):
    id_palestrante: Optional[int] = Field(default=None, primary_key=True)
    nome: Optional[str] = None
    formacao: Optional[str] = None


class Palestra(SQLModel, table=True):
    id_palestra: Optional[int] = Field(default=None, primary_key=True)
    titulo: Optional[str] = None
    horario_inicio: str = Field(nullable=False)
    horario_fim: str = Field(nullable=False)
    local: Optional[str] = None
    id_palestrante: int = Field(nullable=False, foreign_key="palestrante.id_palestrante")


class Presenca(SQLModel, table=True):
    id_presenca: Optional[int] = Field(default=None, primary_key=True)
    id_aluno: Optional[int] = Field(default=None, foreign_key="aluno.id_aluno")
    id_palestra: Optional[int] = Field(default=None, foreign_key="palestra.id_palestra")
    horario_checkin: Optional[float] = None


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






