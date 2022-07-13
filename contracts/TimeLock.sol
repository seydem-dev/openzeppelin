// SPDX-License-Identifier: MIT

error NotOwner();
error AlreadyQueued();
error TimestampNotInRange();
error NotQueued();
error TimestampNotPassed();
error TimestampExpired();
error TransactionFailed();

pragma solidity ^0.8.0;

contract TimeLock {

    event Queue(address indexed target, uint256 indexed amount, string func, bytes data, uint256 timestamp, bytes32 transactionId);
    event Execute(address indexed target, uint256 indexed amount, string func, bytes data, uint256 timestamp, bytes32 transactionId);
    event Cancel(bytes32 indexed transactionId);

    address public immutable owner;

    uint8 public constant MIN_DELAY = 10;
    uint8 public constant MAX_DELAY = 100;
    uint8 public constant GRACE_PERIOD = 100;

    mapping(bytes32 => bool) public queued;

    modifier onlyOwner {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    receive() external payable {}

    constructor() {
        owner = msg.sender;
    }

    function queue(address target, uint256 amount, string calldata func, bytes calldata data, uint256 timestamp) external onlyOwner {
        bytes32 transactionId = getTransactionId(target, amount, func, data, timestamp);
        if (queued[transactionId]) revert AlreadyQueued();
        if (timestamp < block.timestamp + MIN_DELAY || timestamp > block.timestamp + MAX_DELAY) revert TimestampNotInRange();
        queued[transactionId] = true;
        emit Queue(target, amount, func, data, timestamp, transactionId);
    }

    function getTransactionId(address target, uint256 amount, string calldata func, bytes calldata data, uint256 timestamp) public pure returns (bytes32 transactionid) {
        return keccak256(abi.encode(target, amount, func, data, timestamp));
    }

    function execute(address target, uint256 amount, string calldata func, bytes calldata data, uint256 timestamp) external payable onlyOwner returns (bytes memory) {
        bytes32 transactionId = getTransactionId(target, amount, func, data, timestamp);
        if (!queued[transactionId]) revert NotQueued();
        if (block.timestamp < timestamp) revert TimestampNotPassed();
        if (block.timestamp > timestamp + GRACE_PERIOD) revert TimestampExpired();
        queued[transactionId] = false;
        bytes memory _data;
        if (bytes(func).length > 0) {
            _data = abi.encodePacked(bytes4(keccak256(bytes(func))), data);
        } else {
            _data = data;
        }
        (bool passed, bytes memory response) = target.call{value: amount}(data);
        if (!passed) revert TransactionFailed();
        emit Execute(target, amount, func, data, timestamp, transactionId);
        return response;
    }

    function cancel(bytes32 transactionId) external onlyOwner {
        if (!queued[transactionId]) revert NotQueued();
        queued[transactionId] = false;
        emit Cancel(transactionId);
    }
}
