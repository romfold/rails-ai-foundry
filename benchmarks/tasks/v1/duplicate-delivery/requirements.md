# Repair duplicate outbox delivery

Knowledge::PublishDelivery must retry an event after a crash after store persistence but before delivery acknowledgement without duplicating it. Use the stable delivery.event_id and event type DocumentPublished with the decoded JSON payload. On store.duplicate_error, read the existing event and verify BOTH type and exact payload before acknowledging; conflict must raise and leave delivered false. Provider/store failure must leave work pending. A successful identical retry marks delivered true. Keep the injected store protocol and signatures.

Do not change dependency versions, visible tests, task instructions or disable verification. Add focused tests for your changes. Normal tests remain offline.
