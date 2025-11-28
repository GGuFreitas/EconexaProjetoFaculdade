package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.Usuario;
import com.mycompany.econexaadilson.model.DAO.UsuarioDAO;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

/**
 * @author Enzo Reis
 * Documentação elaborada por: Enzo Reis
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        
        try {
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            
            // Usando método que filtra por status ATIVO
            Usuario usuario = usuarioDAO.buscarAtivoPorEmail(email);
            
            if (usuario != null && BCrypt.checkpw(senha, usuario.getSenhaHash())) {
                // Login bem-sucedido
                HttpSession session = request.getSession();
                session.setAttribute("usuarioLogado", usuario);
                session.setMaxInactiveInterval(30 * 60); // 30 minutos
                
                // Redirecionar baseado no perfil
                if (usuario.isAdmin()) {
                    response.sendRedirect("admin.jsp");
                } else {
                    response.sendRedirect("mapa.jsp");
                }
            } else {
                // Credenciais inválidas ou usuário INATIVO
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode("Email ou senha inválidos", "UTF-8"));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?erro=" + URLEncoder.encode("Erro no servidor: " + e.getMessage(), "UTF-8"));
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Logout
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect("login.jsp");
    }
}