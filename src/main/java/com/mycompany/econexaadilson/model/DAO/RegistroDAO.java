/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.econexaadilson.model.DAO;

import com.mycompany.econexaadilson.model.Registro;
import com.mycompany.econexaadilson.model.TipoRegistro;
import com.mycompany.econexaadilson.model.Usuario;
import com.mycompany.econexaadilson.model.config.ConexaoBanco;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author gufre
 */
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

                if (registro.getTipoRegistro() != null) {
                    stmt.setLong(8, registro.getTipoRegistro().getId());
                } else {
                    return null;
                }

                // NOVO: usuario_id
                if (registro.getUsuario() != null) {
                    stmt.setLong(9, registro.getUsuario().getId());
                } else {
                    stmt.setNull(9, java.sql.Types.BIGINT);
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
     // Verificar se há nova foto
     boolean temNovaFoto = (registro.getFotoStream() != null) || 
                           (registro.getFotoBytes() != null && registro.getFotoBytes().length > 0);

     String sql;
     if (temNovaFoto) {
         sql = "UPDATE registro SET titulo=?, descricao=?, latitude=?, longitude=?, foto=?, status=?, tipo_registro_id=? WHERE id=?";
     } else {
         sql = "UPDATE registro SET titulo=?, descricao=?, latitude=?, longitude=?, status=?, tipo_registro_id=? WHERE id=?";
     }

     try (Connection conn = ConexaoBanco.getConnection();
          PreparedStatement stmt = conn.prepareStatement(sql)) {

         int paramIndex = 1;
         stmt.setString(paramIndex++, registro.getTitulo());
         stmt.setString(paramIndex++, registro.getDescricao());
         stmt.setDouble(paramIndex++, registro.getLatitude());
         stmt.setDouble(paramIndex++, registro.getLongitude());

         if (temNovaFoto) {
             if (registro.getFotoStream() != null) {
                 stmt.setBlob(paramIndex++, registro.getFotoStream());
             } else if (registro.getFotoBytes() != null && registro.getFotoBytes().length > 0) {
                 stmt.setBytes(paramIndex++, registro.getFotoBytes());
             } else {
                 stmt.setNull(paramIndex++, java.sql.Types.BLOB);
             }
         }

         stmt.setString(paramIndex++, registro.getStatus());
         stmt.setLong(paramIndex++, registro.getTipoRegistro().getId());
         stmt.setLong(paramIndex++, registro.getId());

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
        String sql = "SELECT r.id, r.titulo, r.descricao, r.data, r.latitude, r.longitude, r.status, " +
                     "tr.id as tipo_id, tr.nome as tipo_nome, tr.categoria as tipo_categoria, " +
                     "u.id as usuario_id, u.nome as usuario_nome, u.email as usuario_email " + // NOVO
                     "FROM registro r " +
                     "JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                     "JOIN usuarios u ON r.usuario_id = u.id " + // NOVO
                     "ORDER BY r.data DESC";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Registro registro = new Registro();
                registro.setId(rs.getLong("id"));
                registro.setTitulo(rs.getString("titulo"));
                registro.setDescricao(rs.getString("descricao"));
                registro.setData(rs.getTimestamp("data"));
                registro.setLatitude(rs.getDouble("latitude"));
                registro.setLongitude(rs.getDouble("longitude"));
                registro.setStatus(rs.getString("status"));

                TipoRegistro tipo = new TipoRegistro();
                tipo.setId(rs.getLong("tipo_id"));
                tipo.setNome(rs.getString("tipo_nome"));
                tipo.setCategoria(rs.getString("tipo_categoria"));
                registro.setTipoRegistro(tipo);

                // NOVO: Usuário
                Usuario usuario = new Usuario();
                usuario.setId(rs.getLong("usuario_id"));
                usuario.setNome(rs.getString("usuario_nome"));
                usuario.setEmail(rs.getString("usuario_email"));
                registro.setUsuario(usuario);

                registros.add(registro);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return registros;
    }

    public Registro buscarPorId(Long id) {
        String sql = "SELECT r.id, r.titulo, r.descricao, r.data, r.latitude, r.longitude, r.status, " +
                     "tr.id as tipo_id, tr.nome as tipo_nome, tr.categoria as tipo_categoria, " +
                     "u.id as usuario_id, u.nome as usuario_nome, u.email as usuario_email " + // NOVO
                     "FROM registro r " +
                     "JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                     "JOIN usuarios u ON r.usuario_id = u.id " + // NOVO
                     "WHERE r.id = ?";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Registro registro = new Registro();
                    registro.setId(rs.getLong("id"));
                    registro.setTitulo(rs.getString("titulo"));
                    registro.setDescricao(rs.getString("descricao"));
                    registro.setData(rs.getTimestamp("data"));
                    registro.setLatitude(rs.getDouble("latitude"));
                    registro.setLongitude(rs.getDouble("longitude"));
                    registro.setStatus(rs.getString("status"));

                    TipoRegistro tipo = new TipoRegistro();
                    tipo.setId(rs.getLong("tipo_id"));
                    tipo.setNome(rs.getString("tipo_nome"));
                    tipo.setCategoria(rs.getString("tipo_categoria"));
                    registro.setTipoRegistro(tipo);

                    // NOVO: Usuário
                    Usuario usuario = new Usuario();
                    usuario.setId(rs.getLong("usuario_id"));
                    usuario.setNome(rs.getString("usuario_nome"));
                    usuario.setEmail(rs.getString("usuario_email"));
                    registro.setUsuario(usuario);

                    return registro;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    public List<Registro> listarPorUsuario(Long usuarioId) {
        List<Registro> registros = new ArrayList<>();
        String sql = "SELECT r.id, r.titulo, r.descricao, r.data, r.latitude, r.longitude, r.status, " +
                     "tr.id as tipo_id, tr.nome as tipo_nome, tr.categoria as tipo_categoria, " +
                     "u.id as usuario_id, u.nome as usuario_nome, u.email as usuario_email " +
                     "FROM registro r " +
                     "JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                     "JOIN usuarios u ON r.usuario_id = u.id " +
                     "WHERE r.usuario_id = ? " +
                     "ORDER BY r.data DESC";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, usuarioId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Registro registro = new Registro();
                    registro.setId(rs.getLong("id"));
                    registro.setTitulo(rs.getString("titulo"));
                    registro.setDescricao(rs.getString("descricao"));
                    registro.setData(rs.getTimestamp("data"));
                    registro.setLatitude(rs.getDouble("latitude"));
                    registro.setLongitude(rs.getDouble("longitude"));
                    registro.setStatus(rs.getString("status"));

                    TipoRegistro tipo = new TipoRegistro();
                    tipo.setId(rs.getLong("tipo_id"));
                    tipo.setNome(rs.getString("tipo_nome"));
                    tipo.setCategoria(rs.getString("tipo_categoria"));
                    registro.setTipoRegistro(tipo);

                    Usuario usuario = new Usuario();
                    usuario.setId(rs.getLong("usuario_id"));
                    usuario.setNome(rs.getString("usuario_nome"));
                    usuario.setEmail(rs.getString("usuario_email"));
                    registro.setUsuario(usuario);

                    registros.add(registro);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return registros;
    }
    public byte[] getImagemById(Long registroId) {
        String sql = "SELECT foto FROM registro WHERE id = ?";
        byte[] imgBytes = null;
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, registroId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Blob blob = rs.getBlob("foto");
                    if (blob != null) {
                        imgBytes = blob.getBytes(1, (int) blob.length());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return imgBytes;
    }
}