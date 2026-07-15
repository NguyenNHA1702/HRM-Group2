package com.hrm.project.util;

import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import javax.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * Lớp tiện ích phân quyền động.
 * Ánh xạ (URL path + HTTP Method + action param) -> (Module code + Action type).
 *
 * 12 module sau tái cấu trúc:
 *   DASHBOARD, EMPLOYEE_MGMT, CONTRACT_MGMT, DEPT_MGMT,
 *   ATTENDANCE, SCHEDULE_MGMT, LEAVE_MGMT,
 *   PAYROLL, SALARY_CONFIG, USER_MGMT, RBAC, SYSTEM
 */
public class PermissionUtils {

    // ---------------------------------------------------------------
    // Inner class chứa yêu cầu quyền của một HTTP request
    // ---------------------------------------------------------------
    public static class RequiredPermission {
        public final String moduleCode;
        public final String actionType; // VIEW | CREATE | EDIT | DELETE

        public RequiredPermission(String moduleCode, String actionType) {
            this.moduleCode = moduleCode;
            this.actionType = actionType;
        }
    }

    // ---------------------------------------------------------------
    // Ánh xạ HttpServletRequest sang Module và Action yêu cầu
    // ---------------------------------------------------------------

    /**
     * Xác định URL path, Method và Action param hiện tại yêu cầu module và action gì.
     * Trả về null nếu URL không yêu cầu kiểm tra quyền module cụ thể.
     */
    public static RequiredPermission getRequiredPermission(HttpServletRequest req) {
        String path = req.getServletPath();
        String method = req.getMethod();
        String action = req.getParameter("action");
        boolean isPost = "POST".equalsIgnoreCase(method);

        // ─── 1. DASHBOARD ───────────────────────────────────────────────
        if ("/dashboard".equals(path)) {
            return new RequiredPermission("DASHBOARD", "VIEW");
        }

        // ─── 2. DEPT_MGMT (Phòng ban) ───────────────────────────────────
        if ("/hr/departments".equals(path)) {
            if (isPost) {
                if ("create".equals(action) || "add".equals(action))
                    return new RequiredPermission("DEPT_MGMT", "CREATE");
                if ("delete".equals(action))
                    return new RequiredPermission("DEPT_MGMT", "DELETE");
                // update, deactivate, activate, bulkTransfer → EDIT
                return new RequiredPermission("DEPT_MGMT", "EDIT");
            }
            return new RequiredPermission("DEPT_MGMT", "VIEW");
        }

        // ─── 3. EMPLOYEE_MGMT (Hồ sơ nhân viên — không bao gồm hợp đồng) ─
        if (path.startsWith("/nhan-vien") || path.startsWith("/admin/nhan-vien")) {
            if (isPost) {
                if ("delete".equals(action))
                    return new RequiredPermission("EMPLOYEE_MGMT", "DELETE");
                if ("create".equals(action) || "add".equals(action))
                    return new RequiredPermission("EMPLOYEE_MGMT", "CREATE");
                return new RequiredPermission("EMPLOYEE_MGMT", "EDIT");
            }
            return new RequiredPermission("EMPLOYEE_MGMT", "VIEW");
        }

        // ─── 4. CONTRACT_MGMT (Hợp đồng lao động) ──────────────────────
        if ("/hr/contracts".equals(path) || "/hr/api/contracts".equals(path)) {
            if (isPost) {
                if ("terminate".equals(action) || "delete".equals(action))
                    return new RequiredPermission("CONTRACT_MGMT", "DELETE");
                if ("create".equals(action) || "renew".equals(action))
                    return new RequiredPermission("CONTRACT_MGMT", "CREATE");
                return new RequiredPermission("CONTRACT_MGMT", "EDIT");
            }
            return new RequiredPermission("CONTRACT_MGMT", "VIEW");
        }

        // ─── 5. USER_MGMT (Tài khoản người dùng) ───────────────────────
        if ("/admin/users".equals(path) || "/admin/users/action".equals(path)
                || "/admin/user/update".equals(path) || "/admin/user/toggle-active".equals(path)
                || "/admin/api/user/detail".equals(path)) {
            if (isPost) {
                if ("delete".equals(action))
                    return new RequiredPermission("USER_MGMT", "DELETE");
                if ("create".equals(action))
                    return new RequiredPermission("USER_MGMT", "CREATE");
                return new RequiredPermission("USER_MGMT", "EDIT");
            }
            return new RequiredPermission("USER_MGMT", "VIEW");
        }

        // ─── 6. ATTENDANCE (Chấm công & giải trình) ─────────────────────
        // Lưu ý: ca làm / ngày lễ / lịch phân công đã được tách sang SCHEDULE_MGMT
        if ("/cham-cong".equals(path) || "/cham-cong/thong-ke".equals(path)
                || path.startsWith("/hr/attendance-explanations")
                || "/admin/attendance/lock".equals(path)) {
            if (isPost) {
                if ("delete".equals(action))
                    return new RequiredPermission("ATTENDANCE", "DELETE");
                if ("create".equals(action) || "add".equals(action))
                    return new RequiredPermission("ATTENDANCE", "CREATE");
                if ("submitExplanation".equals(action))
                    return new RequiredPermission("ATTENDANCE", "VIEW");
                return new RequiredPermission("ATTENDANCE", "EDIT");
            }
            return new RequiredPermission("ATTENDANCE", "VIEW");
        }

        // ─── 7. SCHEDULE_MGMT (Ca làm việc, ngày nghỉ lễ, lịch phân công) ─
        if ("/admin/work-shifts".equals(path) || "/admin/holidays".equals(path)
                || path.startsWith("/schedule")) {
            if (isPost) {
                if ("delete".equals(action) || path.contains("/delete"))
                    return new RequiredPermission("SCHEDULE_MGMT", "DELETE");
                if ("create".equals(action) || "add".equals(action)
                        || path.contains("/assign") || path.contains("/create"))
                    return new RequiredPermission("SCHEDULE_MGMT", "CREATE");
                return new RequiredPermission("SCHEDULE_MGMT", "EDIT");
            }
            return new RequiredPermission("SCHEDULE_MGMT", "VIEW");
        }

        // ─── 8. LEAVE_MGMT (Nghỉ phép) ─────────────────────────────────
        if ("/nghi-phep".equals(path) || "/nghi-phep/create".equals(path)
                || "/nghi-phep/cancel".equals(path) || "/hr/leave-summary".equals(path)
                || "/hr/leave-requests".equals(path) || "/hr/leave-balance".equals(path)
                || "/hr/leave-request/action".equals(path) || "/admin/leave-types".equals(path)) {
            if (isPost) {
                if ("delete".equals(action) || path.contains("/delete"))
                    return new RequiredPermission("LEAVE_MGMT", "DELETE");
                if ("create".equals(action) || "add".equals(action) || path.contains("/create"))
                    return new RequiredPermission("LEAVE_MGMT", "CREATE");
                return new RequiredPermission("LEAVE_MGMT", "EDIT");
            }
            return new RequiredPermission("LEAVE_MGMT", "VIEW");
        }

        // ─── 9. PAYROLL (Tạo/xem/duyệt bảng lương) ─────────────────────
        // Lưu ý: thang lương/phụ cấp/bảo hiểm đã được tách sang SALARY_CONFIG
        if ("/admin/payrolls".equals(path) || path.startsWith("/admin/payroll")
                || "/luong".equals(path) || "/luong/export-pdf".equals(path)) {
            if (isPost) {
                if ("delete".equals(action) || path.contains("/delete"))
                    return new RequiredPermission("PAYROLL", "DELETE");
                if ("generate".equals(action) || "create".equals(action)
                        || "add".equals(action) || path.contains("/generate"))
                    return new RequiredPermission("PAYROLL", "CREATE");
                return new RequiredPermission("PAYROLL", "EDIT");
            }
            return new RequiredPermission("PAYROLL", "VIEW");
        }

        // ─── 10. SALARY_CONFIG (Thang bảng lương, phụ cấp, bảo hiểm) ───
        if ("/admin/salary-scales".equals(path) || "/admin/allowance-types".equals(path)
                || "/admin/position-allowances".equals(path) || "/admin/insurance".equals(path)
                || "/admin/insurance/action".equals(path)) {
            if (isPost) {
                if ("delete".equals(action))
                    return new RequiredPermission("SALARY_CONFIG", "DELETE");
                if ("create".equals(action) || "add".equals(action))
                    return new RequiredPermission("SALARY_CONFIG", "CREATE");
                return new RequiredPermission("SALARY_CONFIG", "EDIT");
            }
            return new RequiredPermission("SALARY_CONFIG", "VIEW");
        }

        // ─── 11. RBAC (Phân quyền) ──────────────────────────────────────
        if ("/admin/permissions".equals(path) || "/phan-quyen".equals(path)
                || path.startsWith("/admin/api/role-permissions")
                || path.startsWith("/admin/api/roles")) {
            if (isPost) {
                return new RequiredPermission("RBAC", "EDIT");
            }
            return new RequiredPermission("RBAC", "VIEW");
        }

        // ─── 12. SYSTEM CONFIG (Cấu hình hệ thống) ─────────────────────
        if ("/cau-hinh".equals(path)) {
            if (isPost) {
                return new RequiredPermission("SYSTEM", "EDIT");
            }
            return new RequiredPermission("SYSTEM", "VIEW");
        }

        return null; // URL không yêu cầu kiểm tra quyền module cụ thể
    }

    // ---------------------------------------------------------------
    // Kiểm tra quyền từ Session Map
    // ---------------------------------------------------------------

    /**
     * Kiểm tra xem user có đủ quyền để thực hiện hành động được yêu cầu hay không.
     *
     * @param userPermissions Map quyền của user (key = moduleCode, value = ModulePermissionDTO)
     * @param req             Yêu cầu quyền cần kiểm tra (từ getRequiredPermission)
     * @return true nếu user được phép, false nếu không có quyền
     */
    public static boolean hasPermission(Map<String, ModulePermissionDTO> userPermissions,
                                        RequiredPermission req) {
        if (req == null) return true;
        if (userPermissions == null) return false;

        ModulePermissionDTO modulePerm = userPermissions.get(req.moduleCode);
        if (modulePerm == null) return false;

        switch (req.actionType) {
            case "VIEW":   return modulePerm.isView();
            case "CREATE": return modulePerm.isCreate();
            case "EDIT":   return modulePerm.isEdit();
            case "DELETE": return modulePerm.isDelete();
            default:       return false;
        }
    }
}
