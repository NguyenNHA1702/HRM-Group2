package com.hrm.project.filter;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class SecurityFilter implements Filter {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo trống để tương thích mọi phiên bản Servlet
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String path = req.getServletPath();

        // In log ra Terminal để Tiến theo dõi luồng chạy thực tế
        System.out.println("[BẢO VỆ FILTER] Đang quét qua URL: " + path);

        // 1. Loại bỏ hoàn toàn các trang mặc định, tài nguyên tĩnh (css, js, ảnh) khỏi bộ lọc chặn
        if (path == null || path.equals("") || path.equals("/") || path.equals("/index.jsp") ||
                path.startsWith("/login") || path.startsWith("/logout") ||
                path.startsWith("/forgot-password") || path.startsWith("/assets") ||
                path.equals("/check-db")) {

            chain.doFilter(request, response);
            return;
        }

        // 2. KIỂM TRA ĐĂNG NHẬP: Nếu chưa có phiên làm việc -> Cho ra rìa, quay về login
        if (session == null || session.getAttribute("roleGroup") == null) {
            System.out.println("[BẢO VỆ FILTER] -> CHẶN: Chưa đăng nhập. Đá về /login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 2.1 KIỂM TRA VAI TRÒ CÒN HOẠT ĐỘNG KHÔNG (Real-time Auth)
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        if (employeeId != null) {
            boolean isRoleActive = userDAO.isUserRoleActive(employeeId);
            if (!isRoleActive) {
                System.out.println("[BẢO VỆ FILTER] -> CHẶN: Vai trò của tài khoản đã bị vô hiệu hóa bởi Admin!");
                session.invalidate();
                resp.sendRedirect(req.getContextPath() + "/login?error=RoleDeactivated");
                return;
            }
        }

        String roleGroup = (String) session.getAttribute("roleGroup");

        
        
        boolean isHrAllowedAdminPath = "HR".equals(roleGroup) &&
                (path.equals("/admin/salary-scales") || path.equals("/admin/allowance-types"));

        if (!isHrAllowedAdminPath &&
                (path.startsWith("/admin") || path.equals("/phan-quyen") ||
                path.equals("/quan-ly-users") || path.equals("/cau-hinh"))) {

            if (!"ADMIN".equals(roleGroup)) {
                System.out.println("[BẢO VỆ FILTER] -> TỪ CHỐI: User " + roleGroup + " đòi vào vùng Admin!");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }
        }

        // Hợp lệ thì cho đi tiếp
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Hủy trống phục vụ tương thích hệ thống
    }
}