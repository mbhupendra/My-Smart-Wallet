pragma solidity 0.6.0;

contract debugs{
    event Some(address _addr,uint _amt);
    
    
    receive() external payable{
        emit Some(msg.sender,msg.value);
    }
}