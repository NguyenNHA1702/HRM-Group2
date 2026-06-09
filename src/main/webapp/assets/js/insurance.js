// ══════════════════════════════════════════════════════════
// Modal helpers
// ══════════════════════════════════════════════════════════
function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }

document.querySelectorAll('.modal-overlay').forEach(function(m) {
    m.addEventListener('click', function(e) {
        if (e.target === m) m.classList.remove('open');
    });
});

// ══════════════════════════════════════════════════════════
// Insurance Rate — Preview tổng trong modal Thêm
// ══════════════════════════════════════════════════════════
function previewNewTotal() {
    var emp  = parseFloat(document.getElementById('newEmpRate').value)  || 0;
    var emp2 = parseFloat(document.getElementById('newEmpRate2').value) || 0;
    document.getElementById('newTotalPreview').textContent = (emp + emp2).toFixed(1);
}

// ══════════════════════════════════════════════════════════
// Insurance Rate — Inline edit toggle
// ══════════════════════════════════════════════════════════
function toggleEditRate(id) {
    document.getElementById('emp-rate-'   + id).style.display = 'none';
    document.getElementById('emp2-rate-'  + id).style.display = 'none';
    document.getElementById('emp-input-'  + id).style.display = 'inline-block';
    document.getElementById('emp2-input-' + id).style.display = 'inline-block';
    document.getElementById('edit-btn-'   + id).style.display = 'none';
    document.getElementById('save-btn-'   + id).style.display = 'inline-flex';
    document.getElementById('cancel-btn-' + id).style.display = 'inline-flex';
    document.getElementById('emp-input-'  + id).focus();
}

function cancelEditRate(id) {
    var empOrig  = document.getElementById('emp-rate-'  + id).textContent.replace('%','').trim();
    var emp2Orig = document.getElementById('emp2-rate-' + id).textContent.replace('%','').trim();
    document.getElementById('emp-input-'  + id).value = empOrig;
    document.getElementById('emp2-input-' + id).value = emp2Orig;
    restoreDisplayMode(id);
}

function restoreDisplayMode(id) {
    document.getElementById('emp-rate-'   + id).style.display = 'inline-block';
    document.getElementById('emp2-rate-'  + id).style.display = 'inline-block';
    document.getElementById('emp-input-'  + id).style.display = 'none';
    document.getElementById('emp2-input-' + id).style.display = 'none';
    document.getElementById('edit-btn-'   + id).style.display = 'inline-flex';
    document.getElementById('save-btn-'   + id).style.display = 'none';
    document.getElementById('cancel-btn-' + id).style.display = 'none';
}

function updateTotal(id) {
    var emp  = parseFloat(document.getElementById('emp-input-'  + id).value) || 0;
    var emp2 = parseFloat(document.getElementById('emp2-input-' + id).value) || 0;
    document.getElementById('total-rate-' + id).textContent = (emp + emp2).toFixed(1) + '%';
}

function saveRate(id) {
    var emp  = parseFloat(document.getElementById('emp-input-'  + id).value);
    var emp2 = parseFloat(document.getElementById('emp2-input-' + id).value);

    if (isNaN(emp) || isNaN(emp2) || emp < 0 || emp2 < 0 || emp > 100 || emp2 > 100) {
        alert('Tỷ lệ phải là số từ 0 đến 100!');
        return;
    }

    document.getElementById('emp-rate-'  + id).textContent = emp.toFixed(1) + '%';
    document.getElementById('emp2-rate-' + id).textContent = emp2.toFixed(1) + '%';

    document.getElementById('updateRateId').value   = id;
    document.getElementById('updateEmpRate').value  = emp;
    document.getElementById('updateEmpRate2').value = emp2;
    document.getElementById('updateRateForm').submit();
}

// ══════════════════════════════════════════════════════════
// Insurance Rate — Toggle trạng thái
// ══════════════════════════════════════════════════════════
function confirmToggleRate(id, currentActive) {
    var newActive = !currentActive;
    var label     = newActive ? 'Đang áp dụng' : 'Đã dừng';
    if (!confirm('Bạn có chắc muốn đổi trạng thái thành "' + label + '"?')) return;
    document.getElementById('toggleRateId').value       = id;
    document.getElementById('toggleRateIsActive').value = newActive ? '1' : '0';
    document.getElementById('toggleRateForm').submit();
}

// ══════════════════════════════════════════════════════════
// Insurance Rate — Xóa
// ══════════════════════════════════════════════════════════
function confirmDeleteRate(btn) {
    var id   = btn.getAttribute('data-id');
    var name = btn.getAttribute('data-name');
    if (confirm('Bạn có chắc muốn xóa loại bảo hiểm "' + name + '"?\nThao tác này không thể hoàn tác.')) {
        document.getElementById('deleteRateId').value = id;
        document.getElementById('deleteRateForm').submit();
    }
}

// ══════════════════════════════════════════════════════════
// Applicable Group — Mở modal chỉnh sửa và điền dữ liệu
// ══════════════════════════════════════════════════════════
function openEditGroup(btn) {
    // Lấy dữ liệu từ data attributes của button
    var id        = btn.getAttribute('data-id');
    var name      = btn.getAttribute('data-name');
    var desc      = btn.getAttribute('data-desc') || '';
    var cond      = btn.getAttribute('data-cond') || '';
    var sort      = btn.getAttribute('data-sort') || '0';
    var isActive  = btn.getAttribute('data-active') === 'true' ? '1' : '0';

    // Điền dữ liệu vào các field của modal edit
    document.getElementById('editGroupId').value        = id;
    document.getElementById('editGroupName').value      = name;
    document.getElementById('editGroupDesc').value      = desc;
    document.getElementById('editGroupCondition').value = cond;
    document.getElementById('editGroupSort').value      = sort;

    // Set select value và đảm bảo option đúng được chọn
    var selectEl = document.getElementById('editGroupActive');
    selectEl.value = isActive;
    // Fallback: duyệt từng option để chắc chắn
    for (var i = 0; i < selectEl.options.length; i++) {
        selectEl.options[i].selected = (selectEl.options[i].value === isActive);
    }

    // Mở modal
    openModal('editGroupModal');
}

// ══════════════════════════════════════════════════════════
// Applicable Group — Toggle trạng thái
// ══════════════════════════════════════════════════════════
function confirmToggleGroup(id, currentActive) {
    var newActive = !currentActive;
    var label     = newActive ? 'Đang áp dụng' : 'Đã dừng';

    if (!confirm('Bạn có chắc muốn đổi trạng thái nhóm đối tượng này thành "' + label + '"?')) {
        return;
    }

    // Điền dữ liệu vào form ẩn
    var toggleForm = document.getElementById('toggleGroupForm');
    if (toggleForm) {
        document.getElementById('toggleGroupId').value       = id;
        document.getElementById('toggleGroupIsActive').value = newActive ? '1' : '0';

        // Submit form
        toggleForm.submit();
    } else {
        alert('Lỗi: Không tìm thấy form. Vui lòng tải lại trang.');
    }
}

// ══════════════════════════════════════════════════════════
// Applicable Group — Xóa
// ══════════════════════════════════════════════════════════
function confirmDeleteGroup(btn) {
    var id   = btn.getAttribute('data-id');
    var name = btn.getAttribute('data-name');

    if (!confirm('Bạn có chắc muốn xóa nhóm đối tượng "' + name + '"?\nThao tác này không thể hoàn tác.')) {
        return;
    }

    // Điền dữ liệu vào form ẩn
    var deleteForm = document.getElementById('deleteGroupForm');
    if (deleteForm) {
        document.getElementById('deleteGroupId').value = id;

        // Submit form
        deleteForm.submit();
    } else {
        alert('Lỗi: Không tìm thấy form. Vui lòng tải lại trang.');
    }
}