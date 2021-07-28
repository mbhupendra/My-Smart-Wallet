pragma solidity ^0.5.11;

import "./owned.sol";


contract InheritanceModifierExample is owned {

 mapping(address => uint) public tokenBalance;

 address owner;

 uint tokenPrice = 1 ether;

 constructor() public {
 owner = msg.sender;
 tokenBalance[owner] = 100;
 }


 function createNewToken() public onlyowner {
 
 tokenBalance[owner]++;
 }

 function burnToken() public onlyowner{
 
 tokenBalance[owner]--;
 }

 function purchaseToken() public payable {
 require((tokenBalance[owner] * tokenPrice) / msg.value > 0, "not enough tokens");
 tokenBalance[owner] -= msg.value / tokenPrice;
 tokenBalance[msg.sender] += msg.value / tokenPrice;
 }

 function sendToken(address _to, uint _amount) public {
 require(tokenBalance[msg.sender] >= _amount, "Not enough tokens");
 assert(tokenBalance[_to] + _amount >= tokenBalance[_to]);
 assert(tokenBalance[msg.sender] - _amount <= tokenBalance[msg.sender]);
 tokenBalance[msg.sender] -= _amount;
 tokenBalance[_to] += _amount;
 }

}