pragma solidity 0.6.0;

contract uservar{
    struct customer{
        address add;
        uint amt;
    }
    customer public fund;
    
    function change()public{
        fund.add = 0xD9AF114C7dD4bc0575EBb74bcF1d7609D5a82f28;
        fund.amt = 25;
    }
}