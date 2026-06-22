package com.hrm.project.controller.user;

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
                String fullName     = req.getParameter("fullName");
                String email        = req.getParameter("email");
                String roleIdStr    = req.getParameter("roleId");
                String rawPwd       = req.getParameter("password");

                // Cac truong mo rong
                String phone        = req.getParameter("phone");
                String dateOfBirth  = req.getParameter("dateOfBirth");
                String gender       = req.getParameter("gender");
                String personalEmail= req.getParameter("personalEmail");
                String deptIdStr    = req.getParameter("departmentId");
                String posIdStr     = req.getParameter("positionId");
                String isActiveStr  = req.getParameter("isActive");

                if (fullName  == null || fullName.trim().isEmpty()  ||
                        email     == null || email.trim().isEmpty()     ||
                        roleIdStr == null || roleIdStr.trim().isEmpty() ||
                        rawPwd    == null || rawPwd.trim().isEmpty()) {

                    setFlash(req.getSession(), "error",
                            "Vui lòng điền đầy đủ thông tin bắt buộc.");
                } else {
                    Integer departmentId = (deptIdStr != null && !deptIdStr.trim().isEmpty())
                            ? Integer.parseInt(deptIdStr) : null;
                    Integer positionId   = (posIdStr  != null && !posIdStr.trim().isEmpty())
                            ? Integer.parseInt(posIdStr)  : null;
                    boolean isActive     = !"0".equals(isActiveStr); // Mac dinh la active

                    userDAO.createUser(
                            fullName.trim(),
                            email.trim(),
                            Integer.parseInt(roleIdStr),
                            rawPwd,
                            phone        != null ? phone.trim()         : null,
                            dateOfBirth  != null && !dateOfBirth.isEmpty() ? dateOfBirth : null,
                            gender       != null && !gender.isEmpty()      ? gender      : null,
                            personalEmail!= null && !personalEmail.isEmpty()? personalEmail.trim() : null,
                            departmentId,
                            positionId,
                            isActive
                    );
                    setFlash(req.getSession(), "success",
                            "Tạo tài khoản thành công cho " + fullName.trim());
                }

            } else if ("lock".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.toggleActive(uid, false);
                setFlash(req.getSession(), "success", "Đã khóa tài khoản.");

            } else if ("unlock".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.toggleActive(uid, true);
                setFlash(req.getSession(), "success", "Đã mở khóa tài khoản.");

            } else if ("resetPassword".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.forceResetPassword(uid);
                setFlash(req.getSession(), "success",
                        "Đã yêu cầu người dùng đổi mật khẩu lần đăng nhập tới.");

            } else if ("delete".equals(action)) {
                int uid = Integer.parseInt(req.getParameter("userId"));
                userDAO.deleteUser(uid);
                setFlash(req.getSession(), "success", "Đã xóa tài khoản.");

            } else {
                setFlash(req.getSession(), "error", "Hành động không hợp lệ.");
            }

        } catch (SQLException e) {
            setFlash(req.getSession(), "error", "Lỗi hệ thống: " + e.getMessage());
        } catch (NumberFormatException e) {
            setFlash(req.getSession(), "error", "Tham số không hợp lệ.");
        }

        resp.sendRedirect(ctx + "/admin/users");
    }

    private void setFlash(HttpSession session, String type, String msg) {
        session.setAttribute("flash_" + type, msg);
    }
}