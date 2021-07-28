pragma solidity ^0.5.13;

contract ExceptionExample{
    mapping(address => uint64) public balanceReceived;
    
    function recieveMoney()public payable {
        assert(balanceReceived[msg.sender]+ uint64(msg.value) >= balanceReceived[msg.sender]);
        balanceReceived[msg.sender] = uint64(msg.value);
    }
    
    function withdraw(address payable to,uint64 amt)public{
        require(balanceReceived[msg.sender] >= amt,"Not enough money");
        assert(balanceReceived[msg.sender] >= balanceReceived[msg.sender] - amt);
        balanceReceived[msg.sender] -= amt;
        to.transfer(amt);
        
    }
}
