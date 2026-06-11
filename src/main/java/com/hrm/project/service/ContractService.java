package com.hrm.project.service;

import com.hrm.project.model.Contract;
import com.hrm.project.model.dtos.response.ContractDTO;

import java.sql.Date;
import java.util.List;

public interface ContractService {

    List<ContractDTO> getAllContracts();

    boolean createContract(Contract contract, int salaryScaleId);

    boolean terminateContract(int contractId, Date terminateDate, String reason);

    boolean updateStatus(int contractId, int newStatus);

    boolean renewContract(int oldContractId, Contract newContract, int salaryScaleId);
}
