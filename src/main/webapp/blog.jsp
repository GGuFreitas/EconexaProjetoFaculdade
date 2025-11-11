<%-- 
    Document   : Blog
    Adaptado para a tabela blog_post
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- NOVOS IMPORTS --%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>

<%
    // Processamento de ações
    String acao = request.getParameter("acao");
    if ("inserir".equals(acao)) {
        try {
            // Cria um BLOG POST, não um registro de mapa
            Blog post = new Blog();
            post.setTitulo(request.getParameter("titulo"));
            post.setDescricao(request.getParameter("descricao"));
            post.setFotoCapa(request.getParameter("foto_capa")); // Novo campo
            
            // --- ATENÇÃO ---
            // O ID do usuário deve vir da SESSÃO após o login
            // Estamos fixando '1' (Admin) apenas como exemplo
            post.setUsuarioId(1L); 
            // --- FIM ATENÇÃO ---

            post.setStatusPublicacao("PUBLICADO"); // Define o status do post
            post.setDataPublicacao(new Date()); // Define a data
            
            // Opcional: Se o seu formulário enviasse um 'registro_id', 
            // você o definiria aqui. Por enquanto, será nulo.
            // post.setRegistroId(Long.parseLong(request.getParameter("registro_id")));

            new BlogDAO().inserir(post);
            
            // Redireciona para a própria página de blog
            response.sendRedirect("blog.jsp?sucesso=Post criado com sucesso!");
            return;
        } catch (Exception e) {
            response.sendRedirect("blog.jsp?erro=Erro ao criar post: " + e.getMessage());
            return;
        }
    }

    // Carregar dados para exibição (agora da tabela blog_post)
    BlogDAO postDAO = new BlogDAO();
    List<Blog> posts = postDAO.listarTodosPublicados();
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
                            <li class="nav-item"><a class="nav-link" href="index.html">Home</a></li>
                            <li class="nav-item"><a class="nav-link" href="mapa.jsp">Mapa</a></li>
                            <li class="nav-item"><a class="nav-link active" aria-current="page" href="#">Blog</a></li>
                            <li class="nav-item"><a class="nav-link" href="#">Revista</a></li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
        
        <div class="lista-registros">

            <div class="perfil">
                <div class="perfil-avatar">
                    <img src="https://placehold.co/50x50/333/FFF?text=A" alt="Avatar Admin"/>
                </div>
                <div class="perfil-info">
                    <strong>Admin</strong>
                    <small>@admin_econexa</small>
                </div>
                <div class="perfil-acoes">
                    <button class="btn-seguir">Seguir</button>
                </div>
            </div>
            
            <%-- Loop sobre a LISTA DE POSTS --%>
            <% 
                for(Blog post : posts) { 
            %>
            
                <%-- O onclick do mapa foi removido, pois um post não tem lat/long direto --%>
                <div class="registro-item">
                    
                    <section class="conteudo-grid" id="grid-conteudo">
                        <div class="grid">
                            
                            <div class="conteudo">
                                
                                <strong><%= post.getTitulo() %></strong>
                                
                                <div class="texto-registro">
                                    <%-- Mostra o nome do autor vindo do JOIN --%>
                                    <span class="registro-autor">
                                        Por: <%= post.getNomeAutor() %>
                                    </span>
                                </div>
                                
                                <div class="data-registro">
                                    <small class="registro-data">
                                        <p><%= new java.text.SimpleDateFormat("dd/MM/yyyy 'às' HH:mm").format(post.getDataPublicacao()) %></p>
                                    </small>
                                </div>
                                
                            </div>
                            
                            <%-- Usa a foto_capa do banco de dados --%>
                            <img src="<%= (post.getFotoCapa() != null ? post.getFotoCapa() : "resources/img/placeholder.jpg") %>" 
                                 alt="<%= post.getTitulo() %>"
                                 onerror="this.src='https://placehold.co/400x400/EEE/333?text=Sem+Foto'"/>
                            
                        </div>
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
                <%-- Action aponta para blog.jsp --%>
                <form method="POST" action="blog.jsp" id="formRegistro">
                    <input type="hidden" name="acao" value="inserir">
                    
                    
                    <div class="mb-2">
                        <label class="form-label">Título</label>
                        <input type="text" class="form-control" name="titulo" placeholder="Digite o título" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Descrição</label>
                        <textarea class="form-control" name="descricao" placeholder="Escreva seu post..." rows="4"></textarea>
                    </div>
                    
                    <div class="mb-2">
                        <label class="form-label">URL da Foto de Capa</label>
                        <input type="text" class="form-control" name="foto_capa" placeholder="http://.../imagem.jpg">
                    </div>
                    
                    <div class="d-grid gap-2" style="margin-top: 20px;">
                        <button type="submit" class="btn btn-success">
                            Publicar Post
                        </button>
                    </div>
                </form>
            </div>
            
        </div>
        
        <!-- Botão Flutuante -->
        <button class="btn-flutuante" id="btnNovoRegistro" title="Novo Registro" onclick="focarNoFormulario()">
            Postar
        </button>
        
        
        <script src="resources/js/bootstrap.js"></script>
        <script>
            // Função para abrir/fechar sidebar
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