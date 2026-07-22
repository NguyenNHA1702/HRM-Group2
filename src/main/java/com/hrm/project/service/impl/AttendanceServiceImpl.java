package com.hrm.project.service.impl;

import com.hrm.project.dao.AttendanceDAO;
import com.hrm.project.dao.impl.AttendanceDAOImpl;
import com.hrm.project.model.Attendance;
import com.hrm.project.model.AttendanceExplanation;
import com.hrm.project.model.AttendanceImportResult;
import com.hrm.project.model.dtos.response.AttendanceEmployeeStatsDto;
import com.hrm.project.model.dtos.response.AttendanceSystemStatsDto;
import com.hrm.project.service.AttendanceService;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class AttendanceServiceImpl implements AttendanceService {

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("H:mm");
    private static final List<String> REQUIRED_HEADERS = List.of("date");
    private static final List<String> VALID_STATUSES =
            List.of("PRESENT", "LATE", "EARLY_LEAVE", "ABSENT", "HOLIDAY", "LEAVE");
    private static final Map<String, String> STATUS_ALIASES = createStatusAliases();

    private final AttendanceDAO attendanceDAO;

    public AttendanceServiceImpl() {
        this(new AttendanceDAOImpl());
    }

    AttendanceServiceImpl(AttendanceDAO attendanceDAO) {
        this.attendanceDAO = attendanceDAO;
    }

    @Override
    public List<Attendance> getAttendanceByMonth(int year, int month, int employeeId) {
        return attendanceDAO.getAttendanceByMonth(year, month, employeeId);
    }

    @Override
    public AttendanceSystemStatsDto getSystemStatistics(int year, int month) {
        List<AttendanceEmployeeStatsDto> employees =
                attendanceDAO.getEmployeeStatistics(year, month);
        AttendanceSystemStatsDto statistics = new AttendanceSystemStatsDto();
        statistics.setEmployees(employees);
        statistics.setTotalEmployees(employees.size());
        statistics.setExpectedWorkDays(countWorkingDays(year, month) * employees.size());

        int workDays = 0;
        int lateCount = 0;
        int absentCount = 0;
        int leaveCount = 0;
        int overtimeMinutes = 0;
        for (AttendanceEmployeeStatsDto employee : employees) {
            workDays += employee.getWorkDays();
            lateCount += employee.getLateCount();
            absentCount += employee.getAbsentCount();
            leaveCount += employee.getLeaveCount();
            overtimeMinutes += employee.getOvertimeMinutes();
        }

        statistics.setWorkDays(workDays);
        statistics.setLateCount(lateCount);
        statistics.setAbsentCount(absentCount);
        statistics.setLeaveCount(leaveCount);
        statistics.setOvertimeMinutes(overtimeMinutes);
        return statistics;
    }

    static int countWorkingDays(int year, int month) {
        LocalDate date = LocalDate.of(year, month, 1);
        int workingDays = 0;
        while (date.getMonthValue() == month) {
            switch (date.getDayOfWeek()) {
                case SATURDAY:
                case SUNDAY:
                    break;
                default:
                    workingDays++;
                    break;
            }
            date = date.plusDays(1);
        }
        return workingDays;
    }

    @Override
    public AttendanceImportResult importFromExcel(InputStream inputStream) {
        AttendanceImportResult result = new AttendanceImportResult();
        List<Attendance> attendances = new ArrayList<>();
        DataFormatter formatter = new DataFormatter(Locale.US);

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getNumberOfSheets() == 0 ? null : workbook.getSheetAt(0);
            if (sheet == null || sheet.getPhysicalNumberOfRows() == 0) {
                result.addError("File Excel không có dữ liệu.");
                return result;
            }

            Row headerRow = findHeaderRow(sheet, formatter);
            if (headerRow == null) {
                result.addError(
                        "Không tìm thấy dòng tiêu đề có Ngày chấm công và "
                                + "ID nhân viên hoặc Mã nhân viên.");
                return result;
            }
            Map<String, Integer> columns = readHeader(headerRow, formatter);
            for (String requiredHeader : REQUIRED_HEADERS) {
                if (!columns.containsKey(requiredHeader)) {
                    result.addError("Thiếu cột bắt buộc: Ngày chấm công.");
                }
            }
            if (!columns.containsKey("employee_id") && !columns.containsKey("employee_code")) {
                result.addError("Thiếu cột ID nhân viên hoặc Mã nhân viên.");
            }
            if (!result.getErrors().isEmpty()) {
                return result;
            }

            for (int rowIndex = headerRow.getRowNum() + 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                Row row = sheet.getRow(rowIndex);
                if (row == null || isEmptyRow(row, formatter)) {
                    continue;
                }
                try {
                    attendances.add(readAttendance(row, columns, formatter));
                } catch (IllegalArgumentException e) {
                    result.addError("Dòng " + (rowIndex + 1) + ": " + e.getMessage());
                }
            }

            if (!result.getErrors().isEmpty()) {
                return result;
            }
            if (attendances.isEmpty()) {
                result.addError("File Excel không có dòng dữ liệu hợp lệ.");
                return result;
            }

            // ── Bảo vệ ngày nghỉ phép đã duyệt ─────────────────────────────────
            // Query một lần duy nhất để lấy tất cả (employeeId, date) đang LEAVE
            // trong tập hợp sẽ import. Key format: "empId_yyyy-MM-dd_empCode|leaveTypeName"
            Set<String> leaveKeys = attendanceDAO.getApprovedLeaveDateKeys(attendances);

            List<Attendance> toImport = new ArrayList<>();
            for (Attendance att : attendances) {
                String skippedLeaveType = findLeaveKey(leaveKeys, att);
                if (skippedLeaveType != null) {
                    // Bản ghi này trùng với ngày nghỉ phép đã duyệt → bỏ qua + cảnh báo
                    String empLabel = att.getEmployeeCode() != null
                            ? att.getEmployeeCode()
                            : "ID=" + att.getEmployeeId();
                    String dateLabel = att.getDate()
                            .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                    result.addSkipped(
                            "Nhân viên " + empLabel + " ngày " + dateLabel
                            + ": Đang nghỉ phép [" + skippedLeaveType + "] đã được duyệt — bỏ qua.");
                } else {
                    toImport.add(att);
                }
            }

            if (toImport.isEmpty()) {
                // Tất cả dòng đều bị bỏ qua vì trùng nghỉ phép đã duyệt
                result.addError(
                        "Tất cả " + result.getSkippedCount()
                        + " dòng trong file trùng với ngày nghỉ phép đã được duyệt. "
                        + "Không có dữ liệu nào được import.");
                return result;
            }

            result.setImportedRows(attendanceDAO.importAttendances(toImport));
            // ─────────────────────────────────────────────────────────────────

        } catch (SQLException e) {
            result.addError(e.getMessage());
        } catch (Exception e) {
            result.addError("Không thể đọc file .xlsx. Vui lòng kiểm tra lại định dạng file.");
        }
        return result;
    }

    /**
     * Tìm key nghỉ phép tương ứng với bản ghi attendance trong tập leaveKeys.
     * Trả về tên loại nghỉ phép nếu tìm thấy, null nếu không bị bảo vệ.
     *
     * Key format trong Set (từ DAO): "empId_yyyy-MM-dd_empCode|leaveTypeName"
     *  - Nếu att có employeeId → tìm key bắt đầu bằng "empId_date_"
     *  - Nếu att chỉ có employeeCode → tìm key chứa "_date_empCode"
     */
    private String findLeaveKey(Set<String> leaveKeys, Attendance att) {
        if (att.getDate() == null || leaveKeys.isEmpty()) return null;
        String dateStr = att.getDate().toString(); // yyyy-MM-dd

        if (att.getEmployeeId() != null) {
            // Match chính xác theo empId + date
            String prefix = att.getEmployeeId() + "_" + dateStr + "_";
            for (String key : leaveKeys) {
                if (key.startsWith(prefix)) {
                    // Lấy phần sau dấu '|' = leaveTypeName
                    int pipe = key.indexOf('|');
                    return pipe >= 0 ? key.substring(pipe + 1) : "Nghỉ phép";
                }
            }
        } else if (att.getEmployeeCode() != null && !att.getEmployeeCode().isBlank()) {
            // Match theo empCode + date: key có dạng "empId_date_empCode|leaveType"
            for (String key : leaveKeys) {
                int pipeIdx = key.indexOf('|');
                if (pipeIdx < 0) continue;
                String keyPart = key.substring(0, pipeIdx); // "empId_date_empCode"
                if (keyPart.contains("_" + dateStr + "_" + att.getEmployeeCode().trim())) {
                    return key.substring(pipeIdx + 1);
                }
            }
        }
        return null;
    }

    @Override
    public int[] detectImportMonthYear(byte[] fileData) {
        DataFormatter formatter = new DataFormatter(Locale.US);
        try (Workbook workbook = new XSSFWorkbook(new ByteArrayInputStream(fileData))) {
            Sheet sheet = workbook.getNumberOfSheets() == 0 ? null : workbook.getSheetAt(0);
            if (sheet == null) {
                return null;
            }
            Row headerRow = findHeaderRow(sheet, formatter);
            if (headerRow == null) {
                return null;
            }
            Map<String, Integer> columns = readHeader(headerRow, formatter);
            Integer dateCol = columns.get("date");
            if (dateCol == null) {
                return null;
            }
            for (int rowIndex = headerRow.getRowNum() + 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                Row row = sheet.getRow(rowIndex);
                if (row == null || isEmptyRow(row, formatter)) {
                    continue;
                }
                try {
                    LocalDate date = readDate(row, dateCol, formatter);
                    return new int[]{date.getYear(), date.getMonthValue()};
                } catch (IllegalArgumentException ignored) {
                    // thử dòng tiếp theo
                }
            }
        } catch (Exception ignored) {
            // không thể đọc file
        }
        return null;
    }

    private Row findHeaderRow(Sheet sheet, DataFormatter formatter) {
        int lastCandidateRow = Math.min(sheet.getLastRowNum(), sheet.getFirstRowNum() + 19);
        for (int rowIndex = sheet.getFirstRowNum(); rowIndex <= lastCandidateRow; rowIndex++) {
            Row row = sheet.getRow(rowIndex);
            if (row == null) {
                continue;
            }
            Map<String, Integer> columns = readHeader(row, formatter);
            if (columns.containsKey("date")
                    && (columns.containsKey("employee_id")
                    || columns.containsKey("employee_code"))) {
                return row;
            }
        }
        return null;
    }

    private Map<String, Integer> readHeader(Row row, DataFormatter formatter) {
        if (row == null) {
            throw new IllegalArgumentException("File Excel không có dòng tiêu đề.");
        }
        Map<String, Integer> columns = new HashMap<>();
        for (Cell cell : row) {
            String header = canonicalKey(formatter.formatCellValue(cell));
            if ("ma_nhan_vien".equals(header) || "ma_nv".equals(header)
                    || "employee_code".equals(header)) {
                header = "employee_code";
            } else if ("id".equals(header) || "id_nhan_vien".equals(header)
                    || "employee_id".equals(header)) {
                header = "employee_id";
            } else if ("ngay".equals(header) || "ngay_cham_cong".equals(header)) {
                header = "date";
            } else if ("gio_vao".equals(header) || "thoi_gian_vao".equals(header)
                    || "check_in".equals(header)) {
                header = "check_in";
            } else if ("gio_ra".equals(header) || "thoi_gian_ra".equals(header)
                    || "check_out".equals(header)) {
                header = "check_out";
            } else if ("trang_thai".equals(header) || "tinh_trang".equals(header)) {
                header = "status";
            } else if ("ghi_chu".equals(header) || "ly_do".equals(header)) {
                header = "note";
            }
            if (!header.isEmpty()) {
                columns.put(header, cell.getColumnIndex());
            }
        }
        return columns;
    }

    private Attendance readAttendance(Row row, Map<String, Integer> columns, DataFormatter formatter) {
        Attendance attendance = new Attendance();
        attendance.setEmployeeId(readInteger(row, columns.get("employee_id"), formatter));
        attendance.setEmployeeCode(readText(row, columns.get("employee_code"), formatter));
        if (attendance.getEmployeeId() == null
                && (attendance.getEmployeeCode() == null || attendance.getEmployeeCode().isBlank())) {
            throw new IllegalArgumentException(
                    "ID nhân viên hoặc Mã nhân viên không được để trống.");
        }
        attendance.setDate(readDate(row, columns.get("date"), formatter));
        attendance.setCheckIn(readTime(row, columns.get("check_in"), formatter));
        attendance.setCheckOut(readTime(row, columns.get("check_out"), formatter));
        attendance.setStatus(normalizeStatus(
                attendance.getDate(),
                readText(row, columns.get("status"), formatter),
                attendance.getCheckIn(), attendance.getCheckOut()));
        attendance.setNote(readText(row, columns.get("note"), formatter));

        if (attendance.getCheckIn() != null && attendance.getCheckOut() != null
                && !attendance.getCheckOut().isAfter(attendance.getCheckIn())) {
            throw new IllegalArgumentException("Giờ ra phải sau Giờ vào.");
        }
        return attendance;
    }

    private LocalDate readDate(Row row, Integer column, DataFormatter formatter) {
        if (column == null) {
            throw new IllegalArgumentException("Thiếu cột Ngày chấm công.");
        }
        Cell cell = row.getCell(column);
        if (cell == null) {
            throw new IllegalArgumentException("Ngày chấm công không được để trống.");
        }
        if (cell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(cell)) {
            Date date = cell.getDateCellValue();
            return date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        }

        String value = formatter.formatCellValue(cell).trim();
        if (value.isEmpty()) {
            throw new IllegalArgumentException("Ngày chấm công không được để trống.");
        }
        try {
            return LocalDate.parse(value, DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (DateTimeParseException ignored) {
            try {
                return LocalDate.parse(value, DATE_FORMAT);
            } catch (DateTimeParseException e) {
                throw new IllegalArgumentException(
                        "Ngày chấm công phải có dạng yyyy-MM-dd hoặc dd/MM/yyyy.");
            }
        }
    }

    private LocalTime readTime(Row row, Integer column, DataFormatter formatter) {
        if (column == null) {
            return null;
        }
        Cell cell = row.getCell(column);
        if (cell == null) {
            return null;
        }
        if (cell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(cell)) {
            LocalDateTime value = cell.getLocalDateTimeCellValue();
            return value.toLocalTime().withSecond(0).withNano(0);
        }
        String value = formatter.formatCellValue(cell).trim();
        if (value.isEmpty()) {
            return null;
        }
        try {
            return LocalTime.parse(value, TIME_FORMAT);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Giờ vào và Giờ ra phải có dạng HH:mm.");
        }
    }

    private String normalizeStatus(LocalDate date, String status, LocalTime checkIn, LocalTime checkOut) {
        boolean isWeekend = date != null && (date.getDayOfWeek() == java.time.DayOfWeek.SATURDAY || date.getDayOfWeek() == java.time.DayOfWeek.SUNDAY);
        
        if (checkIn == null && checkOut == null && isWeekend) {
            return "HOLIDAY";
        }

        if (status == null) {
            if (checkIn == null && checkOut == null) {
                return "ABSENT";
            }
            return checkIn != null && checkIn.isAfter(LocalTime.of(8, 0)) ? "LATE" : "PRESENT";
        }

        String normalized = canonicalKey(status).toUpperCase(Locale.ROOT);
        normalized = STATUS_ALIASES.getOrDefault(normalized, normalized);

        if (!VALID_STATUSES.contains(normalized)) {
            throw new IllegalArgumentException(
                    "Trạng thái không hợp lệ. Dùng: Đủ công, Đi muộn, Về sớm, "
                            + "Vắng mặt, Ngày nghỉ, Nghỉ lễ, Nghỉ phép hoặc Tăng ca.");
        }
        return normalized;
    }

    private static Map<String, String> createStatusAliases() {
        Map<String, String> aliases = new HashMap<>();
        aliases.put("DU_CONG", "PRESENT");
        aliases.put("DUNG_GIO", "PRESENT");
        aliases.put("CO_MAT", "PRESENT");
        aliases.put("ON_TIME", "PRESENT");
        aliases.put("FULL_DAY", "PRESENT");
        aliases.put("TANG_CA", "PRESENT");
        aliases.put("OVERTIME", "PRESENT");
        aliases.put("DI_MUON", "LATE");
        aliases.put("MUON", "LATE");
        aliases.put("VE_SOM", "EARLY_LEAVE");
        aliases.put("VANG_MAT", "ABSENT");
        aliases.put("VANG", "ABSENT");
        aliases.put("NGHI_KHONG_PHEP", "ABSENT");
        aliases.put("NGAY_LE", "HOLIDAY");
        aliases.put("NGHI_LE", "HOLIDAY");
        aliases.put("NGAY_NGHI", "HOLIDAY");
        aliases.put("CUOI_TUAN", "HOLIDAY");
        aliases.put("NGHI_PHEP", "LEAVE");
        aliases.put("NGHI_CO_PHEP", "LEAVE");
        aliases.put("CO_PHEP", "LEAVE");
        return aliases;
    }

    private String readText(Row row, Integer column, DataFormatter formatter) {
        if (column == null) {
            return null;
        }
        Cell cell = row.getCell(column);
        return cell == null ? null : trimToNull(formatter.formatCellValue(cell));
    }

    private Integer readInteger(Row row, Integer column, DataFormatter formatter) {
        String value = readText(row, column, formatter);
        if (value == null) {
            return null;
        }
        try {
            return new BigDecimal(value).intValueExact();
        } catch (ArithmeticException | NumberFormatException e) {
            throw new IllegalArgumentException("ID nhân viên phải là số nguyên.");
        }
    }

    @Override
    public boolean submitExplanation(int employeeId, String date, String reason) {
        if (date == null || date.isBlank()) {
            throw new IllegalArgumentException("Ngay giai trinh khong hop le.");
        }
        if (reason == null || reason.trim().isEmpty()) {
            throw new IllegalArgumentException("Noi dung giai trinh khong duoc de trong.");
        }
        if (reason.trim().length() > 1000) {
            throw new IllegalArgumentException("Noi dung giai trinh khong duoc vuot qua 1000 ky tu.");
        }
        try {
            LocalDate explanationDate = LocalDate.parse(date);
            if (explanationDate.isAfter(LocalDate.now())) {
                throw new IllegalArgumentException("Khong the gui giai trinh cho ngay tuong lai.");
            }
            return attendanceDAO.submitExplanation(employeeId, explanationDate, reason.trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Ngay giai trinh khong hop le.");
        }
    }

    @Override
    public List<AttendanceExplanation> getExplanations(Integer departmentId, String statusFilter, int page, int pageSize) {
        return attendanceDAO.getExplanations(departmentId, statusFilter, page, pageSize);
    }

    @Override
    public int countExplanations(Integer departmentId, String statusFilter) {
        return attendanceDAO.countExplanations(departmentId, statusFilter);
    }

    @Override
    public boolean reviewExplanation(long id, String reviewStatus, int reviewedBy, String reviewComment) {
        return attendanceDAO.reviewExplanation(id, reviewStatus, reviewedBy, reviewComment);
    }

    @Override
    public AttendanceExplanation getExplanationById(long id) {
        return attendanceDAO.getExplanationById(id);
    }

    @Override
    public AttendanceExplanation getExplanationByEmployeeDate(int employeeId, LocalDate date) {
        return attendanceDAO.getExplanationByEmployeeDate(employeeId, date);
    }

    @Override
    public Map<String, AttendanceExplanation> getExplanationsByMonth(int employeeId, int year, int month) {
        return attendanceDAO.getExplanationsByMonth(employeeId, year, month);
    }

    @Override
    public boolean isAttendanceLocked(int year, int month) {
        return attendanceDAO.isAttendanceLocked(year, month);
    }

    @Override
    public boolean lockAttendance(int year, int month, int lockedBy) {
        return attendanceDAO.lockAttendance(year, month, lockedBy);
    }

    @Override
    public boolean unlockAttendance(int year, int month) {
        return attendanceDAO.unlockAttendance(year, month);
    }

    @Override
    public boolean isDepartmentAttendanceLocked(int departmentId, int year, int month) {
        return attendanceDAO.isDepartmentAttendanceLocked(departmentId, year, month);
    }

    @Override
    public boolean lockDepartmentAttendance(int departmentId, int year, int month, int lockedBy) {
        return attendanceDAO.lockDepartmentAttendance(departmentId, year, month, lockedBy);
    }

    @Override
    public boolean unlockDepartmentAttendance(int departmentId, int year, int month) {
        return attendanceDAO.unlockDepartmentAttendance(departmentId, year, month);
    }

    @Override
    public boolean isAttendanceLockedForEmployee(int employeeId, int year, int month) {
        return attendanceDAO.isAttendanceLockedForEmployee(employeeId, year, month);
    }

    @Override
    public java.util.List<java.util.Map<String, Object>> getDepartmentLockStatuses(int year, int month) {
        return attendanceDAO.getDepartmentLockStatuses(year, month);
    }

    @Override
    public AttendanceSystemStatsDto getDepartmentStatistics(int departmentId, int year, int month) {
        List<AttendanceEmployeeStatsDto> employees =
                attendanceDAO.getDepartmentEmployeeStatistics(departmentId, year, month);
        AttendanceSystemStatsDto statistics = new AttendanceSystemStatsDto();
        statistics.setEmployees(employees);
        statistics.setTotalEmployees(employees.size());
        statistics.setExpectedWorkDays(countWorkingDays(year, month) * employees.size());

        int workDays = 0;
        int lateCount = 0;
        int absentCount = 0;
        int leaveCount = 0;
        int overtimeMinutes = 0;
        for (AttendanceEmployeeStatsDto employee : employees) {
            workDays += employee.getWorkDays();
            lateCount += employee.getLateCount();
            absentCount += employee.getAbsentCount();
            leaveCount += employee.getLeaveCount();
            overtimeMinutes += employee.getOvertimeMinutes();
        }

        statistics.setWorkDays(workDays);
        statistics.setLateCount(lateCount);
        statistics.setAbsentCount(absentCount);
        statistics.setLeaveCount(leaveCount);
        statistics.setOvertimeMinutes(overtimeMinutes);
        return statistics;
    }

    private boolean isEmptyRow(Row row, DataFormatter formatter) {
        for (Cell cell : row) {
            if (!formatter.formatCellValue(cell).trim().isEmpty()) {
                return false;
            }
        }
        return true;
    }

    private String trimToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    static String canonicalKey(String value) {
        String vietnameseAscii = value == null
                ? ""
                : value.trim().replace('Đ', 'D').replace('đ', 'd');
        String normalized = Normalizer.normalize(vietnameseAscii, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "_")
                .replaceAll("^_+|_+$", "");
        return normalized;
    }
}
