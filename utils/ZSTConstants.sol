// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

library ZSTConstants {
    
    // TOKENS

    bytes32 public constant WETH = keccak256("WETH");
    bytes32 public constant EZ_ETH = keccak256("EZ_ETH");
    bytes32 public constant USD_E = keccak256("USD_E");
    bytes32 public constant WE_ETH = keccak256("WE_ETH");
    bytes32 public constant PUF_ETH = keccak256("PUF_ETH");
    bytes32 public constant RS_ETH = keccak256("RS_ETH");
    bytes32 public constant WST_ETH = keccak256("WST_ETH");
    bytes32 public constant LS_ETH = keccak256("LS_ETH");
    bytes32 public constant MST_ETH = keccak256("MST_ETH");
    bytes32 public constant SW_ETH = keccak256("SW_ETH");
    bytes32 public constant M_ETH = keccak256("M_ETH");
    bytes32 public constant MW_BETH = keccak256("MW_BETH");
    bytes32 public constant MSW_ETH = keccak256("MWS_ETH");
    bytes32 public constant C_STONE = keccak256("C_STONE");
    bytes32 public constant EG_ETH = keccak256("EG_ETH");

    // CONTRACTS

    bytes32 public constant ZIRCUIT_STAKING = keccak256("ZIRCUIT_STAKING_CONTRACT");
    bytes32 public constant DEPOSIT_CONTRACT = keccak256("DEPOSIT_CONTRACT");
    bytes32 public constant FACTORY = keccak256("FACTORY");

    // ROLES

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    // MISCELLANEOUS

    address public constant ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant WETH_TOKEN = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

}