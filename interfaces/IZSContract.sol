// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IZSContract {
    
    // PUBLIC FUNCTIONS
    
    function depositETH() payable external;
    function depositAsset(address asset, uint256 amount) external;
    function withdrawAsset(address asset, uint256 amount) external;

    // ADMIN FUNCTIONS
    
    function pause() external;
    function unpause() external;
}