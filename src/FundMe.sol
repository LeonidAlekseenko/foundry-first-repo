// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import { AggregatorV3Interface } from "@chainlink/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 3. Interfaces, Libraries
error FundMe__NotOwner();


contract FundMe {
    
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    AggregatorV3Interface private s_priceFeed;


    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Functions Order:
    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }
    

    /// @notice Funds our contract based on the ETH/USD price
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // если пользователь новый он добавится если старый его баланс плюсуется
        s_addressToAmountFunded[msg.sender] += msg.value;
        // список адресов вкладчиков нужен для функции снятия
        s_funders.push(msg.sender);
    }


    function withdraw() public onlyOwner {

        uint256 fundersLength = s_funders.length;

        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }


    fallback() external payable {
        fund();
    }


    receive() external payable {
        fund();
    }

   
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }




}