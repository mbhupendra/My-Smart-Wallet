pragma solidity 0.6.0;

contract userenums{

    enum ActionChoices{Left,right,up,down}
    ActionChoices public choice;
    
    function stchange1()public{
        choice = ActionChoices.Left;
    }
    function stchange2()public{
        choice = ActionChoices.down;
    }
    function stchange3()public{
        choice = ActionChoices.right;
    }
    
    
    
}