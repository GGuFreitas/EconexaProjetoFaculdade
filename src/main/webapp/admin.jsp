<%-- 
    Document   : admin.jsp
    Author     : gufre, jhonny
--%>

<%@page import="com.mycompany.econexaadilson.model.DAO.RegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.TipoRegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.UsuarioDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.RevistaPostDAO"%> <%@page import="com.mycompany.econexaadilson.model.Registro"%>
<%@page import="com.mycompany.econexaadilson.model.TipoRegistro"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page import="com.mycompany.econexaadilson.model.RevistaPost"%> <%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Date" %>

<%
    // Validação de Segurança
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null || !usuario.isAdmin()) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    
    // Instanciação dos DAOs
    RegistroDAO registroDAO = new RegistroDAO();
    TipoRegistroDAO tipoRegistroDAO = new TipoRegistroDAO();
    BlogDAO blogDAO = new BlogDAO();
    UsuarioDAO usuarioDAO = new UsuarioDAO();
    RevistaPostDAO revistaDAO = new RevistaPostDAO();

    // Lógica de Ações (CRUD)
    String acao = request.getParameter("acao");
    String tipoAcao = request.getParameter("tipoAcao");
    
    // LÓGICA REGISTROS
    if ("registro".equals(tipoAcao)) {
        if ("inserir".equals(acao) || "atualizar".equals(acao)) {
            try {
                Registro registro = new Registro();
                if ("atualizar".equals(acao)) {
                    registro.setId(Long.parseLong(request.getParameter("id")));
                }
                registro.setTitulo(request.getParameter("titulo"));
                registro.setDescricao(request.getParameter("descricao"));
                registro.setData(new Date());
                registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
                registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
                registro.setStatus(request.getParameter("status"));
                Long tipoRegistroId = Long.parseLong(request.getParameter("tipoRegistroId"));
                TipoRegistro tipoRegistro = tipoRegistroDAO.buscarPorId(tipoRegistroId);
                registro.setTipoRegistro(tipoRegistro);
                registro.setUsuario(usuario);
                Part filePart = request.getPart("foto");
                if (filePart != null && filePart.getSize() > 0) {
                    registro.setFotoStream(filePart.getInputStream());
                }
                boolean sucessoOperacao;
                if ("inserir".equals(acao)) {
                    sucessoOperacao = registroDAO.inserir(registro) != null;
                } else {
                    sucessoOperacao = registroDAO.atualizar(registro);
                }
                if (sucessoOperacao) {
                    response.sendRedirect("admin.jsp?tab=registros&sucesso=Registro " + ("inserir".equals(acao) ? "criado" : "atualizado") + "!"); 
                    return;
                } else {
                    response.sendRedirect("admin.jsp?tab=registros&erro=Erro ao " + ("inserir".equals(acao) ? "criar" : "atualizar") + " registro"); 
                    return;
                }
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?tab=registros&erro=" + e.getMessage()); 
                return;
            }
        } else if ("excluir".equals(acao)) {
            try {
                Long id = Long.parseLong(request.getParameter("id"));
                registroDAO.excluir(id);
                response.sendRedirect("admin.jsp?tab=registros&sucesso=Registro apagado!"); return;
            } catch (Exception e) {
                response.sendRedirect("admin.jsp?tab=registros&erro=" + e.getMessage()); return;
            }
        }
    }
    
    // LÓGICA TIPOS
    if ("tipo".equals(tipoAcao)) {
        if ("inserir".equals(acao)) {
             try {
                TipoRegistro t = new TipoRegistro();
                t.setNome(request.getParameter("nome"));
                t.setCategoria(request.getParameter("categoria"));
                t.setDescricao(request.getParameter("descricao"));
                t.setIcone(request.getParameter("icone"));
                tipoRegistroDAO.inserir(t);
                response.sendRedirect("admin.jsp?tab=tipos&sucesso=Categoria criada!"); return;
             } catch(Exception e) { response.sendRedirect("admin.jsp?tab=tipos&erro=" + e.getMessage()); return; }
        } else if ("atualizar".equals(acao)) {
             try {
                TipoRegistro t = new TipoRegistro();
                t.setId(Long.parseLong(request.getParameter("id")));
                t.setNome(request.getParameter("nome"));
                t.setCategoria(request.getParameter("categoria"));
                t.setDescricao(request.getParameter("descricao"));
                t.setIcone(request.getParameter("icone"));
                tipoRegistroDAO.atualizar(t);
                response.sendRedirect("admin.jsp?tab=tipos&sucesso=Categoria atualizada!"); return;
             } catch(Exception e) { response.sendRedirect("admin.jsp?tab=tipos&erro=" + e.getMessage()); return; }
        } else if ("excluir".equals(acao)) {
             try {
                tipoRegistroDAO.excluir(Long.parseLong(request.getParameter("id")));
                response.sendRedirect("admin.jsp?tab=tipos&sucesso=Categoria apagada!"); return;
             } catch(Exception e) { response.sendRedirect("admin.jsp?tab=tipos&erro=" + e.getMessage()); return; }
        }
    }
    
    // LÓGICA BLOG
    if ("blog".equals(tipoAcao)) {
        if ("excluir".equals(acao)) {
            try {
                blogDAO.excluir(Long.parseLong(request.getParameter("id")));
                response.sendRedirect("admin.jsp?tab=blog&sucesso=Post apagado!"); return;
            } catch(Exception e) {
                response.sendRedirect("admin.jsp?tab=blog&erro=" + e.getMessage()); return;
            }
        }
    }

    // LÓGICA REVISTA
    if ("revista".equals(tipoAcao)) {
        if ("excluir".equals(acao)) {
            try {
                revistaDAO.excluir(Long.parseLong(request.getParameter("id")));
                response.sendRedirect("admin.jsp?tab=revista&sucesso=Artigo da revista apagado!"); return;
            } catch(Exception e) {
                response.sendRedirect("admin.jsp?tab=revista&erro=" + e.getMessage()); return;
            }
        }
    }

    // Carregamento das Listas
    List<Registro> registros = registroDAO.listarTodos();
    List<TipoRegistro> tiposRegistro = tipoRegistroDAO.listarTodos();
    List<Blog> posts = blogDAO.listarTodosAdmin();
    List<Usuario> usuariosAtivos = usuarioDAO.listarAtivos();
    List<RevistaPost> revistaPosts = revistaDAO.listarTodos(); // Carrega artigos da revista
    
    // Controle de Abas
    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "registros";

    // Controle de Edição Server-Side
    String editId = request.getParameter("editId");
    String editType = request.getParameter("editType");
    
    Registro registroEdit = null;
    TipoRegistro tipoEdit = null;
    Blog blogEdit = null;
    RevistaPost revistaEdit = null; // Objeto para edição da revista
    
    if (editId != null && !editId.isEmpty()) {
        if ("registro".equals(editType)) { 
            registroEdit = registroDAO.buscarPorId(Long.parseLong(editId));
            activeTab = "registros";
        }
        if ("tipo".equals(editType)) {
            tipoEdit = tipoRegistroDAO.buscarPorId(Long.parseLong(editId));
            activeTab = "tipos";
        }
        if ("blog".equals(editType)) {
            blogEdit = blogDAO.buscarPorId(Long.parseLong(editId));
            activeTab = "blog";
        }
        if ("revista".equals(editType)) { // Carrega dados para edição da revista
            revistaEdit = revistaDAO.buscarPorId(Long.parseLong(editId));
            activeTab = "revista";
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ECONEXA - Painel Admin</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
    <link href="resources/css/admin.css" rel="stylesheet" type="text/css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        .sidebar-right {
            position: fixed;
            top: 0;
            right: -400px;
            width: 400px;
            height: 100vh;
            background: white;
            box-shadow: -2px 0 10px rgba(0,0,0,0.1);
            transition: right 0.3s ease-in-out;
            z-index: 1050;
            padding: 20px;
            overflow-y: auto;
            border-left: 1px solid #ddd;
        }
        .sidebar-right.is-visible {
            right: 0;
        }
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0,0,0,0.5);
            z-index: 1040;
        }
        .sidebar-overlay.is-visible {
            display: block;
        }
        .table td, .table th {
            vertical-align: middle;
        }
    </style>
</head>
<body class="admin-body">
    
    <div class="sidebar-overlay" id="sidebarOverlay" onclick="fecharSidebarEdicao()"></div>

    <header class="main-header">
        <nav class="navbar navbar-expand-md navbar-light">
            <div class="container-fluid">
                
                <button class="btn btn-link sidebar-toggle me-3 text-dark d-md-none" onclick="toggleSidebar()">
                    <i class="fas fa-bars fa-lg"></i>
                </button>
                
                <a class="navbar-brand" href="#">
                    <img src="resources/img/mini-logo.png" alt="ECONEXA" class="navbar-logo">
                </a>
                
                <div class="collapse navbar-collapse justify-content-end">
                    <ul class="navbar-nav">
                        <li class="nav-item"><a class="nav-link" href="index.jsp">Ir para Site</a></li>
                        <li class="nav-item"><span class="nav-link disabled">|</span></li>
                        <li class="nav-item"><a class="nav-link text-danger" href="LoginServlet">Sair</a></li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>

    <div class="d-flex-wrapper">
        
        <div class="sidebar-admin" id="adminSidebar">
            <div class="sidebar-header">
                <h5>Painel de Controle</h5>
                <small class="text-muted">Bem-vindo, <%= usuario.getNome().split(" ")[0] %></small>
            </div>
            <ul class="sidebar-menu">
                <li>
                    <a href="#" onclick="showTab('registros')" class="<%= activeTab.equals("registros") ? "active" : "" %>" id="link-registros">
                        <i class="fas fa-map-marker-alt me-2"></i> Registros (Mapa)
                    </a>
                </li>
                <li>
                    <a href="#" onclick="showTab('tipos')" class="<%= activeTab.equals("tipos") ? "active" : "" %>" id="link-tipos">
                        <i class="fas fa-list me-2"></i> Tipos de Registro
                    </a>
                </li>
                <li>
                    <a href="#" onclick="showTab('blog')" class="<%= activeTab.equals("blog") ? "active" : "" %>" id="link-blog">
                        <i class="fas fa-newspaper me-2"></i> Posts do Blog
                    </a>
                </li>
                <li>
                    <a href="#" onclick="showTab('revista')" class="<%= activeTab.equals("revista") ? "active" : "" %>" id="link-revista">
                        <i class="fas fa-book-open me-2"></i> Revista Digital
                    </a>
                </li>
                <li>
                    <a href="#" onclick="showTab('usuarios')" class="<%= activeTab.equals("usuarios") ? "active" : "" %>" id="link-usuarios">
                        <i class="fas fa-users me-2"></i> Gerenciar Usuários
                    </a>
                </li>
                
                <li class="d-md-none mt-4 border-top pt-2">
                    <a href="LoginServlet" class="text-danger">
                        <i class="fas fa-sign-out-alt me-2"></i> Sair
                    </a>
                </li>
            </ul>
        </div>

        <div class="content-wrapper">
            
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

            <div id="tab-registros" class="tab-section <%= activeTab.equals("registros") ? "active" : "" %>">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2>Gerenciar Registros do Mapa</h2>
                </div>

                <div class="form-section">
                    <h4><%= registroEdit != null ? "Editar Registro" : "Novo Registro" %></h4>
                    <form method="POST" action="SalvarRegistroServlet" enctype="multipart/form-data"> 
                        <input type="hidden" name="origem" value="admin">
                        <% if (registroEdit != null) { %>
                            <input type="hidden" name="id" value="<%= registroEdit.getId() %>">
                            <input type="hidden" name="acao" value="atualizar">
                        <% } else { %>
                            <input type="hidden" name="acao" value="inserir">
                        <% } %>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Título</label>
                                <input type="text" class="form-control" name="titulo" value="<%= registroEdit != null ? registroEdit.getTitulo() : "" %>" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Tipo</label>
                                <select class="form-select" name="tipoRegistroId" required>
                                    <option value="">Selecione...</option>
                                    <% for(TipoRegistro t : tiposRegistro) { %>
                                        <option value="<%= t.getId() %>" <%= registroEdit != null && registroEdit.getTipoRegistro().getId().equals(t.getId()) ? "selected" : "" %>><%= t.getNome() %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-12 mb-3">
                                <label class="form-label">Descrição</label>
                                <textarea class="form-control" name="descricao" rows="2" required><%= registroEdit != null ? registroEdit.getDescricao() : "" %></textarea>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Foto</label>
                                <input type="file" class="form-control" name="foto" accept="image/*">
                                <% if (registroEdit != null) { %>
                                    <small class="text-muted">
                                        <% 
                                            byte[] fotoBytes = registroDAO.getImagemById(registroEdit.getId());
                                            if (fotoBytes != null && fotoBytes.length > 0) { 
                                        %>
                                            <a href="MostrarImagemServlet?id=<%= registroEdit.getId() %>&tipo=registro" target="_blank">Ver foto atual</a>
                                        <% } %>
                                    </small>
                                <% } %>
                            </div>

                            <div class="col-md-3 mb-3">
                                <label class="form-label">Latitude</label>
                                <input type="number" step="any" class="form-control" name="latitude" value="<%= registroEdit != null ? registroEdit.getLatitude() : "" %>" required>
                            </div>
                            <div class="col-md-3 mb-3">
                                <label class="form-label">Longitude</label>
                                <input type="number" step="any" class="form-control" name="longitude" value="<%= registroEdit != null ? registroEdit.getLongitude() : "" %>" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Status</label>
                                <select class="form-select" name="status">
                                    <option value="PENDENTE" <%= registroEdit != null && "PENDENTE".equals(registroEdit.getStatus()) ? "selected" : "" %>>Pendente</option>
                                    <option value="EM_ANDAMENTO" <%= registroEdit != null && "EM_ANDAMENTO".equals(registroEdit.getStatus()) ? "selected" : "" %>>Em Andamento</option>
                                    <option value="RESOLVIDO" <%= registroEdit != null && "RESOLVIDO".equals(registroEdit.getStatus()) ? "selected" : "" %>>Resolvido</option>
                                </select>
                            </div>

                            <div class="col-md-6 mb-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="criarPost" id="criarPost">
                                    <label class="form-check-label" for="criarPost">
                                        Criar post no blog automaticamente
                                    </label>
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary"><%= registroEdit != null ? "Salvar" : "Cadastrar" %></button>
                        <% if (registroEdit != null) { %> 
                            <a href="admin.jsp?tab=registros" class="btn btn-secondary">Cancelar</a> 
                        <% } %>
                    </form>
                </div>
                        
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead><tr><th>ID</th><th>Título</th><th>Usuário</th><th>Tipo</th><th>Status</th><th>Data</th><th>Ações</th></tr>
                        </thead>
                        <tbody>
                            <% for(Registro r : registros) { %>
                            <tr>
                                <td><%= r.getId() %></td>
                                <td><%= r.getTitulo() %></td>
                                <td><%= r.getUsuario() != null ? r.getUsuario().getNome() : "N/A" %></td>
                                <td><%= r.getTipoRegistro().getNome() %></td>
                                <td>
                                    <span class="badge 
                                        <%= "PENDENTE".equals(r.getStatus()) ? "bg-warning" : 
                                            "EM_ANDAMENTO".equals(r.getStatus()) ? "bg-info" : 
                                            "RESOLVIDO".equals(r.getStatus()) ? "bg-success" : "bg-secondary" %>">
                                        <%= r.getStatus() %>
                                    </span>
                                </td>
                                <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getData()) %></td>
                                <td>
                                    <a href="admin.jsp?editId=<%= r.getId() %>&editType=registro&tab=registros" class="btn btn-sm btn-outline-primary btn-acao">Editar</a>
                                    <a href="admin.jsp?tipoAcao=registro&acao=excluir&id=<%= r.getId() %>&tab=registros" class="btn btn-sm btn-outline-danger btn-acao" onclick="return confirm('Excluir?')">Excluir</a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div> 

            <div id="tab-tipos" class="tab-section <%= activeTab.equals("tipos") ? "active" : "" %>">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2>Gerenciar Tipos (Categorias)</h2>
                </div>

                <div class="form-section">
                    <h4><%= tipoEdit != null ? "Editar Tipo" : "Novo Tipo" %></h4>
                    <form method="POST" action="admin.jsp">
                        <input type="hidden" name="tipoAcao" value="tipo">
                        <input type="hidden" name="acao" value="<%= tipoEdit != null ? "atualizar" : "inserir" %>">
                        <input type="hidden" name="tab" value="tipos">
                        <% if (tipoEdit != null) { %> <input type="hidden" name="id" value="<%= tipoEdit.getId() %>"> <% } %>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Nome</label>
                                <input type="text" class="form-control" name="nome" value="<%= tipoEdit != null ? tipoEdit.getNome() : "" %>" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Categoria</label>
                                <select class="form-select" name="categoria">
                                    <option value="POSITIVO" <%= tipoEdit != null && "POSITIVO".equals(tipoEdit.getCategoria()) ? "selected" : "" %>>Positivo</option>
                                    <option value="NEGATIVO" <%= tipoEdit != null && "NEGATIVO".equals(tipoEdit.getCategoria()) ? "selected" : "" %>>Negativo</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Ícone (Classe FontAwesome)</label>
                                <input type="text" class="form-control" name="icone" placeholder="Ex: fa-tree" value="<%= tipoEdit != null && tipoEdit.getIcone() != null ? tipoEdit.getIcone() : "" %>">
                            </div>
                            <div class="col-md-12 mb-3">
                                <label class="form-label">Descrição</label>
                                <textarea class="form-control" name="descricao" rows="2"><%= tipoEdit != null && tipoEdit.getDescricao() != null ? tipoEdit.getDescricao() : "" %></textarea>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-success"><%= tipoEdit != null ? "Salvar" : "Cadastrar" %></button>
                        <% if (tipoEdit != null) { %> <a href="admin.jsp?tab=tipos" class="btn btn-secondary">Cancelar</a> <% } %>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead><tr><th>Ícone</th><th>Nome</th><th>Categoria</th><th>Descrição</th><th>Ações</th></tr></thead>
                        <tbody>
                            <% for(TipoRegistro t : tiposRegistro) { %>
                            <tr>
                                <td class="text-center"><i class="fa <%= t.getIcone() %> fa-lg"></i></td>
                                <td><%= t.getNome() %></td>
                                <td><%= t.getCategoria() %></td>
                                <td><%= t.getDescricao() != null ? t.getDescricao() : "-" %></td>
                                <td>
                                    <a href="admin.jsp?editId=<%= t.getId() %>&editType=tipo&tab=tipos" class="btn btn-sm btn-outline-primary btn-acao">Editar</a>
                                    <a href="admin.jsp?tipoAcao=tipo&acao=excluir&id=<%= t.getId() %>&tab=tipos" class="btn btn-sm btn-outline-danger btn-acao" onclick="return confirm('Excluir?')">Excluir</a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="tab-blog" class="tab-section <%= activeTab.equals("blog") ? "active" : "" %>">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2>Gerenciar Blog</h2>
                </div>

                <div class="form-section">
                    <h4><%= blogEdit != null ? "Editar Post" : "Novo Post" %></h4>
                    
                    <form method="POST" action="SalvarPostServlet" enctype="multipart/form-data">
                        <input type="hidden" name="origem" value="admin">
                        <% if (blogEdit != null) { %> <input type="hidden" name="id" value="<%= blogEdit.getId() %>"> <% } %>
                        
                        <div class="mb-3">
                            <label class="form-label">Título</label>
                            <input type="text" class="form-control" name="titulo" value="<%= blogEdit != null ? blogEdit.getTitulo() : "" %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Conteúdo</label>
                            <textarea class="form-control" name="descricao" rows="3"><%= blogEdit != null ? blogEdit.getDescricao() : "" %></textarea>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Foto</label>
                                <input type="file" class="form-control" name="foto_capa">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Status</label>
                                <select class="form-select" name="status">
                                    <option value="PUBLICADO" <%= blogEdit != null && "PUBLICADO".equals(blogEdit.getStatusPublicacao()) ? "selected" : "" %>>Publicado</option>
                                    <option value="RASCUNHO" <%= blogEdit != null && "RASCUNHO".equals(blogEdit.getStatusPublicacao()) ? "selected" : "" %>>Rascunho</option>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary"><%= blogEdit != null ? "Salvar Alterações" : "Publicar" %></button>
                        <% if (blogEdit != null) { %> <a href="admin.jsp?tab=blog" class="btn btn-secondary">Cancelar</a> <% } %>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead><tr><th>ID</th><th>Título</th><th>Status</th><th>Data</th><th>Ações</th></tr></thead>
                        <tbody>
                            <% for(Blog p : posts) { %>
                            <tr>
                                <td><%= p.getId() %></td>
                                <td><%= p.getTitulo() %></td>
                                <td><span class="badge badge-status-<%= p.getStatusPublicacao() %>"><%= p.getStatusPublicacao() %></span></td>
                                <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(p.getDataPublicacao()) %></td>
                                <td>
                                    <a href="admin.jsp?editId=<%= p.getId() %>&editType=blog&tab=blog" class="btn btn-sm btn-outline-primary btn-acao">Editar</a>
                                    <a href="admin.jsp?tipoAcao=blog&acao=excluir&id=<%= p.getId() %>&tab=blog" class="btn btn-sm btn-outline-danger btn-acao" onclick="return confirm('Excluir?')">Excluir</a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="tab-revista" class="tab-section <%= activeTab.equals("revista") ? "active" : "" %>">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2>Gerenciar Revista Digital</h2>
                </div>

                <div class="form-section">
                    <h4><%= revistaEdit != null ? "Editar Artigo" : "Novo Artigo" %></h4>
                    
                    <form method="POST" action="SalvarRevistaServlet" enctype="multipart/form-data">
                        <input type="hidden" name="origem" value="admin">
                        
                        <% if (revistaEdit != null) { %> 
                            <input type="hidden" name="id" value="<%= revistaEdit.getId() %>"> 
                            <% } %>
                        
                        <div class="mb-3">
                            <label class="form-label">Título</label>
                            <input type="text" class="form-control" name="titulo" value="<%= revistaEdit != null ? revistaEdit.getTitulo() : "" %>" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Autor</label>
                            <input type="text" class="form-control" name="autor" value="<%= revistaEdit != null ? revistaEdit.getAutor() : usuario.getNome() %>" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Conteúdo</label>
                            <textarea class="form-control" name="descricao" rows="4" required><%= revistaEdit != null ? revistaEdit.getDescricao() : "" %></textarea>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Capa</label>
                                <input type="file" class="form-control" name="foto_capa">
                                <% if (revistaEdit != null) { %>
                                    <small class="text-muted"><a href="MostrarImagemServlet?id=<%= revistaEdit.getId() %>&tipo=revista" target="_blank">Ver capa atual</a></small>
                                <% } %>
                            </div>
                        </div>
                        
                        <button type="submit" class="btn btn-primary"><%= revistaEdit != null ? "Salvar Alterações" : "Publicar" %></button>
                        <% if (revistaEdit != null) { %> <a href="admin.jsp?tab=revista" class="btn btn-secondary">Cancelar</a> <% } %>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead><tr><th>ID</th><th>Título</th><th>Autor</th><th>Data</th><th>Ações</th></tr></thead>
                        <tbody>
                            <% for(RevistaPost r : revistaPosts) { %>
                            <tr>
                                <td><%= r.getId() %></td>
                                <td><%= r.getTitulo() %></td>
                                <td><%= r.getAutor() %></td>
                                <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getDataPublicacao()) %></td>
                                <td>
                                    <a href="admin.jsp?editId=<%= r.getId() %>&editType=revista&tab=revista" class="btn btn-sm btn-outline-primary btn-acao">Editar</a>
                                    <a href="admin.jsp?tipoAcao=revista&acao=excluir&id=<%= r.getId() %>&tab=revista" class="btn btn-sm btn-outline-danger btn-acao" onclick="return confirm('Excluir este artigo?')">Excluir</a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="tab-usuarios" class="tab-section <%= activeTab.equals("usuarios") ? "active" : "" %>">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h2>Gerenciar Usuários (Ativos)</h2>
                    </div>
                
                <div class="table-responsive mt-3">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Nome</th>
                                <th>E-mail</th>
                                <th>Perfil</th>
                                <th>Status</th>
                                <th style="width: 180px;">Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (usuariosAtivos.isEmpty()) { %>
                                <tr><td colspan="6" class="text-center">Nenhum usuário ativo encontrado.</td></tr>
                            <% } else { %>
                                <% for(Usuario u : usuariosAtivos) { %>
                                    <tr>
                                        <td><%= u.getId() %></td>
                                        <td><%= u.getNome() %></td>
                                        <td><%= u.getEmail() %></td>
                                        <td>
                                            <span class="badge bg-<%= u.getPerfil().equalsIgnoreCase("admin") ? "danger" : "info" %>">
                                                <%= u.getPerfil() %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge bg-success">ATIVO</span>
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary" 
                                                    onclick="prepararEdicaoUsuario(<%= u.getId() %>, '<%= u.getNome().replace("'", "\\'") %>', '<%= u.getEmail() %>', '<%= u.getPerfil() %>')">
                                                <i class="fas fa-edit"></i> Editar
                                            </button>
                                            
                                            <a href="AdminUsuarioServlet?acao=inativar&id=<%= u.getId() %>" 
                                               class="btn btn-sm btn-outline-danger" 
                                               onclick="return confirm('ATENÇÃO: Deseja realmente INATIVAR o usuário <%= u.getNome() %>?\nEle perderá o acesso ao sistema.')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div> 
    </div>

    <div class="sidebar-right" id="sidebarEdicaoUsuario">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4>Editar Usuário</h4>
            <button type="button" class="btn-close" onclick="fecharSidebarEdicao()"></button>
        </div>
        
        <form method="POST" action="AdminUsuarioServlet?acao=editar" id="formEdicaoUsuario" onsubmit="return validarEdicaoUsuario(event)">
            <input type="hidden" name="id" id="userIdInput">
            
            <div class="mb-3">
                <label class="form-label">Nome Completo</label>
                <input type="text" class="form-control" name="nome" id="userNameInput" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">E-mail</label>
                <input type="email" class="form-control" name="email" id="userEmailInput" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Perfil de Acesso</label>
                <select class="form-select" name="perfil" id="userPerfilInput" required>
                    <option value="MEMBRO">Membro (Comum)</option>
                    <option value="ADMIN">Administrador</option>
                </select>
            </div>
            
            <hr class="my-4">
            <div class="mb-3">
                <label class="form-label text-danger">Redefinir Senha (Opcional)</label>
                <input type="password" class="form-control" name="senha" id="userSenhaInput" placeholder="Deixe vazio para manter a atual (Mínimo 6 caracteres)" minlength="6">
                <small class="text-muted">Preencha apenas se desejar alterar a senha deste usuário.</small>
            </div>
            
            <div class="d-grid gap-2 mt-4">
                <button type="submit" class="btn btn-primary btn-lg">Salvar Alterações</button>
                <button type="button" class="btn btn-outline-secondary" onclick="fecharSidebarEdicao()">Cancelar</button>
            </div>
        </form>
    </div>

    <script src="resources/js/bootstrap.js"></script>
    <script>
        function showTab(tabName) {
            var tabs = document.querySelectorAll('.tab-section');
            tabs.forEach(function(tab) {
                tab.classList.remove('active');
            });
            
            var links = document.querySelectorAll('.sidebar-menu a');
            links.forEach(function(link) {
                link.classList.remove('active');
            });

            var tabElement = document.getElementById('tab-' + tabName);
            var linkElement = document.getElementById('link-' + tabName);

            if (tabElement) tabElement.classList.add('active');
            if (linkElement) linkElement.classList.add('active');
            
            const url = new URL(window.location);
            url.searchParams.set('tab', tabName);
            window.history.pushState({}, '', url);
            
            if (window.innerWidth <= 768) {
                document.getElementById('adminSidebar').classList.remove('active');
            }
        }
        
        function toggleSidebar() {
            document.getElementById('adminSidebar').classList.toggle('active');
        }

        // FUNÇÕES PARA EDIÇÃO DE USUÁRIO (SIDEBAR DIREITA

        function prepararEdicaoUsuario(id, nome, email, perfil) {
            document.getElementById('userSenhaInput').value = ''; 
            document.getElementById('userIdInput').value = id;
            document.getElementById('userNameInput').value = nome;
            document.getElementById('userEmailInput').value = email;
            document.getElementById('userPerfilInput').value = perfil.toUpperCase();
            
            document.getElementById('sidebarEdicaoUsuario').classList.add('is-visible');
            document.getElementById('sidebarOverlay').classList.add('is-visible');
        }

        function fecharSidebarEdicao() {
            document.getElementById('sidebarEdicaoUsuario').classList.remove('is-visible');
            document.getElementById('sidebarOverlay').classList.remove('is-visible');
        }

        function validarEdicaoUsuario(event) {
            const senhaInput = document.getElementById('userSenhaInput');
            const senha = senhaInput.value;
            
            if (senha && senha.trim().length > 0) {
                if (senha.length < 6) {
                    alert('Erro: A nova senha deve ter no mínimo 6 caracteres.');
                    event.preventDefault(); 
                    return false;
                }
            }
            return true;
        }

        document.addEventListener('DOMContentLoaded', () => {
            const urlParams = new URLSearchParams(window.location.search);
            const initialTab = urlParams.get('tab') || 'registros';
            showTab(initialTab);
        });
    </script>
</body>
</html>