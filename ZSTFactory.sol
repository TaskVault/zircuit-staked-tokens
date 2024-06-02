// SPDX-License-Identifier: MIT 
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import {ZSTConfigRoleChecker, IZSTConfig, ZSTConstants} from "./utils/ZSTConfigRoleChecker.sol";
import {ZSToken} from "./ZSToken.sol";
import {UtilLib} from "./utils/UtilLib.sol";
import {IZSTFactory} from "./interfaces/IZSTFactory.sol";
import {StringLib} from "./libraries/StringLib.sol";

/// @title ZSTFactory
/// @notice Issuer of Zircuit Staked Tokens (liquid wrappers) in exchange for user deposits
contract ZSTFactory is IZSTFactory, ZSTConfigRoleChecker, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using StringLib for string;

    string private constant SYMBOL_PREFIX = "zs";
    string private constant NAME_PREFIX = "Zircuit Staked ";

    mapping(address => address) public getZST;
    mapping(address => address) public getUnderlying;
    mapping(address => bool) public isZST;

    address public depositContract;
    address[] public allZSTs;

    event WrapperCreated(address indexed underlying, address indexed zst);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev Initializes the contract
    /// @param zstConfigAddress ZST config address
    function initialize(address zstConfigAddress) external initializer {
        UtilLib.checkNonZeroAddress(zstConfigAddress);
        __Pausable_init();
        __ReentrancyGuard_init();

        zstConfig = IZSTConfig(zstConfigAddress);
        depositContract = zstConfig.getContract(ZSTConstants.DEPOSIT_CONTRACT);
        emit UpdatedZSTConfig(zstConfigAddress);
    }

    /// @dev Creates a liquid wrapper token using the underlying asset
    /// @param underlying Token that a liquid wrapper will be issued for
    function createZST(
        address underlying
    ) 
        external
        onlyZSTAdmin
        onlySupportedAsset(underlying)
    returns (
        address zst
    ) {
        require(underlying != address(0), "ZSTFACTORY: ZERO_ADDRESS");
        require(getZST[underlying] == address(0), "ZSTFACTORY: WRAPPER_EXISTS");

        string memory baseSymbol;
        string memory baseName;
        string memory name;
        string memory symbol;

        if (ZSTConstants.WETH_TOKEN == underlying) {
            baseName = "Wrapped Ethereum";
            baseSymbol = "WETH";
        } else {
            baseName = ERC20(underlying).name();
            baseSymbol = ERC20(underlying).symbol();
        }

        name = concatenate(NAME_PREFIX, baseName);
        symbol = concatenate(SYMBOL_PREFIX, baseSymbol);

        zst = _createZST(name, symbol, underlying);
        getZST[underlying] = zst;
        getUnderlying[zst] = underlying;
        isZST[zst] = true;
        allZSTs.push(zst);
        emit ZSTCreated(underlying, zst, name, symbol);
    }

    /// @dev Deploys the liquid wrapper token
    /// @param name Name used for the liquid wrapper token
    /// @param symbol Symbol used for the liquid wrapper token
    /// @param underlying Address of the underlying token
    function _createZST(
        string memory name, 
        string memory symbol,
        address underlying
    ) 
        internal 
        returns (
            address zst
        ) 
    {
        // deploy token
        zst = address(new ZSToken(name, symbol, underlying, depositContract));
    }

    /// @dev Used to concatenate strings
    /// @param a String prefix
    /// @param b String base
    function concatenate(
        string memory a, 
        string memory b
    ) 
        public 
        pure 
        returns (string memory c)
    {
        c = string(abi.encodePacked(a, b));
    }

    /// @dev Triggers stopped state.
    /// @dev Only callable by ZST config manager. Contract must NOT be paused.
    function pause() external onlyZSTAdmin {
        _pause();
    }

    /// @dev Triggers stopped state.
    /// @dev Only callable by ZST config manager. Contract must NOT be paused.
    function unpause() external onlyZSTAdmin {
        _unpause();
    }
}