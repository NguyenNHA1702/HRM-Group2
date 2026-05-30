function openAddModal() {
    document.getElementById('modalTitle').innerText = "Add New Department";
    document.getElementById('modalAction').value = "add";
    document.getElementById('deptId').value = "";
    document.getElementById('deptCode').value = "";
    document.getElementById('deptCode').readOnly = false;
    document.getElementById('deptName').value = "";
    document.getElementById('deptParent').value = "";
    document.getElementById('deptDesc').value = "";
    document.getElementById('deptActive').value = "1";
}

function openEditModal(button) {
    document.getElementById('modalTitle').innerText = "Update Department Information";
    document.getElementById('modalAction').value = "update";

    document.getElementById('deptId').value = button.getAttribute('data-id');
    document.getElementById('deptCode').value = button.getAttribute('data-code');
    document.getElementById('deptCode').readOnly = true;
    document.getElementById('deptName').value = button.getAttribute('data-name');
    document.getElementById('deptParent').value = button.getAttribute('data-parent') || "";
    document.getElementById('deptDesc').value = button.getAttribute('data-desc');
    document.getElementById('deptActive').value = button.getAttribute('data-active');
}

const rowsPerPage = 10;
let currentPage = 1;
let filteredRows = [];

document.addEventListener("DOMContentLoaded", function () {
    initFilteredRows();
    renderTable();
});

function initFilteredRows() {
    const allRows = document.querySelectorAll(".dept-row");
    filteredRows = Array.from(allRows);
}

// HÀM SỬA LỖI LOGIC TÌM KIẾM VÀ LỌC TRẠNG THÁI KHÔNG CHẠY
function onFilterChange() {
    const searchKeyword = document.getElementById("searchKeyword").value.toLowerCase().trim();
    const filterParent = document.getElementById("filterParent").value.trim();
    const filterStatus = document.getElementById("filterStatus").value.trim();
    const allRows = document.querySelectorAll(".dept-row");

    filteredRows = [];

    allRows.forEach(row => {
        const code = row.getAttribute("data-code").toLowerCase().trim();
        const name = row.getAttribute("data-name").toLowerCase().trim();
        const parentName = row.getAttribute("data-parentname").trim();
        const status = row.getAttribute("data-status").trim(); // Giá trị "1" hoặc "0" dạng chuỗi sạch

        // Thực hiện so khớp dữ liệu linh hoạt (Loại bỏ toán tử === quá nghiêm ngặt với chuỗi hỗn hợp)
        const matchesSearch = (searchKeyword === "" || code.includes(searchKeyword) || name.includes(searchKeyword));
        const matchesParent = (filterParent === "" || parentName === filterParent);
        const matchesStatus = (filterStatus === "" || status === filterStatus);

        if (matchesSearch && matchesParent && matchesStatus) {
            filteredRows.push(row);
        }
        row.style.display = "none"; // Ẩn hàng loạt trước
    });

    currentPage = 1; // Khởi động lại trang đầu tiên sau khi lọc dữ liệu
    renderTable();
}

function renderTable() {
    const totalRecords = filteredRows.length;
    const noDataRow = document.getElementById("noDataRow");

    if (totalRecords === 0) {
        noDataRow.style.display = "";
        document.getElementById("paginationInfo").innerText = "Hiển thị 0 của 0 phòng ban";
        document.getElementById("paginationControls").innerHTML = "";
        return;
    } else {
        noDataRow.style.display = "none";
    }

    const totalPages = Math.ceil(totalRecords / rowsPerPage);
    const startIndex = (currentPage - 1) * rowsPerPage;
    const endIndex = Math.min(startIndex + rowsPerPage, totalRecords);

    // Kéo các dòng thuộc trang hiện hành hiển thị lên
    for (let i = startIndex; i < endIndex; i++) {
        filteredRows[i].style.display = "";
    }

    document.getElementById("paginationInfo").innerText = `Hiển thị ${startIndex + 1}-${endIndex} của ${totalRecords} phòng ban`;
    buildPaginationControls(totalPages);
}

function buildPaginationControls(totalPages) {
    const controlsContainer = document.getElementById("paginationControls");
    let html = "";

    html += `<li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                <a class="page-link" href="#" onclick="changePage(${currentPage - 1}); return false;">Trước</a>
             </li>`;

    for (let i = 1; i <= totalPages; i++) {
        html += `<li class="page-item ${currentPage === i ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="changePage(${i}); return false;" ${currentPage === i ? 'style="background-color: #6366f1; border-color: #6366f1;"' : ''}>${i}</a>
                 </li>`;
    }

    html += `<li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                <a class="page-link" href="#" onclick="changePage(${currentPage + 1}); return false;">Sau</a>
             </li>`;

    controlsContainer.innerHTML = html;
}

function changePage(pageNumber) {
    filteredRows.forEach(row => row.style.display = "none");
    currentPage = pageNumber;
    renderTable();
}