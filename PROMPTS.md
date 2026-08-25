# PROMPTS

AI-assisted development log for the insurance-policy-api project — a running record of the prompts used to build it and what each one produced. New entries go at the bottom.

---

## 1. Explain the project structure

**Prompt:**
> Explain what files are in this project and what the main folders do, as if I'm new to Rails.

**Produced:**
- A walkthrough of the Rails 8 API-only app layout (`app/`, `config/`, `db/`, `test/`, etc.) and what each folder is for
- No code or file changes — explanation only

---

## 2. Policy model and create endpoint

**Prompt:**
> Create a Policy model with these fields: policy_number (string), holder_name (string), status (string, defaulting to "pending"), start_date (date), and end_date (date). Generate the migration, run it, and add a POST /policies endpoint that creates a policy and returns it as JSON. Keep it simple and idiomatic Rails 8.

**Produced:**
- `Policy` model (`app/models/policy.rb`) with presence validation on `policy_number` and `holder_name`
- Migration creating `policies` table: `policy_number`, `holder_name`, `status` (default `"pending"`), `start_date`, `end_date`
- `PoliciesController#create` — creates a policy, renders JSON `201` on success or `422` with error messages on failure
- Route: `resources :policies, only: [:create]`
- Test fixtures and empty model test stub
- Commit: `44cec81` — "Add Policy model and POST /policies endpoint with validation"

---

## 3. Create this file

**Prompt:**
> Create a PROMPTS.md file documenting the prompts I've used so far and what each produced. I'll keep adding to it as the project grows.

**Produced:**
- This `PROMPTS.md` file

---

## 4. Design event sourcing for policy status

**Prompt:**
> I want to add event sourcing to track changes to a policy's status. Before writing any code, explain how you'd design it in this Rails 8 app: what model(s), what the events table looks like, how status gets derived or updated, and what endpoints. Don't change any files yet — just walk me through the plan.

**Produced:**
- A design walkthrough for a scoped, status-only event log (vs. full aggregate event sourcing): a `PolicyStatusEvent` model, an append-only `policy_status_events` table, `policies.status` kept as a denormalized cache updated transactionally alongside each event, a service object to enforce explicit transition rules, and named endpoints for transitions plus a history endpoint
- No code or file changes — explanation only

---

## 5. Implement policy status event sourcing

**Prompt:**
> Go ahead and implement the scoped version, with two changes: (1) drop the metadata jsonb column for now — keep it simple, and (2) expose clear named endpoints POST /policies/:id/activate and POST /policies/:id/cancel that each record a status event and update the policy, plus GET /policies/:id/status_events for the history. Keep the immutable events, the service object, the explicit transition rules, and recompute_status!. Build the migration, model, service, controller, and routes. Explain each file as you create it.

**Produced:**
- Migration creating `policy_status_events`: `policy_id` (FK), `from_status`, `to_status`, `reason`, `occurred_at`, `created_at` (no `updated_at`), indexed on `(policy_id, occurred_at)`
- `PolicyStatusEvent` model (`app/models/policy_status_event.rb`) — immutable via `readonly?`
- `Policy` model updated with a `TRANSITIONS` graph, `status` inclusion validation, `has_many :policy_status_events`, and `recompute_status!` to rebuild the cached status from the event log
- `Policies::TransitionStatus` service object (`app/services/policies/transition_status.rb`) — row-locks the policy, validates the transition, writes the event and updates `status` atomically
- `PoliciesController#activate` / `#cancel` actions, new `PolicyStatusEventsController#index` for history, and a `RecordNotFound` → `404` JSON rescue in `ApplicationController`
- Routes: `POST /policies/:id/activate`, `POST /policies/:id/cancel`, `GET /policies/:id/status_events`
- Commit: `8905d2a` — "Add event-sourced status transitions with audit trail, row-locking, and immutable events"

---
