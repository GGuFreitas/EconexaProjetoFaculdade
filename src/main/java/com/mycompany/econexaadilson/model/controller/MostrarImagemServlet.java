package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.DAO.BlogDAO;
import com.mycompany.econexaadilson.model.DAO.RegistroDAO;
import com.mycompany.econexaadilson.model.DAO.RevistaPostDAO;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "MostrarImagemServlet", urlPatterns = {"/MostrarImagemServlet"})
public class MostrarImagemServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String idParam = request.getParameter("id");
            String tipo = request.getParameter("tipo");
            
            if (idParam == null || idParam.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            
            Long id = Long.parseLong(idParam);
            byte[] imgBytes = null;
            
            if ("registro".equals(tipo)) {
                RegistroDAO registroDao = new RegistroDAO();
                imgBytes = registroDao.getImagemById(id);
            } else if ("revista".equals(tipo)) { // Bloco para revista
                RevistaPostDAO revistaDao = new RevistaPostDAO();
                imgBytes = revistaDao.getImagemById(id);
            } else {
                // Mantém o Blog como padrão (fallback) para compatibilidade com o resto do sistema
                BlogDAO blogDao = new BlogDAO();
                imgBytes = blogDao.getImagemById(id);
            }
            
            if (imgBytes != null && imgBytes.length > 0) {
                response.setContentType("image/jpeg"); 
                OutputStream os = response.getOutputStream();
                os.write(imgBytes);
                os.flush();
                os.close();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido.");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao carregar imagem.");
        }
    }
}