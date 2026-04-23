---
name: fix-types
description: Fix all type checking errors across the project. Use when the user wants to resolve type checker issues.
---

Fix all type checking errors across the project.

## Instructions

1. Detect the type checker configured for the project (look for pyrightconfig.json, mypy.ini, pyproject.toml [tool.mypy] or [tool.pyright], setup.cfg [mypy]). If none is found, default to `pyright` with basic mode.
2. Run the type checker on the project source directories and capture the full output.
3. Group the errors by file.
4. For each file with errors, read the file, understand the context, and fix the type issues. Apply the minimal fix that makes the type checker happy without changing runtime behavior. Common fixes include:
   - Adding `| None` to parameter types that accept None
   - Adding `assert x is not None` or `if x is not None:` guards
   - Using proper type narrowing or casts
   - Fixing incorrect type annotations
   - Adding missing attributes to models/classes
   - Using `Sequence` instead of `list` for covariant type parameters
   - Using proper TypedDict or typed constructors instead of untyped dicts
5. After fixing all files, run the type checker again to verify 0 errors remain.
6. If new errors appear from your fixes, fix those too. Repeat until clean.
7. Run the existing tests to make sure nothing is broken.

## Rules

- Do NOT add `# type: ignore` or `# pyright: ignore` comments. Fix the actual types.
- Do NOT change runtime behavior. Only fix type annotations and add type guards.
- Do NOT add unnecessary imports.
- Prefer the simplest fix: a type guard (`assert`, `if`) over refactoring.
- When a Pydantic model is missing fields, add them to the model if they should exist, or fix the calling code if the field access is wrong.
