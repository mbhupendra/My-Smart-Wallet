pragma solidity ^0.4.22;
import "github.com/provable-things/ethereum-api/provableAPI_0.4.25.sol";

contract ExampleContract is usingProvable {

   string public lon;
   string public lat;
   event LogConstructorInitiated(string nextStep);
   event LogPriceUpdated(string price);
   event LogNewProvableQuery(string description);

   function ExampleContract() payable {
       LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Provable Query.");
   }

   function __callback(bytes32 myid, string result) {
     
       lon = result;       LogPriceUpdated(result);
   }
    function getTokenId(string memory long, string memory lati) pure public returns (uint) {
		return uint(keccak256(abi.encodePacked(long, ",", lati)));
	}
	
   function updatePrice(string a,string b) payable {
       if (provable_getPrice("URL") > this.balance) {
           LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
       } else {
           lat = string(abi.encodePacked('json(http://geo.superworldapp.com/api/json/token/get?tokenId=',a,'&blockchain=e&networkId=',b,').data.lon'));
          
           LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           provable_query("URL", lat );
          
       }
     
   }

}