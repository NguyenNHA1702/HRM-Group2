package com.hrm.project.controller;

import com.hrm.project.dao.AllowanceTypeDAO;
import com.hrm.project.dao.impl.AllowanceTypeDAOImpl;
import com.hrm.project.model.AllowanceType;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AllowanceTypeController", urlPatterns = {"/admin/allowance-types"})
public class AllowanceTypeController extends HttpServlet {

    private final AllowanceTypeDAO dao = new AllowanceTypeDAOImpl();

    /** GET → hiển thị danh sách */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        List<AllowanceType> list = dao.getAllAllowanceTypes();
        req.setAttribute("allowanceTypes", list);
        req.getRequestDispatcher("/WEB-INF/views/admin/allowance-type-list.jsp").forward(req, resp);
    }

    /** POST → xử lý add / update / deactivate / activate */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action  = req.getParameter("action");
        String ctx     = req.getContextPath();
        HttpSession session = req.getSession();

        switch (action == null ? "" : action) {

            case "add": {
                String code        = req.getParameter("code");
                String name        = req.getParameter("name");
                String amountStr   = req.getParameter("amount");
                String description = req.getParameter("description");

                if (isBlank(code) || isBlank(name) || isBlank(amountStr)) {
                    flash(session, "error", "Vui lòng điền đầy đủ các trường bắt buộc.");
                    break;
                }
                if (dao.isCodeExists(code, 0)) {
                    flash(session, "error", "Mã phụ cấp \"" + code.toUpperCase() + "\" đã tồn tại trong hệ thống.");
                    break;
                }
                AllowanceType t = new AllowanceType();
                t.setCode(code);
                t.setName(name);
                t.setAmount(parseDouble(amountStr));
                t.setDescription(description);
                if (dao.addAllowanceType(t)) {
                    flash(session, "success", "Thêm loại phụ cấp \"" + name + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi thêm phụ cấp. Vui lòng thử lại.");
                }
                break;
            }

            case "update": {
                String idStr       = req.getParameter("id");
                String code        = req.getParameter("code");
                String name        = req.getParameter("name");
                String amountStr   = req.getParameter("amount");
                String description = req.getParameter("description");

                if (isBlank(idStr) || isBlank(code) || isBlank(name) || isBlank(amountStr)) {
                    flash(session, "error", "Dữ liệu cập nhật không hợp lệ.");
                    break;
                }
                int id = Integer.parseInt(idStr);
                if (dao.isCodeExists(code, id)) {
                    flash(session, "error", "Mã phụ cấp \"" + code.toUpperCase() + "\" đã được sử dụng bởi loại phụ cấp khác.");
                    break;
                }
                AllowanceType t = new AllowanceType();
                t.setId(id);
                t.setCode(code);
                t.setName(name);
                t.setAmount(parseDouble(amountStr));
                t.setDescription(description);
                if (dao.updateAllowanceType(t)) {
                    flash(session, "success", "Cập nhật loại phụ cấp \"" + name + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi cập nhật. Vui lòng thử lại.");
                }
                break;
            }

            case "deactivate":
            case "activate": {
                String idStr = req.getParameter("id");
                if (isBlank(idStr)) { flash(session, "error", "ID không hợp lệ."); break; }
                boolean toActive = "activate".equals(action);
                int id = Integer.parseInt(idStr);
                if (dao.toggleActive(id, toActive)) {
                    flash(session, "success", toActive ? "Đã kích hoạt loại phụ cấp." : "Đã vô hiệu hóa loại phụ cấp.");
                } else {
                    flash(session, "error", "Lỗi hệ thống, vui lòng thử lại.");
                }
                break;
            }

            default:
                flash(session, "error", "Hành động không xác định.");
        }

        resp.sendRedirect(ctx + "/admin/allowance-types");
    }

    private boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
    private double  parseDouble(String s) {
        try { return Double.parseDouble(s.trim().replace(",", "")); }
        catch (NumberFormatException e) { return 0; }
    }
    private void flash(HttpSession s, String type, String msg) {
        s.setAttribute("flash_" + type, msg);
    }
}
