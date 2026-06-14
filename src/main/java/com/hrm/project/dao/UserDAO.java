package com.hrm.project.dao;

import com.hrm.project.model.UserAccount;
import com.hrm.project.model.Department;
import com.hrm.project.model.Position;
import com.hrm.project.model.Role;
import com.hrm.project.model.UserAccountDTO;
import com.hrm.project.model.UserStatDTO;

import java.sql.SQLException;
import java.util.List;

public interface UserDAO {
    UserAccount getUserById(int id);
    UserAccount getUserDetailById(int id);
    boolean updateProfile(UserAccount user);
    String getPasswordHashByEmployeeId(int employeeId);

    // Teammate's methods (main)
    int findEmployeeIdByEmail(String email) throws SQLException;

    /**
     * Tao tai khoan nguoi dung day du thong tin.
     *
     * @param fullName      Ho ten (bat buoc)
     * @param email         Email dang nhap / work_email (bat buoc)
     * @param roleId        ID role (bat buoc)
     * @param rawPassword   Mat khau tam thoi chua ma hoa (bat buoc)
     * @param phone         So dien thoai (tuy chon)
     * @param dateOfBirth   Ngay sinh dang yyyy-MM-dd (tuy chon)
     * @param gender        Gioi tinh: Nam / Nu / Khac (tuy chon)
     * @param personalEmail Email ca nhan (tuy chon; neu null se dung email dang nhap)
     * @param departmentId  ID phong ban (tuy chon)
     * @param positionId    ID chuc vu (tuy chon)
     * @param isActive      Trang thai hoat dong khi tao
     */
    void createUser(String fullName, String email, int roleId, String rawPassword,
                    String phone, String dateOfBirth, String gender, String personalEmail,
                    Integer departmentId, Integer positionId, boolean isActive) throws SQLException;

    List<UserAccountDTO> getUsers(String keyword, String roleGroup, String status,
                                  int page, int pageSize) throws SQLException;
    int getUsersCount(String keyword, String roleGroup, String status) throws SQLException;
    UserStatDTO getStats() throws SQLException;
    List<Object[]> getRoleGroups() throws SQLException;
    void toggleActive(int userId, boolean active) throws SQLException;
    void forceResetPassword(int userId) throws SQLException;
    void deleteUser(int userId) throws SQLException;

    // Your methods (tung)
    List<Department> getAllDepartments();
    List<Position> getAllPositions();
    List<Role> getAllRoles();
    UserAccount getUserForAdminUpdate(int id);
    boolean updateUserByAdmin(UserAccount user);
    boolean updateUserActiveStatus(int employeeId, boolean isActive);
    UserAccount getUserByEmail(String email);
    boolean updatePassword(int employeeId, String hashedPassword);
    boolean isUserRoleActive(int employeeId);

    // Get all employees for dropdowns/selects
    List<UserAccount> getAllEmployees() throws SQLException;

    /**
     * Suggest employees matching a search term (by employee_code or full_name).
     * Returns at most 10 results for autocomplete.
     */
    List<Object[]> suggestEmployees(String term) throws SQLException;

    /**
     * Check whether an employee with the given ID exists.
     */
    boolean employeeExists(int employeeId) throws SQLException;

    List<com.hrm.project.model.SalaryHistory> getSalaryHistoryByEmployeeId(int employeeId);
}
