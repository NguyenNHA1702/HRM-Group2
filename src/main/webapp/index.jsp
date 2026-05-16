<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    // Lấy session hiện tại mà không tạo mới session mới
    HttpSession userSession = request.getSession(false);

    // Kiểm tra xem employeeId đã tồn tại trong session hay chưa
    if (userSession != null && userSession.getAttribute("employeeId") != null) {
        // Đã đăng nhập -> Chuyển hướng sang trang dashboard
        response.sendRedirect(request.getContextPath() + "/dashboard");
    } else {
        // Chưa đăng nhập -> Chuyển hướng sang trang login
        response.sendRedirect(request.getContextPath() + "/login");
    }
%>