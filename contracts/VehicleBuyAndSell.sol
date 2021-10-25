// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract VehicleBuyAndSell {

    struct Registration {
        string registration;
        address owner;
    }

    struct Offer {
        string registration;
        uint256 value;
        address from;
        address to;
        uint256 status;
        uint256 createdAt;
    }

    mapping(address => uint256) public balances;
    mapping(string => Offer) public offers;
    mapping(string => Registration) public registrationsMapping;

    constructor() {
        registrationsMapping["AAA1234"] = Registration("AAA1234", 0x92DA7b05c3E60d95Ab499F725DB12293a00b4b5A);
        registrationsMapping["BBB1234"] = Registration("BBB1234", 0x73200395B30475D32Fa6B83c304a0daE998A67A6);
        registrationsMapping["CCC9999"] = Registration("CCC9999", 0x27bA6159f7Bd347a934D31649e17CB10EbD557B4);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function saveRegistration(string memory _registration) public {
        bool canStore = compareStrings(registrationsMapping[_registration].registration, "");
        require(canStore, "the registration is already stored");
        registrationsMapping[_registration] = Registration(_registration, msg.sender);
    }

    function acceptOffer(string memory _registration, address _newOwner) public {
        require(registrationsMapping[_registration].owner == msg.sender, "only the owner can accept a registration");

        bool canAcceptAnOffer = offers[_registration].status == 1;
        require(canAcceptAnOffer, "you have an inactive offer");

        balances[msg.sender] = balances[msg.sender] + balances[_newOwner];
        balances[_newOwner] = 0;

        registrationsMapping[_registration].owner = _newOwner;
    }

    function createOffer(address _to, string memory _registration) public payable {
        require(registrationsMapping[_registration].owner == _to, "you can only send offer to the owner");

        bool canCreateAnOffer = offers[_registration].status == 0 || offers[_registration].status == 2;
        require(canCreateAnOffer, "you have already an offer active, cancel it first");

        balances[msg.sender] = msg.value;
        offers[_registration] = Offer(_registration,  msg.value, msg.sender, _to, 1, block.timestamp);
    }

    function cancelOffer(string memory _registration) payable public {
        require(offers[_registration].status == 1, "you can only cancel an active offer");
        require(offers[_registration].from == msg.sender, "you only can cancel your offer");

        offers[_registration].status = 2;
        payable(msg.sender).transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    function getOffer(string memory _registration) public view returns (Offer memory){
        return offers[_registration];
    }

    function getOwner(string memory _registration) public view returns (address){
        return registrationsMapping[_registration].owner;
    }

    function getMyBalance() public view returns (uint256){
        return balances[msg.sender];
    }

    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }
}