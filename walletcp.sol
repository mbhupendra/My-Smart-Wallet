pragma solidity ^0.6.0;

contract wallet{
    address public owner;
    bool public pause;
    constructor() public{
        owner = msg.sender;
    }
    struct Payment{
            uint amt;
            uint timestamp;
    }
    struct Balance{
        uint totbal;
        uint numpay;
        mapping(uint => Payment) payments;
    }
    mapping(address => Balance)public Balance_record;
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier whilenotpaused(){
        require(pause == false,"Sc is paused");
        _;
    }
    function change(bool ch)public onlyOwner{
        pause = ch;
    }
    
    function sendmoney()public payable whilenotpaused {
        Balance_record[msg.sender].totbal += msg.value;
        Balance_record[msg.sender].numpay+=1;
        Payment memory pay = Payment(msg.value,now);
        Balance_record[msg.sender].payments[Balance_record[msg.sender].numpay] = pay;
        
    }
    
    function getbal()public view whilenotpaused returns(uint){
        return Balance_record[msg.sender].totbal ;
    }
    
    function convert(uint amtinwei)public pure returns(uint){
        return amtinwei/1 ether;
    }
    function withdraw(uint _amt)public whilenotpaused{
        require(Balance_record[msg.sender].totbal >= _amt,"not enough funds");
        
        Balance_record[msg.sender].totbal -= _amt;
        msg.sender.transfer(_amt);
        
    }
    function destroy(address payable ender)public onlyOwner{
        selfdestruct(ender);
    }
    
}