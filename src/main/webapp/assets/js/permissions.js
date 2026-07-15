let currentRoleId = null;
let editingRoleId = null;
let roles = [...initialRoles];

// Trạng thái tìm kiếm, sắp xếp, lọc, phân trang
let searchKeyword = '';
let statusFilter = 'all';
let sortBy = 'name-asc';
let currentPage = 1;
const pageSize = 4;

function getCheckIcon() {
    return `<svg class="w-5 h-5 text-green-600 mx-auto pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>`;
}

function getXIcon() {
    return `<svg class="w-5 h-5 text-red-400 mx-auto pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>`;
}

function renderRoles() {
    // 1. Lọc theo tên/mô tả và trạng thái
    let filtered = roles.filter(role => {
        const matchesSearch = role.name.toLowerCase().includes(searchKeyword.toLowerCase()) ||
                              (role.description && role.description.toLowerCase().includes(searchKeyword.toLowerCase()));
        const matchesStatus = statusFilter === 'all' ||
                              (statusFilter === 'active' && role.isActive) ||
                              (statusFilter === 'inactive' && !role.isActive);
        return matchesSearch && matchesStatus;
    });

    // 2. Sắp xếp danh sách
    filtered.sort((a, b) => {
        if (sortBy === 'name-asc') {
            return a.name.localeCompare(b.name);
        } else if (sortBy === 'name-desc') {
            return b.name.localeCompare(a.name);
        } else if (sortBy === 'users-desc') {
            return b.userCount - a.userCount;
        } else if (sortBy === 'users-asc') {
            return a.userCount - b.userCount;
        }
        return 0;
    });

    // 3. Phân trang
    const totalCount = filtered.length;
    const totalPages = Math.ceil(totalCount / pageSize);
    if (currentPage > totalPages) currentPage = Math.max(1, totalPages);
    
    const startIdx = (currentPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalCount);
    const pagedRoles = filtered.slice(startIdx, endIdx);

    // Cập nhật số liệu phân trang
    document.getElementById('page-total-count').innerText = totalCount;
    document.getElementById('page-start-idx').innerText = totalCount > 0 ? startIdx + 1 : 0;
    document.getElementById('page-end-idx').innerText = endIdx;

    // Render danh sách thẻ lên grid
    const grid = document.getElementById('roles-grid');
    grid.innerHTML = '';

    if (pagedRoles.length === 0) {
        grid.innerHTML = '<div class="col-span-full py-12 text-center text-gray-500 font-medium">Không tìm thấy vai trò nào phù hợp.</div>';
    } else {
        pagedRoles.forEach(role => {
            const card = document.createElement('div');
            card.id = `role-card-${role.id}`;
            card.className = `role-card bg-white rounded-lg shadow p-6 cursor-pointer transition hover:shadow-lg relative ${currentRoleId === role.id ? 'ring-2 ring-indigo-500' : ''}`;
            card.onclick = () => selectRole(role.id, role.name, role.description);
            
            const badgeClass = role.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
            const badgeText = role.isActive ? 'Hoạt động' : 'Tạm khóa';

            card.innerHTML = `
                <div class="flex items-start justify-between mb-3">
                  <div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
                    <svg class="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z">
                      </path>
                    </svg>
                  </div>
                  <div class="flex flex-col items-end gap-1.5">
                    <span class="px-2.5 py-0.5 bg-gray-100 text-gray-700 text-xs font-semibold rounded-full">
                      ${role.userCount} users
                    </span>
                    <span class="px-2.5 py-0.5 text-xs font-semibold rounded-full ${badgeClass}">
                      ${badgeText}
                    </span>
                  </div>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2 pr-8">${role.name}</h3>
                <p class="text-sm text-gray-600 line-clamp-2">${role.description || 'Chưa có mô tả.'}</p>
                
                <!-- Nút sửa thông tin chi tiết -->
                <button onclick="openEditModal(event, ${role.id})" class="absolute bottom-4 right-4 p-2 bg-gray-50 hover:bg-indigo-50 text-gray-600 hover:text-indigo-600 rounded-lg border border-gray-200 transition shadow-sm" title="Chỉnh sửa vai trò">
                  <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path>
                  </svg>
                </button>
            `;
            grid.appendChild(card);
        });
    }

    renderPagination(totalPages);
}

function renderPagination(totalPages) {
    const nav = document.getElementById('pagination-pages');
    nav.innerHTML = '';

    if (totalPages <= 1) {
        document.getElementById('pagination-container').classList.add('hidden');
        return;
    }
    document.getElementById('pagination-container').classList.remove('hidden');

    // Nút trước
    const prev = document.createElement('button');
    prev.disabled = currentPage === 1;
    prev.className = `relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 ${currentPage === 1 ? 'opacity-50 cursor-not-allowed' : ''}`;
    prev.onclick = () => { if (currentPage > 1) { currentPage--; renderRoles(); } };
    prev.innerHTML = `
        <span class="sr-only">Trước</span>
        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
        </svg>
    `;
    nav.appendChild(prev);

    // Danh sách trang số
    for (let i = 1; i <= totalPages; i++) {
        const pageBtn = document.createElement('button');
        const isActive = currentPage === i;
        pageBtn.className = `relative inline-flex items-center px-4 py-2 text-sm font-semibold ${isActive ? 'z-10 bg-indigo-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600' : 'text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0'}`;
        pageBtn.onclick = () => { currentPage = i; renderRoles(); };
        pageBtn.innerText = i;
        nav.appendChild(pageBtn);
    }

    // Nút sau
    const next = document.createElement('button');
    next.disabled = currentPage === totalPages;
    next.className = `relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0 ${currentPage === totalPages ? 'opacity-50 cursor-not-allowed' : ''}`;
    next.onclick = () => { if (currentPage < totalPages) { currentPage++; renderRoles(); } };
    next.innerHTML = `
        <span class="sr-only">Sau</span>
        <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
        </svg>
    `;
    nav.appendChild(next);

    // Mobile buttons bind
    document.getElementById('btn-prev-mobile').onclick = () => { if (currentPage > 1) { currentPage--; renderRoles(); } };
    document.getElementById('btn-next-mobile').onclick = () => { if (currentPage < totalPages) { currentPage++; renderRoles(); } };
    document.getElementById('btn-prev-mobile').disabled = currentPage === 1;
    document.getElementById('btn-next-mobile').disabled = currentPage === totalPages;
}

function openEditModal(event, roleId) {
    if (event) event.stopPropagation(); // Không cho sự kiện chọn card kích hoạt

    editingRoleId = roleId;
    const role = roles.find(r => r.id === roleId);
    if (!role) return;

    document.getElementById('modal-role-name').value = role.name;
    document.getElementById('modal-role-desc').value = role.description || '';
    document.getElementById('modal-role-status').value = String(role.isActive);

    // Khóa dropdown status nếu là Admin mặc định (ID = 1)
    const statusSelect = document.getElementById('modal-role-status');
    const warning = document.getElementById('modal-status-warning');
    if (roleId === 1) {
        statusSelect.disabled = true;
        warning.classList.remove('hidden');
    } else {
        statusSelect.disabled = false;
        warning.classList.add('hidden');
    }

    document.getElementById('edit-role-modal').classList.remove('hidden');
}

function closeEditModal() {
    document.getElementById('edit-role-modal').classList.add('hidden');
    editingRoleId = null;
}

function saveRoleDetails() {
    if (!editingRoleId) return;

    const name = document.getElementById('modal-role-name').value.trim();
    const description = document.getElementById('modal-role-desc').value.trim();
    const isActive = document.getElementById('modal-role-status').value === 'true';

    if (!name) {
        showToast('Tên vai trò không được để trống.', 'error');
        return;
    }

    const updatePayload = {
        roleId: editingRoleId,
        name: name,
        description: description
    };

    fetch(contextPath + '/admin/api/roles/update', {
        method: 'POST',
        headers: { 
            'Content-Type': 'application/json; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify(updatePayload)
    })
    .then(response => {
        if (response.status === 403) {
            return response.text().then(text => { throw new Error(text || 'Bạn không có quyền thực hiện hành động này.'); });
        }
        if (!response.ok) {
            return response.json().then(err => { throw new Error(err.error || 'Lỗi cập nhật chi tiết.') });
        }
        return response.json();
    })
    .then(data => {
        if (editingRoleId !== 1) {
            const togglePayload = {
                roleId: editingRoleId,
                isActive: isActive
            };
            return fetch(contextPath + '/admin/api/roles/toggle', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json; charset=UTF-8',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify(togglePayload)
            }).then(resp => {
                if (resp.status === 403) {
                    return resp.text().then(text => { throw new Error(text || 'Bạn không có quyền thực hiện hành động này.'); });
                }
                if (!resp.ok) {
                    return resp.json().then(err => { throw new Error(err.error || 'Lỗi cập nhật trạng thái.') });
                }
                return resp.json();
            });
        }
        return { status: 'success' };
    })
    .then(data => {
        showToast('🎉 Lưu thay đổi vai trò thành công!', 'success');
        
        // Cập nhật mảng cục bộ
        const role = roles.find(r => r.id === editingRoleId);
        if (role) {
            role.name = name;
            role.description = description;
            role.isActive = isActive;
        }

        renderRoles();
        closeEditModal();

        // Đồng bộ lại tiêu đề ma trận nếu đang mở vai trò này
        if (currentRoleId === editingRoleId) {
            document.getElementById('matrix-title').innerText = "Ma trận phân quyền: " + name;
            document.getElementById('matrix-desc').innerText = description || "Không có mô tả chi tiết.";
        }
    })
    .catch(error => {
        showToast('❌ Thất bại: ' + error.message, 'error');
    });
}

function showToast(message, type = 'success') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `flex items-center w-full max-w-xs p-4 mb-4 text-gray-500 bg-white rounded-lg shadow pointer-events-auto transition duration-300 transform translate-x-10 opacity-0`;
    
    const iconColor = type === 'success' ? 'text-green-500 bg-green-100' : 'text-red-500 bg-red-100';
    const iconSvg = type === 'success' 
        ? `<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>`
        : `<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/></svg>`;

    toast.innerHTML = `
        <div class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 ${iconColor} rounded-lg">
            ${iconSvg}
        </div>
        <div class="ml-3 text-sm font-normal text-gray-900">${message}</div>
        <button type="button" class="ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8" onclick="this.parentElement.remove()">
            <span class="sr-only">Đóng</span>
            <svg class="w-3 h-3" fill="none" viewBox="0 0 14 14"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/></svg>
        </button>
    `;
    
    container.appendChild(toast);
    
    // Tạo hiệu ứng trượt vào
    setTimeout(() => {
        toast.classList.remove('translate-x-10', 'opacity-0');
        toast.classList.add('translate-x-0', 'opacity-100');
    }, 10);
    
    // Tự động biến mất
    setTimeout(() => {
        toast.classList.remove('translate-x-0', 'opacity-100');
        toast.classList.add('translate-x-10', 'opacity-0');
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

function selectRole(roleId, roleName, roleDesc) {
    currentRoleId = roleId;

    document.querySelectorAll('.role-card').forEach(card => {
        card.classList.remove('ring-2', 'ring-indigo-500');
    });

    const activeCard = document.getElementById('role-card-' + roleId);
    if(activeCard) {
        activeCard.classList.add('ring-2', 'ring-indigo-500');
    }

    document.getElementById('matrix-title').innerText = "Ma trận phân quyền: " + roleName;
    document.getElementById('matrix-desc').innerText = roleDesc ? roleDesc : "Không có mô tả chi tiết.";
    document.getElementById('matrix-container').classList.remove('hidden');

    // Ẩn/Hiện/Vô hiệu hóa nút Lưu thay đổi nếu là Admin
    const saveBtn = document.getElementById('btn-save-permissions');
    if (roleId === 1) {
        saveBtn.disabled = true;
        saveBtn.classList.add('opacity-50', 'cursor-not-allowed');
        saveBtn.title = "Không thể chỉnh sửa quyền của Admin";
    } else {
        saveBtn.disabled = false;
        saveBtn.classList.remove('opacity-50', 'cursor-not-allowed');
        saveBtn.title = "";
    }

    fetch(contextPath + '/admin/api/role-permissions?roleId=' + roleId)
        .then(response => {
            if (!response.ok) throw new Error('Lỗi kết nối hệ thống.');
            return response.json();
        })
        .then(data => {
            renderMatrixTable(data);
        })
        .catch(error => console.error('Error:', error));
}

function renderMatrixTable(permissions) {
    const tbody = document.getElementById('matrix-body');
    tbody.innerHTML = '';

    permissions.forEach(perm => {
        const row = document.createElement('tr');
        row.className = "hover:bg-gray-50 transition";
        row.setAttribute('data-module-id', perm.moduleId);

        // Nếu là Admin (roleId = 1), ép buộc hiển thị toàn bộ tích xanh (true)
        const displayView = currentRoleId === 1 ? true : perm.view;
        const displayCreate = currentRoleId === 1 ? true : perm.create;
        const displayEdit = currentRoleId === 1 ? true : perm.edit;
        const displayDelete = currentRoleId === 1 ? true : perm.delete;

        row.innerHTML = `
            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">${perm.moduleName}</td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="view" data-value="${displayView}">
                ${displayView ? getCheckIcon() : getXIcon()}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="create" data-value="${displayCreate}">
                ${displayCreate ? getCheckIcon() : getXIcon()}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="edit" data-value="${displayEdit}">
                ${displayEdit ? getCheckIcon() : getXIcon()}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="delete" data-value="${displayDelete}">
                ${displayDelete ? getCheckIcon() : getXIcon()}
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Lắng nghe click để đổi trạng thái tích xanh/đỏ mượt mà
document.getElementById('matrix-body').addEventListener('click', function(e) {
    // Nếu là Admin mặc định (roleId = 1), không cho phép chỉnh sửa quyền
    if (currentRoleId === 1) {
        showToast('⚠️ Đây là vai trò Admin hệ thống, toàn bộ quyền luôn được mở mặc định và không thể sửa đổi.', 'error');
        return;
    }

    const cell = e.target.closest('.perm-cell');
    if (!cell) return;

    let currentValue = cell.getAttribute('data-value') === 'true';
    let newValue = !currentValue;

    cell.setAttribute('data-value', newValue);
    cell.innerHTML = newValue ? getCheckIcon() : getXIcon();
});

// Sự kiện bấm nút Lưu thay đổi đẩy gói tin JSON về Server
document.getElementById('btn-save-permissions').addEventListener('click', function() {
    if (!currentRoleId) return;

    const rows = document.querySelectorAll('#matrix-body tr');
    const permissionList = [];

    rows.forEach(row => {
        const moduleId = parseInt(row.getAttribute('data-module-id'));
        const isView = row.querySelector('[data-type="view"]').getAttribute('data-value') === 'true';
        const isCreate = row.querySelector('[data-type="create"]').getAttribute('data-value') === 'true';
        const isEdit = row.querySelector('[data-type="edit"]').getAttribute('data-value') === 'true';
        const isDelete = row.querySelector('[data-type="delete"]').getAttribute('data-value') === 'true';

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
        headers: { 
            'Content-Type': 'application/json; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify(payload)
    })
        .then(response => {
            if (response.status === 403) {
                return response.text().then(text => { throw new Error(text || 'Bạn không có quyền lưu ma trận phân quyền.'); });
            }
            if (!response.ok) throw new Error('Sự cố lưu dữ liệu.');
            return response.json();
        })
        .then(data => {
            showToast('🎉 Cập nhật ma trận phân quyền thành công!', 'success');
        })
        .catch(error => showToast('❌ Thất bại: ' + error.message, 'error'));
});

document.addEventListener("DOMContentLoaded", function() {
    // Đăng ký sự kiện lọc tìm kiếm, trạng thái, sắp xếp
    document.getElementById('role-search-input').addEventListener('input', (e) => {
        searchKeyword = e.target.value;
        currentPage = 1;
        renderRoles();
    });

    document.getElementById('role-status-filter').addEventListener('change', (e) => {
        statusFilter = e.target.value;
        currentPage = 1;
        renderRoles();
    });

    document.getElementById('role-sort-by').addEventListener('change', (e) => {
        sortBy = e.target.value;
        currentPage = 1;
        renderRoles();
    });

    // Khởi chạy render vai trò
    renderRoles();

    // Chọn vai trò đầu tiên nếu có
    if (roles.length > 0) {
        selectRole(roles[0].id, roles[0].name, roles[0].description);
    }
});