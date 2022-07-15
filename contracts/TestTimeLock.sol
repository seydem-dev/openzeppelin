contract TestTimeLock {

    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    } 

    function test() external {
        require(msg.sender == timeLock, "Not TimeLock");
    }
}
