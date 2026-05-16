package com.hrm.project.dao;

import com.hrm.project.model.dtos.response.LoginResponseDto;

public interface AuthDao {
    LoginResponseDto findByEmailAndPassword(String email, String passwordHash);
    void createSession(int accountId, String tokenHash, java.sql.Timestamp expiresAt);
}
