package com.hrm.project.dao;

import com.hrm.project.model.UserAccount;

public interface UserDAO {
    UserAccount getUserById(int id);
    boolean updateProfile(UserAccount user);
}
