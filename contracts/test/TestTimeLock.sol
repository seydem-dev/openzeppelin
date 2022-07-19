error NotOwner();

contract TestTimeLock {

    address public immutable owner;
    address public immutable timeLock;

    constructor(address _timeLock) {
        owner = msg.sender;
        timeLock = _timeLock;
    } 

    function test() external {
        if (msg.sender != owner) revert NotOwner();
    }
}
