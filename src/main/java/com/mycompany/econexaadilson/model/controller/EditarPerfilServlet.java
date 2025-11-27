/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.Usuario;
import com.mycompany.econexaadilson.model.DAO.UsuarioDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.net.URLEncoder;
import org.mindrot.jbcrypt.BCrypt;

/**
 * Servlet responsável por processar a requisição de edição de perfil do usuário.
 * Lida com a validação da nova senha e realiza o hashing BCrypt antes de
 * atualizar os dados no banco.
 */

@WebServlet("/EditarPerfil")
public class EditarPerfilServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String message = null;
        boolean sucesso = false;
        
        // 1. OBTÉM A SESSÃO E O USUÁRIO LOGADO
        HttpSession session = request.getSession();
        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");

        // Validação de segurança
        if (usuarioLogado == null) {
            response.sendRedirect("login.jsp?erro=" + URLEncoder.encode("Sessão expirada. Faça login novamente.", "UTF-8"));
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();
        Usuario usuarioParaAtualizar = new Usuario();

        try {
            // Define o ID (imutável)
            usuarioParaAtualizar.setId(usuarioLogado.getId()); 
            
            // 2. OBTÉM DADOS DO FORMULÁRIO
            String novoNome = request.getParameter("nome");
            String novoEmail = request.getParameter("email");
            String novaSenha = request.getParameter("senha"); 
            String confirmaSenha = request.getParameter("confirmaSenha");
            
            // Define nome e email
            usuarioParaAtualizar.setNome(novoNome);
            usuarioParaAtualizar.setEmail(novoEmail);

            usuarioParaAtualizar.setPerfil(usuarioLogado.getPerfil()); 

            // 3. LÓGICA DE ATUALIZAÇÃO DE SENHA
            if (novaSenha != null && !novaSenha.trim().isEmpty()) {
                // Senha fornecida: Validar e Hashear
                if (!novaSenha.equals(confirmaSenha)) {
                    message = "Erro: A nova senha e a confirmação de senha não coincidem.";
                    response.sendRedirect("meuPerfil.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
                    return;
                }
                
                String senhaHasheada = BCrypt.hashpw(novaSenha, BCrypt.gensalt());
                usuarioParaAtualizar.setSenhaHash(senhaHasheada);
                
            } else {
                // Senha NÃO fornecida: Manter a antiga
                Usuario usuarioExistente = dao.buscarPorId(usuarioLogado.getId());
                
                if (usuarioExistente != null) {
                    usuarioParaAtualizar.setSenhaHash(usuarioExistente.getSenhaHash());
                } else {
                    message = "Erro interno: Não foi possível carregar os dados originais do usuário.";
                    response.sendRedirect("meuPerfil.jsp?erro=" + URLEncoder.encode(message, "UTF-8"));
                    return;
                }
            }
            
            // 4. ATUALIZAÇÃO NO BANCO DE DADOS
            sucesso = dao.atualizar(usuarioParaAtualizar);

            if (sucesso) {
                // 5. SUCESSO: Atualiza o objeto da sessão
                // Buscamos o objeto completo atualizado do banco para garantir integridade
                Usuario usuarioAtualizado = dao.buscarPorId(usuarioLogado.getId());
                
                if(usuarioAtualizado != null){
                    usuarioAtualizado.setSenhaHash(null); // Segurança: não deixar hash na sessão
                    session.setAttribute("usuarioLogado", usuarioAtualizado);
                }
                
                message = "Seus dados foram atualizados com sucesso!";
            } else {
                message = "Erro ao atualizar dados. O e-mail pode já estar em uso.";
            }

        } catch (Exception e) {
            message = "ERRO INTERNO: " + e.getMessage();
            e.printStackTrace();
        } finally {
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            String redirectUrl = sucesso ? "meuPerfil.jsp?sucesso=" + encodedMessage : "meuPerfil.jsp?erro=" + encodedMessage;
            response.sendRedirect(redirectUrl);
        }
    }
}