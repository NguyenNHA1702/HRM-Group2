package com.hrm.project.controller;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.Department;
import com.hrm.project.model.Position;
import com.hrm.project.model.Role;
import com.hrm.project.model.UserAccount;

import com.hrm.project.dao.SalaryScaleDAO;
import com.hrm.project.dao.impl.SalaryScaleDAOImpl;
import com.hrm.project.dao.AllowanceTypeDAO;
import com.hrm.project.dao.impl.AllowanceTypeDAOImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminUpdateUserController", urlPatterns = { "/admin/user/update" })
public class AdminUpdateUserController extends HttpServlet {

    private UserDAO userDAO = new UserDAOImpl();
    private SalaryScaleDAO salaryScaleDAO = new SalaryScaleDAOImpl();
    private AllowanceTypeDAO allowanceTypeDAO = new AllowanceTypeDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/users?error=InvalidUserId");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);
            UserAccount user = userDAO.getUserForAdminUpdate(userId);
            if (user != null) {
                List<Department> departments = userDAO.getAllDepartments();
                List<Position> positions = userDAO.getAllPositions();
                List<Role> roles = userDAO.getAllRoles();
                List<com.hrm.project.model.SalaryScale> salaryScales = salaryScaleDAO.getAllSalaryScales();
                List<com.hrm.project.model.AllowanceType> allowanceTypes = allowanceTypeDAO.getAllAllowanceTypes();

                List<com.hrm.project.model.SalaryHistory> salaryHistory = userDAO.getSalaryHistoryByEmployeeId(userId);

                request.setAttribute("user", user);
                request.setAttribute("departments", departments);
                request.setAttribute("positions", positions);
                request.setAttribute("roles", roles);
                request.setAttribute("salaryScales", salaryScales);
                request.setAttribute("allowanceTypes", allowanceTypes);
                request.setAttribute("salaryHistory", salaryHistory);

                request.getRequestDispatcher("/WEB-INF/views/admin/admin_update_user.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=UserNotFound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/users?error=InvalidUserId");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String fullName = request.getParameter("fullName");
            
            String phone = request.getParameter("phone");
            if (phone != null && phone.trim().isEmpty()) {
                phone = null;
            }
            
            String personalEmail = request.getParameter("personalEmail");
            if (personalEmail != null && personalEmail.trim().isEmpty()) {
                personalEmail = null;
            }
            
            String dateOfBirth = request.getParameter("dateOfBirth");
            if (dateOfBirth != null && dateOfBirth.trim().isEmpty()) {
                dateOfBirth = null;
            }
            
            String gender = request.getParameter("gender");
            if (gender != null && gender.trim().isEmpty()) {
                gender = null;
            }
            
            String departmentIdStr = request.getParameter("departmentId");
            int departmentId = (departmentIdStr != null && !departmentIdStr.trim().isEmpty()) ? Integer.parseInt(departmentIdStr) : 0;
            
            String positionIdStr = request.getParameter("positionId");
            int positionId = (positionIdStr != null && !positionIdStr.trim().isEmpty()) ? Integer.parseInt(positionIdStr) : 0;

            String salaryScaleIdStr = request.getParameter("salaryScaleId");
            int salaryScaleId = (salaryScaleIdStr != null && !salaryScaleIdStr.trim().isEmpty()) ? Integer.parseInt(salaryScaleIdStr) : 0;

            String[] allowanceTypeIdsStr = request.getParameterValues("allowanceTypeIds");
            java.util.List<Integer> allowanceTypeIds = new java.util.ArrayList<>();
            if (allowanceTypeIdsStr != null) {
                for (String idStr : allowanceTypeIdsStr) {
                    if (idStr != null && !idStr.trim().isEmpty()) {
                        allowanceTypeIds.add(Integer.parseInt(idStr));
                    }
                }
            }
            
            String status = request.getParameter("status");
            
            String roleIdStr = request.getParameter("roleId");
            int roleId = (roleIdStr != null && !roleIdStr.trim().isEmpty()) ? Integer.parseInt(roleIdStr) : 0;

            UserAccount user = new UserAccount();
            user.setEmployeeId(id);
            user.setFullName(fullName);
            user.setPhone(phone);
            user.setPersonalEmail(personalEmail);
            user.setDateOfBirth(dateOfBirth);
            user.setGender(gender);
            user.setDepartmentId(departmentId);
            user.setPositionId(positionId);
            user.setSalaryScaleId(salaryScaleId);
            user.setAllowanceTypeIds(allowanceTypeIds);
            user.setStatus(status);
            user.setRoleId(roleId);

            String activeTab = request.getParameter("activeTab");
            if (activeTab == null || activeTab.trim().isEmpty()) {
                activeTab = "personal";
            }

            boolean success = userDAO.updateUserByAdmin(user);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/user/update?id=" + id + "&success=1&tab=" + java.net.URLEncoder.encode(activeTab, "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/user/update?id=" + id + "&error=1&tab=" + java.net.URLEncoder.encode(activeTab, "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/users?error=SystemError");
        }
    }
}
