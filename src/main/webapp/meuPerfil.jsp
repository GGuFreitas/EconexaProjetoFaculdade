<%-- 
    Document   : meuPerfil
    Updated    : Abas + Edição (Sem Foto) + Exclusão + Interação
    Author     : gufre / jhonny
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Date"%>

<%
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
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar">
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
                                <a class="nav-link dropdown-toggle active" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown">
                                    <%= nomeExibicao %>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li><a class="dropdown-item text-danger" href="LoginServlet">Sair</a></li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
        
        <div class="perfil-header">
            <img src="https://placehold.co/120x120/27ae60/FFF?text=<%= nomeExibicao.substring(0,1) %>" class="perfil-avatar-large"/>
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
            
            <!-- Alertas -->
            <% if (sucesso != null) { %> <div class="alert alert-success"><%= sucesso %></div> <% } %>
            <% if (erro != null) { %> <div class="alert alert-danger"><%= erro %></div> <% } %>
            
            <div class="profile-tabs">
                <button class="tab-btn active" id="btn-meus" onclick="openTab('meus', this)">MINHAS PUBLICAÇÕES</button>
                <button class="tab-btn" id="btn-curtidos" onclick="openTab('curtidos', this)">CURTIDOS</button>
                <button class="tab-btn" id="btn-salvos" onclick="openTab('salvos', this)">SALVOS</button>
            </div>

            <div id="meus" class="tab-content active">
                <% if (meusPosts.isEmpty()) { %>
                     <div class="text-center mt-4" style="color: #888;">
                        <p>Você ainda não publicou nada.</p>
                     </div>
                <% } %>
                
                <% for(Blog post : meusPosts) { %>
                    <div class="registro-item">
                        <section class="conteudo-grid">
                            <div class="grid">
                                <div class="conteudo">
                                    <div class="d-flex gap-2">
                                            <!-- Botão Editar -->
                                            <button class="btn btn-dark" style="border-radius: 50%; width: 32px; height: 32px; padding: 0;" 
                                                    onclick="prepararEdicao(<%= post.getId() %>, '<%= post.getTitulo().replace("'", "\\'") %>', '<%= post.getDescricao().replace("'", "\\'").replace("\n", " ") %>')"
                                                    title="Editar">
                                                <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
                                            </button>
                                            <!-- Botão Excluir -->
                                            <a href="SalvarPostServlet?acao=excluir&id=<%= post.getId() %>&origem=perfil" 
                                               class="btn btn-danger" style="border-radius: 50%; width: 32px; height: 32px; padding: 0; display: flex; align-items: center; justify-content: center;"
                                               onclick="return confirm('Tem certeza que deseja excluir?')" title="Excluir">
                                                <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
                                            </a>
                                        </div>
                                    <div >
                                        <strong><%= post.getTitulo() %></strong>
                                        
                                    </div>

                                    <div class="texto-registro">
                                        <span class="registro-autor">Status: <span class="badge bg-<%= "PUBLICADO".equals(post.getStatusPublicacao()) ? "success" : "warning" %>"><%= post.getStatusPublicacao() %></span></span>
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
                        <div class="post-actions">
                            <button class="action-btn"><svg viewBox="0 0 24 24" class="icon-heart"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg><span class="like-count"><%= post.getTotalCurtidas() %></span></button>
                        </div>
                    </div>
                <% } %>
            </div>

            <div id="curtidos" class="tab-content">
                <% if (curtidos.isEmpty()) { %> <p class="text-center mt-4" style="color: #888;">Nenhum post curtido.</p> <% } %>
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
                            <button class="action-btn <%= post.isCurtidoPeloUsuario() ? "active" : "" %>" onclick="interagirPost(this, <%= post.getId() %>, 'like')">
                                <svg viewBox="0 0 24 24" class="icon-heart"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                                <span class="like-count"><%= post.getTotalCurtidas() %></span>
                            </button>
                         </div>
                    </div>
                <% } %>
            </div>

            <div id="salvos" class="tab-content">
                <% if (salvos.isEmpty()) { %> <p class="text-center mt-4" style="color: #888;">Nenhum post salvo.</p> <% } %>
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
                            <button class="action-btn <%= post.isSalvoPeloUsuario() ? "active" : "" %>" onclick="interagirPost(this, <%= post.getId() %>, 'save')">
                                <svg viewBox="0 0 24 24" class="icon-bookmark"><path d="M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z"/></svg>
                            </button>
                         </div>
                    </div>
                <% } %>
            </div>

        </div>
        
        <div class="sidebar" id="sidebar-main">
            <div class="form-novo-registro">
                <h5 id="formTitle">Editar Post</h5>
                <form method="POST" action="SalvarPostServlet" id="formRegistro" enctype="multipart/form-data">
                    <input type="hidden" name="origem" value="perfil">
                    <input type="hidden" name="id" id="inputId">
                    
                    <div class="mb-2">
                        <label class="form-label">Título</label>
                        <input type="text" class="form-control" name="titulo" id="inputTitulo" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Descrição</label>
                        <textarea class="form-control" name="descricao" id="inputDescricao" rows="4"></textarea>
                    </div>
                    
                    
                    <div class="d-grid gap-2 mt-3">
                        <button type="submit" class="btn btn-primary">Salvar Alterações</button>
                        <button type="button" class="btn btn-secondary" onclick="document.getElementById('sidebar-main').classList.remove('is-visible')">Cancelar</button>
                    </div>
                </form>
            </div>
        </div>

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
                setTimeout(() => { document.getElementById(tabName).classList.add("active"); }, 10);
                if(btnElement) { btnElement.classList.add("active"); }
            }
            
            function prepararEdicao(id, titulo, descricao) {
                var sidebar = document.getElementById("sidebar-main");
                sidebar.classList.add('is-visible');
                document.getElementById("inputId").value = id;
                document.getElementById("inputTitulo").value = titulo;
                document.getElementById("inputDescricao").value = descricao;
                window.scrollTo(0, 0);
            }

            function interagirPost(btnElement, postId, tipo) {
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
                }).then(response => { if (!response.ok) { btnElement.classList.toggle('active'); alert("Erro."); } })
                  .catch(error => { btnElement.classList.toggle('active'); });
            }
        </script>
    </body>
</html>