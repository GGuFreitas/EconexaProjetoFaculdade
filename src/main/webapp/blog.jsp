<%-- 
    Document   : Blog
    Author     : jhonny
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    
    boolean estaLogado = (usuario != null);
    Long userId = estaLogado ? usuario.getId() : null; 
    
    String nomeExibicao = "Convidado";
    String emailExibicao = "";
    
    if (estaLogado) {
        String nomeCompleto = usuario.getNome();
        nomeExibicao = nomeCompleto.split(" ")[0];
        emailExibicao = usuario.getEmail();
    }

    BlogDAO postDAO = new BlogDAO();
    List<Blog> posts = postDAO.listarTodosPublicados(userId);
    
    String sucesso = request.getParameter("sucesso");
    String erro = request.getParameter("erro");
%>

<html>
    <head>
        <title>Blog</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="resources/css/blog.css" rel="stylesheet" type="text/css"/>
        <style>
            /* Estilos auxiliares para os ícones */
            .action-btn.active .icon-heart { fill: #e74c3c; stroke: #e74c3c; }
            .action-btn.active .icon-bookmark { fill: #f1c40f; stroke: #f1c40f; }
            .icon-heart, .icon-bookmark, .icon-comment { fill: none; stroke: white; stroke-width: 2; }
            .like-count { color: white; font-weight: bold; margin-left: 5px; font-size: 0.9rem; }
        </style>
    </head>
    <body>
        
        <header class="main-header">
            <nav class="navbar navbar-expand-md navbar-light bg-transparent main-header">
                <div class="container-fluid">
                    <a class="navbar-brand" href="#">
                        <img src="resources/img/mini-logo.png" alt="ECONEXA" class="navbar-logo">
                    </a>

                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar"
                            aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>

                    <div class="collapse navbar-collapse" id="mainNavbar">
                        <ul class="navbar-nav nav-pills mb-2 mb-lg-0">
                            <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                            <li class="nav-item"><a class="nav-link" href="mapa.jsp">Mapa</a></li>
                            <li class="nav-item"><a class="nav-link active" aria-current="page" href="#">Blog</a></li>
                            <li class="nav-item"><a class="nav-link" href="revistaPost.jsp">Revista</a></li>
                            
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
        
        <div class="lista-registros">
            
            <div class="perfil">
                <div class="perfil-avatar">
                    <% if (estaLogado) { %>
                        <img src="https://placehold.co/50x50/27ae60/FFF?text=<%= nomeExibicao.substring(0,1) %>" alt="Avatar"/>
                    <% } else { %>
                        <img src="https://placehold.co/50x50/CCC/FFF?text=?" alt="Avatar Visitante"/>
                    <% } %>
                </div>
                <div class="perfil-info">
                    <strong><%= estaLogado ? usuario.getNome() : "Visitante" %></strong>
                    <small><%= estaLogado ? usuario.getEmail() : "Faça login para interagir" %></small>
                </div>
                
                <div>
                    <a class="btn btn-light" href="meuPerfil.jsp">Meu perfil</a>
                </div>
            </div>

            <!-- Alertas -->
            <% if (request.getParameter("sucesso") != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= request.getParameter("sucesso") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if (request.getParameter("erro") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= request.getParameter("erro") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <% for(Blog post : posts) { 
                boolean isDono = estaLogado && usuario.getId().equals(post.getUsuarioId());
            %>
                <div class="registro-item">
                    <section class="conteudo-grid" id="grid-conteudo">
                        <div class="grid">
                            <div class="conteudo">
                                <% if (isDono) { %>
                                        <div class="d-flex gap-2">
                                            <button class="btn btn-dark" style="border-radius: 50%; width: 32px; height: 32px; padding: 0;" 
                                                    onclick="prepararEdicao(<%= post.getId() %>, '<%= post.getTitulo().replace("'", "\\'") %>', '<%= post.getDescricao().replace("'", "\\'").replace("\n", " ") %>')"
                                                    title="Editar">
                                                <!-- Ícone Lápis -->
                                                <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
                                            </button>
                                            
                                            <a href="SalvarPostServlet?acao=excluir&id=<%= post.getId() %>&origem=blog" 
                                               class="btn btn-danger" 
                                               style="border-radius: 50%; width: 32px; height: 32px; padding: 0; display: flex; align-items: center; justify-content: center;"
                                               onclick="return confirm('Tem certeza que deseja excluir este post?')"
                                               title="Excluir">
                                                <!-- Ícone Lixeira -->
                                                <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
                                            </a>
                                        </div>
                                    <% } %>
                                <div>
                                    <strong><%= post.getTitulo() %></strong>
                                    
                                    
                                </div>
                                
                                <div class="texto-registro">
                                     <span class="registro-autor">
                                         Por: <%= post.getNomeAutor() %>
                                     </span>
                                </div>
                                
                                <div class="descricao-registro">
                                     <span class="descricao-texto">
                                         <%= post.getDescricao() %>
                                     </span>
                                </div>
                                
                                <div class="data-registro">
                                    <small class="registro-data">
                                        <p><%= new java.text.SimpleDateFormat("dd/MM/yyyy 'às' HH:mm").format(post.getDataPublicacao()) %></p>
                                    </small>
                                </div>
                            </div>
                            
                            <img src="MostrarImagemServlet?id=<%= post.getId() %>" 
                                 alt="<%= post.getTitulo() %>"
                                 class="post-imagem"
                                 onerror="this.style.display='none'; this.parentElement.classList.add('no-grid-image');"/>
                        </div>
                    </section>
                    
                    <div class="post-actions">
                        
                        <button class="action-btn <%= post.isCurtidoPeloUsuario() ? "active" : "" %>" 
                                onclick="interagirPost(this, <%= post.getId() %>, 'like')"
                                title="Curtir">
                            <svg viewBox="0 0 24 24" class="icon-heart">
                                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                            </svg>
                            <span class="like-count"><%= post.getTotalCurtidas() %></span>
                        </button>
                        
                        <button class="action-btn <%= post.isSalvoPeloUsuario() ? "active" : "" %>"
                                onclick="interagirPost(this, <%= post.getId() %>, 'save')"
                                title="Salvar no Perfil">
                            <svg viewBox="0 0 24 24" class="icon-bookmark">
                                <path d="M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z"/>
                            </svg>
                        </button>
                    </div>
                    
                </div>
            <% } %>
        </div>
        
        <!-- NOVA SIDEBAR (Estilo Revista) -->
        <div class="sidebar-right" id="sidebarBlog">
            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                <h4 class="mb-0 fw-bold text-dark" id="sidebarTitle"><i class="fas fa-edit me-2 text-success"></i>Postar</h4>
                <button type="button" class="btn-close" onclick="fecharSidebar()"></button>
            </div>
            
            <form method="POST" action="SalvarPostServlet" id="formRegistro" enctype="multipart/form-data">
                <input type="hidden" name="origem" value="blog">
                <input type="hidden" name="id" id="inputId">

                <div class="mb-3">
                    <label class="form-label fw-bold">Título</label>
                    <input type="text" class="form-control form-control-lg" name="titulo" id="inputTitulo" required placeholder="Digite um título...">
                </div>
                
                <div class="mb-3">
                    <label class="form-label fw-bold">Conteúdo</label>
                    <textarea class="form-control" name="descricao" id="inputDescricao" rows="8" required placeholder="Escreva o conteúdo do seu post aqui..."></textarea>
                </div>
                
                <!-- Div Foto (Será escondida na edição) -->
                <div class="mb-4" id="divFotoCapa">
                    <label class="form-label fw-bold">Imagem de Capa</label>
                    <div class="input-group">
                        <input type="file" class="form-control" name="foto_capa" id="inputFoto" accept="image/png, image/jpeg">
                        <label class="input-group-text" for="inputFoto"><i class="fas fa-upload"></i></label>
                    </div>
                    <div class="form-text">Recomendado: Imagens horizontais (JPG/PNG).</div>
                </div>
                
                <div class="d-grid gap-2">
                    <% if (estaLogado) { %>
                        <button type="submit" class="btn btn-success btn-lg rounded-pill fw-bold" id="btnSubmit">
                            <i class="fas fa-paper-plane me-2"></i> Publicar Post
                        </button>
                    <% } else { %>
                        <a href="login.jsp" class="btn btn-secondary btn-lg rounded-pill">Faça login para publicar</a>
                    <% } %>
                </div>
            </form>
        </div>
        
        <!-- Botão Flutuante -->
        
        <% if (estaLogado) { %>
                    <button class="btn-flutuante" id="btnNovoRegistro" onclick="prepararNovoPost()">
            <i class="fas fa-plus me-2"></i>Postar
        </button>
                <% } %>
        
        
        <!-- Overlay -->
        <div class="overlay" id="overlay" onclick="fecharSidebar()"></div>
        
        
        <script src="resources/js/bootstrap.js"></script>
        <script>
            function toggleSidebar() {
                const sidebar = document.getElementById('sidebarBlog');
                const overlay = document.getElementById('overlay');
                sidebar.classList.toggle('active');
                overlay.classList.toggle('active');
                document.body.style.overflow = sidebar.classList.contains('active') ? 'hidden' : '';
            }
            
            function fecharSidebar() {
                const sidebar = document.getElementById('sidebarBlog');
                const overlay = document.getElementById('overlay');
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
                document.body.style.overflow = '';
            }

            function prepararNovoPost() {
                document.getElementById("formRegistro").reset();
                document.getElementById("inputId").value = "";
                
                // Garante que o campo de foto apareça
                document.getElementById("divFotoCapa").classList.remove("d-none");
                
                document.getElementById("sidebarTitle").innerHTML = '<i class="fas fa-edit me-2 text-success"></i>Novo Post';
                document.getElementById("btnSubmit").innerHTML = '<i class="fas fa-paper-plane me-2"></i> Publicar Post';
                document.getElementById("btnSubmit").classList.replace("btn-primary", "btn-success");
                
                toggleSidebar();
            }

            function prepararEdicao(id, titulo, descricao) {
                document.getElementById("inputId").value = id;
                document.getElementById("inputTitulo").value = titulo;
                document.getElementById("inputDescricao").value = descricao;
                
                // ESCONDE foto na edição (regra solicitada)
                document.getElementById("divFotoCapa").classList.add("d-none");
                
                document.getElementById("sidebarTitle").innerHTML = '<i class="fas fa-pencil-alt me-2 text-primary"></i>Editar Post';
                document.getElementById("btnSubmit").innerHTML = '<i class="fas fa-save me-2"></i> Salvar Alterações';
                document.getElementById("btnSubmit").classList.replace("btn-success", "btn-primary");
                
                toggleSidebar();
            }

            // Função AJAX para interagir
            function interagirPost(btnElement, postId, tipo) {
                <% if (!estaLogado) { %>
                    alert("Faça login para interagir!");
                    return;
                <% } %>

                var isAdding = !btnElement.classList.contains('active');
                btnElement.classList.toggle('active');
                
                if (tipo === 'like') {
                    var countSpan = btnElement.querySelector('.like-count');
                    if(countSpan) {
                        var currentCount = parseInt(countSpan.innerText);
                        countSpan.innerText = isAdding ? currentCount + 1 : Math.max(0, currentCount - 1);
                    }
                }

                fetch('InteracaoServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'postId=' + postId + '&tipo=' + tipo
                })
                .then(response => { if (!response.ok) { btnElement.classList.toggle('active'); alert("Erro."); } })
                .catch(error => { btnElement.classList.toggle('active'); });
            }
        </script>
        
    </body>
</html>