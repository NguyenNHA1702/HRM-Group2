package com.hrm.project.service.impl;

import com.hrm.project.dao.LeaveRequestDAO;
import com.hrm.project.dao.impl.LeaveRequestDAOImpl;
import com.hrm.project.model.LeaveRequest;
import com.hrm.project.model.dtos.response.LeaveSummaryDto;
import com.hrm.project.service.LeaveRequestService;

import java.sql.Date;
import java.util.List;

public class LeaveRequestServiceImpl implements LeaveRequestService {

    private final LeaveRequestDAO leaveRequestDAO =
            new LeaveRequestDAOImpl();

    @Override
    public List<LeaveRequest> getEmployeeRequests(int employeeId) {
        return leaveRequestDAO.getByEmployee(employeeId);
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
            sendNotificationToRoleGroup("HR", "Đơn nghỉ phép mới", "Có một đơn xin nghỉ phép mới cần duyệt.", "INFO");
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
    public List<LeaveSummaryDto> getLeaveSummaryReport(Date fromDate, Date toDate, Integer departmentId) {
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
}