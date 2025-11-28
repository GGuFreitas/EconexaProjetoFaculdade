package com.mycompany.econexaadilson.model.controller;
/**
 * Servlet para salvar registros no mapa com opção de criar post no blog
 * @author Jhonny e Gustavo de Freitas
 * @author Gustavo Freitas - Documentação
 */
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
    /**
     * Processa criação e atualização de registros com upload de imagem
     * @param request Dados do registro, coordenadas e arquivo de imagem
     * @param response Redirecionamento com resultado
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String message = null;
        boolean sucesso = false;
        String origem = request.getParameter("origem"); // "admin" ou null (mapa)
        
        try {
            HttpSession session = request.getSession();
            Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
            
            if (usuarioLogado == null) {
                message = "Você precisa estar logado para criar um registro.";
                response.sendRedirect("login.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
                return;
            }

            // 1. Instanciação e Dados Básicos
            Registro registro = new Registro();
            RegistroDAO dao = new RegistroDAO();
            
            // Verifica se é uma atualização (tem ID e ação 'atualizar')
            String acao = request.getParameter("acao");
            String idParam = request.getParameter("id");
            boolean isAtualizacao = "atualizar".equalsIgnoreCase(acao) && idParam != null && !idParam.isEmpty();

            if (isAtualizacao) {
                // Se for edição, precisamos preservar a imagem antiga caso o usuário não envie uma nova
                Long id = Long.parseLong(idParam);
                registro.setId(id);
                
                // Busca dados atuais para manter a foto se não for enviada uma nova
                byte[] imagemAtual = dao.getImagemById(id);
                if (imagemAtual != null) {
                    registro.setFotoStream(new ByteArrayInputStream(imagemAtual));
                }
            }

            registro.setUsuarioId(usuarioLogado.getId());
            registro.setTitulo(request.getParameter("titulo"));
            registro.setDescricao(request.getParameter("descricao"));
            registro.setLatitude(Double.parseDouble(request.getParameter("latitude")));
            registro.setLongitude(Double.parseDouble(request.getParameter("longitude")));
            
            // 2. Definição do Tipo
            Long tipoRegistroId = Long.parseLong(request.getParameter("tipoRegistroId"));
            TipoRegistro tipo = new TipoRegistro();
            tipo.setId(tipoRegistroId);
            registro.setTipoRegistro(tipo);

            // 3. Definição do Status
            // Se o admin enviou um status, usa ele. Se não, usa "PENDENTE"
            String statusParam = request.getParameter("status");
            if (statusParam != null && !statusParam.isEmpty()) {
                registro.setStatus(statusParam);
            } else {
                registro.setStatus("PENDENTE");
            }

            // 4. Processamento da Imagem (Upload)
            Part filePart = request.getPart("foto"); 
            byte[] imagemBytes = null;
            
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
                // Sobrescreve a foto (nova ou antiga) com a nova enviada
                registro.setFotoStream(new ByteArrayInputStream(imagemBytes));
            } else if (isAtualizacao) {
                // Se for atualização e não enviou foto nova, precisamos ler os bytes da antiga para variáveis locais
                imagemBytes = dao.getImagemById(registro.getId());
            }

            registro.setData(new Date()); // Atualiza a data da última modificação

            // 5. Execução no Banco de Dados (Inserir ou Atualizar)
            Long registroId = null;

            if (isAtualizacao) {
                // Lógica de ATUALIZAÇÃO
                sucesso = dao.atualizar(registro);
                if (sucesso) registroId = registro.getId();
                message = sucesso ? "Registro atualizado com sucesso!" : "Erro ao atualizar registro.";
            } else {
                // Lógica de INSERÇÃO
                registroId = dao.inserir(registro);
                sucesso = (registroId != null);
                message = sucesso ? "Registro criado com sucesso!" : "Erro ao criar registro.";
            }

            // 6. Lógica Opcional: Criar Post no Blog Automaticamente
            if (sucesso) {
                String criarPost = request.getParameter("criarPost");
                
                if ("on".equals(criarPost)) {
                    Blog post = new Blog();
                    post.setTitulo("Relato: " + registro.getTitulo());
                    post.setDescricao(registro.getDescricao());
                    post.setUsuarioId(usuarioLogado.getId());
                    post.setRegistroId(registroId); // Usa o ID (novo ou existente)
                    post.setStatusPublicacao("PUBLICADO");
                    post.setDataPublicacao(new Date());
                    
                    // Usa a imagem processada (nova ou a recuperada do banco na edição)
                    if (imagemBytes != null) {
                        post.setFotoCapaStream(new ByteArrayInputStream(imagemBytes));
                    }
                    
                    new BlogDAO().inserir(post);
                    message += " E postado no Blog!";
                }
            }

        } catch (Exception e) {
            message = "ERRO: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (!response.isCommitted()) {
                String encodedMessage = URLEncoder.encode(message, "UTF-8");
                String redirectPage = (origem != null && origem.equals("admin")) ? "admin.jsp" : "mapa.jsp";
                
                // Mantém na aba correta se for admin
                if(redirectPage.equals("admin.jsp")) {
                    redirectPage += "?tab=registros&";
                } else {
                    redirectPage += "?";
                }

                if (sucesso) {
                    response.sendRedirect(redirectPage + "sucesso=" + encodedMessage);
                } else {
                    response.sendRedirect(redirectPage + "erro=" + encodedMessage);
                }
            }
        }
    }
}