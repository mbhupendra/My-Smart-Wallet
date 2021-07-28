pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract LandRecord{
    uint public personCount = 0;
    uint public plotCount = 0;
    uint public adminCount = 0;
    address public govtGSTAddr ;
    
    constructor(address _govt)public{
        govtGSTAddr = _govt;
    }
     
    struct Person{
        uint personId;
        uint perAadharno;
        address perAddr;
        uint[] plotsOwned;
        address[] inheritChildren;
        
    }
    
    event plotAdded(uint plotId,string plotAddr,uint price,address owner,uint times);
    event plotSale(uint plotId,bool isSelling,uint sellingPrice,uint times);
    event plotTransferred(uint plotId,address[] oldowner,address newowner,uint sellPrice,uint times);
    
    mapping(address=>Person) public people;
    mapping(uint=>address) public personIds;
    mapping(uint=>Person) public personaadhars;
    
    struct Plot{
        uint plotId;
        string plotaddr;
        uint plotprice;
        uint taxpercent;
        string typedesc;
        address[] owneraddr;
        bool isSelling;
        uint sellingPrice;
        address newowner;
        string neighbours;
        bool[] consensus;
        string imageurl;
    }
    
    mapping(uint => Plot) public Plots;
    
    struct Admin{
        uint adminId;
        uint adminaadharno;
        address adminaddr;
        string role;
    }
    
    mapping(address=>Admin) public Admins;
    mapping(uint=>address) public AdminIds;
    mapping(uint=>Admin) public Adminaadhars;
    
    function addPerson(uint _perAadharno,address[] calldata _inheritChildren) public returns(uint) {
        uint x = people[msg.sender].personId;
        if(x == 0){
            Person memory aux;
            personCount++;
            aux.personId = personCount;
            aux.perAadharno = _perAadharno;
            aux.perAddr = msg.sender;
            aux.inheritChildren = _inheritChildren;
            people[msg.sender] = aux;
            personIds[personCount] = msg.sender;
            personaadhars[_perAadharno] = aux;
            return personCount;
            
        }
        else{
            Person memory aux = people[msg.sender];
            aux.inheritChildren = _inheritChildren;
            people[msg.sender] = aux;
            return personCount;            
        }
        
    }
    
    function addAdmin(uint _adminaadharno,string memory _role) public returns(uint){
        uint x = Admins[msg.sender].adminId;
        if(x == 0){
            adminCount++;
            Admin memory aux;
            aux.adminId = adminCount;
            aux.adminaadharno = _adminaadharno;
            aux.adminaddr = msg.sender;
            aux.role = _role;
            Admins[msg.sender] = aux;
            AdminIds[adminCount] = msg.sender;
            Adminaadhars[_adminaadharno] = aux;
            return adminCount;
            
        }
        else{
            Admin memory aux = Admins[msg.sender]; 
            aux.adminaadharno = _adminaadharno;
            aux.role = _role;
            Admins[msg.sender] = aux;
            
        }
    }
    
    function addPlot(string memory _plotaddr,uint _plotprice,uint _taxpercent,string memory _typedesc,address[] memory _owneraddr,string memory _neighbours,string memory _imageurl) public returns(uint){
       plotCount++;
       Plot memory aux;
       aux.plotId = plotCount; 
       aux.plotaddr = _plotaddr;
       aux.plotprice = _plotprice;
       aux.owneraddr = _owneraddr;
       aux.taxpercent = _taxpercent;
       aux.typedesc = _typedesc;
       aux.neighbours = _neighbours;   
       aux.imageurl = _imageurl;
       Plots[plotCount] = aux;
       emit plotAdded(plotCount,_plotaddr,_plotprice,_owneraddr[0],now);
       return plotCount;
    }
    
    function putForSale(uint _plotId,uint _price)public {
        Plot memory aux = Plots[_plotId];
        aux.isSelling = true;
        aux.sellingPrice = _price;
        Plots[_plotId] = aux;
        emit plotSale(_plotId,true,_price,now);
    }
    
    function desale(uint _plotId) public {
        Plot memory aux = Plots[_plotId];
        aux.isSelling = false;
        aux.sellingPrice = 0;
        Plots[_plotId] = aux;
        emit plotSale(_plotId,false,0,now);
    }
    
    function addTax(uint _plotId,uint _taxpercent)public {
        Plot memory aux = Plots[_plotId];
        aux.taxpercent = _taxpercent;
        Plots[_plotId] = aux;
    }
    
    function buyLand(uint _plotId)public payable{
        Plot memory aux = Plots[_plotId];
        require(aux.isSelling);
        require(aux.sellingPrice <= msg.value);
        aux.newowner = msg.sender;
        Plots[_plotId] = aux;
    }
    
    function consensus(uint _plotId,bool _dec)public{
        Plots[_plotId].consensus.push(_dec);
        Plot storage aux = Plots[_plotId];
        uint participants = aux.consensus.length;
        if( participants >= ((adminCount/2)+1)){
            uint nostrue;
            for(uint i = 0; i < participants;i++){
                if(aux.consensus[i]){
                    nostrue++;
                }
            }
            if((2*nostrue)>=adminCount){
                transfer(_plotId);
            }
        }
    }
    
    function transfer(uint _plotId)public{
        Plot memory aux = Plots[_plotId];
        uint nosowner = aux.owneraddr.length;
        uint totmoney = aux.sellingPrice;
        uint newmoney = (aux.sellingPrice/nosowner);
        address newowner = aux.newowner;
        address[] memory oldowner = aux.owneraddr;
        for(uint i = 0; i < nosowner;i++){
                (payable(aux.owneraddr[i])).transfer(newmoney);
            }
        aux.plotprice = aux.sellingPrice;
        aux.isSelling = false;
        aux.sellingPrice = 0;
        aux.newowner = address(0x0);
        Plots[_plotId] = aux;
        delete Plots[_plotId].owneraddr;
        Plots[_plotId].owneraddr.push(newowner);
        plotTransferred(_plotId,oldowner,newowner,totmoney,now);
    }
    
    function expirePerson(uint _plotId)public{
        address[] storage x = Plots[_plotId].owneraddr;
        Person memory aux = people[x[0]];
        delete Plots[_plotId].owneraddr;
        Plots[_plotId].owneraddr = aux.inheritChildren;
        
    }
    
    function getowner(uint _plotId)public view returns(address[] memory){
        return Plots[_plotId].owneraddr;
    }
    
    function getconsensus(uint _plotId)public view returns(bool[] memory){
        return Plots[_plotId].consensus;
    }
}