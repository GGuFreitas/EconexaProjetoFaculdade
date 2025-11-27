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
        String origem = request.getParameter("origem"); // "admin" ou null
        String acao = request.getParameter("acao"); // "inserir" ou "atualizar"
        
        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
        
        if (usuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            RegistroDAO registroDAO = new RegistroDAO();
            Registro registro;
            
            if ("atualizar".equals(acao)) {
                // Modo atualização
                Long id = Long.parseLong(request.getParameter("id"));
                registro = registroDAO.buscarPorId(id);
                if (registro == null) {
                    throw new Exception("Registro não encontrado para atualização");
                }
            } else {
                // Modo inserção
                registro = new Registro();
            }
            
            registro.setTitulo(request.getParameter("titulo"));
            registro.setDescricao(request.getParameter("descricao"));
            registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
            registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
            
            String status = request.getParameter("status");
            if (status != null) {
                registro.setStatus(status);
            } else {
                registro.setStatus("PENDENTE");
            }
            
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

            if ("inserir".equals(acao)) {
                registro.setData(new Date());
                registro.setUsuario(usuario);

                Long novoId = registroDAO.inserir(registro);
                sucesso = (novoId != null);

                if (sucesso) {
                    message = "Registro criado com sucesso!";

                    String criarPost = request.getParameter("criarPost");

                    /*if (criarPost != null && criarPost.equals("on")) {
                        Blog post = new Blog();
                        post.setTitulo("Relato: " + registro.getTitulo());
                        post.setDescricao(registro.getDescricao());
                        post.setUsuarioId(usuario.getId());
                        post.setRegistroId(novoId); // 
                        post.setStatusPublicacao("PUBLICADO");
                        post.setDataPublicacao(new Date());

                        if (imagemBytes != null) {
                            post.setFotoCapaStream(new ByteArrayInputStream(imagemBytes));
                        }

                        boolean postCriado = new BlogDAO().inserir(post);
                        if (postCriado) {
                            message += " E postado no Blog!";
                        } else {
                            message += " (Erro ao criar post no blog)";
                        }
                    }*/
                    
                }
            } else {
                // Atualização
                sucesso = registroDAO.atualizar(registro);
                message = sucesso ? "Registro atualizado com sucesso!" : "Erro ao atualizar registro";
            }

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace();
            sucesso = false;
        } finally {
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            
            if ("admin".equals(origem)) {
                if (sucesso) {
                    response.sendRedirect("admin.jsp?tab=registros&sucesso=" + encodedMessage);
                } else {
                    response.sendRedirect("admin.jsp?tab=registros&erro=" + encodedMessage);
                }
            } else {
                if (sucesso) {
                    response.sendRedirect("mapa.jsp?sucesso=" + encodedMessage);
                } else {
                    response.sendRedirect("mapa.jsp?erro=" + encodedMessage);
                }
            }
        }
    }
}