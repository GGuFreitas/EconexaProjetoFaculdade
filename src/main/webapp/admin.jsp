<%-- 
    Document   : admin
    Created on : 20 de out. de 2025, 19:53:09
    Author     : gufre
--%>

<%@page import="com.mycompany.econexaadilson.model.DAO.RegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.TipoRegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Registro"%>
<%@page import="com.mycompany.econexaadilson.model.TipoRegistro"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%
       
    
    // Processamento de ações
    String acao = request.getParameter("acao");
    String tipoAcao = request.getParameter("tipoAcao");
    
    // Processar ações de Registro
    if ("registro".equals(tipoAcao)) {
        if ("inserir".equals(acao)) {
            try {
                Registro registro = new Registro();
                registro.setTitulo(request.getParameter("titulo"));
                registro.setDescricao(request.getParameter("descricao"));
                registro.setData(new Date());
                registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
                registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
                registro.setStatus(request.getParameter("status"));
                
                Long tipoRegistroId = Long.parseLong(request.getParameter("tipoRegistroId"));
                TipoRegistro tipoRegistro = new TipoRegistroDAO().buscarPorId(tipoRegistroId);
                registro.setTipoRegistro(tipoRegistro);
                
                new RegistroDAO().inserir(registro);
                response.sendRedirect("admin.jsp?sucesso=Registro criado com sucesso!");
                return;
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?erro=Erro ao criar registro: " + e.getMessage());
                return;
            }
        } else if ("atualizar".equals(acao)) {
            try {
                Registro registro = new Registro();
                registro.setId(Long.parseLong(request.getParameter("id")));
                registro.setTitulo(request.getParameter("titulo"));
                registro.setDescricao(request.getParameter("descricao"));
                registro.setData(new Date());
                registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
                registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
                registro.setStatus(request.getParameter("status"));
                
                Long tipoRegistroId = Long.parseLong(request.getParameter("tipoRegistroId"));
                TipoRegistro tipoRegistro = new TipoRegistroDAO().buscarPorId(tipoRegistroId);
                registro.setTipoRegistro(tipoRegistro);
                
                new RegistroDAO().atualizar(registro);
                response.sendRedirect("admin.jsp?sucesso=Registro atualizado com sucesso!");
                return;
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?erro=Erro ao atualizar registro: " + e.getMessage());
                return;
            }
        } else if ("excluir".equals(acao)) {
            try {
                Long id = Long.parseLong(request.getParameter("id"));
                new RegistroDAO().excluir(id);
                response.sendRedirect("admin.jsp?sucesso=Registro excluído com sucesso!");
                return;
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?erro=Erro ao excluir registro: " + e.getMessage());
                return;
            }
        }
    }
    
    // Processar ações de Tipo de Registro
    if ("tipo".equals(tipoAcao)) {
        if ("inserir".equals(acao)) {
            try {
                TipoRegistro tipo = new TipoRegistro();
                tipo.setNome(request.getParameter("nome"));
                tipo.setCategoria(request.getParameter("categoria"));
                tipo.setDescricao(request.getParameter("descricao"));
                tipo.setIcone(request.getParameter("icone"));
                
                new TipoRegistroDAO().inserir(tipo);
                response.sendRedirect("admin.jsp?sucesso=Tipo de registro criado com sucesso!");
                return;
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?erro=Erro ao criar tipo de registro: " + e.getMessage());
                return;
            }
        } else if ("atualizar".equals(acao)) {
            try {
                TipoRegistro tipo = new TipoRegistro();
                tipo.setId(Long.parseLong(request.getParameter("id")));
                tipo.setNome(request.getParameter("nome"));
                tipo.setCategoria(request.getParameter("categoria"));
                tipo.setDescricao(request.getParameter("descricao"));
                tipo.setIcone(request.getParameter("icone"));
                
                new TipoRegistroDAO().atualizar(tipo);
                response.sendRedirect("admin.jsp?sucesso=Tipo de registro atualizado com sucesso!");
                return;
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?erro=Erro ao atualizar tipo de registro: " + e.getMessage());
                return;
            }
        } else if ("excluir".equals(acao)) {
            try {
                Long id = Long.parseLong(request.getParameter("id"));
                new TipoRegistroDAO().excluir(id);
                response.sendRedirect("admin.jsp?sucesso=Tipo de registro excluído com sucesso!");
                return;
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?erro=Erro ao excluir tipo de registro: " + e.getMessage());
                return;
            }
        }
    }

    // Carregar dados
    RegistroDAO registroDAO = new RegistroDAO();
    TipoRegistroDAO tipoRegistroDAO = new TipoRegistroDAO();
    List<Registro> registros = registroDAO.listarTodos();
    List<TipoRegistro> tiposRegistro = tipoRegistroDAO.listarTodos();
    
    // Parâmetros para edição
    String editId = request.getParameter("editId");
    String editType = request.getParameter("editType");
    Registro registroEdit = null;
    TipoRegistro tipoEdit = null;
    
    if (editId != null && !editId.isEmpty()) {
        if ("registro".equals(editType)) {
            registroEdit = registroDAO.buscarPorId(Long.parseLong(editId));
        } else if ("tipo".equals(editType)) {
            tipoEdit = tipoRegistroDAO.buscarPorId(Long.parseLong(editId));
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ECONEXA - Administração</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
    <link href="resources/css/admin.css" rel="stylesheet" type="text/css"/>
</head>
<body  class="admin-body">
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
                        <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                        <li class="nav-item"><a class="nav-link" href="mapa.jsp">Mapa</a></li>
                        <li class="nav-item"><a class="nav-link active" href="admin.jsp">Gerenciar</a></li>
                        <li class="nav-item"><a class="nav-link" href="#">Blog</a></li>
                        <li class="nav-item"><a class="nav-link" href="#">Revista</a></li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>

    <div class="admin-container">
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

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1>Gerenciamento ECONEXA</h1>
        </div>

        <!-- Formulários de Cadastro -->
        <div class="row mb-4">
            <!-- Formulário de Registro -->
            <div class="col-md-6">
                <div class="form-section">
                    <h4><%= registroEdit != null ? "Editar Registro" : "Novo Registro" %></h4>
                    <form method="POST" action="admin.jsp">
                        <input type="hidden" name="tipoAcao" value="registro">
                        <input type="hidden" name="acao" value="<%= registroEdit != null ? "atualizar" : "inserir" %>">
                        <% if (registroEdit != null) { %>
                            <input type="hidden" name="id" value="<%= registroEdit.getId() %>">
                        <% } %>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Título</label>
                                    <input type="text" class="form-control" name="titulo" 
                                           value="<%= registroEdit != null ? registroEdit.getTitulo() : "" %>" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Tipo de Registro</label>
                                    <select class="form-select" name="tipoRegistroId" required>
                                        <option value="">Selecione o tipo</option>
                                        <% for(TipoRegistro tipo : tiposRegistro) { %>
                                            <% if (registroEdit != null && registroEdit.getTipoRegistro() != null) { %>
                                                <option value="<%= tipo.getId() %>" 
                                                    <%= registroEdit.getTipoRegistro().getId().equals(tipo.getId()) ? "selected" : "" %>>
                                                    <%= tipo.getNome() %>
                                                </option>
                                            <% } else { %>
                                                <option value="<%= tipo.getId() %>"><%= tipo.getNome() %></option>
                                            <% } %>
                                        <% } %>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Descrição</label>
                            <textarea class="form-control" name="descricao" rows="3"><%= registroEdit != null ? registroEdit.getDescricao() : "" %></textarea>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label class="form-label">Latitude</label>
                                    <input type="number" step="any" class="form-control" name="latitude" 
                                           value="<%= registroEdit != null ? registroEdit.getLatitude() : "" %>" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label class="form-label">Longitude</label>
                                    <input type="number" step="any" class="form-control" name="longitude" 
                                           value="<%= registroEdit != null ? registroEdit.getLongitude() : "" %>" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <select class="form-select" name="status" required>
                                        <option value="PENDENTE" <%= registroEdit != null && "PENDENTE".equals(registroEdit.getStatus()) ? "selected" : "" %>>Pendente</option>
                                        <option value="EM_ANDAMENTO" <%= registroEdit != null && "EM_ANDAMENTO".equals(registroEdit.getStatus()) ? "selected" : "" %>>Em Andamento</option>
                                        <option value="RESOLVIDO" <%= registroEdit != null && "RESOLVIDO".equals(registroEdit.getStatus()) ? "selected" : "" %>>Resolvido</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary">
                                <%= registroEdit != null ? "Atualizar Registro" : "Cadastrar Registro" %>
                            </button>
                            <% if (registroEdit != null) { %>
                                <a href="admin.jsp" class="btn btn-secondary">Cancelar Edição</a>
                            <% } %>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- Formulário de Tipo de Registro -->
            <div class="col-md-6">
                <div class="form-section">
                    <h4><%= tipoEdit != null ? "Editar Tipo de Registro" : "Novo Tipo de Registro" %></h4>
                    <form method="POST" action="admin.jsp">
                        <input type="hidden" name="tipoAcao" value="tipo">
                        <input type="hidden" name="acao" value="<%= tipoEdit != null ? "atualizar" : "inserir" %>">
                        <% if (tipoEdit != null) { %>
                            <input type="hidden" name="id" value="<%= tipoEdit.getId() %>">
                        <% } %>
                        
                        <div class="mb-3">
                            <label class="form-label">Nome</label>
                            <input type="text" class="form-control" name="nome" 
                                   value="<%= tipoEdit != null ? tipoEdit.getNome() : "" %>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Categoria</label>
                            <select class="form-select" name="categoria" required>
                                <option value="POSITIVO" <%= tipoEdit != null && "POSITIVO".equals(tipoEdit.getCategoria()) ? "selected" : "" %>>Positivo</option>
                                <option value="NEGATIVO" <%= tipoEdit != null && "NEGATIVO".equals(tipoEdit.getCategoria()) ? "selected" : "" %>>Negativo</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Descrição</label>
                            <textarea class="form-control" name="descricao" rows="3"><%= tipoEdit != null ? tipoEdit.getDescricao() : "" %></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Ícone</label>
                            <input type="text" class="form-control" name="icone" 
                                   value="<%= tipoEdit != null ? tipoEdit.getIcone() : "" %>" 
                                   placeholder="Ex: leaf, users, alert-triangle">
                        </div>
                        
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-success">
                                <%= tipoEdit != null ? "Atualizar Tipo" : "Cadastrar Tipo" %>
                            </button>
                            <% if (tipoEdit != null) { %>
                                <a href="admin.jsp" class="btn btn-secondary">Cancelar Edição</a>
                            <% } %>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Listas de Dados -->
        <div class="row">
            <!-- Lista de Registros -->
            <div class="col-md-12 mb-4">
                <div class="form-section">
                    <h4>Registros Cadastrados (<%= registros.size() %>)</h4>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Título</th>
                                    <th>Descrição</th>
                                    <th>Tipo</th>
                                    <th>Categoria</th>
                                    <th>Status</th>
                                    <th>Coordenadas</th>
                                    <th>Data</th>
                                    <th>Ações</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for(Registro registro : registros) { %>
                                <tr>
                                    <td><%= registro.getId() %></td>
                                    <td><strong><%= registro.getTitulo() %></strong></td>
                                    <td><%= registro.getDescricao() != null ? registro.getDescricao() : "" %></td>
                                    <td><%= registro.getTipoRegistro().getNome() %></td>
                                    <td>
                                        <span class="badge <%= registro.getTipoRegistro().getCategoria().equals("POSITIVO") ? "badge-positivo" : "badge-negativo" %>">
                                            <%= registro.getTipoRegistro().getCategoria() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge bg-<%= registro.getStatus().equals("PENDENTE") ? "warning" : 
                                                               registro.getStatus().equals("RESOLVIDO") ? "success" : "info" %>">
                                            <%= registro.getStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <small><%= String.format("%.6f", registro.getLatitude()) %>, <%= String.format("%.6f", registro.getLongitude()) %></small>
                                    </td>
                                    <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(registro.getData()) %></td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="admin.jsp?editId=<%= registro.getId() %>&editType=registro" 
                                               class="btn btn-outline-primary btn-acao">Editar</a>
                                            <form method="POST" action="admin.jsp" style="display: inline;">
                                                <input type="hidden" name="tipoAcao" value="registro">
                                                <input type="hidden" name="acao" value="excluir">
                                                <input type="hidden" name="id" value="<%= registro.getId() %>">
                                                <button type="submit" class="btn btn-outline-danger btn-acao" 
                                                        onclick="return confirm('Tem certeza que deseja excluir este registro?')">
                                                    Excluir
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Lista de Tipos de Registro -->
            <div class="col-md-12">
                <div class="form-section">
                    <h4>Tipos de Registro (<%= tiposRegistro.size() %>)</h4>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Nome</th>
                                    <th>Categoria</th>
                                    <th>Descrição</th>
                                    <th>Ícone</th>
                                    <th>Ações</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for(TipoRegistro tipo : tiposRegistro) { %>
                                <tr>
                                    <td><%= tipo.getId() %></td>
                                    <td><strong><%= tipo.getNome() %></strong></td>
                                    <td>
                                        <span class="badge <%= tipo.getCategoria().equals("POSITIVO") ? "badge-positivo" : "badge-negativo" %>">
                                            <%= tipo.getCategoria() %>
                                        </span>
                                    </td>
                                    <td><%= tipo.getDescricao() != null ? tipo.getDescricao() : "" %></td>
                                    <td><%= tipo.getIcone() != null ? tipo.getIcone() : "" %></td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="admin.jsp?editId=<%= tipo.getId() %>&editType=tipo" 
                                               class="btn btn-outline-primary btn-acao">Editar</a>
                                            <form method="POST" action="admin.jsp" style="display: inline;">
                                                <input type="hidden" name="tipoAcao" value="tipo">
                                                <input type="hidden" name="acao" value="excluir">
                                                <input type="hidden" name="id" value="<%= tipo.getId() %>">
                                                <button type="submit" class="btn btn-outline-danger btn-acao" 
                                                        onclick="return confirm('Tem certeza que deseja excluir este tipo de registro?')">
                                                    Excluir
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="resources/js/bootstrap.js"></script>
</body>
</html>
