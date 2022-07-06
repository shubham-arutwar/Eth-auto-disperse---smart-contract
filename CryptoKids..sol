 // SPDX-License-Identifier: Unlicensed

 pragma solidity ^0.8.7;

 contract CryptoKids {
    // owner DAD
    address owner;

    constructor(){
        owner = msg.sender;
    }

    // define Kid
    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint ammount;
        bool canWithdraw;
    }

    Kid[] public kids;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // add kid to contract
    function addKid(address payable walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint ammount, bool canWithdraw) public onlyOwner {
        kids.push(Kid(
            walletAddress,
            firstName,
            lastName,
            releaseTime,
            ammount,
            canWithdraw
        ));
    }

    function balanceOf() public view returns(uint){
        return address(this).balance;
    }

    // diposit funds to contract, to kids account
    function diposit(address walletAddress) payable public {
        addToKidsBalance(walletAddress);
    }
    
    function addToKidsBalance(address walletAddress) private {
        for(uint i = 0; i < kids.length; i++){
            if(kids[i].walletAddress == walletAddress) {
                kids[i].ammount += msg.value;
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint){
        for(uint i = 0; i < kids.length; i++){
            if(kids[i].walletAddress == walletAddress){
                return i;
            }
        }
        return 999; 
    }

    // kid check if able to withdraw
    function availableToWithdraw(address walletAddress) public returns(bool){
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].releaseTime, "you canot withdraw yet");
        if (block.timestamp > kids[i].releaseTime){
            kids[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // withdraw money
    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress, "you must be kid to withdraw");
        require(kids[i].canWithdraw == true, "you are not able to withdraw at this time");
        kids[i].walletAddress.transfer(kids[i].ammount);
    }
 }