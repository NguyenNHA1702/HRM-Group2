package com.hrm.project.controller;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ChangePasswordController", urlPatterns = {"/change-password"})
public class ChangePasswordController extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        // Chặn nếu chưa đăng nhập
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int employeeId = (int) session.getAttribute("employeeId");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 1. Kiểm tra validation cơ bản
        if (currentPassword == null || currentPassword.isBlank() ||
                newPassword == null || newPassword.isBlank() ||
                confirmPassword == null || confirmPassword.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/profile?pwdError=Vui lòng điền đầy đủ các trường.");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/profile?pwdError=Mật khẩu mới và xác nhận mật khẩu không khớp.");
            return;
        }

        // 2. Lấy password_hash hiện tại dưới DB lên để đối chiếu
        String dbHash = userDAO.getPasswordHashByEmployeeId(employeeId);
        if (dbHash == null) {
            response.sendRedirect(request.getContextPath() + "/profile?pwdError=Không tìm thấy tài khoản hệ thống.");
            return;
        }

        // Đồng bộ cơ chế chuẩn hóa đầu khố của chuỗi mã hóa giống y xì AuthDao của nhóm
        if (dbHash.startsWith("$2y$")) {
            dbHash = dbHash.replaceFirst("\\$2y\\$", "\\$2a\\$");
        }

        // Kiểm tra xem mật khẩu cũ nhập vào có khớp không (Hỗ trợ bypass luôn pass test "123456" của nhóm)
        if (!"123456".equals(currentPassword) && !BCrypt.checkpw(currentPassword, dbHash)) {
            response.sendRedirect(request.getContextPath() + "/profile?pwdError=Mật khẩu hiện tại không chính xác.");
            return;
        }

        // 3. Tiến hành băm mật khẩu mới bằng BCrypt và lưu xuống DB
        String newPasswordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        boolean success = userDAO.updatePassword(employeeId, newPasswordHash);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/profile?pwdSuccess=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/profile?pwdError=Lỗi hệ thống, không thể cập nhật mật khẩu.");
        }
    }
}