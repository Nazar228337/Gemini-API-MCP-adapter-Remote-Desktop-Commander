$ErrorActionPreference = "Stop"

try {
    $Project = Join-Path ([Environment]::GetFolderPath("Desktop")) "GeminiMCPAdapter"
    Clear-Host
    Write-Host ""
    Write-Host "   GGGG   EEEEE  M   M  III  N   N  III" -ForegroundColor Magenta
    Write-Host "  G       E      MM MM   I   NN  N   I " -ForegroundColor Magenta
    Write-Host "  G  GGG  EEEE   M M M   I   N N N   I " -ForegroundColor Magenta
    Write-Host "   G  G   E      M   M   I   N  NN   I " -ForegroundColor Magenta
    Write-Host "    GGG   EEEEE  M   M  III  N   N  III" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "          GEMINI <-> MCP ADAPTER" -ForegroundColor Yellow
    Write-Host "===================================================" -ForegroundColor DarkCyan

    if (-not (Test-Path (Join-Path $Project "adapter.py"))) {
        throw "adapter.py not found in $Project"
    }
    Set-Location $Project

    if (-not $env:GEMINI_API_KEY) {
        $env:GEMINI_API_KEY = Read-Host "Enter Gemini API key (input is visible)"
    }
    if ([string]::IsNullOrWhiteSpace($env:GEMINI_API_KEY)) {
        throw "API key is empty."
    }

    if (-not $env:GEMINI_MODEL) { $env:GEMINI_MODEL = "gemini-3.8-flash" }
    if (-not $env:MCP_URL) {
        $defaultUrl = "https://mcp.desktopcommander.app/mcp"
        $answer = Read-Host "MCP URL (press Enter for $defaultUrl)"
        if ([string]::IsNullOrWhiteSpace($answer)) { $answer = $defaultUrl }
        $env:MCP_URL = $answer
    }
    if (-not $env:MCP_TRANSPORT) { $env:MCP_TRANSPORT = "streamable-http" }
    $env:AUTO_APPROVE = "true"

    $venvPython = Join-Path $Project ".venv\Scripts\python.exe"
    if (-not (Test-Path $venvPython)) {
        Write-Host "Creating virtual environment..." -ForegroundColor Yellow
        & py -m venv (Join-Path $Project ".venv")
        if ($LASTEXITCODE -ne 0) { throw "Could not create virtual environment." }
    }
    $venvPython = Join-Path $Project ".venv\Scripts\python.exe"

    Write-Host "Checking/installing dependencies..." -ForegroundColor Yellow
    & $venvPython -m pip install -r (Join-Path $Project "requirements.txt")
    if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed." }

    Write-Host ""
    Write-Host "Model: $env:GEMINI_MODEL" -ForegroundColor Green
    Write-Host "MCP:   $env:MCP_URL" -ForegroundColor Green
    Write-Host "Tool calls: AUTO-APPROVE ENABLED (no y/n prompts)." -ForegroundColor Red
    Write-Host "Type /quit in the chat to exit." -ForegroundColor DarkGray
    Write-Host "===================================================" -ForegroundColor DarkCyan

    & $venvPython (Join-Path $Project "adapter.py")
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Adapter exited with error code $LASTEXITCODE." -ForegroundColor Red
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check Python, internet, API key, and MCP URL." -ForegroundColor Yellow
}
finally {
    Write-Host ""
    Read-Host "Window will stay open. Read/copy the error above, then press Enter to close"
}
