package com.hrm.project.controller.common;

import com.hrm.project.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

@WebServlet("/check-db")
public class DatabaseCheckServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<html><head><title>Test DB Connection</title></head><body style='font-family: Arial; text-align: center; margin-top: 50px;'>");
        out.println("<h2>Kiểm tra kết nối Database MySQL</h2>");
        
        try (Connection conn = DBUtil.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                out.println("<h3 style='color:green;'>✔️ KẾT NỐI DATABASE THÀNH CÔNG!</h3>");
                out.println("<p>Hệ thống đã nhận diện được Database cấu hình trong DBUtil.</p>");
                System.out.println(">>> KẾT NỐI DATABASE THÀNH CÔNG (Test từ /check-db)");
            } else {
                out.println("<h3 style='color:red;'>❌ KẾT NỐI DATABASE THẤT BẠI!</h3>");
                out.println("<p>Connection trả về null hoặc đã bị đóng.</p>");
            }
        } catch (Exception e) {
            out.println("<h3 style='color:red;'>❌ KẾT NỐI DATABASE THẤT BẠI!</h3>");
            out.println("<p>Lý do: <b>" + e.getMessage() + "</b></p>");
            out.println("<div style='text-align: left; background: #f4f4f4; padding: 10px; display: inline-block;'>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
            out.println("</div>");
            System.err.println(">>> LỖI TEST KẾT NỐI DB: " + e.getMessage());
        }
        
        out.println("<br><br><a href='" + req.getContextPath() + "/login'>Quay lại trang Đăng nhập</a>");
        out.println("</body></html>");
    }
}
