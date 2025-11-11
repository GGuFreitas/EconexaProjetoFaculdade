package com.mycompany.econexaadilson.model.DAO;

import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.config.ConexaoBanco; // Presumo que você tenha esta classe

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class BlogDAO {

    /**
     * Lista todos os posts que estão marcados como 'PUBLICADO'.
     * Também busca o nome do autor.
     */
    public List<Blog> listarTodosPublicados() {
        List<Blog> posts = new ArrayList<>();
        // Query faz JOIN com usuarios para pegar o nome
        String sql = "SELECT bp.*, u.nome as nome_autor " +
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
                post.setFotoCapa(rs.getString("foto_capa"));
                post.setStatusPublicacao(rs.getString("status_publicacao"));
                post.setDataPublicacao(rs.getTimestamp("data_publicacao"));
                post.setUsuarioId(rs.getLong("usuario_id"));
                post.setRegistroId(rs.getLong("registro_id"));
                
                // Campo do JOIN
                post.setNomeAutor(rs.getString("nome_autor")); 
                
                posts.add(post);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Em um app real, logar o erro
        }
        return posts;
    }

    /**
     * Insere um novo post no blog.
     */
    public boolean inserir(Blog post) {
        String sql = "INSERT INTO blog_post (titulo, descricao, foto_capa, status_publicacao, usuario_id, registro_id, data_publicacao) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, post.getTitulo());
            stmt.setString(2, post.getDescricao());
            stmt.setString(3, post.getFotoCapa());
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
}