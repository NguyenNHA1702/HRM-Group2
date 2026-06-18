package com.hrm.project.controller;

import com.hrm.project.service.ContractService;
import com.hrm.project.service.impl.ContractServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ContractController", urlPatterns = {"/hr/contracts"})
public class ContractController extends HttpServlet {

    private final ContractService contractService = new ContractServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Kiểm tra quyền: chỉ ADMIN và HR được truy cập
        String roleGroup = (String) session.getAttribute("roleGroup");
        if (roleGroup == null || (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền truy cập chức năng Quản lý Hợp đồng.");
            return;
        }

        // 3. Lấy danh sách hợp đồng và forward sang JSP
        request.setAttribute("contracts", contractService.getAllContracts());

        request.getRequestDispatcher("/WEB-INF/views/hr/contracts.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
