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
            <p class="text-sm text-gray-500 mt-1">Xin chào, <c:out value="${sessionScope.fullName}" default="Admin"/></p>
          </div>

          <!-- Toast Notification Container -->
          <div id="toast-container" class="fixed top-5 right-5 z-50 flex flex-col gap-2 pointer-events-none"></div>

          <!-- Thanh tìm kiếm & bộ lọc -->
          <div class="bg-white p-4 rounded-lg shadow flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div class="flex-1 min-w-[200px]">
              <div class="relative">
                <input type="text" id="role-search-input" placeholder="Tìm kiếm tên hoặc mô tả vai trò..." 
                  class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                  </svg>
                </div>
              </div>
            </div>
            <div class="flex flex-wrap items-center gap-4">
              <!-- Lọc trạng thái -->
              <div class="flex items-center gap-2">
                <label for="role-status-filter" class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Trạng thái:</label>
                <select id="role-status-filter" class="border border-gray-300 rounded-lg px-3 py-1.5 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
                  <option value="all">Tất cả</option>
                  <option value="active">Hoạt động</option>
                  <option value="inactive">Tạm khóa</option>
                </select>
              </div>
              <!-- Sắp xếp -->
              <div class="flex items-center gap-2">
                <label for="role-sort-by" class="text-xs font-semibold text-gray-500 uppercase tracking-wider">Sắp xếp:</label>
                <select id="role-sort-by" class="border border-gray-300 rounded-lg px-3 py-1.5 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500">
                  <option value="name-asc">Tên (A-Z)</option>
                  <option value="name-desc">Tên (Z-A)</option>
                  <option value="users-desc">Số users (Giảm dần)</option>
                  <option value="users-asc">Số users (Tăng dần)</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Grid hiển thị vai trò động -->
          <div id="roles-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <!-- Được render động bằng JS -->
          </div>

          <!-- Phân trang -->
          <div id="pagination-container" class="flex items-center justify-between bg-white px-4 py-3 rounded-lg shadow">
            <div class="flex flex-1 justify-between sm:hidden">
              <button id="btn-prev-mobile" class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Trước</button>
              <button id="btn-next-mobile" class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Sau</button>
            </div>
            <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
              <div>
                <p class="text-sm text-gray-700">
                  Hiển thị từ <span id="page-start-idx" class="font-medium">0</span> đến <span id="page-end-idx" class="font-medium">0</span> trong tổng số <span id="page-total-count" class="font-medium">0</span> vai trò
                </p>
              </div>
              <div>
                <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination" id="pagination-pages">
                  <!-- Nút phân trang tự động tạo ở đây -->
                </nav>
              </div>
            </div>
          </div>

          <!-- Modal chỉnh sửa vai trò -->
          <div id="edit-role-modal" class="fixed inset-0 z-50 overflow-y-auto hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
            <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
              <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true" onclick="closeEditModal()"></div>
              <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
              
              <div class="inline-block align-middle bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
                <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                  <div class="sm:flex sm:items-start w-full">
                    <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-indigo-100 sm:mx-0 sm:h-10 sm:w-10">
                      <svg class="h-6 w-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                      </svg>
                    </div>
                    <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left w-full">
                      <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">Chỉnh sửa thông tin vai trò</h3>
                      <div class="mt-4 space-y-4 w-full">
                        <div>
                          <label for="modal-role-name" class="block text-sm font-medium text-gray-700">Tên vai trò <span class="text-red-500">*</span></label>
                          <input type="text" id="modal-role-name" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md p-2 border" placeholder="Nhập tên vai trò...">
                        </div>
                        <div>
                          <label for="modal-role-desc" class="block text-sm font-medium text-gray-700">Mô tả</label>
                          <textarea id="modal-role-desc" rows="3" class="mt-1 focus:ring-indigo-500 focus:border-indigo-500 block w-full shadow-sm sm:text-sm border-gray-300 rounded-md p-2 border" placeholder="Mô tả vai trò..."></textarea>
                        </div>
                        <div id="modal-status-container">
                          <label for="modal-role-status" class="block text-sm font-medium text-gray-700">Trạng thái hoạt động</label>
                          <select id="modal-role-status" class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                            <option value="true">Hoạt động (Active)</option>
                            <option value="false">Tạm khóa (Inactive)</option>
                          </select>
                          <p id="modal-status-warning" class="mt-1.5 text-xs text-amber-600 hidden font-medium">⚠️ Đây là vai trò Admin mặc định, không được phép vô hiệu hóa.</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse gap-2">
                  <button type="button" onclick="saveRoleDetails()" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-indigo-600 text-base font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:ml-3 sm:w-auto sm:text-sm">Lưu thay đổi</button>
                  <button type="button" onclick="closeEditModal()" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">Hủy</button>
                </div>
              </div>
            </div>
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
        const initialRoles = [
          <c:forEach var="role" items="${roles}" varStatus="loop">
            {
              id: ${role.id},
              name: "<c:out value='${role.name}' escapeXml='true'/>",
              description: "<c:out value='${role.description}' escapeXml='true'/>",
              isActive: ${role.isActive ? 'true' : 'false'},
              userCount: ${role.userCount}
            }${!loop.last ? ',' : ''}
          </c:forEach>
        ];
      </script>

      <script src="${pageContext.request.contextPath}/assets/js/permissions.js"></script>

    </body>

    </html>