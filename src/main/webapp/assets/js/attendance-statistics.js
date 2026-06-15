'use strict';

document.addEventListener('DOMContentLoaded', function () {
    var searchInput = document.getElementById('statistics-search-input');
    if (!searchInput) {
        return;
    }

    searchInput.addEventListener('input', function () {
        var keyword = normalizeText(searchInput.value);
        var rows = document.querySelectorAll(
            '#attendance-statistics-table tbody .statistics-row'
        );
        var visibleRows = 0;

        rows.forEach(function (row) {
            var matches = normalizeText(row.textContent).indexOf(keyword) !== -1;
            row.hidden = !matches;
            if (matches) {
                visibleRows++;
            }
        });

        var noResult = document.getElementById('statistics-no-result');
        if (noResult) {
            noResult.hidden = rows.length === 0 || visibleRows > 0;
        }
    });
});

function normalizeText(value) {
    return (value || '')
        .replace(/[Đđ]/g, function (character) {
            return character === 'Đ' ? 'D' : 'd';
        })
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .trim();
}
