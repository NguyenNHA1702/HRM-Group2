package com.hrm.project.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class AttendanceImportResult {

    private int importedRows;
    private final List<String> errors      = new ArrayList<>();
    private final List<String> skippedRows = new ArrayList<>();

    public int getImportedRows() {
        return importedRows;
    }

    public void setImportedRows(int importedRows) {
        this.importedRows = importedRows;
    }

    public List<String> getErrors() {
        return Collections.unmodifiableList(errors);
    }

    public void addError(String error) {
        errors.add(error);
    }

    /** Danh sách cảnh báo các dòng bị bỏ qua (trùng ngày nghỉ phép đã duyệt). */
    public List<String> getSkippedRows() {
        return Collections.unmodifiableList(skippedRows);
    }

    public void addSkipped(String warning) {
        skippedRows.add(warning);
    }

    public int getSkippedCount() {
        return skippedRows.size();
    }

    public boolean hasSkipped() {
        return !skippedRows.isEmpty();
    }

    /**
     * Thành công khi không có lỗi nghiêm trọng VÀ có ít nhất 1 dòng được import.
     * Các dòng bị skip không ảnh hưởng đến trạng thái thành công.
     */
    public boolean isSuccess() {
        return errors.isEmpty() && importedRows > 0;
    }
}
