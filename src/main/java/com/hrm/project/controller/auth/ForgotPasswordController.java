package com.hrm.project.controller.auth;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.UserAccount;
import com.hrm.project.util.EmailUtility;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.SecureRandom;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    private UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot_password.jsp").forward(request, response);
            return;
        }

        email = email.trim();
        UserAccount user = userDAO.getUserByEmail(email);

        if (user == null) {
            request.setAttribute("error", "Email không tồn tại hoặc tài khoản chưa được thiết lập.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot_password.jsp").forward(request, response);
            return;
        }

        // Tạo mật khẩu ngẫu nhiên tạm thời
        String newPassword = generateRandomPassword();
        // Mã hóa BCrypt
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        // Cập nhật vào DB
        boolean success = userDAO.updatePassword(user.getEmployeeId(), hashedPassword);

        if (success) {
            // Gửi email
            String subject = "Khôi phục mật khẩu tài khoản HRM System";
            String emailContent = "<h3>Xin chào " + user.getFullName() + ",</h3>"
                    + "<p>Yêu cầu khôi phục mật khẩu tài khoản HR Management System của bạn đã được xử lý.</p>"
                    + "<p>Mật khẩu tạm thời mới của bạn là: <strong style='color: #6366f1; font-size: 1.15rem; background: #f1f5f9; padding: 4px 10px; border-radius: 6px; font-family: monospace;'>" + newPassword + "</strong></p>"
                    + "<p>Vui lòng đăng nhập bằng mật khẩu này và thay đổi lại mật khẩu mới ngay trong mục Profile của bạn để bảo mật thông tin.</p>"
                    + "<br><p>Trân trọng,<br>Bộ phận kỹ thuật hỗ trợ HRM.</p>";

            boolean emailSent = EmailUtility.sendEmail(email, subject, emailContent);
            
            if (emailSent) {
                String successMsg = "Mật khẩu mới đã được gửi tới email của bạn thành công! Vui lòng kiểm tra hộp thư.";
                response.sendRedirect(request.getContextPath() + "/login?success=" + java.net.URLEncoder.encode(successMsg, "UTF-8"));
                return;
            } else {
                request.setAttribute("error", "Không thể gửi email. Vui lòng thử lại sau.");
            }
        } else {
            request.setAttribute("error", "Có lỗi xảy ra trong quá trình cập nhật mật khẩu mới. Vui lòng thử lại.");
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/forgot_password.jsp").forward(request, response);
    }

    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }
}
