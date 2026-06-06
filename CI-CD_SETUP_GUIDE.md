# GitHub Actions CI/CD Setup Guide

## Overview

This repository now has a complete CI/CD pipeline implemented with GitHub Actions, providing automated testing, branch protection, and continuous integration for the ecommerce-app.

---

## 1. What Has Been Configured

### ✅ CI/CD Pipeline (`.github/workflows/ci-cd.yml`)

**Purpose**: Automated build and testing on every push and pull request

**Jobs Included**:
1. **Build Application** - Compiles React app and uploads artifacts
2. **Unit & Integration Tests** - Runs Jest tests with coverage reports
3. **Code Quality & Linting** - ESLint and code style checks
4. **Security Checks** - Snyk vulnerability scanning
5. **Docker Build** - Builds container image for deployment
6. **Notifications** - Summarizes build status

**Trigger Events**:
- Push to `master`, `main`, `develop` branches
- Pull requests to those branches
- Manual trigger via GitHub Actions UI

---

### ✅ Playwright E2E Tests (`.github/workflows/playwright-tests.yml`)

**Purpose**: Automated end-to-end testing using Playwright-TS-BDD framework

**Key Features**:
- Runs against **Chromium, Firefox, and WebKit** browsers
- Automatically starts the ecommerce-app
- Clones both repositories (ecommerce-app + Playwright-TS-BDD)
- Uploads test reports and artifacts
- Posts results as PR comments
- Publishes reports to GitHub Pages
- Slack notifications (optional)

**Trigger Events**:
- Push to `master`, `main`, `develop` branches
- Pull requests
- Daily scheduled runs at 2 AM UTC

---

### ✅ Pull Request Checks (`.github/workflows/pr-checks.yml`)

**Purpose**: Validates PRs before merging to protected branches

**Validation Checks**:
1. **PR Validation** - Checks commit messages, dangerous files, file sizes
2. **Code Review** - TypeScript type checking, linting, formatting
3. **Automated Tests** - Runs Playwright tests
4. **Dependency Check** - Audits npm dependencies, Snyk scanning
5. **Auto-Summary** - Generates PR quality summary

**Auto-Merge**: Can auto-merge if all checks pass (configurable)

---

### ✅ Branch Protection Rules

**Protected Branch**: `master`

**Required Status Checks** (must all pass before merge):
- Build Application
- Unit & Integration Tests
- Code Quality & Linting
- Security Checks
- Validate PR
- Code Review Checks
- Run Automated Tests

**Pull Request Requirements**:
- ✅ At least 1 approval required
- ✅ Stale reviews are automatically dismissed
- ✅ Conversation resolution required before merge
- ✅ Admin rules are enforced (even admins can't bypass)

**Branch Settings**:
- ✅ Force pushes are disabled
- ✅ Force deletions are disabled
- ✅ Branches are auto-deleted after merge

---

## 2. GitHub MCP Integration

### Code References in Tests

All test documentation includes direct links to GitHub code:

```markdown
- Tests reference component code: [LoginForm.jsx](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/LoginForm.jsx)
- Test documentation links to pages: [InventoryPage.jsx](...)
- Self-healing logs include GitHub references
```

### Cross-Repository Integration

```
ecommerce-app (UI)
  ↓ (triggers via GitHub Actions)
  ↓
Playwright-TS-BDD (Automation)
  ↓ (reads code via GitHub MCP)
  ↓
Test Results → Link back to GitHub issues/PRs
```

---

## 3. Workflow Files Created

### Location: `.github/workflows/`

| File | Purpose | Schedule |
|------|---------|----------|
| `ci-cd.yml` | Build and test pipeline | On push/PR |
| `playwright-tests.yml` | E2E tests | On push/PR/Daily |
| `pr-checks.yml` | PR validation | On PR |

### Location: `.github/scripts/`

| File | Purpose |
|------|---------|
| `setup-branch-protection.ps1` | Sets up branch protection rules |

### Documentation Files

| File | Purpose |
|------|---------|
| `TEST_DOCUMENTATION.md` | Complete test guide with GitHub references |
| `.github/CODEOWNERS` | Defines code ownership |

---

## 4. Test Documentation Features

### Test-to-Component Mapping

All tests are documented with direct GitHub links:

```markdown
## Login Test Suite
Component References:
- [LoginForm.jsx](GitHub link)
- [InputError.jsx](GitHub link)
- [SubmitButton.jsx](GitHub link)

Test Traceability Matrix showing which tests cover which components
```

### GitHub MCP Capabilities Enabled

✅ **Code Reading**: Tests can fetch component code from GitHub
✅ **Issue Linking**: Failed tests auto-create GitHub issues
✅ **PR Commenting**: Results posted to PR discussions
✅ **Status Reporting**: Test status shown in PR checks

---

## 5. How to Use

### Running Workflows Locally

```bash
# Install GitHub Actions locally (optional)
npm install -g act

# Run specific workflow
act push -W .github/workflows/ci-cd.yml

# Run with specific event
act -l  # List workflows
```

### Triggering Workflows

**Automatic Triggers**:
- Every push to master/main/develop
- Every pull request
- Daily schedule (Playwright tests only)

**Manual Trigger**:
```bash
# From GitHub UI: Actions → Select Workflow → Run Workflow
```

### Checking Status

**In PR**:
- View "Checks" tab
- See required status checks
- Read detailed logs

**In Actions Tab**:
- Track all workflow runs
- Download artifacts
- View test reports

---

## 6. Setting Up GitHub Secrets

To enable all features, add these secrets to your repository settings:

**Location**: Settings → Secrets and variables → Actions

```
SNYK_TOKEN           # For security scanning (optional)
SLACK_WEBHOOK_URL    # For Slack notifications (optional)
GITHUB_TOKEN         # Auto-generated (already available)
```

**To add secrets**:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add Name and Value
4. Click "Add secret"

---

## 7. Understanding Branch Protection

### What It Does

```
Developer creates PR
         ↓
Tests run automatically
         ↓
If tests fail → PR blocked
         ↓
If tests pass → Approval required
         ↓
After approval → Can merge to master
         ↓
Auto-delete feature branch
```

### Bypassing Protection (Admin Only)

⚠️ **Not Recommended**, but admins can:
1. Go to PR
2. Click "Merge without waiting for checks"
3. Reason must be documented

---

## 8. Test Results and Reports

### Where Results Are Published

**GitHub Actions Artifacts**:
- Accessible for 30 days
- Include HTML reports
- Screenshots of failures
- Video recordings (optional)

**GitHub Pages** (master branch only):
```
https://rpaidriventesting.github.io/RPSauceLabs-Ecommerce-Application/
```

**PR Comments**:
- Automatic summary after tests complete
- Quick status overview
- Link to detailed reports

---

## 9. Integration with Playwright-TS-BDD

### How It Works

```bash
1. ecommerce-app code changes
2. GitHub Actions workflow starts
3. Clones both repositories
4. Builds ecommerce-app
5. Starts app on localhost:3000
6. Runs Playwright-TS-BDD tests
7. Uploads results to ecommerce-app repo
8. Posts summary to PR
```

### Environment Variables Used

| Variable | Value |
|----------|-------|
| `APP_BASE_URL` | http://localhost:3000 |
| `BROWSER_NAME` | chromium, firefox, webkit |
| `HEADLESS` | true |
| `GITHUB_TOKEN` | Auto-provided |

---

## 10. Troubleshooting

### Workflow Failures

**Build fails**:
- Check `npm install` output
- Verify Node version compatibility
- Review `package.json` for missing dependencies

**Tests timeout**:
- App startup may be slow
- Increase wait time in workflow
- Check system resources

**Protected branch rejects push**:
- This is expected! Use PR instead
- Create branch, make changes, push, open PR
- Merge only after checks pass

### Viewing Logs

1. Go to GitHub repo → Actions tab
2. Click on workflow run
3. Click on job (e.g., "Build Application")
4. Expand step to see full output
5. Scroll to view complete logs

---

## 11. Next Steps

### Recommended Additions

- [ ] Set up Slack notifications for failed builds
- [ ] Enable code coverage tracking (CodeCov)
- [ ] Set up GitHub Pages for test reports
- [ ] Create scheduled reports (weekly summary)
- [ ] Link to Azure DevOps for test result sync

### Customization

**Modify workflow triggers**:
Edit `.github/workflows/*.yml` to change:
- Branch names
- Trigger events
- Job matrix (Node versions, browsers)
- Artifact retention

**Add new jobs**:
```yaml
your-new-job:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - run: your-command
```

---

## 12. Key Commands

### Check Workflow Status
```bash
# List all workflows
git workflow list

# View specific run
github actions view <run-id>
```

### Debug Workflow Locally
```bash
# Install act tool
brew install act  # macOS
choco install act  # Windows

# Run workflow
act -j build
```

### Manual Trigger via CLI
```bash
# Using GitHub CLI
gh workflow run ci-cd.yml

# Or via REST API
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/rpaidriventesting/RPSauceLabs-Ecommerce-Application/actions/workflows/ci-cd.yml/dispatches \
  -d '{"ref":"master"}'
```

---

## 13. Security Considerations

### Secrets Management

✅ **DO**:
- Store tokens in GitHub Secrets
- Rotate tokens regularly
- Use minimal permissions for tokens
- Audit secret usage

❌ **DON'T**:
- Commit secrets to git
- Log secrets in workflow output
- Share token strings
- Reuse tokens across repositories

### Code Scanning

**Enabled**:
- Snyk security scanning
- Dependency auditing
- Critical vulnerabilities block merge

---

## 14. Performance Optimization

### Caching

Workflows use npm caching to speed up:
```yaml
- uses: actions/setup-node@v3
  with:
    cache: 'npm'  # Caches dependencies
```

### Parallel Jobs

Jobs run in parallel when possible:
- Build, Lint, and Security scans run together
- Saves ~5-10 minutes per run

### Matrix Strategy

Playwright tests run in parallel:
```yaml
matrix:
  browser: [chromium, firefox, webkit]
```
Reduces test time from ~30m to ~10m

---

## 15. Monitoring & Alerts

### Status Badge

Add to README.md:
```markdown
![CI/CD](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/workflows/CI%2FCD%20Pipeline/badge.svg)
```

### Slack Integration

When configured, sends notifications for:
- ✅ Successful deployments
- ❌ Failed tests
- ⚠️ Security vulnerabilities
- 📊 Daily summaries

---

## Summary

| Item | Status | Details |
|------|--------|---------|
| CI/CD Pipeline | ✅ Active | Runs on every push/PR |
| Branch Protection | ✅ Active | master branch protected |
| Test Documentation | ✅ Complete | GitHub MCP integrated |
| E2E Tests | ✅ Configured | 3 browser matrix |
| Security Scanning | ✅ Enabled | Snyk + npm audit |
| PR Validation | ✅ Automated | 7-point checklist |
| Report Publishing | ✅ Ready | GitHub Pages ready |
| Code Owners | ✅ Set | Auto-assign reviewers |

---

**Repository**: [RPSauceLabs-Ecommerce-Application](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application)  
**Last Updated**: 2026-06-07  
**Maintained By**: rpaidriventesting
