<%-- 
    Document   : mapa
    Created on : 20 de out. de 2025, 19:40:41
    Author     : gufre
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.RegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.TipoRegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.TipoRegistro"%>
<%@page import="com.mycompany.econexaadilson.model.Registro"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>
<%
    
    // Processamento de ações
    String acao = request.getParameter("acao");
    if ("inserir".equals(acao)) {
        try {
            Registro registro = new Registro();
            registro.setTitulo(request.getParameter("titulo"));
            registro.setDescricao(request.getParameter("descricao"));
            registro.setData(new Date());
            registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
            registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
            registro.setStatus("PENDENTE");
            
            Long tipoRegistroId = Long.parseLong(request.getParameter("tipoRegistroId"));
            TipoRegistro tipoRegistro = new TipoRegistroDAO().buscarPorId(tipoRegistroId);
            registro.setTipoRegistro(tipoRegistro);
            
            new RegistroDAO().inserir(registro);
            response.sendRedirect("mapa.jsp?sucesso=Registro criado com sucesso!");
            return;
        } catch (Exception e) {
            response.sendRedirect("mapa.jsp?erro=Erro ao criar registro: " + e.getMessage());
            return;
        }
    }

    // Carregar dados para exibição
    RegistroDAO registroDAO = new RegistroDAO();
    TipoRegistroDAO tipoRegistroDAO = new TipoRegistroDAO();
    List<Registro> registros = registroDAO.listarTodos();
    List<TipoRegistro> tiposRegistro = tipoRegistroDAO.listarTodos();

%>
<!DOCTYPE html>
<html>
<head>
    <title>ECONEXA - Mapa</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="resources/css/leaflet.css" rel="stylesheet" type="text/css"/>
    <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
    <link href="resources/css/mapa.css" rel="stylesheet" type="text/css"/>
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
        <li class="nav-item"><a class="nav-link active" aria-current="page" href="#">Mapa</a></li>
        <li class="nav-item"><a class="nav-link" href="#">Blog</a></li>
        <li class="nav-item"><a class="nav-link" href="#">Revista</a></li>
      </ul>
    </div>
  </div>
</nav>
        </header>

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

    <div id="mapa-container">
        <div id="mapa"></div>
        
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar-main">
            <!-- FILTROS REMOVIDOS POR ENQUANTO
            
            <div class="filtros">
                <h5>Filtros</h5>
                <select id="filtro-categoria" class="form-select mb-2">
                    <option value="TODOS">Todas as categorias</option>
                    <option value="POSITIVO">Positivo</option>
                    <option value="NEGATIVO">Negativo</option>
                </select>
                <select id="filtro-tipo" class="form-select">
                    <option value="TODOS">Todos os tipos</option>
                    <% for(TipoRegistro tipo : tiposRegistro) { %>
                        <option value="<%= tipo.getId() %>"><%= tipo.getNome() %></option>
                    <% } %>
                </select>
            </div> 
            
            -->
            
            <div class="form-novo-registro">
                <h5>Novo Registro</h5>
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
                        <label class="form-label">Tipo</label>
                        <select class="form-select" name="tipoRegistroId" required>
                            <option value="">Selecione o tipo</option>
                            <% for(TipoRegistro tipo : tiposRegistro) { %>
                                <option value="<%= tipo.getId() %>">
                                    <%= tipo.getNome() %>
                                </option>
                            <% } %>
                        </select>
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
            
            <div class="lista-registros">
                <h5>Registros (<%= registros.size() %>)</h5>
                <div id="lista-registros-container">
                    <% for(Registro registro : registros) { 
                        String badgeClass = "";
                        if ("PENDENTE".equals(registro.getStatus())) {
                            badgeClass = "warning";
                        } else if ("RESOLVIDO".equals(registro.getStatus())) {
                            badgeClass = "success";
                        } else {
                            badgeClass = "info";
                        }
                    %>
                        <div class="registro-item <%= "POSITIVO".equals(registro.getTipoRegistro().getCategoria()) ? "categoria-positivo" : "categoria-negativo" %>"
                             onclick="mostrarNoMapa(<%= registro.getLatitude() %>, <%= registro.getLongitude() %>, '<%= registro.getTitulo().replace("'", "\\'") %>', '<%= registro.getDescricao().replace("'", "\\'") %>')">
                            <strong><%= registro.getTitulo() %></strong>
                            <div class="mt-1">
                                <small class="text-muted">
                                    <%= registro.getTipoRegistro().getNome() %> • 
                                    <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %>
                                </small>
                            </div>
                            <div class="mt-1">
                                <span class="badge bg-<%= badgeClass %>">
                                    <%= registro.getStatus() %>
                                </span>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- Botão Flutuante -->
        <button class="btn-flutuante" id="btnNovoRegistro" title="Novo Registro" onclick="focarNoFormulario()">
            Novo Registro
        </button>
    </div>

    <script src="resources/js/leaflet.js" type="text/javascript"></script>
    <script src="resources/js/bootstrap.js"></script>
    <script>
        // Inicialização do mapa
        var map = L.map('mapa').setView([-15.788, -47.879], 13); // Coordenadas de Brasília

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        // Variável para armazenar o marcador de localização selecionada
        var marcadorSelecionado = null;
        var marcadoresRegistros = [];

        // Evento de clique no mapa para adicionar/atualizar marcador
        map.on('click', function(e) {
            var lat = e.latlng.lat;
            var lng = e.latlng.lng;

            // Atualiza os campos ocultos do formulário
            document.getElementById('inputLatitude').value = lat;
            document.getElementById('inputLongitude').value = lng;

            // Remove o marcador anterior, se existir
            if (marcadorSelecionado) {
                map.removeLayer(marcadorSelecionado);
            }

            // Adiciona um novo marcador
            marcadorSelecionado = L.marker([lat, lng]).addTo(map)
                .bindPopup('Localização selecionada: ' + lat.toFixed(4) + ', ' + lng.toFixed(4))
                .openPopup();
        });

        // Função para obter a localização do usuário
        function obterLocalizacao() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;

                    // Atualiza os campos ocultos
                    document.getElementById('inputLatitude').value = lat;
                    document.getElementById('inputLongitude').value = lng;

                    // Remove marcador anterior
                    if (marcadorSelecionado) {
                        map.removeLayer(marcadorSelecionado);
                    }

                    // Adiciona marcador na localização atual
                    marcadorSelecionado = L.marker([lat, lng]).addTo(map)
                        .bindPopup('Sua localização atual: ' + lat.toFixed(4) + ', ' + lng.toFixed(4))
                        .openPopup();

                    // Centraliza o mapa na localização atual
                    map.setView([lat, lng], 15);
                }, function(error) {
                    alert('Erro ao obter localização: ' + error.message);
                });
            } else {
                alert('Geolocalização não é suportada por este navegador.');
            }
        }

        // Função para focar no formulário (rolar a página até o formulário)
        function focarNoFormulario() {
            const sidebar = document.getElementById("sidebar-main");
            const button = document.getElementById("btnNovoRegistro");
            
            
            if (button.textContent === 'Fechar') {
                button.textContent = 'Novo Registro';
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
        <% for(Registro registro : registros) { %>
            var marcador = L.marker([<%= registro.getLatitude() %>, <%= registro.getLongitude() %>])
                .addTo(map)
                .bindPopup(`
                    <h6><%= registro.getTitulo() %></h6>
                    <p><%= registro.getDescricao() %></p>
                    <small><strong>Tipo:</strong> <%= registro.getTipoRegistro().getNome() %></small>
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