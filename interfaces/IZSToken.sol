// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IZSToken is IERC20 {

    // FUNCTIONS

    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;

}