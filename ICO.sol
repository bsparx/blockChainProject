// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "MyERC20.sol";

/*
* @author Muddasir Javed
* @notice Blockchain Assignment Requirement 2: ERC20 and ICO
*/

contract InitialCoinOffering { 

    uint public maxMintable;
    uint public totalMinted;
    uint public endBlock;
    uint public startBlock;
    uint public exchangeRate;
    bool public isFunding;
    MyERC20 public Token;
    address public creator;

    mapping (address => uint256) public heldTokens;

    event Contribution(address from, uint256 amount);

    /**
     * @dev Sets the values for {_myTokenAddress}
     * This value is set during construction. This is the ERC20 contract on which the ICO is run.
     */

    constructor(address _myTokenAddress) {
        maxMintable = 100000;
        totalMinted = 0;
        endBlock = block.timestamp + 10 weeks;
        startBlock = block.timestamp;
        Token = MyERC20(_myTokenAddress);
        exchangeRate = 99; 
        creator = msg.sender;
    }

    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }

    /**
     * @dev Allows the current creator to close the sale
     */

    function closeSale(address _creator) internal {
      require(_creator==creator);
      isFunding = false;
      Token.disableICO();
    }

    /**
     * @dev Core functionality of the ICO.
     * Allows receiving of ethers with payable modifier
     */

    function mint(uint _amount) public payable {
        require(msg.value>0, "Amount should be more than 0");
        require(isFunding, "ICO disabled.");
        require(block.number <= endBlock, "ICO Time has ended.");
        require(msg.value >= _amount*exchangeRate, "Insufficient funds for provided amount.");
        uint256 total = totalMinted + _amount;
        require(total<=maxMintable, "Max amount exceeding.");
        totalMinted += total;
        Token.preSaleMint(msg.sender, _amount);
        heldTokens[msg.sender] = _amount;
        emit Contribution(msg.sender, _amount);
    }

    /**
     * @dev Function that is hit when money is sent using address.send() or address.transfer()
     * Mentioned as a recommended addition when receiving ethers
     * Reference used: https://soliditylang.org/blog/2020/03/23/fallback-receive-split/
     */

    receive() external payable {
        revert();
    }

    /**
     * @dev Fallback function that is hit when no other function matches
     * Mentioned as a recommended addition when receiving ethers
     * Reference used: https://soliditylang.org/blog/2020/03/23/fallback-receive-split/
     */

    fallback() external payable {
        require(msg.value>0, "Amount should be more than 0");
        require(isFunding, "ICO disabled.");
        require(block.number <= endBlock, "ICO Time has ended.");
        uint256 amount = msg.value * exchangeRate/100;
        uint256 total = totalMinted + amount;
        require(total<=maxMintable);
        totalMinted += total;
        Token.preSaleMint(msg.sender, amount);
        heldTokens[msg.sender] = amount;
        emit Contribution(msg.sender, amount);
    }

    /**
     * @dev Allows the current creator to update the exchange rate
     */

    function updateRate(uint256 rate) external onlyCreator {
        require(isFunding);
        exchangeRate = rate;
    }

    /**
     * @dev Allows the current creator to give ownership to a new address
     */

    function changeCreator(address _creator) external onlyCreator {
        creator = _creator;
    }

    /**
     * @dev Simple view function to check tokens held by address "_address"
     */

    function getHeldCoin(address _address) public view returns (uint256) {
        return heldTokens[_address];
    }

    /**
     * @dev Allows the creator of the ICO to withdraw funds collected
     */

    function withdraw() external onlyCreator {
        require (block.timestamp >= endBlock, "ICO is still running.");
        uint contractWorth = address(this).balance;
        (bool success, ) = creator.call{value : contractWorth}("");
        require(success, "Unsuccessful withdrawal.");
        closeSale(msg.sender);
    }

}