package com.hrm.project.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class AttendanceImportResult {

    private int importedRows;
    private final List<String> errors = new ArrayList<>();

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

    public boolean isSuccess() {
        return errors.isEmpty() && importedRows > 0;
    }
}
