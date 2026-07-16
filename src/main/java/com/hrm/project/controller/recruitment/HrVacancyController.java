package com.hrm.project.controller.recruitment;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.service.DepartmentService;
import com.hrm.project.service.RecruitmentService;
import com.hrm.project.service.impl.DepartmentServiceImpl;
import com.hrm.project.service.impl.RecruitmentServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/hr/vacancies")
public class HrVacancyController extends HttpServlet {

    private final RecruitmentService recruitmentService = new RecruitmentServiceImpl();
    private final DepartmentService departmentService = new DepartmentServiceImpl();
    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isHrOrAdmin(request, response)) {
            return;
        }

        request.setAttribute("vacancies", recruitmentService.getAllVacancies());
        request.setAttribute("departments", departmentService.getAllDepartments());
        request.setAttribute("positions", userDAO.getAllPositions());

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashMessage") != null) {
            request.setAttribute("message", session.getAttribute("flashMessage"));
            session.removeAttribute("flashMessage");
        } else {
            String message = request.getParameter("message");
            if (message != null) {
                request.setAttribute("message", message);
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/hr/vacancies.jsp")
                .forward(request, response);
    }

    static boolean isHrOrAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        String roleGroup = (String) session.getAttribute("roleGroup");
        if (roleGroup == null || (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền truy cập chức năng Tuyển dụng.");
            return false;
        }
        return true;
    }
}
