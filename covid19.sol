pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Pausable.sol";

contract COVID is Ownable,Pausable{
    uint public hospitalcount = 0;
    uint public patientcount = 0;
     enum State { Tested, Active, Recovered , Deceased }
    struct hospital{
        uint hospital_id;
        string hospital_name;
        bool registered;
        uint[] own_patients;
    }

    mapping(uint=>hospital) public hosp;
    
    struct patient{
        uint patient_id;
        address patient_acc;
        uint aadhar_no;
        string patient_name;
        uint report_added;
        State patient_state;
        string report_hash; //stores the IPFS hash where patients record is stored
    }
    
    mapping(uint=>patient) public pat; 
    
    modifier onlyRegistered(uint hos_id){
        require(hosp[hos_id].registered == true,"Check the hospitalId");
        _;
    } 
    
    function addHospital(string memory hosp_name)public{
        hospitalcount++;
        hosp[hospitalcount].hospital_id = hospitalcount;
        hosp[hospitalcount].hospital_name = hosp_name;
        hosp[hospitalcount].registered = false;
        
    }
    
    function registerhospital(uint hosp_id,bool reg)public onlyOwner{
        hosp[hosp_id].registered = reg;
    }
    
    function addpatient(uint hosp_id,uint aadhar,address account,string memory name)public onlyRegistered(hosp_id){
        patientcount++;
        pat[aadhar].patient_id = patientcount;
        pat[aadhar].aadhar_no = aadhar;
        pat[aadhar].patient_acc = account;
        pat[aadhar].patient_name = name;
        pat[aadhar].report_added = now;
        hosp[hosp_id].own_patients.push(aadhar);
    }
    
    function updatePatientState(uint hosp_id,uint aadhar,uint state,string memory hash)public onlyRegistered(hosp_id){
        pat[aadhar].report_hash = hash;
        if(state == 0)
        {pat[aadhar].patient_state = State.Tested;}
        if(state == 1)
        {pat[aadhar].patient_state = State.Active;}
        if(state == 2)
        {pat[aadhar].patient_state = State.Recovered;}
        if(state == 3)
        {pat[aadhar].patient_state = State.Deceased;}
    }
    
    function viewpatient(uint aadhar)public view returns(patient memory){
        return pat[aadhar];
    }
    
    function viewReport(uint aadhar)public view returns(string memory){
        return pat[aadhar].report_hash;
    }
    
    
}