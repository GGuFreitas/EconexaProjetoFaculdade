package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.Registro;
import com.mycompany.econexaadilson.model.DAO.RegistroDAO;
import com.mycompany.econexaadilson.model.TipoRegistro;
import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.DAO.BlogDAO;
import com.mycompany.econexaadilson.model.Usuario;

import java.io.ByteArrayInputStream;
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

@WebServlet(name = "SalvarRegistroServlet", urlPatterns = {"/SalvarRegistroServlet"})
@MultipartConfig(maxFileSize = 16177215) // 15MB
public class SalvarRegistroServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String message = null;
        boolean sucesso = false;
        
        try {
            HttpSession session = request.getSession();
            Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
            
            if (usuarioLogado == null) {
                message = "Você precisa estar logado para criar um registro.";
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
                return;
            }

            Registro registro = new Registro();
            
            registro.setUsuarioId(usuarioLogado.getId());
            // ----------------------------------
            
            registro.setTitulo(request.getParameter("titulo"));
            registro.setDescricao(request.getParameter("descricao"));
            registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
            registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
            
            Long tipoRegistroId = Long.parseLong(request.getParameter("tipoRegistroId"));
            TipoRegistro tipo = new TipoRegistro();
            tipo.setId(tipoRegistroId);
            registro.setTipoRegistro(tipo);

            byte[] imagemBytes = null;
            Part filePart = request.getPart("foto"); 
            
            if (filePart != null && filePart.getSize() > 0) {
                imagemBytes = new byte[(int) filePart.getSize()];
                try (InputStream is = filePart.getInputStream()) {
                    int bytesRead = 0;
                    while (bytesRead < imagemBytes.length) {
                        int result = is.read(imagemBytes, bytesRead, imagemBytes.length - bytesRead);
                        if (result == -1) break;
                        bytesRead += result;
                    }
                }
                registro.setFotoStream(new ByteArrayInputStream(imagemBytes));
            }

            registro.setStatus("PENDENTE");
            registro.setData(new Date());

            Long novoId = new RegistroDAO().inserir(registro);
            sucesso = (novoId != null);

            if (sucesso) {
                message = "Registro criado com sucesso!";
                
                String criarPost = request.getParameter("criarPost");
                
                if (criarPost != null && criarPost.equals("on")) {
                    Blog post = new Blog();
                    post.setTitulo("Relato: " + registro.getTitulo());
                    post.setDescricao(registro.getDescricao());
                    post.setUsuarioId(usuarioLogado.getId());
                    post.setRegistroId(novoId);
                    post.setStatusPublicacao("PUBLICADO");
                    post.setDataPublicacao(new Date());
                    
                    if (imagemBytes != null) {
                        post.setFotoCapaStream(new ByteArrayInputStream(imagemBytes));
                    }
                    
                    new BlogDAO().inserir(post);
                    message += " E postado no Blog!";
                }
                
            } else {
                message = "Erro ao criar registro.";
            }

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (!response.isCommitted()) {
                String encodedMessage = URLEncoder.encode(message, "UTF-8");
                if (sucesso) {
                    response.sendRedirect("mapa.jsp?sucesso=" + encodedMessage);
                } else {
                    response.sendRedirect("mapa.jsp?erro=" + encodedMessage);
                }
            }
        }
    }
}