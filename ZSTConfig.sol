// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { UtilLib } from "./utils/UtilLib.sol";
import { ZSTConstants } from "./utils/ZSTConstants.sol";
import { IZSTConfig } from "./interfaces/IZSTConfig.sol";
import { IZtakingPool } from "./interfaces/IZtakingPool.sol";

/// @title ZSTConfig
/// @notice Handles ZST configuration (e.g. supported assets)
contract ZSTConfig is IZSTConfig, AccessControlUpgradeable {
    mapping(bytes32 tokenKey => address tokenAddress) public tokenMap;
    mapping(bytes32 contractKey => address contractAddress) public contractMap;
    mapping(address token => bool isSupported) public isSupportedAsset;

    address[] public supportedAssetList;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev Reverts if the asset is not supported
    modifier onlySupportedAsset(address asset) {
        if (!isSupportedAsset[asset]) {
            revert AssetNotSupported();
        }
        _;
    }

    /// @dev Initializes the contract
    /// @param admin Admin address
    /// @param zircuitStakingAddress Zircuit Staking Contract address
    /// @param factoryAddress ZST Contract address
    /// @param depositContract Deposit Contract address
    function initialize(
        address admin, 
        address zircuitStakingAddress,
        address factoryAddress,
        address depositContract,
        address[] memory supportedAssets
    ) 
        external 
        initializer 
    {
        UtilLib.checkNonZeroAddress(admin);
        UtilLib.checkNonZeroAddress(zircuitStakingAddress);
        UtilLib.checkNonZeroAddress(factoryAddress);

        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);

        _setContract(ZSTConstants.ZIRCUIT_STAKING, zircuitStakingAddress);
        _setContract(ZSTConstants.FACTORY, factoryAddress);
        _setContract(ZSTConstants.DEPOSIT_CONTRACT, depositContract);

        uint256 length = supportedAssets.length;
        for(uint256 i; i < length; ++i){
            _addNewSupportedAsset(supportedAssets[i]);
        }
    }

    /// @dev Adds a new supported asset
    /// @param asset Asset address
    function addNewSupportedAsset(address asset) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addNewSupportedAsset(asset);
    }

    /// @dev private function to add a new supported asset
    /// @param asset Asset address
    function _addNewSupportedAsset(address asset) private {
        UtilLib.checkNonZeroAddress(asset);
        if (isSupportedAsset[asset]) {
            revert AssetAlreadySupported();
        }
        // check if Zircuit Staking Pool supports the asset
        if (!IZtakingPool(contractMap[ZSTConstants.ZIRCUIT_STAKING]).tokenAllowlist(asset)) {
            revert AssetNotSupported();
        }
        isSupportedAsset[asset] = true;
        supportedAssetList.push(asset);
        emit AddedNewSupportedAsset(asset);
    }

    /// @dev Returns the list of supported assets
    function getSupportedAssetList() external view override returns (address[] memory) {
        return supportedAssetList;
    }

    /// @dev Returns a contract using it's key
    /// @param contractKey The contract's key
    function getContract(bytes32 contractKey) public view override returns (address) {
        return contractMap[contractKey];
    }

    /// @dev Assigns a token to the token map
    /// @param tokenKey Token key
    /// @param assetAddress Address of the asset
    function setToken(bytes32 tokenKey, address assetAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setToken(tokenKey, assetAddress);
    }

    /// @dev private function to set a token
    /// @param key Token key
    /// @param val Token address
    function _setToken(bytes32 key, address val) private {
        UtilLib.checkNonZeroAddress(val);
        if (tokenMap[key] == val) {
            revert ValueAlreadyInUse();
        }
        tokenMap[key] = val;
        emit SetToken(key, val);
    }

    /// @dev Assigns a contract to the token map
    /// @param contractKey Contract key
    /// @param assetAddress Address of the contract
    function setContract(bytes32 contractKey, address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setContract(contractKey, contractAddress);
    }

    /// @dev private function to set a contract
    /// @param key Contract key
    /// @param val Contract address
    function _setContract(bytes32 key, address val) private {
        UtilLib.checkNonZeroAddress(val);
        if (contractMap[key] == val) {
            revert ValueAlreadyInUse();
        }
        contractMap[key] = val;
        emit SetContract(key, val);
    }
}