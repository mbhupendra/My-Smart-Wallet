pragma solidity ^0.5.0;

contract variables{
    
    uint256 public myuint = 2;
    bool public mybool;
    string public mystr;
    
    
    function changeval() public {
        mybool = true;
    }
    
    function increment()public{
        myuint++;
    }
    
    function deccrement()public{
        myuint--;
    }
    
    function setstr(string memory to)public returns(string memory){
        mystr = to;
        return(mystr);    
        
    }
}