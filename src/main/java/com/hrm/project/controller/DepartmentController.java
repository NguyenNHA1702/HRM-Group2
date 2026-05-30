package com.hrm.project.controller;

import com.hrm.project.model.Department;
import com.hrm.project.service.DepartmentService;
import com.hrm.project.service.impl.DepartmentServiceImpl;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        if ("add".equals(action)) {
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