/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.econexaadilson.model.controller;


import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.DAO.BlogDAO;
import com.mycompany.econexaadilson.model.Registro;
import com.mycompany.econexaadilson.model.DAO.RegistroDAO;
import com.mycompany.econexaadilson.model.Usuario;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "CriarPostDoRegistroServlet", urlPatterns = {"/CriarPostDoRegistroServlet"})
public class CriarPostDoRegistroServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String message = null;
        boolean sucesso = false;
        
        try {
            HttpSession session = request.getSession();
            Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
            
            if (usuarioLogado == null) {
                message = "Você precisa estar logado para criar um post.";
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
                return;
            }

            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                throw new IllegalArgumentException("ID do registro não fornecido.");
            }
            Long registroId = Long.parseLong(idParam);

            RegistroDAO registroDAO = new RegistroDAO();
            Registro registroOriginal = registroDAO.buscarPorId(registroId);
            
            if (registroOriginal == null) {
                throw new Exception("Registro original não encontrado.");
            }
            
            byte[] imagemBytes = registroDAO.getImagemById(registroId);

            Blog post = new Blog();
            post.setTitulo("Relato: " + registroOriginal.getTitulo());
            post.setDescricao("Localização: " + registroOriginal.getLatitude() + ", " + registroOriginal.getLongitude() + "\n\n" + registroOriginal.getDescricao());
            
            if (imagemBytes != null && imagemBytes.length > 0) {
                post.setFotoCapaStream(new ByteArrayInputStream(imagemBytes));
            }

            post.setUsuarioId(usuarioLogado.getId());
            post.setRegistroId(registroOriginal.getId());
            post.setStatusPublicacao("PUBLICADO");
            post.setDataPublicacao(new Date());

            sucesso = new BlogDAO().inserir(post);

            if (sucesso) {
                message = "Registro transformado em post com sucesso!";
                response.sendRedirect("blog.jsp?sucesso=" + URLEncoder.encode(message, "UTF-8"));
            } else {
                message = "Erro ao criar post a partir do registro.";
                response.sendRedirect("mapa.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
            }

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace();
            response.sendRedirect("mapa.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
        }
    }
}
