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

<%
    String acao = request.getParameter("acao");
    String filtro = request.getParameter("filtro");
    
    RegistroDAO registroDAO = new RegistroDAO();
    TipoRegistroDAO tipoRegistroDAO = new TipoRegistroDAO();
    List<TipoRegistro> tiposRegistro = tipoRegistroDAO.listarTodos();
    
    // Carregar registros com filtro
    List<Registro> registros;
    if ("meus".equals(filtro) && estaLogado) {
        registros = registroDAO.listarPorUsuario(usuario.getId());
    } else {
        registros = registroDAO.listarTodos();
    }
    
    String sucesso = request.getParameter("sucesso");
    String erro = request.getParameter("erro");
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
                        <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                        <li class="nav-item"><a class="nav-link active" aria-current="page" href="#">Mapa</a></li>
                        <li class="nav-item"><a class="nav-link" href="blog.jsp">Blog</a></li>
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

    <div id="mapa-container">
        <div id="mapa"></div>
        
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar-main">
            
            <div class="form-novo-registro">
                  <h5>Novo Registro</h5>
                  <form method="POST" action="SalvarRegistroServlet" id="formRegistro" enctype="multipart/form-data">
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
                            <label class="form-label">Foto (Opcional)</label>
                            <input type="file" class="form-control" name="foto" id="inputFoto" accept="image/*" capture="environment">
                            <small class="text-muted">Você pode tirar uma foto ou escolher da galeria</small>
                      </div>
                      
                      <% if (estaLogado) { %>
                          <div class="form-check mb-3">
                              <input class="form-check-input" type="checkbox" name="criarPost" id="checkCriarPost">
                              <label class="form-check-label" for="checkCriarPost">
                                  Publicar também no Blog
                              </label>
                          </div>
                      <% } %>
                        
                      <div class="mb-2">
                          <small class="text-muted">
                              Clique no mapa para selecionar a localização
                          </small>
                      </div>
                      
                      <div class="d-grid gap-2">
                          <button type="button" class="btn btn-primary" onclick="obterLocalizacao()">
                              Usar Minha Localização
                          </button>
                          
                          <% if (estaLogado) { %>
                              <button type="submit" class="btn btn-success">Salvar Registro</button>
                          <% } else { %>
                              <a href="login.jsp" class="btn btn-secondary">Faça login para registrar</a>
                          <% } %>
                      </div>
                  </form>
            </div>
            
           <div class="lista-registros">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5>Registros (<%= registros.size() %>)</h5>
        <% if (estaLogado) { %>
            <div class="btn-group btn-group-sm">
                <a href="mapa.jsp?filtro=todos" class="btn btn-outline-secondary <%= !"meus".equals(filtro) ? "active" : "" %>">Todos</a>
                <a href="mapa.jsp?filtro=meus" class="btn btn-outline-primary <%= "meus".equals(filtro) ? "active" : "" %>">Meus</a>
            </div>
        <% } %>
    </div>
    
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
            
            // Verifica se é do usuário logado
            boolean meuRegistro = estaLogado && registro.getUsuario() != null && 
                                 registro.getUsuario().getId().equals(usuario.getId());
        %>
            <div class="registro-item <%= "POSITIVO".equals(registro.getTipoRegistro().getCategoria()) ? "categoria-positivo" : "categoria-negativo" %> <%= meuRegistro ? "meu-registro" : "" %>"
                 onclick="mostrarNoMapa(<%= registro.getLatitude() %>, <%= registro.getLongitude() %>, '<%= registro.getTitulo().replace("'", "\\'") %>', '<%= registro.getDescricao().replace("'", "\\'") %>')">
                <div class="d-flex justify-content-between align-items-start">
                    <strong><%= registro.getTitulo() %></strong>
                    <% if (meuRegistro) { %>
                        <span class="badge bg-primary badge-sm">Meu</span>
                    <% } %>
                </div>
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
                    <% if (registro.getUsuario() != null) { %>
                        <small class="text-muted ms-2">
                            por <%= registro.getUsuario().getNome().split(" ")[0] %>
                        </small>
                    <% } %>
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
        var southWest = L.latLng(-23.65, -46.35);
        var northEast = L.latLng(-23.40, -46.00);
        var bounds = L.latLngBounds(southWest, northEast);
        var map = L.map('mapa', {
            center: [-23.5189, -46.1891], 
            zoom: 13,
            maxBounds: bounds,
            minZoom: 12,        
            maxZoom: 18          
        });

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        var marcadorSelecionado = null;
        var marcadoresRegistros = [];
        var marcadoresPorCoordenadas = {};

        function criarIconeRegistro(categoria) {
            var cor, simbolo, borderRadius;
            if (categoria === 'POSITIVO') {
                cor = '#27ae60'; 
                simbolo = '✓';
                borderRadius = '4px'; 
            } else {
                cor = '#e74c3c'; 
                simbolo = '⚠';
                borderRadius = '50%'; 
            }
            return L.divIcon({
                className: 'icone-registro',
                html: '<div style="background-color: ' + cor + '; width: 32px; height: 32px; border-radius: ' + borderRadius + '; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 16px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.4);">' + simbolo + '</div>',
                iconSize: [38, 38],
                iconAnchor: [19, 19],
                popupAnchor: [0, -19]
            });
        }

        function criarIconeSelecao() {
            return L.divIcon({
                className: 'icone-selecao',
                html: '<div style="background-color: #f39c12; width: 28px; height: 28px; border-radius: 4px; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 14px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.4); transform: rotate(45deg);">+</div>',
                iconSize: [34, 34],
                iconAnchor: [17, 17],
                popupAnchor: [0, -17]
            });
        }

        function criarIconeLocalizacao() {
            return L.divIcon({
                className: 'icone-localizacao',
                html: '<div style="background-color: #3498db; width: 24px; height: 24px; border-radius: 50%; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.4);">📍</div>',
                iconSize: [30, 30],
                iconAnchor: [15, 15],
                popupAnchor: [0, -15]
            });
        }

        <% for(Registro registro : registros) { %>
            var lat = <%= registro.getLatitude() %>;
            var lng = <%= registro.getLongitude() %>;
            var categoria = '<%= registro.getTipoRegistro().getCategoria() %>';
            var icone = criarIconeRegistro(categoria);

            var popupContent = 
                '<div class="popup-content">' +
                '<h6><%= registro.getTitulo().replace("'", "\\'") %></h6>' +
                '<img src="MostrarImagemServlet?id=<%= registro.getId() %>&tipo=registro" style="max-width: 100%; height: auto; border-radius: 4px; margin-bottom: 8px;" onerror="this.style.display=\'none\'">' +
                '<p><%= registro.getDescricao().replace("'", "\\'") %></p>' +
                '<div class="popup-details">' +
                '<small><strong>Tipo:</strong> <%= registro.getTipoRegistro().getNome() %></small><br>' +
                '<small><strong>Status:</strong> <%= registro.getStatus() %></small><br>' +
                '<small><strong>Data:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %></small><br>' +
                <% if (registro.getUsuario() != null) { %>
                    '<small><strong>Registrado por:</strong> <%= registro.getUsuario().getNome() %></small>' +
                <% } %>
                '</div>' +
                '</div>';

            var marcador = L.marker([lat, lng], {icon: icone})
                .addTo(map)
                .bindPopup(popupContent);

            marcadoresRegistros.push(marcador);
            marcadoresPorCoordenadas[lat.toFixed(6) + ',' + lng.toFixed(6)] = marcador;
        <% } %>

        map.on('click', function(e) {
            var lat = e.latlng.lat;
            var lng = e.latlng.lng;
            document.getElementById('inputLatitude').value = lat;
            document.getElementById('inputLongitude').value = lng;

            if (marcadorSelecionado) { map.removeLayer(marcadorSelecionado); }

            marcadorSelecionado = L.marker([lat, lng], { icon: criarIconeSelecao() }).addTo(map)
            .bindPopup('📍 Localização selecionada<br>Lat: ' + lat.toFixed(4) + '<br>Lng: ' + lng.toFixed(4))
            .openPopup();
        });

        function obterLocalizacao() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;
                    document.getElementById('inputLatitude').value = lat;
                    document.getElementById('inputLongitude').value = lng;

                    if (marcadorSelecionado) { map.removeLayer(marcadorSelecionado); }

                    marcadorSelecionado = L.marker([lat, lng], { icon: criarIconeLocalizacao() }).addTo(map)
                    .bindPopup('📍 Sua localização atual').openPopup();
                    map.setView([lat, lng], 15);
                }, function(error) { alert('Erro ao obter localização: ' + error.message); });
            } else { alert('Geolocalização não suportada.'); }
        }

        function focarNoFormulario() {
            const sidebar = document.getElementById("sidebar-main");
            const button = document.getElementById("btnNovoRegistro");
            if (button.textContent === 'Fechar') { button.textContent = 'Novo Registro'; } 
            else { button.textContent = 'Fechar'; }
            sidebar.classList.toggle('is-visible');
        }

        function mostrarNoMapa(lat, lng, titulo, descricao) {
            map.setView([lat, lng], 15);
            map.eachLayer(function(layer) {
                if (layer instanceof L.Marker) {
                    var markerLat = layer.getLatLng().lat;
                    var markerLng = layer.getLatLng().lng;
                    if (markerLat.toFixed(6) === lat.toFixed(6) && markerLng.toFixed(6) === lng.toFixed(6)) {
                        map.closePopup();
                        layer.openPopup();
                    }
                }
            });
        }
    </script>
</body>
</html>