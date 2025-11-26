package com.mycompany.econexaadilson.model.DAO;

import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.config.ConexaoBanco;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogDAO {

    public List<Blog> listarTodosPublicados(Long usuarioLogadoId) {
        List<Blog> posts = new ArrayList<>();
        
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id) as total_likes, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id AND usuario_id = ?) as curtiu, " +
                     "(SELECT COUNT(*) FROM post_salvos WHERE post_id = bp.id AND usuario_id = ?) as salvou " +
                     "FROM blog_post bp " +
                     "JOIN usuarios u ON bp.usuario_id = u.id " +
                     "WHERE bp.status_publicacao = 'PUBLICADO' " +
                     "ORDER BY bp.data_publicacao DESC";
                     
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            long idParaVerificacao = (usuarioLogadoId != null) ? usuarioLogadoId : -1;
            stmt.setLong(1, idParaVerificacao);
            stmt.setLong(2, idParaVerificacao);
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                posts.add(criarBlogFromResultSetCompleto(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    
    public List<Blog> listarPorUsuario(Long userId) {
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id) as total_likes, " +
                     "0 as curtiu, 0 as salvou " + 
                     "FROM blog_post bp " +
                     "JOIN usuarios u ON bp.usuario_id = u.id " +
                     "WHERE bp.usuario_id = ? " +
                     "ORDER BY bp.data_publicacao DESC";
        return executarQueryLista(sql, userId);
    }

    public List<Blog> listarCurtidosPorUsuario(Long userId) {
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id) as total_likes, " +
                     "1 as curtiu, " + 
                     "(SELECT COUNT(*) FROM post_salvos WHERE post_id = bp.id AND usuario_id = ?) as salvou " +
                     "FROM post_curtidas pc " +
                     "JOIN blog_post bp ON pc.post_id = bp.id " +
                     "JOIN usuarios u ON bp.usuario_id = u.id " +
                     "WHERE pc.usuario_id = ? " +
                     "ORDER BY pc.data_interacao DESC";
        return executarQueryListaDupla(sql, userId, userId);
    }

    public List<Blog> listarSalvosPorUsuario(Long userId) {
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id) as total_likes, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id AND usuario_id = ?) as curtiu, " +
                     "1 as salvou " + 
                     "FROM post_salvos ps " +
                     "JOIN blog_post bp ON ps.post_id = bp.id " +
                     "JOIN usuarios u ON bp.usuario_id = u.id " +
                     "WHERE ps.usuario_id = ? " +
                     "ORDER BY ps.data_interacao DESC";
        return executarQueryListaDupla(sql, userId, userId);
    }

    
    public boolean alternarCurtida(Long usuarioId, Long postId) {
        if(usuarioId == null || postId == null) return false;
        
        boolean jaCurtiu = verificarInteracao("post_curtidas", usuarioId, postId);
        String sql;
        
        if (jaCurtiu) {
            sql = "DELETE FROM post_curtidas WHERE usuario_id=? AND post_id=?";
        } else {
            sql = "INSERT INTO post_curtidas (usuario_id, post_id) VALUES (?, ?)";
        }
        return executarUpdateSimples(sql, usuarioId, postId);
    }

    public boolean alternarSalvar(Long usuarioId, Long postId) {
        if(usuarioId == null || postId == null) return false;
        
        boolean jaSalvou = verificarInteracao("post_salvos", usuarioId, postId);
        String sql;
        
        if (jaSalvou) {
            sql = "DELETE FROM post_salvos WHERE usuario_id=? AND post_id=?";
        } else {
            sql = "INSERT INTO post_salvos (usuario_id, post_id) VALUES (?, ?)";
        }
        return executarUpdateSimples(sql, usuarioId, postId);
    }


    public List<Blog> listarTodosAdmin() {
        List<Blog> posts = new ArrayList<>();
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor " +
                     "FROM blog_post bp JOIN usuarios u ON bp.usuario_id = u.id ORDER BY bp.data_publicacao DESC";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                 posts.add(criarBlogFromResultSetSimples(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return posts;
    }

    public boolean inserir(Blog post) {
        String sql = "INSERT INTO blog_post (titulo, descricao, foto_capa, status_publicacao, usuario_id, registro_id, data_publicacao) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, post.getTitulo()); 
            stmt.setString(2, post.getDescricao());
            if (post.getFotoCapaStream() != null) stmt.setBlob(3, post.getFotoCapaStream()); else stmt.setNull(3, java.sql.Types.BLOB);
            stmt.setString(4, post.getStatusPublicacao()); 
            stmt.setLong(5, post.getUsuarioId());
            if (post.getRegistroId() != null) stmt.setLong(6, post.getRegistroId()); else stmt.setNull(6, java.sql.Types.BIGINT);
            stmt.setTimestamp(7, new Timestamp(post.getDataPublicacao().getTime()));
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean atualizar(Blog post) {
        String sql = "UPDATE blog_post SET titulo=?, descricao=?, status_publicacao=? WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, post.getTitulo());
            stmt.setString(2, post.getDescricao());
            stmt.setString(3, post.getStatusPublicacao());
            stmt.setLong(4, post.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    public boolean excluir(Long id) {
        String sql = "DELETE FROM blog_post WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }

    public Blog buscarPorId(Long id) {
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor FROM blog_post bp JOIN usuarios u ON bp.usuario_id = u.id WHERE bp.id = ?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return criarBlogFromResultSetSimples(rs);
        } catch (SQLException e) {}
        return null;
    }

    public byte[] getImagemById(Long id) {
        String sql = "SELECT foto_capa FROM blog_post WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if(rs.next()) { Blob b = rs.getBlob(1); if(b!=null) return b.getBytes(1, (int)b.length()); }
        } catch (SQLException e) {}
        return null;
    }


    private boolean verificarInteracao(String tabela, Long usuarioId, Long postId) {
        String sql = "SELECT 1 FROM " + tabela + " WHERE usuario_id=? AND post_id=?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, usuarioId); stmt.setLong(2, postId);
            return stmt.executeQuery().next();
        } catch (SQLException e) { return false; }
    }

    private boolean executarUpdateSimples(String sql, Long usuarioId, Long postId) {
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, usuarioId); stmt.setLong(2, postId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private List<Blog> executarQueryLista(String sql, Long param) {
        List<Blog> posts = new ArrayList<>();
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, param); ResultSet rs = stmt.executeQuery();
            while (rs.next()) posts.add(criarBlogFromResultSetCompleto(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return posts;
    }
    
    private List<Blog> executarQueryListaDupla(String sql, Long param1, Long param2) {
        List<Blog> posts = new ArrayList<>();
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, param1); stmt.setLong(2, param2); ResultSet rs = stmt.executeQuery();
            while (rs.next()) posts.add(criarBlogFromResultSetCompleto(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return posts;
    }

    private Blog criarBlogFromResultSetCompleto(ResultSet rs) throws SQLException {
        Blog post = criarBlogFromResultSetSimples(rs);
        post.setTotalCurtidas(rs.getInt("total_likes"));
        post.setCurtidoPeloUsuario(rs.getInt("curtiu") > 0);
        post.setSalvoPeloUsuario(rs.getInt("salvou") > 0);
        return post;
    }

    private Blog criarBlogFromResultSetSimples(ResultSet rs) throws SQLException {
        Blog post = new Blog();
        post.setId(rs.getLong("id"));
        post.setTitulo(rs.getString("titulo"));
        post.setDescricao(rs.getString("descricao"));
        post.setStatusPublicacao(rs.getString("status_publicacao"));
        post.setDataPublicacao(rs.getTimestamp("data_publicacao"));
        post.setUsuarioId(rs.getLong("usuario_id"));
        post.setNomeAutor(rs.getString("nome_autor"));
        return post;
    }
}