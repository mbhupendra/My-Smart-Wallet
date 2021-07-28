pragma solidity ^0.5.13;

contract MyContract{
   uint256 public myuint = 3;
   function setmyuint(uint _myuint) public{
       myuint = _myuint;
   }
   bool public mybool = false;
   
   function setmybool (bool _mybool) public {
       mybool = _mybool;
   }
    
    string public mystr;
    function setstr(string memory _mystr) public {
        mystr = _mystr;
    }
}