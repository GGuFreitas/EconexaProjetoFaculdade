/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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
            Registro registro = new Registro();
            
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
                try (InputStream is = filePart.getInputStream()) {
                    
                    imagemBytes = new byte[is.available()];
                    is.read(imagemBytes);
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
                    
                    HttpSession session = request.getSession();
                    Usuario usuario = (Usuario) session.getAttribute("usuarioLogado");
                    
                    if (usuario != null) {
                        Blog post = new Blog();
                        post.setTitulo("Relato: " + registro.getTitulo());
                        post.setDescricao(registro.getDescricao());
                        post.setUsuarioId(usuario.getId());
                        post.setRegistroId(novoId);
                        post.setStatusPublicacao("PUBLICADO");
                        post.setDataPublicacao(new Date());
                        
                        if (imagemBytes != null) {
                            post.setFotoCapaStream(new ByteArrayInputStream(imagemBytes));
                        }
                        
                        new BlogDAO().inserir(post);
                        message += " Postado no Blog!";
                    }
                }
                
            } else {
                message = "Erro ao criar registro.";
            }

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace();
        } finally {
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            
            if (sucesso) {
                response.sendRedirect("mapa.jsp?sucesso=" + encodedMessage);
            } else {
                response.sendRedirect("mapa.jsp?erro=" + encodedMessage);
            }
        }
    }
}