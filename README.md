# `zevm` 

most portable evm runtime

## Run
```bash
zig build run
```

## TODO
- [ ] Refactor: EVM should operate on State (like CPU on process context)  
- [ ] Warm/cold account tracking for gas costs
- [ ] Proper external contract calls
- [ ] Return data handling
- [ ] Gas refunds for SSTORE
- [ ] Real block/chain context (currently mocked)
- [ ] Transient storage (TLOAD/TSTORE) 
- [ ] External code fetching
- [ ] integrate `evmc`