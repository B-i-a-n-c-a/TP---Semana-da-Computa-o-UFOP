from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from dados_banco import (
    cria_conexao_postgre, cria_tabela,
    Aluno, Palestrante, Palestra, Presenca
)
from sqlmodel import Session, select
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import io

app = FastAPI(title="API Semana da Computação DECSI")

# Permitir requisições do Flutter (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def primeira_conexao():
    cria_tabela()


# ===================== SCHEMAS (Pydantic) =====================

class AlunoCreate(BaseModel):
    nome: str
    email: str
    cpf: str
    matricula: str

class PalestranteCreate(BaseModel):
    nome: str
    formacao: str

class PalestraCreate(BaseModel):
    titulo: str
    data: str
    horario_inicio: str
    horario_fim: str
    local: str
    id_palestrante: int

class CheckinCreate(BaseModel):
    id_aluno: int
    id_palestra: int


# ===================== ROTAS - ALUNO =====================

@app.get("/")
def read_root():
    return {"status": "API Semana da Computação DECSI rodando!"}


@app.post("/alunos")
def criar_aluno(dados: AlunoCreate):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        aluno = Aluno(
            nome=dados.nome,
            email=dados.email,
            cpf=dados.cpf,
            matricula=dados.matricula,
        )
        session.add(aluno)
        session.commit()
        session.refresh(aluno)
        return aluno


@app.get("/alunos")
def listar_alunos():
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        alunos = session.exec(select(Aluno)).all()
        return alunos


@app.get("/alunos/{id_aluno}")
def buscar_aluno(id_aluno: int):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        aluno = session.get(Aluno, id_aluno)
        if not aluno:
            raise HTTPException(status_code=404, detail="Aluno não encontrado")
        return aluno


# ===================== ROTAS - PALESTRANTE =====================

@app.post("/palestrantes")
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


@app.get("/palestrantes")
def listar_palestrantes():
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestrantes = session.exec(select(Palestrante)).all()
        return palestrantes


# ===================== ROTAS - PALESTRA =====================

@app.post("/palestras")
def criar_palestra(dados: PalestraCreate):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        # Verificar se palestrante existe
        palestrante = session.get(Palestrante, dados.id_palestrante)
        if not palestrante:
            raise HTTPException(status_code=404, detail="Palestrante não encontrado")
        palestra = Palestra(
            titulo=dados.titulo,
            data=dados.data,
            horario_inicio=dados.horario_inicio,
            horario_fim=dados.horario_fim,
            local=dados.local,
            id_palestrante=dados.id_palestrante,
        )
        session.add(palestra)
        session.commit()
        session.refresh(palestra)
        return palestra


@app.get("/palestras")
def listar_palestras():
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        palestras = session.exec(select(Palestra)).all()
        return palestras


# ===================== ROTAS - CHECK-IN =====================

@app.post("/checkin")
def fazer_checkin(dados: CheckinCreate):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        # Verificar se aluno existe
        aluno = session.get(Aluno, dados.id_aluno)
        if not aluno:
            raise HTTPException(status_code=404, detail="Aluno não encontrado")
        # Verificar se palestra existe
        palestra = session.get(Palestra, dados.id_palestra)
        if not palestra:
            raise HTTPException(status_code=404, detail="Palestra não encontrada")
        # Verificar se já fez check-in
        existente = session.exec(
            select(Presenca).where(
                Presenca.id_aluno == dados.id_aluno,
                Presenca.id_palestra == dados.id_palestra,
            )
        ).first()
        if existente:
            raise HTTPException(status_code=400, detail="Check-in já realizado para esta palestra")
        presenca = Presenca(
            id_aluno=dados.id_aluno,
            id_palestra=dados.id_palestra,
            horario_checkin=datetime.now().timestamp(),
        )
        session.add(presenca)
        session.commit()
        session.refresh(presenca)
        return {"mensagem": "Check-in realizado com sucesso!", "presenca": presenca}


@app.get("/checkin/{id_aluno}")
def listar_checkins_aluno(id_aluno: int):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        presencas = session.exec(
            select(Presenca).where(Presenca.id_aluno == id_aluno)
        ).all()
        return presencas


# ===================== ROTAS - CERTIFICADO =====================

@app.get("/certificado/{id_aluno}")
def emitir_certificado(id_aluno: int):
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        aluno = session.get(Aluno, id_aluno)
        if not aluno:
            raise HTTPException(status_code=404, detail="Aluno não encontrado")

        # Buscar palestras que o aluno participou
        presencas = session.exec(
            select(Presenca).where(Presenca.id_aluno == id_aluno)
        ).all()

        if not presencas:
            raise HTTPException(
                status_code=400,
                detail="Aluno não possui presenças registradas"
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
                # Calcular horas (formato HH:MM)
                try:
                    inicio = datetime.strptime(palestra.horario_inicio, "%H:%M")
                    fim = datetime.strptime(palestra.horario_fim, "%H:%M")
                    diff = (fim - inicio).seconds / 3600
                    total_horas += diff
                except Exception:
                    pass

        return {
            "aluno": {
                "nome": aluno.nome,
                "email": aluno.email,
                "cpf": aluno.cpf,
                "matricula": aluno.matricula,
            },
            "palestras": palestras_info,
            "total_horas": round(total_horas, 1),
            "data_emissao": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "mensagem": f"Certificamos que {aluno.nome} participou da Semana da Computação DECSI com carga horária total de {round(total_horas, 1)} horas.",
        }


"""uvicorn main:app --reload --app-dir backend comando de execução"""

