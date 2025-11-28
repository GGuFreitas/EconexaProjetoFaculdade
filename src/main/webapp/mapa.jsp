<%-- 
    Document   : mapa
    Created on : 20 de out. de 2025, 19:40:41
    Author     : gufre
    Descrição  : Página principal do mapa interativo da ECONEXA
                Permite visualizar registros ambientais, adicionar novos registros
                e filtrar por usuário. Integra com Leaflet para mapas e Font Awesome para ícones.
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
    // SEÇÃO: VERIFICAÇÃO DE AUTENTICAÇÃO DO USUÁRIO
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    
    boolean estaLogado = (usuario != null);
    String nomeExibicao = "Convidado";
    
    if (estaLogado) {
        String nomeCompleto = usuario.getNome();
        nomeExibicao = nomeCompleto.split(" ")[0];
    }
%>

<%
    // SEÇÃO: CARREGAMENTO DE DADOS E FILTROS
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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="resources/css/leaflet.css" rel="stylesheet" type="text/css"/>
    <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>

    <link href="resources/css/mapa.css" rel="stylesheet" type="text/css"/>
    
    <link href="resources/css/style-index.css" rel="stylesheet" type="text/css"/>
</head>
<body>
    <!-- SEÇÃO: CABEÇALHO E NAVEGAÇÃO  -->
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

    <!-- SEÇÃO: ALERTAS DO SISTEMA -->
    <% if (sucesso != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= sucesso %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if (erro != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i><%= erro %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- SEÇÃO: CONTAINER PRINCIPAL DO MAPA -->
    <div id="mapa-container">
        <!-- Mapa Leaflet -->
        <div id="mapa"></div>
        
        <!-- SIDEBAR - CONTROLES E LISTA DE REGISTROS -->
        <div class="sidebar" id="sidebar-main">
            
            <!-- FORMULÁRIO DE NOVO REGISTRO -->
            <div class="form-novo-registro">
                  <h5><i class="fas fa-plus-circle me-2"></i>Novo Registro</h5>
                  <form method="POST" action="SalvarRegistroServlet" id="formRegistro" enctype="multipart/form-data">
                      <input type="hidden" name="latitude" id="inputLatitude">
                      <input type="hidden" name="longitude" id="inputLongitude">

                      <div class="mb-2">
                          <label class="form-label"><i class="fas fa-heading me-1"></i>Título</label>
                          <input type="text" class="form-control" name="titulo" placeholder="Digite o título" required>
                      </div>
                      <div class="mb-2">
                          <label class="form-label"><i class="fas fa-align-left me-1"></i>Descrição</label>
                          <textarea class="form-control" name="descricao" placeholder="Descreva o registro" rows="2"></textarea>
                      </div>
                      <div class="mb-2">
                          <label class="form-label"><i class="fas fa-tag me-1"></i>Tipo</label>
                          <select class="form-select" name="tipoRegistroId" required>
                              <option value="">Selecione o tipo</option>
                              <% for(TipoRegistro tipo : tiposRegistro) { %>
                                  <option value="<%= tipo.getId() %>" data-icone="<%= tipo.getIcone() != null ? tipo.getIcone() : "" %>">
                                      <i class="fas <%= tipo.getIcone() != null ? tipo.getIcone() : "fa-map-marker" %> me-2"></i>
                                      <%= tipo.getNome() %>
                                  </option>
                              <% } %>
                          </select>
                      </div>
                      
                      <div class="mb-2">
                            <label class="form-label"><i class="fas fa-camera me-1"></i>Foto (Opcional)</label>
                            <input type="file" class="form-control" name="foto" id="inputFoto" accept="image/*" capture="environment">
                            <small class="text-muted">Você pode tirar uma foto ou escolher da galeria</small>
                      </div>
                      
                      <% if (estaLogado) { %>
                          <div class="form-check mb-3">
                              <input class="form-check-input" type="checkbox" name="criarPost" id="checkCriarPost">
                              <label class="form-check-label" for="checkCriarPost">
                                  <i class="fas fa-blog me-1"></i>Publicar também no Blog
                              </label>
                          </div>
                      <% } %>
                        
                      <div class="mb-2">
                          <small class="text-muted">
                              <i class="fas fa-map-marker-alt me-1"></i>Clique no mapa para selecionar a localização
                          </small>
                      </div>
                      
                      <div class="d-grid gap-2">
                          <button type="button" class="btn btn-primary" onclick="obterLocalizacao()">
                              <i class="fas fa-location-arrow me-1"></i>Usar Minha Localização
                          </button>
                          
                          <% if (estaLogado) { %>
                              <button type="submit" class="btn btn-success">
                                  <i class="fas fa-save me-1"></i>Salvar Registro
                              </button>
                          <% } else { %>
                              <a href="login.jsp" class="btn btn-secondary">
                                  <i class="fas fa-sign-in-alt me-1"></i>Faça login para registrar
                              </a>
                          <% } %>
                      </div>
                  </form>
            </div>
            
            <!-- LISTA DE REGISTROS EXISTENTES -->
           <div class="lista-registros">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5><i class="fas fa-list me-2"></i>Registros (<%= registros.size() %>)</h5>
                    <% if (estaLogado) { %>
                        <div class="btn-group btn-group-sm">
                            <a href="mapa.jsp?filtro=todos" class="btn btn-outline-secondary <%= !"meus".equals(filtro) ? "active" : "" %>">
                                Todos
                            </a>
                            <a href="mapa.jsp?filtro=meus" class="btn btn-outline-primary <%= "meus".equals(filtro) ? "active" : "" %>">
                                Meus
                            </a>
                        </div>
                    <% } %>
                </div>
                
                <div id="lista-registros-container">
                    <% for(Registro registro : registros) { 
                        // Determina a classe do badge baseado no status
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
                        
                        // Obtém o ícone do tipo de registro
                        String iconeRegistro = registro.getTipoRegistro().getIcone() != null ? 
                                             registro.getTipoRegistro().getIcone() : "fa-map-marker-alt";
                    %>
                        <div class="registro-item <%= "POSITIVO".equals(registro.getTipoRegistro().getCategoria()) ? "categoria-positivo" : "categoria-negativo" %> <%= meuRegistro ? "meu-registro" : "" %>"
                             onclick="mostrarNoMapa(<%= registro.getLatitude() %>, <%= registro.getLongitude() %>, '<%= registro.getTitulo().replace("'", "\\'") %>', '<%= registro.getDescricao().replace("'", "\\'") %>')">
                            <div class="d-flex justify-content-between align-items-start">
                                <strong>
                                    <i class="fas <%= iconeRegistro %> me-2"></i>
                                    <%= registro.getTitulo() %>
                                </strong>
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
                                    <i class="fas 
                                        <% if ("PENDENTE".equals(registro.getStatus())) { %>
                                            fa-clock
                                        <% } else if ("RESOLVIDO".equals(registro.getStatus())) { %>
                                            fa-check
                                        <% } else { %>
                                            fa-info-circle
                                        <% } %>
                                    me-1"></i>
                                    <%= registro.getStatus() %>
                                </span>
                                <% if (registro.getUsuario() != null) { %>
                                    <small class="text-muted ms-2">
                                        <i class="fas fa-user me-1"></i>por <%= registro.getUsuario().getNome().split(" ")[0] %>
                                    </small>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!--  BOTÃO FLUTUANTE PARA NOVO REGISTRO -->
        <button class="btn-flutuante" id="btnNovoRegistro" title="Novo Registro" onclick="focarNoFormulario()">
            <i class="fas fa-plus me-2"></i>Novo Registro
        </button>
    </div>

    
    <script src="resources/js/leaflet.js" type="text/javascript"></script>
    <script src="resources/js/bootstrap.js"></script>
    
    <script>
        // CONFIGURAÇÃO INICIAL DO MAPA LEAFLET
        var southWest = L.latLng(-23.65, -46.35);
        var northEast = L.latLng(-23.40, -46.00);
        var bounds = L.latLngBounds(southWest, northEast);
        
        // Inicializa o mapa com view em São Paulo
        var map = L.map('mapa', {
            center: [-23.5189, -46.1891], // Centro de São Paulo
            zoom: 13,
            maxBounds: bounds,
            minZoom: 12,        // Zoom mínimo para evitar afastamento
            maxZoom: 18         // Zoom máximo para evitar aproximação excessiva
        });

        // Adiciona layer do OpenStreetMap
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        // 
        // VARIÁVEIS GLOBAIS PARA CONTROLE DOS MARCADORES
        // 
        var marcadorSelecionado = null;
        var marcadoresRegistros = [];
        var marcadoresPorCoordenadas = {};

        /**
         * Cria ícone personalizado para marcadores no mapa
         * @param {string} categoria - Categoria do registro (POSITIVO/NEGATIVO)
         * @param {string} iconeNome - Nome da classe do Font Awesome
         * @returns {L.DivIcon} Ícone personalizado para o marcador
         */
        function criarIconeRegistro(categoria, iconeNome) {
            var cor, iconeClass, borderRadius;
            
            // Define cores e estilos baseados na categoria
            if (categoria === 'POSITIVO') {
                cor = '#27ae60'; // Verde para positivos
                iconeClass = obterIcone(iconeNome, categoria);
                borderRadius = '4px'; // Formato quadrado com bordas arredondadas
            } else {
                cor = '#e74c3c'; // Vermelho para negativos
                iconeClass = obterIcone(iconeNome, categoria);
                borderRadius = '50%'; // Formato circular
            }
            
            return L.divIcon({
                className: 'icone-registro',
                html: '<div style="background-color: ' + cor + '; width: 32px; height: 32px; border-radius: ' + borderRadius + '; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-size: 14px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.4);">' +
                      '<i class="fas ' + iconeClass + '"></i>' +
                      '</div>',
                iconSize: [38, 38],
                iconAnchor: [19, 19],
                popupAnchor: [0, -19]
            });
        }

        // 
        // FUNÇÃO: FALLBACK PARA ÍCONES AUSENTES
        // 
        /**
         * Garante que sempre haja um ícone válido, usando fallbacks quando necessário
         * @param {string} iconeNome - Nome original do ícone
         * @param {string} categoria - Categoria do registro
         * @returns {string} Nome da classe do ícone válida
         */
        function obterIcone(iconeNome, categoria) {
            if (!iconeNome || iconeNome.trim() === '') {
                // Fallbacks baseados na categoria
                return categoria === 'POSITIVO' ? 'fa-check' : 'fa-exclamation-triangle';
            }
            return iconeNome;
        }

        // 
        // FUNÇÃO: CRIAR ÍCONE PARA SELEÇÃO DE LOCALIZAÇÃO
        // 
        function criarIconeSelecao() {
            return L.divIcon({
                className: 'icone-selecao',
                html: '<div style="background-color: #f39c12; width: 28px; height: 28px; border-radius: 4px; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 14px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.4); transform: rotate(45deg);">+</div>',
                iconSize: [34, 34],
                iconAnchor: [17, 17],
                popupAnchor: [0, -17]
            });
        }

        // 
        // FUNÇÃO: CRIAR ÍCONE PARA LOCALIZAÇÃO ATUAL
        // 
        function criarIconeLocalizacao() {
            return L.divIcon({
                className: 'icone-localizacao',
                html: '<div style="background-color: #3498db; width: 24px; height: 24px; border-radius: 50%; border: 3px solid white; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 12px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.4);">📍</div>',
                iconSize: [30, 30],
                iconAnchor: [15, 15],
                popupAnchor: [0, -15]
            });
        }

        // 
        // LOOP PARA CRIAR MARCADORES DOS REGISTROS EXISTENTES
        // 
        <% for(Registro registro : registros) { %>
            var lat = <%= registro.getLatitude() %>;
            var lng = <%= registro.getLongitude() %>;
            var categoria = '<%= registro.getTipoRegistro().getCategoria() %>';
            var iconeNome = '<%= registro.getTipoRegistro().getIcone() != null ? registro.getTipoRegistro().getIcone() : "" %>';
            var icone = criarIconeRegistro(categoria, iconeNome);

            // Conteúdo do popup com informações completas do registro
            var popupContent = 
                '<div class="popup-content">' +
                '<h6><i class="fas ' + iconeNome + ' me-2"></i><%= registro.getTitulo().replace("'", "\\'") %></h6>' +
                '<img src="MostrarImagemServlet?id=<%= registro.getId() %>&tipo=registro" style="max-width: 100%; height: auto; border-radius: 4px; margin-bottom: 8px;" onerror="this.style.display=\'none\'">' +
                '<p><%= registro.getDescricao().replace("'", "\\'") %></p>' +
                '<div class="popup-details">' +
                '<small><strong>Tipo:</strong> <i class="fas ' + iconeNome + ' me-1"></i><%= registro.getTipoRegistro().getNome() %></small><br>' +
                '<small><strong>Status:</strong> <%= registro.getStatus() %></small><br>' +
                '<small><strong>Data:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %></small><br>' +
                <% if (registro.getUsuario() != null) { %>
                    '<small><strong>Registrado por:</strong> <%= registro.getUsuario().getNome() %></small>' +
                <% } %>
                '</div>' +
                '</div>';

            // Cria e adiciona o marcador ao mapa
            var marcador = L.marker([lat, lng], {icon: icone})
                .addTo(map)
                .bindPopup(popupContent);

            // Armazena referências para controle
            marcadoresRegistros.push(marcador);
            marcadoresPorCoordenadas[lat.toFixed(6) + ',' + lng.toFixed(6)] = marcador;
        <% } %>

        // EVENTO: CLIQUE NO MAPA PARA SELEÇÃO DE LOCALIZAÇÃO
        // 
        map.on('click', function(e) {
            var lat = e.latlng.lat;
            var lng = e.latlng.lng;
            
            // Preenche os campos hidden do formulário
            document.getElementById('inputLatitude').value = lat;
            document.getElementById('inputLongitude').value = lng;

            // Remove marcador anterior se existir
            if (marcadorSelecionado) { 
                map.removeLayer(marcadorSelecionado); 
            }

            // Cria novo marcador na posição clicada
            marcadorSelecionado = L.marker([lat, lng], { icon: criarIconeSelecao() }).addTo(map)
            .bindPopup('📍 Localização selecionada<br>Lat: ' + lat.toFixed(4) + '<br>Lng: ' + lng.toFixed(4))
            .openPopup();
        });

        // FUNÇÃO: OBTER LOCALIZAÇÃO ATUAL DO USUÁRIO
        // 
        function obterLocalizacao() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;
                    
                    // Preenche os campos do formulário
                    document.getElementById('inputLatitude').value = lat;
                    document.getElementById('inputLongitude').value = lng;

                    // Remove marcador anterior se existir
                    if (marcdorSelecionado) { 
                        map.removeLayer(marcadorSelecionado); 
                    }

                    // Cria marcador na localização atual
                    marcadorSelecionado = L.marker([lat, lng], { icon: criarIconeLocalizacao() }).addTo(map)
                    .bindPopup('📍 Sua localização atual').openPopup();
                    
                    // Centraliza o mapa na localização
                    map.setView([lat, lng], 15);
                    
                }, function(error) { 
                    alert('Erro ao obter localização: ' + error.message); 
                });
            } else { 
                alert('Geolocalização não suportada pelo seu navegador.'); 
            }
        }

        // FUNÇÃO: TOGGLE DA SIDEBAR (FORMULÁRIO)
        function focarNoFormulario() {
            const sidebar = document.getElementById("sidebar-main");
            const button = document.getElementById("btnNovoRegistro");
            
            // Alterna texto do botão
            if (button.textContent.includes('Fechar')) { 
                button.innerHTML = '<i class="fas fa-plus me-2"></i>Novo Registro'; 
            } else { 
                button.innerHTML = '<i class="fas fa-times me-2"></i>Fechar'; 
            }
            
            // Alterna visibilidade da sidebar
            sidebar.classList.toggle('is-visible');
        }

        
        /**
         * Centraliza o mapa em um registro específico e abre seu popup
         * @param {number} lat - Latitude do registro
         * @param {number} lng - Longitude do registro
         * @param {string} titulo - Título do registro (para debug)
         * @param {string} descricao - Descrição do registro (para debug)
         */
        function mostrarNoMapa(lat, lng, titulo, descricao) {
            // Centraliza o mapa na localização do registro
            map.setView([lat, lng], 15);
            
            // Procura e abre o popup do marcador correspondente
            map.eachLayer(function(layer) {
                if (layer instanceof L.Marker) {
                    var markerLat = layer.getLatLng().lat;
                    var markerLng = layer.getLatLng().lng;
                    
                    // Compara coordenadas com precisão de 6 casas decimais
                    if (markerLat.toFixed(6) === lat.toFixed(6) && markerLng.toFixed(6) === lng.toFixed(6)) {
                        map.closePopup(); // Fecha popups abertos
                        layer.openPopup(); // Abre popup do marcador
                    }
                }
            });
        }
    </script>
</body>
</html>