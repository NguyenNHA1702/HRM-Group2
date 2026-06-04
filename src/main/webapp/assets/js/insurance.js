// ── Modal helpers ──────────────────────────────────────────
function openModal(id)  { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }

document.querySelectorAll('.modal-overlay').forEach(m => {
    m.addEventListener('click', e => { if (e.target === m) m.style.display = 'none'; });
});

// ── Preview total in Add modal ─────────────────────────────
function previewNewTotal() {
    const emp  = parseFloat(document.getElementById('newEmpRate').value)  || 0;
    const emp2 = parseFloat(document.getElementById('newEmpRate2').value) || 0;
    document.getElementById('newTotalPreview').textContent = (emp + emp2).toFixed(1);
}

// ── Inline edit toggle ─────────────────────────────────────
function toggleEditRate(id) {
    // Show inputs, hide display spans, show save/cancel
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
    // Restore original display value from the span text
    const empOrig  = document.getElementById('emp-rate-'  + id).textContent.replace('%','').trim();
    const emp2Orig = document.getElementById('emp2-rate-' + id).textContent.replace('%','').trim();
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
    const emp  = parseFloat(document.getElementById('emp-input-'  + id).value) || 0;
    const emp2 = parseFloat(document.getElementById('emp2-input-' + id).value) || 0;
    document.getElementById('total-rate-' + id).textContent = (emp + emp2).toFixed(1) + '%';
}

function saveRate(id) {
    const emp  = parseFloat(document.getElementById('emp-input-'  + id).value);
    const emp2 = parseFloat(document.getElementById('emp2-input-' + id).value);

    if (isNaN(emp) || isNaN(emp2) || emp < 0 || emp2 < 0 || emp > 100 || emp2 > 100) {
        alert('Tỷ lệ phải là số từ 0 đến 100!');
        return;
    }

    // Update display spans
    document.getElementById('emp-rate-'  + id).textContent = emp.toFixed(1) + '%';
    document.getElementById('emp2-rate-' + id).textContent = emp2.toFixed(1) + '%';

    // Submit hidden form
    document.getElementById('updateRateId').value   = id;
    document.getElementById('updateEmpRate').value  = emp;
    document.getElementById('updateEmpRate2').value = emp2;
    document.getElementById('updateRateForm').submit();
}

// ── Toggle trạng thái loại bảo hiểm ───────────────────────
function confirmToggleRate(id, currentActive) {
    const newActive = !currentActive;
    const label     = newActive ? 'Đang áp dụng' : 'Đã dừng';
    if (!confirm('Bạn có chắc muốn đổi trạng thái thành "' + label + '"?')) return;
    document.getElementById('toggleRateId').value      = id;
    document.getElementById('toggleRateIsActive').value = newActive ? '1' : '0';
    document.getElementById('toggleRateForm').submit();
}

// ── Delete ─────────────────────────────────────────────────
function confirmDeleteRate(id, name) {
    if (confirm('Bạn có chắc muốn xóa loại bảo hiểm "' + name + '"?\nThao tác này không thể hoàn tác.')) {
        document.getElementById('deleteRateId').value = id;
        document.getElementById('deleteRateForm').submit();
    }
}