pragma solidity ^0.6.8;

import "https://github.com/kole-swapnil/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";


abstract contract ERC20Interface {
  function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);
    function balanceOf(address tokenOwner) public virtual view returns (uint balance);    //"constant" deprecated at 0.5.0 
}


contract SuperWorldToken is ERC721{

    address public owner;
    address public coinAddress;
    ERC20Interface public superWorldCoin;

    // percentage cut
    uint public percentageCut;
    uint public basePrice;
    uint public buyId = 0;
    uint public listId = 0;

    // tokenId => base price in wei
    mapping(uint => uint) public basePrices;

    // tokenId => bought price in wei
    mapping(uint => uint) public boughtPrices;

    // tokenId => sell price in wei
    mapping(uint => uint) public sellPrices;

    // tokenId => is selling
    mapping(uint => bool) public isSellings;
//added    //tokenOwner
//    mapping(uint => address)public _tokenOwners;
    // tokenId => buyId
    mapping(uint => uint) public buyIds;

    // token history
    struct TokenHistory {
        uint tokenId;
        address owner;
        uint price;
    }
    // tokenId => token history array
    mapping(uint => TokenHistory[]) public tokenHistories;

    // events
    // TODO: add timestamp (block or UTC)
    event EventBuyToken(uint buyId, string lon, string lat, address indexed buyer, address indexed seller, uint price, uint timestamp);
    event EventBuyTokenFail(uint buyId, string lon, string lat, address indexed buyer, address indexed seller, uint price, uint timestamp);
    event EventBuyTokenId1(uint buyId, uint indexed tokenId1, string lon, string lat, address buyer, address seller, uint price, uint timestamp);
    event EventListToken(uint listId, uint buyId, string lon, string lat, address indexed seller, uint price, bool isListed, uint timestamp);
    event EventListTokenId1(uint listId, uint buyId, uint indexed tokenId1, string lon, string lat, address seller, uint price, bool isListed, uint timestamp);
    event EventReceiveApproval(address buyer, uint coins, address _coinAddress, bytes32 _data);


    constructor(address _coinAddress, uint _percentageCut, uint _basePrice)
    public
    ERC721("SuperWorld", "SUPERWORLD") {
        owner = msg.sender;
        coinAddress = _coinAddress;
        superWorldCoin = ERC20Interface(coinAddress);
        percentageCut = _percentageCut;
        basePrice = _basePrice;
        buyId = 0;
        listId = 0;
    }


    function setBasePrice(uint _basePrice) public {
        require(msg.sender == owner);
        require(_basePrice > 0);
        basePrice = _basePrice;
    }

//changed
    function setBasePrice(string memory lon, string memory lat, uint _basePrice) public {
        require(msg.sender == owner);
        require(_basePrice > 0);
        uint tokenId = getTokenId(lon, lat);
        basePrices[tokenId] = _basePrice;
    }


    function setPercentageCut(uint _percentageCut) public {
        require(msg.sender == owner);
        require(_percentageCut > 0);
        percentageCut = _percentageCut;
    }


    function createToken(address buyer, uint tokenId, uint256 price) private {
        _mint(buyer, tokenId);
        recordTransaction(tokenId, price);
    }


    function recordTransaction(uint tokenId, uint256 price) private {
        boughtPrices[tokenId] = price;
        tokenHistories[tokenId].push(TokenHistory(tokenId, msg.sender, price));
    }

//changed
    function getTokenId(string memory lon, string memory lat) pure public returns (uint) {
        return uint(keccak256(abi.encodePacked(lon, ",", lat)));
    }

//changed
    // getInfo: tokenId, tokenOwner, isOwned, isSelling, price
    function getInfo(string memory lon, string memory lat) view public returns (uint, address, bool, bool, uint) {
        uint tokenId = getTokenId(lon, lat);
        address tokenowner = EnumerableMap.get(_tokenOwners,tokenId);              //address _tokenOwner = tokenOwner[tokenId];              
        bool isOwned = tokenowner != address(0);   //bool isOwned = tokenowner != 0x0;
        bool isSelling = isSellings[tokenId];
        uint price = getPrice(tokenId);
        return (tokenId, tokenowner, isOwned, isSelling, price);
    }

    function receiveApproval(address buyer, uint coins, address _coinAddress, bytes32 _data) public {
        emit EventReceiveApproval(buyer, coins, _coinAddress, _data);
        require(_coinAddress == coinAddress);
        string memory dataString = bytes32ToString(_data);
        buyTokenWithCoins(buyer, coins, getLon(dataString), getLat(dataString));
    }

//changed
    function buyTokenWithCoins(address buyer, uint coins, string memory lon, string memory lat) public returns (bool) {
        uint tokenId = getTokenId(lon, lat);
        address seller = EnumerableMap.get(_tokenOwners,tokenId)  ;              //_tokenOwners[tokenId];

        // unique token not bought yet
        if (seller == address(0x0)) {
            require(coins >= basePrice);
            require(superWorldCoin.balanceOf(buyer) >= basePrice);
            if (!superWorldCoin.transferFrom(buyer, address(this), basePrice)) {
                return false;
            }
            createToken(buyer, tokenId, basePrice);
            emitBuyTokenEvents(tokenId, lon, lat, buyer, seller, basePrice, now);
            return true;
        }

        return false;
    }

//changed
    // buy token; returns isSuccess
    function buyToken(string memory lon, string memory lat) payable public returns (bool) {
        uint tokenId = getTokenId(lon, lat);
        uint offerPrice = msg.value;
        address seller = (EnumerableMap.get(_tokenOwners,tokenId))  ;   // _tokenOwners[tokenId];

        // unique token not bought yet
        if (seller == address(0x0)) {
            require(offerPrice >= basePrice);
            require(offerPrice >= basePrices[tokenId]);
            createToken(msg.sender, tokenId, offerPrice);
            emitBuyTokenEvents(tokenId, lon, lat, msg.sender, seller, offerPrice, now);
            return true;
        }

        // check selling
        require(isSellings[tokenId] == true);
        // check sell price > 0
        require(sellPrices[tokenId] > 0);
        // check offer price >= sell price
        require(offerPrice >= sellPrices[tokenId]);

        // send percentage of cut to contract owner
        uint fee = SafeMath.div(SafeMath.mul(offerPrice, percentageCut), 100);
        uint priceAfterFee = SafeMath.sub(offerPrice, fee);

        // mark not selling
        isSellings[tokenId] = false;

        // send payment
        uint160 by = uint160(seller);
        address payable _seller = address(by);
        if (!_seller.send(priceAfterFee)) {
                // if failed to send, mark selling
                isSellings[tokenId] = true;
                emit EventBuyTokenFail(tokenId, lon, lat, msg.sender, seller, offerPrice, now);
                return false;
        }

        // transfer token
        //removeTokenFrom(seller, tokenId);
        //addTokenTo(msg.sender, tokenId);
        _holderTokens[seller].remove(tokenId);
        _holderTokens[msg.sender].add(tokenId);
        recordTransaction(tokenId, offerPrice);
        sellPrices[tokenId] = offerPrice;
        emitBuyTokenEvents(tokenId, lon, lat, msg.sender, seller, offerPrice, now);
        return true;
    }

//changed
    function emitBuyTokenEvents(uint tokenId, string memory lon, string memory lat, address buyer, address seller, uint offerPrice, uint timestamp) private {
        buyId++;
        buyIds[tokenId] = buyId;
        emit EventBuyToken(buyId, lon, lat, buyer, seller, offerPrice, timestamp);
        emit EventBuyTokenId1(buyId, getTokenId(truncateDecimals(lon, 1), truncateDecimals(lat, 1)), lon, lat, buyer, seller, offerPrice, timestamp);
    }

    // list / delist
//changed
    function listToken(string memory lon, string memory lat, uint sellPrice) public {
        uint tokenId = getTokenId(lon, lat);
        require(msg.sender == EnumerableMap.get(_tokenOwners,tokenId));
        isSellings[tokenId] = true;
        sellPrices[tokenId] = sellPrice;
        emitListTokenEvents(buyIds[tokenId], lon, lat, msg.sender, sellPrice, true, now);
    }

//changed
    function delistToken(string memory lon, string memory lat) public {
        uint tokenId = getTokenId(lon, lat);
        require(msg.sender == EnumerableMap.get(_tokenOwners,tokenId));
        isSellings[tokenId] = false;
        emitListTokenEvents(buyIds[tokenId], lon, lat, msg.sender, sellPrices[tokenId], false, now);
        sellPrices[tokenId] = 0;
    }

//changed
    function emitListTokenEvents(uint _buyId, string memory lon, string memory lat, address seller, uint sellPrice, bool isListed, uint timestamp) private {
        listId++;
        emit EventListToken(listId, _buyId, lon, lat, seller, sellPrice, isListed, timestamp);
        emit EventListTokenId1(listId, _buyId, getTokenId(truncateDecimals(lon, 1), truncateDecimals(lat, 1)), lon, lat, seller, sellPrice, isListed, timestamp);
    }


    function getPrice(uint tokenId) view public returns (uint) {
        if (EnumerableMap.get(_tokenOwners,tokenId) == address(0)) {
            // not owned
            uint _basePrice = basePrices[tokenId];
            if (_basePrice == 0) {
                return basePrice;
            }
            else {
                return _basePrice;
            }
        }
        else {
            // owned
            if (isSellings[tokenId]) {
                return sellPrices[tokenId];
            }
            else {
                return boughtPrices[tokenId];
            }
        }
    }

//changed
    function truncateDecimals(string memory str, uint decimal) pure public returns (string memory) {
    bytes memory strBytes = bytes(str);
        uint length = strBytes.length;
        uint endIndex = length - 1;
        uint i;
    for (i = 0; i < length; i++) {
      if (strBytes[i] == ".") {
                endIndex = i;
            }
            if (i == endIndex + decimal + 1) {
                break;
            }
    }
        if (i >= length) {
            return str;
        }
        return substring(str, 0, i);
    }

//changed
    function substring(string memory str, uint startIndex, uint endIndex) pure private returns (string memory) {
    bytes memory strBytes = bytes(str);
        if (endIndex == 0) {
            endIndex = strBytes.length;
        }
    bytes memory result = new bytes(endIndex - startIndex);
    for (uint i = startIndex; i < endIndex; i++) {
      result[i - startIndex] = strBytes[i];
    }
    return string(result);
    }
//changed

    function indexOfComma(string memory str) pure private returns (uint) {
        bytes memory strBytes = bytes(str);
        uint length = strBytes.length;
        for (uint i = 0; i < length; i++) {
            if (strBytes[i] == ",") {
                return i;
            }
        }
        return 0;
    }

//changed
    function getLon(string memory str) pure private returns (string memory) {
        uint index = indexOfComma(str);
        return substring(str, 0, index);
    }

//changed
    function getLat(string memory str) pure private returns (string memory) {
        uint index = indexOfComma(str);
        return substring(str, index + 1, 0);
    }

//changed
    function bytesToString(bytes memory _dataBytes) pure private returns (string memory) {
        if (_dataBytes.length == 0) {
            return "";
        }

        bytes32 dataBytes32;

        assembly {
            dataBytes32 := mload(add(_dataBytes, 32))
        }
        return bytes32ToString(dataBytes32);
    }

//changed
    function bytes32ToString(bytes32 _dataBytes32) pure private returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        uint j;
        for (j = 0; j < 32; j++) {                 //outscope declaration
                byte char = byte(bytes32(uint(_dataBytes32) * 2 ** (8 * j)));
                if (char != 0) {
                        bytesString[charCount] = char;
                        charCount++;
                }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
                bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    

    function withdrawBalance() public payable  {
        require(msg.sender == owner);
        uint balance = address(this).balance;
        uint160 by = uint160(msg.sender);
        address payable _by = address(by);
        _by.transfer(balance);
        
        //address(msg.sender).transfer(balance);
    }
}
