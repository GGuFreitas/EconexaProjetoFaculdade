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
        if (origem == null) origem = "blog";

        try {
            HttpSession session = request.getSession();
            Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
            
            if (usuarioLogado == null) {
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode("Login necessário.", "UTF-8"));
                return;
            }

            Blog post = new Blog();
            
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                post.setId(Long.parseLong(idParam));
            }
            
            post.setTitulo(request.getParameter("titulo"));
            post.setDescricao(request.getParameter("descricao"));
            post.setUsuarioId(usuarioLogado.getId()); 
            
            String status = request.getParameter("status");
            post.setStatusPublicacao(status != null ? status : "PUBLICADO");
            post.setDataPublicacao(new Date());

            InputStream inputStream = null;
            Part filePart = request.getPart("foto_capa");
            if (filePart != null && filePart.getSize() > 0) {
                inputStream = filePart.getInputStream();
                post.setFotoCapaStream(inputStream);
            }

            BlogDAO dao = new BlogDAO();

            if (post.getId() != null && post.getId() > 0) {
                sucesso = dao.atualizar(post);
                message = "Post atualizado com sucesso!";
            } else {
                sucesso = dao.inserir(post);
                message = "Post criado com sucesso!";
            }

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace();
        } finally {
            redirecionar(response, sucesso, message, origem);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String acao = request.getParameter("acao");
        String origem = request.getParameter("origem");
        if (origem == null) origem = "blog";
        
        if ("excluir".equals(acao)) {
            String message = null;
            boolean sucesso = false;
            
            try {
                HttpSession session = request.getSession();
                Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
                
                if (usuarioLogado == null) {
                    response.sendRedirect("login.jsp");
                    return;
                }

                Long idPost = Long.parseLong(request.getParameter("id"));
                BlogDAO dao = new BlogDAO();
                
                Blog postAlvo = dao.buscarPorId(idPost);
                
                if (postAlvo != null) {
                    if (usuarioLogado.isAdmin() || postAlvo.getUsuarioId().equals(usuarioLogado.getId())) {
                        sucesso = dao.excluir(idPost);
                        message = "Post excluído com sucesso.";
                    } else {
                        message = "Você não tem permissão para excluir este post.";
                    }
                } else {
                    message = "Post não encontrado.";
                }

            } catch (Exception e) {
                message = "Erro ao excluir: " + e.getMessage();
                e.printStackTrace();
            } finally {
                redirecionar(response, sucesso, message, origem);
            }
        }
    }

    private void redirecionar(HttpServletResponse response, boolean sucesso, String message, String origem) throws IOException {
        if (!response.isCommitted()) {
            String paginaDestino = "blog.jsp";
            if ("perfil".equals(origem)) {
                paginaDestino = "meuPerfil.jsp";
            } else if ("admin".equals(origem)) {
                paginaDestino = "admin.jsp";
            }
            
            String param = sucesso ? "sucesso" : "erro";
            response.sendRedirect(paginaDestino + "?" + param + "=" + URLEncoder.encode(message, "UTF-8"));
        }
    }
}