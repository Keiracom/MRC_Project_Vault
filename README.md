# MRC Project Management System

An AI-powered project management system using Obsidian + GitHub + Claude Desktop with MCP integrations.

## 🚀 Quick Start for New Claude Sessions

### Essential Commands
```
"Read QUICK_START.md for current project status"
"Today focusing on: [n8n/dashboard/supabase/business]" 
"Route and save: [any information to document]"
```

### Session Workflow
1. **Start**: Read `QUICK_START.md` → Navigate to relevant `FOCUS_AREAS/` 
2. **Work**: Use "Route and save:" for all updates
3. **End**: Update status and commit changes to git

## 📁 System Structure

### Core Files
- **`QUICK_START.md`** - Current status, priorities, quick navigation
- **`SAVE_ROUTER.md`** - Automated information routing system

### Focus Areas (Session-Specific Context)
- **`n8n_workflows.md`** - Automation infrastructure and workflow status
- **`supabase.md`** - Database schema, operations, and configuration  
- **`dashboard.md`** - Customer interface development and features
- **`business_operations.md`** - Customer lifecycle, tiers, and strategy

### Error Prevention
- **`n8n_errors.md`** - Common n8n mistakes and proven solutions
- **`supabase_errors.md`** - Database issues and fixes

### Project Knowledge
- **`decisions.md`** - Architecture decisions with reasoning
- **`learnings.md`** - Key insights and discoveries

## 🎯 How Information Gets Routed

The `SAVE_ROUTER.md` automatically directs information to the right files:

| Information Type | Destination | Trigger Words |
|------------------|-------------|---------------|
| Completed tasks | `FOCUS_AREAS/[area].md` + `QUICK_START.md` | "completed", "finished", "done" |
| Errors & solutions | `MISTAKES_AND_FIXES/[area]_errors.md` | "error", "bug", "failed" |
| Decisions | `PROJECT_CORE/decisions.md` | "decided", "chose", "approach" |
| Learnings | `PROJECT_CORE/learnings.md` | "learned", "discovered", "insight" |
| Progress updates | `QUICK_START.md` | "progress", "status", "working on" |

## 🔗 Obsidian Integration

### Bidirectional Links
- Use `[[file-name]]` to create connections between concepts
- Example: `[[n8n-workflows]]` → `[[supabase-integration]]` → `[[customer-data]]`

### Navigation
- **Graph View**: See all project connections visually
- **Search**: Find any information instantly across all files  
- **Backlinks**: See what connects to current concept

## 🤖 Claude Desktop MCP Integration

### Required MCPs
- **Filesystem MCP**: Read/write local Obsidian files
- **Git MCP**: Commit changes and version control
- **GitHub MCP**: Sync with remote repository

### Usage Examples
```
"Route and save: n8n payment workflow completed successfully"
→ Updates FOCUS_AREAS/n8n_workflows.md
→ Updates QUICK_START.md progress
→ Creates links to related components
→ Commits changes to git

"Route and save: Supabase RLS policy blocking customer creation"  
→ Documents in MISTAKES_AND_FIXES/supabase_errors.md
→ Includes solution and prevention steps
→ Links to related database operations
```

## 📊 Project Context

### Marketing Reality Check (MRC)
- **Service**: Automated competitive intelligence for SMBs
- **Tiers**: Startup ($297), Growth ($697), Enterprise ($1,297) monthly
- **Tech Stack**: n8n, Supabase, Claude API, SEMrush, Stripe
- **Target**: Business owners spending $5-15K/month on marketing

### Current Status
- Website live with payments ✅
- Database schema complete ✅  
- 1 active n8n workflow ✅
- Ready for customer acquisition

## 🔄 Maintenance

### Daily
- Use "Route and save:" for all discoveries
- Update QUICK_START.md with current focus
- Check relevant MISTAKES_AND_FIXES before starting work

### Weekly  
- Review and organize accumulated information
- Update architecture decisions if major choices made
- Commit comprehensive status updates

### Monthly
- Review all decisions and learnings for patterns
- Update system structure if needed
- Archive old information if necessary

## 🚨 Critical Guidelines

### For n8n Work
1. **Always** check `MISTAKES_AND_FIXES/n8n_errors.md` first
2. **Never** use Basic LLM Chain nodes (use HTTP Request)
3. **Always** create complete JSON workflows
4. **Test** thoroughly before activating

### For Supabase Work  
1. **Always** check `MISTAKES_AND_FIXES/supabase_errors.md` first
2. **Enable** RLS policies for security
3. **Use** service keys for n8n operations
4. **Test** schema changes in staging first

### For All Work
1. **Document** decisions as you make them
2. **Link** related concepts with `[[brackets]]`
3. **Update** QUICK_START.md with progress
4. **Commit** changes regularly to git

---

## 🎉 Benefits of This System

✅ **No Information Loss** - Everything preserved in git history  
✅ **No Claude Overload** - Focused documentation per session  
✅ **No Repeated Mistakes** - Error docs prevent expensive redo  
✅ **Perfect Handoffs** - Every session knows exactly where you left off  
✅ **Visual Connections** - Obsidian shows how everything relates  
✅ **Automated Routing** - Claude saves information to the right place  
✅ **Version Control** - Track every decision and change over time

This system transforms complex multi-platform projects into manageable, well-documented, and continuously improving workflows.
