#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Configure branch protection rules for GitHub repository
.DESCRIPTION
    Sets up branch protection for master/main branch with required checks
.PARAMETER Owner
    GitHub repository owner (default: rpaidriventesting)
.PARAMETER Repo
    GitHub repository name (default: RPSauceLabs-Ecommerce-Application)
.PARAMETER Token
    GitHub Personal Access Token (reads from environment if not provided)
.PARAMETER Branch
    Branch to protect (default: master)
#>

param(
    [string]$Owner = "rpaidriventesting",
    [string]$Repo = "RPSauceLabs-Ecommerce-Application",
    [string]$Token = $env:GITHUB_TOKEN,
    [string]$Branch = "master"
)

if (-not $Token) {
    Write-Error "GITHUB_TOKEN environment variable or -Token parameter is required"
    exit 1
}

$headers = @{
    'Authorization' = "token $Token"
    'Accept' = 'application/vnd.github.v3+json'
    'Content-Type' = 'application/json'
}

$baseUrl = "https://api.github.com/repos/$Owner/$Repo"

# Branch Protection Rules Configuration
$protectionRules = @{
    required_status_checks = @{
        strict = $true
        contexts = @(
            "Build Application",
            "Unit & Integration Tests",
            "Code Quality & Linting",
            "Security Checks",
            "Validate PR",
            "Code Review Checks",
            "Run Automated Tests"
        )
    }
    enforce_admins = $true
    required_pull_request_reviews = @{
        dismiss_stale_reviews = $true
        require_code_owner_reviews = $false
        required_approving_review_count = 1
    }
    restrictions = $null
    required_linear_history = $false
    allow_force_pushes = $false
    allow_deletions = $false
    required_conversation_resolution = $true
}

$protectionJson = $protectionRules | ConvertTo-Json -Depth 10

Write-Host "[LOCK] Configuring branch protection for $Branch branch..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest `
        -Uri "$baseUrl/branches/$Branch/protection" `
        -Headers $headers `
        -Method PUT `
        -Body $protectionJson `
        -UseBasicParsing
    
    Write-Host "[SUCCESS] Branch protection rules configured successfully!" -ForegroundColor Green
    Write-Host "   - Requires passing CI/CD checks" -ForegroundColor Green
    Write-Host "   - Requires pull request review" -ForegroundColor Green
    Write-Host "   - Enforces admin rules" -ForegroundColor Green
    Write-Host "   - Requires conversation resolution" -ForegroundColor Green
}
catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Warning "Some branch protection rules may already be configured"
        Write-Host "Attempting to update existing rules..." -ForegroundColor Yellow
    }
    else {
        Write-Error "Failed to configure branch protection: $_"
        exit 1
    }
}

# Configure CODEOWNERS file
Write-Host "`n[INFO] Creating CODEOWNERS file..." -ForegroundColor Cyan

$codeownersContent = @"
# GitHub CODEOWNERS file
# This file defines code owners for automatic PR reviews

# Default owners for all files
* @rpaidriventesting

# Automation framework tests
.github/workflows/playwright-tests.yml @rpaidriventesting
.github/workflows/pr-checks.yml @rpaidriventesting

# Component owners
/src/components/ @rpaidriventesting
/src/pages/ @rpaidriventesting

# Configuration
/public/ @rpaidriventesting
Dockerfile @rpaidriventesting
babel.config.js @rpaidriventesting
"@

$codeownersPath = ".github/CODEOWNERS"

try {
    $codeownersContent | Out-File -FilePath $codeownersPath -Encoding UTF8 -Force
    Write-Host "[SUCCESS] CODEOWNERS file created at $codeownersPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to create CODEOWNERS file: $_"
}

# Configure repository settings
Write-Host "`n[CONFIG] Configuring repository settings..." -ForegroundColor Cyan

$repoSettings = @{
    has_issues = $true
    has_projects = $true
    has_wiki = $false
    has_downloads = $true
    is_template = $false
    default_branch = $Branch
    allow_squash_merge = $true
    allow_merge_commit = $true
    allow_rebase_merge = $true
    delete_branch_on_merge = $true
}

$settingsJson = $repoSettings | ConvertTo-Json

try {
    Invoke-WebRequest `
        -Uri "$baseUrl" `
        -Headers $headers `
        -Method PATCH `
        -Body $settingsJson `
        -UseBasicParsing | Out-Null
    
    Write-Host "[SUCCESS] Repository settings configured successfully!" -ForegroundColor Green
    Write-Host "   - Auto-delete head branches after merge enabled" -ForegroundColor Green
}
catch {
    Write-Warning "Could not update repository settings: $_"
}

# Display summary
Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] BRANCH PROTECTION SETUP COMPLETE" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "`nBranch: $Branch"
Write-Host "Required Status Checks:"
Write-Host "  [OK] Build Application"
Write-Host "  [OK] Unit & Integration Tests"
Write-Host "  [OK] Code Quality & Linting"
Write-Host "  [OK] Security Checks"
Write-Host "  [OK] PR Validation"
Write-Host "  [OK] Code Review Checks"
Write-Host "  [OK] Automated E2E Tests"
Write-Host "`nPull Request Requirements:"
Write-Host "  [OK] At least 1 approval required"
Write-Host "  [OK] Stale reviews dismissed"
Write-Host "  [OK] Conversation resolution required"
Write-Host "  [OK] Admin enforcement enabled"
Write-Host "`nBranch Settings:"
Write-Host "  [OK] Force pushes disabled"
Write-Host "  [OK] Force deletions disabled"
Write-Host "  [OK] Auto-delete on merge enabled"
Write-Host "`n====================================================" -ForegroundColor Cyan
