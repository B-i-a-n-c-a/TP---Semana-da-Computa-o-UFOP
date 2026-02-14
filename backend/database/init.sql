CREATE TABLE Aluno (
    id_aluno INT PRIMARY KEY,
    nome TEXT,
    email TEXT,
    cpf TEXT,
    matricula TEXT,
    UNIQUE (cpf, matricula)
);

-- Tabela de Palestrantes
CREATE TABLE Palestrante (
    id_palestrante SERIAL PRIMARY KEY,
    nome TEXT,
    formacao TEXT
);

-- Tabela de Palestras
CREATE TABLE Palestra (
    id_palestra SERIAL PRIMARY KEY,
    titulo TEXT,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    local TEXT,
    id_palestrante INT NOT NULL,
    CONSTRAINT fk_palestrante 
        FOREIGN KEY (id_palestrante) 
        REFERENCES Palestrante (id_palestrante) 
        ON DELETE NO ACTION 
        ON UPDATE NO ACTION
);

-- Tabela de Presenças (Relacionamento Aluno x Palestra)
CREATE TABLE Presenca (
    id_presenca SERIAL PRIMARY KEY,
    id_aluno INT,
    id_palestra INT,
    horario_checkin FLOAT,
    CONSTRAINT fk_aluno 
        FOREIGN KEY (id_aluno) 
        REFERENCES Aluno (id_aluno) 
        ON DELETE NO ACTION 
        ON UPDATE NO ACTION,
    CONSTRAINT fk_palestra 
        FOREIGN KEY (id_palestra) 
        REFERENCES Palestra (id_palestra) 
        ON DELETE NO ACTION 
        ON UPDATE NO ACTION
);
