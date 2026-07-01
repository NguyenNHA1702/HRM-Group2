package com.hrm.project.dao;

import com.hrm.project.model.Contract;
import com.hrm.project.model.dtos.response.ContractDTO;

import java.sql.Date;
import java.util.List;

public interface ContractDAO {

    List<ContractDTO> getAllContracts();

    boolean createContract(Contract contract);

    boolean checkContractNumberExists(String contractNumber);

    boolean checkActiveContractExists(int employeeId);

    /**
     * Returns the contract_number of the currently active contract for an employee,
     * or null if none exists.
     */
    String getActiveContractNumber(int employeeId);

    boolean terminateContract(int contractId, Date terminateDate, String reason);

    boolean updateStatus(int contractId, int newStatus);

    /**
     * Returns the contract_type of a contract by its ID, or -1 if not found.
     */
    int getContractTypeById(int contractId);

    boolean renewContract(int oldContractId, Contract newContract);
}
