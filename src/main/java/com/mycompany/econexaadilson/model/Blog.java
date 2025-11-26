/**
 *
 * @author Jhonny
 */

package com.mycompany.econexaadilson.model;

import java.io.InputStream;
import java.util.Date;

public class Blog {

    private Long id;
    private String titulo;
    private String descricao;
    private Date dataPublicacao;
    private String statusPublicacao;
    private Long usuarioId;
    private Long registroId;
    private String nomeAutor;
    
    private InputStream fotoCapaStream; 
    private byte[] fotoCapaBytes;
    
    private int totalCurtidas;
    private boolean curtidoPeloUsuario; 
    private boolean salvoPeloUsuario;
    // -----------------------------------

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    public Date getDataPublicacao() { return dataPublicacao; }
    public void setDataPublicacao(Date dataPublicacao) { this.dataPublicacao = dataPublicacao; }
    public String getStatusPublicacao() { return statusPublicacao; }
    public void setStatusPublicacao(String statusPublicacao) { this.statusPublicacao = statusPublicacao; }
    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }
    public Long getRegistroId() { return registroId; }
    public void setRegistroId(Long registroId) { this.registroId = registroId; }
    public String getNomeAutor() { return nomeAutor; }
    public void setNomeAutor(String nomeAutor) { this.nomeAutor = nomeAutor; }
    public InputStream getFotoCapaStream() { return fotoCapaStream; }
    public void setFotoCapaStream(InputStream fotoCapaStream) { this.fotoCapaStream = fotoCapaStream; }
    public byte[] getFotoCapaBytes() { return fotoCapaBytes; }
    public void setFotoCapaBytes(byte[] fotoCapaBytes) { this.fotoCapaBytes = fotoCapaBytes; }

    public int getTotalCurtidas() { return totalCurtidas; }
    public void setTotalCurtidas(int totalCurtidas) { this.totalCurtidas = totalCurtidas; }

    public boolean isCurtidoPeloUsuario() { return curtidoPeloUsuario; }
    public void setCurtidoPeloUsuario(boolean curtidoPeloUsuario) { this.curtidoPeloUsuario = curtidoPeloUsuario; }

    public boolean isSalvoPeloUsuario() { return salvoPeloUsuario; }
    public void setSalvoPeloUsuario(boolean salvoPeloUsuario) { this.salvoPeloUsuario = salvoPeloUsuario; }
}