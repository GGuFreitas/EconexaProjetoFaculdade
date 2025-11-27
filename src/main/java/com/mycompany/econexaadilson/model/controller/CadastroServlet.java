/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.Usuario;
import com.mycompany.econexaadilson.model.DAO.UsuarioDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

/**
 *
 * @author
 */
@WebServlet(name = "CadastroServlet", urlPatterns = {"/CadastroServlet"})
public class CadastroServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        String confirmarSenha = request.getParameter("confirmarSenha");
        
        try {
            // Validações
            if (!senha.equals(confirmarSenha)) {
                response.sendRedirect("cadastro.jsp?erro=" + URLEncoder.encode("Senhas não coincidem", "UTF-8"));
                return;
            }
            
            if (senha.length() < 6) {
                response.sendRedirect("cadastro.jsp?erro=" + URLEncoder.encode("Senha deve ter pelo menos 6 caracteres", "UTF-8"));
                return;
            }
            
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            
            // (Nota: Se o email existir mas estiver INATIVO, o banco barrará no insert)
            if (usuarioDAO.buscarAtivoPorEmail(email) != null) {
                response.sendRedirect("cadastro.jsp?erro=" + URLEncoder.encode("Email já cadastrado", "UTF-8"));
                return;
            }
            
            // Criar novo usuário
            Usuario novoUsuario = new Usuario();
            novoUsuario.setNome(nome);
            novoUsuario.setEmail(email);
            novoUsuario.setSenhaHash(BCrypt.hashpw(senha, BCrypt.gensalt()));
            novoUsuario.setPerfil("MEMBRO"); // Padrão é MEMBRO
            novoUsuario.setStatus("ATIVO");  // Define explicitamente como ATIVO
            novoUsuario.setDataCriacao(new Date());
            
            if (usuarioDAO.inserir(novoUsuario)) {
                response.sendRedirect("login.jsp?sucesso=" + URLEncoder.encode("Conta criada com sucesso! Faça login.", "UTF-8"));
            } else {
                response.sendRedirect("cadastro.jsp?erro=" + URLEncoder.encode("Erro ao criar conta. O e-mail pode já estar em uso.", "UTF-8"));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cadastro.jsp?erro=" + URLEncoder.encode("Erro no servidor: " + e.getMessage(), "UTF-8"));
        }
    }
}