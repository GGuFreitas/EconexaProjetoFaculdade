/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.econexaadilson.model;

/**
 *
 * @author Enzo Reis
 */

import java.util.Date;

public class Usuario {
    private Long id;
    private String nome;
    private String email;
    private String senhaHash;
    private String perfil; // "MEMBRO" ou "ADMIN"
    private Date dataCriacao;

    // Construtores
    public Usuario() {}

    public Usuario(Long id, String nome, String email, String senhaHash, String perfil, Date dataCriacao) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.senhaHash = senhaHash;
        this.perfil = perfil;
        this.dataCriacao = dataCriacao;
    }

    // Getters e Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getSenhaHash() { return senhaHash; }
    public void setSenhaHash(String senhaHash) { this.senhaHash = senhaHash; }
    
    public String getPerfil() { return perfil; }
    public void setPerfil(String perfil) { this.perfil = perfil; }
    
    public Date getDataCriacao() { return dataCriacao; }
    public void setDataCriacao(Date dataCriacao) { this.dataCriacao = dataCriacao; }
    
    // Método utilitário
    public boolean isAdmin() {
        return "ADMIN".equals(this.perfil);
    }
}