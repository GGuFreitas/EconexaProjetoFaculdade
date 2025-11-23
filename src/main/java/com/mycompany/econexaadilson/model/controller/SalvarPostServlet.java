package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.DAO.BlogDAO;
import com.mycompany.econexaadilson.model.Usuario;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import javax.servlet.http.HttpSession;

@WebServlet(name = "SalvarPostServlet", urlPatterns = {"/SalvarPostServlet"})
@MultipartConfig(maxFileSize = 16177215) // 15MB
public class SalvarPostServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String message = null;
        boolean sucesso = false;
        String origem = request.getParameter("origem");
        
        try {
            HttpSession session = request.getSession();
            Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
            
            if (usuarioLogado == null) {
                message = "Você precisa estar logado para postar.";
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
                return;
            }

            Blog post = new Blog();
            
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                post.setId(Long.parseLong(idParam));
            }
            
            post.setTitulo(request.getParameter("titulo"));
            post.setDescricao(request.getParameter("descricao"));
            
            String status = request.getParameter("status");
            post.setStatusPublicacao(status != null ? status : "PUBLICADO");

            InputStream inputStream = null;
            Part filePart = request.getPart("foto_capa");
            if (filePart != null && filePart.getSize() > 0) {
                inputStream = filePart.getInputStream();
                post.setFotoCapaStream(inputStream);
            }

            post.setUsuarioId(usuarioLogado.getId());
            post.setDataPublicacao(new Date());

            BlogDAO dao = new BlogDAO();
            
            if (post.getId() != null && post.getId() > 0) {
                sucesso = dao.atualizar(post);
                message = "Post atualizado!";
            } else {
                sucesso = dao.inserir(post);
                message = "Post criado!";
            }

            if (!sucesso) message = "Erro ao salvar post.";

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (!response.isCommitted()) {
                String encodedMessage = URLEncoder.encode(message, "UTF-8");
                String redirectPage = "blog.jsp";
                
                if ("admin".equals(origem)) {
                    redirectPage = "admin.jsp";
                }
                
                if (sucesso) {
                    response.sendRedirect(redirectPage + "?sucesso=" + encodedMessage);
                } else {
                    response.sendRedirect(redirectPage + "?erro=" + encodedMessage);
                }
            }
        }
    }
}