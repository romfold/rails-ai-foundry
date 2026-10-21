## 1. Host and generated package

- [x] 1.1 Create the independently locked managed Rails/PostgreSQL host; verify exact bundle versions and public generator discovery.
- [x] 1.2 Generate the v2 Inventory package, composition, aggregate, contracts, projection and read model through public commands; verify structural checking.

## 2. Executable behavior

- [x] 2.1 Implement restock/reserve/release invariants and projection; verify success, invalid quantities, insufficient stock, invalid releases and unchanged streams on rejection.
- [x] 2.2 Add historical fixture/upcaster and concurrency/rebuild scenarios; verify unchanged stored rows and stale write rejection.
- [x] 2.3 Add preserving setup, fresh-stream demo and verify commands; run repeated setup and independent process replay without data loss.

## 3. Completion

- [x] 3.1 Extend managed CI, document ownership/setup/limits and roadmap status; verify links and separate support-desk v1 layout.
- [x] 3.2 Run own locked example suite, support desk, final framework checks, lint, strict OpenSpec and gem inspection; record local evidence, commit and archive only after success.
