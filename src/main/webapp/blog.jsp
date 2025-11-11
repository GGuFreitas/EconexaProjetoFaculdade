<%-- 
    Document   : Blog
    Created on : 10 de nov. de 2025, 19:40:41
    Author     : Jhonny
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>

<%
    
    // Processamento de ações
    String acao = request.getParameter("acao");
    if ("inserir".equals(acao)) {
        try {
            Blog registro = new Blog();
            registro.setTitulo(request.getParameter("titulo"));
            registro.setDescricao(request.getParameter("descricao"));
            registro.setData(new Date());
            registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
            registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
            registro.setStatus("PENDENTE");
            
            new BlogDAO().inserir(registro);
            response.sendRedirect("mapa.jsp?sucesso=Registro criado com sucesso!");
            return;
        } catch (Exception e) {
            response.sendRedirect("mapa.jsp?erro=Erro ao criar registro: " + e.getMessage());
            return;
        }
    }

    // Carregar dados para exibição
    BlogDAO registroDAO = new BlogDAO();
    List<Blog> registros = registroDAO.listarTodos();

%>

<html>
    <head>
        <title>Blog</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0"><head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
        <link href="resources/css/blog.css" rel="stylesheet" type="text/css"/>
        </head>
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
        
        <p>PERFIL VAI AQUI</p>
    
    </div>
    
        <% 
            for(Blog registro : registros) { 
                // Esta lógica Java é mantida para que você possa usá-la no seu CSS
                String badgeClass = "";
                if ("PENDENTE".equals(registro.getStatus())) {
                    badgeClass = "warning";
                } else if ("RESOLVIDO".equals(registro.getStatus())) {
                    badgeClass = "success";
                } else {
                    badgeClass = "info";
                }
        %>
        
            <div class="registro-item"
                 onclick="mostrarNoMapa(<%= registro.getLatitude() %>, <%= registro.getLongitude() %>, '<%= registro.getTitulo().replace("'", "\\'") %>', '<%= registro.getDescricao().replace("'", "\\'") %>')">
                
                
                
        <section class="conteudo-grid" id="grid-conteudo">
            <div class="grid">
                
                <div class="conteudo">
                    
                    <strong><%= registro.getTitulo() %></strong>
                
                <div class="texto-registro">
                    <span class="registro-status status-<%= badgeClass %>">
                        <%= registro.getStatus() %>
                    </span>
                </div>
                    
                <div class="data-registro">
                    <small class="registro-data">
                        <p><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %></p>
                    </small>
                </div>
                
                
                   
                    
                </div>
                    
                    
                    <img src="resources/img/papagaio.jpg" alt=""/>
                    
                
                </div>
                
                
                
            </div>
        </section>
                
                
                    
        <% 
            } // Fim do loop 
        %>
</div>
        
        <div class="sidebar" id="sidebar-main">
            
            <div class="form-novo-registro">
                <h5>Postar</h5>
                <form method="POST" action="mapa.jsp" id="formRegistro">
                    <input type="hidden" name="acao" value="inserir">
                    <input type="hidden" name="latitude" id="inputLatitude">
                    <input type="hidden" name="longitude" id="inputLongitude">
                    
                    <div class="mb-2">
                        <label class="form-label">Título</label>
                        <input type="text" class="form-control" name="titulo" placeholder="Digite o título" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Descrição</label>
                        <textarea class="form-control" name="descricao" placeholder="Descreva o registro" rows="2"></textarea>
                    </div>
                    
                    <div class="mb-2">
                        <small class="text-muted">
                            Clique no mapa para selecionar a localização
                        </small>
                    </div>
                    
                    <div class="d-grid gap-2">
                        <button type="button" class="btn btn-primary" onclick="obterLocalizacao()">
                            Usar Minha Localização
                        </button>
                        <button type="submit" class="btn btn-success">
                            Salvar Registro
                        </button>
                    </div>
                </form>
            </div>
            
            
        </div>
        
        <!-- Botão Flutuante -->
        <button class="btn-flutuante" id="btnNovoRegistro" title="Novo Registro" onclick="focarNoFormulario()">
            Postar
        </button>
    </div>
        
        
        <script src="resources/js/bootstrap.js"></script>

        <script>
        

        // Função para focar no formulário (rolar a página até o formulário)
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

        // Função para mostrar um registro no mapa (quando clicado na lista)
        function mostrarNoMapa(lat, lng, titulo, descricao) {
            map.setView([lat, lng], 15);
            
            // Remove marcadores temporários anteriores
            marcadoresRegistros.forEach(function(marcador) {
                if (marcador._popup && marcador._popup._content && marcador._popup._content.includes('temporário')) {
                    map.removeLayer(marcador);
                }
            });
            
            // Adiciona marcador temporário
            var marcadorTemporario = L.marker([lat, lng]).addTo(map)
                .bindPopup('<h6>' + titulo + '</h6><p>' + descricao + '</p><small>Visualização temporária</small>')
                .openPopup();
                
            marcadoresRegistros.push(marcadorTemporario);
        }

        // Adicionar os registros existentes no mapa
        <% for(Blog registro : registros) { %>
            var marcador = L.marker([<%= registro.getLatitude() %>, <%= registro.getLongitude() %>])
                .addTo(map)
                .bindPopup(`
                    <h6><%= registro.getTitulo() %></h6>
                    <p><%= registro.getDescricao() %></p>
                    <small><strong>Status:</strong> <%= registro.getStatus() %></small>
                    <small><strong>Data:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %></small>
                `);
                
            marcadoresRegistros.push(marcador);
        <% } %>


        /*
         * 
        // Filtros
        document.getElementById('filtro-categoria').addEventListener('change', aplicarFiltros);
        document.getElementById('filtro-tipo').addEventListener('change', aplicarFiltros);

        
        function aplicarFiltros() {
            var filtroCategoria = document.getElementById('filtro-categoria').value;
            var filtroTipo = document.getElementById('filtro-tipo').value;
            
            // Aqui você implementaria a lógica para filtrar os registros
            // e atualizar o mapa conforme necessário
            console.log('Filtros aplicados:', {
                categoria: filtroCategoria,
                tipo: filtroTipo
            });
        }
        
        */
        
        
    </script>
    
    </body>
</html>
