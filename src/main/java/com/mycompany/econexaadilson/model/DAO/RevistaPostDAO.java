/**
 *
 * @author Jhonny
 */

package com.mycompany.econexaadilson.model.DAO;

import com.mycompany.econexaadilson.model.RevistaPost;
import com.mycompany.econexaadilson.model.config.ConexaoBanco;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RevistaPostDAO {

    public boolean inserir(RevistaPost post) {
        String sql = "INSERT INTO revista_post (titulo, descricao, foto_capa, autor, usuario_id, data_publicacao) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, post.getTitulo());
            stmt.setString(2, post.getDescricao());
            if (post.getFotoCapaStream() != null) {
                stmt.setBlob(3, post.getFotoCapaStream());
            } else {
                stmt.setNull(3, java.sql.Types.BLOB);
            }
            stmt.setString(4, post.getAutor());
            stmt.setLong(5, post.getUsuarioId());
            stmt.setTimestamp(6, new Timestamp(new java.util.Date().getTime()));
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean atualizar(RevistaPost post) {
        String sql = "UPDATE revista_post SET titulo=?, descricao=?, autor=? WHERE id=?";
        
        // Se houver foto nova, atualiza também a foto
        if (post.getFotoCapaStream() != null) {
            sql = "UPDATE revista_post SET titulo=?, descricao=?, autor=?, foto_capa=? WHERE id=?";
        }

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, post.getTitulo());
            stmt.setString(2, post.getDescricao());
            stmt.setString(3, post.getAutor());
            
            if (post.getFotoCapaStream() != null) {
                stmt.setBlob(4, post.getFotoCapaStream());
                stmt.setLong(5, post.getId());
            } else {
                stmt.setLong(4, post.getId());
            }
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean excluir(Long id) {
        String sql = "DELETE FROM revista_post WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public RevistaPost buscarPorId(Long id) {
        String sql = "SELECT * FROM revista_post WHERE id = ?";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                RevistaPost p = new RevistaPost();
                p.setId(rs.getLong("id"));
                p.setTitulo(rs.getString("titulo"));
                p.setDescricao(rs.getString("descricao"));
                p.setAutor(rs.getString("autor"));
                p.setUsuarioId(rs.getLong("usuario_id"));
                p.setDataPublicacao(rs.getTimestamp("data_publicacao"));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<RevistaPost> listarTodos() {
        List<RevistaPost> posts = new ArrayList<>();
        String sql = "SELECT r.*, u.nome as nome_criador FROM revista_post r JOIN usuarios u ON r.usuario_id = u.id ORDER BY r.data_publicacao DESC";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                RevistaPost p = new RevistaPost();
                p.setId(rs.getLong("id"));
                p.setTitulo(rs.getString("titulo"));
                p.setDescricao(rs.getString("descricao"));
                p.setAutor(rs.getString("autor"));
                p.setDataPublicacao(rs.getTimestamp("data_publicacao"));
                p.setUsuarioId(rs.getLong("usuario_id"));
                p.setNomeUsuarioCriador(rs.getString("nome_criador"));
                posts.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }
    
    public byte[] getImagemById(Long id) {
        String sql = "SELECT foto_capa FROM revista_post WHERE id = ?";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Blob blob = rs.getBlob("foto_capa");
                if (blob != null) {
                    return blob.getBytes(1, (int) blob.length());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}