package com.hrm.project.controller.role;

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

        request.setCharacterEncoding("UTF-8");


        List<RoleWithCountDTO> roles = roleService.getAllRolesWithCount();


        request.setAttribute("roles", roles);


        request.getRequestDispatcher("/WEB-INF/views/admin/permission.jsp").forward(request, response);
    }
}