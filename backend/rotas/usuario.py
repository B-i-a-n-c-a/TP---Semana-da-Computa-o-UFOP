"""
Rotas de usuários normais:
- Fazer check-in em palestra
- Avaliar palestra
- Ver cronograma (palestras)
- Ver notificações
- Ver perfil / certificado próprio
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from sqlmodel import Session, select
from datetime import datetime
from dados_banco import (
    cria_conexao_postgre, Palestra, Presenca, Palestrante,
    Usuario, Avaliacao, Notificacao,
)
from auth_utils import hash_senha, verificar_senha

router = APIRouter()


# ===================== SCHEMAS =====================

class CheckinCreate(BaseModel):
    id_usuario: int
    id_palestra: int


class AvaliacaoCreate(BaseModel):
    id_usuario: int
    id_palestra: int
    nota: int  # 1 a 5
    comentario: str | None = None


class AlterarEmailRequest(BaseModel):
    id_usuario: int
    senha_atual: str
    novo_email: str


class AlterarSenhaRequest(BaseModel):
    id_usuario: int
    senha_atual: str
    nova_senha: str


class ExcluirContaRequest(BaseModel):
    id_usuario: int
    senha_atual: str


class AlterarNomeRequest(BaseModel):
    id_usuario: int
    novo_nome: str


# ===================== CRONOGRAMA (público) =====================

@router.get("/palestras")
def listar_palestras():
    """Lista todas as palestras (cronograma público)."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestras = session.exec(select(Palestra)).all()
        resultado = []
        for p in palestras:
            palestrante = session.get(Palestrante, p.id_palestrante)
            resultado.append({
                "id_palestra": p.id_palestra,
                "titulo": p.titulo,
                "descricao": p.descricao,
                "data": p.data,
                "horario_inicio": p.horario_inicio,
                "horario_fim": p.horario_fim,
                "local": p.local,
                "palestrante": palestrante.nome if palestrante else "N/A",
            })
        return resultado


# ===================== CHECK-IN =====================

@router.post("/checkin")
def fazer_checkin(dados: CheckinCreate):
    """Faz check-in do usuário em uma palestra."""
    id_usuario = dados.id_usuario
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        # Verificar se palestra existe
        palestra = session.get(Palestra, dados.id_palestra)
        if not palestra:
            raise HTTPException(status_code=404, detail="Palestra não encontrada")
        # Verificar se já fez check-in
        existente = session.exec(
            select(Presenca).where(
                Presenca.id_usuario == id_usuario,
                Presenca.id_palestra == dados.id_palestra,
            )
        ).first()
        if existente:
            raise HTTPException(status_code=400, detail="Check-in já realizado para esta palestra")

        presenca = Presenca(
            id_usuario=id_usuario,
            id_palestra=dados.id_palestra,
            horario_checkin=datetime.now().timestamp(),
        )
        session.add(presenca)
        session.commit()
        session.refresh(presenca)
        return {"mensagem": "Check-in realizado com sucesso!", "presenca_id": presenca.id_presenca}


@router.get("/checkins")
def listar_meus_checkins(id_usuario: int):
    """Lista check-ins do usuário."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        presencas = session.exec(
            select(Presenca).where(Presenca.id_usuario == id_usuario)
        ).all()
        resultado = []
        for p in presencas:
            palestra = session.get(Palestra, p.id_palestra)
            resultado.append({
                "id_presenca": p.id_presenca,
                "id_palestra": p.id_palestra,
                "titulo_palestra": palestra.titulo if palestra else "N/A",
                "horario_checkin": p.horario_checkin,
            })
        return resultado


# ===================== AVALIAÇÃO =====================

@router.post("/avaliar")
def avaliar_palestra(dados: AvaliacaoCreate):
    """Usuário avalia uma palestra que assistiu."""
    id_usuario = dados.id_usuario
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        # Verificar se palestra existe
        palestra = session.get(Palestra, dados.id_palestra)
        if not palestra:
            raise HTTPException(status_code=404, detail="Palestra não encontrada")
        # Verificar se fez check-in na palestra
        presenca = session.exec(
            select(Presenca).where(
                Presenca.id_usuario == id_usuario,
                Presenca.id_palestra == dados.id_palestra,
            )
        ).first()
        if not presenca:
            raise HTTPException(
                status_code=400,
                detail="Você precisa ter feito check-in nesta palestra para avaliar",
            )
        # Verificar se já avaliou
        avaliacao_existente = session.exec(
            select(Avaliacao).where(
                Avaliacao.id_usuario == id_usuario,
                Avaliacao.id_palestra == dados.id_palestra,
            )
        ).first()
        if avaliacao_existente:
            raise HTTPException(status_code=400, detail="Você já avaliou esta palestra")

        if dados.nota < 1 or dados.nota > 5:
            raise HTTPException(status_code=400, detail="Nota deve ser entre 1 e 5")

        avaliacao = Avaliacao(
            id_usuario=id_usuario,
            id_palestra=dados.id_palestra,
            nota=dados.nota,
            comentario=dados.comentario,
        )
        session.add(avaliacao)
        session.commit()
        session.refresh(avaliacao)
        return {"mensagem": "Avaliação registrada com sucesso!", "avaliacao_id": avaliacao.id_avaliacao}


@router.get("/avaliacoes")
def listar_minhas_avaliacoes(id_usuario: int):
    """Lista avaliações feitas pelo usuário."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        avaliacoes = session.exec(
            select(Avaliacao).where(Avaliacao.id_usuario == id_usuario)
        ).all()
        resultado = []
        for a in avaliacoes:
            palestra = session.get(Palestra, a.id_palestra)
            resultado.append({
                "id_avaliacao": a.id_avaliacao,
                "titulo_palestra": palestra.titulo if palestra else "N/A",
                "nota": a.nota,
                "comentario": a.comentario,
            })
        return resultado


@router.get("/avaliacoes-por-palestra")
def listar_avaliacoes_por_palestra():
    """Lista todas as avaliações agrupadas por palestra."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestras = session.exec(select(Palestra)).all()
        resultado = []
        for p in palestras:
            palestrante = session.get(Palestrante, p.id_palestrante)
            avaliacoes = session.exec(
                select(Avaliacao).where(Avaliacao.id_palestra == p.id_palestra)
            ).all()
            lista_avaliacoes = []
            for a in avaliacoes:
                usuario = session.get(Usuario, a.id_usuario)
                lista_avaliacoes.append({
                    "id_avaliacao": a.id_avaliacao,
                    "nome_usuario": usuario.nome if usuario else "Anônimo",
                    "nota": a.nota,
                    "comentario": a.comentario,
                })
            notas = [a.nota for a in avaliacoes]
            media = round(sum(notas) / len(notas), 1) if notas else 0
            resultado.append({
                "id_palestra": p.id_palestra,
                "titulo": p.titulo,
                "palestrante": palestrante.nome if palestrante else "N/A",
                "data": p.data,
                "media_nota": media,
                "total_avaliacoes": len(avaliacoes),
                "avaliacoes": lista_avaliacoes,
            })
        return resultado


# ===================== NOTIFICAÇÕES =====================

@router.get("/notificacoes")
def listar_notificacoes(id_usuario: int):
    """Lista notificações do usuário."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        notificacoes = session.exec(
            select(Notificacao).where(Notificacao.id_usuario == id_usuario)
        ).all()
        return [
            {
                "id_notificacao": n.id_notificacao,
                "titulo": n.titulo,
                "mensagem": n.mensagem,
                "lida": n.lida,
            }
            for n in notificacoes
        ]


@router.put("/notificacoes/{id_notificacao}/lida")
def marcar_notificacao_lida(id_notificacao: int, id_usuario: int):
    """Marca uma notificação como lida."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        notif = session.get(Notificacao, id_notificacao)
        if not notif or notif.id_usuario != id_usuario:
            raise HTTPException(status_code=404, detail="Notificação não encontrada")
        notif.lida = True
        session.add(notif)
        session.commit()
        return {"mensagem": "Notificação marcada como lida"}


# ===================== PERFIL =====================

@router.get("/perfil")
def meu_perfil(id_usuario: int):
    """Retorna dados do perfil do usuário."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        u = session.get(Usuario, id_usuario)
        if not u:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")
        return {
            "id_usuario": u.id_usuario,
            "nome": u.nome,
            "email": u.email,
            "cpf": u.cpf,
            "matricula": u.matricula,
            "role": u.role,
        }


# ===================== MEU CERTIFICADO =====================

@router.get("/meu-certificado")
def meu_certificado(id_usuario: int):
    """Retorna certificado do próprio usuário."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        u = session.get(Usuario, id_usuario)
        if not u:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")

        presencas = session.exec(
            select(Presenca).where(Presenca.id_usuario == id_usuario)
        ).all()

        if not presencas:
            raise HTTPException(
                status_code=400,
                detail="Você não possui presenças registradas",
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
                "nome": u.nome,
                "email": u.email,
                "cpf": u.cpf,
                "matricula": u.matricula,
            },
            "palestras": palestras_info,
            "total_horas": round(total_horas, 1),
            "data_emissao": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "mensagem": (
                f"Certificamos que {u.nome} participou da Semana da "
                f"Computação DECSI com carga horária total de {round(total_horas, 1)} horas."
            ),
        }


# ===================== GERENCIAR CONTA =====================

@router.put("/alterar-nome")
def alterar_nome(dados: AlterarNomeRequest):
    """Altera o nome do usuário."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        u = session.get(Usuario, dados.id_usuario)
        if not u:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")
        if not dados.novo_nome.strip():
            raise HTTPException(status_code=400, detail="O nome não pode ser vazio")
        u.nome = dados.novo_nome.strip()
        session.add(u)
        session.commit()
        return {
            "mensagem": "Nome alterado com sucesso!",
            "usuario": {
                "id_usuario": u.id_usuario,
                "nome": u.nome,
                "email": u.email,
                "role": u.role,
                "cpf": u.cpf,
                "matricula": u.matricula,
            },
        }


@router.put("/alterar-email")
def alterar_email(dados: AlterarEmailRequest):
    """Altera o email do usuário após verificar a senha atual."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        u = session.get(Usuario, dados.id_usuario)
        if not u:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")
        if not verificar_senha(dados.senha_atual, u.senha_hash):
            raise HTTPException(status_code=400, detail="Senha atual incorreta")
        # Verificar se o novo email já está em uso
        existente = session.exec(
            select(Usuario).where(Usuario.email == dados.novo_email)
        ).first()
        if existente and existente.id_usuario != dados.id_usuario:
            raise HTTPException(status_code=400, detail="Este email já está em uso")
        u.email = dados.novo_email
        session.add(u)
        session.commit()
        return {
            "mensagem": "Email alterado com sucesso!",
            "usuario": {
                "id_usuario": u.id_usuario,
                "nome": u.nome,
                "email": u.email,
                "role": u.role,
                "cpf": u.cpf,
                "matricula": u.matricula,
            },
        }


@router.put("/alterar-senha")
def alterar_senha(dados: AlterarSenhaRequest):
    """Altera a senha do usuário após verificar a senha atual."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        u = session.get(Usuario, dados.id_usuario)
        if not u:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")
        if not verificar_senha(dados.senha_atual, u.senha_hash):
            raise HTTPException(status_code=400, detail="Senha atual incorreta")
        u.senha_hash = hash_senha(dados.nova_senha)
        session.add(u)
        session.commit()
        return {"mensagem": "Senha alterada com sucesso!"}


@router.delete("/excluir-conta")
def excluir_conta(dados: ExcluirContaRequest):
    """Exclui a conta do usuário após verificar a senha atual."""
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        u = session.get(Usuario, dados.id_usuario)
        if not u:
            raise HTTPException(status_code=404, detail="Usuário não encontrado")
        if not verificar_senha(dados.senha_atual, u.senha_hash):
            raise HTTPException(status_code=400, detail="Senha atual incorreta")
        # Remover dados associados
        presencas = session.exec(
            select(Presenca).where(Presenca.id_usuario == dados.id_usuario)
        ).all()
        for p in presencas:
            session.delete(p)
        avaliacoes = session.exec(
            select(Avaliacao).where(Avaliacao.id_usuario == dados.id_usuario)
        ).all()
        for a in avaliacoes:
            session.delete(a)
        notificacoes = session.exec(
            select(Notificacao).where(Notificacao.id_usuario == dados.id_usuario)
        ).all()
        for n in notificacoes:
            session.delete(n)
        session.delete(u)
        session.commit()
        return {"mensagem": "Conta excluída com sucesso"}
