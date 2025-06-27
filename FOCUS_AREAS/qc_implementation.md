# Quality Control Implementation Guide

## Overview
This guide details the complete QC framework for ensuring high-quality messages and reports across all MRC distribution channels. Every message and report goes through automated quality control before reaching prospects.

## QC Architecture

### Three-Layer QC System

```
1. Sunday Batch QC (2-6 AM)
   ├── Message QC (5,000 messages)
   └── Report QC (85 reports)

2. Real-time QC (On-demand)
   └── Email Report QC (30-60 seconds)

3. Manual Override Queue
   └── Critical failures requiring human review
```

## Message QC Implementation

### Sunday Message QC Workflow (#21)

**Purpose**: Ensure all 5,000 personalized messages are error-free before weekly distribution.

#### Claude Prompt for Message QC
```javascript
const messageQCPrompt = `
Review this outreach message for quality issues:

PROSPECT INFO:
- Name: ${prospect.first_name} ${prospect.last_name}
- Company: ${prospect.company_name}
- Industry: ${prospect.industry}
- Is LinkedIn: ${prospect.is_linkedin}

GENERATED MESSAGE:
Subject: ${prospect.generated_subject}
Body: ${prospect.generated_message}

QUALITY CHECKS:
1. Placeholders: Ensure no [PLACEHOLDER] or {{variable}} remains
2. Personalization: Verify names, company, competitors are accurate
3. Grammar: Fix any spelling or grammar errors
4. Length: LinkedIn (250 char), Email (150 words)
5. Link: Verify report link is present and correct format
6. Tone: Professional but conversational

COMPETITOR VALIDATION:
- Mentioned competitors must be real companies
- Industry references must match prospect's industry
- Statistics should be realistic

RETURN FORMAT:
{
  "status": "approved" | "fixed" | "failed",
  "issues": ["list of issues found"],
  "final_subject": "corrected subject if needed",
  "final_message": "corrected message if needed"
}

For "failed" status, explain why it cannot be automatically fixed.
`;
```

#### n8n Node Configuration
```javascript
// Sunday Message QC Workflow
{
  "nodes": [
    {
      "name": "Schedule Trigger",
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": {
          "interval": [{ "weekday": 0, "hour": 2 }] // Sunday 2 AM
        }
      }
    },
    {
      "name": "Get Pending Messages",
      "type": "@n8n/n8n-nodes-langchain.supabase",
      "parameters": {
        "query": "SELECT * FROM prospects WHERE message_qc_status = 'pending' AND message_generated_at > NOW() - INTERVAL '4 hours'"
      }
    },
    {
      "name": "Batch Process",
      "type": "n8n-nodes-base.splitInBatches",
      "parameters": {
        "batchSize": 100 // Process 100 at a time
      }
    },
    {
      "name": "Claude QC Review",
      "type": "@n8n/n8n-nodes-langchain.claude",
      "parameters": {
        "prompt": "{{messageQCPrompt}}",
        "model": "claude-3-haiku" // Fast model for high volume
      }
    },
    {
      "name": "Update Database",
      "type": "@n8n/n8n-nodes-langchain.supabase",
      "parameters": {
        "operation": "update",
        "table": "prospects",
        "updateKey": "id",
        "columns": {
          "message_qc_status": "={{$json.status}}",
          "message_qc_issues": "={{$json.issues}}",
          "final_subject": "={{$json.final_subject}}",
          "final_message": "={{$json.final_message}}",
          "message_qc_checked_at": "={{new Date().toISOString()}}",
          "ready_to_send": "={{$json.status !== 'failed'}}"
        }
      }
    }
  ]
}
```

### Common Message Issues & Fixes

1. **Unfilled Placeholders**
   - Issue: "Hi [FirstName]" or "competing with {{competitor}}"
   - Fix: Replace with actual data or remove sentence

2. **Wrong Industry Terms**
   - Issue: "medical keywords" for an e-commerce company
   - Fix: Use industry-appropriate language

3. **Unrealistic Claims**
   - Issue: "losing $1M/month" for small business
   - Fix: Scale to appropriate company size

4. **Generic Messaging**
   - Issue: No specific personalization
   - Fix: Add at least one company-specific detail

## Report QC Implementation

### Sunday Report QC Workflow (#22)

**Purpose**: Validate all 85 pre-generated LinkedIn reports for data accuracy and formatting.

#### Claude Prompt for Report QC
```javascript
const reportQCPrompt = `
Quality check this competitive analysis report:

COMPANY: ${prospect.company_name}
DOMAIN: ${prospect.company_domain}
INDUSTRY: ${prospect.industry}

REPORT HTML: ${report.html_content}

CRITICAL CHECKS:
1. Data Accuracy
   - All 6 competitors are real companies in same industry
   - Traffic numbers are realistic (not 0, not billions)
   - Keyword counts make sense (10-10,000 range)
   - Ad spend estimates align with company size

2. Completeness
   ✓ Executive Summary present
   ✓ 6 competitor cards with data
   ✓ Keyword opportunities section
   ✓ Quick wins (at least 3)
   ✓ ROI projections
   ✓ Clear CTAs to subscribe

3. Formatting
   - No broken HTML tags
   - Images/charts display properly
   - Mobile responsive design
   - No Lorem Ipsum or placeholder text

4. Business Logic
   - Recommendations are actionable
   - Opportunities match company size
   - $297/mo pricing mentioned correctly
   - No contradictions between sections

5. Technical Validation
   - Report UUID matches prospect
   - All links use correct domain
   - Analytics tracking present
   - Expiration date set correctly

RETURN FORMAT:
{
  "status": "approved" | "fixed" | "failed",
  "issues": ["array of specific issues"],
  "critical_errors": boolean,
  "final_html_content": "fixed HTML if needed"
}

For "failed" status, explain what needs manual intervention.
`;
```

### Real-time Email Report QC (#23)

**Purpose**: Quick validation of reports generated on-demand from email clicks.

#### Optimized for Speed (30-60 seconds)
```javascript
const quickReportQCPrompt = `
Quick quality check - CRITICAL ERRORS ONLY:

Report for: ${prospect.company_name}
Generated in: ${generationTime}ms

CHECK ONLY:
1. ❌ Competitor data exists (not null/0)
2. ❌ HTML renders without errors
3. ❌ Company name correct throughout
4. ❌ CTA buttons link correctly
5. ❌ No error messages in content

If ANY critical error found, return:
{
  "status": "blocked",
  "reason": "specific critical error",
  "send_apology": true
}

Otherwise return:
{
  "status": "approved"
}

Skip minor issues - focus on report deliverability.
`;
```

#### Apology Email for Blocked Reports
```javascript
const apologyEmail = `
Subject: Quick update on your ${company} competitive analysis

Hi ${firstName},

I encountered an unusual data point while analyzing your competitors 
that needs verification to ensure accuracy.

Rather than send you incomplete information, I'm having our senior 
analyst personally review your report. 

You'll receive the enhanced analysis within 2 hours - with extra 
attention to the opportunities most relevant to ${company}.

I appreciate your patience. Quality insights are worth the wait!

Best,
Sarah from MRC

P.S. Reply if you have specific competitors you'd like us to focus on.
`;
```

## QC Performance Monitoring

### Key Metrics to Track
```sql
-- QC Performance Dashboard
CREATE VIEW v_qc_dashboard AS
SELECT 
  DATE(created_at) as date,
  qc_type,
  COUNT(*) as total_processed,
  COUNT(CASE WHEN qc_result = 'approved' THEN 1 END) as approved,
  COUNT(CASE WHEN qc_result = 'fixed' THEN 1 END) as auto_fixed,
  COUNT(CASE WHEN qc_result = 'blocked' THEN 1 END) as failed,
  ROUND(AVG(qc_duration_ms)) as avg_time_ms,
  ROUND(COUNT(CASE WHEN qc_result != 'blocked' THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) as success_rate
FROM report_qc_log
GROUP BY DATE(created_at), qc_type
ORDER BY date DESC, qc_type;
```

### Common QC Patterns
```sql
-- Most common issues
SELECT 
  unnest(issues_found) as issue,
  COUNT(*) as frequency
FROM report_qc_log
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY issue
ORDER BY frequency DESC
LIMIT 20;
```

## Implementation Checklist

### Database Setup
- [ ] Run enhanced_schema.sql to add QC fields
- [ ] Create report_qc_log table
- [ ] Add indexes for QC queries
- [ ] Set up views for monitoring

### n8n Workflow Creation
- [ ] Workflow #21: Sunday Message QC
- [ ] Workflow #22: Sunday Report QC  
- [ ] Workflow #23: Real-time Email QC
- [ ] Test with sample data

### Claude Integration
- [ ] Set up Claude API in n8n
- [ ] Test QC prompts with edge cases
- [ ] Optimize token usage
- [ ] Set up fallback for API failures

### Monitoring Setup
- [ ] Create QC dashboard in Bubble
- [ ] Set up alerts for high failure rates
- [ ] Daily QC summary email
- [ ] Weekly QC performance review

## Best Practices

### Performance Optimization
1. **Batch Processing**: 100 messages at a time
2. **Parallel Execution**: Up to 5 concurrent QC checks
3. **Caching**: Store QC results for analysis
4. **Model Selection**: Use Claude Haiku for speed

### Error Handling
1. **Graceful Failures**: Always have fallback
2. **Manual Queue**: Route unfixable issues to humans
3. **Logging**: Track every QC decision
4. **Alerts**: Notify team of systematic issues

### Continuous Improvement
1. **Weekly Reviews**: Analyze common issues
2. **Prompt Updates**: Refine based on failures
3. **A/B Testing**: Test different QC strategies
4. **Feedback Loop**: Learn from manual fixes

## ROI of Quality Control

### Without QC
- 2% catastrophic failure rate = 100 bad messages/week
- 10% minor issues = 500 suboptimal messages
- Reputation damage from broken reports
- Lost conversions from quality issues

### With QC  
- <0.1% failures reach prospects
- 98% of issues auto-fixed
- Consistent brand quality
- Higher conversion rates
- Better deliverability

### Cost Analysis
- QC adds ~$50/week in Claude API costs
- Prevents loss of ~$891/week in potential revenue
- ROI: 1,782% return on QC investment

## Quick Reference Commands

```bash
# Check QC status
SELECT * FROM v_sunday_progress;

# Find failed messages
SELECT * FROM prospects 
WHERE message_qc_status = 'failed' 
ORDER BY message_generated_at DESC;

# QC performance
SELECT * FROM v_qc_dashboard 
WHERE date = CURRENT_DATE;

# Manual review queue
SELECT * FROM report_qc_log 
WHERE qc_result = 'blocked' 
AND created_at > NOW() - INTERVAL '24 hours';
```