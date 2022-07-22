// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

error NotOwner();
error AlreadyQueued(bytes32);
error TimestampNotInRange(uint256, uint256);
error NotQueued(bytes32);
error TimestampNotPassed(uint256, uint256);
error TimestampExpired(uint256, uint256);
error TransactionFailed();

contract TimeLock {

    event Queue(address indexed target, uint256 indexed amount, string func, bytes data, uint256 timestamp, bytes32 transactionId);
    event Execute(address indexed target, uint256 indexed amount, string func, bytes data, uint256 timestamp, bytes32 transactionId);
    event Cancel(bytes32 indexed transactionId);

    address public immutable owner;

    uint256 public constant MIN_DELAY = 10;
    uint256 public constant MAX_DELAY = 1000;
    uint256 public constant GRACE_PERIOD = 1000;

    mapping(bytes32 => bool) public queued;

    modifier onlyOwner {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function queue(address target, uint256 amount, string calldata func, bytes calldata data, uint256 timestamp) external onlyOwner {
        bytes32 transactionId = getTransactionId(target, amount, func, data, timestamp);
        if (queued[transactionId]) revert AlreadyQueued(transactionId);
        if (timestamp < block.timestamp + MIN_DELAY || timestamp > block.timestamp + MAX_DELAY) revert TimestampNotInRange(block.timestamp, timestamp);
        queued[transactionId] = true;
        emit Queue(target, amount, func, data, timestamp, transactionId);
    }

    function getTransactionId(address target, uint256 amount, string calldata func, bytes calldata data, uint256 timestamp) public pure returns (bytes32 transactionid) {
        return keccak256(abi.encode(target, amount, func, data, timestamp));
    }

    function execute(address target, uint256 amount, string calldata func, bytes calldata data, uint256 timestamp) external payable onlyOwner returns (bytes memory) {
        bytes32 transactionId = getTransactionId(target, amount, func, data, timestamp);
        if (!queued[transactionId]) revert NotQueued(transactionId);
        if (block.timestamp < timestamp) revert TimestampNotPassed(block.timestamp, timestamp);
        if (block.timestamp > timestamp + GRACE_PERIOD) revert TimestampExpired(block.timestamp, timestamp + GRACE_PERIOD);
        queued[transactionId] = false;
        bytes memory _data;
        uint256 funcLength = bytes(func).length;
        if (funcLength > 0) {
            _data = abi.encodePacked(bytes4(keccak256(bytes(func))), data);
        } else {
            _data = data;
        }
        (bool passed, bytes memory response) = target.call{value: amount}(_data);
        if (passed) revert TransactionFailed();
        emit Execute(target, amount, func, data, timestamp, transactionId);
        return response;
    }

    function cancel(bytes32 transactionId) external onlyOwner {
        if (!queued[transactionId]) revert NotQueued(transactionId);
        queued[transactionId] = false;
        emit Cancel(transactionId);
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp + 15;
    }
}
