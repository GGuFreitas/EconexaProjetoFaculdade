/**
 *
 * @author Jhonny
 */

package com.mycompany.econexaadilson.model.controller;



import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.DAO.BlogDAO;

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


@WebServlet(name = "SalvarPostServlet", urlPatterns = {"/SalvarPostServlet"})
@MultipartConfig(maxFileSize = 16177215) // 15MB
public class SalvarPostServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8"); 
        
        String message = null;
        boolean sucesso = false;
        try {
            Blog post = new Blog();
            
            post.setTitulo(request.getParameter("titulo"));
            post.setDescricao(request.getParameter("descricao"));

            InputStream inputStream = null;
            Part filePart = request.getPart("foto_capa"); 
            if (filePart != null && filePart.getSize() > 0) {
                inputStream = filePart.getInputStream();
                post.setFotoCapaStream(inputStream); 
            }

            // ------------------- ATENÇÃO -------------------------
            // O ID do usuário deve vir da SESSÃO após o login
            // o 1 (Admin) tá apenas como exemplo
            post.setUsuarioId(1L);

            post.setStatusPublicacao("PUBLICADO");
            post.setDataPublicacao(new Date());

            sucesso = new BlogDAO().inserir(post);

            if (sucesso) {
                message = "Post criado com sucesso!";
            } else {
                message = "Erro ao criar post.";
            }

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace(); 
        } finally {
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            
            if (sucesso) {
                response.sendRedirect("blog.jsp?sucesso=" + encodedMessage);
            } else {
                response.sendRedirect("blog.jsp?erro=" + encodedMessage);
            }
        }
    }
}