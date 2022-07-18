error NotOwner();

contract TimeLockTest {

    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    } 

    function test() external {
        if (msg.sender != owner) revert NotOwner();
    }
}
