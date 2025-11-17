<%-- 
    Document   : cadastro
    Created on : 17 de nov. de 2025, 12:04:20
    Author     : Enzo Reis
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>ECONEXA - Cadastro</title>
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
                <h3>Criar Conta</h3>
                <p class="text-muted">Junte-se à comunidade</p>
            </div>

            <% if (request.getParameter("erro") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= request.getParameter("erro") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="CadastroServlet" method="POST">
                <div class="mb-3">
                    <label for="nome" class="form-label">Nome Completo</label>
                    <input type="text" class="form-control" id="nome" name="nome" required 
                           placeholder="Seu nome completo">
                </div>
                
                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" name="email" required 
                           placeholder="seu@email.com">
                </div>
                
                <div class="mb-3">
                    <label for="senha" class="form-label">Senha</label>
                    <input type="password" class="form-control" id="senha" name="senha" required 
                           placeholder="Mínimo 6 caracteres" minlength="6">
                </div>
                
                <div class="mb-3">
                    <label for="confirmarSenha" class="form-label">Confirmar Senha</label>
                    <input type="password" class="form-control" id="confirmarSenha" name="confirmarSenha" required 
                           placeholder="Digite novamente sua senha">
                </div>
                
                <button type="submit" class="btn btn-success w-100 mb-3">Criar Conta</button>
                
                <div class="text-center">
                    <a href="login.jsp">Já tem conta? Faça login</a>
                </div>
            </form>
        </div>
    </div>
    
    <script src="resources/js/bootstrap.js"></script>
</body>
</html>