package com.hrm.project.service;

import com.hrm.project.model.dtos.response.LoginResponseDto;

public interface AuthService {
    public LoginResponseDto login(String email, String password) throws Exception;
}
