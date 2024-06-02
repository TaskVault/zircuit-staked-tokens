// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

interface IZSTConfig {
    
    // ERRORS

    error ValueAlreadyInUse();
    error AssetAlreadySupported();
    error AssetNotSupported();

    error CallerNotZSTConfigAdmin();
    error CallerNotZSTConfigManager();
    error CallerNotZSTConfigFactory();

    error CallerNotZSTConfigAllowedRole(string role);

    // EVENTS

    event SetToken(bytes32 key, address indexed tokenAddr);
    event SetContract(bytes32 key, address indexed contractAddr);
    event AddedNewSupportedAsset(address indexed asset);
    event RemovedSupportedAsset(address indexed asset);

    // FUNCTIONS

    function isSupportedAsset(address asset) external view returns (bool);
    function getContract(bytes32 contractId) external view returns (address);
    function getSupportedAssetList() external view returns (address[] memory);

}