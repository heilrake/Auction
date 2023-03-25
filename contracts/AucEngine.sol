// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract AucEngine {
    address public owner;
    uint constant DURATION = 2 days;
    uint constant FEE = 10; //10%

    struct Auction {
        address payable seller;
        uint startingPrice;
        uint finalPrice;
        uint startAt;
        uint endsAt;
        uint discountRate;
        string item;
        bool stopped;
    }

    Auction[] public auctions;

    constructor() {
        owner = msg.sender; 
    }

    function createAuction() external {
        
    }
}
