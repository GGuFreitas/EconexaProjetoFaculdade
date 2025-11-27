/*
 * Script SQL para criação e populamento do banco de dados ECONEXA.
 * Atualizado: 27 de Novembro de 2025 (Inclusão de Status na tabela usuarios)
 */

-- Define o banco de dados
CREATE DATABASE IF NOT EXISTS econexa
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE econexa;

-- TABELA USUARIOS
CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('MEMBRO', 'ADMIN') DEFAULT 'MEMBRO',
    -- NOVO CAMPO: Status do usuário para exclusão lógica
    status ENUM('ATIVO', 'INATIVO') NOT NULL DEFAULT 'ATIVO',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABELA TIPO_REGISTRO
CREATE TABLE IF NOT EXISTS tipo_registro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria ENUM('POSITIVO', 'NEGATIVO') NOT NULL,
    descricao TEXT,
    icone VARCHAR(50),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABELA REGISTRO
CREATE TABLE IF NOT EXISTS registro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    data TIMESTAMP NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    foto LONGBLOB,
    status ENUM('PENDENTE', 'EM_ANDAMENTO', 'RESOLVIDO') DEFAULT 'PENDENTE',
    tipo_registro_id BIGINT NOT NULL,
    usuario_id BIGINT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tipo_registro_id) REFERENCES tipo_registro(id) ON DELETE RESTRICT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE 
);

-- TABELA BLOG_POST
CREATE TABLE IF NOT EXISTS blog_post (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT NOT NULL,
    foto_capa LONGBLOB NULL, 
    status_publicacao ENUM('RASCUNHO', 'PUBLICADO') DEFAULT 'RASCUNHO',
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT NOT NULL,
    registro_id BIGINT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (registro_id) REFERENCES registro(id) ON DELETE SET NULL
);

-- TABELA REVISTA_POST
CREATE TABLE IF NOT EXISTS revista_post (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT NOT NULL,
    foto_capa LONGBLOB NULL, 
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    autor VARCHAR(200) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id));

-- TABELA LOG
CREATE TABLE IF NOT EXISTS Log (
    id_log BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome_tabela VARCHAR(100) NOT NULL,
    id_registro_alterado BIGINT NOT NULL,
    acao VARCHAR(10) NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100),
    dados_antigos TEXT,
    dados_novos TEXT
);

-- TABELA POST_CURTIDAS
CREATE TABLE IF NOT EXISTS post_curtidas (
    usuario_id BIGINT NOT NULL,
    post_id BIGINT NOT NULL,
    data_interacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, post_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES blog_post(id) ON DELETE CASCADE
);

-- TABELA POST_SALVOS
CREATE TABLE IF NOT EXISTS post_salvos (
    usuario_id BIGINT NOT NULL,
    post_id BIGINT NOT NULL,
    data_interacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, post_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES blog_post(id) ON DELETE CASCADE
);


-- =========================================================================
-- INSERÇÃO DE DADOS INICIAIS
-- =========================================================================

-- Senha = admin123 (Hash BCrypt para o Admin)
INSERT INTO usuarios (nome, email, senha_hash, perfil, status) VALUES
('Admin', 'admin@econexa.com', '$2a$10$AjSLurEZm7CDNM9/98/4KOqwTbUTMTg8JIbcEPtbtqFIljkVfOHwK', 'ADMIN', 'ATIVO');


INSERT INTO tipo_registro (nome, categoria, descricao, icone) VALUES
('Problema na Via', 'NEGATIVO', 'Buracos, asfalto ruim, calçadas quebradas, obstruções', 'fa-road'),
('Iluminação', 'NEGATIVO', 'Lâmpadas queimadas, postes quebrados, áreas escuras', 'fa-lightbulb'),
('Lixo e Limpeza', 'NEGATIVO', 'Lixo acumulado, entulho, terrenos sujos, coleta atrasada', 'fa-trash'),
('Água e Esgoto', 'NEGATIVO', 'Vazamentos, esgoto a céu aberto, alagamentos, poluição hídrica', 'fa-tint'),
('Animais em Risco', 'NEGATIVO', 'Maus-tratos, abandono, animais soltos, condições precárias', 'fa-paw'),
('Meio Ambiente', 'NEGATIVO', 'Queimadas, poluição, desmatamento, degradação ambiental', 'fa-tree'),
('Danos Urbanos', 'NEGATIVO', 'Pichações, vandalismo, mobiliário urbano quebrado', 'fa-spray-can'),
('Obras e Construção', 'NEGATIVO', 'Obras irregulares, tapumes perigosos, materiais na rua', 'fa-hard-hat'),
('Ruído Excessivo', 'NEGATIVO', 'Barulho alto, perturbação, poluição sonora', 'fa-volume-up'),
('Sinalização', 'NEGATIVO', 'Placas danificadas, falta de sinalização, trânsito perigoso', 'fa-traffic-light'),
('Animais Silvestres', 'NEGATIVO', 'Animais silvestres em área urbana, atropelamentos, caça', 'fa-crow'),
('Poluição', 'NEGATIVO', 'Poluição do ar, rios poluídos, contaminação, resíduos tóxicos', 'fa-smog'),
('Área Verde', 'POSITIVO', 'Parques bem cuidados, praças limpas, jardins bonitos', 'fa-leaf'),
('Melhoria Urbana', 'POSITIVO', 'Ruas reformadas, calçadas acessíveis, melhorias na cidade', 'fa-road'),
('Limpeza Pública', 'POSITIVO', 'Áreas limpas, lixo recolhido, cidade bem cuidada', 'fa-broom'),
('Proteção Animal', 'POSITIVO', 'Resgate de animais, cuidados veterinários, adoção responsável', 'fa-paw'),
('Conservação Ambiental', 'POSITIVO', 'Reflorestamento, preservação, ações ecológicas', 'fa-tree'),
('Mobilidade Sustentável', 'POSITIVO', 'Ciclovias, transporte ecológico, acessibilidade', 'fa-bicycle'),
('Segurança Pública', 'POSITIVO', 'Ações de segurança, policiamento, iluminação preventiva', 'fa-shield-alt'),
('Cultura e Lazer', 'POSITIVO', 'Eventos culturais, espaços de lazer, atividades comunitárias', 'fa-theater-masks'),
('Ação Comunitária', 'POSITIVO', 'Mutirões, projetos sociais, voluntariado, união de vizinhos', 'fa-users'),
('Infraestrutura Nova', 'POSITIVO', 'Novas obras, equipamentos públicos, melhorias urbanas', 'fa-building'),
('Proteção Animal', 'POSITIVO', 'Campanhas de castração, abrigos, cuidados com animais de rua', 'fa-heart'),
('Reciclagem', 'POSITIVO', 'Pontos de coleta seletiva, compostagem, educação ambiental', 'fa-recycle'),
('Conservação Natural', 'POSITIVO', 'Proteção de nascentes, áreas de preservação, biodiversidade', 'fa-mountain');

INSERT INTO registro (titulo, descricao, data, latitude, longitude, status, tipo_registro_id, usuario_id) VALUES
('Buraco na Av. Narciso Yague', 'Buraco grande perto do shopping de Mogi', CURRENT_TIMESTAMP, -23.518, -46.191, 'PENDENTE', 1, 1),
('Poste queimado na Rua das Flores', 'Poste apagado em frente ao número 50, no bairro Vila Nova', CURRENT_TIMESTAMP, -23.530, -46.185, 'EM_ANDAMENTO', 2, 1),
('Lixo na Praça da Matriz', 'Lixeiras transbordando na Praça Coronel Benedito de Almeida', CURRENT_TIMESTAMP, -23.522, -46.190, 'RESOLVIDO', 3, 1),
('Parque Centenário limpo', 'Parque Centenário está muito bem cuidado, ótimo para lazer', CURRENT_TIMESTAMP, -23.513, -46.208, 'PENDENTE', 11, 1),
('Asfalto novo no Centro', 'Rua Dr. Deodato Wertheimer recapeada perto da estação', CURRENT_TIMESTAMP, -23.521, -46.188, 'RESOLVIDO', 12, 1),
('Árvore em risco na Vila Oliveira', 'Árvore grande com galhos quebrando na R. Pres. Campos Sales', CURRENT_TIMESTAMP, -23.508, -46.185, 'PENDENTE', 5, 1),
('Movimento no Mercadão', 'Mercado Municipal com grande variedade de produtos locais', CURRENT_TIMESTAMP, -23.522, -46.187, 'PENDENTE', 18, 1);

-- Inserção de um post de blog (que depende de registro)
INSERT INTO blog_post (titulo, descricao, foto_capa, status_publicacao, usuario_id, registro_id)
SELECT 
    'Resolvido o buraco da Avenida Principal!',
    'Equipes foram até a Avenida Principal e realizaram o reparo completo da via.',
    NULL,
    'PUBLICADO',
    1, 
    id
FROM registro
WHERE id = 1;


-- =========================================================================
-- TRIGGERS PARA AUDITORIA (LOG)
-- =========================================================================

-- -------------------------------------------------------------------------
-- TRIGGERS DA TABELA USUARIOS (COM STATUS)
-- -------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_log_usuarios_update 
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('usuarios', 
           OLD.id,
           'UPDATE', 
           USER(), 
           -- Dados Antigos: Inclui o status anterior
           CONCAT('Nome: ', OLD.nome, ' | Email: ', OLD.email, ' | Perfil: ', OLD.perfil, ' | Status: ', OLD.status),
           -- Dados Novos: Inclui o novo status (se for INATIVO, essa é a ação de exclusão lógica)
           CONCAT('Nome: ', NEW.nome, ' | Email: ', NEW.email, ' | Perfil: ', NEW.perfil, ' | Status: ', NEW.status)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_usuarios_insert 
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('usuarios', 
           NEW.id,
           'INSERT', 
           USER(), 
           NULL,
           -- Dados Novos: Inclui o status (sempre ATIVO no insert)
           CONCAT('Nome: ', NEW.nome, ' | Email: ', NEW.email, ' | Perfil: ', NEW.perfil, ' | Status: ', NEW.status)
         );
END$$
DELIMITER ;

-- Mantido o Trigger de DELETE, embora não optarei pela exclusão física
DELIMITER $$
CREATE TRIGGER trg_log_usuarios_delete 
AFTER DELETE ON usuarios
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('usuarios', 
           OLD.id,
           'DELETE', 
           USER(), 
           -- Dados Antigos: Inclui o status antes da exclusão
           CONCAT('Nome: ', OLD.nome, ' | Email: ', OLD.email, ' | Perfil: ', OLD.perfil, ' | Status: ', OLD.status),
           NULL
         );
END$$
DELIMITER ;

-- -------------------------------------------------------------------------
-- TRIGGERS DAS OUTRAS TABELAS
-- -------------------------------------------------------------------------

-- Tipo_registro
DELIMITER $$
CREATE TRIGGER trg_log_tipo_registro_update 
AFTER UPDATE ON tipo_registro
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('tipo_registro', 
           OLD.id,
           'UPDATE', 
           USER(), 
           CONCAT('Nome: ', OLD.nome, ' | Categoria: ', OLD.categoria),
           CONCAT('Nome: ', NEW.nome, ' | Categoria: ', NEW.categoria)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_tipo_registro_insert 
AFTER INSERT ON tipo_registro
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('tipo_registro', 
           NEW.id,
           'INSERT', 
           USER(), 
           NULL,
           CONCAT('Nome: ', NEW.nome, ' | Categoria: ', NEW.categoria)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_tipo_registro_delete 
AFTER DELETE ON tipo_registro
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('tipo_registro', 
           OLD.id,
           'DELETE', 
           USER(), 
           CONCAT('Nome: ', OLD.nome, ' | Categoria: ', OLD.categoria),
           NULL
         );
END$$
DELIMITER ;


-- Registro
DELIMITER $$
CREATE TRIGGER trg_log_registro_update 
AFTER UPDATE ON registro
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('registro', 
           OLD.id,
           'UPDATE', 
           USER(), 
           CONCAT('Título: ', OLD.titulo, ' | Status: ', OLD.status, ' | Tipo: ', OLD.tipo_registro_id),
           CONCAT('Título: ', NEW.titulo, ' | Status: ', NEW.status, ' | Tipo: ', NEW.tipo_registro_id)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_registro_insert 
AFTER INSERT ON registro
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('registro', 
           NEW.id,
           'INSERT', 
           USER(), 
           NULL,
           CONCAT('Título: ', NEW.titulo, ' | Status: ', NEW.status, ' | Tipo: ', NEW.tipo_registro_id, ' | Usuário: ', NEW.usuario_id)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_registro_delete 
AFTER DELETE ON registro
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('registro', 
           OLD.id,
           'DELETE', 
           USER(), 
           CONCAT('Título: ', OLD.titulo, ' | Status: ', OLD.status, ' | Tipo: ', OLD.tipo_registro_id),
           NULL
         );
END$$
DELIMITER ;


-- blog_post
DELIMITER $$
CREATE TRIGGER trg_log_blog_post_update 
AFTER UPDATE ON blog_post
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('blog_post', 
           OLD.id,
           'UPDATE', 
           USER(), 
           CONCAT('Título: ', OLD.titulo, ' | Status: ', OLD.status_publicacao),
           CONCAT('Título: ', NEW.titulo, ' | Status: ', NEW.status_publicacao)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_blog_post_insert 
AFTER INSERT ON blog_post
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('blog_post', 
           NEW.id,
           'INSERT', 
           USER(), 
           NULL,
           CONCAT('Título: ', NEW.titulo, ' | Status: ', NEW.status_publicacao, ' | Usuário: ', NEW.usuario_id)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_blog_post_delete 
AFTER DELETE ON blog_post
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('blog_post', 
           OLD.id,
           'DELETE', 
           USER(), 
           CONCAT('Título: ', OLD.titulo, ' | Status: ', OLD.status_publicacao),
           NULL
         );
END$$
DELIMITER ;


-- revista_post
DELIMITER $$
CREATE TRIGGER trg_log_revista_post_update 
AFTER UPDATE ON revista_post
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('revista_post', 
           OLD.id,
           'UPDATE', 
           USER(), 
           CONCAT('Título: ', OLD.titulo, ' | Autor: ', OLD.autor),
           CONCAT('Título: ', NEW.titulo, ' | Autor: ', NEW.autor)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_revista_post_insert 
AFTER INSERT ON revista_post
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('revista_post', 
           NEW.id,
           'INSERT', 
           USER(), 
           NULL,
           CONCAT('Título: ', NEW.titulo, ' | Autor: ', NEW.autor, ' | Usuário: ', NEW.usuario_id)
         );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_log_revista_post_delete 
AFTER DELETE ON revista_post
FOR EACH ROW
BEGIN 
    INSERT INTO Log(nome_tabela, id_registro_alterado, acao, usuario, dados_antigos, dados_novos) 
    VALUES('revista_post', 
           OLD.id,
           'DELETE', 
           USER(), 
           CONCAT('Título: ', OLD.titulo, ' | Autor: ', OLD.autor),
           NULL
         );
END$$
DELIMITER ;