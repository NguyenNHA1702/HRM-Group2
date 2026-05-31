<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        /* ── Modal overlay ── */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.45);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.open {
            display: flex;
        }

        /* ── Modal box ── */
        .modal {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: 0 20px 60px rgba(0,0,0,.18);
            padding: 32px;
            width: 100%;
            max-width: 480px;
            animation: modalIn .18s ease;
        }
        @keyframes modalIn {
            from { opacity: 0; transform: translateY(-12px) scale(.97); }
            to   { opacity: 1; transform: none; }
        }

        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }
        .modal-header h2 {
            font-size: 18px;
            font-weight: 700;
            color: var(--text);
        }
        .modal-close {
            background: none;
            border: none;
            cursor: pointer;
            color: var(--muted);
            font-size: 22px;
            line-height: 1;
            padding: 2px 6px;
            border-radius: 6px;
            transition: background .15s;
        }
        .modal-close:hover { background: var(--bg); color: var(--text); }

        /* ── Form fields inside modal ── */
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            font-weight: 500;
            margin-bottom: 6px;
            color: var(--text);
            font-size: 13px;
        }
        .form-control {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            color: var(--text);
            background: var(--white);
            transition: border-color .15s, box-shadow .15s;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }
        textarea.form-control { resize: vertical; }

        .modal-footer {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 24px;
        }

        /* ── Alert message (success/error) ── */
        .alert {
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 20px;
        }
        .alert-success { background: var(--green-light); color: #166534; }
        .alert-error   { background: var(--red-light);   color: #991b1b; }
    </style>
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Đơn nghỉ phép</h1>
                <div class="subtitle">Danh sách đơn nghỉ phép của bạn</div>
            </div>

            <button class="btn btn-primary" onclick="openModal()">
                + Tạo đơn
            </button>
        </div>

        <%-- Flash message --%>
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success">${sessionScope.successMsg}</div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-error">${sessionScope.errorMsg}</div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <div class="card">

            <div class="card-header">
                <div class="card-title">Danh sách đơn</div>
            </div>

            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Loại nghỉ</th>
                        <th>Từ ngày</th>
                        <th>Đến ngày</th>
                        <th>Số ngày</th>
                        <th>Trạng thái</th>
                        <th></th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach items="${requests}" var="r">
                        <tr>
                            <td>${r.leaveTypeName}</td>
                            <td>${r.startDate}</td>
                            <td>${r.endDate}</td>
                            <td>${r.totalDays}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status eq 'APPROVED'}">
                                        <span class="badge badge-green">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'REJECTED'}">
                                        <span class="badge badge-red">Từ chối</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'PENDING'}">
                                        <span class="badge badge-orange">Chờ duyệt</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-gray">Đã hủy</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${r.status eq 'PENDING'}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/nghi-phep/cancel">
                                        <input type="hidden" name="id" value="${r.id}">
                                        <button class="btn btn-danger btn-sm">Hủy</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

        </div>

    </div>
</div>

<%-- ══════════════ MODAL TẠO ĐƠN ══════════════ --%>
<div class="modal-overlay" id="createLeaveModal" onclick="handleOverlayClick(event)">
    <div class="modal">

        <div class="modal-header">
            <h2>Tạo đơn nghỉ phép</h2>
            <button class="modal-close" onclick="closeModal()" aria-label="Đóng">&#x2715;</button>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/nghi-phep/create">

            <div class="form-group">
                <label for="leaveTypeId">Loại nghỉ</label>
                <select name="leaveTypeId" id="leaveTypeId" class="form-control">
                    <c:forEach items="${leaveTypes}" var="t">
                        <option value="${t.id}">${t.name}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label for="startDate">Từ ngày</label>
                <input type="date" name="startDate" id="startDate"
                       class="form-control" required>
            </div>

            <div class="form-group">
                <label for="endDate">Đến ngày</label>
                <input type="date" name="endDate" id="endDate"
                       class="form-control" required>
            </div>

            <div class="form-group">
                <label for="reason">Lý do</label>
                <textarea name="reason" id="reason" rows="4"
                          class="form-control"
                          placeholder="Nhập lý do nghỉ phép..."></textarea>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal()">
                    Hủy bỏ
                </button>
                <button type="submit" class="btn btn-primary">
                    Gửi đơn
                </button>
            </div>

        </form>

    </div>
</div>

<script>
    function openModal() {
        document.getElementById('createLeaveModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeModal() {
        document.getElementById('createLeaveModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    function handleOverlayClick(e) {
        if (e.target === document.getElementById('createLeaveModal')) closeModal();
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeModal();
    });

    <%-- Tự mở modal nếu có lỗi validation từ server --%>
    <c:if test="${not empty sessionScope.openModal}">
    openModal();
    </c:if>
</script>

</body>
</html>
