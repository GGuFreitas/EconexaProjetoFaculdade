/**
 *
 * @author Jhonny
 */

package com.mycompany.econexaadilson.model.controller;


import com.mycompany.econexaadilson.model.DAO.BlogDAO;
import com.mycompany.econexaadilson.model.DAO.RegistroDAO;
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
            Long id = Long.parseLong(request.getParameter("id"));
            String tipo = request.getParameter("tipo"); // "blog" ou "registro"
            
            byte[] imgBytes = null;
            
            if ("registro".equals(tipo)) {
                // Busca imagem do registro
                RegistroDAO registroDao = new RegistroDAO();
                imgBytes = registroDao.getImagemById(id);
            } else {
                // Default para blog (mantém compatibilidade)
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
                // Envia uma imagem placeholder
                response.sendRedirect("resources/img/placeholder.jpg");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido.");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erro ao carregar imagem.");
        }
    }
}