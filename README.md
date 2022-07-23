# Time Lock
**Time Lock is a contract commonly used in DeFi and DAOs. The purpose of time lock is to delay a transaction. By queuing a transaction, you have to wait a specific amount of time before the transaction passes which can be extremely convenient in case of an exploit. It can give you some time to secure funds.**

```
Queue
```
*Fired when transaction is queued.*

```
Execute
```
*Fired when transaction is executed.*

```
Cancel
```
*Fired when transaction is canceled.*

```
owner
```
*Address of contract deployer.*

```
MIN_DELAY
```
*Required for `timestamp` to be between `MIN_DELAY` and `MAX_DELAY`*

```
MAX_DELAY
```
*Required for `timestamp` to be between `MIN_DELAY` and `MAX_DELAY`*

```
GRACE_PERIOD
```
*Time for how long transaction can, after queued, be executed.*

```
queued
```
*Checks if transaction is queued.*

```
onlyOwner
```
*Checks if caller is owner, throws if not.*

```
queue()
```
*Function that queues a transaction. Only callable by owner. Cant queue before minimum delay period and after maximum delay period.*

```
getTransactionId()
```
*Required to get transaction ID of params for `execute()`*

```
execute()
```
*Function that executes queued transaction. Execution must take place after given timestamp and before grace period.*

```
getTimestamp()
```
*Gets current block timestamp + 15 seconds.*

# Test Time Lock

```
owner
```
*Address of contract deployer.*

```
timeLock
```
*Address for main contract.`*

```
test()
```
*Test function*
