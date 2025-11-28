/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.RevistaPost;
import com.mycompany.econexaadilson.model.DAO.RevistaPostDAO;
import com.mycompany.econexaadilson.model.Usuario;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

/**
 * Servlet para gerenciar artigos da revista (criar, editar, excluir)
 * @author Jhonny
 * @author Gustavo Freitas - Documentação
 */
@WebServlet(name = "SalvarRevistaServlet", urlPatterns = {"/SalvarRevistaServlet"})
@MultipartConfig(maxFileSize = 16177215) // 16MB
public class SalvarRevistaServlet extends HttpServlet {
    /**
     * Processa todas as operações CRUD para artigos da revista
     * @param request Dados do artigo e ação a ser executada
     * @param response Redirecionamento com resultado
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String message = null;
        boolean sucesso = false;
        
        try {
            HttpSession session = request.getSession();
            Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
            
            if (usuarioLogado == null) {
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode("Faça login para realizar esta ação.", "UTF-8"));
                return;
            }

            String acao = request.getParameter("acao");
            RevistaPostDAO dao = new RevistaPostDAO();

            if ("excluir".equals(acao)) {
                // EXCLUIR
                Long id = Long.parseLong(request.getParameter("id"));
                // Verificação de segurança: apenas o dono ou admin pode excluir
                RevistaPost postExistente = dao.buscarPorId(id);
                if (postExistente != null && (postExistente.getUsuarioId().equals(usuarioLogado.getId()) || usuarioLogado.isAdmin())) {
                    sucesso = dao.excluir(id);
                    message = sucesso ? "Artigo excluído com sucesso." : "Erro ao excluir artigo.";
                } else {
                    message = "Você não tem permissão para excluir este artigo.";
                }
                
            } else {
                // INSERIR ou ATUALIZAR
                String titulo = request.getParameter("titulo");
                String autor = request.getParameter("autor");
                String descricao = request.getParameter("descricao");
                Part filePart = request.getPart("foto_capa");
                
                RevistaPost post = new RevistaPost();
                post.setTitulo(titulo);
                post.setAutor(autor);
                post.setDescricao(descricao);
                post.setUsuarioId(usuarioLogado.getId());
                
                if (filePart != null && filePart.getSize() > 0) {
                    post.setFotoCapaStream(filePart.getInputStream());
                }

                String idParam = request.getParameter("id");
                if (idParam != null && !idParam.isEmpty()) {
                    // ATUALIZAR
                    Long id = Long.parseLong(idParam);
                    post.setId(id);
                    
                    // Validação de permissão
                    RevistaPost postExistente = dao.buscarPorId(id);
                    if (postExistente != null && (postExistente.getUsuarioId().equals(usuarioLogado.getId()) || usuarioLogado.isAdmin())) {
                        sucesso = dao.atualizar(post); // O DAO cuida se deve manter a imagem antiga ou não
                        message = sucesso ? "Artigo atualizado com sucesso!" : "Erro ao atualizar artigo.";
                    } else {
                        message = "Permissão negada.";
                    }
                } else {
                    // INSERIR
                    sucesso = dao.inserir(post);
                    message = sucesso ? "Artigo publicado com sucesso!" : "Erro ao publicar artigo.";
                }
            }

        } catch (Exception e) {
            message = "Erro interno: " + e.getMessage();
            e.printStackTrace();
        }
        
        String encodedMsg = URLEncoder.encode(message, "UTF-8");
        String redirect = sucesso ? "revistaPost.jsp?sucesso=" + encodedMsg : "revistaPost.jsp?erro=" + encodedMsg;
        response.sendRedirect(redirect);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}