// ═══════════════════════════════════════════════════════════════════════════
// contracts.js — Client-side filtering, pagination, and modal logic
// ═══════════════════════════════════════════════════════════════════════════

const rowsPerPage = 10;
let currentPage = 1;
let filteredRows = [];

document.addEventListener("DOMContentLoaded", function () {
    initFilteredRows();
    renderTable();

    // ── Smart End Date: listen for contract type & start date changes ─────
    const typeSelect  = document.getElementById("formContractType");
    const startInput  = document.getElementById("formStartDate");

    if (typeSelect) typeSelect.addEventListener("change", applyEndDateRule);
    if (startInput) startInput.addEventListener("change", applyEndDateRule);
});

// ── Init: collect all data rows ──────────────────────────────────────────
function initFilteredRows() {
    const allRows = document.querySelectorAll(".contract-row");
    filteredRows = Array.from(allRows);
}

// ── Filter: real-time client-side search + dropdowns ─────────────────────
function onFilterChange() {
    const keyword      = document.getElementById("searchKeyword").value.toLowerCase().trim();
    const filterType   = document.getElementById("filterType").value.trim();
    const filterStatus = document.getElementById("filterStatus").value.trim();
    const allRows      = document.querySelectorAll(".contract-row");

    filteredRows = [];

    allRows.forEach(row => {
        const empCode        = row.getAttribute("data-empcode") || "";
        const empName        = row.getAttribute("data-empname") || "";
        const contractNumber = row.getAttribute("data-contractnumber") || "";
        const type           = row.getAttribute("data-type") || "";
        const status         = row.getAttribute("data-status") || "";

        const matchesSearch = (keyword === "" ||
            empCode.includes(keyword) ||
            empName.includes(keyword) ||
            contractNumber.includes(keyword));
        const matchesType   = (filterType === "" || type === filterType);
        const matchesStatus = (filterStatus === "" || status === filterStatus);

        if (matchesSearch && matchesType && matchesStatus) {
            filteredRows.push(row);
        }
        row.style.display = "none";
    });

    currentPage = 1;
    renderTable();
}

// ── Pagination: render visible rows for the current page ─────────────────
function renderTable() {
    const totalRecords = filteredRows.length;
    const noDataRow    = document.getElementById("noDataRow");

    if (totalRecords === 0) {
        noDataRow.style.display = "";
        document.getElementById("paginationInfo").innerText = "Hiển thị 0 của 0 hợp đồng";
        document.getElementById("paginationControls").innerHTML = "";
        return;
    } else {
        noDataRow.style.display = "none";
    }

    const totalPages = Math.ceil(totalRecords / rowsPerPage);
    const startIndex = (currentPage - 1) * rowsPerPage;
    const endIndex   = Math.min(startIndex + rowsPerPage, totalRecords);

    for (let i = startIndex; i < endIndex; i++) {
        filteredRows[i].style.display = "";
    }

    document.getElementById("paginationInfo").innerText =
        `Hiển thị ${startIndex + 1}-${endIndex} của ${totalRecords} hợp đồng`;
    buildPaginationControls(totalPages);
}

function buildPaginationControls(totalPages) {
    const container = document.getElementById("paginationControls");
    let html = "";

    // Previous
    html += `<li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                <a class="page-link" href="#" onclick="changePage(${currentPage - 1}); return false;">Trước</a>
             </li>`;

    // Page numbers (show max 5 centered around current)
    let startPage = Math.max(1, currentPage - 2);
    let endPage   = Math.min(totalPages, startPage + 4);
    if (endPage - startPage < 4) startPage = Math.max(1, endPage - 4);

    for (let i = startPage; i <= endPage; i++) {
        html += `<li class="page-item ${currentPage === i ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="changePage(${i}); return false;"
                       ${currentPage === i ? 'style="background-color: #6366f1; border-color: #6366f1;"' : ''}>${i}</a>
                 </li>`;
    }

    // Next
    html += `<li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                <a class="page-link" href="#" onclick="changePage(${currentPage + 1}); return false;">Sau</a>
             </li>`;

    container.innerHTML = html;
}

function changePage(pageNumber) {
    filteredRows.forEach(row => row.style.display = "none");
    currentPage = pageNumber;
    renderTable();
}

// ═══════════════════════════════════════════════════════════════════════════
// MODAL: Tạo hợp đồng mới
// ═══════════════════════════════════════════════════════════════════════════

function openCreateModal() {
    document.getElementById("contractModalTitle").innerText = "Tạo hợp đồng mới";
    document.getElementById("modalAction").value = "create";
    document.getElementById("oldContractId").value = "";

    // Clear all fields
    document.getElementById("formEmployeeId").value = "";
    document.getElementById("formEmployeeId").readOnly = false;
    document.getElementById("formContractNumber").value = "";
    document.getElementById("formContractType").value = "1";
    document.getElementById("formStartDate").value = todayISO();
    document.getElementById("formEndDate").value = "";
    document.getElementById("formEndDate").readOnly = false;
    document.getElementById("formBaseSalary").value = "";
    document.getElementById("formDescription").value = "";
    document.getElementById("formContractFile").value = "";

    document.getElementById("btnSubmitContract").innerText = "Lưu hợp đồng";
    document.getElementById("btnSubmitContract").style.backgroundColor = "#6366f1";

    applyEndDateRule();
    $('#contractModal').modal('show');
}

// ═══════════════════════════════════════════════════════════════════════════
// VIEW FILE: Open scanned contract in new tab or show warning
// ═══════════════════════════════════════════════════════════════════════════

function openFileView(btn) {
    const fileUrl = btn.getAttribute("data-fileurl");

    if (fileUrl && fileUrl.trim() !== "" && fileUrl !== "null") {
        // Prepend context path for relative server URLs
        const url = fileUrl.trim().startsWith("http") ? fileUrl.trim() : CTX + "/" + fileUrl.trim();
        window.open(url, '_blank');
    } else {
        showAlert("warning", "Hợp đồng này chưa được upload file scan lên hệ thống.");
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODAL: Gia hạn hợp đồng
// ═══════════════════════════════════════════════════════════════════════════

function openRenewModal(btn) {
    document.getElementById("contractModalTitle").innerText = "Gia hạn hợp đồng — " + btn.getAttribute("data-empname");
    document.getElementById("modalAction").value = "renew";
    document.getElementById("oldContractId").value = btn.getAttribute("data-id");

    document.getElementById("formEmployeeId").value = btn.getAttribute("data-employeeid");
    document.getElementById("formEmployeeId").readOnly = true;
    document.getElementById("formContractNumber").value = "";
    document.getElementById("formContractType").value = btn.getAttribute("data-type") || "2";
    document.getElementById("formStartDate").value = todayISO();
    document.getElementById("formEndDate").value = "";
    document.getElementById("formEndDate").readOnly = false;
    document.getElementById("formBaseSalary").value = parseFloat(btn.getAttribute("data-salary") || "0");
    document.getElementById("formDescription").value = "";
    document.getElementById("formContractFile").value = "";

    document.getElementById("btnSubmitContract").innerText = "Xác nhận gia hạn";
    document.getElementById("btnSubmitContract").style.backgroundColor = "#059669";

    applyEndDateRule();
    $('#contractModal').modal('show');
}

// ═══════════════════════════════════════════════════════════════════════════
// MODAL: Chấm dứt hợp đồng
// ═══════════════════════════════════════════════════════════════════════════

function openTerminateModal(btn) {
    document.getElementById("terminateContractId").value = btn.getAttribute("data-id");
    document.getElementById("terminateContractLabel").innerText = btn.getAttribute("data-contractnumber");
    document.getElementById("terminateEmpName").innerText = btn.getAttribute("data-empname");
    document.getElementById("terminateReason").value = "";

    $('#terminateModal').modal('show');
}

// ═══════════════════════════════════════════════════════════════════════════
// AJAX SUBMIT: Create / Renew (multipart/form-data for file upload)
// ═══════════════════════════════════════════════════════════════════════════

const ALLOWED_FILE_TYPES = ['application/pdf', 'image/jpeg', 'image/png'];
const ALLOWED_EXTENSIONS = ['.pdf', '.jpg', '.jpeg', '.png'];

function submitContract() {
    const action         = document.getElementById("modalAction").value;
    const employeeId     = document.getElementById("formEmployeeId").value;
    const contractNumber = document.getElementById("formContractNumber").value.trim();
    const contractType   = document.getElementById("formContractType").value;
    const startDate      = document.getElementById("formStartDate").value;
    const endDate        = document.getElementById("formEndDate").value;
    const baseSalary     = document.getElementById("formBaseSalary").value;
    const description    = document.getElementById("formDescription").value;
    const fileInput      = document.getElementById("formContractFile");

    if (!employeeId || !contractNumber || !contractType || !startDate || !baseSalary) {
        showAlert("error", "Vui lòng điền đầy đủ các trường bắt buộc.");
        return;
    }

    // ── File validation: bắt buộc khi tạo mới ──────────────────────────
    if (action === "create") {
        if (!fileInput.files || fileInput.files.length === 0) {
            showAlert("error", "Vui lòng chọn file hợp đồng scan (PDF, JPG, JPEG hoặc PNG).");
            return;
        }
    }

    // ── Validate file format (if a file is selected) ───────────────────
    if (fileInput.files && fileInput.files.length > 0) {
        const file = fileInput.files[0];
        const fileName = file.name.toLowerCase();
        const hasValidExt = ALLOWED_EXTENSIONS.some(ext => fileName.endsWith(ext));

        if (!hasValidExt) {
            showAlert("error", "Định dạng file không hợp lệ. Chỉ chấp nhận: PDF, JPG, JPEG, PNG.");
            return;
        }
    }

    // ── Build FormData (multipart) ─────────────────────────────────────
    const formData = new FormData();
    formData.append("action", action);
    formData.append("employeeId", employeeId);
    formData.append("contractNumber", contractNumber);
    formData.append("contractType", contractType);
    formData.append("startDate", startDate);
    formData.append("endDate", endDate);
    formData.append("baseSalary", baseSalary);
    formData.append("description", description);

    if (fileInput.files && fileInput.files.length > 0) {
        formData.append("contractFile", fileInput.files[0]);
    }

    if (action === "renew") {
        formData.append("oldContractId", document.getElementById("oldContractId").value);
    }

    fetch(CTX + "/hr/api/contracts", {
        method: "POST",
        body: formData  // No Content-Type header — browser sets multipart boundary automatically
    })
    .then(res => res.json())
    .then(data => {
        if (data.status === "success") {
            $('#contractModal').modal('hide');
            showAlert("success", data.message);
            setTimeout(() => location.reload(), 1200);
        } else {
            showAlert("error", data.message || data.error || "Lỗi không xác định từ máy chủ.");
        }
    })
    .catch(err => {
        showAlert("error", "Lỗi kết nối mạng: " + err.message);
    });
}

// ═══════════════════════════════════════════════════════════════════════════
// AJAX SUBMIT: Terminate
// ═══════════════════════════════════════════════════════════════════════════

function submitTerminate() {
    const contractId = document.getElementById("terminateContractId").value;
    const reason     = document.getElementById("terminateReason").value;

    const params = new URLSearchParams();
    params.append("action", "terminate");
    params.append("contractId", contractId);
    params.append("reason", reason);

    fetch(CTX + "/hr/api/contracts", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
        body: params.toString()
    })
    .then(res => res.json())
    .then(data => {
        if (data.status === "success") {
            $('#terminateModal').modal('hide');
            showAlert("success", data.message);
            setTimeout(() => location.reload(), 1200);
        } else {
            // Show exact server error message
            showAlert("error", data.message || data.error || "Lỗi không xác định từ máy chủ.");
        }
    })
    .catch(err => {
        showAlert("error", "Lỗi kết nối mạng: " + err.message);
    });
}

// ═══════════════════════════════════════════════════════════════════════════
// UTILITIES
// ═══════════════════════════════════════════════════════════════════════════

function showAlert(type, message) {
    const container = document.getElementById("alertContainer");

    let color, border, bgColor;
    if (type === "success") {
        color = "#137333"; border = "#34a853"; bgColor = "#e6f4ea";
    } else if (type === "warning") {
        color = "#92400e"; border = "#f59e0b"; bgColor = "#fffbeb";
    } else {
        color = "#c5221f"; border = "#ea4335"; bgColor = "#fce8e6";
    }

    container.innerHTML = `
        <div class="alert alert-dismissible fade show border-0 shadow-sm mb-4" role="alert"
             style="border-left: 4px solid ${border} !important; background-color: ${bgColor}; color: ${color}; border-radius: 8px;">
            ${message}
            <button type="button" class="close" data-dismiss="alert" aria-label="Close" style="outline: none;">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>`;

    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        const alert = container.querySelector('.alert');
        if (alert) alert.remove();
    }, 5000);
}

function todayISO() {
    const d = new Date();
    return d.getFullYear() + '-' +
        String(d.getMonth() + 1).padStart(2, '0') + '-' +
        String(d.getDate()).padStart(2, '0');
}

function formatDateForInput(dateStr) {
    // Handle both "yyyy-MM-dd" and "Mon Jun 10 ..." formats
    if (!dateStr || dateStr === "null") return "";
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return d.getFullYear() + '-' +
        String(d.getMonth() + 1).padStart(2, '0') + '-' +
        String(d.getDate()).padStart(2, '0');
}

// ═══════════════════════════════════════════════════════════════════════════
// SMART END DATE: Auto-calculate based on contract type + start date
// ═══════════════════════════════════════════════════════════════════════════

function applyEndDateRule() {
    const typeValue   = document.getElementById("formContractType").value;
    const startDate   = document.getElementById("formStartDate").value;
    const endDateEl   = document.getElementById("formEndDate");

    switch (typeValue) {

        case "2": // Chính thức 1 năm → auto +1 year, lock field
            if (startDate) {
                const d = new Date(startDate);
                d.setFullYear(d.getFullYear() + 1);
                endDateEl.value = d.getFullYear() + '-' +
                    String(d.getMonth() + 1).padStart(2, '0') + '-' +
                    String(d.getDate()).padStart(2, '0');
            } else {
                endDateEl.value = "";
            }
            endDateEl.readOnly = true;
            break;

        case "3": // Không thời hạn → clear & lock
            endDateEl.value    = "";
            endDateEl.readOnly = true;
            break;

        case "1": // Thử việc → editable
        case "4": // Thời vụ  → editable
        default:
            endDateEl.readOnly = false;
            break;
    }
}
