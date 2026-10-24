# Gemini MCP Adapter

A small async bridge: Google Gemini function calling -> MCP tool calls -> tool results back to Gemini.

## 1. Install

Use Python 3.11+ (Python 3.13 should be fine):

```powershell
cd "$HOME\GeminiMCPAdapter"
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

## 2. Configure Gemini

Create an API key in Google AI Studio, then set it in the current PowerShell session:

```powershell
$env:GEMINI_API_KEY = "YOUR_GOOGLE_AI_STUDIO_KEY"
$env:GEMINI_MODEL = "gemini-2.5-flash"
```

## 3. Connect to an MCP server

For an HTTP server that supports **MCP Streamable HTTP**:

```powershell
$env:MCP_URL = "https://your-mcp-server.example/mcp"
python .\adapter.py
```

If the endpoint needs a bearer token:

```powershell
$env:MCP_BEARER_TOKEN = "YOUR_TOKEN"
```

For a local stdio MCP server, clear MCP_URL and set its executable and JSON argument list:

```powershell
Remove-Item Env:MCP_URL -ErrorAction SilentlyContinue
$env:MCP_COMMAND = "npx"
$env:MCP_ARGS_JSON = '["@scope/server-package"]'
python .\adapter.py
```

The adapter expects the server to implement MCP. A URL ending in /mcp is not automatically guaranteed to be public or compatible; use the endpoint and authentication method supplied by that server's operator.

## 4. Safety and usage

- Type a request at the prompt; use `/quit` to exit.
- Each proposed tool call shows its arguments and asks for approval.
- To skip approvals, set `$env:AUTO_APPROVE = "true"`. Only do this in a trusted, controlled environment; desktop tools may read/write files or run commands.
- Optional: `$env:MAX_TOOL_ROUNDS = "8"`.
- Tool schemas are discovered at startup with `list_tools`; JSON-RPC protocol internals are handled by the official MCP SDK.
- Free Gemini API quotas and model availability can change. Tool calls consume API quota.
