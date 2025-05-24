// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
* @author Muddasir Javed
* @notice Blockchain Assignment Requirement 1: Auction
*/

contract Auction {

    address owner;
    address highestBidder;
    uint startTime;
    uint endTime;
    uint minBid;
    uint highestBindingBid;
    uint increment;
    bool isRunning;
    mapping (address => uint) bids;

    /**
     * @dev Sets the values for {_startTime} and {_minBid}.
     * All two of these values are immutable: they can only be set once during
     * construction.
     */

    constructor(uint _startTime, uint _minBid) {
        owner = msg.sender;
        startTime = _startTime;
        minBid = _minBid;
        increment = 10;
        highestBindingBid = 0;
        endTime = _startTime + 2 weeks;
        isRunning = true;
    }

    /** 
     * @dev View function to get address of the owner.
     * The owner is the person who starts the auction and has the ability to end it 
     */

    function getOwner() external view returns (address) {
        return owner;
    }

    /** 
     * @dev View function to get address of the the current highest bidder.
     */

    function getHighestBidder() external view returns (address) {
        return highestBidder;
    }

    /** 
     * @dev Core functionality of the auction contract
     * Requires auction to be running (it should not have ended) and the time of ending must not be met.
     * Requires bidder to have the amount in their wallet that they want to bid (previous bid + the increment value)
     * Handles bidders in the mapping and updates highest bidder
     */

    function placeBid() external payable {
        require(block.timestamp < endTime && isRunning, "Auction already ended.");
        require(msg.value > minBid, "Minimum amount of bid not satisfied.");
        if (highestBindingBid == 0) { //First ever bid becomes the highest bid
            highestBidder = msg.sender;
            highestBindingBid = msg.value;
        } else {
            uint percentage = highestBindingBid * increment/100; //Increment is 10% of highest bid
            require(msg.value >= (highestBindingBid+percentage),"Bid is not high enough");        
                highestBindingBid =msg.value;
                highestBidder = msg.sender;
                bids[msg.sender] += msg.value;
        }
    }

    /** 
     * @dev Core functionality of the auction contract
     * It can only be called by the owner (i.e., the person who deployed the contract)
     * Requires success on address.call{}() to call off the auction
     */

    function endAuction() external {
        require(msg.sender == owner, "Caller is not the owner.");
        (bool success, ) = owner.call{value: highestBindingBid}(""); 
        require(success, "Failed to transfer upon end of Auction.");
        bids[highestBidder] -= highestBindingBid; //We deduct highestBid + Incentive, not all the msg.value
        isRunning = false;
    }

    /** 
     * @dev Core functionality of the auction contract
     * Requires the contract to be running (it should not have ended).
     * Requires the caller to have participated in the auction or have more than 0 in balance
     * After the bid amount is successfully withdrawn, the mapping is updated so repeated withdrawal is not possible.
     */
    
    function withdraw() external {
        require(!isRunning, "Cannot withdraw while Auction is running.");
        require(bids[msg.sender] > 0, "Caller has no money to withdraw.");
        uint amountHeld = bids[msg.sender];
        (bool success, ) = msg.sender.call{value: amountHeld}("");
        require(success, "Failed to withdraw post-auction amount.");
        bids[msg.sender] = 0;
    }
}