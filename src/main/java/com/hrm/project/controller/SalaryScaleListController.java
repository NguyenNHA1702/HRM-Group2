package com.hrm.project.controller;

import com.hrm.project.dao.SalaryScaleDAO;
import com.hrm.project.dao.impl.SalaryScaleDAOImpl;
import com.hrm.project.model.SalaryScale;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SalaryScaleListController", urlPatterns = {"/admin/salary-scales"})
public class SalaryScaleListController extends HttpServlet {

    private final SalaryScaleDAO dao = new SalaryScaleDAOImpl();

    /** GET /admin/salary-scales → hiển thị danh sách */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        List<SalaryScale> list = dao.getAllSalaryScales();
        req.setAttribute("salaryScales", list);
        req.getRequestDispatcher("/WEB-INF/views/admin/salary-scale-list.jsp").forward(req, resp);
    }

    /** POST /admin/salary-scales → xử lý add / update / toggleActive */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String ctx    = req.getContextPath();
        HttpSession session = req.getSession();

        switch (action == null ? "" : action) {

            // ─── THÊM MỚI ────────────────────────────────────────────────
            case "add": {
                String grade       = req.getParameter("grade");
                String basicStr    = req.getParameter("basicSalary");
                String allowStr    = req.getParameter("allowance");
                String description = req.getParameter("description");

                if (isBlank(grade) || isBlank(basicStr) || isBlank(allowStr)) {
                    flash(session, "error", "Vui lòng điền đầy đủ các trường bắt buộc.");
                    break;
                }
                if (dao.isGradeExists(grade, 0)) {
                    flash(session, "error", "Mã bậc lương \"" + grade + "\" đã tồn tại trong hệ thống.");
                    break;
                }
                SalaryScale s = new SalaryScale();
                s.setGrade(grade);
                s.setBasicSalary(parseDouble(basicStr));
                s.setAllowance(parseDouble(allowStr));
                s.setDescription(description);
                if (dao.addSalaryScale(s)) {
                    flash(session, "success", "Thêm bậc lương \"" + grade + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi thêm bậc lương. Vui lòng thử lại.");
                }
                break;
            }

            // ─── CẬP NHẬT ────────────────────────────────────────────────
            case "update": {
                String idStr       = req.getParameter("id");
                String grade       = req.getParameter("grade");
                String basicStr    = req.getParameter("basicSalary");
                String allowStr    = req.getParameter("allowance");
                String description = req.getParameter("description");

                if (isBlank(idStr) || isBlank(grade) || isBlank(basicStr) || isBlank(allowStr)) {
                    flash(session, "error", "Dữ liệu cập nhật không hợp lệ.");
                    break;
                }
                int id = Integer.parseInt(idStr);
                if (dao.isGradeExists(grade, id)) {
                    flash(session, "error", "Mã bậc lương \"" + grade + "\" đã được sử dụng bởi bậc lương khác.");
                    break;
                }
                SalaryScale s = new SalaryScale();
                s.setId(id);
                s.setGrade(grade);
                s.setBasicSalary(parseDouble(basicStr));
                s.setAllowance(parseDouble(allowStr));
                s.setDescription(description);
                if (dao.updateSalaryScale(s)) {
                    flash(session, "success", "Cập nhật bậc lương \"" + grade + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi cập nhật. Vui lòng thử lại.");
                }
                break;
            }

            // ─── VÔ HIỆU HÓA / KÍCH HOẠT LẠI ────────────────────────────
            case "deactivate":
            case "activate": {
                String idStr = req.getParameter("id");
                if (isBlank(idStr)) { flash(session, "error", "ID không hợp lệ."); break; }
                boolean toActive = "activate".equals(action);
                int id = Integer.parseInt(idStr);
                if (dao.toggleActive(id, toActive)) {
                    flash(session, "success", toActive ? "Đã kích hoạt bậc lương." : "Đã vô hiệu hóa bậc lương.");
                } else {
                    flash(session, "error", "Lỗi hệ thống, vui lòng thử lại.");
                }
                break;
            }

            default:
                flash(session, "error", "Hành động không xác định.");
        }

        resp.sendRedirect(ctx + "/admin/salary-scales");
    }

    // ── Utilities ──────────────────────────────────────────────────────────
    private boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
    private double  parseDouble(String s) {
        try { return Double.parseDouble(s.trim().replace(",", "")); }
        catch (NumberFormatException e) { return 0; }
    }
    private void flash(HttpSession s, String type, String msg) {
        s.setAttribute("flash_" + type, msg);
    }
}
