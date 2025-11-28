package com.mycompany.econexaadilson.model.controller;
/**
 * Servlet para gerenciar interações de usuário com posts (curtir/salvar)
 * Autor: Jhonny Brito
 * Documentação: Gustavo Freitas
 */
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
    /**
     * Processa requisições POST para interações (like/save) em posts
     * @param request Requisição contendo tipo de interação e ID do post
     * @param response Resposta JSON com resultado da operação
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
        // Verifica se usuário está autenticado   
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
             // Executa ação baseada no tipo de interação    
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