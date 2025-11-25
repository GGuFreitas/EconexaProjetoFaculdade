<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    
    boolean estaLogado = (usuario != null);
    String nomeExibicao = "Convidado";
    
    if (estaLogado) {
        String nomeCompleto = usuario.getNome();
        nomeExibicao = nomeCompleto.split(" ")[0];
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>ECONEXA</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="resources/css/style-index.css" rel="stylesheet" type="text/css"/>
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
                            <li class="nav-item"><a class="nav-link active" aria-current="page" href="#">Home</a></li>
                            <li class="nav-item"><a class="nav-link" href="mapa.jsp">Mapa</a></li>
                            <li class="nav-item"><a class="nav-link"  href="blog.jsp">Blog</a></li>
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
        
        <div id="index-body">
            <div id="index-main">
                
                <div class="index-main-text">
                    <h1>CONECTADO COM O AMBIENTE EM VOLTA</h1>
                    <p>Veja o mapa interativo, acompanhe todas as ocorrências, aprenda um pouco e conheça mais sobre a cidade que vive!</p>
                    <p>Mogi das Cruzes - Suzano</p>
                </div>
                <div>
                    <img class="index-logo" src="resources/img/logo.png" alt="">
                </div>
                
            </div>
        </div>

        <div>

        </div>

        <script src="resources/js/bootstrap.js"></script>
    </body>
</html>