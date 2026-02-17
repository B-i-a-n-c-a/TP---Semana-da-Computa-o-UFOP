"""
Utilitários de autenticação JWT para o sistema.
"""
import os
import hashlib
import jwt
import datetime
from pathlib import Path
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv

_env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(_env_path)

SECRET_KEY = os.getenv("SECRET_KEY", "semana-computacao-decsi-secret-2026")
ALGORITHM = "HS256"
TOKEN_EXPIRA_HORAS = 24

security = HTTPBearer()


def hash_senha(senha: str) -> str:
    """Gera hash SHA-256 da senha."""
    return hashlib.sha256(senha.encode()).hexdigest()


def verificar_senha(senha: str, senha_hash: str) -> bool:
    """Verifica se a senha corresponde ao hash."""
    return hash_senha(senha) == senha_hash


def criar_token(id_usuario: int, role: str, nome: str) -> str:
    """Cria token JWT com id, role e nome do usuário."""
    payload = {
        "sub": id_usuario,
        "role": role,
        "nome": nome,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=TOKEN_EXPIRA_HORAS),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def decodificar_token(token: str) -> dict:
    """Decodifica e valida o token JWT."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token inválido")


def get_usuario_atual(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Dependency que retorna o payload do usuário autenticado."""
    return decodificar_token(credentials.credentials)


def exigir_admin(usuario: dict = Depends(get_usuario_atual)) -> dict:
    """Dependency que exige que o usuário seja admin."""
    if usuario.get("role") != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Acesso restrito a administradores",
        )
    return usuario


def exigir_usuario(usuario: dict = Depends(get_usuario_atual)) -> dict:
    """Dependency que exige qualquer usuário autenticado."""
    return usuario
