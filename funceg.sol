pragma solidity ^0.6.0;

contract functionExample{
    address payable owner;
    constructor()public{
        owner = msg.sender;
    }
    function destruct()public{
        require(owner == msg.sender,"NON-owner");
        selfdestruct(owner);
    }
    function who()public view returns(address){
        return owner;
    }
    function conver(uint amtwei)public pure returns(uint){
        return amtwei/1 ether;
    }
    mapping(address => uint) public balanceReceived;
    
    function recieveMoney()public payable {
        assert(balanceReceived[msg.sender]+ (msg.value) >= balanceReceived[msg.sender]);
        balanceReceived[msg.sender] = (msg.value);
    }
    
    function withdraw(address payable to,uint amt)public{
        require(balanceReceived[msg.sender] >= amt,"Not enough money");
        assert(balanceReceived[msg.sender] >= balanceReceived[msg.sender] - amt);
        balanceReceived[msg.sender] -= amt;
        to.transfer(amt);
        
    }
    
  receive() external payable {
  recieveMoney();
 }
}
