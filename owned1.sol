pragma solidity 0.6.0;


contract owned{
    address public owner;
    constructor()public{
        owner = msg.sender;
    }
     modifier onlyOwner(){
         require(owner == msg.sender,"U are not the owner");
         _;
    }
    
}