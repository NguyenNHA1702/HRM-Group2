package com.hrm.project.controller.common;

import com.hrm.project.model.Department;
import com.hrm.project.service.DepartmentService;
import com.hrm.project.service.impl.DepartmentServiceImpl;
import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Sửa URL Pattern sang phân hệ hr
@WebServlet(name = "DepartmentController", urlPatterns = {"/hr/departments"})
public class DepartmentController extends HttpServlet {

    private final DepartmentService departmentService = new DepartmentServiceImpl();
    private final UserDAO userDAO = new UserDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("suggest_manager".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            String term = request.getParameter("term");
            if (term == null || term.trim().isEmpty()) {
                response.getWriter().write("[]");
                return;
            }
            try {
                java.util.List<Object[]> rows = userDAO.suggestEmployees(term.trim());
                JsonArray jsonArray = new JsonArray();
                for (Object[] row : rows) {
                    JsonObject obj = new JsonObject();
                    obj.addProperty("id", (int) row[0]);
                    obj.addProperty("code", (String) row[1]);
                    obj.addProperty("name", (String) row[2]);
                    jsonArray.add(obj);
                }
                response.getWriter().write(gson.toJson(jsonArray));
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        if ("getMembers".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                int departmentId = Integer.parseInt(request.getParameter("id"));
                List<com.hrm.project.model.UserAccountDTO> members = departmentService.getMembersByDepartment(departmentId);
                response.getWriter().write(gson.toJson(members));
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
            return;
        }

        List<Department> list = departmentService.getAllDepartments();
        request.setAttribute("departments", list);

        // CHÚ Ý: Đường dẫn mới trỏ vào folder views/hr/
        request.getRequestDispatcher("/WEB-INF/views/hr/departments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        // Handle JSON or direct status change actions
        if ("deactivate".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                int activeCount = departmentService.countActiveEmployees(id);
                if (activeCount > 0) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Cannot deactivate department. There are still active employees or a manager assigned to this department. Please transfer them first.\"}");
                    return;
                }
                boolean success = departmentService.deactivateDepartment(id);
                response.getWriter().write("{\"success\": " + success + "}");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
            }
            return;
        }

        if ("activate".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean success = departmentService.activateDepartment(id);
                response.getWriter().write("{\"success\": " + success + "}");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
            }
            return;
        }

        if ("bulkTransfer".equals(action) || (request.getContentType() != null && request.getContentType().contains("application/json"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try {
                int targetDepartmentId = -1;
                java.util.List<Integer> employeeIds = new java.util.ArrayList<>();
                
                if (request.getContentType() != null && request.getContentType().contains("application/json")) {
                    JsonObject payload = gson.fromJson(request.getReader(), JsonObject.class);
                    if (payload.has("targetDepartmentId")) {
                        targetDepartmentId = payload.get("targetDepartmentId").getAsInt();
                    }
                    if (payload.has("employeeIds")) {
                        JsonArray arr = payload.getAsJsonArray("employeeIds");
                        for (int i = 0; i < arr.size(); i++) {
                            employeeIds.add(arr.get(i).getAsInt());
                        }
                    }
                } else {
                    targetDepartmentId = Integer.parseInt(request.getParameter("targetDepartmentId"));
                    String[] ids = request.getParameterValues("employeeIds");
                    if (ids != null) {
                        for (String idStr : ids) {
                            if (idStr.contains(",")) {
                                for (String part : idStr.split(",")) {
                                    if (!part.trim().isEmpty()) {
                                        employeeIds.add(Integer.parseInt(part.trim()));
                                    }
                                }
                            } else {
                                if (!idStr.trim().isEmpty()) {
                                    employeeIds.add(Integer.parseInt(idStr.trim()));
                                }
                            }
                        }
                    }
                }
                
                // Check if target department is vacant/managerless BEFORE the transfer
                boolean isTargetEmptyOrManagerless = false;
                try (java.sql.Connection conn = com.hrm.project.dao.impl.DBConnection.getConnection();
                     java.sql.PreparedStatement ps = conn.prepareStatement(
                         "SELECT manager_id, (SELECT COUNT(*) FROM employees WHERE department_id = ? AND UPPER(status) = 'ACTIVE') AS emp_count " +
                         "FROM departments WHERE id = ?")) {
                    ps.setInt(1, targetDepartmentId);
                    ps.setInt(2, targetDepartmentId);
                    try (java.sql.ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            int mgrId = rs.getInt("manager_id");
                            boolean isManagerNull = rs.wasNull();
                            int empCount = rs.getInt("emp_count");
                            if (isManagerNull || empCount == 0) {
                                isTargetEmptyOrManagerless = true;
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                
                boolean success = departmentService.bulkTransferEmployees(targetDepartmentId, employeeIds);
                boolean requireManagerAlert = success && isTargetEmptyOrManagerless;
                
                JsonObject jsonResponse = new JsonObject();
                jsonResponse.addProperty("success", success);
                jsonResponse.addProperty("requireManagerAlert", requireManagerAlert);
                response.getWriter().write(gson.toJson(jsonResponse));
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
            }
            return;
        }

        Department d = new Department();
        d.setCode(request.getParameter("code"));
        d.setName(request.getParameter("name"));
        d.setDescription(request.getParameter("description"));
        d.setIsActive(Integer.parseInt(request.getParameter("isActive")));

        String parentIdStr = request.getParameter("parentId");
        if (parentIdStr != null && !parentIdStr.isEmpty()) {
            d.setParentId(Integer.parseInt(parentIdStr));
        }

        String managerIdParam = request.getParameter("manager_id");
        if (managerIdParam == null || managerIdParam.trim().isEmpty()) {
            managerIdParam = request.getParameter("managerId");
        }
        int managerId = -1;
        if (managerIdParam != null && !managerIdParam.trim().isEmpty()) {
            managerId = Integer.parseInt(managerIdParam.trim());
            d.setManagerId(managerId);
        } else {
            request.setAttribute("message", "Lỗi: manager_id là bắt buộc!");
            doGet(request, response);
            return;
        }

        if ("create".equals(action) || "add".equals(action)) {
            if (departmentService.addDepartment(d)) {
                request.setAttribute("message", "Thêm mới phòng ban thành công!");
            } else {
                request.setAttribute("message", "Lỗi: Không thể thêm mới phòng ban!");
            }
        } else if ("update".equals(action)) {
            d.setId(Integer.parseInt(request.getParameter("id")));
            if (d.getIsActive() == 0) {
                int activeCount = departmentService.countActiveEmployees(d.getId());
                if (activeCount > 0) {
                    request.setAttribute("message", "Lỗi: Cannot deactivate department. There are still active employees or a manager assigned to this department. Please transfer them first.");
                    doGet(request, response);
                    return;
                }
            }
            if (departmentService.updateDepartment(d)) {
                request.setAttribute("message", "Cập nhật thông tin thành công!");
            } else {
                request.setAttribute("message", "Lỗi: Cập nhật thất bại!");
            }
        }

        doGet(request, response);
    }
}