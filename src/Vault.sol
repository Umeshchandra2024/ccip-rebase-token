// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {IRebaseToken} from "./interfaces/IRebaseToken.sol";


contract Vault {
    // Change the type from 'address' to 'IRebaseToken'
    IRebaseToken private immutable i_rebaseToken;

    event Deposit(address indexed user, uint256 amount);  // indexed is for more efficient to query for searching for offchain applications like frontend
    event Redeem(address indexed user, uint256 amount);

    error Vault_RedeemFailed();
    error Vault_DepositAmountIsZero(); // Added for deposit check

    
    // Change the constructor parameter type to 'IRebaseToken'
    constructor(IRebaseToken _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

    /**
     * @notice Fallback function to accept ETH rewards sent directly to the contract.
     */

    receive() external payable {}

    /**
     * @notice Allows a user to deposit ETH and receive an equivalent amount of RebaseTokens.
     */

    function deposit() external payable {
        uint256 amountToMint = msg.value;
        if(amountToMint == 0) {
            revert  Vault_DepositAmountIsZero();
        }
        // This call is now valid because the compiler knows i_rebaseToken conforms to IRebaseToken
        uint256 interestRate = i_rebaseToken.getInterestRate();
        i_rebaseToken.mint(msg.sender, amountToMint, interestRate);
        emit Deposit(msg.sender, amountToMint);
    }

    /**
     * @notice Allows a user to burn their RebaseTokens and receive a corresponding amount of ETH.
     * @param _amount The amount of RebaseTokens to redeem.
     * @dev Follows Checks-Effects-Interactions pattern. Uses low-level .call for ETH transfer.
     */
    function redeem(uint256 _amount) external {
        if(_amount == type(uint256).max) {
            _amount = i_rebaseToken.balanceOf(msg.sender);
        }
        // 1. Effects (State changes occur first)
        // Burn the specified amount of tokens from the caller (msg.sender)
        // The RebaseToken's burn function should handle checks for sufficient balance.
        i_rebaseToken.burn(msg.sender, _amount);

        // 2. Interactions (External calls / ETH transfer last)
        // Send the equivalent amount of ETH back to the user
        (bool success,)= payable(msg.sender).call{value: _amount}("");

        // Check if the ETH transfer succeeded
        if(!success) {
            revert Vault_RedeemFailed(); // Use the custom error
        }

        // Emit an event logging the redemption
        emit Redeem(msg.sender, _amount);

    }

    function getRebaseTokenAddress() external view returns(address) {
        return address(i_rebaseToken);
    }
}