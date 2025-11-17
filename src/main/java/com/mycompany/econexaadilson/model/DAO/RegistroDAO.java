package com.mycompany.econexaadilson.model.DAO;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author gufre
 */
import com.mycompany.econexaadilson.model.config.ConexaoBanco;
import com.mycompany.econexaadilson.model.Registro;
import com.mycompany.econexaadilson.model.TipoRegistro;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RegistroDAO {
    
   public boolean inserir(Registro registro) {
        String sql = "INSERT INTO registro (titulo, descricao, data, latitude, longitude, foto, status, tipo_registro_id) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, registro.getTitulo());
            stmt.setString(2, registro.getDescricao());
            stmt.setTimestamp(3, new Timestamp(registro.getData().getTime()));
            stmt.setDouble(4, registro.getLatitude());
            stmt.setDouble(5, registro.getLongitude());
            
            // Modificado para BLOB
            if (registro.getFotoStream() != null) {
                stmt.setBlob(6, registro.getFotoStream());
            } else {
                stmt.setNull(6, java.sql.Types.BLOB);
            }
            
            stmt.setString(7, registro.getStatus());
            stmt.setLong(8, registro.getTipoRegistro().getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
   
   
     // Método para buscar imagem por ID do registro
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
   
    
    public List<Registro> listarTodos() {
        List<Registro> registros = new ArrayList<>();
        String sql = "SELECT r.*, tr.nome as tipo_nome, tr.categoria as tipo_categoria, " +
                    "tr.descricao as tipo_descricao, tr.icone as tipo_icone " +
                    "FROM registro r " +
                    "INNER JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
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
                tipo.setId(rs.getLong("tipo_registro_id"));
                tipo.setNome(rs.getString("tipo_nome"));
                tipo.setCategoria(rs.getString("tipo_categoria"));
                tipo.setDescricao(rs.getString("tipo_descricao"));
                tipo.setIcone(rs.getString("tipo_icone"));
                
                registro.setTipoRegistro(tipo);
                registros.add(registro);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return registros;
    }
    
       public Registro buscarPorIdComImagem(Long id) {
        String sql = "SELECT r.*, tr.nome as tipo_nome, tr.categoria as tipo_categoria, " +
                    "tr.descricao as tipo_descricao, tr.icone as tipo_icone " +
                    "FROM registro r " +
                    "INNER JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                    "WHERE r.id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Registro registro = new Registro();
                registro.setId(rs.getLong("id"));
                registro.setTitulo(rs.getString("titulo"));
                registro.setDescricao(rs.getString("descricao"));
                registro.setData(rs.getTimestamp("data"));
                registro.setLatitude(rs.getDouble("latitude"));
                registro.setLongitude(rs.getDouble("longitude"));
                registro.setStatus(rs.getString("status"));
                
                // Carrega a imagem
                Blob blob = rs.getBlob("foto");
                if (blob != null) {
                    registro.setFotoBytes(blob.getBytes(1, (int) blob.length()));
                }
                
                TipoRegistro tipo = new TipoRegistro();
                tipo.setId(rs.getLong("tipo_registro_id"));
                tipo.setNome(rs.getString("tipo_nome"));
                tipo.setCategoria(rs.getString("tipo_categoria"));
                tipo.setDescricao(rs.getString("tipo_descricao"));
                tipo.setIcone(rs.getString("tipo_icone"));
                
                registro.setTipoRegistro(tipo);
                return registro;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
        public Registro buscarPorId(Long id) {
        String sql = "SELECT r.*, tr.nome as tipo_nome, tr.categoria as tipo_categoria, " +
                    "tr.descricao as tipo_descricao, tr.icone as tipo_icone " +
                    "FROM registro r " +
                    "INNER JOIN tipo_registro tr ON r.tipo_registro_id = tr.id " +
                    "WHERE r.id = ?";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();

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
                tipo.setId(rs.getLong("tipo_registro_id"));
                tipo.setNome(rs.getString("tipo_nome"));
                tipo.setCategoria(rs.getString("tipo_categoria"));
                tipo.setDescricao(rs.getString("tipo_descricao"));
                tipo.setIcone(rs.getString("tipo_icone"));

                registro.setTipoRegistro(tipo);
                return registro;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
        public boolean atualizar(Registro registro) {
            String sql = "UPDATE registro SET titulo = ?, descricao = ?, data = ?, " +
                        "latitude = ?, longitude = ?, status = ?, tipo_registro_id = ? " +
                        "WHERE id = ?";

            try (Connection conn = ConexaoBanco.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {

                stmt.setString(1, registro.getTitulo());
                stmt.setString(2, registro.getDescricao());
                stmt.setTimestamp(3, new Timestamp(registro.getData().getTime()));
                stmt.setDouble(4, registro.getLatitude());
                stmt.setDouble(5, registro.getLongitude());
                stmt.setString(6, registro.getStatus()); // Corrigido: era 7
                stmt.setLong(7, registro.getTipoRegistro().getId()); // Corrigido: era 8
                stmt.setLong(8, registro.getId()); // Corrigido: era 9

                return stmt.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }
    
    public boolean excluir(Long id) {
        String sql = "DELETE FROM registro WHERE id = ?";
        
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
