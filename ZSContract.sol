// SPDX-License-Identifier: MIT 
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import {ZSTConfigRoleChecker, IZSTConfig, ZSTConstants} from "./utils/ZSTConfigRoleChecker.sol";
import {UtilLib} from "./utils/UtilLib.sol";

import {IZSTFactory} from "./interfaces/IZSTFactory.sol";
import {IZtakingPool} from "./interfaces/IZtakingPool.sol";
import {IZSToken} from "./interfaces/IZSToken.sol";
import {IZSContract} from "./interfaces/IZSContract.sol";

///@title ZSContract
///@notice Deposits assets to the Zircuit Staking Pool and issues liquid wrapper tokens in exchange
contract ZSContract is IZSContract, ZSTConfigRoleChecker, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20 for IERC20;

    /// @dev Zircuit Staking Contract
    address public zircuitStaking;
    /// @dev Factory Contract issuing wrapper tokens
    address public factory;

    /// @dev All deposits made to the staking contract for each asset
    mapping(address => uint256) public assetsDeposited;
    mapping(address => mapping(address => uint256)) public zstBalances;

    /// @dev Revert if Zircuit Staking Token does not exist
    modifier onlyExistingZST(address zst) {
        if (!IZSTFactory(factory).isZST(zst)) {
            revert IZSTFactory.ZSTDoesNotExist();
        }
        _;
    }

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
        zircuitStaking = zstConfig.getContract(ZSTConstants.ZIRCUIT_STAKING);
        factory = zstConfig.getContract(ZSTConstants.FACTORY);
        emit UpdatedZSTConfig(zstConfigAddress);
    }

    /// @dev Approve tokens for the Zircuit Staking Contract
    function maxApproveToZircuitStakingContract(
        address asset
    )
        external
        onlyZSTAdmin
        onlySupportedAsset(asset)
    {
        UtilLib.checkNonZeroAddress(asset);
        IERC20(asset).approve(zircuitStaking, type(uint256).max);
    }

    /// @dev Deposit ETH to the Zircuit Staking Contract and mint liquid wrapper
    function depositETH() payable external {
        require(msg.value > 0, "DEPOSIT_CONTRACT: ZERO_DEPOSIT_AMOUNT");
        assetsDeposited[ZSTConstants.WETH_TOKEN] += msg.value;
        IZtakingPool(zircuitStaking).depositETHFor{ value: msg.value }(address(this));
        _mintZST(msg.sender, ZSTConstants.WETH_TOKEN, msg.value);
    }

    /// @dev Deposit ERC20 tokens to the Zircuit Staking Contract and mint liquid wrapper
    /// @param asset Token deposited by the user
    function depositAsset(
        address asset, 
        uint256 amount
    ) 
        external 
        onlySupportedAsset(asset) 
    {
        require(amount > 0, "DEPOSIT_CONTRACT: ZERO_DEPOSIT_AMOUNT");
        assetsDeposited[asset] += amount;
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        IZtakingPool(zircuitStaking).depositFor(asset, address(this), amount);
        _mintZST(msg.sender, asset, amount);
    }

    /// @dev Withdraw ERC20 tokens from the Zircuit Staking Contract and burn liquid wrapper
    /// @param zst Liquid wrapper token sent to redeem underlying asset
    /// @param amount Amount of tokens being redeemed
    function withdrawAsset(
        address zst,
        uint256 amount
    )
        external
        onlyExistingZST(zst)
    {
        UtilLib.checkNonZeroAddress(zst);
        require(amount > 0, "DEPOSIT_CONTRACT: ZERO_WITHDRAW_AMOUNT");
        require(IERC20(zst).balanceOf(msg.sender) >= amount, "DEPOSIT_CONTRACT: INSUFFICIENT_BALANCE");
        address underlying = IZSTFactory(factory).getUnderlying(zst);
        require(assetsDeposited[underlying] >= amount, "DEPOSIT_CONTRACT: INVALID_WITHDRAW_AMOUNT");
        assetsDeposited[underlying] -= amount;
        IZtakingPool(zircuitStaking).withdraw(underlying, amount);
        IERC20(underlying).safeTransfer(msg.sender, amount);
        _burnZST(msg.sender, zst, amount);
    }
    
    /// @dev Mint liquid wrapper token
    /// @param recipient Depositor address
    /// @param underlying Underlying asset address used for issuing for liquid wrapper token
    /// @param amount Amount of tokens to be minted
    function _mintZST(
        address recipient,
        address underlying,
        uint256 amount
    ) 
        private
    {
        // fetching Zircuit Staked Token address using the underlying token
        address zstAddress = IZSTFactory(factory).getZST(underlying);
        IZSToken(zstAddress).mint(recipient, amount);
    }

    /// @dev Burn liquid wrapper token
    /// @param from Withdrawer address
    /// @param zstAddress Liquid wrapper token address about to be burned
    /// @param amount Amount of tokens to be burned
    function _burnZST(
        address from, 
        address zstAddress, 
        uint256 amount
    ) 
        private
    {
        IZSToken(zstAddress).burn(from, amount);
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