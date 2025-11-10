/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Other/SQLTemplate.sql to edit this template
 */
/**
 * Author:  gufre
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
('Buraco na Avenida Principal', 'Grande buraco na pista da Avenida Central, próximo ao número 123', CURRENT_TIMESTAMP, -15.792, -47.882, 'PENDENTE', 21),
('Poste de luz queimado', 'Poste não funciona há 3 dias na Rua das Flores', CURRENT_TIMESTAMP, -15.786, -47.875, 'EM_ANDAMENTO', 22),
('Lixo acumulado', 'Acúmulo de lixo na praça do bairro', CURRENT_TIMESTAMP, -15.788, -47.879, 'RESOLVIDO', 23),
('Parque bem conservado', 'Parque da cidade está impecável', CURRENT_TIMESTAMP, -15.790, -47.885, 'PENDENTE', 31),
('Nova pavimentação', 'Rua recém-asfaltada no centro', CURRENT_TIMESTAMP, -15.785, -47.878, 'RESOLVIDO', 35),
('Árvore caída', 'Árvore caída bloqueando a rua', CURRENT_TIMESTAMP, -15.795, -47.880, 'PENDENTE', 25),
('Feira comunitária', 'Feira de produtos locais no bairro', CURRENT_TIMESTAMP, -15.782, -47.876, 'PENDENTE', 40);
