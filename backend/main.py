from fastapi import FastAPI
from dados_banco import cria_conexao_postgre, cria_tabela
from sqlmodel import Field, SQLModel, create_engine

app = FastAPI()

@app.on_event("startup")
def primeira_conexao():
    cria_tabela()

@app.get("/")
def read_root():
    return {"status": "Tabela Aluno criada com sucesso!!"}




"""uvicorn main:app --reload comando de execução"""

