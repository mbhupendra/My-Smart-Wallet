pragma solidity ^0.6.0;

import "https://github.com/kole-swapnil/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


//abstract contract ReceiveApprovalInterface {
//  function receiveApproval(address buyer, uint256 _value, address _coinAddress, bytes32 _data) public virtual returns (bool success);
//}


contract SuperWorldCoins is ERC20 {
    //string name = 'SuperWorldCoin';
    //string symbol = 'SUPERWORLD';
  //uint8 decimals = 18;
  uint public INITIAL_SUPPLY = 10000000000000000000000000; // 10,000,000 SUPER
    //ReceiveApprovalInterface public SuperWorldToken;
  constructor() ERC20('SuperWorldCoin','SUPERWORLD') public {
    _totalSupply = INITIAL_SUPPLY;
    _balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }


  function stringToBytes32(string memory source) pure private returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
      if (tempEmptyStringTest.length == 0) {
          return 0x0;
      }

      assembly {
          result := mload(add(source, 32))
      }
  }
  
  
 function approveAndCall(address _spender, uint256 _value) public returns (bool) {
    uint160 by = uint160(_spender);
    address payable spender = address(by);
    if (approve(spender, _value)) 
        return true;
    else
        return false;
}

/*
  function approveAndCall(address _spender, uint256 _value, bytes32 data) public returns (bool) {
    //SuperWorldToken.receiveApproval(address buyer, uint coins, address _coinAddress, bytes32 _data)
    uint160 by = uint160(_spender);
    address payable spender = address(by); 
    if (approve(spender, _value)) {
        //bytes4 x = bytes4(bytes32(keccak256("receiveApproval(msg.sender,_value,address(this),data)")));
//      if (bool(spender.call(x,msg.sender, _value, address(this), data))) {
    //    if(true){
  //      bool y = spender.call(bytes(SuperWorldToken.receiveApproval(msg.sender,_value,address(this),data)));
//check with max         //      if (_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes32)"))), msg.sender, _value, address(this), data)) {
        bool z = SuperWorldToken.receiveApproval(_spender,_value,address(this),data);  //checkfor _spender
    if (z) {
        return true;
      }
      return false;
    }
  }*/
}
