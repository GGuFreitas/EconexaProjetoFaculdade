# 📋 Documentação do Projeto ECONEXA

## 📖 Índice
1. [Visão Geral](#visão-geral)
2. [Funcionalidades](#funcionalidades)
3. [Tecnologias Utilizadas](#tecnologias-utilizadas)
4. [Estrutura do Projeto](#estrutura-do-projeto)
5. [Instalação e Configuração](#instalação-e-configuração)
6. [Modelo de Dados](#modelo-de-dados)
7. [APIs e Endpoints](#apis-e-endpoints)
8. [Telas e Fluxos](#telas-e-fluxos)
9. [Contribuição](#contribuição)

## 🎯 Visão Geral

O **ECONEXA** é uma plataforma web inovadora desenvolvida para promover a conscientização e ação socioambiental através da tecnologia. A aplicação permite que usuários registrem problemas ambientais em um mapa interativo, criando uma rede colaborativa de monitoramento e solução de questões socioambientais.

### 🎯 Objetivos
- **Mapeamento Colaborativo**: Permitir que cidadãos relatem problemas ambientais
- **Educação Ambiental**: Disseminar conhecimento através de blog e revista integrados
- **Ação Social**: Conectar comunidade, poder público e organizações
- **Transparência**: Acompanhamento público da resolução de problemas

### 👥 Público-Alvo
- Comunidade em geral
- Órgãos públicos ambientais
- ONGs e instituições de proteção ambiental
- Estudantes e educadores

## ⚙️ Funcionalidades

### 🗺️ Módulo de Mapeamento
- **Mapa Interativo**: Visualização Leaflet com OpenStreetMap
- **Geolocalização**: Captura automática de coordenadas
- **Marcadores Categorizados**: Ícones diferenciados para problemas/soluções
- **Filtros Avançados**: Por tipo, status, usuário e data
- **Upload de Fotos**: Evidências visuais dos registros

### 👤 Módulo de Usuários
- **Cadastro e Login**: Sistema de autenticação seguro
- **Perfis Diferenciados**: Membro e Administrador
- **Gestão de Conteúdo**: Usuários veem apenas seus registros
- **Sistema de Curtidas**: Engajamento com publicações

### 📝 Módulo de Conteúdo
- **Blog Integrado**: Posts relacionados aos registros
- **Revista Digital**: Conteúdo editorial qualificado
- **Categorização**: Tipos pré-definidos de registros ambientais
- **Status Tracking**: Acompanhamento de resolução

### ⚡ Módulo Administrativo
- **Painel de Controle**: Gestão completa de conteúdos
- **Moderação**: Aprovação/edição/exclusão de registros
- **Relatórios**: Dados estatísticos e analytics
- **Backup e Logs**: Sistema de auditoria completo

## 🛠️ Tecnologias Utilizadas

### 💻 Backend
- **Java EE**: Linguagem principal
- **JSP (JavaServer Pages)**: Renderização dinâmica
- **Servlets**: Controladores da aplicação
- **MySQL**: Banco de dados relacional
- **JDBC**: Conexão com banco de dados
- **BCrypt**: Criptografia de senhas

### 🎨 Frontend
- **HTML5**: Estrutura semântica
- **CSS3**: Estilos e responsividade
- **Bootstrap 5**: Framework CSS
- **JavaScript**: Interatividade
- **Leaflet.js**: Mapas interativos
- **Font Awesome**: Ícones

### 📦 Ferramentas e Bibliotecas
- **Maven**: Gerenciamento de dependências
- **Git**: Controle de versão
- **Tomcat**: Servidor de aplicação
- **OpenStreetMap**: Mapas base
- **Chart.js**: Gráficos (futuras implementações)

## 📁 Estrutura do Projeto

```
EconexaProjetoFaculdade/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── mycompany/
│       │           └── econexaadilson/
│       │               ├── controller/          # Servlets
│       │               ├── model/
│       │               │   ├── DAO/            # Data Access Objects
│       │               │   ├── config/         # Configurações
│       │               │   └── entities/       # Entidades JPA
│       │               └── util/               # Utilitários
│       └── webapp/
│           ├── resources/
│           │   ├── css/                        # Estilos
│           │   ├── js/                         # Scripts
│           │   └── img/                        # Imagens
│           ├── WEB-INF/                        # Configurações web
│           └── *.jsp                           # Páginas JSP
├── database/                                   # Scripts SQL
├── documentation/                              # Documentação
└── README.md
```

## 🚀 Instalação e Configuração

### Pré-requisitos
- Java JDK 8+
- Apache Tomcat 9+
- MySQL 5.7+
- Maven 3.6+

### 📥 Passos de Instalação

1. **Clone do Repositório**
```bash
git clone https://github.com/GGuFreitas/EconexaProjetoFaculdade.git
cd EconexaProjetoFaculdade
```

2. **Configuração do Banco de Dados**
```sql
-- Execute o script SQL incluído no projeto
-- O script criará automaticamente:
-- - Database 'econexa'
-- - Tabelas e relações
-- - Usuário admin padrão
-- - Tipos de registro iniciais
```

3. **Configuração da Conexão**
```java
// Edite o arquivo: src/main/java/com/mycompany/econexaadilson/model/config/ConexaoBanco.java
public class ConexaoBanco {
    private static final String URL = "jdbc:mysql://localhost:3306/econexa";
    private static final String USER = "seu_usuario";
    private static final String PASSWORD = "sua_senha";
}
```

4. **Deploy no Tomcat**
```bash
mvn clean package
# Copie o .war para webapps do Tomcat
```

5. **Acesso à Aplicação**
```
http://localhost:8080/EconexaProjetoFaculdade/
```

### 🔧 Configurações Importantes

**Credenciais Admin Padrão:**
- Email: `admin@econexa.com`
- Senha: `admin123`

**Portas Configuradas:**
- Aplicação: 8080
- MySQL: 3306

## 🗃️ Modelo de Dados

### 📊 Diagrama Entidade-Relacionamento

```
usuarios (1) ---- (N) registro
    |                   |
    |                   |
 (N) ---- (N)       (1) ---- (1)
post_curtidas       tipo_registro
    |
    |
 (N) ---- (N)
post_salvos
```

### 🗂️ Principais Tabelas

#### 👥 Tabela `usuarios`
```sql
CREATE TABLE usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('MEMBRO', 'ADMIN') DEFAULT 'MEMBRO',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 🗺️ Tabela `registro`
```sql
CREATE TABLE registro (
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
    FOREIGN KEY (tipo_registro_id) REFERENCES tipo_registro(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);
```

#### 📋 Tabela `tipo_registro`
```sql
CREATE TABLE tipo_registro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria ENUM('POSITIVO', 'NEGATIVO') NOT NULL,
    descricao TEXT,
    icone VARCHAR(50),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 📝 Tabela `blog_post`
```sql
CREATE TABLE blog_post (
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
```

## 🌐 APIs e Endpoints

### 🔐 Autenticação
- `POST /LoginServlet` - Login de usuários
- `GET /LoginServlet` - Logout

### 🗺️ Registros no Mapa
- `POST /SalvarRegistroServlet` - Criar/editar registro
- `GET /MostrarImagemServlet` - Exibir imagens dos registros
- `GET /mapa.jsp` - Página principal do mapa

### 📊 Administração
- `GET /admin.jsp` - Painel administrativo
- Operações CRUD para registros, tipos e posts

### 📝 Conteúdo
- `GET /blog.jsp` - Página do blog
- `POST /SalvarPostServlet` - Gerenciar posts

## 🎨 Telas e Fluxos

### 🏠 Página Inicial (`index.jsp`)
- Apresentação do projeto
- Estatísticas da plataforma
- Chamada para ação

### 🗺️ Mapa Interativo (`mapa.jsp`)
**Funcionalidades:**
- Mapa Leaflet com controles
- Formulário flutuante para novos registros
- Lista lateral de registros existentes
- Filtros por tipo e usuário
- Geolocalização automática

**Fluxo:**
1. Usuário clica no mapa ou usa geolocalização
2. Preenche formulário com dados do problema
3. Opcional: upload de foto e criação de post no blog
4. Registro aparece no mapa em tempo real

### ⚡ Painel Admin (`admin.jsp`)
**Abas:**
- **Registros**: Gestão de todos os registros do mapa
- **Tipos**: CRUD de categorias de registros
- **Blog**: Moderação de posts

**Funcionalidades Admin:**
- Edição em lote
- Exclusão com confirmação
- Alteração de status
- Upload de imagens

### 📱 Design Responsivo
- **Mobile First**: Interface otimizada para dispositivos móveis
- **Bootstrap 5**: Grid system responsivo
- **Touch Friendly**: Botões e controles otimizados para touch

## 🤝 Contribuição

### 📝 Como Contribuir

1. **Fork do Projeto**
2. **Crie uma Branch**
```bash
git checkout -b feature/nova-funcionalidade
```
3. **Commit das Alterações**
```bash
git commit -m "Adiciona nova funcionalidade"
```
4. **Push para a Branch**
```bash
git push origin feature/nova-funcionalidade
```
5. **Abra um Pull Request**

### 🐛 Reportando Issues

Use o template:
```
## Descrição do Problema

## Passos para Reproduzir

## Comportamento Esperado

## Screenshots (se aplicável)

## Ambiente:
- Navegador: 
- SO:
- Versão da Aplicação:
```

### 🔄 Fluxo de Desenvolvimento

1. **Desenvolvimento**: Feature branches a partir de `develop`
2. **Testes**: Validação em ambiente de staging
3. **Review**: Code review obrigatório
4. **Deploy**: Merge para `main` apenas versões estáveis

## 📈 Próximas Implementações

### 🚀 Roadmap
- [ ] **Sistema de Notificações**
- [ ] **APIs RESTful**
- [ ] **Aplicativo Mobile**
- [ ] **Relatórios Avançados**
- [ ] **Integração com órgãos públicos**
- [ ] **Sistema de gamificação**
- [ ] **Análise de dados com machine learning**

### 🔧 Melhorias Técnicas
- [ ] Migração para Spring Boot
- [ ] Implementação de Docker
- [ ] Testes automatizados
- [ ] CI/CD pipeline
- [ ] Cache distribuído
- [ ] CDN para imagens

## 📄 Licença

Este projeto é desenvolvido para fins acadêmicos como parte do curso de Análise e Desenvolvimento de Sistemas da Universidade de Mogi das Cruzes.

## 👥 Autores

- **Gustavo de Freitas** - [GGuFreitas](https://github.com/GGuFreitas)
- **Jhonny Brito** - Co-desenvolvedor - [jhonnywobrito](https://github.com/jhonnywobrito)
- **Enzo Reis** - Co-desenvolvedor [Enzo-rbt0](https://github.com/Enzo-rbt0)
- **Enzo Reis** - Co-desenvolvedor [alexmichel21](https://github.com/alexmichel21) 
## 🙏 Agradecimentos

- Universidade de Mogi das Cruzes
- Professores orientadores
- Comunidade open source
- Contribuidores e testadores

---

**📞 Contato:** gu.fre.and@gmail.com  
**🌐 Repositório:** [GitHub - EconexaProjetoFaculdade](https://github.com/GGuFreitas/EconexaProjetoFaculdade)  
**📊 Demo:** Indisponivel ainda

---

*Documentação atualizada em: 20 de outubro de 2025*
