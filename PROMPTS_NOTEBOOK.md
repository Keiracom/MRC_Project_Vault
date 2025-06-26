# MRC Project Prompts Notebook

## 🚀 SESSION START PROMPTS

### Universal Project Load (Use Every Session)
```
Load my MRC project from C:\Users\dvids\MRC\MRC_Project_Vault using filesystem MCP.

Read QUICK_START.md for current project status.

Today I want to focus on: [CHOOSE ONE: n8n workflows / dashboard development / supabase database / business operations / integration work]

Based on my focus area, read the relevant file in FOCUS_AREAS/ and check MISTAKES_AND_FIXES/ for known issues in that area.

Confirm you understand the current project status and today's focus before we begin.
```

### n8n Workflow Focus Session
```
Load MRC project via filesystem MCP.
Read QUICK_START.md for status.
Focus: n8n workflows

CRITICAL: Read FOCUS_AREAS/n8n_workflows.md + MISTAKES_AND_FIXES/n8n_errors.md

Today's n8n task: [SPECIFIC TASK - e.g., "Create report generation workflow" or "Fix payment processing issue"]

REMEMBER: 
- Never use Basic LLM Chain nodes (use HTTP Request for Claude API)
- Complete JSON workflows only (no manual UI work)
- Always enable "Continue on Fail" for external APIs

Ready to work on n8n following our established patterns?
```

### Dashboard Development Focus
```
Load MRC project via filesystem MCP.
Read QUICK_START.md for status.
Focus: Dashboard development

Read FOCUS_AREAS/dashboard.md + MISTAKES_AND_FIXES/dashboard_errors.md (if exists)

Today's dashboard task: [SPECIFIC TASK - e.g., "Build Growth tier MVP" or "Implement mobile responsiveness"]

Key context: Using Bubble platform, mobile-first design, Growth tier ($697) gets dashboard access.

Ready to work on customer dashboard following our Bubble strategy?
```

### Supabase Database Focus
```
Load MRC project via filesystem MCP.
Read QUICK_START.md for status.
Focus: Supabase database

CRITICAL: Read FOCUS_AREAS/supabase.md + MISTAKES_AND_FIXES/supabase_errors.md

Today's database task: [SPECIFIC TASK - e.g., "Optimize customer queries" or "Add new table for feature X"]

REMEMBER:
- Always enable RLS policies for security
- Use anon key if service key shows auth errors
- Test schema changes in staging first

Ready to work on database following our established security patterns?
```

### Business Operations Focus
```
Load MRC project via filesystem MCP.
Read QUICK_START.md for status.
Focus: Business operations

Read FOCUS_AREAS/business_operations.md for customer lifecycle, tiers, and strategy.

Today's business task: [SPECIFIC TASK - e.g., "Optimize conversion funnel" or "Plan customer acquisition campaign"]

Key context: Startup ($297), Growth ($697), Enterprise ($1,297) tiers. Target: business owners spending $5-15K/month on marketing.

Ready to work on business operations and customer success?
```

## 💾 SAVE & ROUTING PROMPTS

### Universal Save Command
```
Route and save: [DESCRIBE WHAT YOU LEARNED/COMPLETED/DISCOVERED]
```

### Specific Save Examples
```
Route and save: n8n payment workflow completed and tested successfully

Route and save: Found Supabase RLS authentication error when creating customers

Route and save: Decided to use Bubble over Retool for dashboard platform

Route and save: Learned that business owners respond better to outcome language than metrics

Route and save: Dashboard mobile responsiveness completed for Growth tier

Route and save: Customer tier upgrade logic implemented in payment processing workflow
```

### Progress Update
```
Route and save: Session progress update - completed [LIST TASKS], currently working on [CURRENT TASK], next priority is [NEXT TASK], no blockers
```

### Error Documentation
```
Route and save: Error found - [DESCRIBE PROBLEM] when [DOING WHAT]. Solution: [HOW WE FIXED IT]. Prevention: [HOW TO AVOID NEXT TIME]
```

### Decision Recording
```
Route and save: Decision made - [WHAT WAS DECIDED] because [REASONING]. Alternatives considered: [OTHER OPTIONS]. Impact: [HOW THIS AFFECTS PROJECT]
```

## 🔄 SESSION MANAGEMENT PROMPTS

### Mid-Session Check
```
Pause and save all progress so far using the routing system. Update QUICK_START.md with current status and what we've accomplished this session.
```

### Session End
```
End of session - save all progress and prepare handoff:

1. Route and save: Session summary - [WHAT WAS ACCOMPLISHED]
2. Update QUICK_START.md with current status and next session priorities
3. Commit all changes to git with descriptive message
4. Prepare handoff notes for next Claude session

What should the next session focus on?
```

### Emergency Save
```
Quick save current progress before we lose context:
- Route and save: [CURRENT WORK STATUS]
- Update QUICK_START.md with where we are
- Commit to git immediately
```

## 🔧 TECHNICAL WORK PROMPTS

### n8n Workflow Creation
```
Create new n8n workflow: [WORKFLOW NAME]

Requirements:
- Complete JSON configuration (no manual UI work needed)
- Use HTTP Request nodes for Claude API (never Basic LLM Chain)
- Include error handling with "Continue on Fail" for external APIs
- Add comprehensive logging for debugging
- Test with sample data before providing final JSON

Purpose: [WHAT THIS WORKFLOW DOES]
Trigger: [HOW IT STARTS]
Data Flow: [INPUT → PROCESSING → OUTPUT]
```

### Supabase Operations
```
Supabase task: [DESCRIBE DATABASE OPERATION]

Before proceeding:
1. Check MISTAKES_AND_FIXES/supabase_errors.md for known issues
2. Verify RLS policies are properly configured
3. Use appropriate API key type (try anon key if service key fails)
4. Include error handling and validation

Operation: [SPECIFIC DATABASE TASK]
```

### Dashboard Development
```
Dashboard task: [SPECIFIC UI/UX WORK]

Context:
- Platform: Bubble
- Target: Growth tier customers ($697/month)
- Mobile-first design (50%+ mobile users)
- Integration: Supabase database via API

Requirements: [SPECIFIC FEATURE REQUIREMENTS]
```

## 🚨 ERROR RESOLUTION PROMPTS

### n8n Workflow Issues
```
n8n workflow problem: [DESCRIBE ISSUE]

Before troubleshooting:
1. Check MISTAKES_AND_FIXES/n8n_errors.md for this exact issue
2. Verify we're using HTTP Request (not Basic LLM Chain) for Claude API
3. Check workflow execution logs for specific error messages
4. Test individual nodes to isolate the problem

Let's debug this systematically.
```

### Supabase Database Issues
```
Supabase error: [DESCRIBE DATABASE PROBLEM]

Debug checklist:
1. Check MISTAKES_AND_FIXES/supabase_errors.md for similar issues
2. Verify RLS policies allow the operation
3. Test with different API key (anon vs service)
4. Check foreign key constraints and data types
5. Verify network connectivity and rate limits

Error message: [EXACT ERROR IF AVAILABLE]
```

### Integration Problems
```
Integration issue between [SYSTEM A] and [SYSTEM B]:

Problem: [DESCRIBE THE CONNECTION/DATA FLOW ISSUE]

Debug approach:
1. Check each system individually
2. Verify API credentials and endpoints
3. Test data format and validation
4. Check network/firewall issues
5. Review error logs from both systems

Let's trace the data flow step by step.
```

## 📊 ANALYSIS & PLANNING PROMPTS

### Project Status Review
```
Comprehensive project status review:

1. Read QUICK_START.md and all FOCUS_AREAS files
2. Analyze current progress vs project goals
3. Identify any blockers or risks
4. Recommend next priorities based on current state
5. Update QUICK_START.md with fresh assessment

Provide executive summary of where we stand and what needs focus.
```

### Architecture Decision
```
Architecture decision needed: [DESCRIBE THE CHOICE TO MAKE]

Research approach:
1. Review PROJECT_CORE/decisions.md for similar past decisions
2. Consider alternatives: [LIST OPTIONS]
3. Analyze pros/cons of each option
4. Consider impact on current system
5. Make recommendation with clear reasoning

Document the final decision in PROJECT_CORE/decisions.md
```

### Customer Impact Analysis
```
Analyze customer impact of: [DESCRIBE CHANGE/FEATURE/ISSUE]

Consider:
1. Effect on each tier (Startup $297, Growth $697, Enterprise $1,297)
2. Business owner perspective (outcomes vs metrics)
3. Implementation complexity and timeline
4. Competitive advantage implications
5. Revenue/retention impact

Provide recommendation with business justification.
```

## 🎯 SPECIALIZED WORK PROMPTS

### Customer Communication
```
Create customer communication for: [PURPOSE]

Requirements:
- Use business outcome language (not marketing metrics)
- Focus on customer success and ROI
- Follow prescription model: Diagnose → Prescribe → Show results
- Professional but approachable tone
- Clear next steps for customer

Target audience: [STARTUP/GROWTH/ENTERPRISE] tier customers
```

### Competitive Analysis
```
Competitive analysis task: [SPECIFIC RESEARCH NEED]

Research framework:
1. Identify direct competitors (agencies, not tools)
2. Analyze positioning and messaging
3. Compare pricing and value proposition
4. Assess competitive advantages/disadvantages
5. Recommend positioning strategy

Focus: How we're different from $5-10K/month agencies and consultants
```

### Performance Optimization
```
Optimize performance for: [SYSTEM/WORKFLOW/PROCESS]

Analysis areas:
1. Current performance metrics
2. Bottlenecks and constraints
3. Scaling considerations
4. Cost optimization opportunities
5. User experience impact

Goal: [SPECIFIC PERFORMANCE TARGET]
```

## 🔍 DEBUGGING & TROUBLESHOOTING PROMPTS

### Systematic Debugging
```
Debug issue: [PROBLEM DESCRIPTION]

Systematic approach:
1. Reproduce the problem reliably
2. Check logs and error messages
3. Isolate the failing component
4. Test each integration point
5. Review recent changes that might have caused issue
6. Test fix in staging before production

Document solution in appropriate MISTAKES_AND_FIXES file.
```

### Workflow Testing
```
Test workflow: [WORKFLOW NAME]

Testing checklist:
- [ ] Test with valid data inputs
- [ ] Test with invalid/missing data
- [ ] Test external API failure scenarios
- [ ] Verify error handling and logging
- [ ] Check data flow to final destination
- [ ] Test webhook endpoints respond correctly
- [ ] Verify execution logs show success

Document any issues found and fixes applied.
```

### Integration Validation
```
Validate integration: [SYSTEM A] ↔ [SYSTEM B]

Validation steps:
1. Test authentication and authorization
2. Verify data format and mapping
3. Check error handling and retries
4. Test rate limiting and timeouts
5. Validate end-to-end data flow
6. Monitor performance under load

Document integration patterns for future reference.
```

## 💡 QUICK REFERENCE COMMANDS

### Fast Navigation
```
"Show me current n8n workflow status"
"What's the next priority for dashboard development?"
"Check for any Supabase errors we should know about"
"What are the current customer tier pricing and features?"
"Review recent architecture decisions"
```

### Fast Updates
```
"Mark n8n workflow X as completed"
"Update customer acquisition numbers"
"Add new competitor analysis insight"
"Record performance optimization result"
"Document new integration pattern"
```

### Fast Checks
```
"Any blockers preventing customer launch?"
"Is payment processing working correctly?"
"Are all critical workflows activated?"
"What's our current technical debt?"
"Any customer feedback to address?"
```

---

## 📋 PROMPT USAGE GUIDELINES

### Choose the Right Prompt
1. **Always start** with Universal Project Load
2. **Use focus-specific prompts** for deep work sessions
3. **Save frequently** using routing prompts
4. **End properly** with session handoff prompts

### Adapt Prompts as Needed
- Replace `[BRACKETED ITEMS]` with specific details
- Add context specific to your current work
- Modify based on what you're trying to accomplish

### Maintain the System
- Update prompts when you find better patterns
- Add new prompts for recurring tasks
- Document successful prompt variations

---

*Keep this notebook handy for every Claude session. These prompts ensure consistent, productive interactions while maintaining your comprehensive project documentation.*