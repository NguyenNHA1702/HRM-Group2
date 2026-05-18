package com.hrm.project.service.impl;

import com.hrm.project.dao.AuthDao;
import com.hrm.project.dao.impl.AuthDaoImpl;
import com.hrm.project.model.dtos.response.LoginResponseDto;
import com.hrm.project.service.AuthService;


import java.sql.Timestamp;
import java.util.UUID;

public class AuthServiceImpl implements AuthService {

    private final AuthDao authDao = new AuthDaoImpl();

    @Override
    public LoginResponseDto login(String email, String password) throws Exception {
        String passwordHash = password;

        LoginResponseDto result = authDao.findByEmailAndPassword(email, passwordHash);

        if (result != null){
            String sessionToken = UUID.randomUUID().toString();
            result.setSessionToken(sessionToken);

            Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + (60 * 60 * 1000));

            authDao.createSession(result.getAccountId(), sessionToken, expiresAt);
        }

        return result;
    }
}
