# MRC Credentials Location

**Critical Information**: All MRC project credentials are stored in:
```
C:\Users\dvids\MRC\MRC Credentials.md
```

## When Creating Workflows

Always reference this file for:
- n8n instance URL and API key
- Supabase connection details
- Stripe API keys (LIVE/PRODUCTION)
- SendGrid API key
- Claude API key
- All other service credentials

## Security Notes
- These are LIVE credentials - handle with extreme care
- Stripe keys process real money
- Always use n8n's credential manager for storage
- Never commit credentials to version control
- Keep credentials file outside of git repository

---
*Last Updated: 2024-12-19*
*Always refer to the master file for most current credentials*