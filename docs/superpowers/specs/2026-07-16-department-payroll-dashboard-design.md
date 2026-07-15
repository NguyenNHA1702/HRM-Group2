# Department Payroll Dashboard

## 1. Goal Description
Xây dựng một trang Dashboard dành riêng cho Manager để xem tổng quan và chi tiết quỹ lương của phòng ban do họ quản lý. Thay vì phải dùng chung trang /admin/payrolls với HR, Manager sẽ có một giao diện tinh gọn, tập trung vào số liệu thực tế của phòng ban mình.

## 2. Architecture & Data Flow
- **Route**: /manager/department-payroll
- **Controller**: DepartmentPayrollController
  - Lấy employeeId từ Session -> Tìm departmentId mà nhân viên này làm Manager.
  - Tải danh sách các tháng đã có Bảng lương (Payroll).
  - Tải chi tiết lương (PayrollDetail) của toàn bộ nhân viên thuộc phòng ban đó trong tháng được chọn.
  - Tính toán các chỉ số tổng quan: Tổng quỹ lương, Số lượng nhân sự, Trung bình lương.
- **View**: /WEB-INF/views/manager/department-payroll.jsp (Giao diện dạng Single-page Dashboard).

## 3. Giao diện (UI/UX)
- Thanh lọc: Chọn Tháng/Năm để xem dữ liệu.
- **Top Metrics (3 Thẻ)**:
  - Thẻ 1: Tổng quỹ lương (Tổng 
etSalary của cả phòng).
  - Thẻ 2: Số lượng nhân sự.
  - Thẻ 3: Mức lương trung bình.
- **Bottom Table (Bảng chi tiết)**:
  - Danh sách nhân viên trong phòng cùng các thông số cơ bản (Tổng thu nhập, Các khoản trừ, Thực nhận).
  - Nút "Mắt" ở cuối mỗi dòng để mở Modal bóc tách chi tiết lương (sử dụng lại logic Modal của màn hình chi tiết lương).

## 4. User Review Required / Open Questions
> [!IMPORTANT]
> **Câu hỏi về trạng thái hiển thị của Bảng lương:**
> Bạn đề xuất chỉ hiển thị bảng lương từ trạng thái MANAGER_CONFIRMED trở lên (tức là sau khi Manager duyệt) để tránh nhầm lẫn. Tuy nhiên, theo luồng hiện tại của hệ thống, **chính Manager là người duyệt bảng lương từ DRAFT lên MANAGER_CONFIRMED**. 
> Nếu trang Dashboard này không hiển thị các bảng lương ở trạng thái DRAFT, vậy Manager sẽ vào đâu để xem và bấm nút duyệt bảng lương?
> 
> **Đề xuất 2 hướng giải quyết:**
> **Hướng 1**: Vẫn hiển thị bảng lương DRAFT trên Dashboard này, nhưng có nhãn (Badge) màu vàng cảnh báo "Bản nháp - Chờ bạn duyệt", kèm theo nút "Duyệt bảng lương" to rõ ràng.
> **Hướng 2**: Tuân thủ ý của bạn là chỉ hiện MANAGER_CONFIRMED trở lên trên Dashboard này. Khi đó, Manager sẽ duyệt bảng lương ở một trang khác (ví dụ trang "Chờ duyệt"). Bạn đang định để Manager duyệt ở đâu?

## 5. Verification Plan
- Chạy thử nghiệm bằng tài khoản Manager.
- Xác nhận trang Dashboard chỉ hiển thị nhân viên thuộc phòng ban của Manager đó.
- Kiểm tra các công thức tính Tổng quỹ lương, Số lượng nhân sự hoạt động chính xác.
- Đảm bảo Modal chi tiết lương hiển thị đủ dữ liệu.
