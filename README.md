# README

# Insurance Policy API

A Rails 8 API for managing insurance policies, with an **event-sourced audit trail**
for status changes. Built as a demonstration of clean, production-minded backend design.

## What it does

Policies move through a lifecycle (`pending → active → cancelled/expired`). Rather than
just overwriting a status field, every transition is recorded as an immutable event, so
the full history of what happened to a policy — and when — is always preserved and auditable.

## Key design decisions

- **Event sourcing (scoped):** each status change is stored as an immutable `PolicyStatusEvent`.
  The `status` column is a denormalized cache; the event log is the source of truth, and
  `recompute_status!` can rebuild the cache from events at any time.
- **Explicit transition rules:** an allowed-transitions graph rejects invalid moves
  (e.g. reactivating a cancelled policy) before any event is written.
- **Concurrency-safe:** transitions use row-level locking (`SELECT ... FOR UPDATE`) so
  simultaneous requests can't corrupt a policy's state.
- **Atomic writes:** the event and the status update happen in a single transaction —
  you never get one without the other.
- **Immutable events:** events are read-only once created; corrections are new events, never edits.
- **Service-object architecture:** transition logic lives in `Policies::TransitionStatus`,
  keeping controllers and models thin.

## API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/policies` | Create a policy |
| POST | `/policies/:id/activate` | Activate a policy (records an event) |
| POST | `/policies/:id/cancel` | Cancel a policy (records an event) |
| GET | `/policies/:id/status_events` | Full status-change history (audit trail) |

## Running locally

```bash
bundle install
bin/rails db:setup
bin/rails server
```

Then, for example:

```bash
# create a policy
curl -X POST http://localhost:3000/policies -H "Content-Type: application/json" \
  -d '{"policy_number":"POL-100","holder_name":"Jane Doe","start_date":"2026-01-01","end_date":"2026-12-31"}'

# activate it, then view its history
curl -X POST http://localhost:3000/policies/1/activate
curl http://localhost:3000/policies/1/status_events
```

## Tech

Ruby 3.3 · Rails 8.1 · SQLite (development) · built with Claude Code (see `PROMPTS.md`)
