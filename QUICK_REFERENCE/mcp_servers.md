# MCP Servers Configuration - Quick Reference

## Overview
MCP (Model Context Protocol) servers are now configured in Claude Code, providing direct access to critical MRC infrastructure and knowledge bases.

## Configured MCP Servers

### 1. n8n API Server
**Purpose**: Direct control of n8n workflows
**Access**: `@n8n`
**Capabilities**:
- List all workflows
- Trigger webhook-based workflows
- Get workflow execution status
- View workflow configurations
- Monitor execution logs

**Example Commands**:
```
@n8n list workflows
@n8n trigger workflow [workflow-id]
@n8n get execution [execution-id]
```

### 2. n8n Knowledge Server
**Purpose**: Complete documentation of all 525+ n8n nodes
**Access**: `@n8n-knowledge`
**Capabilities**:
- Node property documentation
- Operation examples
- Best practices for each node
- Integration patterns

**Example Usage**:
```
@n8n-knowledge what are the properties of the SEMrush node?
@n8n-knowledge how do I configure webhook authentication?
```

### 3. PostgreSQL (Supabase)
**Purpose**: Direct database access to MRC data
**Access**: `@postgres`
**Database**: skcudwqqdqlobinjzjyw.supabase.co
**Capabilities**:
- Query prospects and reports tables
- Monitor report generation status
- Analyze conversion metrics
- Debug data issues

**Example Queries**:
```sql
@postgres SELECT COUNT(*) FROM prospects WHERE created_at > NOW() - INTERVAL '7 days';
@postgres SELECT * FROM report_tracking WHERE converted_at IS NOT NULL;
```

### 4. GitHub
**Purpose**: Repository and code management
**Access**: `@github`
**Capabilities**:
- View repository files
- Check commit history
- Manage issues and PRs
- Update workflow configurations

**Example Commands**:
```
@github list repos
@github get file Keiracom/MRC_Project_Vault/FOCUS_AREAS/n8n_workflows.md
```

### 5. Brave Search
**Purpose**: Web research for competitor analysis
**Access**: `@brave-search`
**Capabilities**:
- Search for competitor information
- Find industry trends
- Research marketing strategies
- Validate SEMrush data

**Example Searches**:
```
@brave-search search "email marketing agencies pricing 2024"
@brave-search search "SEO tools comparison SEMrush alternatives"
```

## Environment Variables Set

```bash
N8N_API_URL="https://keiracom.app.n8n.cloud/api/v1"
N8N_API_KEY="[JWT token for n8n access]"
GITHUB_PERSONAL_ACCESS_TOKEN="[GitHub PAT]"
BRAVE_API_KEY="[Brave Search API key]"
```

## Use Cases for MRC Project

### Testing Report Generation
1. Use `@postgres` to find a test prospect
2. Use `@n8n` to trigger the report generation workflow
3. Use `@postgres` to monitor the report_tracking table
4. Use `@n8n` to check execution status

### Debugging Workflow Issues
1. Use `@n8n` to list workflows and find the problematic one
2. Use `@n8n-knowledge` to understand node configurations
3. Use `@n8n` to view execution logs
4. Use `@postgres` to check related database records

### Competitor Research
1. Use `@brave-search` to find competitor information
2. Use `@postgres` to store findings in database
3. Use `@github` to update documentation

### Monitoring System Health
```bash
# Check recent prospect additions
@postgres SELECT COUNT(*) FROM prospects WHERE created_at > NOW() - INTERVAL '1 day';

# Check active workflows
@n8n list workflows --active

# Check recent reports
@postgres SELECT * FROM generated_reports ORDER BY created_at DESC LIMIT 10;
```

## Important Notes

1. **Security**: All credentials are session-specific and not persisted
2. **Rate Limits**: Be mindful of API rate limits for each service
3. **Logging**: All MCP operations are logged by the respective services
4. **Docker Requirement**: The n8n-knowledge server requires Docker to be running

## Troubleshooting

If an MCP server isn't responding:
1. Check if the server is listed: `claude mcp list`
2. Remove and re-add: `claude mcp remove [name]` then add again
3. Verify environment variables are set
4. For Docker-based servers, ensure Docker is running

## Quick Test Commands

Test each server is working:
```bash
# Test n8n API
@n8n list workflows

# Test n8n Knowledge
@n8n-knowledge list available nodes

# Test PostgreSQL
@postgres SELECT version();

# Test GitHub
@github list repos

# Test Brave Search
@brave-search search "test query"
```