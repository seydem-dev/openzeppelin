contract TestTimeLock {

    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    } 

    function test() external {
        require(msg.sender == timeLock, "Not TimeLock");
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp + 100;
    }
}
