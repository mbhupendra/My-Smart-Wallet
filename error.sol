pragma solidity ^0.6.0;

import "./owned3.sol";



contract errorhandling is owned {
    uint public balance;
    
    function getmoney()public payable{
        if(owner != msg.sender){
            revert("Not Owner");
        }
        balance += msg.value;
    }
     
    function withdraw(uint amt)public onlyOwner {
       
        assert(balance>=amt);
        balance -= amt;
    }
}