// Autor: Jhonny

package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.DAO.BlogDAO;
import com.mycompany.econexaadilson.model.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "InteracaoServlet", urlPatterns = {"/InteracaoServlet"})
public class InteracaoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
        
        if (usuario == null) {
            response.setStatus(401);
            response.getWriter().write("{\"error\": \"Login necessário\"}");
            return;
        }
        
        try {
            String tipo = request.getParameter("tipo"); 
            Long postId = Long.parseLong(request.getParameter("postId"));
            
            BlogDAO dao = new BlogDAO();
            boolean sucesso = false;
            
            if ("like".equals(tipo)) {
                sucesso = dao.alternarCurtida(usuario.getId(), postId);
            } else if ("save".equals(tipo)) {
                sucesso = dao.alternarSalvar(usuario.getId(), postId);
            }
            
            if (sucesso) {
                response.getWriter().write("{\"success\": true}");
            } else {
                response.setStatus(500);
                response.getWriter().write("{\"error\": \"Erro no banco\"}");
            }
            
        } catch (Exception e) {
            response.setStatus(500);
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}