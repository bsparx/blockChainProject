// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "ERC20.sol";

/*
* @author Muddasir Javed
* @notice Blockchain Assignment Requirement 2: ERC20 and ICO
*/

contract MyERC20 is ERC20 {

    address owner;
    uint price;
    bool initialOfferingEnabled;

    /**
     * @dev Sets the values for {name} and {symbol}.
     * All two of these values are immutable: they can only be set once during
     * construction.
     */

    constructor() ERC20("MuddasirToken", "MT") {
        owner = msg.sender;
        price = 10000000000000000; //0.01 Ether, default 18 decimal 
        initialOfferingEnabled = true;
    }

    /**
     * @dev Simple view function to get price of coin
     */

    function getPrice() external view returns (uint) {
        return price;
    }

    /**
     * @dev Simple view function to get status of the coin offering
     */

    function isICOAvailable() external view returns (bool) {
        return initialOfferingEnabled;
    }

    /**
     * @dev Simple view function to get caller's balance
     */

    function getBalance() external view returns (uint) {
        return balanceOf(msg.sender);
    }

    /**
     * @dev Simple view function to check how much more allowance an appointed operator has
     * Calls back on the allowance function inside ERC20
     */

    function checkOperatorAllocation(address _appointedOperator) external view returns (uint) {
        return allowance((msg.sender), _appointedOperator);
    }

    /**
     * @dev Core functionality of the ERC20
     * Has payable modifier, meaning it can accept ethers
     */

    function mint(uint _amount) external payable {
        require(_amount > 0, "Amount should be more than 0");
        require(msg.value >= (_amount*price), "Insufficient ethers provided.");
        address payable minter = payable(msg.sender);
        _mint(minter, _amount);
    }

    /**
     * @dev Simple transfer function to allow transfer of tokens
     */

    function transferToken(address _to, uint _amount) external {
        require(_to != address(0), "Cannot send to zero address.");
        uint userBalance = balanceOf(msg.sender);
        require(userBalance >= _amount, "Insufficient funds.");
        transfer(_to, _amount);
    }
    
    /**
     * @dev Appoints address "_operator" to spend "_amount" of coins on behalf of the owner
     * Calls the ERC20's internal _approve function
     */

    function appointOperator(address _operator, uint _amount) external {
        require(msg.sender == owner, "Only owner can appoint operators.");
        _approve(msg.sender, _operator, _amount);
    }

    /**
     * @dev Core functionality of the ICO.
     * Disables the ICO sale stage
     */

    function disableICO() external {
        require(msg.sender == owner, "Only owner can call this.");
        require(initialOfferingEnabled == true, "Sale already closed.");
        initialOfferingEnabled = false;
    }

    /**
     * @dev Presale minting functionality. 
     */

    function preSaleMint(address _minter, uint _amount) external {
        require(initialOfferingEnabled == true, "Presale has been closed.");
        _mint(_minter, _amount);
    }
}