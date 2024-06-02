// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title ZSToken
/// @notice Zircuit Staked Token that has been issued 1:1 for the user's deposit
contract ZSToken is ERC20 {

    address public immutable zstOwner;
    address public immutable factory;
    address public immutable underlyingToken;

    /// @dev Revert if msg.sender is not the owner
    modifier onlyZSTOwner() {
        require(msg.sender == zstOwner, "ZSTOKEN: UNAUTHORIZED_ACCESS");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address underlying,
        address owner
    ) 
        ERC20(name, symbol)
    {
        require(underlying != address(0), "ZSTOKEN: ZERO_ADDRESS");
        factory = msg.sender;
        underlyingToken = underlying;
        zstOwner = owner;
    }

    /// @dev Mint ZSTs
    /// @param to Recipient of the tokens
    /// @param amount Amount of tokens to be minted
    function mint(
        address to, 
        uint256 amount
    ) 
        external
        onlyZSTOwner
    {
        _mint(to, amount);
    }

    /// @dev Burn ZSTs
    /// @param from Address where the tokens are burned from
    /// @param amount Amount of tokens to be burned
    function burn(
        address from, 
        uint256 amount
    ) 
        external
        onlyZSTOwner
    {
        _burn(from, amount);
    }
}