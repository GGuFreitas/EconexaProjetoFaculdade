/**
 * @author Alex Michel
 */

package com.mycompany.econexaadilson.model;

import java.io.InputStream;
import java.util.Date;

public class RevistaPost {
    private Long id;
    private String titulo;
    private String descricao;
    private InputStream fotoCapaStream; // Para upload
    private Date dataPublicacao;
    private Long usuarioId;
    private String autor; // Nome do autor do artigo
    
    // Campos auxiliares para exibição (não salvos diretamente na tabela revista_post)
    private String nomeUsuarioCriador; 

    // Construtores
    public RevistaPost() {}

    public RevistaPost(Long id, String titulo, String descricao, Date dataPublicacao, String autor) {
        this.id = id;
        this.titulo = titulo;
        this.descricao = descricao;
        this.dataPublicacao = dataPublicacao;
        this.autor = autor;
    }

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public InputStream getFotoCapaStream() { return fotoCapaStream; }
    public void setFotoCapaStream(InputStream fotoCapaStream) { this.fotoCapaStream = fotoCapaStream; }

    public Date getDataPublicacao() { return dataPublicacao; }
    public void setDataPublicacao(Date dataPublicacao) { this.dataPublicacao = dataPublicacao; }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

    public String getAutor() { return autor; }
    public void setAutor(String autor) { this.autor = autor; }
    
    public String getNomeUsuarioCriador() { return nomeUsuarioCriador; }
    public void setNomeUsuarioCriador(String nomeUsuarioCriador) { this.nomeUsuarioCriador = nomeUsuarioCriador; }
}