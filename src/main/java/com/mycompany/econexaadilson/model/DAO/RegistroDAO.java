/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.econexaadilson.model.DAO;

/**
 * 
 * @author gufre
 */


import com.mycompany.econexaadilson.model.Registro;
import com.mycompany.econexaadilson.model.TipoRegistro;
import com.mycompany.econexaadilson.model.Usuario;
import com.mycompany.econexaadilson.model.config.ConexaoBanco;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RegistroDAO {

    public Long inserir(Registro registro) {
        String sql = "INSERT INTO registro (titulo, descricao, data, latitude, longitude, foto, status, tipo_registro_id, usuario_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, registro.getTitulo());
            stmt.setString(2, registro.getDescricao());
            stmt.setTimestamp(3, new Timestamp(registro.getData().getTime()));
            stmt.setDouble(4, registro.getLatitude());
            stmt.setDouble(5, registro.getLongitude());
            
            if (registro.getFotoStream() != null) {
                stmt.setBlob(6, registro.getFotoStream());
            } else {
                stmt.setNull(6, java.sql.Types.BLOB);
            }
            
            stmt.setString(7, registro.getStatus());
            stmt.setLong(8, registro.getTipoRegistro().getId());
            
            if (registro.getUsuarioId() != null) {
                stmt.setLong(9, registro.getUsuarioId());
            } else {
                stmt.setLong(9, 1); 
            }
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getLong(1);
                    }
                }
            }
            return null;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean atualizar(Registro registro) {
        String sql = "UPDATE registro SET titulo=?, descricao=?, data=?, latitude=?, longitude=?, status=?, tipo_registro_id=? WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, registro.getTitulo());
            stmt.setString(2, registro.getDescricao());
            stmt.setTimestamp(3, new Timestamp(registro.getData().getTime()));
            stmt.setDouble(4, registro.getLatitude());
            stmt.setDouble(5, registro.getLongitude());
            stmt.setString(6, registro.getStatus());
            stmt.setLong(7, registro.getTipoRegistro().getId());
            stmt.setLong(8, registro.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean excluir(Long id) {
        String sql = "DELETE FROM registro WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Registro> listarTodos() {
        List<Registro> registros = new ArrayList<>();
        String sql = "SELECT r.*, " +
                     "tr.id as tr_id, tr.nome as tr_nome, tr.categoria as tr_categoria, tr.icone as tr_icone, " +
                     "u.id as u_id, u.nome as u_nome, u.email as u_email " +
                     "FROM registro r " +
                     "JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                     "JOIN usuarios u ON r.usuario_id = u.id " + // JOIN com usuário
                     "ORDER BY r.data DESC";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                registros.add(criarRegistroFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return registros;
    }

    public List<Registro> listarPorUsuario(Long userId) {
        List<Registro> registros = new ArrayList<>();
        String sql = "SELECT r.*, " +
                     "tr.id as tr_id, tr.nome as tr_nome, tr.categoria as tr_categoria, tr.icone as tr_icone, " +
                     "u.id as u_id, u.nome as u_nome, u.email as u_email " +
                     "FROM registro r " +
                     "JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                     "JOIN usuarios u ON r.usuario_id = u.id " +
                     "WHERE r.usuario_id = ? " + // Filtro
                     "ORDER BY r.data DESC";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                registros.add(criarRegistroFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return registros;
    }

    public Registro buscarPorId(Long id) {
        String sql = "SELECT r.*, " +
                     "tr.id as tr_id, tr.nome as tr_nome, tr.categoria as tr_categoria, tr.icone as tr_icone, " +
                     "u.id as u_id, u.nome as u_nome, u.email as u_email " +
                     "FROM registro r " +
                     "JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                     "JOIN usuarios u ON r.usuario_id = u.id " +
                     "WHERE r.id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return criarRegistroFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public byte[] getImagemById(Long registroId) {
        String sql = "SELECT foto FROM registro WHERE id = ?";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, registroId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Blob blob = rs.getBlob("foto");
                    if (blob != null) {
                        return blob.getBytes(1, (int) blob.length());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Registro criarRegistroFromResultSet(ResultSet rs) throws SQLException {
        Registro r = new Registro();
        r.setId(rs.getLong("id"));
        r.setTitulo(rs.getString("titulo"));
        r.setDescricao(rs.getString("descricao"));
        r.setData(rs.getTimestamp("data"));
        r.setLatitude(rs.getDouble("latitude"));
        r.setLongitude(rs.getDouble("longitude"));
        r.setStatus(rs.getString("status"));
        r.setUsuarioId(rs.getLong("usuario_id"));

        TipoRegistro tipo = new TipoRegistro();
        tipo.setId(rs.getLong("tr_id"));
        tipo.setNome(rs.getString("tr_nome"));
        tipo.setCategoria(rs.getString("tr_categoria"));
        tipo.setIcone(rs.getString("tr_icone"));
        r.setTipoRegistro(tipo);
        
        Usuario u = new Usuario();
        u.setId(rs.getLong("u_id"));
        u.setNome(rs.getString("u_nome"));
        u.setEmail(rs.getString("u_email"));
        r.setUsuario(u);

        return r;
    }
}