# HRM-Group2 — Hệ thống Quản lý Nhân sự (HRMS)

Dự án môn SWP391 — FPT University, Kỳ 8 SU26.

---

## Tổng quan

Ứng dụng web quản lý nhân sự nội bộ xây dựng bằng **Java Servlet + JSP + MySQL**, triển khai trên **Apache Tomcat 9**.  
Hỗ trợ 4 vai trò người dùng với giao diện, luồng quy trình nghiệp vụ và phân quyền chi tiết.

---

## Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Backend | Java 11, Servlet 4.0, JSP 2.3 |
| Frontend | HTML/CSS, JSTL, JavaScript (vanilla) |
| Database | MySQL 8.x |
| Migration | Flyway 9.x |
| Build tool | Maven |
| Server | Apache Tomcat 9.0.83 (via Cargo plugin) |
| Bảo mật mật khẩu | jBCrypt |
| Email | JavaMail (javax.mail) |
| JSON | Gson 2.10.1 |
| Xuất báo cáo | OpenPDF 1.3.30, Apache POI 5.2.5 |

---

## Kiến trúc thư mục

```
src/main/
├── java/com/hrm/project/
│   ├── controller/     ← Servlet xử lý HTTP request (gồm thư mục con api/)
│   ├── dao/            ← Interface truy vấn DB
│   │   └── impl/       ← Implement JDBC thực tế
│   ├── model/          ← Entity / DTO
│   ├── service/        ← Business logic
│   ├── filter/         ← SecurityFilter (auth + real-time role active check)
│   ├── listener/       ← FlywayConfig (auto migrate khi khởi động)
│   └── util/           ← DBUtil, EmailUtility
├── resources/
│   └── db/migration/   ← Flyway SQL scripts (V1 → V20)
└── webapp/
    ├── assets/         ← CSS, JS, Images
    ├── uploads/        ← File upload lưu trữ (hợp đồng scan...)
    └── WEB-INF/
        ├── common/     ← sidebar.jsp, header.jsp, footer.jsp
        └── views/
            ├── admin/  ← Quản trị hệ thống, cấu hình lương, bảo hiểm, phân quyền
            ├── hr/     ← Quản lý nhân viên, phòng ban, hợp đồng, đơn phép, thống kê
            ├── manager/← Quản lý phòng ban, phê duyệt nghỉ phép
            └── employee/← Đơn nghỉ phép cá nhân, xem lịch chấm công, phiếu lương
```

---

## Phân quyền chi tiết (Role & Permissions)

Hệ thống bảo mật đa lớp thông qua `SecurityFilter` kiểm tra phiên đăng nhập và vai trò real-time:

| Role | Mô tả | Quyền hạn chính |
|---|---|---|
| **ADMIN** | Quản trị viên hệ thống | Toàn quyền cấu hình hệ thống (Users, Role-permissions, Ca làm việc, Ngày nghỉ lễ, Cấu hình tỷ lệ bảo hiểm, Loại nghỉ phép, Thang bảng lương, Loại phụ cấp, phê duyệt/thanh toán lương). |
| **HR** | Bộ phận Nhân sự | Quản lý thông tin nhân viên, phòng ban đa cấp, lập & gia hạn hợp đồng lao động, xem & duyệt nghỉ phép, xem thang bảng lương, loại phụ cấp, cấu hình bảo hiểm, lập bảng lương tháng (`payrolls` dạng `DRAFT`), nhập dữ liệu chấm công từ Excel. |
| **MANAGER** | Quản lý bộ phận | Quản lý nhân sự thuộc phòng ban của mình, phê duyệt đơn nghỉ phép của nhân viên cấp dưới, xem thống kê chấm công của phòng ban, xem cấu hình bảo hiểm. |
| **EMPLOYEE** | Nhân viên | Xem lịch chấm công cá nhân, gửi giải trình chấm công khi đi trễ/về sớm, tạo và theo dõi đơn xin nghỉ phép, xem thông tin bảo hiểm, xem và tải phiếu lương cá nhân (`my-payroll`). |

---

## Chức năng chính

### 1. Xác thực & Bảo mật (Authentication & Security)
- Đăng nhập / Đăng xuất.
- Đổi mật khẩu / Quên mật khẩu (gửi mã xác nhận qua Email).
- **Bảo vệ Session Real-time**: Kiểm tra trạng thái kích hoạt của tài khoản (`is_active` của vai trò) trên từng request. Nếu Admin vô hiệu hóa vai trò của User, User sẽ lập tức bị đá ra khỏi hệ thống.

### 2. Quản lý Phòng ban Đa cấp (Hierarchical Departments)
- Quản lý phòng ban theo mô hình cha - con (`parentId`).
- Phân bổ Trưởng phòng ban (Manager) có kiểm tra ràng buộc nghiệp vụ (không cho phép gán tài khoản thuộc vai trò ADMIN hoặc HR làm Trưởng phòng ban).

### 3. Quản lý Hợp đồng Lao động (Contracts)
- Tạo mới, gia hạn (Renew - tự động chuyển hợp đồng cũ sang `EXPIRED`), hoặc chấm dứt hợp đồng (`TERMINATED`).
- Hỗ trợ tải lên (Upload) file đính kèm bản scan hợp đồng (định dạng PDF, JPG, JPEG, PNG). Lưu trữ an toàn trên server và liên kết với hồ sơ nhân viên.

### 4. Quản lý Phân lịch làm việc (Work Scheduling)
- Phân lịch làm việc cho từng nhân viên theo ca làm việc (`work_shifts`).
- Theo dõi lịch sử thay đổi ca làm việc (`schedule_history`) ghi nhận chi tiết: ca cũ, ca mới, người thực hiện thay đổi, lý do thay đổi và thời điểm thay đổi.

### 5. Quản lý Chấm công & Giải trình (Attendance & Explanations)
- Ghi nhận Check-in/Check-out của nhân viên.
- Nhân viên gửi đơn giải trình chấm công (`attendance_explanations`) kèm lý do khi đi muộn/về sớm để Quản lý hoặc HR xem xét duyệt.
- HR import trực tiếp dữ liệu chấm công hàng tháng thông qua file Excel (`.xlsx`).
- Báo cáo thống kê chấm công toàn hệ thống dưới dạng biểu đồ/bảng số liệu trực quan cho HR và Manager.

### 6. Quản lý Thang bảng lương, Phụ cấp & Bảo hiểm (Payroll, Allowances & Insurance)
- **Thang bảng lương**: Thiết lập các bậc lương cứng (`salary_scales`).
- **Phụ cấp**: Cho phép liên kết nhiều loại phụ cấp (`employee_allowances` n-n) cho một nhân viên.
- **Bảo hiểm**: Cấu hình tỷ lệ đóng bảo hiểm (BHXH, BHYT, BHTN) chi tiết cho cả nhân viên và người sử dụng lao động, gán nhóm đối tượng áp dụng bảo hiểm theo Luật Lao động Việt Nam.

### 7. Tính lương & Phê duyệt lương tự động (Payroll Process)
- Tự động đồng bộ dữ liệu chấm công (`attendance`) vào tổng hợp công (`attendance_summary`) trước khi thực hiện tính lương.
- Luồng xử lý lương hàng tháng theo 3 trạng thái:
  1. **DRAFT (Nháp)**: HR lập bảng tính lương nháp dựa trên mức lương cứng, phụ cấp, tỷ lệ bảo hiểm và tổng hợp ngày công thực tế.
  2. **APPROVED (Đã duyệt)**: ADMIN phê duyệt bảng lương tháng sau khi kiểm tra thông tin.
  3. **PAID (Đã chi trả)**: ADMIN xác nhận đã thanh toán tiền lương cho nhân viên.
- Nhân viên chủ động tra cứu phiếu lương cá nhân chi tiết hàng tháng và hỗ trợ **tải phiếu lương (Payslip) dưới dạng PDF**.
- HR/Admin có thể **xuất bảng lương tổng hợp ra file Excel** để phục vụ báo cáo và lưu trữ.

---

## Database Migration (Flyway)

Flyway tự động đồng bộ cấu trúc DB khi ứng dụng khởi chạy. Danh sách các phiên bản Migration hiện tại:

| Phiên bản | Nội dung thực hiện |
|---|---|
| **V1** | Tạo các bảng nhân sự cơ bản (`employees`, `departments`, `positions`, `user_accounts`). |
| **V2** | Seed dữ liệu mẫu cho hệ thống (tài khoản demo, phòng ban ban đầu). |
| **V3** | Tạo bảng thang bảng lương (`salary_scales`). |
| **V4** | Thêm cột trạng thái hoạt động `is_active` cho các cấu hình; tạo bảng loại phụ cấp (`allowance_types`). |
| **V6** | Tạo bảng ca làm việc (`work_shifts`) và ngày nghỉ lễ (`holidays`). |
| **V7** | Thiết lập cấu trúc bảo hiểm ban đầu. |
| **V8** | Liên kết thông tin nhân viên với thang lương và phụ cấp tương ứng. |
| **V9** | Xây dựng hệ thống quản lý đơn xin nghỉ phép (`leave_types`, `leave_requests`). |
| **V10** | Cập nhật ràng buộc UNIQUE cho bảng ca làm việc (`work_shifts`). |
| **V11** | Tạo bảng cấu hình chi tiết tỷ lệ đóng bảo hiểm (`insurance_rate`). |
| **V12** | Tạo Database View (`vw_leave_request_detail`) hỗ trợ thống kê tình hình nghỉ phép. |
| **V13** | Tạo bảng nhóm đối tượng áp dụng bảo hiểm bắt buộc (`insurance_applicable_group`) theo luật VN. |
| **V14** | Tạo bảng dữ liệu chấm công (`attendance`). |
| **V15** | Tái cấu trúc phụ cấp (quan hệ n-n `employee_allowances`), tạo các bảng quản lý lương (`payrolls`, `payroll_details`), tổng hợp công (`attendance_summary`) và lịch sử thay đổi lương của nhân viên (`employee_salary_history`). |
| **V16** | Tạo bảng phân lịch làm việc (`employee_schedules`) và lịch sử đổi lịch (`schedule_history`). |
| **V17** | Tạo bảng quản lý hợp đồng lao động (`contracts`). |
| **V18** | Viết Store Procedure để cập nhật an toàn trường `file_url` cho bảng `contracts` lưu file đính kèm. |
| **V20** | Tạo bảng giải trình chấm công (`attendance_explanations`) cho nhân viên. |

---

## Hướng dẫn cài đặt & Khởi chạy

### Yêu cầu hệ thống
- JDK 11+
- Maven 3.6+
- MySQL 8.x đang chạy tại `localhost:3306`

### Bước 1: Tạo Database
Tạo database trống tên là `HRM_DB` với mã hóa UTF-8:
```sql
CREATE DATABASE HRM_DB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Bước 2: Cấu hình kết nối Database
Cập nhật thông tin kết nối DB (User/Password) trong file [DBConnection.java](file:///f:/FPT/Ky8_SU26/SWP391/HRM-Group2/src/main/java/com/hrm/project/util/DBConnection.java) (hoặc file cấu hình tương ứng):
```java
private static final String URL = "jdbc:mysql://localhost:3306/HRM_DB?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
private static final String USER = "root";
private static final String PASSWORD = "your_password_here";
```

### Bước 3: Build & Chạy ứng dụng
Mở terminal tại thư mục gốc dự án và chạy lệnh:
```bash
mvn clean package cargo:run
```
Sau đó truy cập: [http://localhost:8080](http://localhost:8080)

*Flyway sẽ tự động chạy các script SQL để tạo bảng và seed dữ liệu mẫu trong lần chạy đầu tiên.*

---

## Danh mục URL & Phân quyền truy cập

| URL Path | HTTP Method | Servlet / Controller xử lý | Quyền truy cập (Role) |
|---|---|---|---|
| `/login`, `/logout` | GET/POST | `LoginServlet` | Public |
| `/forgot-password` | GET/POST | `ForgotPasswordController` | Public |
| `/dashboard` | GET | `DashboardController` | Tất cả vai trò (ADMIN, HR, MANAGER, EMPLOYEE) |
| `/profile` | GET/POST | `ProfileController` | Tất cả vai trò |
| `/change-password` | GET/POST | `ChangePasswordController` | Tất cả vai trò |
| `/admin/users` | GET | `AdminUserList` | ADMIN, HR |
| `/admin/users/action` | POST | `AdminUserListController` | ADMIN |
| `/admin/user/update` | GET/POST | `AdminUpdateUserController` | ADMIN, HR |
| `/admin/user/toggle-active` | POST | `AdminToggleActiveUserController` | ADMIN |
| `/admin/api/user/detail` | GET | `AdminGetUserDetailController` | API / ADMIN |
| `/admin/salary-scales` | GET/POST | `SalaryScaleListController` | ADMIN, HR |
| `/admin/allowance-types` | GET/POST | `AllowanceTypeController` | ADMIN, HR |
| `/admin/leave-types` | GET/POST | `AdminLeaveTypeController` | ADMIN |
| `/admin/work-shifts` | GET/POST | `WorkShiftController` | ADMIN |
| `/admin/holidays` | GET/POST | `HolidayController` | ADMIN |
| `/admin/insurance` | GET | `AdminInsuranceConfig` | ADMIN, HR, MANAGER, EMPLOYEE |
| `/admin/insurance/action` | POST | `AdminInsuranceConfig` | ADMIN, HR, MANAGER |
| `/admin/permissions` | GET | `RoleManagementController` | ADMIN |
| `/admin/api/role-permissions` | GET | `GetRolePermissionsController` | API / ADMIN |
| `/admin/api/role-permissions/save` | POST | `SaveRolePermissionsController` | API / ADMIN |
| `/admin/api/roles/update` | POST | `AdminUpdateRoleController` | API / ADMIN |
| `/admin/api/roles/toggle` | POST | `AdminToggleRoleActiveController` | API / ADMIN |
| `/admin/payrolls` | GET | `PayrollListController` | ADMIN, HR |
| `/admin/payroll/generate` | POST | `GeneratePayrollController` | ADMIN, HR |
| `/admin/payroll/detail` | GET | `PayrollDetailController` | ADMIN, HR |
| `/admin/payroll/approve` | POST | `ApprovePayrollController` | ADMIN |
| `/admin/payroll/export-excel` | GET | `ExportPayrollExcelController` | ADMIN, HR |
| `/luong` | GET | `EmployeeMyPayrollController` | EMPLOYEE |
| `/luong/export-pdf` | GET | `ExportPayslipPdfController` | EMPLOYEE |
| `/schedule/view` | GET | `ScheduleController` | ADMIN, HR, MANAGER |
| `/schedule/assign` | GET/POST | `ScheduleController` | ADMIN, HR |
| `/schedule/update` | GET/POST | `ScheduleController` | ADMIN, HR |
| `/schedule/employee` | GET | `ScheduleController` | EMPLOYEE |
| `/schedule/delete` | POST | `ScheduleController` | ADMIN, HR |
| `/hr/contracts` | GET | `ContractController` | ADMIN, HR |
| `/hr/api/contracts` | POST/GET | `ContractApiController` | API / ADMIN, HR |
| `/hr/departments` | GET/POST | `DepartmentController` | ADMIN, HR |
| `/hr/leave-requests` | GET | `HrLeaveRequestController` | ADMIN, HR |
| `/hr/leave-request/action` | POST | `HrReviewLeaveController` | ADMIN, HR |
| `/nghi-phep` | GET | `LeaveRequestController` | EMPLOYEE |
| `/nghi-phep/create` | GET/POST | `CreateLeaveRequestController` | EMPLOYEE |
| `/nghi-phep/cancel` | POST | `CancelLeaveRequestController` | EMPLOYEE |
| `/cham-cong` | GET/POST | `AttendanceController` | HR, MANAGER, EMPLOYEE (ADMIN bị chặn) |
| `/cham-cong/thong-ke` | GET | `AttendanceStatisticsController` | HR, MANAGER |
| `/check-db` | GET | `DatabaseCheckServlet` | Developer / Testing |

---

## Nhóm phát triển

Dự án SWP391 — FPT University  
Nhóm 2 — Kỳ 8 Summer 2026
