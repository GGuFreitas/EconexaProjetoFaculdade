/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.econexaadilson.model;

/**
 *
 * @author gufre
 */
import java.util.Date;

public class Registro {
    private Long id;
    private String titulo;
    private String descricao;
    private Date data;
    private Double latitude;
    private Double longitude;
    private String foto;
    private String status;
    private TipoRegistro tipoRegistro;
    
    // Construtores, getters e setters
    public Registro() {}
    
    public Registro(Long id, String titulo, String descricao, Date data, 
                   Double latitude, Double longitude, String foto, 
                   String status, TipoRegistro tipoRegistro) {
        this.id = id;
        this.titulo = titulo;
        this.descricao = descricao;
        this.data = data;
        this.latitude = latitude;
        this.longitude = longitude;
        this.foto = foto;
        this.status = status;
        this.tipoRegistro = tipoRegistro;
    }
    
    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    
    public Date getData() { return data; }
    public void setData(Date data) { this.data = data; }
    
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    
    public String getFoto() { return foto; }
    public void setFoto(String foto) { this.foto = foto; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public TipoRegistro getTipoRegistro() { return tipoRegistro; }
    public void setTipoRegistro(TipoRegistro tipoRegistro) { this.tipoRegistro = tipoRegistro; }
}