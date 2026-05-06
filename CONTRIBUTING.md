# Contributing to Local Cafe Hunter

## Branch Naming Convention

```
feature/<short-description>
bugfix/<short-description>
```

Examples:
- `feature/login-auth`
- `feature/map-view`
- `bugfix/null-cafe-list`

## Commit Message Format

```
<type>(<scope>): <short description>

[optional body]

[footer: Closes #<issue-number>]
```

### Types
| Type | Description |
|------|-------------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `refactor:` | Code restructure, no feature change |
| `style:` | UI tweak, formatting |
| `chore:` | Config, dependency |
| `test:` | Add/edit tests |

### Examples
```
feat(auth): implement Firebase email login
fix(map): resolve null exception on location load
style(login): align button per Figma v2
chore: add .env.example for API key setup
```

### Rules
- Title ≤ 72 characters
- Use **present tense** ("add" not "added")
- Reference issues: `Closes #12`
- English only

## Pull Request Process

1. Create branch from `dev` (not `main`)
2. Write code + tests
3. Fill PR template
4. Request review
5. Minimum 1 approval to merge
6. Delete branch after merge

## Git Flow

```
main     ───────────────────────── production
                          weekly merge
dev      ────●────────────●──────── integration
             \            /
feature/*   ──●── PR ────→ (approved + merge)
```

## Code Review Checklist

- [ ] Logic is correct
- [ ] Error handling present
- [ ] Variable/function names are clear
- [ ] No hardcoded API keys
- [ ] Loading state / UX feedback
- [ ] Lint pass (`flutter analyze`)
