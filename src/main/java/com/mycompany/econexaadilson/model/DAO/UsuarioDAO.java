/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.econexaadilson.model.DAO;

import com.mycompany.econexaadilson.model.config.ConexaoBanco;
import com.mycompany.econexaadilson.model.Usuario;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object (DAO) para a entidade Usuario.
 * Responsável por toda a comunicação entre a aplicação e a tabela 'usuarios'
 * no banco de dados, implementando operações CRUD (Criar, Ler, Atualizar, Deletar)
 * e métodos de busca específicos.
 */

public class UsuarioDAO {
    
    /**
     * Busca um usuário pelo e-mail E verifica se ele está ATIVO no sistema.
     * CRÍTICO para o fluxo de LOGIN e AUTENTICAÇÃO.
     * * @param email O e-mail do usuário.
     * @return O objeto Usuario se encontrado e ATIVO, ou null.
     */
    public Usuario buscarAtivoPorEmail(String email) {
        // Consulta SQL exige que o status seja 'ATIVO'
        String sql = "SELECT * FROM usuarios WHERE email = ? AND status = 'ATIVO'";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return criarUsuarioFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("Erro ao buscar usuário ativo por email: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Busca um usuário pelo ID, independentemente do seu status (ATIVO/INATIVO).
     * Usado principalmente por processos internos (ex: Admin, Edição de Perfil).
     * * @param id O ID do usuário.
     * @return O objeto Usuario se encontrado, ou null.
     */
    public Usuario buscarPorId(Long id) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return criarUsuarioFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.err.println("Erro ao buscar usuário por ID: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Insere um novo usuário. O 'status' é definido por padrão como 'ATIVO'.
     * @param usuario O objeto Usuario.
     * @return true se a inserção for bem-sucedida.
     */
    public boolean inserir(Usuario usuario) {
        // Inclui o campo 'status' com valor padrão 'ATIVO' (ou o valor setado no objeto)
        String sql = "INSERT INTO usuarios (nome, email, senha_hash, perfil, status) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, usuario.getNome());
            stmt.setString(2, usuario.getEmail());
            stmt.setString(3, usuario.getSenhaHash());
            stmt.setString(4, usuario.getPerfil());
            // Garante que o status seja ATIVO por padrão, a menos que o objeto o defina.
            stmt.setString(5, (usuario.getStatus() != null ? usuario.getStatus() : "ATIVO")); 
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Erro ao inserir usuário: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * **ADMINISTRATION / CRUD**
     * Lista TODOS os usuários que estão ATIVOS no sistema.
     * Esta lista será usada na tela de Gerenciamento de Usuários do Admin.
     * * @return Uma lista de objetos Usuario com status 'ATIVO'.
     */
    public List<Usuario> listarAtivos() {
        List<Usuario> usuarios = new ArrayList<>();
        // Filtra apenas por status = 'ATIVO'
        String sql = "SELECT * FROM usuarios WHERE status = 'ATIVO' ORDER BY nome";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                usuarios.add(criarUsuarioFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.err.println("Erro ao listar usuários ativos: " + e.getMessage());
        }
        return usuarios;
    }
    
    /**
     * **ADMINISTRATION: INATIVAR USUÁRIO (Exclusão Lógica)**
     * Altera o status do usuário para 'INATIVO'.
     * @param id O ID do usuário a ser inativado.
     * @return true se o status foi atualizado com sucesso.
     */
    public boolean inativar(Long id) {
        String sql = "UPDATE usuarios SET status = 'INATIVO' WHERE id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, id);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Erro ao inativar usuário: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * **ADMINISTRATION / PERFIL**
     * Atualiza o nome, email, senha (hash) e perfil (uso administrativo) de um usuário.
     * @param usuario O objeto Usuario contendo os novos dados e o ID.
     * @return true se a atualização for bem-sucedida.
     */
    public boolean atualizar(Usuario usuario) {
        // Atualiza todos os campos de edição, exceto data de criação e ID
        String sql = "UPDATE usuarios SET nome = ?, email = ?, senha_hash = ?, perfil = ? WHERE id = ?";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, usuario.getNome());
            stmt.setString(2, usuario.getEmail());
            stmt.setString(3, usuario.getSenhaHash());
            stmt.setString(4, usuario.getPerfil());
            stmt.setLong(5, usuario.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Erro ao atualizar dados do usuário: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Método auxiliar privado para mapear um registro do banco de dados (ResultSet)
     * para um objeto Usuario.
     * @param rs O ResultSet posicionado no registro a ser mapeado.
     * @return O objeto Usuario preenchido.
     */
    private Usuario criarUsuarioFromResultSet(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setId(rs.getLong("id"));
        usuario.setNome(rs.getString("nome"));
        usuario.setEmail(rs.getString("email"));
        usuario.setSenhaHash(rs.getString("senha_hash"));
        usuario.setPerfil(rs.getString("perfil"));
        usuario.setStatus(rs.getString("status")); // Mapeia o novo campo STATUS
        usuario.setDataCriacao(rs.getTimestamp("data_criacao"));
        return usuario;
    }
}