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
    // Verificar se usuário está logado
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

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
                        <li class="nav-item"><a class="nav-link" href="blog.jsp">Blog</a></li>
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

        // Variáveis globais
        var marcadorSelecionado = null;

        // SISTEMA SIMPLIFICADO DE ÍCONES - 2 CORES E FORMATOS DIFERENTES
        function criarIconeRegistro(categoria) {
            var cor, simbolo, borderRadius;

            if (categoria === 'POSITIVO') {
                cor = '#27ae60'; // VERDE
                simbolo = '✓';
                borderRadius = '4px'; // Quadrado para positivos
            } else {
                cor = '#e74c3c'; // VERMELHO
                simbolo = '⚠';
                borderRadius = '50%'; // Círculo para negativos
            }

            return L.divIcon({
                className: 'icone-registro',
                html: '<div style="' +
                    'background-color: ' + cor + '; ' +
                    'width: 32px; ' +
                    'height: 32px; ' +
                    'border-radius: ' + borderRadius + '; ' +
                    'border: 3px solid white; ' +
                    'display: flex; ' +
                    'align-items: center; ' +
                    'justify-content: center; ' +
                    'color: white; ' +
                    'font-weight: bold; ' +
                    'font-size: 16px; ' +
                    'cursor: pointer; ' +
                    'box-shadow: 0 2px 8px rgba(0,0,0,0.4);' +
                    '">' + simbolo + '</div>',
                iconSize: [38, 38],
                iconAnchor: [19, 19],
                popupAnchor: [0, -19]
            });
        }

        // ÍCONE DIFERENTE PARA SELEÇÃO (CLIQUE NO MAPA)
        function criarIconeSelecao() {
            return L.divIcon({
                className: 'icone-selecao',
                html: `
                    <div style="
                        background-color: #f39c12; 
                        width: 28px; 
                        height: 28px; 
                        border-radius: 4px; 
                        border: 3px solid white;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: white;
                        font-weight: bold;
                        font-size: 14px;
                        cursor: pointer;
                        box-shadow: 0 2px 8px rgba(0,0,0,0.4);
                        transform: rotate(45deg);
                    ">+</div>
                `,
                iconSize: [34, 34],
                iconAnchor: [17, 17],
                popupAnchor: [0, -17]
            });
        }

        // ÍCONE DIFERENTE PARA LOCALIZAÇÃO
        function criarIconeLocalizacao() {
            return L.divIcon({
                className: 'icone-localizacao',
                html: `
                    <div style="
                        background-color: #3498db; 
                        width: 24px; 
                        height: 24px; 
                        border-radius: 50%; 
                        border: 3px solid white;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: white;
                        font-weight: bold;
                        font-size: 12px;
                        cursor: pointer;
                        box-shadow: 0 2px 8px rgba(0,0,0,0.4);
                    ">📍</div>
                `,
                iconSize: [30, 30],
                iconAnchor: [15, 15],
                popupAnchor: [0, -15]
            });
        }

        // Adicionar os registros existentes no mapa
        <% for(Registro registro : registros) { %>
            var lat = <%= registro.getLatitude() %>;
            var lng = <%= registro.getLongitude() %>;
            var categoria = '<%= registro.getTipoRegistro().getCategoria() %>';

            var icone = criarIconeRegistro(categoria);

            var marcador = L.marker([lat, lng], {icon: icone})
                .addTo(map)
                .bindPopup(
                   '<div class="popup-content">' +
                   '<h6><%= registro.getTitulo().replace("'", "\\'") %></h6>' +
                   '<img src="MostrarImagemServlet?id=<%= registro.getId() %>&tipo=registro" ' +
                   'style="max-width: 100%; height: auto; border-radius: 4px; margin-bottom: 8px;" ' +
                   'onerror="this.style.display=\'none\'">' +
                   '<p><%= registro.getDescricao().replace("'", "\\'") %></p>' +
                   '<div class="popup-details">' +
                   '<small><strong>Tipo:</strong> <%= registro.getTipoRegistro().getNome() %></small><br>' +
                   '<small><strong>Status:</strong> <%= registro.getStatus() %></small><br>' +
                   '<small><strong>Data:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %></small>' +
                   '</div>' +
                   '</div>'
               );
        <% } %>

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

            marcadorSelecionado = L.marker([lat, lng], {
                icon: criarIconeSelecao()
            }).addTo(map)
            .bindPopup('📍 Localização selecionada<br>Lat: ' + lat.toFixed(4) + '<br>Lng: ' + lng.toFixed(4))
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

                                // Adiciona marcador na localização atual com ícone personalizado
                    marcadorSelecionado = L.marker([lat, lng], {
                        icon: criarIconeLocalizacao()
                    }).addTo(map)
                    .bindPopup('📍 Sua localização atual')
                    .openPopup();

                    map.setView([lat, lng], 15);
                }, function(error) {
                    alert('Erro ao obter localização: ' + error.message);
                });
            } else {
                alert('Geolocalização não é suportada por este navegador.');
            }
        }

        // Função para focar no formulário
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

        // Função para mostrar registro no mapa
        function mostrarNoMapa(lat, lng, titulo, descricao) {
            map.setView([lat, lng], 15);

            // Encontrar e abrir o marcador existente
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