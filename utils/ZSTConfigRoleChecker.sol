// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import { UtilLib } from "./UtilLib.sol";
import { ZSTConstants } from "./ZSTConstants.sol";

import { IZSTConfig } from "../interfaces/IZSTConfig.sol";
import { IZtakingPool } from "../interfaces/IZtakingPool.sol";

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

abstract contract ZSTConfigRoleChecker {
    
    IZSTConfig public zstConfig;

    // EVENTS
    event UpdatedZSTConfig(address indexed zstConfig);

    // MODIFIERS
    modifier onlyRole(bytes32 role) {
        if (!IAccessControl(address(zstConfig)).hasRole(role, msg.sender)) {
            string memory roleString = string(abi.encodePacked(role));
            revert IZSTConfig.CallerNotZSTConfigAllowedRole(roleString);
        }
        _;
    }

    modifier onlyZSTAdmin() {
        if (!IAccessControl(address(zstConfig)).hasRole(ZSTConstants.DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert IZSTConfig.CallerNotZSTConfigAdmin();
        }
        _;
    }

    modifier onlySupportedAsset(address asset) {
        if (!zstConfig.isSupportedAsset(asset)) {
            revert IZSTConfig.AssetNotSupported();
        }
        _;
    }

    // SETTERS

    /// @notice Updates the ZST config contract
    /// @dev only callable by ZST admin
    /// @param zstConfigAddr the new ZS config contract Address
    function updateZSTConfig(address zstConfigAddr) external virtual onlyZSTAdmin {
        if (address(zstConfig) != address(0)) revert IZSTConfig.ValueAlreadyInUse();

        UtilLib.checkNonZeroAddress(zstConfigAddr);
        zstConfig = IZSTConfig(zstConfigAddr);
        emit UpdatedZSTConfig(zstConfigAddr);
    }
}