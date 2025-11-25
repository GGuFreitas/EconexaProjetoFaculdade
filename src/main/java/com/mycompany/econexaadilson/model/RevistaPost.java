/**
 *
 * @author Alex Michel
 */

package com.mycompany.econexaadilson.model;

import java.io.InputStream;
import java.util.Date;


public class RevistaPost {

    private Long id;
    private String titulo;
    private String descricao;
    private Date dataPublicacao;
    
    // Campo da tabela revista_post (VARCHAR(200) NOT NULL)
    private String autor; 
    
    private Long usuarioId; 
    
    // Campo auxiliar para o nome completo do autor (resultado de JOIN com 'usuarios')
    private String nomeAutor;
    
    // Campos para manipulação da imagem (BLOB)
    private InputStream fotoCapaStream;
    private byte[] fotoCapaBytes;


    // --- Getters e Setters ---

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    
    public Date getDataPublicacao() { return dataPublicacao; }
    public void setDataPublicacao(Date dataPublicacao) { this.dataPublicacao = dataPublicacao; }
    
    // Getter e Setter para o campo 'autor' da tabela
    public String getAutor() { return autor; }
    public void setAutor(String autor) { this.autor = autor; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }
    
    public String getNomeAutor() { return nomeAutor; }
    public void setNomeAutor(String nomeAutor) { this.nomeAutor = nomeAutor; }

    // --- Getters e Setters imagem ---

    public InputStream getFotoCapaStream() { return fotoCapaStream; }
    public void setFotoCapaStream(InputStream fotoCapaStream) { this.fotoCapaStream = fotoCapaStream; }
    
    public byte[] getFotoCapaBytes() { return fotoCapaBytes; }
    public void setFotoCapaBytes(byte[] fotoCapaBytes) { this.fotoCapaBytes = fotoCapaBytes; }
}