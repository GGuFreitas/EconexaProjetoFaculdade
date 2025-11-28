package com.mycompany.econexaadilson.model.controller;
/**
 * Servlet para criar posts do blog a partir de registros existentes
 * Transforma um registro do mapa em um post do blog
 * @author Jhonny Brito
 * @author Gustavo Freitas - Documentação
 */

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
     /**
     * Processa requisição GET para transformar registro em post do blog
     * @param request Requisição HTTP contendo ID do registro
     * @param response Resposta HTTP com redirecionamento
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String message = null;
        boolean sucesso = false;
        
        try {
            HttpSession session = request.getSession();
            Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
            // Verifica se usuário está logado    
            if (usuarioLogado == null) {
                message = "Você precisa estar logado para criar um post.";
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
                return;
            }
            // Obtém ID do registro a ser transformado em post
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                throw new IllegalArgumentException("ID do registro não fornecido.");
            }
            Long registroId = Long.parseLong(idParam);
            // Busca registro original no banco
            RegistroDAO registroDAO = new RegistroDAO();
            Registro registroOriginal = registroDAO.buscarPorId(registroId);
            
            if (registroOriginal == null) {
                throw new Exception("Registro original não encontrado.");
            }
            // Obtém imagem do registro para usar como foto de capa
            byte[] imagemBytes = registroDAO.getImagemById(registroId);
           
            // Cria novo post do blog baseado no registro
            Blog post = new Blog();
            post.setTitulo("Relato: " + registroOriginal.getTitulo());
            post.setDescricao("Localização: " + registroOriginal.getLatitude() + ", " + registroOriginal.getLongitude() + "\n\n" + registroOriginal.getDescricao());
            
            // Se existir imagem no registro, usa como foto de capa
            if (imagemBytes != null && imagemBytes.length > 0) {
                post.setFotoCapaStream(new ByteArrayInputStream(imagemBytes));
            }
            // Define dados do post
            post.setUsuarioId(usuarioLogado.getId());
            post.setRegistroId(registroOriginal.getId());
            post.setStatusPublicacao("PUBLICADO");
            post.setDataPublicacao(new Date());

            sucesso = new BlogDAO().inserir(post);
            
            // Redireciona com mensagem de sucesso ou erro
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
