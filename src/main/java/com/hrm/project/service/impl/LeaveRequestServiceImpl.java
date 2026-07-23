package com.hrm.project.service.impl;

import com.hrm.project.dao.LeaveRequestDAO;
import com.hrm.project.dao.impl.LeaveRequestDAOImpl;
import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.model.LeaveRequest;
import com.hrm.project.model.dtos.response.LeaveSummaryDto;
import com.hrm.project.service.LeaveRequestService;

import java.sql.Date;
import java.util.List;

public class LeaveRequestServiceImpl implements LeaveRequestService {

    private final LeaveRequestDAO leaveRequestDAO =
            new LeaveRequestDAOImpl();
    private final DepartmentDAO departmentDAO = new DepartmentDAOImpl();

    @Override
    public List<LeaveRequest> getEmployeeRequests(int employeeId) {
        return leaveRequestDAO.getByEmployee(employeeId);
    }

    @Override
    public List<LeaveRequest> getRequestsForManager(int managerId) {
        return leaveRequestDAO.getRequestsForManager(managerId);
    }

    @Override
    public List<LeaveRequest> getAllRequests() {
        return leaveRequestDAO.getAll();
    }

    @Override
    public LeaveRequest getById(int id) {
        return leaveRequestDAO.getById(id);
    }

    @Override
    public boolean createRequest(LeaveRequest request) {
        boolean result = leaveRequestDAO.create(request);
        if (result) {
            if ("PENDING_MANAGER".equals(request.getStatus())) {
                sendNotificationToDepartmentManager(request.getEmployeeId(), "Đơn nghỉ phép mới", "Có nhân viên vừa gửi đơn xin nghỉ phép cần bạn duyệt.", "INFO");
            } else {
                sendNotificationToRoleGroup("HR", "Đơn nghỉ phép mới", "Có một đơn xin nghỉ phép mới cần duyệt.", "INFO");
            }
        }
        return result;
    }

    @Override
    public boolean approveRequest(int requestId, int reviewerId) {
        boolean result = leaveRequestDAO.approve(requestId, reviewerId);
        if (result) {
            sendNotificationToEmployee(requestId, "Đơn nghỉ phép được duyệt", "Đơn nghỉ phép của bạn đã được duyệt.", "SUCCESS");
        }
        return result;
    }

    @Override
    public boolean rejectRequest(int requestId, int reviewerId) {
        boolean result = leaveRequestDAO.reject(requestId, reviewerId);
        if (result) {
            sendNotificationToEmployee(requestId, "Đơn nghỉ phép bị từ chối", "Đơn nghỉ phép của bạn đã bị từ chối.", "WARNING");
        }
        return result;
    }

    private void sendNotificationToEmployee(int requestId, String title, String content, String type) {
        try {
            LeaveRequest req = leaveRequestDAO.getById(requestId);
            if (req != null) {
                com.hrm.project.dao.NotificationDAO notificationDAO = new com.hrm.project.dao.impl.NotificationDAOImpl();
                com.hrm.project.model.Notification noti = new com.hrm.project.model.Notification();
                noti.setTitle(title);
                noti.setContent(content);
                noti.setType(type);
                
                int notiId = notificationDAO.createNotification(noti);
                if (notiId > 0) {
                    notificationDAO.addNotificationForUsers(notiId, java.util.Collections.singletonList(req.getEmployeeId()));
                    String payload = "{\"title\":\"" + title + "\", \"content\":\"" + content + "\"}";
                    com.hrm.project.utils.SSEManager.sendNotification(req.getEmployeeId(), payload);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean cancelRequest(int requestId) {
        return leaveRequestDAO.cancel(requestId);
    }

    @Override
    public List<LeaveSummaryDto> getLeaveSummaryReport(Date fromDate, Date toDate, Integer departmentId, String roleGroup, Integer userId) {
        // Nếu là manager, tự động lấy departmentId dựa trên managerId (userId)
        if ("MANAGER".equalsIgnoreCase(roleGroup) && userId != null) {
            // departmentId được lấy từ DepartmentDAO (có method getDepartmentIdByManagerId)
            departmentId = departmentDAO.getDepartmentIdByManagerId(userId);
        }
        return leaveRequestDAO.getLeaveSummaryReport(fromDate, toDate, departmentId);
    }

    private void sendNotificationToRoleGroup(String roleGroup, String title, String content, String type) {
        try {
            com.hrm.project.dao.NotificationDAO notificationDAO = new com.hrm.project.dao.impl.NotificationDAOImpl();
            com.hrm.project.model.Notification noti = new com.hrm.project.model.Notification();
            noti.setTitle(title);
            noti.setContent(content);
            noti.setType(type);
            
            int notiId = notificationDAO.createNotification(noti);
            if (notiId > 0) {
                notificationDAO.addNotificationForRoleGroup(notiId, roleGroup);
                String payload = "{\"title\":\"" + title + "\", \"content\":\"" + content + "\"}";
                // Broadcast cho tất cả (ai thuộc nhóm HR có trong DB sẽ có thông báo khi refresh, còn popup hiện tạm cho mọi người)
                // Hoặc có thể cải tiến lấy userIds từ role.
                com.hrm.project.utils.SSEManager.broadcastNotification(payload); 
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void sendNotificationToDepartmentManager(int employeeId, String title, String content, String type) {
        try {
            String sql = "SELECT d.manager_id FROM employees e JOIN departments d ON e.department_id = d.id WHERE e.id = ?";
            try (java.sql.Connection con = com.hrm.project.dao.impl.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, employeeId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Object mgrObj = rs.getObject("manager_id");
                        if (mgrObj != null) {
                            int managerId = rs.getInt("manager_id");
                            com.hrm.project.dao.NotificationDAO notificationDAO = new com.hrm.project.dao.impl.NotificationDAOImpl();
                            com.hrm.project.model.Notification noti = new com.hrm.project.model.Notification();
                            noti.setTitle(title);
                            noti.setContent(content);
                            noti.setType(type);
                            int notiId = notificationDAO.createNotification(noti);
                            if (notiId > 0) {
                                notificationDAO.addNotificationForUsers(notiId, java.util.Collections.singletonList(managerId));
                                String payload = "{\"title\":\"" + title + "\", \"content\":\"" + content + "\"}";
                                com.hrm.project.utils.SSEManager.sendNotification(managerId, payload);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}