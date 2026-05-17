<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý phân quyền - HRMS</title>

  <!-- Google Font & Tailwind -->
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            sans: ['"Plus Jakarta Sans"', 'sans-serif'],
          }
        }
      }
    }
  </script>

  <!-- Custom Stylesheet -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/permissions.css">
  
  <!-- FontAwesome -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-[#f8fafc] font-sans antialiased text-slate-800 min-h-screen">

<!-- 1. Header Include -->
<jsp:include page="/WEB-INF/common/header.jsp" />

<div class="flex">
  <!-- 2. Sidebar Include -->
  <jsp:include page="/WEB-INF/common/sidebar.jsp" />

  <!-- 3. Main Dashboard Area -->
  <main class="flex-1 p-8 space-y-8 overflow-y-auto max-w-[calc(100vw-260px)]">

    <!-- Toast Notifications Container -->
    <div id="toast-container" class="toast-container"></div>

    <!-- Title & Greeting Section -->
    <div class="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-200 pb-6 gap-4">
      <div>
        <div class="flex items-center gap-2 text-sm font-semibold text-indigo-600 mb-1">
          <i class="fa-solid fa-shield-halved"></i>
          <span>HỆ THỐNG QUẢN TRỊ</span>
        </div>
        <h1 class="text-3xl font-extrabold text-slate-900 tracking-tight">Phân quyền & Vai trò</h1>
        <p class="text-sm text-slate-500 mt-1">Xin chào, <span class="font-bold text-slate-700">${sessionScope.fullName != null ? sessionScope.fullName : "Nguyễn Văn Admin"}</span></p>
      </div>
      <div>
        <button onclick="openCreateModal()" class="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-sm rounded-xl shadow-lg shadow-indigo-100 hover:shadow-indigo-200 transition-all flex items-center gap-2">
          <i class="fa-solid fa-plus text-xs"></i> Thêm vai trò mới
        </button>
      </div>
    </div>

    <!-- Interactive Search, Filters & Sorters toolbar -->
    <div class="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex flex-col xl:flex-row gap-4 items-center justify-between">
      <div class="flex flex-col md:flex-row gap-3 w-full xl:w-auto items-stretch md:items-center">
        <!-- Search input -->
        <div class="relative flex-1 md:w-80">
          <i class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
          <input type="text" id="search-roles" oninput="handleSearchFilter()" placeholder="Tìm vai trò..." class="w-full pl-11 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-indigo-500 focus:bg-white transition-all">
        </div>

        <!-- Filter by Role Group -->
        <div class="relative">
          <select id="filter-group" onchange="handleSearchFilter()" class="w-full md:w-48 appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-indigo-500 focus:bg-white transition-all cursor-pointer">
            <option value="">Tất cả Nhóm</option>
            <c:forEach var="g" items="${groups}">
              <option value="${g.id}">${g.name}</option>
            </c:forEach>
          </select>
          <i class="fa-solid fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
        </div>

        <!-- Filter by Status -->
        <div class="relative">
          <select id="filter-status" onchange="handleSearchFilter()" class="w-full md:w-44 appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-indigo-500 focus:bg-white transition-all cursor-pointer">
            <option value="">Tất cả Trạng thái</option>
            <option value="active">Hoạt động</option>
            <option value="inactive">Vô hiệu hóa</option>
          </select>
          <i class="fa-solid fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
        </div>
      </div>

      <!-- Sorting Controls -->
      <div class="flex gap-3 w-full xl:w-auto justify-end items-center">
        <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Sắp xếp:</span>
        <div class="relative">
          <select id="sort-roles" onchange="handleSearchFilter()" class="w-48 appearance-none pl-4 pr-10 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-indigo-500 focus:bg-white transition-all cursor-pointer">
            <option value="id-asc">Mặc định (ID)</option>
            <option value="name-asc">Tên (A-Z)</option>
            <option value="name-desc">Tên (Z-A)</option>
            <option value="users-desc">Số lượng users (Nhiều nhất)</option>
            <option value="users-asc">Số lượng users (Ít nhất)</option>
          </select>
          <i class="fa-solid fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
        </div>
      </div>
    </div>

    <!-- Role Cards grid and Pagination wrapper -->
    <div>
      <div id="role-cards-container" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Rendered dynamically by permissions.js -->
      </div>
      
      <!-- Pagination Widget -->
      <div id="pagination-container" class="flex items-center justify-between border-t border-slate-200 pt-6 mt-6">
        <p class="text-sm text-slate-500" id="pagination-info">
          Hiển thị <b>0 - 0</b> trên tổng số <b>0</b> vai trò
        </p>
        <div class="flex items-center gap-2" id="pagination-buttons">
          <!-- Rendered dynamically by permissions.js -->
        </div>
      </div>
    </div>

    <!-- Elegant Matrix container (Opens upon clicking card) -->
    <div id="matrix-container" class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden hidden transition-all duration-300">
      <div class="p-6 bg-slate-50/70 border-b border-slate-200 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 mb-1">
            <span class="inline-flex items-center justify-center w-6 h-6 bg-indigo-100 rounded-lg text-indigo-600 text-xs font-semibold">
              <i class="fa-solid fa-network-wired"></i>
            </span>
            <h3 id="matrix-title" class="text-lg font-bold text-slate-900">Ma trận phân quyền</h3>
          </div>
          <p id="matrix-desc" class="text-sm text-slate-500 pl-8"></p>
        </div>
        
        <div class="flex items-center gap-3">
          <button onclick="toggleAllMatrixCheckboxes(true)" class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-lg transition-all">
            <i class="fa-solid fa-check-double mr-1"></i> Chọn tất cả
          </button>
          <button onclick="toggleAllMatrixCheckboxes(false)" class="px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-lg transition-all">
            <i class="fa-solid fa-rotate-left mr-1"></i> Bỏ chọn hết
          </button>
        </div>
      </div>
      
      <div class="overflow-x-auto">
        <table class="w-full min-w-[700px]">
          <thead>
            <tr class="bg-slate-100/50 border-b border-slate-200 text-slate-500 uppercase tracking-wider text-xs font-bold">
              <th class="px-8 py-4 text-left w-1/3">Module hệ thống</th>
              <th class="px-6 py-4 text-center">Xem (View)</th>
              <th class="px-6 py-4 text-center">Tạo mới (Create)</th>
              <th class="px-6 py-4 text-center">Sửa (Edit)</th>
              <th class="px-6 py-4 text-center">Xóa (Delete)</th>
            </tr>
          </thead>
          <tbody id="matrix-body" class="divide-y divide-slate-100">
            <!-- Rendered dynamically by permissions.js -->
          </tbody>
        </table>
      </div>
      
      <div class="p-6 bg-slate-50/70 border-t border-slate-200 flex justify-end gap-3">
        <button onclick="hideMatrixContainer()" class="px-4 py-2 border border-slate-200 bg-white hover:bg-slate-50 text-slate-700 font-semibold text-sm rounded-xl transition-all">
          Hủy bỏ
        </button>
        <button id="btn-save-permissions" class="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-sm rounded-xl shadow-md shadow-indigo-100 hover:shadow-indigo-200 transition-all flex items-center gap-2">
          <i class="fa-solid fa-floppy-disk text-xs"></i> Lưu ma trận quyền
        </button>
      </div>
    </div>

  </main>
</div>

<!-- 4. Footer Include -->
<jsp:include page="/WEB-INF/common/footer.jsp" />

<!-- 5. Edit/Create Role Modal -->
<div id="role-modal" class="modal-overlay">
  <div class="modal-content">
    <div class="px-6 py-4 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
      <h3 id="modal-title" class="text-base font-bold text-slate-900">Chỉnh sửa vai trò</h3>
      <button onclick="closeRoleModal()" class="w-8 h-8 rounded-lg hover:bg-slate-200 text-slate-400 hover:text-slate-600 transition-all flex items-center justify-center">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>
    <form id="role-form" onsubmit="submitRoleForm(event)" class="p-6 space-y-4">
      <input type="hidden" id="modal-role-id">
      
      <div>
        <label for="modal-role-name" class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Tên vai trò <span class="text-red-500">*</span></label>
        <input type="text" id="modal-role-name" required placeholder="Ví dụ: HR Payroll, IT Technical Leader..." class="form-input">
      </div>
      
      <div>
        <label for="modal-role-group" class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Nhóm phân quyền <span class="text-red-500">*</span></label>
        <div class="relative">
          <select id="modal-role-group" required class="form-input appearance-none pr-10 cursor-pointer">
            <c:forEach var="g" items="${groups}">
              <option value="${g.id}">${g.name} (${g.code})</option>
            </c:forEach>
          </select>
          <i class="fa-solid fa-chevron-down absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs pointer-events-none"></i>
        </div>
      </div>
      
      <div>
        <label for="modal-role-desc" class="block text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Mô tả vai trò</label>
        <textarea id="modal-role-desc" rows="3" placeholder="Mô tả cụ thể phạm vi hoặc giới hạn của chức vụ này..." class="form-input resize-none"></textarea>
      </div>
      
      <div class="flex justify-end gap-3 pt-2">
        <button type="button" onclick="closeRoleModal()" class="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold text-sm rounded-xl transition-all">
          Hủy bỏ
        </button>
        <button type="submit" class="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-sm rounded-xl shadow-md transition-all">
          Lưu thay đổi
        </button>
      </div>
    </form>
  </div>
</div>

<!-- Custom Confirmation Dialog Box -->
<div id="confirm-modal" class="modal-overlay">
  <div class="modal-content max-w-sm p-6 text-center">
    <div class="w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center text-amber-600 text-lg mx-auto mb-4">
      <i class="fa-solid fa-circle-question"></i>
    </div>
    <h3 id="confirm-title" class="text-lg font-bold text-slate-900 mb-2">Xác nhận hành động</h3>
    <p id="confirm-message" class="text-sm text-slate-500 mb-6">Bạn có chắc chắn muốn tiếp tục hành động này không?</p>
    <div class="flex justify-center gap-3">
      <button onclick="closeConfirmModal(false)" class="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold text-sm rounded-xl transition-all">
        Hủy bỏ
      </button>
      <button onclick="closeConfirmModal(true)" class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-sm rounded-xl transition-all">
        Đồng ý
      </button>
    </div>
  </div>
</div>

<!-- 6. Embedded Model and Global script variables -->
<script>
  const contextPath = "${pageContext.request.contextPath}";
  
  // Inject complete model list directly into javascript for lightning fast reactivity
  let rolesData = [
    <c:forEach var="role" items="${roles}" varStatus="status">
      {
        id: ${role.id},
        name: `${role.name}`,
        description: `${role.description != null ? role.description : ""}`,
        userCount: ${role.userCount},
        isActive: ${role.isActive},
        groupId: ${role.groupId},
        groupName: `${role.groupName}`
      }${not status.last ? ',' : ''}
    </c:forEach>
  ];
  
  const groupsData = [
    <c:forEach var="g" items="${groups}" varStatus="status">
      {
        id: ${g.id},
        code: `${g.code}`,
        name: `${g.name}`
      }${not status.last ? ',' : ''}
    </c:forEach>
  ];
</script>

<!-- Custom JS logic -->
<script src="${pageContext.request.contextPath}/assets/js/permissions.js"></script>

</body>
</html>