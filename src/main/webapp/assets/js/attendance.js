/* ============================================================
   attendance.js  –  HRM Attendance Calendar (Employee View)
   ============================================================ */

'use strict';

/* ── Constants ── */
const WEEKDAYS = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
const STATUS_LABEL = { present: 'Đủ công', late: 'Đi muộn', absent: 'Vắng mặt', leave: 'Nghỉ phép' };
const STATUS_ICON  = { present: '✓', late: '⚠', absent: '✕', leave: '◷' };

/* ── Global state – written by JSP inline script, read after DOMContentLoaded ── */
window._attendanceBootData = window._attendanceBootData || null;

let currentMonth, currentYear;
let attendanceData = [];
let activeFilter = 'all';

/* ── Boot: wait for DOM then init ── */
document.addEventListener('DOMContentLoaded', function () {
    if (window._attendanceBootData) {
        const d = window._attendanceBootData;
        _boot(d.month, d.year, d.data);
    }

    /* Modal backdrop / keyboard close */
    const modal = document.getElementById('editModal');
    if (modal) {
        modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(); });
    }
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeModal(); });
});

/* Called by window._attendanceBootData setter or DOMContentLoaded, whichever is later */
function _boot(month, year, data) {
    currentMonth   = month;
    currentYear    = year;
    attendanceData = data || [];
    activeFilter   = 'all';

    renderStats();
    renderFilterChips();
    renderCalendar();
}

/* Public init – called from JSP inline script */
function initCalendar(month, year, data) {
    window._attendanceBootData = { month: month, year: year, data: data };
    /* If DOM already ready (e.g. script deferred), boot immediately */
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        _boot(month, year, data);
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
        else if (a.status === 'late')    late++;
        else if (a.status === 'absent')  absent++;
        else if (a.status === 'leave')   leave++;

        if (a.checkOut && a.checkOut !== '--:--') {
            var parts = a.checkOut.split(':');
            var endMin = parseInt(parts[0]) * 60 + parseInt(parts[1]);
            if (endMin > 17 * 60 + 30) otMinutes += endMin - (17 * 60 + 30);
        }
    });

    var otHours     = (otMinutes / 60).toFixed(1);
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
        { key: 'all',     label: 'Tất cả',    cls: '' },
        { key: 'present', label: 'Đủ công',   cls: 'chip-present' },
        { key: 'late',    label: 'Đi muộn',   cls: 'chip-late' },
        { key: 'absent',  label: 'Vắng mặt',  cls: 'chip-absent' },
        { key: 'leave',   label: 'Nghỉ phép', cls: 'chip-leave' },
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
    var firstDay    = new Date(currentYear, currentMonth - 1, 1).getDay();
    var today       = new Date();
    var todayStr    = toDateStr(today.getFullYear(), today.getMonth() + 1, today.getDate());

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
        var dateStr   = toDateStr(currentYear, currentMonth, day);
        var dow       = new Date(currentYear, currentMonth - 1, day).getDay();
        var isWeekend = (dow === 0 || dow === 6);
        var isToday   = (dateStr === todayStr);
        var isFuture  = (dateStr > todayStr);
        var att       = attendanceData.find(function (a) { return a.date === dateStr; }) || null;

        var matchesFilter = activeFilter === 'all'
            || (att && att.status === activeFilter)
            || (activeFilter === 'absent' && !att && !isWeekend && !isFuture);

        var cls = 'calendar-day';
        if (isWeekend)       cls += ' weekend-day';
        else if (att)        { cls += ' status-' + att.status; if (!matchesFilter) cls += ' chip-dimmed'; }
        else if (isFuture)   cls += ' future-day';
        if (isToday)         cls += ' today';

        var el = document.createElement('div');
        el.className = cls;
        el.setAttribute('data-date', dateStr);
        el.innerHTML = buildDayHTML(day, att, isWeekend, isFuture);

        if (!isWeekend) {
            (function (ds, a, future, dn) {
                el.onclick = function () { openModal(ds, a, future, dn); };
            })(dateStr, att, isFuture, day);
        }

        grid.appendChild(el);
    }
}

function buildDayHTML(day, att, isWeekend, isFuture) {
    var numEl = '<div class="day-num">' + day + '</div>';
    if (att) {
        var lateMin  = calcLateMinutes(att.checkIn);
        var lateNote = (att.status === 'late' && lateMin > 0)
            ? '<div class="late-min">Muộn ' + lateMin + 'p</div>' : '';

        var timeEl = (att.checkIn && att.checkIn !== '--:--')
            ? '<div class="day-time">▶ ' + att.checkIn + '<br>◀ ' + (att.checkOut || '--:--') + '</div>'
            : '';

        var badge = '<div class="day-badge ' + att.status + '">'
            + (STATUS_ICON[att.status] || '') + ' '
            + (STATUS_LABEL[att.status] || att.status)
            + '</div>';

        return numEl + timeEl + lateNote + badge;
    }

    if (isWeekend) return numEl;
    if (isFuture) {
        return numEl + '<div class="day-time" style="color:var(--clr-muted);font-size:.65rem">—</div>';
    }
    return numEl + '<div class="day-badge absent">✕ Chưa có</div>';
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
function openModal(dateStr, att, isFuture, dayNum) {
    var modal = document.getElementById('editModal');
    if (!modal) return;

    document.getElementById('modal-date').textContent =
        'Ngày ' + dayNum + ' tháng ' + currentMonth + ' năm ' + currentYear;

    var cvIn  = document.getElementById('cv-checkin');
    var cvOut = document.getElementById('cv-checkout');
    if (cvIn)  cvIn.textContent  = att ? (att.checkIn  || '--:--') : '--:--';
    if (cvOut) cvOut.textContent = att ? (att.checkOut || '--:--') : '--:--';

    var explanationForm = document.getElementById('explanation-form');
    var explanationDate = document.getElementById('explanation-date');
    var explanationReason = document.getElementById('explanation-reason');
    if (explanationDate) explanationDate.value = dateStr;
    if (explanationReason) explanationReason.value = '';
    if (explanationForm) explanationForm.style.display = isFuture ? 'none' : 'flex';

    var qaBar = document.getElementById('quick-action-bar');
    if (qaBar) {
        if (isFuture) {
            qaBar.style.display = 'none';
        } else {
            qaBar.style.display = 'flex';
            qaBar.className = 'quick-action-bar';
            qaBar.innerHTML =
                '<div class="qab-text"><strong>Giải trình chấm công</strong>Bạn chỉ có thể gửi giải trình cho dữ liệu của chính mình.</div>';
        }
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
    params.set('year',  year);
    window.location.search = params.toString();
}
