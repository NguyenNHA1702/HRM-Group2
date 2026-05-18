<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Quản lý phân quyền - HRMS</title>

      <script src="https://cdn.tailwindcss.com"></script>

      <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/permissions.css">
      <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
      <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    </head>

    <body class="bg-gray-100">

      <jsp:include page="/WEB-INF/common/header.jsp" />

      <div class="flex">
        <jsp:include page="/WEB-INF/common/sidebar.jsp" />

        <main class="flex-1 p-6 space-y-6">

          <div class="border-b border-gray-200 pb-4">
            <h1 class="text-2xl font-bold text-gray-900">Phân quyền</h1>
            <p class="text-sm text-gray-500 mt-1">Xin chào, Nguyễn Văn Admin</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <c:forEach var="role" items="${roles}">
              <div onclick="selectRole(${role.id}, '${role.name}', '${role.description}')" id="role-card-${role.id}"
                data-role-id="${role.id}" data-role-name="${role.name}" data-role-desc="${role.description}"
                class="role-card bg-white rounded-lg shadow p-6 cursor-pointer transition hover:shadow-lg">
                <div class="flex items-start justify-between mb-3">
                  <div class="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center">
                    <svg class="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z">
                      </path>
                    </svg>
                  </div>
                  <span class="px-3 py-1 bg-gray-100 text-gray-700 text-sm font-medium rounded-full">
                    ${role.userCount} users
                  </span>
                </div>
                <h3 class="text-lg font-semibold text-gray-900 mb-2">${role.name}</h3>
                <p class="text-sm text-gray-600">${role.description}</p>
              </div>
            </c:forEach>
          </div>

          <div id="matrix-container" class="bg-white rounded-lg shadow hidden">
            <div class="p-6 border-b border-gray-200">
              <h3 id="matrix-title" class="text-lg font-semibold text-gray-900">Ma trận phân quyền</h3>
              <p id="matrix-desc" class="text-sm text-gray-600 mt-1"></p>
            </div>
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Module
                    </th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Xem
                    </th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Tạo mới
                    </th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Chỉnh
                      sửa</th>
                    <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Xóa
                    </th>
                  </tr>
                </thead>
                <tbody id="matrix-body" class="divide-y divide-gray-200 bg-white">
                </tbody>
              </table>
            </div>
            <div class="p-6 border-t border-gray-200 flex justify-end">
              <button id="btn-save-permissions"
                class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition font-medium shadow-sm">
                Lưu thay đổi
              </button>
            </div>
          </div>

        </main>
      </div>

      <jsp:include page="/WEB-INF/common/footer.jsp" />

      <script>
        const contextPath = "${pageContext.request.contextPath}";
      </script>

      <script src="${pageContext.request.contextPath}/assets/js/permissions.js"></script>

    </body>

    </html>