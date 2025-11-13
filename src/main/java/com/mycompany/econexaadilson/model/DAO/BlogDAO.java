/**
 *
 * @author Jhonny
 */

package com.mycompany.econexaadilson.model.DAO;

import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.config.ConexaoBanco;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogDAO {

    public List<Blog> listarTodosPublicados() {
        List<Blog> posts = new ArrayList<>();
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor " +
                     "FROM blog_post bp " +
                     "JOIN usuarios u ON bp.usuario_id = u.id " +
                     "WHERE bp.status_publicacao = 'PUBLICADO' " +
                     "ORDER BY bp.data_publicacao DESC";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Blog post = new Blog();
                post.setId(rs.getLong("id"));
                post.setTitulo(rs.getString("titulo"));
                post.setDescricao(rs.getString("descricao"));
                post.setStatusPublicacao(rs.getString("status_publicacao"));
                post.setDataPublicacao(rs.getTimestamp("data_publicacao"));
                post.setUsuarioId(rs.getLong("usuario_id"));
                post.setRegistroId(rs.getLong("registro_id"));
                post.setNomeAutor(rs.getString("nome_autor")); // Campo do JOIN
                posts.add(post);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    public boolean inserir(Blog post) {
        String sql = "INSERT INTO blog_post (titulo, descricao, foto_capa, status_publicacao, usuario_id, registro_id, data_publicacao) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, post.getTitulo());
            stmt.setString(2, post.getDescricao());
            
            if (post.getFotoCapaStream() != null) {
                stmt.setBlob(3, post.getFotoCapaStream());
            } else {
                stmt.setNull(3, java.sql.Types.BLOB);
            }

            stmt.setString(4, post.getStatusPublicacao());
            stmt.setLong(5, post.getUsuarioId());
            if (post.getRegistroId() != null) {
                stmt.setLong(6, post.getRegistroId());
            } else {
                stmt.setNull(6, java.sql.Types.BIGINT);
            }
            stmt.setTimestamp(7, new Timestamp(post.getDataPublicacao().getTime()));

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public byte[] getImagemById(Long postId) {
        String sql = "SELECT foto_capa FROM blog_post WHERE id = ?";
        byte[] imgBytes = null;
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, postId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Blob blob = rs.getBlob("foto_capa");
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