// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { AggregatorV3Interface } from "@chainlink/src/v0.8/interfaces/AggregatorV3Interface.sol";


library PriceConverter {


    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }


    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1_000_000_000_000_000_000;
        return ethAmountInUsd;
    }
}