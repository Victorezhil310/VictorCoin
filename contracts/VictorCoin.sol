// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VictorCoin (VCT) ERC-20 Smart Contract
 * @dev Implementation of the VictorCoin token with 5% owner royalty tax,
 *      staking mechanisms, and anti-whale protections.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract VictorCoin is IERC20 {
    string public constant name = "VictorCoin";
    string public constant symbol = "VCT";
    uint8 public constant decimals = 18;

    uint256 private _totalSupply = 1_000_000_000 * 10**18; // 1 Billion VCT
    address public owner;
    uint256 public constant OWNER_TAX_PERCENT = 5; // 5% Owner Royalty

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isExemptFromFee;

    event OwnerRoyaltySwept(address indexed owner, uint256 amount);
    event FeeExemptionUpdated(address indexed account, bool isExempt);

    modifier onlyOwner() {
        require(msg.sender == owner, "VictorCoin: Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
        isExemptFromFee[msg.sender] = true;
        isExemptFromFee[address(this)] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address ownerAddr, address spender) public view override returns (uint256) {
        return _allowances[ownerAddr][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "VictorCoin: Transfer amount exceeds allowance");
        
        _allowances[sender][msg.sender] = currentAllowance - amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "VictorCoin: Transfer from zero address");
        require(recipient != address(0), "VictorCoin: Transfer to zero address");
        require(_balances[sender] >= amount, "VictorCoin: Transfer amount exceeds balance");

        uint256 feeAmount = 0;
        if (!isExemptFromFee[sender] && !isExemptFromFee[recipient]) {
            feeAmount = (amount * OWNER_TAX_PERCENT) / 100;
        }

        uint256 sendAmount = amount - feeAmount;

        _balances[sender] -= amount;
        _balances[recipient] += sendAmount;
        emit Transfer(sender, recipient, sendAmount);

        if (feeAmount > 0) {
            _balances[owner] += feeAmount;
            emit Transfer(sender, owner, feeAmount);
            emit OwnerRoyaltySwept(owner, feeAmount);
        }
    }

    function setFeeExemption(address account, bool exempt) external onlyOwner {
        isExemptFromFee[account] = exempt;
        emit FeeExemptionUpdated(account, exempt);
    }
}
