package com.hrm.project.controller;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * AdminUserActionServlet — xu ly cac thao tac CRUD User.
 * POST /admin/users/action
 * Param: action = create | lock | unlock | resetPwd | delete
 */
public class AdminUserListController extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        String ctx    = req.getContextPath();

        if (action == null) {
            action = "";
        }

        try {
            if ("create".equals(action)) {
                String fullName  = req.getParameter("fullName");
                // Chap nhan ca email cong ty lan email ca nhan
                String email     = req.getParameter("email");
                String roleIdStr = req.getParameter("roleId");
                String rawPwd    = req.getParameter("password");

                if (fullName  == null || fullName.trim().isEmpty()  ||
                        email     == null || email.trim().isEmpty()     ||
                        roleIdStr == null || roleIdStr.trim().isEmpty() ||
                        rawPwd    == null || rawPwd.trim().isEmpty()) {

                    setFlash(req.getSession(), "error",
                            "Vui long dien day du thong tin.");
                } else {
                    userDAO.createUser(
                            fullName.trim(),
                            email.trim(),
                            Integer.parseInt(roleIdStr),
                            rawPwd
                    );
                    setFlash(req.getSession(), "success",
                            "Tao tai khoan thanh cong cho " + fullName.trim());
                }

            } else if ("lock".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.toggleActive(uid, false);
                setFlash(req.getSession(), "success", "Da khoa tai khoan.");

            } else if ("unlock".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.toggleActive(uid, true);
                setFlash(req.getSession(), "success", "Da mo khoa tai khoan.");

            } else if ("resetPassword".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.forceResetPassword(uid);
                setFlash(req.getSession(), "success",
                        "Da yeu cau nguoi dung doi mat khau lan dang nhap toi.");

            } else if ("delete".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.deleteUser(uid);
                setFlash(req.getSession(), "success", "Da xoa tai khoan.");

            } else {
                setFlash(req.getSession(), "error", "Hanh dong khong hop le.");
            }

        } catch (SQLException e) {
            setFlash(req.getSession(), "error", "Loi he thong: " + e.getMessage());
        } catch (NumberFormatException e) {
            setFlash(req.getSession(), "error", "Tham so khong hop le.");
        }

        resp.sendRedirect(ctx + "/admin/users");
    }

    private void setFlash(HttpSession session, String type, String msg) {
        session.setAttribute("flash_" + type, msg);
    }
}