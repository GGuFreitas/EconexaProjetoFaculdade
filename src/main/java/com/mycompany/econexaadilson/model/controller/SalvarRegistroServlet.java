/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import com.mycompany.econexaadilson.model.Registro;
import com.mycompany.econexaadilson.model.TipoRegistro;
import com.mycompany.econexaadilson.model.DAO.RegistroDAO;
import com.mycompany.econexaadilson.model.DAO.TipoRegistroDAO;

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
            registro.setData(new Date());
            registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
            registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
            registro.setStatus("PENDENTE");
            
            // Processar a imagem
            InputStream inputStream = null;
            Part filePart = request.getPart("foto"); 
            if (filePart != null && filePart.getSize() > 0) {
                inputStream = filePart.getInputStream();
                registro.setFotoStream(inputStream); 
            }
            
            // Tipo de registro
            Long tipoRegistroId = Long.parseLong(request.getParameter("tipoRegistroId"));
            TipoRegistro tipoRegistro = new TipoRegistroDAO().buscarPorId(tipoRegistroId);
            registro.setTipoRegistro(tipoRegistro);
            
            sucesso = new RegistroDAO().inserir(registro);

            if (sucesso) {
                message = "Registro criado com sucesso!";
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