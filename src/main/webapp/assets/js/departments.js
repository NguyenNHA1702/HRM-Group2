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

    // --- Deactivate action click ---
    $(document).on('click', '.btn-deactivate', function(e) {
        e.preventDefault();
        const id = $(this).data('id');
        const name = $(this).data('name');
        
        if (confirm('Bạn có chắc chắn muốn vô hiệu hóa phòng ban "' + name + '" không?')) {
            $.ajax({
                url: CTX + '/hr/departments',
                type: 'POST',
                data: {
                    action: 'deactivate',
                    id: id
                },
                success: function(response) {
                    if (response.success) {
                        alert('Vô hiệu hóa phòng ban thành công!');
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error deactivating department:', error);
                    alert('Lỗi hệ thống: Không thể vô hiệu hóa phòng ban.');
                }
            });
        }
    });

    // --- Activate action click ---
    $(document).on('click', '.btn-activate', function(e) {
        e.preventDefault();
        const id = $(this).data('id');
        const name = $(this).data('name');
        
        if (confirm('Bạn có chắc chắn muốn kích hoạt lại phòng ban "' + name + '" không?')) {
            $.ajax({
                url: CTX + '/hr/departments',
                type: 'POST',
                data: {
                    action: 'activate',
                    id: id
                },
                success: function(response) {
                    if (response.success) {
                        alert('Kích hoạt phòng ban thành công!');
                        location.reload();
                    } else {
                        alert(response.message || 'Kích hoạt thất bại.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error activating department:', error);
                    alert('Lỗi hệ thống: Không thể kích hoạt phòng ban.');
                }
            });
        }
    });

    let currentDeptId = null;

    // --- View Members Click (Populate modal and table) ---
    $(document).on('click', '.view-members', function(e) {
        e.preventDefault();
        currentDeptId = $(this).data('id');
        $('#transferAlert').hide().empty();
        $('#checkAllMembers').prop('checked', false);
        $('#targetDeptSelect').val('');
        
        // Hide the current department option in the select dropdown so we don't transfer to itself
        $('#targetDeptSelect option').show();
        if (currentDeptId) {
            $('#targetDeptSelect option[value="' + currentDeptId + '"]').hide();
        }
        
        const tbody = $('#membersTable tbody');
        tbody.html('<tr><td colspan="4" class="text-center py-4"><span class="spinner-border spinner-border-sm mr-2"></span>Đang tải danh sách thành viên...</td></tr>');
        
        $('#deptMembersModal').modal('show');
        
        $.ajax({
            url: CTX + '/hr/departments',
            type: 'GET',
            data: {
                action: 'getMembers',
                id: currentDeptId
            },
            success: function(members) {
                tbody.empty();
                if (members && members.length > 0) {
                    members.forEach(function(member) {
                        const posName = member.positionName ? member.positionName : 'Chưa có chức vụ';
                        tbody.append(
                            '<tr>' +
                            '  <td class="text-center"><input type="checkbox" class="member-checkbox" data-id="' + member.id + '" style="width: 16px; height: 16px; cursor: pointer;"></td>' +
                            '  <td><span class="font-weight-bold text-dark">' + member.employeeCode + '</span></td>' +
                            '  <td>' + member.fullName + '</td>' +
                            '  <td><span class="badge badge-light border text-secondary px-2 py-1" style="border-radius: 6px;">' + posName + '</span></td>' +
                            '</tr>'
                        );
                    });
                } else {
                    tbody.html('<tr><td colspan="4" class="text-center text-muted py-4">Phòng ban này chưa có nhân sự hoặc không có nhân sự hoạt động.</td></tr>');
                }
            },
            error: function(xhr, status, error) {
                console.error('Error fetching members:', error);
                tbody.html('<tr><td colspan="4" class="text-center text-danger py-4">Có lỗi xảy ra khi tải danh sách thành viên.</td></tr>');
            }
        });
    });

    // --- Check/Uncheck All Members ---
    $(document).on('change', '#checkAllMembers', function() {
        const isChecked = $(this).prop('checked');
        $('.member-checkbox').prop('checked', isChecked);
    });

    // Sync header checkbox state when individual checkboxes are toggled
    $(document).on('change', '.member-checkbox', function() {
        const total = $('.member-checkbox').length;
        const checked = $('.member-checkbox:checked').length;
        $('#checkAllMembers').prop('checked', total > 0 && total === checked);
    });

    // --- Bulk Transfer Selected Members ---
    $(document).on('click', '#btnTransferSelected', function(e) {
        e.preventDefault();
        $('#transferAlert').hide().empty();
        
        const targetDeptId = $('#targetDeptSelect').val();
        if (!targetDeptId) {
            $('#transferAlert').text('Vui lòng chọn phòng ban nhận cần điều chuyển.').show();
            return;
        }
        
        const employeeIds = [];
        $('.member-checkbox:checked').each(function() {
            employeeIds.push(parseInt($(this).data('id')));
        });
        
        if (employeeIds.length === 0) {
            $('#transferAlert').text('Vui lòng chọn ít nhất một nhân viên để điều chuyển.').show();
            return;
        }
        
        if (confirm('Bạn có chắc chắn muốn điều chuyển ' + employeeIds.length + ' nhân sự sang phòng ban mới không?')) {
            $.ajax({
                url: CTX + '/hr/departments',
                type: 'POST',
                data: {
                    action: 'bulkTransfer',
                    targetDepartmentId: targetDeptId,
                    employeeIds: employeeIds.join(',')
                },
                success: function(response) {
                    if (response.success) {
                        if (response.requireManagerAlert) {
                            if (typeof Swal !== 'undefined') {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Transfer successful!',
                                    text: 'Note: This department currently has no Manager. Please assign a Department Manager immediately.',
                                    confirmButtonText: 'OK'
                                }).then(function() {
                                    location.reload();
                                });
                            } else {
                                alert('Transfer successful! Note: This department currently has no Manager. Please assign a Department Manager immediately.');
                                location.reload();
                            }
                        } else {
                            alert('Điều chuyển nhân sự thành công!');
                            location.reload();
                        }
                    } else {
                        $('#transferAlert').text(response.message || 'Lỗi: Không thể thực hiện điều chuyển.').show();
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Error during bulk transfer:', error);
                    $('#transferAlert').text('Lỗi hệ thống: Điều chuyển thất bại.').show();
                }
            });
        }
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