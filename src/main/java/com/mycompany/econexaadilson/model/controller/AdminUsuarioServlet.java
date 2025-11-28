/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.mycompany.econexaadilson.model.controller;

import com.mycompany.econexaadilson.model.Usuario;
import com.mycompany.econexaadilson.model.DAO.UsuarioDAO;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;

/**
 * Servlet de controle para ações administrativas sobre usuários (Inativar/Editar).
 * Apenas acessível por usuários com perfil 'admin'.
 * @author Enzo Reis
 * Documentação elaborada por: Enzo Reis
 */
@WebServlet("/AdminUsuarioServlet")
public class AdminUsuarioServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Configuração de codificação
        request.setCharacterEncoding("UTF-8");
        String acao = request.getParameter("acao");
        String message = null;
        boolean sucesso = false;
        
        UsuarioDAO dao = new UsuarioDAO();
        
        // 1. Verificação de Permissão (Simplificada, o AuthFilter deveria complementar)
        Usuario usuarioLogado = (Usuario) request.getSession().getAttribute("usuarioLogado");
        if (usuarioLogado == null || !usuarioLogado.getPerfil().equalsIgnoreCase("admin")) {
             response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acesso negado. Apenas administradores.");
             return;
        }

        try {
            if ("inativar".equalsIgnoreCase(acao)) {
                // AÇÃO: INATIVAR USUÁRIO (Exclusão Lógica)
                Long id = Long.parseLong(request.getParameter("id"));
                sucesso = dao.inativar(id);
                message = sucesso ? "Usuário inativado (excluído logicamente) com sucesso." : "Erro ao inativar usuário.";
                
            } else if ("editar".equalsIgnoreCase(acao) && "POST".equalsIgnoreCase(request.getMethod())) {
                // AÇÃO: EDITAR DADOS DO USUÁRIO
                Long id = Long.parseLong(request.getParameter("id"));
                String nome = request.getParameter("nome");
                String email = request.getParameter("email");
                String perfil = request.getParameter("perfil");
                String novaSenha = request.getParameter("senha");
                
                Usuario usuarioParaAtualizar = dao.buscarPorId(id);

                if (usuarioParaAtualizar == null) {
                    message = "Erro: Usuário não encontrado para edição.";
                } else {
                    usuarioParaAtualizar.setNome(nome);
                    usuarioParaAtualizar.setEmail(email);
                    usuarioParaAtualizar.setPerfil(perfil);

                    // Lógica de senha: Hashear se fornecida, senão manter a hash existente
                    if (novaSenha != null && !novaSenha.trim().isEmpty()) {
                        // Hashear a nova senha antes de definir no objeto
                        String senhaHasheada = BCrypt.hashpw(novaSenha, BCrypt.gensalt());
                        usuarioParaAtualizar.setSenhaHash(senhaHasheada);
                    } 
                    // Se 'novaSenha' estiver vazia, o hash existente é mantido.
                    
                    sucesso = dao.atualizar(usuarioParaAtualizar);
                    message = sucesso ? "Dados do usuário atualizados com sucesso." : "Erro ao atualizar. Email pode estar duplicado.";
                }
            } else {
                message = "Ação ou método HTTP inválido.";
            }

        } catch (NumberFormatException | NullPointerException e) {
            message = "Erro de parâmetro: ID inválido ou faltando.";
            e.printStackTrace();
        } catch (Exception e) {
            message = "Erro interno: " + e.getMessage();
            e.printStackTrace();
        } finally {
            // Redireciona para a página admin.jsp com a aba correta e mensagem de status
            String encodedMessage = URLEncoder.encode(message, "UTF-8");
            String statusParam = sucesso ? "sucesso" : "erro";
            
            // Redireciona para a TAB de usuários (tab=usuarios)
            response.sendRedirect("admin.jsp?" + statusParam + "=" + encodedMessage + "&tab=usuarios");
        }
    }
}