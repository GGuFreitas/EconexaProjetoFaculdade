package com.mycompany.econexaadilson.model;

/**
 * @author Gustavo Freitas
 */
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TipoRegistro {
    private Long id;
    private String nome;
    private String categoria;
    private String descricao;
    private String icone;
    
    // Construtores, getters e setters
    public TipoRegistro() {}
    
    public TipoRegistro(Long id, String nome, String categoria, String descricao, String icone) {
        this.id = id;
        this.nome = nome;
        this.categoria = categoria;
        this.descricao = descricao;
        this.icone = icone;
    }
    
    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
    
    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }
    
    public String getIcone() { return icone; }
    public void setIcone(String icone) { this.icone = icone; }
}