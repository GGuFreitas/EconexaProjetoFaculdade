<%--
    Author  : Alex Michel
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page import="com.mycompany.econexaadilson.model.RevistaPost"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.RevistaPostDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>

<%
    // Lógica de Sessão e Dados
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    String nomeExibicao = (usuario != null) ? usuario.getNome().split(" ")[0] : "Convidado";
    boolean estaLogado = (usuario != null);

    RevistaPostDAO revistaDAO = new RevistaPostDAO();
    List<RevistaPost> listaArtigos = revistaDAO.listarTodos();
    
    String sucesso = request.getParameter("sucesso");
    String erro = request.getParameter("erro");
%>

<!DOCTYPE html>
<html lang="pt-br">
    <head>
        <title>Revista Digital - ECONEXA</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        
        <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="resources/css/blog.css" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        
        <style>
            /* Estilos Específicos da Revista */
            .revista-hero {
                text-align: center;
                padding: 3rem 1rem;
                color: white;
                text-shadow: 0 2px 10px rgba(0,0,0,0.5);
                margin-bottom: 2rem;
            }
            
            .card-revista {
                border: none;
                border-radius: 12px;
                overflow: hidden;
                background-color: #fff;
                box-shadow: 0 6px 15px rgba(0,0,0,0.1);
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                position: relative;
            }
            
            .card-revista:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }
            
            .card-img-wrapper {
                height: 250px;
                overflow: hidden;
                position: relative;
            }
            
            .card-img-wrapper img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.5s ease;
            }
            
            .card-revista:hover .card-img-wrapper img {
                transform: scale(1.05);
            }
            
            .card-body {
                padding: 1.5rem;
                display: flex;
                flex-direction: column;
            }
            
            .meta-info {
                font-size: 0.85rem;
                color: #6c757d;
                margin-bottom: 0.5rem;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            
            .article-title {
                font-weight: 700;
                color: #2c3e50;
                margin-bottom: 1rem;
                font-size: 1.5rem;
            }
            
            .article-desc {
                color: #555;
                font-size: 0.95rem;
                line-height: 1.6;
                flex-grow: 1;
            }
            
            .author-badge {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                background-color: #e9ecef;
                color: #0d6efd;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                font-size: 0.9rem;
            }
            
            .owner-actions {
                position: absolute;
                top: 10px;
                right: 10px;
                z-index: 10;
                background: rgba(255,255,255,0.9);
                border-radius: 8px;
                padding: 5px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            }

            .sidebar-revista {
                position: fixed;
                top: 0;
                right: -450px;
                width: 400px;
                height: 100vh;
                background: white;
                z-index: 1050;
                box-shadow: -5px 0 15px rgba(0,0,0,0.1);
                transition: right 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
                overflow-y: auto;
                padding: 2rem;
            }
            
            .sidebar-revista.active {
                right: 0;
            }
            
            .overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100vw;
                height: 100vh;
                background: rgba(0,0,0,0.5);
                z-index: 1040;
                opacity: 0;
                visibility: hidden;
                transition: all 0.3s ease;
                backdrop-filter: blur(2px);
            }
            
            .overlay.active {
                opacity: 1;
                visibility: visible;
            }

            @media (min-width: 768px) {
                .card-img-wrapper {
                    height: 100%;
                    min-height: 280px;
                }
            }
        </style>
    </head>
    <body>
        
        <header class="main-header">
            <nav class="navbar navbar-expand-md navbar-light bg-transparent main-header">
                <div class="container-fluid">
                    <a class="navbar-brand" href="#">
                        <img src="resources/img/mini-logo.png" alt="ECONEXA" class="navbar-logo">
                    </a>

                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar" aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>

                    <div class="collapse navbar-collapse" id="mainNavbar">
                        <ul class="navbar-nav nav-pills mb-2 mb-lg-0">
                            <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                            <li class="nav-item"><a class="nav-link" href="mapa.jsp">Mapa</a></li>
                            <li class="nav-item"><a class="nav-link" href="blog.jsp">Blog</a></li>
                            <li class="nav-item"><a class="nav-link active" aria-current="page" href="revistaPost.jsp">Revista</a></li>
                            
                            <% if (estaLogado && usuario.isAdmin()) { %>
                                <li class="nav-item"><a class="nav-link" href="admin.jsp">Admin</a></li>
                            <% } %>

                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" 
                                   data-bs-toggle="dropdown" aria-expanded="false">
                                    
                                    <%= nomeExibicao %>
                                    
                                    <% if (estaLogado && usuario.isAdmin()) { %>
                                        <span class="badge bg-danger ms-1">ADMIN</span>
                                    <% } %>
                                </a>
                                
                                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
                                    
                                    <% if (estaLogado) { %>
                                        <li class="px-3 py-2">
                                            <small class="text-muted">Logado como</small><br>
                                            <strong><%= usuario.getNome() %></strong><br>
                                            <small class="text-muted"><%= usuario.getEmail() %></small>
                                        </li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item" href="meuPerfil.jsp">Meu Perfil</a></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item text-danger" href="LoginServlet">
                                            <i class="fas fa-sign-out-alt"></i> Sair
                                        </a></li>
                                        
                                    <% } else { %>
                                        <li><a class="dropdown-item" href="login.jsp">Entrar</a></li>
                                        <li><a class="dropdown-item" href="cadastro.jsp">Cadastrar-se</a></li>
                                    <% } %>
                                    
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>

        <div class="container pb-5">
            
            <div class="revista-hero">
                <h1 class="display-4 fw-bold">Revista Digital Econexa</h1>
                <p class="lead">Artigos, novidades e sustentabilidade em um só lugar.</p>
                
                <% if (estaLogado) { %>
                    <button class="btn btn-success btn-lg shadow mt-3 rounded-pill px-4" onclick="prepararNovoArtigo()">
                        <i class="fas fa-pen-nib me-2"></i> Publicar Artigo
                    </button>
                <% } else { %>
                    <div class="alert alert-info d-inline-block mt-3 px-4 py-2 rounded-pill" style="opacity: 0.9;">
                        <small><i class="fas fa-info-circle me-1"></i> Faça login para contribuir com a revista.</small>
                    </div>
                <% } %>
            </div>

            <% if (sucesso != null) { %> 
                <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fas fa-check-circle me-2"></i> <%= sucesso %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div> 
            <% } %>
            <% if (erro != null) { %> 
                <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i> <%= erro %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div> 
            <% } %>

            <div class="row g-4">
                <% if (listaArtigos.isEmpty()) { %>
                    <div class="col-12">
                        <div class="text-center p-5 text-white bg-dark bg-opacity-25 rounded-3 border border-white border-opacity-25">
                            <i class="far fa-folder-open fa-3x mb-3 opacity-50"></i>
                            <h3>Nenhum artigo encontrado.</h3>
                            <p>Seja o primeiro a compartilhar conhecimento com a comunidade!</p>
                        </div>
                    </div>
                <% } %>

                <% for (RevistaPost artigo : listaArtigos) { 
                    boolean isDono = usuario != null && usuario.getId().equals(artigo.getUsuarioId());
                %>
                    <div class="col-12">
                        <div class="card card-revista">
                            
                            <% if (isDono || (usuario != null && usuario.isAdmin())) { %>
                                <div class="owner-actions">
                                    <button class="btn btn-sm btn-outline-primary" 
                                            onclick="prepararEdicao(<%= artigo.getId() %>, '<%= artigo.getTitulo().replace("'", "\\'") %>', '<%= artigo.getAutor().replace("'", "\\'") %>', '<%= artigo.getDescricao().replace("'", "\\'").replace("\n", " ").replace("\r", " ") %>')"
                                            title="Editar Artigo">
                                        <i class="fas fa-pencil-alt"></i>
                                    </button>
                                    <a href="SalvarRevistaServlet?acao=excluir&id=<%= artigo.getId() %>" 
                                       class="btn btn-sm btn-outline-danger" 
                                       onclick="return confirm('Tem certeza que deseja excluir este artigo?')"
                                       title="Excluir Artigo">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            <% } %>

                            <div class="row g-0 align-items-center">
                                <div class="col-md-5 col-lg-4">
                                    <div class="card-img-wrapper">
                                        <img src="MostrarImagemServlet?id=<%= artigo.getId() %>&tipo=revista" 
                                             alt="<%= artigo.getTitulo() %>"
                                             onerror="this.src='resources/img/placeholder.jpg'">
                                    </div>
                                </div>
                                
                                <div class="col-md-7 col-lg-8">
                                    <div class="card-body">
                                        <div class="meta-info d-flex align-items-center">
                                            <span class="badge bg-primary me-2">ARTIGO</span>
                                            <span><i class="far fa-calendar me-1"></i> <%= new SimpleDateFormat("dd/MM/yyyy").format(artigo.getDataPublicacao()) %></span>
                                        </div>
                                        
                                        <h3 class="article-title"><%= artigo.getTitulo() %></h3>
                                        
                                        <p class="article-desc">
                                            <%= artigo.getDescricao().length() > 250 ? artigo.getDescricao().substring(0, 250) + "..." : artigo.getDescricao() %>
                                        </p>
                                        
                                        <div class="d-flex align-items-center mt-3 pt-3 border-top w-100">
                                            <div class="author-badge me-2">
                                                <%= artigo.getAutor().substring(0, 1).toUpperCase() %>
                                            </div>
                                            <div class="d-flex flex-column" style="line-height: 1.2;">
                                                <small class="text-muted" style="font-size: 0.75rem;">Escrito por</small>
                                                <span class="fw-bold text-dark"><%= artigo.getAutor() %></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>

        <div class="sidebar-revista" id="sidebarRevista">
            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                <h4 class="mb-0 fw-bold text-dark" id="sidebarTitle"><i class="fas fa-edit me-2 text-success"></i>Novo Artigo</h4>
                <button type="button" class="btn-close" onclick="fecharSidebar()"></button>
            </div>
            
            <form action="SalvarRevistaServlet" method="POST" enctype="multipart/form-data" id="formRevista">
                
                <input type="hidden" name="id" id="inputId">
                <input type="hidden" name="acao" id="inputAcao" value="inserir">

                <div class="mb-3">
                    <label class="form-label fw-bold">Título do Artigo</label>
                    <input type="text" class="form-control form-control-lg" name="titulo" id="inputTitulo" required placeholder="Digite um título chamativo...">
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Autor</label>
                    <input type="text" class="form-control" name="autor" id="inputAutor" required 
                           value="<%= (usuario != null) ? usuario.getNome() : "" %>" <%= (usuario != null && !usuario.isAdmin()) ? "readonly" : "" %>>
                    <% if(usuario != null && usuario.isAdmin()) { %>
                        <div class="form-text">Como admin, você pode editar o nome do autor.</div>
                    <% } %>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Conteúdo</label>
                    <textarea class="form-control" name="descricao" id="inputDescricao" rows="8" required placeholder="Escreva o conteúdo do seu artigo aqui..."></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-bold">Imagem de Capa</label>
                    <div class="input-group">
                        <input type="file" class="form-control" name="foto_capa" accept="image/png, image/jpeg" id="inputFoto">
                        <label class="input-group-text" for="inputFoto"><i class="fas fa-upload"></i></label>
                    </div>
                    <div class="form-text">Recomendado: Imagens horizontais (JPG/PNG). Na edição, deixe vazio para manter a atual.</div>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-success btn-lg rounded-pill fw-bold" id="btnSubmit">
                        <i class="fas fa-paper-plane me-2"></i> Publicar Artigo
                    </button>
                    <button type="button" class="btn btn-light btn-lg rounded-pill" onclick="fecharSidebar()">Cancelar</button>
                </div>
            </form>
        </div>
        
        <div class="overlay" id="overlay" onclick="fecharSidebar()"></div>

        <script src="resources/js/bootstrap.js"></script>
        <script>
            function toggleSidebar() {
                const sidebar = document.getElementById('sidebarRevista');
                const overlay = document.getElementById('overlay');
                
                sidebar.classList.toggle('active');
                overlay.classList.toggle('active');
                
                if (sidebar.classList.contains('active')) {
                    document.body.style.overflow = 'hidden';
                } else {
                    document.body.style.overflow = '';
                }
            }

            // Função para abrir sidebar em modo NOVO artigo
            function prepararNovoArtigo() {
                // Limpa os campos
                document.getElementById('inputId').value = '';
                document.getElementById('inputAcao').value = 'inserir';
                document.getElementById('inputTitulo').value = '';
                document.getElementById('inputDescricao').value = '';
                // Reseta título e botão
                document.getElementById('sidebarTitle').innerHTML = '<i class="fas fa-edit me-2 text-success"></i>Novo Artigo';
                document.getElementById('btnSubmit').innerHTML = '<i class="fas fa-paper-plane me-2"></i> Publicar Artigo';
                
                toggleSidebar();
            }

            // Função para abrir sidebar em modo EDIÇÃO
            function prepararEdicao(id, titulo, autor, descricao) {
                document.getElementById('inputId').value = id;
                document.getElementById('inputAcao').value = 'atualizar'; // Define ação de atualizar
                document.getElementById('inputTitulo').value = titulo;
                document.getElementById('inputAutor').value = autor;
                document.getElementById('inputDescricao').value = descricao;
                
                // Muda visualmente para indicar edição
                document.getElementById('sidebarTitle').innerHTML = '<i class="fas fa-pencil-alt me-2 text-primary"></i>Editar Artigo';
                document.getElementById('btnSubmit').innerHTML = '<i class="fas fa-save me-2"></i> Salvar Alterações';
                
                toggleSidebar();
            }

            function fecharSidebar() {
                const sidebar = document.getElementById('sidebarRevista');
                const overlay = document.getElementById('overlay');
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
                document.body.style.overflow = '';
            }
        </script>
    </body>
</html>