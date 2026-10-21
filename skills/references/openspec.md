# OpenSpec integration

Foundry tests OpenSpec 1.12.0. Use the installed upstream exploration, proposal, apply, update, sync, and archive skills. Read current specifications and active changes relevant to the task. Keep implementation tasks unchecked until their behavior is verified, and archive completed bounded changes after tests and relevant checks pass.

Use the pinned CLI for artifact instructions and native specification validation. Validation checks artifact structure; it does not prove application behavior. Keep Packwerk and behavioral tests as separate evidence. Retain earlier archives as history and avoid duplicating architecture configuration in proposals.

Setup is `foundry setup --specs=openspec`. The consuming application may pin `@fission-ai/openspec` as a development dependency. Foundry checks a local `node_modules/.bin/openspec` before PATH. Preserve existing skills and specifications; resolve collisions explicitly rather than passing force over the application.
