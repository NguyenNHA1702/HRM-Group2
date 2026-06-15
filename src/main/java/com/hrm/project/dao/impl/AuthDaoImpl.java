package com.hrm.project.dao.impl;

import com.hrm.project.dao.AuthDao;
import com.hrm.project.model.dtos.response.LoginResponseDto;
import com.hrm.project.dao.impl.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

public class AuthDaoImpl implements AuthDao {

    @Override
    public LoginResponseDto findByEmailAndPassword(String email, String passwordRaw) {
        String sql = "SELECT e.employee_id, ua.id AS account_id, ua.role_id, e.full_name, e.work_email, e.role_name, e.role_group_code, e.avatar_url, ua.password_hash, emp.position_id, " +
                "(SELECT COUNT(*) FROM departments WHERE manager_id = e.employee_id) AS is_actual_manager " +
                "FROM vw_my_profile e " +
                "JOIN user_accounts ua ON e.employee_id = ua.employee_id " +
                "JOIN roles r ON ua.role_id = r.id " +
                "JOIN employees emp ON e.employee_id = emp.id " +
                "WHERE e.work_email = ? AND ua.is_active = 1 AND r.is_active = 1";


        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {

                    int positionId = rs.getInt("position_id");
                    int isActualManager = rs.getInt("is_actual_manager");
                    String finalRoleGroupCode = rs.getString("role_group_code");
                    String finalRoleName = rs.getString("role_name");
                    int finalRoleId = rs.getInt("role_id");

                    // 1. Luôn ưu tiên vị trí Giám đốc Điều Hành (position_id = 1) là ADMIN
                    if (positionId == 1) {
                        finalRoleGroupCode = "ADMIN";
                        finalRoleName = "Admin";
                        finalRoleId = 1;
                    }
                    // 2. Nếu tài khoản được phân vai MANAGER nhưng thực tế không quản lý phòng ban nào nữa:
                    else if ("MANAGER".equals(finalRoleGroupCode) && isActualManager == 0) {
                        // Trả lại vai trò cũ dựa theo vị trí công tác của họ
                        if (positionId == 2 || positionId == 3) {
                            finalRoleGroupCode = "HR";
                            finalRoleName = (positionId == 2) ? "HR Manager" : "HR Specialist";
                            finalRoleId = 3;
                        } else {
                            finalRoleGroupCode = "EMPLOYEE";
                            finalRoleName = "Employee";
                            finalRoleId = 9;
                        }
                    }

                    // -----------------------------------------------------------------
                    // CƠ CHẾ BẺ KHÓA ĐỂ DEV TEST NHANH:
                    // Nếu nhập đúng pass "123456", hệ thống tự động bypass không check chuỗi dummy trong DB nữa
                    // -----------------------------------------------------------------
                    if ("123456".equals(passwordRaw)) {
                        System.out.println("[DEBUG LOGIN] -> PHÁT HIỆN PASS TEST MẶC ĐỊNH (123456)! Đang bypass cấu hình...");

                        LoginResponseDto dto = new LoginResponseDto();
                        dto.setEmployeeId(rs.getInt("employee_id"));
                        dto.setAccountId(rs.getInt("account_id"));
                        dto.setRoleId(finalRoleId);
                        dto.setFullName(rs.getString("full_name"));
                        dto.setWorkEmail(rs.getString("work_email"));
                        dto.setRoleName(finalRoleName);
                        dto.setRoleGroupCode(finalRoleGroupCode);
                        dto.setAvatarUrl(rs.getString("avatar_url"));

                        System.out.println("[DEBUG LOGIN] -> Đăng nhập THÀNH CÔNG (Bypass) cho user: " + dto.getFullName());
                        return dto;
                    }
                    // -----------------------------------------------------------------

                    // Khối check BCrypt gốc phòng trường hợp sau này có account thật
                    String dbPasswordHash = rs.getString("password_hash");
                    if (dbPasswordHash != null && dbPasswordHash.startsWith("$2y$")) {
                        dbPasswordHash = dbPasswordHash.replaceFirst("\\$2y\\$", "\\$2a\\$");
                    }

                    if (org.mindrot.jbcrypt.BCrypt.checkpw(passwordRaw, dbPasswordHash)) {
                        System.out.println("[DEBUG LOGIN] -> BCrypt khớp mật khẩu!");
                        LoginResponseDto dto = new LoginResponseDto();
                        dto.setEmployeeId(rs.getInt("employee_id"));
                        dto.setAccountId(rs.getInt("account_id"));
                        dto.setRoleId(finalRoleId);
                        dto.setFullName(rs.getString("full_name"));
                        dto.setWorkEmail(rs.getString("work_email"));
                        dto.setRoleName(finalRoleName);
                        dto.setRoleGroupCode(finalRoleGroupCode);
                        dto.setAvatarUrl(rs.getString("avatar_url"));
                        return dto;
                    } else {
                        System.out.println("[DEBUG LOGIN] -> Thất bại: Mật khẩu nhập vào không khớp với chuỗi BCrypt trong DB.");
                    }
                } else {
                    System.out.println("[DEBUG LOGIN] -> Thất bại: Không tìm thấy Email này hoặc tài khoản bị khóa (is_active != 1).");
                }
            }
        } catch (SQLException e) {
            System.err.println("[DEBUG LOGIN] >>> GẶP LỖI SQL TRONG QUÁ TRÌNH TRUY VẤN:");
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public void createSession(int accountId, String tokenHash, Timestamp expiresAt) {
        String sql = "INSERT INTO user_sessions (user_account_id, token_hash, expires_at) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);
            ps.setString(2, tokenHash);
            ps.setTimestamp(3, expiresAt);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}