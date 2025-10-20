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
    <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
    <link href="resources/css/style-index.css" rel="stylesheet" type="text/css"/>
    <link href="resources/css/style-mapa.css" rel="stylesheet" type="text/css"/>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" />
</head>
<body>
    <header class="main-header">
        <nav class="navbar navbar-expand-md navbar-light bg-transparent main-header">
            <div class="container-fluid">
                <a class="navbar-brand" href="index.jsp">
                    <img src="resources/img/mini-logo.png" alt="ECONEXA" class="navbar-logo">
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar"
                    aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="mainNavbar">
                    <ul class="navbar-nav nav-pills mb-2 mb-lg-0">
                        <li class="nav-item"><a class="nav-link" href="index.html">Home</a></li>
                        <li class="nav-item"><a class="nav-link active" href="mapa.jsp">Mapa</a></li>
                        <li class="nav-item"><a class="nav-link" href="admin.jsp">Gerenciar</a></li>
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
        <div class="sidebar">
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
                <% for(Registro registro : registros) { %>
                    <div class="registro-item <%= registro.getTipoRegistro().getCategoria().equals("POSITIVO") ? "categoria-positivo" : "categoria-negativo" %>"
                         onclick="mostrarNoMapa(<%= registro.getLatitude() %>, <%= registro.getLongitude() %>)">
                        <strong><%= registro.getTitulo() %></strong>
                        <div class="mt-1">
                            <small class="text-muted">
                                <%= registro.getTipoRegistro().getNome() %> • 
                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %>
                            </small>
                        </div>
                        <div class="mt-1">
                            <span class="badge bg-<%= registro.getStatus().equals("PENDENTE") ? "warning" : 
                                               registro.getStatus().equals("RESOLVIDO") ? "success" : "info" %>">
                                <%= registro.getStatus() %>
                            </span>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
        
        <!-- Botão Flutuante -->
        <button class="btn-flutuante" id="btnNovoRegistro" title="Novo Registro" onclick="focarNoFormulario()">
            +
        </button>
    </div>

    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"></script>
    <script src="resources/js/bootstrap.js"></script>
    <script>
        // Variáveis globais
        let mapa;
        let marcadores = [];
        let localizacaoAtual = null;
        
        // Inicializar mapa
        function inicializarMapa() {
            mapa = L.map('mapa').setView([-23.5505, -46.6333], 13);
            
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(mapa);
            
            // Adicionar marcadores existentes
            <% for(Registro registro : registros) { %>
                adicionarMarcador(
                    <%= registro.getLatitude() %>,
                    <%= registro.getLongitude() %>,
                    '<%= registro.getTitulo().replace("'", "\\'") %>',
                    '<%= registro.getDescricao() != null ? registro.getDescricao().replace("'", "\\'") : "" %>',
                    '<%= registro.getTipoRegistro().getCategoria() %>',
                    '<%= registro.getTipoRegistro().getNome().replace("'", "\\'") %>',
                    '<%= registro.getData() %>',
                    '<%= registro.getStatus() %>'
                );
            <% } %>
            
            // Configurar evento de clique no mapa
            mapa.on('click', function(e) {
                localizacaoAtual = e.latlng;
                document.getElementById('inputLatitude').value = e.latlng.lat;
                document.getElementById('inputLongitude').value = e.latlng.lng;
                alert('Localização selecionada: ' + e.latlng.lat.toFixed(6) + ', ' + e.latlng.lng.toFixed(6));
            });
        }
        
        // Adicionar marcador no mapa
        function adicionarMarcador(lat, lng, titulo, descricao, categoria, tipo, data, status) {
            var cor = categoria === 'POSITIVO' ? '#28a745' : '#dc3545';
            var categoriaTexto = categoria === 'POSITIVO' ? '✅ Positivo' : '❌ Negativo';
            
            var icone = L.divIcon({
                className: 'custom-marker',
                html: '<div style="background-color: ' + cor + '; width: 20px; height: 20px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 5px rgba(0,0,0,0.2);"></div>',
                iconSize: [24, 24],
                iconAnchor: [12, 12]
            });
            
            var dataFormatada = new Date(data).toLocaleDateString();
            
            var popupContent = '<div>' +
                '<h6>' + titulo + '</h6>' +
                '<p>' + (descricao || 'Sem descrição') + '</p>' +
                '<small><strong>Tipo:</strong> ' + tipo + '</small><br>' +
                '<small><strong>Data:</strong> ' + dataFormatada + '</small><br>' +
                '<small><strong>Status:</strong> ' + status + '</small><br>' +
                '<small><strong>Categoria:</strong> ' + categoriaTexto + '</small>' +
                '</div>';
            
            var marcador = L.marker([lat, lng], { icon: icone })
                .addTo(mapa)
                .bindPopup(popupContent);
            
            marcadores.push(marcador);
        }
        
        // Obter localização do usuário
        function obterLocalizacao() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    function(position) {
                        localizacaoAtual = {
                            lat: position.coords.latitude,
                            lng: position.coords.longitude
                        };
                        document.getElementById('inputLatitude').value = localizacaoAtual.lat;
                        document.getElementById('inputLongitude').value = localizacaoAtual.lng;
                        mapa.setView([localizacaoAtual.lat, localizacaoAtual.lng], 15);
                        alert('Localização obtida: ' + localizacaoAtual.lat.toFixed(6) + ', ' + localizacaoAtual.lng.toFixed(6));
                    },
                    function(error) {
                        alert('Erro ao obter localização: ' + error.message);
                    }
                );
            } else {
                alert('Geolocalização não suportada pelo navegador');
            }
        }
        
        // Mostrar registro no mapa
        function mostrarNoMapa(lat, lng) {
            mapa.setView([lat, lng], 16);
        }
        
        // Focar no formulário
        function focarNoFormulario() {
            document.querySelector('.form-novo-registro').scrollIntoView({ 
                behavior: 'smooth' 
            });
        }
        
        // Filtrar marcadores
        function filtrarMarcadores() {
            var categoria = document.getElementById('filtro-categoria').value;
            var tipo = document.getElementById('filtro-tipo').value;
            
            marcadores.forEach(function(marcador) {
                var popupContent = marcador.getPopup().getContent();
                var isPositivo = popupContent.includes('✅ Positivo');
                var tipoNome = '';
                
                var tipoIndex = popupContent.indexOf('<strong>Tipo:</strong>');
                if (tipoIndex !== -1) {
                    var tipoText = popupContent.substring(tipoIndex + 20);
                    tipoNome = tipoText.split('<')[0].trim();
                }
                
                var mostrar = true;
                
                if (categoria !== 'TODOS') {
                    if (categoria === 'POSITIVO' && !isPositivo) mostrar = false;
                    if (categoria === 'NEGATIVO' && isPositivo) mostrar = false;
                }
                
                if (tipo !== 'TODOS') {
                    var tipoSelect = document.querySelector('#filtro-tipo option[value="' + tipo + '"]');
                    if (tipoSelect && tipoNome !== tipoSelect.textContent) {
                        mostrar = false;
                    }
                }
                
                if (mostrar) {
                    mapa.addLayer(marcador);
                } else {
                    mapa.removeLayer(marcador);
                }
            });
        }
        
        // Inicializar quando a página carregar
        document.addEventListener('DOMContentLoaded', function() {
            inicializarMapa();
            
            // Configurar eventos dos filtros
            document.getElementById('filtro-categoria').addEventListener('change', filtrarMarcadores);
            document.getElementById('filtro-tipo').addEventListener('change', filtrarMarcadores);
        });
    </script>
</body>
</html>