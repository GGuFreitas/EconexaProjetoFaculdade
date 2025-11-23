<%-- 
    Author   : jhonny
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
    String nomeExibicao = "Convidado";
    String emailExibicao = "";
    
    if (estaLogado) {
        String nomeCompleto = usuario.getNome();
        nomeExibicao = nomeCompleto.split(" ")[0];
        emailExibicao = usuario.getEmail();
    }

    BlogDAO postDAO = new BlogDAO();
    List<Blog> posts = postDAO.listarTodosPublicados();
    
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
                            <li class="nav-item"><a class="nav-link" href="#">Revista</a></li>
                            
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
                                        <li><a class="dropdown-item" href="#">Meu Perfil</a></li>
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
                    
                        <!-- Se tiver foto de perfil, coloque aqui. Por enquanto, inicial do nome -->
                        
                        <img src="https://placehold.co/50x50/27ae60/FFF?text=<%= nomeExibicao.substring(0,1) %>" alt="Avatar"/>
                    <% } else { %>
                        <img src="https://placehold.co/50x50/CCC/FFF?text=?" alt="Avatar Visitante"/>
                    <% } %>
                </div>
                <div class="perfil-info">
                    <strong><%= estaLogado ? usuario.getNome() : "Visitante" %></strong>
                    <small><%= estaLogado ? usuario.getEmail() : "Faça login para interagir" %></small>
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
            
            <!-- Lista de Posts -->
            <% for(Blog post : posts) { %>
                <div class="registro-item">
                    <section class="conteudo-grid" id="grid-conteudo">
                        <div class="grid">
                            <div class="conteudo">
                                <strong><%= post.getTitulo() %></strong>
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
                </div>
            <% } %>
        </div>
        
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