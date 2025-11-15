/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Other/SQLTemplate.sql to edit this template
 */
/**
 * Author:  gufre, jhonny
 * Created: 20 de out. de 2025
 */

-- Script para MySQL - ECONEXA
CREATE DATABASE IF NOT EXISTS econexa
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE econexa;

-- Criar tabela de tipos de registro
CREATE TABLE IF NOT EXISTS tipo_registro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria ENUM('POSITIVO', 'NEGATIVO') NOT NULL,
    descricao TEXT,
    icone VARCHAR(50),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de registros
CREATE TABLE IF NOT EXISTS registro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    data TIMESTAMP NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    foto VARCHAR(255),
    status ENUM('PENDENTE', 'EM_ANDAMENTO', 'RESOLVIDO') DEFAULT 'PENDENTE',
    tipo_registro_id BIGINT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tipo_registro_id) REFERENCES tipo_registro(id) ON DELETE RESTRICT
);

-- Inserir dados iniciais para tipos de registro (categorias negativas)
INSERT INTO tipo_registro (nome, categoria, descricao, icone) VALUES
('Buraco na Via', 'NEGATIVO', 'Buraco ou irregularidade na pista', 'fa-road'),
('Iluminação Pública', 'NEGATIVO', 'Problema com iluminação pública', 'fa-lightbulb'),
('Coleta de Lixo', 'NEGATIVO', 'Problema com coleta de resíduos', 'fa-trash'),
('Esgoto a Céu Aberto', 'NEGATIVO', 'Vazamento ou esgoto exposto', 'fa-tint'),
('Árvore em Risco', 'NEGATIVO', 'Árvore com risco de queda', 'fa-tree'),
('Pichação', 'NEGATIVO', 'Pichação em muros ou paredes', 'fa-spray-can'),
('Obra Irregular', 'NEGATIVO', 'Obra sem autorização ou perigosa', 'fa-hard-hat'),
('Poluição Sonora', 'NEGATIVO', 'Ruído excessivo na vizinhança', 'fa-volume-up'),
('Entulho na Via', 'NEGATIVO', 'Entulho ou materiais na rua', 'fa-dumpster'),
('Sinalização Danificada', 'NEGATIVO', 'Placas ou sinalização danificada', 'fa-traffic-light');

-- Inserir dados iniciais para tipos de registro (categorias positivas)
INSERT INTO tipo_registro (nome, categoria, descricao, icone) VALUES
('Área Verde Bem Cuidada', 'POSITIVO', 'Parque ou praça bem conservada', 'fa-leaf'),
('Obra de Melhoria', 'POSITIVO', 'Obra que melhora a infraestrutura', 'fa-tools'),
('Limpeza Pública', 'POSITIVO', 'Área pública limpa e conservada', 'fa-broom'),
('Iluminação Eficiente', 'POSITIVO', 'Iluminação pública funcionando bem', 'fa-lightbulb'),
('Pavimentação Nova', 'POSITIVO', 'Rua recém-pavimentada', 'fa-road'),
('Arborização Urbana', 'POSITIVO', 'Novo plantio de árvores', 'fa-tree'),
('Mobilidade Urbana', 'POSITIVO', 'Melhoria na mobilidade', 'fa-bicycle'),
('Segurança Pública', 'POSITIVO', 'Ação positiva de segurança', 'fa-shield-alt'),
('Cultura e Lazer', 'POSITIVO', 'Evento ou espaço cultural', 'fa-theater-masks'),
('Ação Comunitária', 'POSITIVO', 'Ação positiva da comunidade', 'fa-users');

-- Inserir alguns registros de exemplo para testar o mapa
INSERT INTO registro (titulo, descricao, data, latitude, longitude, status, tipo_registro_id) VALUES
('Buraco na Av. Narciso Yague', 'Buraco grande perto do shopping de Mogi', CURRENT_TIMESTAMP, -23.518, -46.191, 'PENDENTE', 21),
('Poste queimado na Rua das Flores', 'Poste apagado em frente ao número 50, no bairro Vila Nova', CURRENT_TIMESTAMP, -23.530, -46.185, 'EM_ANDAMENTO', 22),
('Lixo na Praça da Matriz', 'Lixeiras transbordando na Praça Coronel Benedito de Almeida', CURRENT_TIMESTAMP, -23.522, -46.190, 'RESOLVIDO', 23),
('Parque Centenário limpo', 'Parque Centenário está muito bem cuidado, ótimo para lazer', CURRENT_TIMESTAMP, -23.513, -46.208, 'PENDENTE', 31),
('Asfalto novo no Centro', 'Rua Dr. Deodato Wertheimer recapeada perto da estação', CURRENT_TIMESTAMP, -23.521, -46.188, 'RESOLVIDO', 35),
('Árvore em risco na Vila Oliveira', 'Árvore grande com galhos quebrando na R. Pres. Campos Sales', CURRENT_TIMESTAMP, -23.508, -46.185, 'PENDENTE', 25),
('Movimento no Mercadão', 'Mercado Municipal com grande variedade de produtos locais', CURRENT_TIMESTAMP, -23.522, -46.187, 'PENDENTE', 40);

-- Criando tabelas do blog

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('MEMBRO', 'ADMIN') DEFAULT 'MEMBRO',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS blog_post (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT NOT NULL,
    foto_capa MEDIUMBLOB NULL, 
    status_publicacao ENUM('RASCUNHO', 'PUBLICADO') DEFAULT 'RASCUNHO',
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT NOT NULL,
    registro_id BIGINT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (registro_id) REFERENCES registro(id) ON DELETE SET NULL
);

INSERT INTO usuarios (nome, email, senha_hash, perfil) VALUES
('Admin', 'admin@econexa.com', 'senha', 'ADMIN');





----- Simulação de post (opcional)
INSERT INTO blog_post (titulo, descricao, foto_capa, status_publicacao, usuario_id, registro_id)
SELECT 
    'Resolvido o buraco da Avenida Principal!',
    'Equipes foram até a Avenida Principal e realizaram o reparo completo da via.',
    'SEM FOTO',
    'PUBLICADO',
    1,
    id
FROM registro
WHERE id = 1;