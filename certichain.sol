pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

 import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";


contract Certificates is Ownable{
    
    uint256 public collegecnt = 0;
    uint256 public studentcnt = 0;
    uint256 public certificatecnt = 0;
    
    event clgAdded(uint indexed clg_id,string clg_name,uint times);
    event clgRegistered(uint indexed clg_id,bool isReg,uint times);
    event stuAdded(uint indexed stu_id,uint indexed aadhar,string stu_name,uint indexed clg_id,uint times);
    event certAdded(uint indexed cert_id,uint indexed clg_id,uint indexed stu_id,uint times);
    
    struct College{
        uint clg_id;
        address clg_address;
        string clg_name;
        bool isregistered;
        uint[] clg_student;
    }
    
    struct Cert{
        uint cert_id;
        uint college_id;
        uint stu_id;
        string cert_name;
        uint student_aadhar;
        string ipfs_hash;
        uint time;
    }
    
    struct Student{
        uint stu_aadhar_no;
        uint stu_id;
        string stu_name;
        uint cllg_id;
        uint certcount;
        uint[] certs;

    } 
    
    
    mapping(address=>College) public colleges;
    mapping(uint=>address) public colId;
    
    mapping(uint=>Student) public students;
    mapping(uint=>uint) public stuId;
    
    mapping(uint => Cert) public certy;
    
    
     modifier onlyRegisteredCollege(address _addr){
        require(colleges[_addr].isregistered == true,"Not registered");
        _;
    } 
    
    modifier uniqueclg(address _addr){
        bool unique = true;
        for(uint i=1;i<=collegecnt;i++){
            if(colId[i] == _addr){
                unique = false;
                break;
            }
        
        }
        require(unique == true,"already exists");
        _;
        
    }
    
    modifier uniquestudent(uint _aadhar){
        bool unique = true;
        for(uint i=1;i<=studentcnt;i++){
            if(stuId[i] == _aadhar){
                unique = false;
                break;
            }
        
        }
        require(unique == true,"already exists");
        _;
        
    }
    
    function addCollege(string memory _clg_name)public uniqueclg(msg.sender){
        collegecnt++;
        colId[collegecnt] = msg.sender;
        colleges[msg.sender].clg_id = collegecnt;
        colleges[msg.sender].clg_name = _clg_name;
        colleges[msg.sender].clg_address = msg.sender;
        colleges[msg.sender].isregistered = false;
        emit clgAdded(collegecnt,_clg_name,now);
        
    }
    
    function registerCollege(uint _clg_id,bool _reg)public onlyOwner{
       colleges[colId[_clg_id]].isregistered = _reg;
       emit clgRegistered(_clg_id,_reg,now);
    }
    
    function addStudent(uint _cllg_id,uint _aadhar,string memory _name)public onlyRegisteredCollege(msg.sender) uniquestudent(_aadhar){
        studentcnt++;
        stuId[studentcnt]= _aadhar;
        students[_aadhar].stu_aadhar_no = _aadhar;
        students[_aadhar].stu_name = _name;
        students[_aadhar].stu_id = studentcnt;
        students[_aadhar].cllg_id = _cllg_id;
        students[_aadhar].certcount = 0;
        colleges[msg.sender].clg_student.push(studentcnt);
        emit stuAdded(studentcnt,_aadhar,_name,_cllg_id,now);
    }
    
    function addCertificate(uint _cllg_id,uint _stu_id,uint _studentaadhar,string memory _hash,string memory _name)public{ 
        certificatecnt++;
        certy[certificatecnt].cert_id = certificatecnt;
        certy[certificatecnt].stu_id = _stu_id;
        certy[certificatecnt].college_id = _cllg_id;
        certy[certificatecnt].cert_name = _name;
        certy[certificatecnt].student_aadhar = _studentaadhar;
        certy[certificatecnt].ipfs_hash = _hash;
        certy[certificatecnt].time = now;
        students[_studentaadhar].certs.push(certificatecnt);
        students[_studentaadhar].certcount++;
        emit certAdded(certificatecnt,_cllg_id,_stu_id,now);
    }
    
    function getClgStu(address _addr) public view returns(uint[] memory){
        return colleges[_addr].clg_student;
    }
    
    function getStuCert(uint _aadhar) public view returns(uint[] memory){
        return students[_aadhar].certs;
    }
    
    
}