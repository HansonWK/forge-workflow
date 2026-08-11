# Architecture Guidelines

> Fill this in — or run `/clarify architecture` to be quizzed and have it generated. Claude reads this
> to keep new code within your chosen architecture, and `code-review` checks against it. Keep it
> **decision-focused** (see the `authoring` skill: encode the decision, not the principle).

## Pattern

<!-- Which architecture does this codebase follow? Pick one (or describe your own):
     - Hexagonal / Ports & Adapters — a domain core isolated behind ports; adapters for IO/DB/UI.
       Rule of thumb: the domain never imports infrastructure; dependencies point inward.
     - Layered — presentation → application → domain → infrastructure; each layer depends only downward.
     - Vertical slice — organise by feature/use-case; each slice owns its end-to-end code.
     - Modular monolith / microservices / other — describe the boundaries and how modules communicate.
-->
- **Pattern:** <e.g. Hexagonal (Ports & Adapters)>

## Boundaries & dependency rules

<!-- The concrete rules Claude must keep to. Examples:
     - The domain layer imports nothing from infrastructure or the framework.
     - IO (DB, HTTP, queue) lives only in adapters; inject it via ports/interfaces.
     - No business logic in controllers/handlers — delegate to the domain / use-case.
     - Where shared types/contracts live. -->
- <rule>
- <rule>

## Where things go

<!-- Directory conventions: where domain, use-cases, adapters, and entrypoints live. -->
- `<path>` — <what belongs here>

## Anti-patterns (reject in review)

<!-- e.g. a repository/DB call inside a domain entity; framework types leaking into the domain. -->
- <anti-pattern>
