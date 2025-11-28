package com.mycompany.econexaadilson.model.DAO;

/**
 * DAO (Data Access Object) para gerenciamento de posts do blog
 * Responsável por todas as operações de CRUD e interações com posts
 * @author Jhonny Brito
 * Documentação elaborada por: Gustavo Freitas
 */
import com.mycompany.econexaadilson.model.Blog;
import com.mycompany.econexaadilson.model.config.ConexaoBanco;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogDAO {
        /**
        * Lista todos os posts PUBLICADOS, incluindo informações de interação do usuário logado
        * @param usuarioLogadoId ID do usuário logado (pode ser null para usuários não logados)
        * @return Lista de posts publicados com informações de curtidas e salvos
        */
    public List<Blog> listarTodosPublicados(Long usuarioLogadoId) {
        List<Blog> posts = new ArrayList<>();
                    // Query complexa que inclui contagem de likes e verificação se o usuário curtiu/salvou cada post

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
    /**
     * Lista posts criados por um usuário específico
     * @param userId ID do usuário dono dos posts
     * @return Lista de posts do usuário
     */
    
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
    /**
     * Lista posts que um usuário curtiu
     * @param userId ID do usuário
     * @return Lista de posts curtidos pelo usuário
     */
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
    /**
     * Lista posts salvos por um usuário
     * @param userId ID do usuário
     * @return Lista de posts salvos pelo usuário
     */
    public List<Blog> listarSalvosPorUsuario(Long userId) {
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id) as total_likes, " +
                     "(SELECT COUNT(*) FROM post_curtidas WHERE post_id = bp.id AND usuario_id = ?) as curtiu, " +
                     "1 as salvou " + 
                     "FROM post_salvos ps " +
                     "JOIN blog_post bp ON ps.post_id = bp.id " +
                     "JOIN usuarios u ON bp.usuario_id = u.id " +
                     "WHERE ps.usuario_id = ? " +
                     "ORDER BY ps.data_interacao DESC"; // Ordena pela data do salvamento
        return executarQueryListaDupla(sql, userId, userId);
    }

    /**
     * Alterna o estado de curtida de um post (curtir/descurtir)
     * @param usuarioId ID do usuário
     * @param postId ID do post
     * @return true se a operação foi bem sucedida
     */
    public boolean alternarCurtida(Long usuarioId, Long postId) {
        if(usuarioId == null || postId == null) return false;
        // Verifica se o usuário já curtiu o post
        boolean jaCurtiu = verificarInteracao("post_curtidas", usuarioId, postId);
        String sql;
        
        if (jaCurtiu) {
            
            sql = "DELETE FROM post_curtidas WHERE usuario_id=? AND post_id=?"; // Remove a curtida existente
        } else {
            sql = "INSERT INTO post_curtidas (usuario_id, post_id) VALUES (?, ?)"; // Adiciona nova curtida
        }
        return executarUpdateSimples(sql, usuarioId, postId);
    }
    /**
     * Alterna o estado de salvamento de um post (salvar/remover dos salvos)
     * @param usuarioId ID do usuário
     * @param postId ID do post
     * @return true se a operação foi bem sucedida
     */
    public boolean alternarSalvar(Long usuarioId, Long postId) {
        if(usuarioId == null || postId == null) return false;
        
        boolean jaSalvou = verificarInteracao("post_salvos", usuarioId, postId);
        String sql;
        
        if (jaSalvou) {
            sql = "DELETE FROM post_salvos WHERE usuario_id=? AND post_id=?"; // Remove dos salvos
        } else {
            sql = "INSERT INTO post_salvos (usuario_id, post_id) VALUES (?, ?)"; // Adiciona aos salvos
        }
        return executarUpdateSimples(sql, usuarioId, postId);
    }

    /**
     * Lista todos os posts para administração (inclui RASCUNHOS)
     * @return Lista completa de posts sem filtro de publicação
     */
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
    /**
     * Insere um novo post no blog
     * @param post Objeto Blog com os dados do post
     * @return true se a inserção foi bem sucedida
     */
    public boolean inserir(Blog post) {
        String sql = "INSERT INTO blog_post (titulo, descricao, foto_capa, status_publicacao, usuario_id, registro_id, data_publicacao) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, post.getTitulo()); 
            stmt.setString(2, post.getDescricao());
            if (post.getFotoCapaStream() != null) stmt.setBlob(3, post.getFotoCapaStream()); else stmt.setNull(3, java.sql.Types.BLOB);
            stmt.setString(4, post.getStatusPublicacao()); 
            stmt.setLong(5, post.getUsuarioId());
             // Registro_id é opcional (pode ser usado para relacionar com outros registros do sistema)
            if (post.getRegistroId() != null) stmt.setLong(6, post.getRegistroId()); else stmt.setNull(6, java.sql.Types.BIGINT);
            stmt.setTimestamp(7, new Timestamp(post.getDataPublicacao().getTime()));
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
     /**
     * Atualiza um post existente
     * @param post Objeto Blog com os dados atualizados
     * @return true se a atualização foi bem sucedida
     */
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
    /**
     * Exclui um post pelo ID
     * @param id ID do post a ser excluído
     * @return true se a exclusão foi bem sucedida
     */
    public boolean excluir(Long id) {
        String sql = "DELETE FROM blog_post WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { return false; }
    }
    /**
     * Busca um post específico pelo ID
     * @param id ID do post
     * @return Objeto Blog ou null se não encontrado
     */
    public Blog buscarPorId(Long id) {
        String sql = "SELECT bp.id, bp.titulo, bp.descricao, bp.status_publicacao, bp.data_publicacao, bp.usuario_id, bp.registro_id, u.nome as nome_autor FROM blog_post bp JOIN usuarios u ON bp.usuario_id = u.id WHERE bp.id = ?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) return criarBlogFromResultSetSimples(rs);
        } catch (SQLException e) {}
        return null;
    }
    /**
     * Obtém a imagem de capa de um post
     * @param id ID do post
     * @return Array de bytes com a imagem ou null se não existir
     */
    public byte[] getImagemById(Long id) {
        String sql = "SELECT foto_capa FROM blog_post WHERE id=?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            ResultSet rs = stmt.executeQuery();
            if(rs.next()) { Blob b = rs.getBlob(1); if(b!=null) return b.getBytes(1, (int)b.length()); }
        } catch (SQLException e) {}
        return null;
    }

    // ============ MÉTODOS PRIVADOS AUXILIARES ============

    /**
     * Verifica se existe uma interação do usuário com um post em uma tabela específica
     * @param tabela Nome da tabela (post_curtidas ou post_salvos)
     * @param usuarioId ID do usuário
     * @param postId ID do post
     * @return true se a interação existe
     */
    private boolean verificarInteracao(String tabela, Long usuarioId, Long postId) {
        String sql = "SELECT 1 FROM " + tabela + " WHERE usuario_id=? AND post_id=?";
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, usuarioId); stmt.setLong(2, postId);
            return stmt.executeQuery().next();
        } catch (SQLException e) { return false; }
    }
    /**
     * Executa uma operação de UPDATE simples com dois parâmetros
     */
    private boolean executarUpdateSimples(String sql, Long usuarioId, Long postId) {
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, usuarioId); stmt.setLong(2, postId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
    /**
     * Executa uma query que retorna lista de posts com um parâmetro
     */
    private List<Blog> executarQueryLista(String sql, Long param) {
        List<Blog> posts = new ArrayList<>();
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, param); ResultSet rs = stmt.executeQuery();
            while (rs.next()) posts.add(criarBlogFromResultSetCompleto(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return posts;
    }
    /**
     * Executa uma query que retorna lista de posts com dois parâmetros
     */
    private List<Blog> executarQueryListaDupla(String sql, Long param1, Long param2) {
        List<Blog> posts = new ArrayList<>();
        try (Connection conn = ConexaoBanco.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, param1); stmt.setLong(2, param2); ResultSet rs = stmt.executeQuery();
            while (rs.next()) posts.add(criarBlogFromResultSetCompleto(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return posts;
    }
       /**
     * Cria objeto Blog a partir de ResultSet com informações completas (inclui interações)
     */
    private Blog criarBlogFromResultSetCompleto(ResultSet rs) throws SQLException {
        Blog post = criarBlogFromResultSetSimples(rs);
        post.setTotalCurtidas(rs.getInt("total_likes"));
        post.setCurtidoPeloUsuario(rs.getInt("curtiu") > 0);
        post.setSalvoPeloUsuario(rs.getInt("salvou") > 0);
        return post;
    }
    /**
     * Cria objeto Blog a partir de ResultSet com informações básicas
     */
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