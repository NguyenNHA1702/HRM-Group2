package com.hrm.project.controller;

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
        Department d = new Department();
        d.setCode(request.getParameter("code"));
        d.setName(request.getParameter("name"));
        d.setDescription(request.getParameter("description"));
        d.setIsActive(Integer.parseInt(request.getParameter("isActive")));

        String parentIdStr = request.getParameter("parentId");
        if (parentIdStr != null && !parentIdStr.isEmpty()) {
            d.setParentId(Integer.parseInt(parentIdStr));
        }

        // Retrieve and log mandatory manager_id
        String managerIdParam = request.getParameter("manager_id");
        if (managerIdParam == null || managerIdParam.trim().isEmpty()) {
            managerIdParam = request.getParameter("managerId");
        }
        System.out.println("Received manager_id parameter: " + managerIdParam);

        if (managerIdParam != null && !managerIdParam.trim().isEmpty()) {
            d.setManagerId(Integer.parseInt(managerIdParam.trim()));
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
            if (departmentService.updateDepartment(d)) {
                request.setAttribute("message", "Cập nhật thông tin thành công!");
            } else {
                request.setAttribute("message", "Lỗi: Cập nhật thất bại!");
            }
        }

        doGet(request, response);
    }
}