// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import { ExampleExternalContract } from "./ExampleExternalContract.sol";

/* Custom error */
error WithdrawFailure();
error DeadlineNotReached();
error DeadlineReached();
error NoFundToWithdraw();
error AlreadyExecuted();
error WithdrawNotAllowed();

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  /* Constant */
  uint256 public constant threshold = 1 ether;

  /* Var */
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;
  bool public executedOnce = false;
  address public owner;

  /* Mapping */
  mapping (address => uint256) public balances;


  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  /* Event */
  event Stake(address, uint256);

  /* Modifier */
  modifier notCompleted() {
      require(!exampleExternalContract.completed(), "Not completed");
    _;
  }
  
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  function stake() public payable {
    // No stake if deadline is reached
    if (block.timestamp >= deadline) {
      revert DeadlineReached();
    }

    balances[msg.sender] = address(this).balance;
    // Send event stake
    emit Stake(msg.sender, balances[msg.sender]);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public notCompleted {
    if (executedOnce) {
      revert AlreadyExecuted();
    }

    if (block.timestamp < deadline) {
      // Trigger error since you can not execute until deadline reached
      revert DeadlineNotReached();
    } else {
      if (address(this).balance >= threshold) {
        exampleExternalContract.complete{value: address(this).balance}();
      } else {
        openForWithdraw = true;
      }
      // Set execution once after completion or open to withdraw
      executedOnce = true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public payable notCompleted {
    if (block.timestamp >= deadline && openForWithdraw) {
      // Revert if no fund for the sender
      if (balances[msg.sender] == 0) {
        revert NoFundToWithdraw();
      }
      (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
      if (sent) {
        // reset balance
        balances[msg.sender] = 0;
        // Reset wihdraw
      } else {
        revert WithdrawFailure();
      }
    } else {
      // Trigger error since you can not execute until deadline reached
      revert WithdrawNotAllowed();
    }
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }

    return deadline - block.timestamp;
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
