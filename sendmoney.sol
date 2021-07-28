pragma solidity ^0.5.13;

contract startstop{
    
    address owner;
    
    struct Payment{
        uint amount;
        uint timestamp;
        
    }
    
    struct balance {
        uint totbalance;
        uint numpay;
        mapping(uint => Payment) payments;
    }
    mapping(address => balance)public balrec;

    constructor()public{
        owner = msg.sender;
    }
    function sendmoney()public payable{
       balrec[msg.sender].totbalance += msg.value ;
       Payment memory payment = Payment(msg.value,now);
       balrec[msg.sender].payments[balrec[msg.sender].numpay] = payment;
       balrec[msg.sender].numpay +=1;
    }
    function getBalance()public view returns(uint){
        return address(this).balance;        
    }    
    
    function withdrew (address payable too,uint amt)public {
        require(balrec[msg.sender].totbalance >=amt,"low balance");
        balrec[msg.sender].totbalance -= amt;
        too.transfer(amt);
    }
    
    function withdrawall(address payable _to)public {
        uint balsend = balrec[msg.sender].totbalance;
         balrec[msg.sender].totbalance -= balsend;
        _to.transfer(balsend);
         
    }
    
}