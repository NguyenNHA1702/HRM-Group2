package com.hrm.project.filter;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import com.hrm.project.util.PermissionUtils;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

@WebFilter("/*")
public class SecurityFilter implements Filter {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo trống để tương thích mọi phiên bản Servlet
    }

    @Override
    @SuppressWarnings("unchecked")
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String path = req.getServletPath();
        String method = req.getMethod();

        System.out.println("[BẢO VỆ FILTER] Đang quét qua URL: " + path);

        // 1. Bỏ qua tài nguyên tĩnh, trang public (login, assets, v.v.)
        if (path == null || path.equals("") || path.equals("/") || path.equals("/index.jsp") ||
                path.startsWith("/login") || path.startsWith("/logout") ||
                path.startsWith("/forgot-password") || path.startsWith("/assets") ||
                path.startsWith("/uploads") || path.equals("/check-db")) {
                path.startsWith("/uploads") || path.equals("/check-db") ||
                path.startsWith("/api/notifications")) {   // SSE stream & notification API - mọi role đã login đều dùng

            chain.doFilter(request, response);
            return;
        }

        // 2. Kiểm tra đăng nhập
        if (session == null || session.getAttribute("roleGroup") == null) {
            System.out.println("[BẢO VỆ FILTER] -> CHẶN: Chưa đăng nhập. Đá về /login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 2.1 Kiểm tra vai trò còn hoạt động không (Real-time Auth)
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        if (employeeId != null) {
            boolean isRoleActive = userDAO.isUserRoleActive(employeeId);
            if (!isRoleActive) {
                System.out.println("[BẢO VỆ FILTER] -> CHẶN: Vai trò bị vô hiệu hóa!");
                session.invalidate();
                resp.sendRedirect(req.getContextPath() + "/login?error=RoleDeactivated");
                return;
            }
        }

        String roleGroup = (String) session.getAttribute("roleGroup");

        // 3. ADMIN: bypass mọi kiểm tra module để tránh tự khoá chính mình
        if ("ADMIN".equals(roleGroup)) {
            chain.doFilter(request, response);
            return;
        }

        // 4. Kiểm tra quyền ĐỘNG dựa trên bảng role_permissions trong DB
        Map<String, ModulePermissionDTO> userPermissions =
                (Map<String, ModulePermissionDTO>) session.getAttribute("userPermissions");

        PermissionUtils.RequiredPermission reqPerm =
                PermissionUtils.getRequiredPermission(req);

        if (reqPerm != null) {
            boolean hasAccess = PermissionUtils.hasPermission(userPermissions, reqPerm);
            if (!hasAccess) {
                System.out.println("[BẢO VỆ FILTER] -> TỪ CHỐI: " + roleGroup
                        + " không có quyền [" + reqPerm.actionType + "] trên module [" + reqPerm.moduleCode + "]");

                String requestedWith = req.getHeader("X-Requested-With");
                boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(requestedWith)
                        || "POST".equalsIgnoreCase(req.getMethod());

                if (isAjax) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    resp.setContentType("text/plain;charset=UTF-8");
                    resp.getWriter().write("Bạn không có quyền thực hiện hành động này.");
                } else {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                            "Bạn không có quyền thực hiện hành động này.");
                }
        boolean isHrAllowedAdminPath = "HR".equals(roleGroup) &&
                (path.equals("/admin/salary-scales") || path.equals("/admin/allowance-types") ||
                        path.equals("/admin/leave-types") || path.equals("/admin/insurance") ||
                        path.equals("/admin/insurance/action") || path.equals("/admin/payrolls") ||
                        path.equals("/admin/payroll/generate") || path.equals("/admin/payroll/detail") ||
                        path.equals("/admin/payroll/approve") ||
                        path.equals("/admin/payroll/export-excel") ||
                        path.equals("/admin/attendance/lock") ||
                        path.equals("/admin/position-allowances") ||
                        path.equals("/admin/notifications") ||           // Trang gửi thông báo
                        path.equals("/api/admin/notifications/send"));    // API gửi thông báo

        // MANAGER: xem/duyệt bảng lương dept mình + chốt công
        boolean isManagerAllowedAdminPath = "MANAGER".equals(roleGroup) &&
                (path.equals("/admin/payrolls") || path.equals("/admin/payroll/detail") ||
                 path.equals("/admin/payroll/approve") || path.equals("/admin/attendance/lock") ||
                 (path.equals("/admin/insurance") && "GET".equalsIgnoreCase(req.getMethod())));

        boolean isEmployeeAllowedAdminPath = "EMPLOYEE".equals(roleGroup) &&
                "GET".equalsIgnoreCase(req.getMethod()) &&
                path.equals("/admin/insurance");

        if (!isHrAllowedAdminPath && !isManagerAllowedAdminPath &&
                !isEmployeeAllowedAdminPath &&
                (path.startsWith("/admin") || path.equals("/phan-quyen") ||
                        path.equals("/quan-ly-users") || path.equals("/cau-hinh"))) {

            if (!"ADMIN".equals(roleGroup)) {
                System.out.println("[BẢO VỆ FILTER] -> TỪ CHỐI: User " + roleGroup + " đòi vào vùng Admin!");
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
                return;
            }
        }

        // 5. Hợp lệ -> cho đi tiếp
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Hủy trống phục vụ tương thích hệ thống
    }
}
