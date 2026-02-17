-- =============================================
-- Banco de dados: Semana da Computação DECSI
-- Com separação Admin / Usuário
-- =============================================

-- Tabela de Usuários (admin e user)
CREATE TABLE IF NOT EXISTS usuario (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    cpf VARCHAR(20),
    matricula VARCHAR(50)
);

-- Tabela de Palestrantes
CREATE TABLE IF NOT EXISTS palestrante (
    id_palestrante SERIAL PRIMARY KEY,
    nome TEXT,
    formacao TEXT
);

-- Tabela de Palestras
CREATE TABLE IF NOT EXISTS palestra (
    id_palestra SERIAL PRIMARY KEY,
    titulo TEXT,
    descricao TEXT,
    data TEXT,
    horario_inicio VARCHAR(10) NOT NULL,
    horario_fim VARCHAR(10) NOT NULL,
    local TEXT,
    id_palestrante INT NOT NULL,
    CONSTRAINT fk_palestrante
        FOREIGN KEY (id_palestrante)
        REFERENCES palestrante (id_palestrante)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

-- Tabela de Presenças (check-in)
CREATE TABLE IF NOT EXISTS presenca (
    id_presenca SERIAL PRIMARY KEY,
    id_usuario INT,
    id_palestra INT,
    horario_checkin FLOAT,
    CONSTRAINT fk_usuario_presenca
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_palestra_presenca
        FOREIGN KEY (id_palestra)
        REFERENCES palestra (id_palestra)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

-- Tabela de Avaliações
CREATE TABLE IF NOT EXISTS avaliacao (
    id_avaliacao SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_palestra INT NOT NULL,
    nota INT CHECK (nota >= 1 AND nota <= 5),
    comentario TEXT,
    CONSTRAINT fk_usuario_avaliacao
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_palestra_avaliacao
        FOREIGN KEY (id_palestra)
        REFERENCES palestra (id_palestra)
        ON DELETE CASCADE,
    UNIQUE (id_usuario, id_palestra)
);

-- Tabela de Notificações
CREATE TABLE IF NOT EXISTS notificacao (
    id_notificacao SERIAL PRIMARY KEY,
    id_usuario INT,
    titulo VARCHAR(255) NOT NULL,
    mensagem TEXT NOT NULL,
    lida BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_usuario_notificacao
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
);

-- Inserir admin padrão (senha: admin123 → SHA-256)
INSERT INTO usuario (nome, email, senha_hash, role)
VALUES ('Administrador', 'admin@decsi.ufop.br',
        '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin')
ON CONFLICT (email) DO NOTHING;
