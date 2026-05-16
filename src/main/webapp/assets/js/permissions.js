let currentRoleId = null;

function getCheckIcon() {
    return `<svg class="w-5 h-5 text-green-600 mx-auto pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>`;
}

function getXIcon() {
    return `<svg class="w-5 h-5 text-red-400 mx-auto pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>`;
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

        // Giữ nguyên các class Tailwind px-6 py-4 giống hệt bản cứng của bạn
        row.innerHTML = `
            <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">${perm.moduleName}</td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="view" data-value="${perm.view}">
                ${perm.view ? getCheckIcon() : getXIcon()}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="create" data-value="${perm.create}">
                ${perm.create ? getCheckIcon() : getXIcon()}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="edit" data-value="${perm.edit}">
                ${perm.edit ? getCheckIcon() : getXIcon()}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-center perm-cell cursor-pointer select-none hover:bg-indigo-50 transition" data-type="delete" data-value="${perm.delete}">
                ${perm.delete ? getCheckIcon() : getXIcon()}
            </td>
        `;
        tbody.appendChild(row);
    });
}

// Lắng nghe click để đổi trạng thái tích xanh/đỏ mượt mà
document.getElementById('matrix-body').addEventListener('click', function(e) {
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
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    })
        .then(response => {
            if (!response.ok) throw new Error('Sự cố lưu dữ liệu.');
            return response.json();
        })
        .then(data => {
            alert('🎉 Cập nhật ma trận phân quyền thành công!');
        })
        .catch(error => alert('❌ Thất bại: ' + error.message));
});

document.addEventListener("DOMContentLoaded", function() {
    const firstCard = document.querySelector('.role-card');
    if (firstCard) {
        const id = firstCard.getAttribute('data-role-id');
        const name = firstCard.getAttribute('data-role-name');
        const desc = firstCard.getAttribute('data-role-desc');
        selectRole(id, name, desc);
    }
});