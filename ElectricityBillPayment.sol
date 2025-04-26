// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ElectricityBillPayment {
    address public admin; // Admin address
    uint256 public monthlyBillAmount; // Monthly bill amount
    mapping(address => uint256) public balances; // User balances
    mapping(address => uint256) public lastPaymentTimestamp; // Last payment timestamp for users

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event BillPaid(address indexed user, uint256 amount);
    event BillAmountSet(uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender; // Set the deployer as admin
    }

    // Function to deposit funds into the user's account
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Function to withdraw funds from the user's account
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // Function to check the user's balance
    function checkBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // Function to set the monthly bill amount (Admin-only)
    function setMonthlyBillAmount(uint256 amount) external onlyAdmin {
        require(amount > 0, "Bill amount must be greater than zero");
        monthlyBillAmount = amount;
        emit BillAmountSet(amount);
    }

    // Function to pay the monthly bill manually
    function payBill() external {
        require(monthlyBillAmount > 0, "Monthly bill amount is not set");
        require(balances[msg.sender] >= monthlyBillAmount, "Insufficient balance to pay the bill");
        require(
            block.timestamp - lastPaymentTimestamp[msg.sender] >= 30 days,
            "Bill can only be paid once a month"
        );

        balances[msg.sender] -= monthlyBillAmount;
        lastPaymentTimestamp[msg.sender] = block.timestamp;
        emit BillPaid(msg.sender, monthlyBillAmount);
    }
}
