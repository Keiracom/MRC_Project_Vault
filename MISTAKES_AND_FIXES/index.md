# Mistakes and Fixes Directory

This directory contains documented errors, issues, and their solutions encountered during the development of the MRC project. These files serve as a reference to prevent repeating past mistakes and provide quick solutions to common problems.

## Files in this Directory

- **[[business_operations_errors]]** - Common mistakes and solutions related to business logic, customer lifecycle, and operational decisions
- **[[n8n_errors]]** - Technical issues with n8n workflows, node configurations, and automation problems with proven fixes
- **[[supabase_errors]]** - Database-related errors, RLS policy issues, and data integrity problems with solutions

## How to Use This Directory

### Before Starting Work
1. **Always check** the relevant error file for your area before beginning
2. **Review** common mistakes to avoid repeating them
3. **Apply** proven solutions when encountering familiar issues

### When Encountering New Errors
1. **Document** the error with full context and error messages
2. **Record** the solution that worked
3. **Include** prevention strategies for future sessions
4. **Link** to related focus areas or decisions

### Error Documentation Format
```markdown
## Error: [Brief Description]
**Date**: [When encountered]
**Context**: [What you were trying to do]
**Error Message**: [Exact error text]
**Root Cause**: [Why it happened]
**Solution**: [Step-by-step fix]
**Prevention**: [How to avoid in future]
**Related**: [[links-to-related-docs]]
```

## Common Patterns Across All Areas

1. **API Integration Issues** - Authentication, rate limits, and connection problems
2. **Data Consistency** - Synchronization between services
3. **Workflow Dependencies** - Order of operations and timing issues
4. **Configuration Mistakes** - Incorrect settings or missing parameters

## Quick Links
- [[../FOCUS_AREAS/|Focus Areas]]
- [[../QUICK_START|Quick Start Guide]]
- [[../PROJECT_CORE/decisions|Architecture Decisions]]