/* * Author:  gufre, jhonny
 * Created: 20 de out. de 2025
 */

CREATE DATABASE IF NOT EXISTS econexa
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE econexa;

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('MEMBRO', 'ADMIN') DEFAULT 'MEMBRO',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tipo_registro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria ENUM('POSITIVO', 'NEGATIVO') NOT NULL,
    descricao TEXT,
    icone VARCHAR(50),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE -- NOVO: FK para usuário
);

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
-- senha = admin123
 INSERT INTO usuarios (nome, email, senha_hash, perfil) VALUES
('Admin', 'admin@econexa.com', '$2a$10$AjSLurEZm7CDNM9/98/4KOqwTbUTMTg8JIbcEPtbtqFIljkVfOHwK', 'ADMIN');

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

-- 4. Por último blog_post (que depende de registro)
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