from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dados_banco import cria_conexao_postgre, cria_tabela, Usuario
from auth_utils import hash_senha
from sqlmodel import Session, select
from rotas.auth import router as auth_router
from rotas.admin import router as admin_router
from rotas.usuario import router as usuario_router

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
    # Criar admin padrão se não existir
    engine = cria_conexao_postgre()
    with Session(engine) as session:
        admin = session.exec(
            select(Usuario).where(Usuario.email == "admin@decsi.ufop.br")
        ).first()
        if not admin:
            admin = Usuario(
                nome="Administrador",
                email="admin@decsi.ufop.br",
                senha_hash=hash_senha("admin123"),
                role="admin",
            )
            session.add(admin)
            session.commit()
            print(">>> Admin padrão criado: admin@decsi.ufop.br / admin123")


# ---- Rotas ----

# Autenticação (login, registro) — sem prefixo de proteção
app.include_router(auth_router, prefix="/auth", tags=["Autenticação"])

# Rotas exclusivas de administradores
app.include_router(admin_router, prefix="/admin", tags=["Administração"])

# Rotas de usuários normais
app.include_router(usuario_router, prefix="/usuario", tags=["Usuário"])


@app.get("/")
def read_root():
    return {"status": "API Semana da Computação DECSI rodando!"}


"""uvicorn main:app --reload --app-dir backend comando de execução"""

