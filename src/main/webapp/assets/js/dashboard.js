/* ================================================================
   dashboard.js — Shared JS cho dashboard pages
   ================================================================ */

/** Hàm tạo bar chart đơn giản với Chart.js */
function createBarChart(canvasId, labels, data, color) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;
    return new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: color || '#4F46E5',
                borderRadius: 6,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: {
                x: { grid: { display: false }, ticks: { font: { size: 11, family: 'Inter' } } },
                y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { font: { size: 11, family: 'Inter' } } }
            }
        }
    });
}

/** Hàm tạo line chart */
function createLineChart(canvasId, labels, data, color) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;
    return new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                borderColor: color || '#4F46E5',
                backgroundColor: hexToRgba(color || '#4F46E5', 0.08),
                borderWidth: 2,
                pointBackgroundColor: color || '#4F46E5',
                pointRadius: 4,
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: {
                x: { grid: { display: false }, ticks: { font: { size: 11, family: 'Inter' } } },
                y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { font: { size: 11, family: 'Inter' } } }
            }
        }
    });
}

/** Hàm tạo doughnut chart */
function createDoughnutChart(canvasId, labels, data, colors) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;
    return new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: colors || ['#4F46E5', '#22c55e', '#f59e0b'],
                borderWidth: 0
            }]
        },
        options: {
            cutout: '65%',
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { font: { size: 11, family: 'Inter' }, boxWidth: 12, padding: 16 }
                }
            }
        }
    });
}

/** Hàm tạo grouped bar chart */
function createGroupedBarChart(canvasId, labels, datasets) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;
    return new Chart(ctx, {
        type: 'bar',
        data: { labels, datasets },
        options: {
            responsive: true,
            plugins: {
                legend: { position: 'bottom', labels: { font: { size: 11, family: 'Inter' }, boxWidth: 12 } }
            },
            scales: {
                x: { grid: { display: false }, ticks: { font: { size: 11, family: 'Inter' } } },
                y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { font: { size: 11, family: 'Inter' } } }
            }
        }
    });
}

/** Helper: hex to rgba */
function hexToRgba(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r},${g},${b},${alpha})`;
}

/** Format số tiền VND */
function formatVND(n) {
    if (n >= 1e9) return (n / 1e9).toFixed(1) + ' tỷ';
    if (n >= 1e6) return (n / 1e6).toFixed(1) + ' triệu';
    return n.toLocaleString('vi-VN') + ' đ';
}