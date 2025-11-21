<%-- 
 *
 * @author Jhonny
 --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
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
                            <% if (usuario.isAdmin()) { %>
                                <li class="nav-item"><a class="nav-link" href="admin.jsp">Admin</a></li>
                            <% } %>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" 
                                   data-bs-toggle="dropdown" aria-expanded="false">
                                    <%
                                    // Pegar apenas o primeiro nome
                                    String nomeCompleto = usuario.getNome();
                                    String primeiroNome = nomeCompleto.split(" ")[0];
                                    %>
                                    <%= primeiroNome %>
                                    <% if (usuario.isAdmin()) { %>
                                        <span class="badge bg-danger ms-1">ADMIN</span>
                                    <% } %>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
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
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
        
        <div class="lista-registros">
            <!-- REMOVIDO: Seção fixa do perfil admin -->
            
            <% if (sucesso != null) { %>
                <div class="alert alert-success"><%= sucesso %></div>
            <% } %>
            <% if (erro != null) { %>
                <div class="alert alert-danger"><%= erro %></div>
            <% } %>
            
            <% 
                for(Blog post : posts) { 
            %>
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
                                 onerror="this.src='https://placehold.co/400x400/EEE/333?text=Sem+Foto'"/>
                        </div>
                    </section>
                </div>
            <% 
                } // Fim do loop 
            %>
        </div>
        
        <div class="sidebar" id="sidebar-main">
            <div class="form-novo-registro">
                <h5>Postar</h5>
                
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
                        <button type="submit" class="btn btn-success">
                            Publicar Post
                        </button>
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