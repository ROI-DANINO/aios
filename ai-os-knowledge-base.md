ai-os-knowledge-base.md
1. Core Concepts

    The Second Brain: An AI system that manages your digital life, stores decisions, summarizes content, and connects ideas, acting as a personal operations hub.
    Business Pods: Breaking workflows down into four core engines: Acquisition, Delivery, Support, and Operations. Focusing on one pod at a time prevents system bloat.
    Adversarial Review & The "Wedge": The idea that before building, you should rigorously pressure-test your assumptions to find the "wedge" (the smallest, most valuable version of the product) and uncover the "10-star product" hidden within the initial idea.
    Subagent-Driven Development: A workflow where a primary agent dispatches fresh, specialized subagents for distinct tasks (e.g., a CEO agent hiring a QA agent or engineer), inspecting their work before continuing.
    Deterministic vs. Non-Deterministic Boundaries: Using AI (non-deterministic) for reasoning and content generation, but using strict code, hooks, and standard operating procedures (deterministic) for safety, file routing, and destructive commands.

2. Architecture & Stack

    Orchestration Layer: Claude Code / Claude Agent SDK. This acts as the "brain," delegating tasks, managing conversation history, and handling local files.
    Company Orchestration & Web UI: Paperclip, an open-source tool that provides a Web UI dashboard for your terminal backend. It creates a "zero-human company" structure, managing a team of specialized AI agents (CEO, engineers, QA), tracking budgets, and running "heartbeats" (scheduled wake-ups for agents to execute tasks).
    Execution Layer (Skills): Composable markdown-based files (.md) that act as standard operating procedures, giving agents step-by-step instructions and tools to execute specific tasks.
    Memory & Data Layer: Local Markdown files (context/, data/) for storing system rules, second-brain connections, and daily workflows. This is highly efficient and avoids the need for complex database setups.
    Infrastructure & Rules: A central claude.md file acts as the system handbook, while a rules/guardrails.md file (or .sh scripts) prevents destructive commands.

3. Key Tools & Integrations

    Superpowers Framework: A GitHub integration that enforces a disciplined software development workflow. It guarantees test-driven development (TDD), writes explicit plans before coding, and manages Git worktrees automatically.
    YC (Y Combinator) CEO Toolkit: A set of Claude Code skills for scoping projects. Includes /office-hours (pushes back on ideas), /ceo-review (adversarial reviews), and /document-release (automatically updates system documentation when code changes).
    Model Context Protocol (MCP): The standard for connecting the AI OS to external tools securely.
    GitHub: Essential for version control, collaboration, and backing up the AI OS.

4. Step-by-Step Build Patterns

    Scope & Design (The YC Pattern): Start by running the YC /office-hours and /ceo-review skills to lock in the product direction. Generate a design system using /design-consultation, followed by defining the exact system architecture.
    Initialize Environment: Create a root folder, add claude.md to define the workspace as a personal operations hub, and create context/ and data/ directories.
    The Superpowers Dev Loop:
        Trigger brainstorming to refine specs.
        Trigger using-git-worktrees to isolate branches.
        Trigger writing-plans for 2-5 minute micro-tasks.
        Trigger subagent-driven-development and test-driven-development to enforce RED-GREEN-REFACTOR execution.
        Trigger requesting-code-review and finishing-a-development-branch.
    Documentation Sync: After any code loop, use the YC /document-release skill to read code diffs and automatically update system architecture and change logs.

5. Decisions & Trade-offs

    Batteries-Included SDKs vs. Ground-Up Frameworks: Building on the Claude Agent SDK is slightly slower and more token-heavy than a raw framework (like Pydantic AI), but it saves massive amounts of infrastructure glue-code and natively handles complex reasoning, subagents, and skills.
    Local MD vs. Vector Databases (RAG): For personal second brains and standard business operations, complex semantic search (RAG) is usually overkill. Local markdown files paired with native file-search out-perform complex RAG setups on small-to-medium datasets.
    Security vs. Autonomy: AI should never have open "write" or "send" access to external systems without a human-in-the-loop approval mechanism. Always enforce the principle of "least privilege".

6. Quotes & Key Moments Worth Preserving

    "There is often a 10-star product hidden within your current product."
    "It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY."
    "If you don't update documentation, you have a snake in the grass that is going to bite you at every chance it gets."
    "You don't just want to give everything access to everything... Always work from the position of least privilege."

7. My Customisations
Vision: A dev-first, tailor-made AI OS to manage my daily work and coding projects. Interface: A dual-layer system using a terminal-based backend for raw development power, paired with a web UI (via Paperclip) for a visual mission control center. Team & Collaboration: Designed with GitHub integration and multi-agent teams in mind so I can delegate tasks visually while the system manages the Git branches. Second Brain Focus: The OS must act as my digital memory—storing architectural decisions, summarizing imported content, connecting disparate ideas, and organizing my workflow via "business pods." Vibe: Futuristic but highly practical. Strictly disciplined when writing code (TDD, isolated branches) but expansive and adversarial when brainstorming.
8. Claude Code Build Instructions

Hey Claude! I am building my custom "AI Operating System" and Second Brain, and I am learning as I go. 

WHAT WE ARE BUILDING:
A dev-first AI OS that features a terminal backend (powered by you) and a Web UI dashboard (powered by Paperclip). It acts as my second brain to store decisions, summarize content, and connect ideas, while operating strictly on the "Superpowers" agentic workflow and the "Y Combinator CEO" framework for scoping.

YOUR DIRECTIVES:
1. Act as my expert senior engineer and architect. I will rely on you to explain complex configurations (like setting up Paperclip, MCP servers, and webhooks) in plain, simple English as we encounter them.
2. Never assume we are rushing. Walk me through this build step-by-step.
3. Check in with me at the end of every single stage for approval before writing massive amounts of code or moving to the next feature.
4. Enforce strict Test-Driven Development (TDD) and automatically use the YC Document Release pattern to keep our documentation updated whenever we change the codebase.
5. Prioritize security—always ask my permission before granting an agent "write" or "send" access.

Let's start by initializing our directory, setting up our `claude.md` file, and configuring our core agent team in Paperclip. What is our very first technical step?

--------------------------------------------------------------------------------
📝 Note on Filtered Information
Per your request, I heavily filtered the following concepts from the source material to keep your knowledge base dense and relevant to your specific build:

    Non-Coding Agent Frameworks: I excluded the deep dives into Pydantic AI, LangChain, n8n, and building raw agent loops from scratch, as you are utilizing the Claude SDK and Paperclip for orchestration.
    Extensive RAG/Database Setups: I omitted the setup instructions for vector databases, semantic search pipelines, and enterprise-level GraphRAG, as the sources explicitly advise using local markdown files for standard Second Brains.
    Specific Business Integrations: I left out the deep tutorials on using Apollo, Firecrawl, and LinkedIn Sales Navigator for automated cold outreach, as your focus is dev-first and second-brain oriented.
    Telegram/Discord Frontends: I excluded the sections about piping the AI OS into Telegram or Discord channels, prioritizing your requested Web UI/Terminal backend combo.