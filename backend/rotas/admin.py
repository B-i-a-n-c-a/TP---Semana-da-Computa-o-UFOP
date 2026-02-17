"""
Rotas exclusivas de administradores:
- Cadastrar palestrantes
- Cadastrar palestras
- Emitir certificados
- Gerenciar administradores
- Enviar notificações
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlmodel import Session, select
from datetime import datetime
from dados_banco import (
    cria_conexao_postgre, Palestrante, Palestra, Presenca,
    Usuario, Notificacao,
)
from auth_utils import hash_senha

router = APIRouter()


# ===================== SCHEMAS =====================

class PalestranteCreate(BaseModel):
    nome: str
    formacao: str


class PalestraCreate(BaseModel):
    titulo: str
    descricao: str | None = None
    data: str
    horario_inicio: str
    horario_fim: str
    local: str
    id_palestrante: int


class AdminCreate(BaseModel):
    nome: str
    email: str
    senha: str


class NotificacaoCreate(BaseModel):
    titulo: str
    mensagem: str
    id_usuario: int | None = None  # None = enviar para todos


# ===================== PALESTRANTE (ADMIN) =====================

@router.post("/palestrantes")
def criar_palestrante(dados: PalestranteCreate):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestrante = Palestrante(
            nome=dados.nome,
            formacao=dados.formacao,
        )
        session.add(palestrante)
        session.commit()
        session.refresh(palestrante)
        return palestrante


@router.get("/palestrantes")
def listar_palestrantes():
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        return session.exec(select(Palestrante)).all()


@router.delete("/palestrantes/{id_palestrante}")
def deletar_palestrante(id_palestrante: int):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestrante = session.get(Palestrante, id_palestrante)
        if not palestrante:
            raise HTTPException(status_code=404, detail="Palestrante não encontrado")
        session.delete(palestrante)
        session.commit()
        return {"mensagem": "Palestrante removido com sucesso"}


# ===================== PALESTRA (ADMIN) =====================

@router.post("/palestras")
def criar_palestra(dados: PalestraCreate):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestrante = session.get(Palestrante, dados.id_palestrante)
        if not palestrante:
            raise HTTPException(status_code=404, detail="Palestrante não encontrado")
        palestra = Palestra(
            titulo=dados.titulo,
            descricao=dados.descricao,
            data=dados.data,
            horario_inicio=dados.horario_inicio,
            horario_fim=dados.horario_fim,
            local=dados.local,
            id_palestrante=dados.id_palestrante,
        )
        session.add(palestra)
        session.commit()
        session.refresh(palestra)

        # Enviar notificação para todos os usuários sobre nova palestra
        usuarios = session.exec(select(Usuario).where(Usuario.role == "user")).all()
        for u in usuarios:
            notif = Notificacao(
                id_usuario=u.id_usuario,
                titulo="Nova palestra cadastrada!",
                mensagem=f'"{dados.titulo}" em {dados.data} às {dados.horario_inicio} - {dados.local}',
            )
            session.add(notif)
        session.commit()

        return palestra


@router.delete("/palestras/{id_palestra}")
def deletar_palestra(id_palestra: int):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestra = session.get(Palestra, id_palestra)
        if not palestra:
            raise HTTPException(status_code=404, detail="Palestra não encontrada")
        session.delete(palestra)
        session.commit()
        return {"mensagem": "Palestra removida com sucesso"}


# ===================== CERTIFICADO (ADMIN) =====================

@router.get("/certificado/{id_usuario}")
def emitir_certificado(id_usuario: int):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        usuario = session.get(Usuario, id_usuario)
        if not usuario:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")

        presencas = session.exec(
            select(Presenca).where(Presenca.id_usuario == id_usuario)
        ).all()

        if not presencas:
            raise HTTPException(
                status_code=400,
                detail="Usuário não possui presenças registradas",
            )

        palestras_info = []
        total_horas = 0.0
        for p in presencas:
            palestra = session.get(Palestra, p.id_palestra)
            if palestra:
                palestrante = session.get(Palestrante, palestra.id_palestrante)
                palestras_info.append({
                    "titulo": palestra.titulo,
                    "local": palestra.local,
                    "horario_inicio": palestra.horario_inicio,
                    "horario_fim": palestra.horario_fim,
                    "palestrante": palestrante.nome if palestrante else "N/A",
                })
                try:
                    inicio = datetime.strptime(palestra.horario_inicio, "%H:%M")
                    fim = datetime.strptime(palestra.horario_fim, "%H:%M")
                    diff = (fim - inicio).seconds / 3600
                    total_horas += diff
                except Exception:
                    pass

        return {
            "usuario": {
                "nome": usuario.nome,
                "email": usuario.email,
                "cpf": usuario.cpf,
                "matricula": usuario.matricula,
            },
            "palestras": palestras_info,
            "total_horas": round(total_horas, 1),
            "data_emissao": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "mensagem": (
                f"Certificamos que {usuario.nome} participou da Semana da "
                f"Computação DECSI com carga horária total de {round(total_horas, 1)} horas."
            ),
        }


# ===================== GERENCIAR ADMINS =====================

@router.post("/administradores")
def criar_admin(dados: AdminCreate):
    """Cria um novo administrador."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        existente = session.exec(
            select(Usuario).where(Usuario.email == dados.email)
        ).first()
        if existente:
            raise HTTPException(status_code=400, detail="E-mail já cadastrado")

        admin = Usuario(
            nome=dados.nome,
            email=dados.email,
            senha_hash=hash_senha(dados.senha),
            role="admin",
        )
        session.add(admin)
        session.commit()
        session.refresh(admin)
        return {
            "mensagem": "Administrador criado com sucesso",
            "admin": {
                "id_usuario": admin.id_usuario,
                "nome": admin.nome,
                "email": admin.email,
                "role": admin.role,
            },
        }


@router.get("/administradores")
def listar_admins():
    """Lista todos os administradores."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        admins = session.exec(
            select(Usuario).where(Usuario.role == "admin")
        ).all()
        return [
            {
                "id_usuario": a.id_usuario,
                "nome": a.nome,
                "email": a.email,
                "role": a.role,
            }
            for a in admins
        ]


@router.delete("/administradores/{id_usuario}")
def remover_admin(id_usuario: int):
    """Remove um administrador."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        admin = session.get(Usuario, id_usuario)
        if not admin or admin.role != "admin":
            raise HTTPException(status_code=404, detail="Administrador não encontrado")
        session.delete(admin)
        session.commit()
        return {"mensagem": "Administrador removido com sucesso"}


# ===================== LISTAR USUÁRIOS (ADMIN) =====================

@router.get("/usuarios")
def listar_usuarios():
    """Lista todos os usuários normais."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        usuarios = session.exec(
            select(Usuario).where(Usuario.role == "user")
        ).all()
        return [
            {
                "id_usuario": u.id_usuario,
                "nome": u.nome,
                "email": u.email,
                "matricula": u.matricula,
            }
            for u in usuarios
        ]


# ===================== NOTIFICAÇÕES (ADMIN) =====================

@router.post("/notificacoes")
def enviar_notificacao(dados: NotificacaoCreate):
    """Envia notificação para um usuário ou para todos."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        if dados.id_usuario:
            # Enviar para um usuário específico
            usuario = session.get(Usuario, dados.id_usuario)
            if not usuario:
                raise HTTPException(status_code=404, detail="Usuário não encontrado")
            notif = Notificacao(
                id_usuario=dados.id_usuario,
                titulo=dados.titulo,
                mensagem=dados.mensagem,
            )
            session.add(notif)
        else:
            # Enviar para todos os usuários
            usuarios = session.exec(
                select(Usuario).where(Usuario.role == "user")
            ).all()
            for u in usuarios:
                notif = Notificacao(
                    id_usuario=u.id_usuario,
                    titulo=dados.titulo,
                    mensagem=dados.mensagem,
                )
                session.add(notif)
        session.commit()
        return {"mensagem": "Notificação enviada com sucesso"}
