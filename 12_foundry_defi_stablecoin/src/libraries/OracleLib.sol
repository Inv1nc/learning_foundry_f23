//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/*
 * @ title OracleLib
 * @author Inv1nc
 * @notice The library is used to check the chainlink Oracle for stable data.
 * If a price is stale, the function will revert and render the DSCEngine unsuable - this is by design
 * We want the DSCEngine to freeze if the price become stale.
 * 
 * So if the chainlink network explodes and you have a lot of money locked in the protocol... too bad
 */

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library OracleLib {
    error OracleLib_StalePrice();

    uint256 private constant TIMEOUT = 3 hours;

    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) {
            revert OracleLib_StalePrice();
        }

        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
