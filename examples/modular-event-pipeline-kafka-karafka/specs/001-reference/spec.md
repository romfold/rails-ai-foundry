# Reliable versioned event pipeline

Version 1 amount and version 2 delta envelopes produce the same normalized counter effect.
Tenant/key cursors enforce sequence order; gaps retry without partial state. Event identities deduplicate effects,
and reuse with different content is quarantined. Malformed or unsupported schemas are durably quarantined.
Karafka consumes a real Kafka topic, retries a transient failure, preserves ordering across duplicates and resumes
a consumer group after restart. Offsets are marked only after database commit or durable quarantine.
The alternative JetStream recipe preserves durable consumer identity across reconnect, replays unacknowledged
committed work without duplicate effects, negatively acknowledges gaps and terminates quarantined poison.
Rails read delivery restricts counter visibility to the authenticated tenant.
