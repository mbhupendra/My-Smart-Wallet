pragma solidity 0.6.0;

contract uservar{
    uint[3] public arr;
    
    function changearr(uint y)public{
        arr[1] = y;
    }    
    
    

}