# Workflows Directory

This directory contains the actual n8n workflow JSON files that can be imported directly into n8n. These are complete, production-ready workflow definitions with all configurations included.

## Files in this Directory

- **[[01__Payment_Processing___Onboarding.json]]** - Handles Stripe webhooks, creates customer records, initiates competitive analysis
  - Status: Active (needs modification to remove 48-hour delay)
  - Trigger: Stripe payment webhooks
  
- **[[02__MRC_Subscription_Management_Workflow.json]]** - Manages subscription lifecycle, upgrades, downgrades, and cancellations
  - Status: Ready for deployment
  - Trigger: Stripe subscription events

- **[[03-partner-commission-calculator.json]]** - Calculates and tracks partner commissions and referral payments
  - Status: Ready for deployment
  - Trigger: Monthly cron job

## How to Import Workflows

1. **Open n8n** instance
2. **Create new workflow** or open existing
3. **Menu → Import from File** 
4. **Select** the JSON file from this directory
5. **Configure** any environment-specific settings:
   - API credentials
   - Webhook URLs
   - Database connections

## Workflow Naming Convention

- **Number prefix** (01, 02, 03) - Indicates execution order or priority
- **Descriptive name** - Clear indication of workflow purpose
- **JSON extension** - Ready for direct import

## Important Notes

### Before Importing
- Check [[../FOCUS_AREAS/n8n_workflows]] for latest status
- Review [[../MISTAKES_AND_FIXES/n8n_errors]] for known issues
- Ensure all required credentials are configured in n8n

### After Importing
- Test with sample data before activating
- Enable webhook endpoints if applicable
- Monitor execution logs for first runs
- Document any modifications in focus area files

## Planned Workflows (Not Yet Created)

Based on the architecture, these workflows need to be created:
- Report Generation Engine (#6) - Critical path
- Email Click Handler (#4-New) - For conversions
- LinkedIn Pre-Generator (#4-Mod) - For efficiency
- API Resource Manager (#18) - For cost control

See [[../FOCUS_AREAS/n8n_workflows]] for full list of 20 planned workflows.

## Quick Links
- [[../FOCUS_AREAS/n8n_workflows|n8n Workflows Documentation]]
- [[../QUICK_START|Quick Start Guide]]
- [[../PROJECT_CORE/decisions|Architecture Decisions]]