/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.econexaadilson.model;

/**
 * Classe de modelo que representa um usuário do sistema.
 * Incluído novo campo 'status' para controle de acesso e exclusão lógica.
 */

import java.util.Date;

public class Usuario {
    private Long id;
    private String nome;
    private String email;
    private String senhaHash;
    private String perfil; // "MEMBRO" ou "ADMIN"
    private String status; // 'ATIVO' ou 'INATIVO' para exclusão lógica
    private Date dataCriacao;

    // Construtores
    public Usuario() {}

    /**
     * Construtor completo da classe Usuario.
     */
    public Usuario(Long id, String nome, String email, String senhaHash, String perfil, String status, Date dataCriacao) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.senhaHash = senhaHash;
        this.perfil = perfil;
        this.status = status; // Novo campo no construtor
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
    
    /**
     * Getter para o status do usuário ('ATIVO' ou 'INATIVO').
     */
    public String getStatus() { return status; }
    
    /**
     * Setter para o status do usuário.
     */
    public void setStatus(String status) { this.status = status; }
    
    public Date getDataCriacao() { return dataCriacao; }
    public void setDataCriacao(Date dataCriacao) { this.dataCriacao = dataCriacao; }
    
    // Métodos utilitários
    
    /**
     * Verifica se o usuário possui o perfil de Administrador.
     */
    public boolean isAdmin() {
        return "ADMIN".equals(this.perfil);
    }
    
    /**
     * Verifica se o usuário está ativo no sistema.
     * Útil para filtros de login e listagens públicas.
     */
    public boolean isAtivo() {
        // Verifica se o status é nulo (fallback) ou explicitamente 'ATIVO'
        return this.status == null || "ATIVO".equalsIgnoreCase(this.status);
    }
}