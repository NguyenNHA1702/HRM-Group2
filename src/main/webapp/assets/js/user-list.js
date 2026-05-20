function openModal(id) {
    const el = document.getElementById(id);

    if (el) {
        el.classList.add('open');
    }
}

function closeModal(id) {
    const el = document.getElementById(id);

    if (el) {
        el.classList.remove('open');
    }
}

/* Close modal when click outside */
document.querySelectorAll('.modal-overlay').forEach(ov => {
    ov.addEventListener('click', e => {
        if (e.target === ov) {
            closeModal(ov.id);
        }
    });
});

/* ESC close modal */
document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal-overlay.open')
            .forEach(m => closeModal(m.id));
    }
});

/* Auto submit filter */
document.querySelectorAll('.filter-auto').forEach(sel => {
    sel.addEventListener('change', () => {
        const f = document.getElementById('filterForm');

        if (f) {
            f.submit();
        }
    });
});

/* Debounce search */
(function () {
    const inp = document.getElementById('searchInput');

    if (!inp) return;

    let t;

    inp.addEventListener('input', () => {
        clearTimeout(t);

        t = setTimeout(() => {
            const f = document.getElementById('filterForm');

            if (f) {
                f.submit();
            }
        }, 600);
    });
})();

/* User actions */
const ACTION_URL = window.actionUrl || '';

function _post(params) {
    const form = document.createElement('form');

    form.method = 'POST';
    form.action = ACTION_URL;

    Object.entries(params).forEach(([k, v]) => {
        const input = document.createElement('input');

        input.type = 'hidden';
        input.name = k;
        input.value = v;

        form.appendChild(input);
    });

    document.body.appendChild(form);
    form.submit();
}

function lockUser(id) {
    if (confirm('Khóa tài khoản này?')) {
        _post({
            action: 'lock',
            userId: id
        });
    }
}

function unlockUser(id) {
    if (confirm('Mở khóa tài khoản này?')) {
        _post({
            action: 'unlock',
            userId: id
        });
    }
}

function resetPassword(id) {
    if (confirm('Yêu cầu đổi mật khẩu lần đăng nhập tiếp?')) {
        _post({
            action: 'resetPassword',
            userId: id
        });
    }
}

function confirmDelete(id, name) {
    if (confirm('Xóa tài khoản "' + name + '"?\nHành động không thể hoàn tác!')) {
        document.getElementById('deleteUserId').value = id;
        document.getElementById('deleteForm').submit();
    }
}

function viewUser(id) {
    const contextPath = window.contextPath || '';
    fetch(contextPath + '/admin/api/user/detail?id=' + id)
        .then(response => {
            if (!response.ok) {
                throw new Error('Không thể tải thông tin chi tiết tài khoản.');
            }
            return response.json();
        })
        .then(data => {
            // Fill details in Modal
            document.getElementById('view_fullName').innerText = data.fullName || 'N/A';
            document.getElementById('view_employeeCode').innerText = data.employeeCode || 'N/A';
            document.getElementById('view_workEmail').innerText = data.workEmail || 'N/A';
            document.getElementById('view_personalEmail').innerText = data.personalEmail || 'N/A';
            document.getElementById('view_phone').innerText = data.phone || 'N/A';
            document.getElementById('view_dateOfBirth').innerText = data.dateOfBirth || 'N/A';
            document.getElementById('view_gender').innerText = data.gender || 'N/A';
            document.getElementById('view_department').innerText = data.departmentName || 'N/A';
            document.getElementById('view_position').innerText = data.positionName || 'N/A';
            document.getElementById('view_role').innerText = data.roleName || 'N/A';

            // Status label mapping
            const statusEl = document.getElementById('view_status');
            if (data.isActive) {
                statusEl.innerText = 'Đang hoạt động (ACTIVE)';
                statusEl.className = 'status-active';
            } else {
                statusEl.innerText = 'Đã khóa (INACTIVE)';
                statusEl.className = 'status-inactive';
            }

            // Avatar display logic
            const avatarImg = document.getElementById('view_avatar');
            const avatarPlaceholder = document.getElementById('view_avatar_placeholder');
            if (data.avatarUrl) {
                avatarImg.src = data.avatarUrl;
                avatarImg.style.display = 'block';
                avatarPlaceholder.style.display = 'none';
            } else {
                avatarImg.style.display = 'none';
                avatarPlaceholder.style.display = 'flex';
            }

            openModal('viewUserModal');
        })
        .catch(err => {
            alert(err.message);
        });
}

/* Flash auto hide */
setTimeout(() => {
    document.querySelectorAll('.flash').forEach(el => {
        el.style.transition = 'opacity .5s';
        el.style.opacity = '0';

        setTimeout(() => el.remove(), 500);
    });
}, 4000);