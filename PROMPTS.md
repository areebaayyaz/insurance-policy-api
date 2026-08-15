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
