# Test Documentation with GitHub MCP Integration

## Overview

This document demonstrates how the Playwright-TS-BDD automation framework integrates with the ecommerce-app repository through GitHub MCP, allowing automated test references to live code in GitHub.

---

## 1. Architecture Overview

### GitHub MCP Integration Points

```
┌─────────────────────────────────────┐
│   GitHub Repository (ecommerce-app) │
│   - React UI Code                   │
│   - Components                      │
│   - Pages                           │
└──────────────┬──────────────────────┘
               │
               ├─► [GitHub MCP]
               │   (Read Code References)
               │
               └─► [Playwright-TS-BDD]
                   (Automation Tests)
```

### Key Components Referenced

| Component | Path | Purpose |
|-----------|------|---------|
| Login Component | [`src/components/LoginForm.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/LoginForm.jsx) | User authentication UI |
| Inventory Page | [`src/pages/InventoryPage.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/pages/InventoryPage.jsx) | Product listing page |
| Cart Component | [`src/components/CartItem.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/CartItem.jsx) | Shopping cart items |
| Header Container | [`src/components/HeaderContainer.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/HeaderContainer.jsx) | Navigation header |

---

## 2. Test Suite Mapping to Components

### Login Test Suite
**File**: `features/sauce-labs-login-journey.feature`

**Purpose**: Test user authentication flow

**Component References**:
- Tests interact with [`LoginForm.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/LoginForm.jsx)
- Validates form submission logic
- Verifies error handling in [`InputError.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/InputError.jsx)

**Test Cases**:
```gherkin
Scenario: Standard User Login and Logout
  Given I navigate to the login page
  When I enter valid credentials
  And I click the login button
  Then I should be redirected to inventory page
  And I should see the logged-in user name
```

**Code Under Test** (from GitHub):
```jsx
// From src/components/LoginForm.jsx
<form onSubmit={handleSubmit}>
  <input
    type="username"
    placeholder="Username"
    value={username}
    onChange={(e) => setUsername(e.target.value)}
  />
  <input
    type="password"
    placeholder="Password"
    value={password}
    onChange={(e) => setPassword(e.target.value)}
  />
  <button type="submit">LOGIN</button>
</form>
```

---

### Inventory Management Test Suite

**File**: `features/inventory-management.feature` (Example)

**Component References**:
- [`InventoryPage.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/pages/InventoryPage.jsx) - Main inventory listing
- [`InventoryListItem.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/InventoryListItem.jsx) - Individual item rendering
- [`CartButton.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/CartButton.jsx) - Add to cart functionality

**Test Scenarios**:
```gherkin
Scenario: Add Product to Cart
  Given I am logged in and on the inventory page
  When I click add to cart on a product
  Then the product should be added to cart
  And cart count should increase

Scenario: Remove Product from Cart
  Given I have items in my cart
  When I click remove from cart
  Then the product should be removed
  And cart count should decrease
```

---

### Checkout Flow Test Suite

**Component References**:
- [`CheckoutPage.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/pages/CheckoutPage.jsx) - Checkout processing
- [`CartItem.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/CartItem.jsx) - Cart item display
- [`Button.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/Button.jsx) - Generic button component
- [`SubmitButton.jsx`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/SubmitButton.jsx) - Form submission

**Test Scenarios**:
```gherkin
Scenario: Complete Purchase
  Given I have items in my cart
  When I proceed to checkout
  And I enter shipping details
  And I confirm payment
  Then I should see order confirmation
  And order number should be displayed
```

---

## 3. GitHub MCP Usage Examples

### Fetching Component Code References

Using GitHub MCP, tests can reference and validate component behavior:

```typescript
// Example: Referencing component from GitHub
import { mcp_github } from '@modelcontextprotocol/client-github';

async function fetchComponentCode(path: string) {
  const code = await mcp_github.getFileContents({
    owner: 'rpaidriventesting',
    repo: 'RPSauceLabs-Ecommerce-Application',
    path: path
  });
  return code;
}

// Usage in test setup
const loginFormCode = await fetchComponentCode('src/components/LoginForm.jsx');
```

### Linking Test Results to GitHub Issues

```typescript
// Auto-link failed tests to GitHub issues
async function linkTestFailureToGitHub(testName: string, error: string) {
  await mcp_github.createIssue({
    owner: 'rpaidriventesting',
    repo: 'RPSauceLabs-Ecommerce-Application',
    title: `🔴 Test Failed: ${testName}`,
    body: `Test failure detected:\n\n${error}\n\nAutomated from Playwright-TS-BDD`
  });
}
```

---

## 4. Test Traceability Matrix

| Test Name | Component(s) | File Path | Status |
|-----------|-----------|-----------|--------|
| Login with Valid Credentials | LoginForm | `src/components/LoginForm.jsx` | ✅ PASS |
| Login with Invalid Credentials | InputError | `src/components/InputError.jsx` | ✅ PASS |
| Add to Cart | CartButton, CartItem | `src/components/Cart*.jsx` | ✅ PASS |
| Remove from Cart | CartItem | `src/components/CartItem.jsx` | ✅ PASS |
| View Inventory | InventoryPage, InventoryListItem | `src/pages/InventoryPage.jsx` | ✅ PASS |
| Complete Checkout | CheckoutPage, SubmitButton | `src/pages/CheckoutPage.jsx` | ✅ PASS |

---

## 5. Self-Healing Framework with GitHub References

The self-healing framework tracks locator changes:

```typescript
// Healing logs reference GitHub components
{
  "timestamp": "2026-06-07T10:30:00Z",
  "test": "Login with Valid Credentials",
  "component": "src/components/LoginForm.jsx",
  "original_selector": "button[type='submit']",
  "healed_selector": "button.login-btn",
  "github_reference": "https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/src/components/LoginForm.jsx",
  "healing_method": "text_match",
  "status": "healed"
}
```

---

## 6. CI/CD Integration

### GitHub Actions Workflow Reference

The automated tests are triggered by GitHub Actions:

**Workflow Files**:
- [`ci-cd.yml`](.github/workflows/ci-cd.yml) - Main CI/CD pipeline
- [`playwright-tests.yml`](.github/workflows/playwright-tests.yml) - E2E test execution
- [`pr-checks.yml`](.github/workflows/pr-checks.yml) - Pull request validation

**Trigger Events**:
- ✅ Push to master/main/develop
- ✅ Pull requests
- ✅ Scheduled daily runs
- ✅ Manual dispatch

---

## 7. Test Report Integration

### Accessing Test Results

Test reports are automatically published to GitHub Pages:
```
https://rpaidriventesting.github.io/RPSauceLabs-Ecommerce-Application/
```

### Report Contents

Each test report includes:
- ✅ Test execution summary
- ✅ Browser compatibility matrix
- ✅ Screenshots for failures
- ✅ Self-healing logs
- ✅ Performance metrics
- ✅ Component coverage

---

## 8. Cross-Repository References

### Linking Between Repos

```
ecommerce-app (UI Code)
  └─ .github/workflows/playwright-tests.yml
     └─ Triggers tests from:
        Playwright-TS-BDD (Automation Framework)
           └─ src/steps/
           └─ src/pages/
           └─ src/core/
```

### Repository Links

| Repository | Purpose | Link |
|------------|---------|------|
| ecommerce-app | React UI Application | [GitHub](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application) |
| Playwright-TS-BDD | Automation Framework | [GitHub](https://github.com/rpaidriventesting/Playwright-TS-BDD) |

---

## 9. Setting Up GitHub MCP Locally

To enable GitHub MCP features in your tests:

```bash
# 1. Configure environment variables
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
export GITHUB_REPO=rpaidriventesting/RPSauceLabs-Ecommerce-Application

# 2. Install GitHub MCP package
npm install @modelcontextprotocol/server-github

# 3. Configure in mcp.json
{
  "servers": {
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github@latest"],
      "type": "stdio",
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_TOKEN"
      }
    }
  }
}
```

---

## 10. Troubleshooting

### Common Issues

| Issue | Solution | Reference |
|-------|----------|-----------|
| Tests fail on component changes | Check [`src/components/`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/tree/master/src/components) for recent changes | Self-Healing Framework |
| Selectors not found | Use GitHub MCP to verify latest selectors | GitHub Code View |
| Build failures | Check [`package.json`](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application/blob/master/package.json) for dependency issues | GitHub Raw View |

---

## 11. Best Practices

✅ **DO:**
- Reference components via GitHub MCP in test documentation
- Link test failures to GitHub issues automatically
- Use GitHub Actions to trigger tests on code changes
- Maintain test-to-component mapping
- Update documentation when components change

❌ **DON'T:**
- Hardcode component selectors without GitHub reference
- Run tests without verifying component code
- Ignore healing logs that indicate component changes
- Forget to link test results back to GitHub
- Skip component documentation updates

---

## 12. Further Reading

- [Playwright Documentation](https://playwright.dev)
- [Playwright-TS-BDD Framework](https://github.com/rpaidriventesting/Playwright-TS-BDD)
- [GitHub MCP Documentation](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [Self-Healing Framework Guide](https://github.com/rpaidriventesting/Playwright-TS-BDD#self-healing)

---

**Last Updated**: 2026-06-07  
**Maintained By**: rpaidriventesting  
**Repository**: [RPSauceLabs-Ecommerce-Application](https://github.com/rpaidriventesting/RPSauceLabs-Ecommerce-Application)
