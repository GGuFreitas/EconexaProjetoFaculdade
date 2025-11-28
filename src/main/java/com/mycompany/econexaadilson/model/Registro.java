/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 * 
 * @author Gustavo Freitas
 */

package com.mycompany.econexaadilson.model;

import java.io.InputStream;
import java.util.Date;

public class Registro {

    private Long id;
    private String titulo;
    private String descricao;
    private Date data;
    private double latitude;
    private double longitude;
    private String status;
    
    private TipoRegistro tipoRegistro;
    
    private Usuario usuario;
    private Long usuarioId; 
    
    private InputStream fotoStream; 
    private byte[] fotoBytes;       

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    public Date getData() { return data; }
    public void setData(Date data) { this.data = data; }
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public TipoRegistro getTipoRegistro() { return tipoRegistro; }
    public void setTipoRegistro(TipoRegistro tipoRegistro) { this.tipoRegistro = tipoRegistro; }
    
    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { 
        this.usuario = usuario;
        if (usuario != null) this.usuarioId = usuario.getId();
    }

    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }
    // ----------------------------------
    
    public InputStream getFotoStream() { return fotoStream; }
    public void setFotoStream(InputStream fotoStream) { this.fotoStream = fotoStream; }
    public byte[] getFotoBytes() { return fotoBytes; }
    public void setFotoBytes(byte[] fotoBytes) { this.fotoBytes = fotoBytes; }
}