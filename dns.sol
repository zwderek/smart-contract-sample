pragma solidity ^0.5.0;

contract Dns {
    struct NameEntry {
        address owner;
        string value;
        bool isUsed; //is the name occupied
        uint price; //price set by owner
    }
    uint256 MAX_INT = uint256(-1);
    uint32 constant REGISTRATION_COST = 100;
    uint32 constant UPDATE_COST = 10;
    uint32 constant SETPRICE_COST = 5;
    
    mapping(bytes32 => NameEntry) data;
    
    function nameNew(string memory name, string memory IP) public payable {
        if (msg.value >= REGISTRATION_COST) {
            bytes32 hash = keccak256(abi.encodePacked(name));
            if (data[hash].isUsed == false) { //the name is not occupied
                data[hash].isUsed = true;
                data[hash].owner = msg.sender;
                data[hash].value = IP;
                data[hash].price = MAX_INT; //initialize the price
            }
        }
    }
    
    function nameUpdate(string memory name, string memory newIP) public payable {
        bytes32 hash = keccak256(abi.encodePacked(name));
        if (data[hash].owner == msg.sender && msg.value >= UPDATE_COST) {
            data[hash].value = newIP;
        }
    }

    function nameLookup(string memory name) public view returns (string memory) {
        return data[keccak256(abi.encodePacked(name))].value;
    }

    //only the owner can set the price, and the cost is 5
    function setPrice(string memory name, uint new_price) public payable { 
        bytes32 hash = keccak256(abi.encodePacked(name));
        require(data[hash].owner == msg.sender, "No permission to set price for this name");
        if (msg.value >= SETPRICE_COST) {
            data[hash].price = new_price;
        }
    }

    //every one can querry the price of a name
    function priceLookup(string memory name) public view returns (uint) { 
        uint _price = data[keccak256(abi.encodePacked(name))].price;
        require(_price < MAX_INT, "Not for sale");
        return _price;
    }

    //one can purchase the name iff he gives an acceptable price, 
    //and the owner will recieve the money
    function purchase(string memory name) public payable { //
        bytes32 hash = keccak256(abi.encodePacked(name));
        require(msg.value >= data[hash].price, "Insufficient amount");
        data[hash].owner = msg.sender;
        msg.sender.transfer(data[hash].price);
    }

    //help to cheack if the user has the ownership or not
    function checkOwnership(string memory name) public view returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(name));
        if(data[hash].owner == msg.sender) {
            return true;
        } else {
            return false;
        }
    }
}