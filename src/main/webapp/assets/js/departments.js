function openAddModal() {
    $('#modalAlert').remove();
    document.getElementById('modalTitle').innerText = "Add New Department";
    document.getElementById('modalAction').value = "add";
    document.getElementById('deptId').value = "";
    document.getElementById('deptCode').value = "";
    document.getElementById('deptCode').readOnly = false;
    document.getElementById('deptName').value = "";
    document.getElementById('deptParent').value = "";
    document.getElementById('deptDesc').value = "";
    document.getElementById('deptActive').value = "1";

    // Reset autocomplete
    document.getElementById('manager_search').value = "";
    document.getElementById('manager_id').value = "";
    document.getElementById('managerHint').style.display = "none";
    document.getElementById('suggestion_box').innerHTML = "";
    $('#suggestion_box').hide();
}

function openEditModal(button) {
    $('#modalAlert').remove();
    document.getElementById('modalTitle').innerText = "Update Department Information";
    document.getElementById('modalAction').value = "update";

    document.getElementById('deptId').value = button.getAttribute('data-id');
    document.getElementById('deptCode').value = button.getAttribute('data-code');
    document.getElementById('deptCode').readOnly = true;
    document.getElementById('deptName').value = button.getAttribute('data-name');
    document.getElementById('deptParent').value = button.getAttribute('data-parent') || "";
    document.getElementById('deptDesc').value = button.getAttribute('data-desc');
    document.getElementById('deptActive').value = button.getAttribute('data-active');

    // Populate manager autocomplete
    const mgrId = button.getAttribute('data-managerid') || "";
    const mgrCode = button.getAttribute('data-managercode') || "";
    const mgrName = button.getAttribute('data-managername') || "";
    document.getElementById('manager_id').value = mgrId;
    if (mgrId && mgrCode && mgrName) {
        document.getElementById('manager_search').value = mgrCode + " - " + mgrName;
        const hint = document.getElementById('managerHint');
        hint.innerText = "✔ Đã chọn: " + mgrName + " (ID: " + mgrId + ")";
        hint.style.display = "block";
        hint.style.color = "#137333";
    } else {
        document.getElementById('manager_search').value = "";
        document.getElementById('managerHint').style.display = "none";
    }
    $('#suggestion_box').hide().empty();
}

const rowsPerPage = 10;
let currentPage = 1;
let filteredRows = [];

document.addEventListener("DOMContentLoaded", function () {
    initFilteredRows();
    renderTable();
});

// jQuery Manager Autocomplete Integration
let managerSuggestTimer = null;

$(document).ready(function() {
    $(document).on('keyup', '#manager_search', function() {
        const keyword = $(this).val().trim();
        console.log("Searching for:", keyword);
        $('#manager_id').val('');
        $('#managerHint').hide();

        if (keyword.length < 2) {
            $('#suggestion_box').hide().empty();
            return;
        }

        clearTimeout(managerSuggestTimer);
        managerSuggestTimer = setTimeout(() => {
            const url = CTX + '/hr/departments?action=suggest_manager&term=' + encodeURIComponent(keyword);
            fetch(url)
                .then(res => {
                    if (!res.ok) {
                        throw new Error("HTTP error " + res.status);
                    }
                    return res.json();
                })
                .then(data => {
                    const suggestions = $('#suggestion_box');
                    suggestions.empty();
                    if (data && data.length > 0) {
                        data.forEach(emp => {
                            suggestions.append(
                                $('<button type="button" class="dropdown-item"></button>')
                                    .text(emp.code + ' - ' + emp.name)
                                    .data('id', emp.id)
                                    .data('name', emp.name)
                            );
                        });
                        suggestions.show();
                    } else {
                        suggestions.hide();
                    }
                })
                .catch(error => {
                    console.error("AJAX Error Details:", error);
                });
        }, 300);
    });

    $(document).on('click', '#suggestion_box .dropdown-item', function(e) {
        e.preventDefault();
        const empId = $(this).data('id');
        const empName = $(this).data('name');
        const textVal = $(this).text();

        $('#manager_id').val(empId);
        $('#manager_search').val(textVal);
        $('#managerHint')
            .text("✔ Đã chọn: " + empName + " (ID: " + empId + ")")
            .css('color', '#137333')
            .show();
        $('#suggestion_box').hide().empty();

        console.log("Selected Manager ID:", $('#manager_id').val());
    });

    // Hide suggestions dropdown when clicking outside
    $(document).on('click', function(e) {
        if (!$(e.target).closest('#manager_search, #suggestion_box').length) {
            $('#suggestion_box').hide();
        }
    });

    function showModalError(message) {
        let alertDiv = $('#modalAlert');
        if (alertDiv.length === 0) {
            $('#departmentModal .modal-body').prepend('<div id="modalAlert" class="alert alert-danger" style="border-radius: 6px; font-size: 14px;"></div>');
            alertDiv = $('#modalAlert');
        }
        alertDiv.text(message).show();
    }

    // Enforce manager selection requirement on submit and validate manager positions
    $('#departmentModal form').on('submit', function(e) {
        const managerId = $('#manager_id').val();
        console.log("Submitting manager_id:", managerId);
        if (!managerId) {
            e.preventDefault();
            alert('Vui lòng chọn Trưởng phòng từ danh sách gợi ý.');
            $('#manager_search').focus();
            return;
        }

        e.preventDefault();
        const form = this;
        const url = form.action;
        const formData = new FormData(form);
        const searchParams = new URLSearchParams();
        for (const pair of formData.entries()) {
            searchParams.append(pair[0], pair[1]);
        }

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: searchParams.toString()
        })
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(text || "Error: Cannot assign an Admin or HR personnel as a Department Manager!");
                });
            }
            return response.text();
        })
        .then(html => {
            if (html.indexOf("Error: Cannot assign an Admin or HR personnel") !== -1) {
                showModalError(html);
            } else {
                // Replace page content to reflect changes and keep the success messages
                document.open();
                document.write(html);
                document.close();
            }
        })
        .catch(error => {
            console.error("Submission Error:", error);
            showModalError(error.message);
        });
    });
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