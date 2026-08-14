# ADR 0006: Make documentation an agent-maintained system

| Status | Date |
| --- | --- |
| Accepted | 2026-08-14 |

## Context

The CLI's correctness depends on details that are easy to erase during routine
maintenance. These include output bytes, dependency boundaries, temporary-file
containment, and accepted legacy defects.

Documentation can drift if agents treat it as optional prose after code changes.

## Decision

Install `librarian`, `gooddocs`, and `richdocs` from the canonical
`neozenith/agentic-dotfiles` source through APM. Require agents to use these
skills for project work and keep the lockfile as the resolved record.

Every project-authored Markdown document contains a relevant Mermaid diagram.
Run the Mermaid complexity and WCAG contrast gates before accepting a diagram.
Generate rich HTML companions under `tmp/richdocs/` when a document benefits
from interactive rendering.

```mermaid
flowchart LR
    Change["Project change"]:::input --> Librarian["librarian"]:::process
    Change --> Gooddocs["gooddocs"]:::process
    Change --> Richdocs["richdocs"]:::process
    Librarian --> Markdown["Canonical Markdown"]:::output
    Gooddocs --> Markdown
    Richdocs --> Markdown
    Richdocs --> Temp["Temporary rich view"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

The required skills keep canonical Markdown organised, accurate, and visual while rich companions remain temporary.

## Consequences

Documentation placement, truth, and presentation become repeatable checks.
Generated rich documents remain disposable, while Markdown stays canonical.

Small policy documents carry small diagrams even when prose alone could explain
them. This is a deliberate consistency rule for this project.
