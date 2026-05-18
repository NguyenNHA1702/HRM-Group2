package com.hrm.project.controller;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.UserAccount;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ProfileController", urlPatterns = { "/profile" })
public class ProfileController extends HttpServlet {

    private UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        Integer userId = (Integer) session.getAttribute("employeeId");
        if (userId == null) {
            userId = (Integer) session.getAttribute("userId");
        }
        if (userId == null) {
            userId = 1;
        }

        UserAccount user = userDAO.getUserById(userId);
        if (user != null) {
            request.setAttribute("user", user);
            request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=UserNotFound");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        int id = Integer.parseInt(request.getParameter("id"));
        String fullName = request.getParameter("fullName");
        String personalEmail = request.getParameter("personalEmail");
        String phone = request.getParameter("phone");

        UserAccount user = new UserAccount();
        user.setEmployeeId(id);
        user.setFullName(fullName);
        user.setPersonalEmail(personalEmail);
        user.setPhone(phone);

        boolean success = userDAO.updateProfile(user);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/profile?success=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/profile?error=1");
        }
    }
}
