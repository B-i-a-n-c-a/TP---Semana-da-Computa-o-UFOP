"""
Rotas de autenticação: registro e login.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlmodel import Session, select
from dados_banco import cria_conexao_postgre, Usuario
from auth_utils import hash_senha, verificar_senha

router = APIRouter()


# ---- Schemas ----

class RegistroRequest(BaseModel):
    nome: str
    email: str
    senha: str
    cpf: str | None = None
    matricula: str | None = None


class LoginRequest(BaseModel):
    email: str
    senha: str


# ---- Rotas ----

@router.post("/registro")
def registrar_usuario(dados: RegistroRequest):
    """Registra um novo usuário (role=user por padrão)."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        # Verificar se e-mail já existe
        existente = session.exec(
            select(Usuario).where(Usuario.email == dados.email)
        ).first()
        if existente:
            raise HTTPException(status_code=400, detail="E-mail já cadastrado")

        usuario = Usuario(
            nome=dados.nome,
            email=dados.email,
            senha_hash=hash_senha(dados.senha),
            role="user",
            cpf=dados.cpf,
            matricula=dados.matricula,
        )
        session.add(usuario)
        session.commit()
        session.refresh(usuario)

        return {
            "mensagem": "Usuário registrado com sucesso!",
            "usuario": {
                "id_usuario": usuario.id_usuario,
                "nome": usuario.nome,
                "email": usuario.email,
                "role": usuario.role,
            },
        }


@router.post("/login")
def login(dados: LoginRequest):
    """Realiza login."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        usuario = session.exec(
            select(Usuario).where(Usuario.email == dados.email)
        ).first()
        if not usuario:
            raise HTTPException(status_code=401, detail="E-mail ou senha inválidos")
        if not verificar_senha(dados.senha, usuario.senha_hash):
            raise HTTPException(status_code=401, detail="E-mail ou senha inválidos")

        return {
            "mensagem": "Login realizado com sucesso!",
            "usuario": {
                "id_usuario": usuario.id_usuario,
                "nome": usuario.nome,
                "email": usuario.email,
                "role": usuario.role,
            },
        }
