package com.hrm.project.service.impl;

import com.hrm.project.dao.ContractDAO;
import com.hrm.project.dao.SalaryScaleDAO;
import com.hrm.project.dao.impl.ContractDAOImpl;
import com.hrm.project.dao.impl.SalaryScaleDAOImpl;
import com.hrm.project.model.Contract;
import com.hrm.project.model.dtos.response.ContractDTO;
import com.hrm.project.service.ContractService;

import com.hrm.project.enums.ContractType;

import java.sql.Date;
import java.util.List;

public class ContractServiceImpl implements ContractService {

    private final ContractDAO contractDAO = new ContractDAOImpl();
    private final SalaryScaleDAO salaryScaleDAO = new SalaryScaleDAOImpl();

    @Override
    public List<ContractDTO> getAllContracts() {
        return contractDAO.getAllContracts();
    }

    @Override
    public boolean createContract(Contract contract, int salaryScaleId) {

        // Resolve salary from salary_scale_id
        double baseSalary = salaryScaleDAO.getBasicSalaryById(salaryScaleId);
        if (baseSalary < 0) {
            throw new RuntimeException(
                    "Thất bại: Bậc lương không tồn tại hoặc đã bị vô hiệu hóa (ID: " + salaryScaleId + ").");
        }
        contract.setBaseSalary(baseSalary);

        // Business rule 1: mỗi nhân viên chỉ được có tối đa 1 hợp đồng Active
        String activeContractNumber = contractDAO.getActiveContractNumber(contract.getEmployeeId());
        if (activeContractNumber != null) {
            throw new RuntimeException(
                    "Thất bại: Nhân viên hiện đang có một hợp đồng " + activeContractNumber + " còn hiệu lực.");
        }

        // Business rule 2: startDate phải nhỏ hơn endDate (trừ HĐ Không thời hạn)
        if (contract.getContractType() != ContractType.INDEFINITE.getValue()) {
            if (contract.getEndDate() == null ||
                    contract.getStartDate().compareTo(contract.getEndDate()) >= 0) {
                throw new RuntimeException(
                        "Thất bại: Ngày bắt đầu phải nhỏ hơn ngày kết thúc hợp đồng.");
            }
        }

        return contractDAO.createContract(contract);
    }

    @Override
    public boolean terminateContract(int contractId, Date terminateDate, String reason) {
        return contractDAO.terminateContract(contractId, terminateDate, reason);
    }

    @Override
    public boolean updateStatus(int contractId, int newStatus) {
        return contractDAO.updateStatus(contractId, newStatus);
    }

    @Override
    public boolean renewContract(int oldContractId, Contract newContract, int salaryScaleId) {

        // Resolve salary from salary_scale_id
        double baseSalary = salaryScaleDAO.getBasicSalaryById(salaryScaleId);
        if (baseSalary < 0) {
            throw new RuntimeException(
                    "Thất bại: Bậc lương không tồn tại hoặc đã bị vô hiệu hóa (ID: " + salaryScaleId + ").");
        }
        newContract.setBaseSalary(baseSalary);

        // Business rule: không cho phép gia hạn hợp đồng Không xác định thời hạn
        int oldContractType = contractDAO.getContractTypeById(oldContractId);
        if (oldContractType == ContractType.INDEFINITE.getValue()) {
            throw new RuntimeException(
                    "Thất bại: Không thể gia hạn hợp đồng không xác định thời hạn.");
        }

        return contractDAO.renewContract(oldContractId, newContract);
    }
}
