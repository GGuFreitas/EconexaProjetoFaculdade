package com.mycompany.econexaadilson.model.DAO;

/**
 * DAO para gerenciamento de Tipos de Registro
 * @author Gustavo de Freitas
 * @author Gustavo Freitas - Documentação
 */
import com.mycompany.econexaadilson.model.config.ConexaoBanco;
import com.mycompany.econexaadilson.model.TipoRegistro;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TipoRegistroDAO {
        /**
        * Insere um novo tipo de registro
        * @param tipo Objeto TipoRegistro com dados do tipo
        * @return true se inserção foi bem sucedida
        */
    public boolean inserir(TipoRegistro tipo) {
        String sql = "INSERT INTO tipo_registro (nome, categoria, descricao, icone) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, tipo.getNome());
            stmt.setString(2, tipo.getCategoria());
            stmt.setString(3, tipo.getDescricao());
            stmt.setString(4, tipo.getIcone());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    /**
     * Lista todos os tipos de registro ordenados por categoria e nome
     * @return Lista de tipos de registro
     */    
    public List<TipoRegistro> listarTodos() {
        List<TipoRegistro> tipos = new ArrayList<>();
        String sql = "SELECT * FROM tipo_registro ORDER BY categoria, nome";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                TipoRegistro tipo = new TipoRegistro();
                tipo.setId(rs.getLong("id"));
                tipo.setNome(rs.getString("nome"));
                tipo.setCategoria(rs.getString("categoria"));
                tipo.setDescricao(rs.getString("descricao"));
                tipo.setIcone(rs.getString("icone"));
                tipos.add(tipo);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tipos;
    }
    /**
     * Busca um tipo de registro específico pelo ID
     * @param id ID do tipo de registro
     * @return Objeto TipoRegistro ou null se não encontrado
     */
    public TipoRegistro buscarPorId(Long id) {
        String sql = "SELECT * FROM tipo_registro WHERE id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                TipoRegistro tipo = new TipoRegistro();
                tipo.setId(rs.getLong("id"));
                tipo.setNome(rs.getString("nome"));
                tipo.setCategoria(rs.getString("categoria"));
                tipo.setDescricao(rs.getString("descricao"));
                tipo.setIcone(rs.getString("icone"));
                return tipo;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
     /**
     * Atualiza um tipo de registro existente
     * @param tipo Objeto TipoRegistro com dados atualizados
     * @return true se atualização foi bem sucedida
     */
    public boolean atualizar(TipoRegistro tipo) {
        String sql = "UPDATE tipo_registro SET nome = ?, categoria = ?, descricao = ?, icone = ? WHERE id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, tipo.getNome());
            stmt.setString(2, tipo.getCategoria());
            stmt.setString(3, tipo.getDescricao());
            stmt.setString(4, tipo.getIcone());
            stmt.setLong(5, tipo.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
     /**
     * Exclui um tipo de registro pelo ID
     * @param id ID do tipo de registro a ser excluído
     * @return true se exclusão foi bem sucedida
     */    
    public boolean excluir(Long id) {
        String sql = "DELETE FROM tipo_registro WHERE id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}