/**
 *
 * @author Jhonny
 */

package com.mycompany.econexaadilson.model.DAO;

import com.mycompany.econexaadilson.model.RevistaPost; // Presumindo uma classe RevistaPost
import com.mycompany.econexaadilson.model.config.ConexaoBanco;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RevistaPostDAO {

    /**
     * Lista todos os posts da revista.
     * Note: A tabela revista_post não possui um campo 'status_publicacao', 
     * então este método lista todos os registros.
     */
    public List<RevistaPost> listarTodos() {
        List<RevistaPost> posts = new ArrayList<>();
        // Note: A tabela revista_post já tem o campo 'autor', então o JOIN com 'usuarios' não é estritamente necessário 
        // apenas para o nome do autor, mas mantive o padrão caso 'usuarios' seja necessário para outras informações.
        String sql = "SELECT rp.id, rp.titulo, rp.descricao, rp.data_publicacao, rp.usuario_id, rp.autor, u.nome as nome_usuario " +
                     "FROM revista_post rp " +
                     "JOIN usuarios u ON rp.usuario_id = u.id " +
                     "ORDER BY rp.data_publicacao DESC";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                posts.add(criarRevistaPostFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return posts;
    }

    /**
     * Busca um post da revista pelo ID.
     */
    public RevistaPost buscarPorId(Long id) {
        String sql = "SELECT rp.id, rp.titulo, rp.descricao, rp.data_publicacao, rp.usuario_id, rp.autor, u.nome as nome_usuario " +
                     "FROM revista_post rp " +
                     "JOIN usuarios u ON rp.usuario_id = u.id " +
                     "WHERE rp.id = ?";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return criarRevistaPostFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Atualiza um post da revista.
     */
    public boolean atualizar(RevistaPost post) {
        // Remove 'status_publicacao'
        String sql = "UPDATE revista_post SET titulo=?, descricao=?, autor=? WHERE id=?"; 
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, post.getTitulo());
            stmt.setString(2, post.getDescricao());
            stmt.setString(3, post.getAutor()); // Campo 'autor' na tabela
            stmt.setLong(4, post.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Exclui um post da revista pelo ID.
     */
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


    /**
     * Insere um novo post da revista.
     */
    public boolean inserir(RevistaPost post) {
        // A tabela tem 'autor' e não tem 'status_publicacao' ou 'registro_id'.
        // 'data_publicacao', 'data_criacao' e 'data_atualizacao' têm DEFAULT.
        String sql = "INSERT INTO revista_post (titulo, descricao, foto_capa, usuario_id, autor) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, post.getTitulo());
            stmt.setString(2, post.getDescricao());
            
            // Lidar com a foto de capa (BLOB)
            if (post.getFotoCapaStream() != null) {
                stmt.setBlob(3, post.getFotoCapaStream());
            } else {
                stmt.setNull(3, java.sql.Types.BLOB);
            }
            
            stmt.setLong(4, post.getUsuarioId());
            stmt.setString(5, post.getAutor());
            
            // Removida data_publicacao pois já é DEFAULT CURRENT_TIMESTAMP
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Obtém a imagem de capa (foto_capa) pelo ID do post.
     */
    public byte[] getImagemById(Long postId) {
        String sql = "SELECT foto_capa FROM revista_post WHERE id = ?";
        try (Connection conn = ConexaoBanco.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, postId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Blob blob = rs.getBlob("foto_capa");
                    if (blob != null) {
                        // Converte o BLOB para array de bytes
                        return blob.getBytes(1, (int) blob.length()); 
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Método auxiliar para criar um objeto RevistaPost a partir do ResultSet.
     */
    private RevistaPost criarRevistaPostFromResultSet(ResultSet rs) throws SQLException {
        RevistaPost post = new RevistaPost();
        post.setId(rs.getLong("id"));
        post.setTitulo(rs.getString("titulo"));
        post.setDescricao(rs.getString("descricao"));
        post.setDataPublicacao(rs.getTimestamp("data_publicacao"));
        post.setUsuarioId(rs.getLong("usuario_id"));
        post.setAutor(rs.getString("autor")); // Campo 'autor' da tabela
        // O campo 'nome_usuario' (resultado do JOIN) pode ser útil para exibição
        post.setNomeAutor(rs.getString("nome_usuario")); 
        return post;
    }
}