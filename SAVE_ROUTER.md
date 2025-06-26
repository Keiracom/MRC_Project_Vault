# Save Router - Information Dispatch System

## 🎯 How to Use This Router
When you need to save something, tell Claude:
"Use SAVE_ROUTER.md to determine where to save [type of information]"

Claude will:
1. Read this router file
2. Identify the information type
3. Save to the specified location
4. Use the specified format

## 📂 Information Types & Destinations

### ✅ COMPLETED TASKS
**Trigger Words**: "completed", "finished", "done", "working"
**Destination**: `FOCUS_AREAS/[area].md` → Status section
**Format**: 
```
- ✅ [Task Name] - [Date] - [Brief note]
```
**Update**: Also update `QUICK_START.md` overall progress

### ❌ ERRORS & SOLUTIONS  
**Trigger Words**: "error", "bug", "failed", "not working", "broken"
**Destination**: `MISTAKES_AND_FIXES/[area]_errors.md`
**Format**:
```markdown
### Error: [Brief Description]
**Date**: [Date]
**Context**: [What were you doing]
**Error**: [Exact error message/problem]
**Solution**: [How it was fixed]
**Prevention**: [How to avoid next time]
**Status**: ✅ Resolved / 🔄 In Progress / ⏳ Pending
```

### 🎯 DECISIONS & CHOICES
**Trigger Words**: "decided", "chose", "going with", "approach"  
**Destination**: `PROJECT_CORE/decisions.md`
**Format**:
```markdown
### Decision: [Topic] - [Date]
**Decision**: [What was decided]
**Reasoning**: [Why this choice]
**Alternatives**: [What else was considered]
**Impact**: [How this affects project]
**Links**: [[related-decision]] [[affected-workflow]]
```

### 🔧 CONFIGURATIONS & SETUP
**Trigger Words**: "config", "setup", "environment", "API key", "endpoint", "credentials"
**Destination**: `FOCUS_AREAS/[area].md` → Configuration section
**Format**:
```markdown
### Configuration: [Component]
**Item**: [What was configured]
**Value/Setting**: [The configuration]
**Purpose**: [Why this setting]
**Notes**: [Important details]
```
**⚠️ CREDENTIALS NOTE**: All actual credentials are stored in `C:\Users\dvids\MRC\MRC Credentials.md`
**Reference Location**: `PROJECT_CORE/credentials_location.md`

### 📈 PROGRESS UPDATES
**Trigger Words**: "progress", "status", "currently", "working on"
**Destination**: `QUICK_START.md` → Current Status section
**Format**:
```markdown
**Last Updated**: [Date]
**Completed This Session**: [List items]
**Currently Working On**: [Current task]
**Next Priority**: [What's next]
**Blockers**: [Any issues]
```

### 💡 LEARNINGS & INSIGHTS
**Trigger Words**: "learned", "discovered", "found out", "insight"
**Destination**: `PROJECT_CORE/learnings.md`
**Format**:
```markdown
### Learning: [Topic] - [Date]
**Discovery**: [What was learned]
**Context**: [How it was discovered]
**Application**: [How to use this knowledge]
**Links**: [[related-concept]] [[workflow-affected]]
```

### 🔄 N8N WORKFLOWS
**Trigger Words**: "workflow", "n8n", "automation"
**Destination**: `FOCUS_AREAS/n8n_workflows.md`
**Format**:
```markdown
### Workflow: [Name]
**Status**: ✅ Complete / 🔄 In Progress / ⏳ Planned
**Purpose**: [What it does]
**Trigger**: [How it starts]
**Data Flow**: [Input → Processing → Output]
**Dependencies**: [What it needs]
**Last Updated**: [Date]
**Links**: [[related-workflow]] [[supabase-table]]
```

### 🖥️ DASHBOARD & FRONTEND
**Trigger Words**: "dashboard", "frontend", "UI", "component"
**Destination**: `FOCUS_AREAS/dashboard.md`
**Format**:
```markdown
### Component: [Name]
**Status**: ✅ Complete / 🔄 In Progress / ⏳ Planned
**Purpose**: [What it does]
**Tech Stack**: [Technologies used]
**Dependencies**: [What it connects to]
**Last Updated**: [Date]
**Links**: [[api-endpoint]] [[design-mockup]]
```

### 🗃️ DATABASE & SUPABASE
**Trigger Words**: "database", "table", "supabase", "schema", "RLS"
**Destination**: `FOCUS_AREAS/supabase.md`
**Format**:
```markdown
### Table: [Name]
**Purpose**: [What data it stores]
**Key Columns**: [Important fields]
**RLS Policy**: [Security rules]
**Connected To**: [What uses this table]
**Last Updated**: [Date]
**Links**: [[workflow-using]] [[business-logic]]
```

## 🎯 Auto-Detection Rules

### Area Detection:
- Contains "n8n" or "workflow" → n8n area
- Contains "dashboard" or "component" or "frontend" → dashboard area  
- Contains "supabase" or "database" → supabase area
- Contains "customer" or "business" → business operations area
- Contains multiple areas → integration area

### Priority Rules:
1. Errors always go to MISTAKES_AND_FIXES first
2. Completions update both area-specific AND QUICK_START.md
3. Decisions go to PROJECT_CORE/decisions.md
4. Everything else goes to relevant FOCUS_AREAS file

## 🚨 Special Routing Rules

### Session Handoff Information:
**Trigger**: "session ending", "handoff", "next session"
**Destination**: `QUICK_START.md` → Update multiple sections
**Action**: Update status, blockers, next steps

### Critical Blockers:
**Trigger**: "blocker", "stuck", "can't proceed"
**Destination**: `QUICK_START.md` → Blockers section (immediate)
**Secondary**: Relevant errors file (detailed)

### Business Operations:
**Trigger**: "customer", "tier", "pricing", "revenue"
**Destination**: `FOCUS_AREAS/business_operations.md`

## 🔄 Usage Examples

### Example 1: Completing a Task
**You say**: "n8n payment workflow completed and tested"
**Claude should**:
1. Identify: "completed" + "workflow" + "n8n" = n8n completion
2. Update: `FOCUS_AREAS/n8n_workflows.md` with status
3. Update: `QUICK_START.md` overall progress
4. Create: Link between payment workflow and related components

### Example 2: Finding an Error
**You say**: "Supabase RLS policy blocking customer creation"
**Claude should**:
1. Identify: "error" + "supabase" = database error
2. Save to: `MISTAKES_AND_FIXES/supabase_errors.md`
3. Use: Error documentation format
4. Link: [[customer-creation]] [[rls-policies]]

### Example 3: Making a Decision
**You say**: "Decided to use Bubble over Retool for dashboard"
**Claude should**:
1. Identify: "decided" = architectural decision
2. Save to: `PROJECT_CORE/decisions.md`
3. Use: Decision documentation format
4. Link: [[dashboard-development]] [[tech-stack]]

## 📋 Router Checklist (For Claude)

When using this router, Claude should:
1. ✅ Read the information type and trigger words
2. ✅ Match to destination using detection rules
3. ✅ Use the specified format with Obsidian links
4. ✅ Update any secondary locations (like QUICK_START.md)
5. ✅ Create relevant [[bidirectional-links]]
6. ✅ Use `edit_file` for local changes (not full file rewrites)
7. ✅ Immediately sync to GitHub using `create_or_update_file`
8. ✅ Confirm what was saved and where

## 🔄 GitHub Sync Process

When saving to `C:\Users\dvids\MRC\MRC_Project_Vault`:

### Process:
1. **Make local changes** using `filesystem:edit_file`
   - Preserves formatting
   - Creates clean diffs
   - Only changes what's needed

2. **Sync to GitHub** using `github:create_or_update_file`
   - Get current file SHA first
   - Update with same content
   - Clear commit message describing changes

### Benefits:
- ✅ Immediate backup to GitHub
- ✅ Clean git history with meaningful diffs
- ✅ Consistency between local and remote
- ✅ No full file rewrites unless necessary
- ✅ Easier tracking of changes over time

### Example Workflow:
```
1. Edit local file: filesystem:edit_file
2. Get file info from GitHub to get SHA
3. Update GitHub: github:create_or_update_file with SHA
4. Confirm both local and remote updated
```
