-- =========================================================================
-- V1 (SQL Server / Azure SQL): Schema inicial do VitalPet (clinicas, veterinarios, tutores, pets,
-- consultas, acompanhamentos, alertas e usuarios de acesso ao sistema)
-- =========================================================================

CREATE TABLE clinicas (
    id                BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(120) NOT NULL,
    endereco          VARCHAR(180) NOT NULL,
    cidade            VARCHAR(80)  NOT NULL,
    estado            VARCHAR(2)   NOT NULL,
    cep               VARCHAR(9)   NOT NULL,
    telefone          VARCHAR(20)  NOT NULL,
    email             VARCHAR(120) NOT NULL,
    cnpj              VARCHAR(14)  NOT NULL,
    ativa             BIT          NOT NULL DEFAULT 1,
    data_cadastro     DATETIME2(6)    NOT NULL,
    data_atualizacao  DATETIME2(6)    NOT NULL,
    CONSTRAINT uk_clinica_cnpj UNIQUE (cnpj)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Unidades veterinarias que utilizam o sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'clinicas';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CNPJ sem pontuacao, 14 digitos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'clinicas', @level2type = N'COLUMN', @level2name = N'cnpj';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Indica se a clinica esta ativa no sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'clinicas', @level2type = N'COLUMN', @level2name = N'ativa';

CREATE TABLE veterinarios (
    id                BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(120) NOT NULL,
    email             VARCHAR(120) NOT NULL,
    telefone          VARCHAR(20)  NOT NULL,
    crmv              VARCHAR(12)  NOT NULL,
    especialidade     VARCHAR(80)  NOT NULL,
    ativo             BIT          NOT NULL DEFAULT 1,
    data_cadastro     DATETIME2(6)    NOT NULL,
    data_atualizacao  DATETIME2(6)    NOT NULL,
    clinica_id        BIGINT       NOT NULL,
    CONSTRAINT uk_veterinario_crmv UNIQUE (crmv),
    CONSTRAINT uk_veterinario_email UNIQUE (email),
    CONSTRAINT fk_veterinario_clinica FOREIGN KEY (clinica_id) REFERENCES clinicas (id)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Profissionais responsaveis pelos atendimentos, vinculados a uma clinica', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'veterinarios';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Registro profissional no formato UF-0000', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'veterinarios', @level2type = N'COLUMN', @level2name = N'crmv';

CREATE TABLE tutores (
    id                BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(120) NOT NULL,
    email             VARCHAR(120) NOT NULL,
    telefone          VARCHAR(20)  NOT NULL,
    cpf               VARCHAR(11)  NOT NULL,
    endereco          VARCHAR(180),
    cidade            VARCHAR(80),
    estado            VARCHAR(2),
    cep               VARCHAR(9),
    ativo             BIT          NOT NULL DEFAULT 1,
    data_cadastro     DATETIME2(6)    NOT NULL,
    data_atualizacao  DATETIME2(6)    NOT NULL,
    CONSTRAINT uk_tutor_cpf UNIQUE (cpf),
    CONSTRAINT uk_tutor_email UNIQUE (email)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Responsaveis pelos pets acompanhados no sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tutores';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'CPF sem pontuacao, 11 digitos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tutores', @level2type = N'COLUMN', @level2name = N'cpf';

CREATE TABLE pets (
    id                BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(80)   NOT NULL,
    especie           VARCHAR(50)   NOT NULL,
    raca              VARCHAR(80),
    data_nascimento   DATE,
    sexo              VARCHAR(20)   NOT NULL,
    peso              NUMERIC(6,2)  NOT NULL,
    observacoes       VARCHAR(500),
    ativo             BIT           NOT NULL DEFAULT 1,
    data_cadastro     DATETIME2(6)     NOT NULL,
    data_atualizacao  DATETIME2(6)     NOT NULL,
    tutor_id          BIGINT        NOT NULL,
    CONSTRAINT fk_pet_tutor FOREIGN KEY (tutor_id) REFERENCES tutores (id)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Animais acompanhados pelo sistema, vinculados a um tutor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pets';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Peso do pet em quilogramas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'pets', @level2type = N'COLUMN', @level2name = N'peso';

CREATE TABLE consultas (
    id                BIGINT        IDENTITY(1,1) PRIMARY KEY,
    data_hora         DATETIME2(6)     NOT NULL,
    tipo              VARCHAR(60)   NOT NULL,
    sintomas          VARCHAR(1000),
    diagnostico       VARCHAR(1000),
    tratamento        VARCHAR(1000),
    status            VARCHAR(30)   NOT NULL DEFAULT 'AGENDADA',
    valor             NUMERIC(10,2) NOT NULL,
    data_cadastro     DATETIME2(6)     NOT NULL,
    data_atualizacao  DATETIME2(6)     NOT NULL,
    pet_id            BIGINT        NOT NULL,
    veterinario_id    BIGINT        NOT NULL,
    CONSTRAINT fk_consulta_pet FOREIGN KEY (pet_id) REFERENCES pets (id),
    CONSTRAINT fk_consulta_veterinario FOREIGN KEY (veterinario_id) REFERENCES veterinarios (id)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Atendimentos realizados a um pet por um veterinario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'consultas';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'AGENDADA, CONCLUIDA ou CANCELADA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'consultas', @level2type = N'COLUMN', @level2name = N'status';

CREATE TABLE acompanhamentos (
    id                BIGINT       IDENTITY(1,1) PRIMARY KEY,
    status            VARCHAR(30)  NOT NULL DEFAULT 'ATIVO',
    data_inicio       DATETIME2(6)    NOT NULL,
    data_fim          DATETIME2(6),
    descricao         VARCHAR(1000) NOT NULL,
    data_cadastro     DATETIME2(6)    NOT NULL,
    data_atualizacao  DATETIME2(6)    NOT NULL,
    consulta_id       BIGINT       NOT NULL,
    CONSTRAINT uk_acompanhamento_consulta UNIQUE (consulta_id),
    CONSTRAINT fk_acompanhamento_consulta FOREIGN KEY (consulta_id) REFERENCES consultas (id)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Continuidade clinica criada apos a finalizacao de uma consulta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'acompanhamentos';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'ATIVO, CONCLUIDO ou CANCELADO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'acompanhamentos', @level2type = N'COLUMN', @level2name = N'status';

CREATE TABLE alertas (
    id                BIGINT       IDENTITY(1,1) PRIMARY KEY,
    tipo              VARCHAR(60)  NOT NULL,
    titulo            VARCHAR(120) NOT NULL,
    descricao         VARCHAR(1000) NOT NULL,
    prioridade        VARCHAR(20)  NOT NULL,
    status            VARCHAR(30)  NOT NULL DEFAULT 'PENDENTE',
    data_alerta       DATETIME2(6)    NOT NULL,
    data_resolucao    DATETIME2(6),
    data_cadastro     DATETIME2(6)    NOT NULL,
    data_atualizacao  DATETIME2(6)    NOT NULL,
    pet_id            BIGINT       NOT NULL,
    acompanhamento_id BIGINT,
    CONSTRAINT fk_alerta_pet FOREIGN KEY (pet_id) REFERENCES pets (id),
    CONSTRAINT fk_alerta_acompanhamento FOREIGN KEY (acompanhamento_id) REFERENCES acompanhamentos (id)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Retornos, vacinas e demais acoes de acompanhamento a serem tratadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'alertas';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'BAIXA, MEDIA ou ALTA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'alertas', @level2type = N'COLUMN', @level2name = N'prioridade';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'PENDENTE, RESOLVIDO ou CANCELADO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'alertas', @level2type = N'COLUMN', @level2name = N'status';

CREATE TABLE usuarios (
    id                BIGINT       IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(120) NOT NULL,
    email             VARCHAR(120) NOT NULL,
    senha             VARCHAR(100) NOT NULL,
    role              VARCHAR(20)  NOT NULL,
    ativo             BIT          NOT NULL DEFAULT 1,
    data_cadastro     DATETIME2(6)    NOT NULL,
    data_atualizacao  DATETIME2(6)    NOT NULL,
    veterinario_id    BIGINT,
    CONSTRAINT uk_usuario_email UNIQUE (email),
    CONSTRAINT fk_usuario_veterinario FOREIGN KEY (veterinario_id) REFERENCES veterinarios (id)
);
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Contas de acesso a aplicacao web (Spring Security)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usuarios';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Hash BCrypt da senha', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usuarios', @level2type = N'COLUMN', @level2name = N'senha';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Perfil de acesso: ADMIN ou VETERINARIO', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usuarios', @level2type = N'COLUMN', @level2name = N'role';
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Vincula um usuario de perfil VETERINARIO ao seu registro profissional, restringindo o que ele pode ver/editar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'usuarios', @level2type = N'COLUMN', @level2name = N'veterinario_id';

-- Indices de apoio as consultas mais frequentes da aplicacao
CREATE INDEX idx_clinica_nome ON clinicas (nome);
CREATE INDEX idx_veterinario_nome ON veterinarios (nome);
CREATE INDEX idx_veterinario_clinica ON veterinarios (clinica_id);
CREATE INDEX idx_pet_nome ON pets (nome);
CREATE INDEX idx_pet_tutor ON pets (tutor_id);
CREATE INDEX idx_consulta_pet ON consultas (pet_id);
CREATE INDEX idx_consulta_veterinario ON consultas (veterinario_id);
CREATE INDEX idx_consulta_status ON consultas (status);
CREATE INDEX idx_alerta_status ON alertas (status);
CREATE INDEX idx_alerta_pet ON alertas (pet_id);
