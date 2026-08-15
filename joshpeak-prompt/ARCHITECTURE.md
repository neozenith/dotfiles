# Architecture

`joshpeak-prompt` is a small Go CLI with one runtime package. It replaces six
zsh prompt helpers while preserving their output bytes, runs the prompt sections
concurrently, and keeps timing data separate from prompt output.

The diagrams below present the system through four lenses. Each overview is
followed by a detailed source map for maintainers.

---

<details>
<summary><b>Table of Contents</b></summary>
<!--TOC-->

- [Architecture](#architecture)
  - [System components](#system-components)
  - [Prompt rendering and timing](#prompt-rendering-and-timing)
  - [External integration and data flow](#external-integration-and-data-flow)
  - [Build and portability](#build-and-portability)

<!--TOC-->
</details>

---

## System components

The executable composes the CLI, concurrent renderer, prompt sections, and two
ports for external commands and token storage.

```mermaid
flowchart LR
    Shell["Shell or caller"]:::input --> Theme["Zsh theme or direct command"]:::process
    Theme --> CLI["CLI entry point"]:::process
    CLI --> Renderer["Concurrent renderer"]:::process
    Renderer --> Sections["Six prompt sections"]:::process
    Sections --> Runner["Command runner"]:::external
    Sections --> Tokens["Token reader"]:::storage
    Renderer --> Prompt["Prompt output"]:::output
    Renderer --> Timings["Timing output"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef external fill:#f1f5f9,stroke:#334155,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

The CLI sends configured sections through a concurrent renderer, with external access isolated behind command and token ports.

<details>
<summary>Explore the detailed component map</summary>

```mermaid
flowchart LR
    subgraph Entry["Entry and dispatch"]
        Shell["Shell or caller"]:::input --> Theme["Zsh theme or direct command"]:::process
        Theme --> MainCmd["cmd main"]:::process
        MainCmd --> Main["prompt.Main"]:::process
        Main --> CLI["RunCLI"]:::process
    end

    subgraph Core["Prompt coordination"]
        Defaults["DefaultSections"]:::process --> Renderer["Renderer"]:::process
        Results["Result slice"]:::storage
        Compose["Compose"]:::process
        Timing["FormatTimings"]:::process
    end

    subgraph Implementations["Section implementations"]
        Git["Git"]:::process
        GitHub["GitHub"]:::process
        Kubernetes["Kubernetes"]:::process
        Python["Python"]:::process
        AWS["AWS"]:::process
        GCloud["GCloud"]:::process
    end

    subgraph Boundaries["External boundaries"]
        Runner["Runner and ExecRunner"]:::external --> Domain["Domain CLI processes"]:::external
        TokenReader["TokenReader and SQLiteTokenReader"]:::storage --> TokenDB["GCloud token database"]:::storage
    end

    Main -->|inject adapters| Defaults
    CLI -->|render command| Renderer
    Renderer -->|goroutine| Git
    Renderer -->|goroutine| GitHub
    Renderer -->|goroutine| Kubernetes
    Renderer -->|goroutine| Python
    Renderer -->|goroutine| AWS
    Renderer -->|goroutine| GCloud
    Git --> Runner
    GitHub --> Runner
    Kubernetes --> Runner
    Python --> Runner
    GCloud --> Runner
    GCloud --> TokenReader
    Renderer -->|results| Results
    Results --> Compose
    Results --> Timing
    CLI --> Compose
    CLI --> Timing
    Compose --> Stdout["Prompt stdout"]:::output
    Timing --> Streams["Timing stdout or stderr"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef external fill:#f1f5f9,stroke:#334155,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

The composition root injects concrete adapters, while the renderer coordinates six section implementations and the CLI chooses the output stream.

</details>

Source: [`joshpeak.zsh-theme`](../zsh/themes/joshpeak.zsh-theme),
[`main.go`](cmd/joshpeak-prompt/main.go),
[`cli.go`](internal/prompt/cli.go), [`prompt.go`](internal/prompt/prompt.go),
and [`runner.go`](internal/prompt/runner.go). See
[ADR 0001](adrs/0001-preserve-output-with-concurrent-renderers.md) for the
concurrency decision.

## Prompt rendering and timing

The renderer captures one invocation origin, creates one span recorder per
section, creates one shared repository pre-step, and starts one goroutine per
section. Git and GitHub consume the same repository snapshot and schedule only
their remaining independent probes. The render report carries section results
and invocation-level shared spans separately.

```mermaid
flowchart LR
    Request["Prompt request"]:::input --> Origin["Capture invocation origin"]:::process
    Origin --> Sections["Render sections concurrently"]:::process
    Origin --> Recorders["Per-section span recorders"]:::process
    Origin --> Shared["Shared repository snapshot"]:::storage
    Recorders --> Spans["Non-sensitive child spans"]:::storage
    Shared --> Sections
    Shared --> SharedSpans["Shared timing spans"]:::storage
    Sections --> Report["Render report"]:::storage
    Spans --> Report
    SharedSpans --> Report
    Report --> Stdout["Prompt stdout"]:::output
    Report --> Table["Relative timing table"]:::output
    Report --> Summary["Summary Mermaid trace"]:::output
    Report --> Detail["Detailed Mermaid trace"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

The report separates one shared repository trace from section results before the CLI selects an output projection.

<details>
<summary>Follow the complete render and timing sequence</summary>

```mermaid
flowchart TD
    Request["prompt or timings command"]:::input --> Render["Renderer.Render"]:::process
    Render --> Origin["Capture invocation origin"]:::process
    Origin --> Slots["Allocate indexed result slots"]:::storage
    Origin --> Recorders["Create one recorder per section"]:::process
    Origin --> Shared["Create shared repository pre-step"]:::storage

    subgraph Parallel["Concurrent section work"]
        Origin -->|goroutine| Git["Time and render Git"]:::process
        Origin -->|goroutine| GitHub["Time and render GitHub"]:::process
        Origin -->|goroutine| Kubernetes["Time and render Kubernetes"]:::process
        Origin -->|goroutine| Python["Time and render Python"]:::process
        Origin -->|goroutine| AWS["Time and render AWS"]:::process
        Origin -->|goroutine| GCloud["Time and render GCloud"]:::process
        GCloud -->|three goroutines| GInfo["Read and join GCloud config"]:::external
        GInfo --> Token["Optional token expiry read"]:::storage
    end

    Recorders -. "context" .-> Git
    Recorders -. "context" .-> GitHub
    Shared --> Snapshot["Branch worktree status credential"]:::storage
    Snapshot -. "context" .-> Git
    Snapshot -. "context" .-> GitHub
    Git --> GitPlan["Parallel Git comparison phases"]:::process
    GitHub --> GitHubPlan["Configured identity and optional PR probes"]:::process
    GitPlan --> GitCalls["Independent Git calls"]:::external
    GitHubPlan --> GitHubCalls["Independent GitHub calls"]:::external
    Shared --> SharedSpans["Shared pre-step spans"]:::storage
    GitCalls --> ChildSpans
    GitHubCalls --> ChildSpans

    Git --> Slots
    GitHub --> Slots
    Kubernetes --> Slots
    Python --> Slots
    AWS --> Slots
    Token --> Slots
    ChildSpans --> Slots
    SharedSpans --> Slots
    Slots --> Wait["Wait for all sections"]:::process
    Wait --> Compose["Map by name and compose fixed order"]:::process
    Compose --> Stdout["Prompt stdout"]:::output
    Wait -. "--timings" .-> Table["Format Module Start Duration"]:::process
    Wait -->|timings text| Table
    Table --> TimingStream["Sorted timing stderr or stdout"]:::output
    Wait -->|timings --mermaid| Mermaid["FormatMermaidTimings"]:::process
    Mermaid --> SummaryFence["Projected summary gantt stdout"]:::output
    Wait -->|timings --mermaid --detail| Detailed["FormatDetailedMermaidTimings"]:::process
    Detailed --> DetailFence["Projected parent and child gantt stdout"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef external fill:#f1f5f9,stroke:#334155,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

The shared pre-step produces one repository snapshot and one timing lane, while section-specific probes retain their own child spans.

</details>

`Compose` preserves literal separators even when a section is empty. The text
table has `Module`, `Start`, and `Duration` columns and sorts rows from slowest
to fastest. `prompt --timings` writes this table to stderr, while `timings`
writes it to stdout.

`timings --mermaid` preserves the configured section order and writes a complete
fenced `gantt` block to stdout. The block uses `dateFormat x`,
`axisFormat %S.%L`, and `tickInterval 1millisecond`. The projection drops the
sub-millisecond remainder from each non-negative start and rounds each positive
duration up to a whole millisecond. Every projected duration is at least 1 ms
so that fast sections remain visible.

`timings --mermaid --detail` emits one Mermaid section per prompt section. Each
trace begins with one shared Git pre-step lane containing branch, worktree,
origin, and credential spans. Each prompt section then contains its parent total
followed by section-specific child spans sorted by start time and operation
label. Git records email, local-base, remote discovery, and indexed remote
comparisons. GitHub normally records a local `read configured account` span and
records a pull-request operation only when the branch requires it. The local
account read overlaps the repository snapshot. An environment token replaces
that span with `resolve environment account`, which needs one API request.

All timing labels are maintainer-authored and value-free. They never contain
command arguments, subprocess output, remote names, account names, or paths.
The default timing table and summary Mermaid trace ignore child spans and retain
their existing output shapes. The detailed trace has flat invocation and
per-section spans rather than a general nested tracing model.

Named section commands bypass the concurrent renderer and render only the
requested section.

Source: [`Renderer.Render`, `Compose`, `FormatTimings`, and
`FormatMermaidTimings`](internal/prompt/prompt.go), [`runWithSpan`](internal/prompt/trace.go),
[`RunCLI`](internal/prompt/cli.go), [`Git.Render`](internal/prompt/git.go), and
[`GitHub.Render`](internal/prompt/github.go), with repository discovery in
[`repository.go`](internal/prompt/repository.go).
See [ADR 0002](adrs/0002-treat-legacy-output-as-a-byte-contract.md) for the
byte contract and [ADR 0007](adrs/0007-export-relative-timing-traces-as-fenced-mermaid.md)
for the timing projection. [ADR 0008](adrs/0008-record-non-sensitive-hierarchical-subprocess-spans.md)
defines the child-span boundary.
[ADR 0009](adrs/0009-parallelise-and-coalesce-prompt-probes.md) defines the
intra-section dependency graphs and invocation-scoped sharing boundary.
[ADR 0010](adrs/0010-build-one-shared-git-pre-step.md) replaces the
per-command sharing boundary with one repository snapshot and timing lane.
[ADR 0011](adrs/0011-compare-configured-github-identity-with-git-credentials.md)
defines the identity-coherence check and removes normal-path authentication
validation.
[ADR 0012](adrs/0012-mark-binary-owned-prompt-rollups.md) defines the visible
binary marker and narrows the byte contract to named section output.
[ADR 0013](adrs/0013-adopt-the-binary-in-the-zsh-theme.md) supersedes that
temporary marker and adopts the binary as the zsh theme's prompt renderer.

## External integration and data flow

Generic host, path, text, and counting work uses the Go standard library.
Domain CLIs remain authoritative for their configured state. GCloud token
expiry is the only runtime database read.

```mermaid
flowchart LR
    Inputs["OS and environment inputs"]:::input --> Sections["Prompt sections"]:::process
    CLIs["Domain CLIs"]:::external --> Sections
    TokenDB["GCloud token database"]:::storage --> Sections
    Sections --> Format["Compatibility formatting"]:::process
    Format --> Results["Section results"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef external fill:#f1f5f9,stroke:#334155,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

Each section combines standard-library inputs with domain-owned state, then formats its result to preserve the shell contract.

<details>
<summary>Inspect every runtime integration</summary>

```mermaid
flowchart LR
    subgraph Sections["Prompt sections"]
        Git["Git"]:::process
        GitHub["GitHub"]:::process
        Kubernetes["Kubernetes"]:::process
        Python["Python"]:::process
        AWS["AWS"]:::process
        GCloud["GCloud"]:::process
    end

    subgraph ProcessBoundary["Process boundary"]
        Runner["Runner"]:::external --> Exec["ExecRunner"]:::external
        Exec --> GitCLI["git"]:::external
        Exec --> GhCLI["gh"]:::external
        Exec --> Kubectl["kubectl"]:::external
        Exec --> PythonCLI["python3"]:::external
        Exec --> GCloudCLI["gcloud"]:::external
    end

    OS["OS hostname home and working directory"]:::input --> Helpers["Hostname and WorkingDirectory"]:::process
    Helpers --> Result["CLI output bytes"]:::output
    Env["Environment variables"]:::input --> AWS
    Env --> Python
    Env --> GCloud
    Env -. "token override" .-> GitHub
    GitConditional["Directory-effective Git config"]:::input --> Git
    GitConditional --> GitHub
    GhConfig["GitHub host account config"]:::input --> GitHub
    Git -->|git| Runner
    GitHub -->|git and gh| Runner
    Kubernetes -->|kubectl| Runner
    Python -->|python3| Runner
    GCloud -->|gcloud| Runner
    TokenReader["SQLiteTokenReader"]:::storage --> Driver["modernc SQLite driver"]:::storage
    Driver --> TokenDB["access_tokens.db"]:::storage
    GCloud -->|account and path| TokenReader
    Git -->|non-empty| Echo["legacyEcho"]:::process
    Git -. "no branch" .-> Result
    GitHub --> Echo
    GitHub -. "unavailable" .-> Result
    Kubernetes --> Echo
    Kubernetes -. "unavailable" .-> Result
    Python --> Echo
    AWS -->|profile set| Echo
    AWS -->|profile missing| Result
    GCloud --> Echo
    Echo --> Result

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef external fill:#f1f5f9,stroke:#334155,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

Runner isolates domain processes, SQLiteTokenReader isolates token storage, and legacy-formatted section paths share the escape-expansion helper.

</details>

`ExecRunner` ignores execution errors and returns any captured stdout after
trimming trailing newlines. Tests substitute the `Runner` and `TokenReader`
interfaces without starting real processes or opening a real user database.

The GitHub section compares Git's directory-effective credential username with
the GitHub CLI's effective identity. Its normal account lookup is local and does
not test token validity or scopes. Environment tokens override host config and
therefore require an API identity lookup; pull-request inspection remains a
separate conditional operation.

Source: [`runner.go`](internal/prompt/runner.go),
[`simple.go`](internal/prompt/simple.go), [`git.go`](internal/prompt/git.go),
[`github.go`](internal/prompt/github.go), [`gcloud.go`](internal/prompt/gcloud.go),
and [`echo.go`](internal/prompt/echo.go). See
[ADR 0004](adrs/0004-keep-domain-clis-and-embed-sqlite.md) for the dependency
boundary and [ADR 0011](adrs/0011-compare-configured-github-identity-with-git-credentials.md)
for the Git and GitHub identity boundary.

## Build and portability

The Makefile is the development entry point. It detects the host with `uname`,
pins and downloads the matching Go toolchain, confines disposable state to the
project `tmp/` tree, builds without CGO, and supports macOS and Linux on both
`arm64` and `amd64`.

```mermaid
flowchart LR
    Make["Documented Make target"]:::input --> Detect["Host OS and arch detection"]:::process
    Detect --> Prepare["Prepare project tmp"]:::process
    Prepare --> Toolchain["Pinned host Go toolchain"]:::storage
    Toolchain --> Check["Checks and compatibility"]:::process
    Toolchain --> Build["CGO-free builds"]:::process
    Build --> Darwin["darwin arm64 and amd64"]:::output
    Build --> Linux["linux arm64 and amd64"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

Documented Make targets detect the host, prepare a local toolchain and caches, then check or build CGO-free binaries for macOS and Linux.

<details>
<summary>See the complete development pipeline</summary>

```mermaid
flowchart TD
    Developer["Developer"]:::input --> Make["Makefile"]:::process
    Make --> Prepare["prepare"]:::process
    Prepare --> Tmp["Project tmp tree"]:::storage
    Tmp --> Caches["Go caches and work dirs"]:::storage
    Make --> Bootstrap["bootstrap"]:::process
    Bootstrap --> Download["Download pinned host Go archive"]:::external
    Download --> Verify["Verify SHA-256"]:::process
    Verify --> Toolchain["Local Go toolchain"]:::storage

    Toolchain --> Check["check"]:::process
    subgraph Confidence["Confidence checks"]
        Check --> Fmt["fmt"]:::process
        Check --> Vet["vet"]:::process
        Check --> Race["race tests when supported"]:::process
        Check --> Coverage["100 percent statement coverage"]:::process
    end

    Toolchain --> Native["build native host"]:::process
    Toolchain --> Cross["build-all"]:::process
    Native --> Binary["bin joshpeak-prompt"]:::output
    Cross --> Darwin["darwin arm64 and amd64"]:::output
    Cross --> Linux["linux arm64 and amd64"]:::output
    Make --> Compat["compat"]:::process
    Oracle["Legacy zsh helpers"]:::external --> Compat
    Binary --> Compat
    Compat --> Report["Byte comparison report"]:::output

    classDef input fill:#dbeafe,stroke:#1e3a8a,color:#1e293b,stroke-width:2px
    classDef process fill:#ede9fe,stroke:#5b21b6,color:#1e293b,stroke-width:2px
    classDef external fill:#f1f5f9,stroke:#334155,color:#1e293b,stroke-width:2px
    classDef storage fill:#fef3c7,stroke:#92400e,color:#1e293b,stroke-width:2px
    classDef output fill:#d1fae5,stroke:#065f46,color:#1e293b,stroke-width:2px
```

The pipeline verifies a pinned toolchain, runs four confidence checks, compares live output with the zsh oracle, and creates native or cross-built binaries.

</details>

The supported hosts are macOS and Linux on `arm64` and `amd64`. `build-all`
cross-builds and commits one `bin/joshpeak-prompt-<os>-<arch>` binary per target,
and the zsh theme selects the host's binary at load. The renderer and ports use
portable Go APIs, so a new operating system needs only its toolchain checksum,
a `build-all` target, and compatibility fixtures. On a 39-bit-VMA kernel the race
detector cannot initialise, so the `race` target runs the suite without it and
warns; other hosts still enforce it.

Source: [Makefile](Makefile),
[`check-legacy.zsh`](scripts/check-legacy.zsh), and [`go.mod`](go.mod). See
[ADR 0003](adrs/0003-keep-development-state-under-project-tmp.md) for local
temporary state and [ADR 0014](adrs/0014-support-linux-and-commit-per-architecture-binaries.md)
for the platform boundary and per-architecture binaries.
