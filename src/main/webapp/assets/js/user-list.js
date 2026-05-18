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

/* Debounce search 600ms */
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
        const i = document.createElement('input');

        i.type = 'hidden';
        i.name = k;
        i.value = v;

        form.appendChild(i);
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

/* Flash auto hide after 4s */
setTimeout(() => {
    document.querySelectorAll('.flash').forEach(el => {
        el.style.transition = 'opacity .5s';
        el.style.opacity = '0';

        setTimeout(() => el.remove(), 500);
    });
}, 4000);