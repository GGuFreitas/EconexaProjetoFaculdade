/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.econexaadilson.model.DAO;

/**
 *
 * @author gufre
 */
import com.mycompany.econexaadilson.model.TipoRegistro;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TipoRegistroDAO {
    
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