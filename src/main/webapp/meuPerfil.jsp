<%-- 
    Created on : 21 de nov. de 2025
    Author     : jhonny
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Date"%>

<%
    // 1. Verificar Autenticação
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nomeExibicao = usuario.getNome().split(" ")[0];
    boolean estaLogado = true; 
    BlogDAO postDAO = new BlogDAO();
    
    List<Blog> meusPosts = postDAO.listarPorUsuario(usuario.getId());
    
    List<Blog> curtidos = postDAO.listarCurtidosPorUsuario(usuario.getId());
    
    List<Blog> salvos = postDAO.listarSalvosPorUsuario(usuario.getId());
    

    String sucesso = request.getParameter("sucesso");
    String erro = request.getParameter("erro");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Meu Perfil - ECONEXA</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="resources/css/blog.css" rel="stylesheet" type="text/css"/>
        <link href="resources/css/meuPerfil.css" rel="stylesheet" type="text/css"/>
        
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
                            <li class="nav-item"><a class="nav-link" href="#">Revista</a></li>
                            <% if (usuario.isAdmin()) { %>
                                <li class="nav-item"><a class="nav-link" href="admin.jsp">Admin</a></li>
                            <% } %>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle active" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <%= nomeExibicao %>
                                    <% if (usuario.isAdmin()) { %><span class="badge bg-danger ms-1">ADMIN</span><% } %>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
                                    <li class="px-3 py-2">
                                        <small class="text-muted">Logado como</small><br>
                                        <strong><%= usuario.getNome() %></strong><br>
                                        <small class="text-muted"><%= usuario.getEmail() %></small>
                                    </li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item active" href="#">Meu Perfil</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item text-danger" href="LoginServlet"><i class="fas fa-sign-out-alt"></i> Sair</a></li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
        
        <!-- HEADER DO PERFIL -->
        <div class="perfil-header">
            <img src="https://placehold.co/120x120/27ae60/FFF?text=<%= nomeExibicao.substring(0,1) %>" class="perfil-avatar-large" alt="Avatar"/>
            <h2 class="perfil-nome"><%= usuario.getNome() %></h2>
            <p class="perfil-email"><%= usuario.getEmail() %></p>
            
            <div class="perfil-stats">
                <div class="stat-item" onclick="openTab('meus', document.getElementById('btn-meus'))">
                    <span class="stat-value"><%= meusPosts.size() %></span>
                    <span class="stat-label">Publicações</span>
                </div>
                <div class="stat-item" onclick="openTab('curtidos', document.getElementById('btn-curtidos'))">
                    <span class="stat-value"><%= curtidos.size() %></span>
                    <span class="stat-label">Curtidas</span>
                </div>
                <div class="stat-item" onclick="openTab('salvos', document.getElementById('btn-salvos'))">
                    <span class="stat-value"><%= salvos.size() %></span>
                    <span class="stat-label">Salvos</span>
                </div>
            </div>
        </div>

        <div class="lista-registros">
            
            <div class="profile-tabs">
                <button class="tab-btn active" id="btn-meus" onclick="openTab('meus', this)">MINHAS PUBLICAÇÕES</button>
                <button class="tab-btn" id="btn-curtidos" onclick="openTab('curtidos', this)">CURTIDOS</button>
                <button class="tab-btn" id="btn-salvos" onclick="openTab('salvos', this)">SALVOS</button>
            </div>

            <div id="meus" class="tab-content active">
                <% if (meusPosts.isEmpty()) { %>
                    <div class="btn btn-success">
                        <p>Você ainda não publicou nada.</p>
                        <a href="blog.jsp" class="btn btn-success mt-2">Criar primeira publicação</a>
                    </div>
                <% } %>
                
                <% for(Blog post : meusPosts) { %>
                    <div class="registro-item">
                        <section class="conteudo-grid">
                            <div class="grid">
                                <div class="conteudo">
                                    <strong><%= post.getTitulo() %></strong>
                                    <div class="texto-registro">
                                        <span class="registro-autor">
                                            Status: <span class="badge bg-<%= "PUBLICADO".equals(post.getStatusPublicacao()) ? "success" : "warning" %>"><%= post.getStatusPublicacao() %></span>
                                        </span>
                                    </div>
                                    <div class="descricao-registro">
                                        <span class="descricao-texto"><%= post.getDescricao() %></span>
                                    </div>
                                    <div class="data-registro">
                                        <small class="registro-data"><p><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(post.getDataPublicacao()) %></p></small>
                                    </div>
                                </div>
                                <img src="MostrarImagemServlet?id=<%= post.getId() %>" class="post-imagem" onerror="this.style.display='none'; this.parentElement.classList.add('no-grid-image');"/>
                            </div>
                        </section>
                    </div>
                <% } %>
            </div>

            <div id="curtidos" class="tab-content">
                <% if (curtidos.isEmpty()) { %> <p class="btn btn-success">Você ainda não curtiu nenhum post.</p> <% } %>
                
                <% for(Blog post : curtidos) { %>
                    <div class="registro-item">
                         <section class="conteudo-grid">
                             <div class="grid">
                                 <div class="conteudo">
                                     <strong><%= post.getTitulo() %></strong>
                                     <div class="texto-registro"><span class="registro-autor">Por: <%= post.getNomeAutor() %></span></div>
                                     <div class="descricao-registro"><span class="descricao-texto"><%= post.getDescricao() %></span></div>
                                     <div class="data-registro"><small class="registro-data"><p><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(post.getDataPublicacao()) %></p></small></div>
                                 </div>
                                 <img src="MostrarImagemServlet?id=<%= post.getId() %>" class="post-imagem" onerror="this.style.display='none'; this.parentElement.classList.add('no-grid-image');"/>
                             </div>
                         </section>
                         
                         <div class="post-actions">
                            <button class="action-btn <%= post.isCurtidoPeloUsuario() ? "active" : "" %>" 
                                    onclick="interagirPost(this, <%= post.getId() %>, 'like')">
                                <svg viewBox="0 0 24 24" class="icon-heart"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                                <span class="like-count"><%= post.getTotalCurtidas() %></span>
                            </button>
                         </div>
                    </div>
                <% } %>
            </div>
            
            <div id="salvos" class="tab-content">
                <% if (salvos.isEmpty()) { %> <p class="btn btn-success">Você ainda não salvou nenhum post.</p> <% } %>
                
                <% for(Blog post : salvos) { %>
                    <div class="registro-item">
                         <section class="conteudo-grid">
                             <div class="grid">
                                 <div class="conteudo">
                                     <strong><%= post.getTitulo() %></strong>
                                     <div class="texto-registro"><span class="registro-autor">Por: <%= post.getNomeAutor() %></span></div>
                                     <div class="descricao-registro"><span class="descricao-texto"><%= post.getDescricao() %></span></div>
                                     <div class="data-registro"><small class="registro-data"><p><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(post.getDataPublicacao()) %></p></small></div>
                                 </div>
                                 <img src="MostrarImagemServlet?id=<%= post.getId() %>" class="post-imagem" onerror="this.style.display='none'; this.parentElement.classList.add('no-grid-image');"/>
                             </div>
                         </section>
                         
                         <div class="post-actions">
                            <button class="action-btn <%= post.isSalvoPeloUsuario() ? "active" : "" %>"
                                    onclick="interagirPost(this, <%= post.getId() %>, 'save')">
                                <svg viewBox="0 0 24 24" class="icon-bookmark"><path d="M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z"/></svg>
                            </button>
                         </div>
                    </div>
                <% } %>
            </div>

        </div>
            
            
            
            <!-- Alertas -->
            <% if (sucesso != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= sucesso %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if (erro != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= erro %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <!-- Sidebar -->
        <div class="sidebar" id="sidebar-main">
            <div class="form-novo-registro">
                <h5>Postar no Blog</h5>
                
                <form method="POST" action="SalvarPostServlet" id="formRegistro" enctype="multipart/form-data">
                    
                    <div class="mb-2">
                        <label class="form-label">Título</label>
                        <input type="text" class="form-control" name="titulo" placeholder="Digite o título" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Descrição</label>
                        <textarea class="form-control" name="descricao" placeholder="Escreva seu post..." rows="4"></textarea>
                    </div>
                    
                    <div class="mb-2">
                        <label class="form-label">Foto de Capa</label>
                        <input type="file" class="form-control" name="foto_capa" accept="image/*">
                    </div>
                    
                    <div class="d-grid gap-2" style="margin-top: 20px;">
                        <% if (estaLogado) { %>
                            <button type="submit" class="btn btn-success">
                                Publicar Post
                            </button>
                        <% } else { %>
                            <a href="login.jsp" class="btn btn-secondary">
                                Faça login para publicar
                            </a>
                        <% } %>
                    </div>
                </form>
            </div>
        </div>
        
        <button class="btn-flutuante" id="btnNovoRegistro" title="Novo Registro" onclick="focarNoFormulario()">
            Postar
        </button>
        
        <script src="resources/js/bootstrap.js"></script>
        <script>
            function openTab(tabName, btnElement) {
                var contents = document.getElementsByClassName("tab-content");
                for (var i = 0; i < contents.length; i++) {
                    contents[i].style.display = "none";  
                    contents[i].classList.remove("active");
                }
                
                var tabs = document.getElementsByClassName("tab-btn");
                for (var i = 0; i < tabs.length; i++) {
                    tabs[i].classList.remove("active");
                }
                
                document.getElementById(tabName).style.display = "block";
                setTimeout(() => {
                     document.getElementById(tabName).classList.add("active");
                }, 10);
               
                if(btnElement) {
                    btnElement.classList.add("active");
                }
            }
            
            function interagirPost(btnElement, postId, tipo) {
                var isAdding = !btnElement.classList.contains('active');
                btnElement.classList.toggle('active');
                
                if (tipo === 'like') {
                    var countSpan = btnElement.querySelector('.like-count');
                    if(countSpan) {
                        var currentCount = parseInt(countSpan.innerText);
                        if (isAdding) {
                            countSpan.innerText = currentCount + 1;
                        } else {
                            countSpan.innerText = Math.max(0, currentCount - 1);
                        }
                    }
                }

                fetch('InteracaoServlet', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'postId=' + postId + '&tipo=' + tipo
                })
                .then(response => {
                    if (!response.ok) {
                        // Reverte em caso de erro
                        btnElement.classList.toggle('active');
                        alert("Erro ao salvar ação.");
                    }
                })
                .catch(error => {
                    console.error('Erro:', error);
                    btnElement.classList.toggle('active');
                });
            }
            
            function focarNoFormulario() {
                const sidebar = document.getElementById("sidebar-main");
                const button = document.getElementById("btnNovoRegistro");
                
                if (button.textContent === 'Fechar') {
                    button.textContent = 'Postar';
                } else {
                    button.textContent = 'Fechar';
                }
                
                sidebar.classList.toggle('is-visible');
            }
        </script>
    </body>
</html>