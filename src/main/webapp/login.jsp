<%-- 
    Document   : login.jsp
    Created on : 17 de nov. de 2025, 12:00:44
    Author     : Enzo Reis
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>ECONEXA - Login</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="resources/css/style-bootstrap.css" rel="stylesheet" type="text/css"/>
    <style>
        .login-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #1e8449 0%, #27ae60 100%);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            padding: 2rem;
            width: 100%;
            max-width: 400px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="text-center mb-4">
                <img src="resources/img/mini-logo.png" alt="ECONEXA" class="mb-3" style="height: 60px;">
                <h3>Login</h3>
                <p class="text-muted">Acesse sua conta</p>
            </div>

            <% if (request.getParameter("erro") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= request.getParameter("erro") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <% if (request.getParameter("sucesso") != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= request.getParameter("sucesso") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="LoginServlet" method="POST">
                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" name="email" required 
                           placeholder="seu@email.com">
                </div>
                
                <div class="mb-3">
                    <label for="senha" class="form-label">Senha</label>
                    <input type="password" class="form-control" id="senha" name="senha" required 
                           placeholder="Sua senha">
                </div>
                
                <button type="submit" class="btn btn-success w-100 mb-3">Entrar</button>
                
                <div class="text-center">
                    <a href="cadastro.jsp">Não tem conta? Cadastre-se</a>
                </div>
            </form>
        </div>
    </div>
    
    <script src="resources/js/bootstrap.js"></script>
</body>
</html>