// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;


import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

contract TransferLogistics {
    
    struct TokenAllowance 
    {
        address token;
        address from;
        address to;
        uint amount;
        uint afterTimestamp;
        uint beforeTimestamp;
        bool anyone;
    }

    // token => from => to 
    mapping(address => mapping(address => mapping(address=> TokenAllowance))) public allowance;


    function AllowUntil(
        address token,
        address to,
        uint amount,
        uint beforeTimestamp,
        bool anyone
    ) public {
        require(beforeTimestamp > block.timestamp, "old date");
        uint fromAllowance = IERC20(token).allowance(msg.sender, address(this));
        require(fromAllowance >= amount, "amount is too high");

        allowance[token][msg.sender][to] = TokenAllowance({
            token: token,
            from: msg.sender,
            to: to,
            amount: amount,
            afterTimestamp: block.timestamp,
            beforeTimestamp: beforeTimestamp,
            anyone: anyone
        });
    }

    function AllowAfter(
        address token,
        address to,
        uint amount,
        uint afterTimestamp,
        bool anyone
    ) public {

                uint fromAllowance = IERC20(token).allowance(msg.sender, address(this));
        require(fromAllowance >= amount, "amount is too high");

        allowance[token][msg.sender][to] = TokenAllowance({
            token: token,
            from: msg.sender,
            to: to,
            amount: amount,
            afterTimestamp: afterTimestamp,
            beforeTimestamp: type(uint).max,
            anyone: anyone
        });
    }

    function AllowAfterAndBefore(
        address token,
        address to,
        uint amount,
        uint afterTimestamp,
        uint beforeTimestamp,
        bool anyone
    ) public {
        afterTimestamp = (afterTimestamp > block.timestamp) ? afterTimestamp : block.timestamp;
        require(beforeTimestamp > afterTimestamp, "invalid date range");
        uint fromAllowance = IERC20(token).allowance(msg.sender, address(this));
        require(fromAllowance >= amount, "amount is too high");

        allowance[token][msg.sender][to] = TokenAllowance({
            token: token,
            from: msg.sender,
            to: to,
            amount: amount,
            afterTimestamp: afterTimestamp,
            beforeTimestamp: beforeTimestamp,
            anyone: anyone
        });
    }

    function requestFrom(
        address token,
        address from,
        address to,
        uint amount
    ) public {

    uint fromAllowance = IERC20(token).allowance(from, address(this));
    require(fromAllowance >= amount, "amount is too high");

     TokenAllowance memory ta = allowance[token][from][msg.sender];
     require(ta.amount >= amount, "requesting too much");
     require(ta.afterTimestamp <= block.timestamp && ta.beforeTimestamp >= block.timestamp, "out of range");
     if (!ta.anyone){
        require(msg.sender == to, "no requests on behalf");
     }
     IERC20(token).transferFrom(from, to, amount);
    }

}
