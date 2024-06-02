// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IZSTFactory {
    
    // EVENTS
    event ZSTCreated(address indexed underlying, address indexed zstAsset, string zstName, string zstSymbol);

    // ERRORS
    error ZSTDoesNotExist();

    // GETTER FUNCTIONS
    function getZST(address asset) external view returns (address);
    function getUnderlying(address zst) external view returns (address underlying);
    function isZST(address zst) external view returns (bool);

    // ADMIN FUNCTIONS
    function createZST(address underlying) external returns (address zst);
    function pause() external;
    function unpause() external;
}