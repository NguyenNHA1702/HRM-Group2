/* ============================================================
   attendance.js  –  HRM Attendance Calendar (Employee View)
   ============================================================ */

'use strict';

/* ── Constants ── */
const WEEKDAYS = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
const STATUS_LABEL = { present: 'Đủ công', late: 'Đi muộn', absent: 'Vắng mặt', leave: 'Nghỉ phép' };
const STATUS_ICON = { present: '✓', late: '⚠', absent: '✕', leave: '◷' };

/* ── Global state – written by JSP inline script, read after DOMContentLoaded ── */
window._attendanceBootData = window._attendanceBootData || null;

let currentMonth, currentYear;
let attendanceData = [];
let explanationStatusMap = {};
let explanationDetailsMap = {};
let isAttendanceLocked = false;
let activeFilter = 'all';
let overtimesData = [];
let isHrRole = false;
let currentViewEmployeeId = null;

/* ── Boot: wait for DOM then init ── */
document.addEventListener('DOMContentLoaded', function () {
    if (window._attendanceBootData) {
        const d = window._attendanceBootData;
        _boot(d.month, d.year, d.data, d.expMap, d.locked, d.expDetailsMap, d.otData, d.isHr, d.empId);
    }

    /* Modal backdrop / keyboard close */
    const modal = document.getElementById('editModal');
    if (modal) {
        modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(); });
    }
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeModal(); });
});

/* Called by window._attendanceBootData setter or DOMContentLoaded, whichever is later */
function _boot(month, year, data, expMap, locked, expDetailsMap, otData, isHr, empId) {
    currentMonth = month;
    currentYear = year;
    attendanceData = data || [];
    explanationStatusMap = expMap || {};
    explanationDetailsMap = expDetailsMap || {};
    isAttendanceLocked = locked === true || locked === 'true';
    activeFilter = 'all';
    overtimesData = otData || [];
    isHrRole = isHr === true || isHr === 'true';
    currentViewEmployeeId = empId;

    renderStats();
    renderFilterChips();
    renderCalendar();
}

/* Public init – called from JSP inline script */
function initCalendar(month, year, data, expMap, locked, expDetailsMap, otData, isHr, empId) {
    window._attendanceBootData = { month: month, year: year, data: data, expMap: expMap || {}, locked: locked, expDetailsMap: expDetailsMap || {}, otData: otData, isHr: isHr, empId: empId };
    /* If DOM already ready (e.g. script deferred), boot immediately */
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        _boot(month, year, data, expMap, locked, expDetailsMap, otData, isHr, empId);
    }
    /* Otherwise DOMContentLoaded listener above will call _boot */
}

/* ────────────────────────────────────────────
   Stats strip
──────────────────────────────────────────── */
function renderStats() {
    var strip = document.getElementById('stats-strip');
    if (!strip) return;

    var present = 0, late = 0, absent = 0, leave = 0, otMinutes = 0;
    attendanceData.forEach(function (a) {
        if (a.status === 'present') present++;
        else if (a.status === 'late') late++;
        else if (a.status === 'absent') absent++;
        else if (a.status === 'leave') leave++;

        if (a.checkOut && a.checkOut !== '--:--') {
            var parts = a.checkOut.split(':');
            var endMin = parseInt(parts[0]) * 60 + parseInt(parts[1]);
            if (endMin > 17 * 60 + 30) otMinutes += endMin - (17 * 60 + 30);
        }
    });

    var otHours = (otMinutes / 60).toFixed(1);
    var workingDays = countWorkingDays(currentYear, currentMonth);

    strip.innerHTML =
        statCard('present', statIcon('present'), 'Ngày công', present
            + ' <span class="stat-total">/ ' + workingDays + '</span>', 'ngày có mặt') +
        statCard('late', statIcon('late'), 'Đi muộn', late, 'lần trong tháng') +
        statCard('absent', statIcon('absent'), 'Vắng mặt', absent, 'ngày không lý do') +
        statCard('leave', statIcon('leave'), 'Nghỉ phép', leave, 'ngày đã duyệt') +
        statCard('ot', statIcon('ot'), 'Tăng ca (OT)', otHours + 'h', 'tổng giờ tháng này');
}

function statCard(type, icon, label, value, sub) {
    return '<div class="stat-card">' +
        '<div>' +
        '<div class="stat-label">' + label + '</div>' +
        '<div class="stat-value">' + value + '</div>' +
        '<div class="stat-sub">' + sub + '</div>' +
        '</div><div class="stat-icon ' + type + '">' + icon + '</div>' +
        '</div>';
}

function statIcon(type) {
    var icons = {
        present: '<svg viewBox="0 0 24 24"><rect x="5" y="4" width="14" height="17" rx="2"></rect><path d="M9 4V2h6v2M8 9h8M8 13h8M8 17h5"></path></svg>',
        late: '<svg viewBox="0 0 24 24"><circle cx="12" cy="13" r="8"></circle><path d="M12 9v5l3 2M9 2h6M12 5V2"></path></svg>',
        absent: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"></circle><path d="M6 6l12 12"></path></svg>',
        leave: '<svg viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"></rect><path d="M16 3v4M8 3v4M3 10h18M8 15l2 2 5-5"></path></svg>',
        ot: '<svg viewBox="0 0 24 24"><path d="M13 2L5 14h7l-1 8 8-12h-7l1-8z"></path></svg>'
    };
    return icons[type] || '';
}

function countWorkingDays(year, month) {
    var days = new Date(year, month, 0).getDate();
    var count = 0;
    for (var d = 1; d <= days; d++) {
        var dow = new Date(year, month - 1, d).getDay();
        if (dow !== 0 && dow !== 6) count++;
    }
    return count;
}

/* ────────────────────────────────────────────
   Filter chips
──────────────────────────────────────────── */
function renderFilterChips() {
    var container = document.getElementById('filter-chips');
    if (!container) return;

    var filters = [
        { key: 'all', label: 'Tất cả', cls: '' },
        { key: 'present', label: 'Đủ công', cls: 'chip-present' },
        { key: 'late', label: 'Đi muộn', cls: 'chip-late' },
        { key: 'absent', label: 'Vắng mặt', cls: 'chip-absent' },
        { key: 'leave', label: 'Nghỉ phép', cls: 'chip-leave' },
    ];

    container.innerHTML = filters.map(function (f) {
        var active = activeFilter === f.key ? ' active' : '';
        return '<button class="chip ' + f.cls + active + '" onclick="setFilter(\'' + f.key + '\')">' + f.label + '</button>';
    }).join('');
}

function setFilter(key) {
    activeFilter = key;
    renderFilterChips();
    renderCalendar();
}

/* ────────────────────────────────────────────
   Calendar grid
──────────────────────────────────────────── */
function renderCalendar() {
    var grid = document.getElementById('calendar-grid');
    if (!grid) return;
    grid.innerHTML = '';

    var title = document.getElementById('calendar-title');
    if (title) title.textContent = 'Tháng ' + currentMonth + ' / ' + currentYear;

    var daysInMonth = new Date(currentYear, currentMonth, 0).getDate();
    var firstDay = new Date(currentYear, currentMonth - 1, 1).getDay();
    var today = new Date();
    var todayStr = toDateStr(today.getFullYear(), today.getMonth() + 1, today.getDate());

    /* Weekday header row */
    WEEKDAYS.forEach(function (d, i) {
        var el = document.createElement('div');
        el.className = 'cal-weekday' + (i === 0 || i === 6 ? ' weekend' : '');
        el.textContent = d;
        grid.appendChild(el);
    });

    /* Empty lead cells */
    for (var i = 0; i < firstDay; i++) {
        var empty = document.createElement('div');
        empty.className = 'calendar-day empty';
        grid.appendChild(empty);
    }

    /* Day cells */
    for (var day = 1; day <= daysInMonth; day++) {
        var dateStr = toDateStr(currentYear, currentMonth, day);
        var dow = new Date(currentYear, currentMonth - 1, day).getDay();
        var isWeekend = (dow === 0 || dow === 6);
        var isToday = (dateStr === todayStr);
        var isFuture = (dateStr > todayStr);
        var att = attendanceData.find(function (a) { return a.date === dateStr; }) || null;

        var matchesFilter = activeFilter === 'all'
            || (att && att.status === activeFilter)
            || (activeFilter === 'absent' && !att && !isWeekend && !isFuture);

        var cls = 'calendar-day';
        if (isWeekend) cls += ' weekend-day';
        else if (att) { cls += ' status-' + att.status; if (!matchesFilter) cls += ' chip-dimmed'; }
        else if (isFuture) cls += ' future-day';
        if (isToday) cls += ' today';

        var otForDay = overtimesData.find(function (o) { return o.overtimeDate === dateStr; });

        var el = document.createElement('div');
        el.className = cls;
        el.setAttribute('data-date', dateStr);
        el.innerHTML = buildDayHTML(day, att, isWeekend, isFuture, otForDay);

        if (!isWeekend || isHrRole || att || otForDay) {
            (function (ds, a, future, dn, ot) {
                el.onclick = function () { openModal(ds, a, future, dn, ot); };
            })(dateStr, att, isFuture, day, otForDay);
        }

        grid.appendChild(el);
    }
}

function buildDayHTML(day, att, isWeekend, isFuture, ot) {
    var numEl = '<div class="day-num">' + day + '</div>';
    var dateStr = toDateStr(currentYear, currentMonth, day);
    var expStatus = explanationStatusMap[dateStr] || null;
    var expBadge = '';

    if (expStatus) {
        if (expStatus === 'PENDING') {
            expBadge = '<div class="exp-badge pending">⏳ Chờ duyệt</div>';
        } else if (expStatus === 'APPROVED') {
            expBadge = '<div class="exp-badge approved">✓ Đã duyệt</div>';
        } else if (expStatus === 'REJECTED') {
            expBadge = '<div class="exp-badge rejected">✕ Từ chối</div>';
        }
    }

    if (att) {
        var lateMin = calcLateMinutes(att.checkIn);
        var lateNote = (att.status === 'late' && lateMin > 0)
            ? '<div class="late-min">Muộn ' + lateMin + 'p</div>' : '';

        var timeEl = (att.checkIn && att.checkIn !== '--:--')
            ? '<div class="day-time">▶ ' + att.checkIn + '<br>◀ ' + (att.checkOut || '--:--') + '</div>'
            : '';

        var badge = '<div class="day-badge ' + att.status + '">'
            + (STATUS_ICON[att.status] || '') + ' '
            + (STATUS_LABEL[att.status] || att.status)
            + '</div>';

        var otBadge = getOtBadgeHTML(ot);

        return numEl + expBadge + lateNote + timeEl + badge + otBadge;
    }

    if (isWeekend) return numEl + expBadge;

    var otBadge = getOtBadgeHTML(ot);

    if (isFuture) {
        return numEl + expBadge + otBadge + '<div class="day-time" style="color:var(--clr-muted);font-size:.65rem">—</div>';
    }

    var absentBadge = '<div class="day-badge absent">✕ Chưa có</div>';
    return numEl + expBadge + absentBadge + otBadge;
}

function getOtBadgeHTML(ot) {
    if (!ot) return '';
    var label = 'OT';
    var bg = '#4f46e5'; // Weekday (Blue)
    var color = '#fff';

    if (ot.overtimeType === 'HOLIDAY') {
        label = 'OT Lễ';
        bg = '#e11d48'; // Holiday (Red)
    } else if (ot.overtimeType === 'WEEKEND') {
        label = 'OT Cuối tuần';
        bg = '#ea580c'; // Weekend (Orange)
    }

    var text = label + ': ' + ot.hours + 'h';
    if (ot.status === 'PENDING') {
        text += ' (Chờ)';
        bg = '#fef08a';
        color = '#854d0e';
    }

    return '<div class="day-badge present" style="background:' + bg + ';color:' + color + ';">' + text + '</div>';
}

function calcLateMinutes(checkIn) {
    if (!checkIn || checkIn === '--:--') return 0;
    var parts = checkIn.split(':');
    var totalMin = parseInt(parts[0]) * 60 + parseInt(parts[1]);
    return totalMin > 480 ? totalMin - 480 : 0;   /* shift start 08:00 = 480 min */
}

function toDateStr(y, m, d) {
    return y + '-' + String(m).padStart(2, '0') + '-' + String(d).padStart(2, '0');
}

/* ────────────────────────────────────────────
   Modal
──────────────────────────────────────────── */
function openModal(dateStr, att, isFuture, dayNum, ot) {
    var modal = document.getElementById('editModal');
    if (!modal) return;

    var expStatus = explanationStatusMap[dateStr] || null;
    var expDetails = explanationDetailsMap[dateStr] || null;

    document.getElementById('modal-date').innerText =
        'Ngày ' + (dayNum < 10 ? '0' + dayNum : dayNum) + '/' +
        (currentMonth < 10 ? '0' + currentMonth : currentMonth) + '/' + currentYear;
    document.getElementById('explanation-date').value = dateStr;

    var cvIn = document.getElementById('cv-checkin');
    var cvOut = document.getElementById('cv-checkout');
    if (cvIn) cvIn.textContent = att ? (att.checkIn || '--:--') : '--:--';
    if (cvOut) cvOut.textContent = att ? (att.checkOut || '--:--') : '--:--';

    var explanationDate = document.getElementById('explanation-date');
    var explanationReason = document.getElementById('explanation-reason');
    var explanationForm = document.getElementById('explanation-form');
    var statusBadge = document.getElementById('explanation-status-badge');
    var inputBlock = document.getElementById('explanation-input-block');

    if (explanationDate) explanationDate.value = dateStr;

    var otDate = document.getElementById('ot-date');
    if (otDate) otDate.value = dateStr;

    var otHours = document.getElementById('ot-hours');
    var otType = document.getElementById('ot-type');
    var otNote = document.getElementById('ot-note');
    if (otHours) {
        if (ot) {
            otHours.value = ot.hours;
            if (otType) otType.value = ot.overtimeType;
            if (otNote) otNote.value = ot.note || '';
        } else {
            otHours.value = '';
            if (otType) {
                // Auto-select based on day type
                var dateObj = new Date(dateStr);
                var dayOfWeek = dateObj.getDay();
                if (dayOfWeek === 0 || dayOfWeek === 6) {
                    otType.value = 'WEEKEND';
                } else {
                    otType.value = 'WEEKDAY';
                }
            }
            if (otNote) otNote.value = '';
        }
    }
    if (explanationReason) explanationReason.value = '';

    var dow = new Date(currentYear, currentMonth - 1, dayNum).getDay();
    var isWeekend = (dow === 0 || dow === 6);
    // Xác định xem có cần giải trình không (ngày đi muộn, vắng mặt hoặc ngày thường trong quá khứ không có record)
    var needsExplanation = (att && (att.status === 'late' || att.status === 'absent')) || (!att && !isWeekend && !isFuture);
    var expStatus = explanationStatusMap[dateStr] || null;

    if (explanationForm) {
        if (isFuture || !needsExplanation) {
            // Ngày tương lai hoặc đủ công / nghỉ phép — ẩn toàn bộ form
            explanationForm.style.display = 'none';
        } else {
            explanationForm.style.display = 'flex';

            // Hiển thị badge trạng thái giải trình
            if (statusBadge) {
                var exp = explanationDetailsMap[dateStr] || null;
                var reviewNote = '';
                if (exp && exp.reviewComment && exp.reviewComment.trim()) {
                    var reviewer = exp.reviewedByName ? exp.reviewedByName : 'HR';
                    reviewNote = '<div style="margin-top:8px; padding-top:6px; border-top:1px dashed currentColor; font-size:0.75rem; opacity:0.95;">' +
                        '💬 <strong>Ý kiến từ HR:</strong> "' + exp.reviewComment + '" (' + reviewer + ')' +
                        '</div>';
                }

                if (isAttendanceLocked) {
                    statusBadge.style.display = 'block';
                    if (expStatus === 'APPROVED') {
                        statusBadge.innerHTML = '<div class="quick-action-bar" style="background:#dcfce7;border-color:#bbf7d0"><div class="qab-text" style="color:#166534"><strong>✓ Đã được duyệt</strong>Giải trình của bạn đã được chấp nhận. Ngày công đã cập nhật.' + reviewNote + '</div></div>';
                    } else if (expStatus === 'PENDING') {
                        statusBadge.innerHTML = '<div class="quick-action-bar"><div class="qab-text"><strong>⏳ Đang chờ duyệt</strong>Bạn đã gửi giải trình. HR đang xem xét.</div></div>';
                    } else if (expStatus === 'REJECTED') {
                        statusBadge.innerHTML = '<div class="quick-action-bar" style="background:#fee2e2;border-color:#fecaca"><div class="qab-text" style="color:#991b1b"><strong>✕ Bị từ chối (Bảng công đã khóa)</strong>Giải trình bị từ chối và tháng chấm công đã khóa, không thể gửi lại.' + reviewNote + '</div></div>';
                    } else {
                        statusBadge.innerHTML = '<div class="quick-action-bar" style="background:#fee2e2;border-color:#fecaca"><div class="qab-text" style="color:#991b1b"><strong>🔒 Bảng công đã khóa</strong>Bảng công tháng này đã khóa. Bạn không thể gửi giải trình mới.</div></div>';
                    }
                    if (inputBlock) inputBlock.style.display = 'none';
                } else {
                    if (expStatus === 'PENDING') {
                        statusBadge.style.display = 'block';
                        statusBadge.innerHTML = '<div class="quick-action-bar"><div class="qab-text"><strong>⏳ Đang chờ duyệt</strong>Bạn đã gửi giải trình. HR đang xem xét.</div></div>';
                        if (inputBlock) inputBlock.style.display = 'none';
                    } else if (expStatus === 'APPROVED') {
                        statusBadge.style.display = 'block';
                        statusBadge.innerHTML = '<div class="quick-action-bar" style="background:#dcfce7;border-color:#bbf7d0"><div class="qab-text" style="color:#166534"><strong>✓ Đã được duyệt</strong>Giải trình của bạn đã được chấp nhận. Ngày công đã cập nhật.' + reviewNote + '</div></div>';
                        if (inputBlock) inputBlock.style.display = 'none';
                    } else if (expStatus === 'REJECTED') {
                        statusBadge.style.display = 'block';
                        statusBadge.innerHTML = '<div class="quick-action-bar" style="background:#fee2e2;border-color:#fecaca"><div class="qab-text" style="color:#991b1b"><strong>✕ Bị từ chối</strong>Giải trình đã bị từ chối. Bạn có thể gửi lại.' + reviewNote + '</div></div>';
                        if (inputBlock) inputBlock.style.display = 'flex';
                    } else {
                        statusBadge.style.display = 'block';
                        statusBadge.innerHTML = '<div class="quick-action-bar"><div class="qab-text"><strong>Giải trình chấm công</strong>Bạn có thể gửi giải trình cho dữ liệu của chính mình.</div></div>';
                        if (inputBlock) inputBlock.style.display = 'flex';
                    }
                }
            }
        }
    }

    var qaBar = document.getElementById('quick-action-bar');
    if (qaBar && explanationForm && explanationForm.style.display !== 'none') {
        qaBar.style.display = 'none'; // Badge đã được hiển trong explanation-status-badge
    } else if (qaBar) {
        qaBar.style.display = 'none';
    }

    modal.classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeModal() {
    var modal = document.getElementById('editModal');
    if (modal) modal.classList.remove('open');
    document.body.style.overflow = '';
}

/* ────────────────────────────────────────────
   Month navigation
──────────────────────────────────────────── */
function prevMonth() {
    var m = currentMonth - 1, y = currentYear;
    if (m < 1) { m = 12; y--; }
    navigateTo(m, y);
}

function nextMonth() {
    var m = currentMonth + 1, y = currentYear;
    if (m > 12) { m = 1; y++; }
    navigateTo(m, y);
}

function navigateTo(month, year) {
    var params = new URLSearchParams(window.location.search);
    params.set('month', month);
    params.set('year', year);
    window.location.search = params.toString();
}
