// State Management
let currentPage = 1;
const itemsPerPage = 6;
let filteredRoles = [...rolesData];
let currentRoleId = null;
let confirmCallback = null;

// Toast Notifications System
function showToast(type, message) {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    const icon = type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation';
    
    toast.innerHTML = `
        <div class="toast-icon">
            <i class="fa-solid ${icon}"></i>
        </div>
        <div class="flex-1">
            <p class="text-sm font-bold text-slate-800">${type === 'success' ? 'Thành công' : 'Thất bại'}</p>
            <p class="text-xs text-slate-500">${message}</p>
        </div>
    `;
    
    container.appendChild(toast);
    
    // Trigger transition
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Remove after 3.5s
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 400);
    }, 3500);
}

// Confirmation Dialog Modal logic
function confirmAction(title, message, onConfirm) {
    document.getElementById('confirm-title').innerText = title;
    document.getElementById('confirm-message').innerText = message;
    document.getElementById('confirm-modal').classList.add('show');
    confirmCallback = onConfirm;
}

function closeConfirmModal(accept) {
    document.getElementById('confirm-modal').classList.remove('show');
    if (accept && confirmCallback) {
        confirmCallback();
    }
    confirmCallback = null;
}

// Rendering Helper functions
function getGroupBadgeClass(groupName) {
    const name = groupName ? groupName.toUpperCase() : "";
    if (name.includes("ADMIN")) {
        return "bg-blue-50 text-blue-700 border border-blue-200/50";
    } else if (name.includes("HR")) {
        return "bg-teal-50 text-teal-700 border border-teal-200/50";
    } else if (name.includes("MANAGER") || name.includes("QUẢN LÝ")) {
        return "bg-amber-50 text-amber-700 border border-amber-200/50";
    } else {
        return "bg-slate-50 text-slate-600 border border-slate-200/50";
    }
}

// Render dynamic roles list into grid
function renderRoles() {
    const container = document.getElementById('role-cards-container');
    container.innerHTML = '';

    if (filteredRoles.length === 0) {
        container.innerHTML = `
            <div class="col-span-full py-12 text-center text-slate-400 bg-white border border-slate-200 rounded-2xl">
                <i class="fa-solid fa-folder-open text-4xl mb-3"></i>
                <p class="text-sm font-semibold">Không tìm thấy vai trò phù hợp</p>
            </div>
        `;
        return;
    }

    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = Math.min(startIndex + itemsPerPage, filteredRoles.length);
    const pageItems = filteredRoles.slice(startIndex, endIndex);

    pageItems.forEach(role => {
        const card = document.createElement('div');
        card.id = `role-card-${role.id}`;
        card.className = `role-card bg-white rounded-2xl shadow-sm p-6 cursor-pointer relative overflow-hidden ${currentRoleId === role.id ? 'active-ring' : ''}`;
        card.setAttribute('onclick', `selectRoleCard(${role.id}, \`${role.name}\`, \`${role.description}\`)`);

        card.innerHTML = `
            <!-- Top Card Actions & Badges -->
            <div class="flex items-start justify-between mb-4">
                <div class="flex items-center gap-2">
                    <span class="px-2.5 py-1 text-xs font-bold rounded-lg ${getGroupBadgeClass(role.groupName)}">
                        ${role.groupName || 'Chưa phân nhóm'}
                    </span>
                    <span class="px-2 py-0.5 text-[10px] font-bold rounded-full ${role.isActive ? 'bg-green-50 text-green-700 border border-green-200/50' : 'bg-red-50 text-red-700 border border-red-200/50'}">
                        ${role.isActive ? 'Hoạt động' : 'Tắt'}
                    </span>
                </div>
                
                <!-- Status Toggle & Edit Buttons -->
                <div class="flex items-center gap-2" onclick="event.stopPropagation()">
                    <button onclick="openEditModal(${role.id})" title="Chỉnh sửa thông tin" class="w-8 h-8 rounded-lg bg-slate-50 hover:bg-indigo-50 hover:text-indigo-600 border border-slate-100 hover:border-indigo-100 transition-all flex items-center justify-center text-slate-500">
                        <i class="fa-solid fa-pen text-xs"></i>
                    </button>
                    
                    <label class="switch" title="Bật/Tắt vai trò">
                        <input type="checkbox" ${role.isActive ? 'checked' : ''} onchange="handleStatusToggle(${role.id}, this)">
                        <span class="slider"></span>
                    </label>
                </div>
            </div>

            <!-- Role Title -->
            <h3 class="text-lg font-bold text-slate-800 mb-2 truncate" title="${role.name}">
                ${role.name}
            </h3>
            
            <!-- Description -->
            <p class="text-sm text-slate-500 line-clamp-2 h-10 mb-4">
                ${role.description || 'Không có mô tả chi tiết về vai trò này.'}
            </p>

            <!-- Card Bottom Stats -->
            <div class="flex items-center justify-between border-t border-slate-100 pt-4 mt-2">
                <span class="text-xs text-slate-400 font-medium">
                    <i class="fa-solid fa-users mr-1"></i>
                    <b>${role.userCount}</b> nhân viên sở hữu
                </span>
                
                <span class="text-xs font-bold text-indigo-600 hover:text-indigo-700 transition flex items-center gap-1">
                    Thiết lập quyền <i class="fa-solid fa-chevron-right text-[10px]"></i>
                </span>
            </div>
        `;
        container.appendChild(card);
    });
}

// Render dynamic pagination controls
function renderPagination() {
    const totalPages = Math.ceil(filteredRoles.length / itemsPerPage);
    const btnContainer = document.getElementById('pagination-buttons');
    const infoText = document.getElementById('pagination-info');

    btnContainer.innerHTML = '';

    if (filteredRoles.length === 0) {
        infoText.innerHTML = 'Hiển thị <b>0 - 0</b> trên tổng số <b>0</b> vai trò';
        return;
    }

    const startIndex = (currentPage - 1) * itemsPerPage + 1;
    const endIndex = Math.min(startIndex + itemsPerPage - 1, filteredRoles.length);
    infoText.innerHTML = `Hiển thị <b>${startIndex} - ${endIndex}</b> trên tổng số <b>${filteredRoles.length}</b> vai trò`;

    if (totalPages <= 1) return;

    // Previous Button
    const prevBtn = document.createElement('button');
    prevBtn.className = 'pagination-btn';
    prevBtn.disabled = currentPage === 1;
    prevBtn.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
    prevBtn.onclick = () => {
        if (currentPage > 1) {
            currentPage--;
            renderRoles();
            renderPagination();
        }
    };
    btnContainer.appendChild(prevBtn);

    // Number Buttons
    for (let i = 1; i <= totalPages; i++) {
        const numBtn = document.createElement('button');
        numBtn.className = `pagination-btn ${currentPage === i ? 'active' : ''}`;
        numBtn.innerText = i;
        numBtn.onclick = () => {
            currentPage = i;
            renderRoles();
            renderPagination();
        };
        btnContainer.appendChild(numBtn);
    }

    // Next Button
    const nextBtn = document.createElement('button');
    nextBtn.className = 'pagination-btn';
    nextBtn.disabled = currentPage === totalPages;
    nextBtn.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
    nextBtn.onclick = () => {
        if (currentPage < totalPages) {
            currentPage++;
            renderRoles();
            renderPagination();
        }
    };
    btnContainer.appendChild(nextBtn);
}

// Filter, Search, and Sort functionality
function handleSearchFilter() {
    const searchVal = document.getElementById('search-roles').value.toLowerCase().trim();
    const groupVal = document.getElementById('filter-group').value;
    const statusVal = document.getElementById('filter-status').value;
    const sortVal = document.getElementById('sort-roles').value;

    filteredRoles = rolesData.filter(role => {
        const matchSearch = role.name.toLowerCase().includes(searchVal) || 
                            role.description.toLowerCase().includes(searchVal);
        const matchGroup = groupVal === "" || role.groupId == groupVal;
        const matchStatus = statusVal === "" || 
                            (statusVal === "active" && role.isActive) || 
                            (statusVal === "inactive" && !role.isActive);
        return matchSearch && matchGroup && matchStatus;
    });

    // Sắp xếp
    if (sortVal === "name-asc") {
        filteredRoles.sort((a, b) => a.name.localeCompare(b.name, 'vi'));
    } else if (sortVal === "name-desc") {
        filteredRoles.sort((a, b) => b.name.localeCompare(a.name, 'vi'));
    } else if (sortVal === "users-desc") {
        filteredRoles.sort((a, b) => b.userCount - a.userCount);
    } else if (sortVal === "users-asc") {
        filteredRoles.sort((a, b) => a.userCount - b.userCount);
    } else {
        filteredRoles.sort((a, b) => a.id - b.id);
    }

    currentPage = 1;
    renderRoles();
    renderPagination();
}

// Status Toggle Active/Deactivate Role API request
function handleStatusToggle(roleId, checkbox) {
    const isChecked = checkbox.checked;
    // Revert visual state until confirmed
    checkbox.checked = !isChecked;

    const role = rolesData.find(r => r.id === roleId);
    const actionText = isChecked ? "kích hoạt" : "vô hiệu hóa";
    
    confirmAction(
        "Thay đổi trạng thái vai trò",
        `Bạn có thực sự muốn ${actionText} vai trò "${role.name}" không?`,
        () => {
            fetch(contextPath + '/admin/api/roles/toggle-active', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ roleId: roleId, isActive: isChecked })
            })
            .then(res => {
                if (!res.ok) throw new Error("Máy chủ phản hồi lỗi.");
                return res.json();
            })
            .then(data => {
                if (data.status === 'success') {
                    role.isActive = isChecked;
                    checkbox.checked = isChecked; // Confirm change visually
                    showToast("success", `Đã ${actionText} vai trò thành công!`);
                    handleSearchFilter();
                } else {
                    showToast("error", data.error || "Không thể thực hiện.");
                }
            })
            .catch(err => {
                showToast("error", "Lỗi kết nối: " + err.message);
            });
        }
    );
}

// Edit/Create Modal Controls
function openEditModal(roleId) {
    const role = rolesData.find(r => r.id === roleId);
    if (!role) return;

    document.getElementById('modal-title').innerText = "Chỉnh sửa vai trò";
    document.getElementById('modal-role-id').value = role.id;
    document.getElementById('modal-role-name').value = role.name;
    document.getElementById('modal-role-group').value = role.groupId;
    document.getElementById('modal-role-desc').value = role.description;
    
    document.getElementById('role-modal').classList.add('show');
}

function openCreateModal() {
    document.getElementById('modal-title').innerText = "Thêm vai trò mới";
    document.getElementById('modal-role-id').value = "";
    document.getElementById('modal-role-name').value = "";
    document.getElementById('modal-role-group').selectedIndex = 0;
    document.getElementById('modal-role-desc').value = "";
    
    document.getElementById('role-modal').classList.add('show');
}

function closeRoleModal() {
    document.getElementById('role-modal').classList.remove('show');
}

// Submit Modal Form to REST API
function submitRoleForm(event) {
    event.preventDefault();
    const roleId = document.getElementById('modal-role-id').value;
    const name = document.getElementById('modal-role-name').value.trim();
    const groupId = document.getElementById('modal-role-group').value;
    const description = document.getElementById('modal-role-desc').value.trim();

    if (!name) {
        showToast("error", "Tên vai trò không được để trống!");
        return;
    }

    const payload = {
        roleId: roleId ? parseInt(roleId) : 0,
        name: name,
        groupId: parseInt(groupId),
        description: description
    };

    fetch(contextPath + '/admin/api/roles/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    })
    .then(res => {
        if (!res.ok) throw new Error("Máy chủ lỗi.");
        return res.json();
    })
    .then(data => {
        if (data.status === 'success') {
            showToast("success", data.message);
            closeRoleModal();
            // Refresh content after a short delay
            setTimeout(() => window.location.reload(), 1000);
        } else {
            showToast("error", data.error || "Thực thi thất bại.");
        }
    })
    .catch(err => {
        showToast("error", "Lỗi: " + err.message);
    });
}

// Selection handling of cards
function selectRoleCard(roleId, roleName, roleDesc) {
    // Re-highlight cards in UI
    document.querySelectorAll('.role-card').forEach(card => {
        card.classList.remove('active-ring');
    });
    
    const card = document.getElementById('role-card-' + roleId);
    if (card) {
        card.classList.add('active-ring');
    }

    selectRole(roleId, roleName, roleDesc);
}

// Read permissions matrix via Ajax
function selectRole(roleId, roleName, roleDesc) {
    currentRoleId = roleId;

    document.getElementById('matrix-title').innerText = "Ma trận phân quyền: " + roleName;
    document.getElementById('matrix-desc').innerText = roleDesc ? roleDesc : "Không có mô tả chi tiết cho vai trò này.";
    
    const container = document.getElementById('matrix-container');
    container.classList.remove('hidden');
    
    // Smooth scroll to matrix container
    setTimeout(() => {
        container.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }, 100);

    fetch(contextPath + '/admin/api/role-permissions?roleId=' + roleId)
        .then(response => {
            if (!response.ok) throw new Error('Lỗi kết nối máy chủ.');
            return response.json();
        })
        .then(data => {
            renderMatrixTable(data);
        })
        .catch(error => {
            showToast("error", "Không thể lấy cấu hình quyền: " + error.message);
        });
}

// Render the permission checkboxes matrix table
function renderMatrixTable(permissions) {
    const tbody = document.getElementById('matrix-body');
    tbody.innerHTML = '';

    permissions.forEach(perm => {
        const row = document.createElement('tr');
        row.className = "hover:bg-slate-50 transition border-b border-slate-100";
        row.setAttribute('data-module-id', perm.moduleId);

        row.innerHTML = `
            <td class="px-8 py-4 whitespace-nowrap text-sm font-semibold text-slate-800">${perm.moduleName}</td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none" onclick="toggleCheckboxInCell(this)">
                <input type="checkbox" class="custom-checkbox pointer-events-none" data-type="view" ${perm.view ? 'checked' : ''}>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none" onclick="toggleCheckboxInCell(this)">
                <input type="checkbox" class="custom-checkbox pointer-events-none" data-type="create" ${perm.create ? 'checked' : ''}>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none" onclick="toggleCheckboxInCell(this)">
                <input type="checkbox" class="custom-checkbox pointer-events-none" data-type="edit" ${perm.edit ? 'checked' : ''}>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none" onclick="toggleCheckboxInCell(this)">
                <input type="checkbox" class="custom-checkbox pointer-events-none" data-type="delete" ${perm.delete ? 'checked' : ''}>
            </td>
        `;
        tbody.appendChild(row);
    });
}

function toggleCheckboxInCell(cell) {
    const cb = cell.querySelector('input[type="checkbox"]');
    cb.checked = !cb.checked;
}

// Select/unselect all checkmarks inside matrix
function toggleAllMatrixCheckboxes(state) {
    const checkboxes = document.querySelectorAll('#matrix-body input[type="checkbox"]');
    checkboxes.forEach(cb => cb.checked = state);
}

function hideMatrixContainer() {
    document.getElementById('matrix-container').classList.add('hidden');
    currentRoleId = null;
    
    // Clear active ring
    document.querySelectorAll('.role-card').forEach(card => {
        card.classList.remove('active-ring');
    });
}

// Click save permissions button
document.getElementById('btn-save-permissions').addEventListener('click', function() {
    if (!currentRoleId) return;

    const rows = document.querySelectorAll('#matrix-body tr');
    const permissionList = [];

    rows.forEach(row => {
        const moduleId = parseInt(row.getAttribute('data-module-id'));
        const isView = row.querySelector('[data-type="view"]').checked;
        const isCreate = row.querySelector('[data-type="create"]').checked;
        const isEdit = row.querySelector('[data-type="edit"]').checked;
        const isDelete = row.querySelector('[data-type="delete"]').checked;

        permissionList.push({
            moduleId: moduleId,
            isView: isView,
            isCreate: isCreate,
            isEdit: isEdit,
            isDelete: isDelete
        });
    });

    const payload = {
        roleId: parseInt(currentRoleId),
        permissions: permissionList
    };

    fetch(contextPath + '/admin/api/role-permissions/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    })
    .then(response => {
        if (!response.ok) throw new Error('Sự cố khi lưu ma trận quyền.');
        return response.json();
    })
    .then(data => {
        if (data.status === "success") {
            showToast("success", "Cập nhật ma trận phân quyền thành công!");
        } else {
            showToast("error", data.error || "Ghi thất bại.");
        }
    })
    .catch(error => showToast("error", "Thất bại: " + error.message));
});

// Initialization
document.addEventListener("DOMContentLoaded", function() {
    handleSearchFilter(); // Triggers initial render
});