# Persistent streaming chat

A tenant creates a conversation, receives incremental replies and reloads persisted history.
Another tenant cannot access or append to it. A pending reply prevents concurrent turns.
Failed providers preserve partial output marked failed and do not contaminate completed history.
Input and output are bounded. Streamed text is escaped, including hostile markup.
The native provider reads its pack-local prompt and root application model alias and passes completed history to RubyLLM.
Normal delivery uses a clearly labeled offline demo provider; no normal test calls a model.
