pragma solidity ^0.6.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract allowallet is Ownable{
    using SafeMath for uint;
    uint public balance = 0 ;
    uint temp;
    mapping(address => uint) public allow;
    constructor()public{
        
    }
    event allowchanged(address indexed who,uint old,uint news);   
    function getmoney()public payable{
        balance = balance.add(msg.value);
    }
    event moneysent(address indexed bene,address indexed sendi,uint am);
    event got(address indexed sendi,uint am);
     modifier isallowed(uint amt){
        require(amt <= allow[msg.sender],"Not allowed");
        _;
    }
    
    function changeallow(address payable to,uint no)public onlyOwner{
        temp = allow[to];
        allow[to] = no;
        emit allowchanged(to,temp,no);
        
    }

    
    function withdraw(address payable to,uint amt)public onlyOwner {
        require(balance >= amt,"Not enough funds");
        balance = balance.sub(amt);
        to.transfer(amt);
        emit moneysent(to,msg.sender,amt);
        
    }
    function withdrawallow(address payable to,uint amt)public isallowed(amt){
        require(balance >= amt,"Not enough funds");
        balance = balance.sub(amt);
        allow[to] = balance.sub(amt);
        to.transfer(amt);
        
    }
    
    receive()external payable{
        getmoney();
        emit got(msg.sender,msg.value);
    }
    
   
}