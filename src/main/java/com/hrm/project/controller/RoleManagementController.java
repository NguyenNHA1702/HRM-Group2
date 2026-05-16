package com.hrm.project.controller;

import com.hrm.project.model.dtos.response.RoleWithCountDTO;
import com.hrm.project.service.RoleService;
import com.hrm.project.service.impl.RoleServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/permissions")
public class RoleManagementController extends HttpServlet {

    private final RoleService roleService;

    public RoleManagementController() {
        this.roleService = new RoleServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Thiết lập mã hóa tiếng Việt cho request và response
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Lấy danh sách Role kèm số lượng user thực tế từ Database
        List<RoleWithCountDTO> roles = roleService.getAllRolesWithCount();

        // Đẩy danh sách roles vào request attribute để giao diện JSP có thể đọc được
        request.setAttribute("roles", roles);

        // Chuyển tiếp (Forward) request sang giao diện permissions.jsp nằm trong thư mục view của admin
        request.getRequestDispatcher("/WEB-INF/views/admin/permissions.jsp").forward(request, response);
    }
}