pragma solidity ^0.6.0;

contract Ownable{
    address payable _owner;
    
    constructor() public{
        _owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(isOwner(),"You are not the owner");
        _;
    }
    function isOwner() public view returns(bool){
        return (msg.sender == _owner);
    }
}

contract Drug is Ownable{
    uint public priceInWei;
    uint public index;
    uint public pricePaid;
    
    DrugManager parentContract;
    
    constructor(DrugManager _parentContract,uint _priceInWei, uint _index)public{
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }
   
    receive() external payable{
        require(pricePaid == 0,"Medicine is paid already");
        require(pricePaid == msg.value,"Medicine full payment required");
        pricePaid += msg.value;
        (bool success,) = address(parentContract).call.value(msg.value)(abi.encodeWithSignature("triggerPayment(uint256)",index));
        require(success,"The transaction successful");
        
    }

    
}

contract DrugManager is Ownable{
    
 enum SupplyChainSteps{Created, Paid, Delivered}

 struct Medicine {
 Drug _item;
 DrugManager.SupplyChainSteps _step;
 string _identifier;
 uint _priceInWei;
 uint mfg_date;
 uint expiry_date;
 bool authorized;
 address buyer;
 string patent;
 }
 mapping(uint => Medicine) public items;
 uint itemIndex;

 event SupplyChainStep(uint _itemIndex, uint _step, address _itemaddress);

 function createItem(string memory _identifier, uint _itemPrice) public onlyOwner{
 Drug item = new Drug(this, _itemPrice, itemIndex);
 items[itemIndex]._item = item;
 items[itemIndex]._priceInWei = _itemPrice;
 items[itemIndex]._step = SupplyChainSteps.Created;
 items[itemIndex]._identifier = _identifier;
 emit SupplyChainStep(itemIndex, uint(items[itemIndex]._step),address(item));
 itemIndex++;
 }
 
 function registermedicine(uint _itemindi) public onlyOwner{
     
 }

 function triggerPayment(uint _itemIndex) public payable {
 require(items[_itemIndex]._priceInWei <= msg.value, "Not fully paid");
 require(items[_itemIndex]._step == SupplyChainSteps.Created, "Item is further in the supply chain");
 items[_itemIndex]._step = SupplyChainSteps.Paid;
 emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._step),address(items[_itemIndex]._item));
 }

 function triggerDelivery(uint _itemIndex) public onlyOwner{
 require(items[_itemIndex]._step == SupplyChainSteps.Paid, "Item is further in the supply chain");
 items[_itemIndex]._step = SupplyChainSteps.Delivered;
 emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._step),address(items[_itemIndex]._item));
 }
     function withdraw() public onlyOwner{
        address myAddress = address(this);
        uint256 etherBalance = myAddress.balance;
        _owner.transfer(etherBalance);
    }
    
function isexpired(uint _itemindi)public {
    
}
function isauthorized(uint _itemindi)public{
    
}
function mfg(uint _itemindi)public{
    
}
function buyerofmedicine(uint _itemindi)public {
    
}

}