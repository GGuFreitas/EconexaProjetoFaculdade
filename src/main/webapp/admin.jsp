<%-- 
    Document   : admin
    Author     : gufre, jhonny
--%>

<%@page import="com.mycompany.econexaadilson.model.DAO.RegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.TipoRegistroDAO"%>
<%@page import="com.mycompany.econexaadilson.model.DAO.BlogDAO"%>
<%@page import="com.mycompany.econexaadilson.model.Registro"%>
<%@page import="com.mycompany.econexaadilson.model.TipoRegistro"%>
<%@page import="com.mycompany.econexaadilson.model.Blog"%>
<%@page import="com.mycompany.econexaadilson.model.Usuario"%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Date" %>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
    if (usuario == null || !usuario.isAdmin()) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    
    RegistroDAO registroDAO = new RegistroDAO();
    TipoRegistroDAO tipoRegistroDAO = new TipoRegistroDAO();
    BlogDAO blogDAO = new BlogDAO();

    String acao = request.getParameter("acao");
    String tipoAcao = request.getParameter("tipoAcao");
    
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
            
            //  Associar usuário admin
            registro.setUsuario(usuario);
            
            //  Processar foto
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

    List<Registro> registros = registroDAO.listarTodos();
    List<TipoRegistro> tiposRegistro = tipoRegistroDAO.listarTodos();
    List<Blog> posts = blogDAO.listarTodosAdmin();
    
    String activeTab = request.getParameter("tab");
    if (activeTab == null) activeTab = "registros";

    String editId = request.getParameter("editId");
    String editType = request.getParameter("editType");
    Registro registroEdit = null;
    TipoRegistro tipoEdit = null;
    Blog blogEdit = null;
    
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
    <!-- Font Awesome para ícones do menu -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="admin-body">
    
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
                
                <li class="d-md-none mt-4 border-top pt-2">
                    <a href="LoginServlet" class="text-danger">
                        <i class="fas fa-sign-out-alt me-2"></i> Sair
                    </a>
                </li>
            </ul>
        </div>

        <div class="content-wrapper">
            
            <!-- Mensagens de Sucesso/Erro -->
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
                                        <% } else { %>
                                            Nenhuma foto cadastrada
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

                            <!-- Campo para criar post no blog -->
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
                        </div>
                        <button type="submit" class="btn btn-success"><%= tipoEdit != null ? "Salvar" : "Cadastrar" %></button>
                        <% if (tipoEdit != null) { %> <a href="admin.jsp?tab=tipos" class="btn btn-secondary">Cancelar</a> <% } %>
                    </form>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead><tr><th>Nome</th><th>Categoria</th><th>Ações</th></tr></thead>
                        <tbody>
                            <% for(TipoRegistro t : tiposRegistro) { %>
                            <tr>
                                <td><%= t.getNome() %></td>
                                <td><%= t.getCategoria() %></td>
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

        </div> 
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

            document.getElementById('tab-' + tabName).classList.add('active');
            document.getElementById('link-' + tabName).classList.add('active');
            
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
    </script>
</body>
</html>