<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Gửi Thông Báo Hệ Thống | HRMS</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    
    <style>
        .notification-card {
            background: #fff;
            border-radius: 12px;
            padding: 32px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            max-width: 800px;
            margin: 0 auto;
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 8px;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 15px;
            font-family: inherit;
            transition: all 0.2s;
            box-sizing: border-box;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 150px;
        }

        .btn-send {
            background: var(--brand);
            color: #fff;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.2s;
        }

        .btn-send:hover {
            background: #4338ca;
        }

        .btn-send:disabled {
            background: #9ca3af;
            cursor: not-allowed;
        }

        .flash-message {
            display: none;
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .flash-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .flash-error {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }

        .help-text {
            font-size: 13px;
            color: var(--muted);
            margin-top: 6px;
        }
    </style>
</head>

<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <main class="content-area">
        <div class="page-header">
            <div>
                <h1>Gửi Thông Báo Hệ Thống</h1>
                <p class="subtitle">Broadcast thông báo realtime tới toàn bộ nhân viên đang online</p>
            </div>
        </div>

        <div class="notification-card">
            <div id="alertBox" class="flash-message" style="display: none;">
                <span id="alertIcon"></span>
                <span id="alertText"></span>
            </div>

            <form id="notificationForm">
                <div class="form-group">
                    <label for="notiTitle">Tiêu đề thông báo <span style="color:red">*</span></label>
                    <input type="text" id="notiTitle" placeholder="Nhập tiêu đề (VD: Thông báo họp công ty)" required maxlength="255">
                </div>

                <div class="form-group">
                    <label for="notiType">Mức độ ưu tiên</label>
                    <select id="notiType">
                        <option value="INFO">Thông tin chung (INFO)</option>
                        <option value="SUCCESS">Thành công (SUCCESS)</option>
                        <option value="WARNING">Cảnh báo / Quan trọng (WARNING)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="notiContent">Nội dung thông báo <span style="color:red">*</span></label>
                    <textarea id="notiContent" placeholder="Nhập nội dung chi tiết..." required></textarea>
                    <div class="help-text">Thông báo sẽ được gửi và hiển thị ngay lập tức trên màn hình của tất cả những người đang truy cập hệ thống.</div>
                </div>

                <div style="text-align: right;">
                    <button type="submit" class="btn-send" id="btnSend">
                        <svg viewBox="0 0 24 24" width="18" height="18" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="22" y1="2" x2="11" y2="13"></line>
                            <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                        </svg>
                        Gửi Thông Báo
                    </button>
                </div>
            </form>
        </div>
    </main>
</div>

<script>
    document.getElementById('notificationForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        const title = document.getElementById('notiTitle').value.trim();
        const content = document.getElementById('notiContent').value.trim();
        const type = document.getElementById('notiType').value;
        const btnSend = document.getElementById('btnSend');
        const alertBox = document.getElementById('alertBox');
        const alertText = document.getElementById('alertText');

        if (!title || !content) {
            return;
        }

        btnSend.disabled = true;
        btnSend.innerHTML = 'Đang gửi...';

        const payload = {
            title: title,
            content: content,
            type: type
        };

        fetch('${pageContext.request.contextPath}/api/admin/notifications/send', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Gửi thông báo thất bại');
            }
            return response.json();
        })
        .then(data => {
            if (data.success) {
                alertBox.className = 'flash-message flash-success';
                alertBox.style.display = 'flex';
                alertText.innerText = 'Đã gửi thông báo thành công tới toàn hệ thống!';
                document.getElementById('notificationForm').reset();
            } else {
                throw new Error(data.error || 'Có lỗi xảy ra');
            }
        })
        .catch(err => {
            alertBox.className = 'flash-message flash-error';
            alertBox.style.display = 'flex';
            alertText.innerText = err.message;
        })
        .finally(() => {
            btnSend.disabled = false;
            btnSend.innerHTML = `
                <svg viewBox="0 0 24 24" width="18" height="18" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="22" y1="2" x2="11" y2="13"></line>
                    <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                </svg>
                Gửi Thông Báo
            `;
            
            // Tự ẩn thông báo sau 5 giây
            setTimeout(() => {
                alertBox.style.display = 'none';
            }, 5000);
        });
    });
</script>
</body>
</html>
