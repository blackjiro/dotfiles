# Claude Code Global Instructions

## Language and Documentation

Generate all markdown documents in Japanese unless otherwise specified.

## Pull Request Creation

Commit changes first if needed. Use `.github/pull_request_template.md` format if exists. Title in semantic versioning style (same language as template). Keep body concise.

## Git Commit Policy

**IMPORTANT**: Never create git commits unless explicitly instructed by the user. Only commit changes when the user specifically asks you to do so.

## Development Principles

Follow Kent Beck's TDD and Tidy First approach. Simplicity first.

## GitHub Operations

Use `gh` CLI for viewing GitHub issues and pull requests.

## Behavior-Driven Test Principles

Follow these principles when writing tests:

### Test Targets
- Test only public/exported interfaces
- Do NOT test private functions or internal implementations

### Mocking Policy
- Self-managed resources (DB, etc.): Do NOT mock, use real connections
- External APIs (paid services, AI APIs, etc.): Mock them

### Test Granularity
- Test end-to-end behavior flows (e.g., API request → response)

### Test Code and Production Code Boundary
- Never modify production code to accommodate test concerns

### Expensive Tests
- Control with `RUN_EXPENSIVE_TESTS=1` environment variable
- Skip in regular CI runs

### Real Database Testing Setup
If the project lacks infrastructure for real DB testing, discuss with the user first:
1. Check if testcontainers, docker-compose, or similar setup exists
   - Look for: `testcontainers` in dependencies, `docker-compose.test.yml`, `.devcontainer/`
2. If not, propose and implement the test infrastructure before writing tests
   - **testcontainers**: Recommended (programmatic container management)
   - **docker-compose**: Good for complex multi-service setups
   - **In-memory DB**: SQLite for simple cases (limited compatibility)
