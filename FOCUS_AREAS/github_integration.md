# GitHub Integration - MRC Project

## Overview
This document covers GitHub integration for the MRC Project Vault, including authentication, syncing, and troubleshooting.

## Repository Information
- **Repository URL**: https://github.com/Keiracom/MRC_Project_Vault.git
- **Primary Branch**: main
- **Local Path**: C:\Users\dvids\MRC\MRC_Project_Vault

## Authentication Setup

### Personal Access Token (PAT)
The project uses GitHub Personal Access Tokens for authentication:
- **Primary PAT**: [REDACTED - See MRC Credentials.md]
- **Alternative PAT**: [REDACTED - See MRC Credentials.md]

### Setting Up Authentication

#### Option 1: Using Git Credential Manager (Recommended)
```bash
# Store credentials for HTTPS
git config --global credential.helper manager
```

#### Option 2: Using Personal Access Token in URL
```bash
# Update remote URL with PAT
git remote set-url origin https://[YOUR-PAT-TOKEN]@github.com/Keiracom/MRC_Project_Vault.git
```

#### Option 3: Using Git Credential Store
```bash
# Enable credential storage
git config credential.helper store

# Push once and enter username/PAT when prompted
git push origin main
# Username: Keiracom
# Password: [PAT token]
```

## Common Operations

### Check Repository Status
```bash
git status
git log --oneline -10
git remote -v
```

### Sync Changes
```bash
# Pull latest changes
git pull origin main

# Add and commit changes
git add -A
git commit -m "Your commit message"

# Push to GitHub
git push origin main
```

### Fix Authentication Issues
If you encounter authentication errors:

1. **Update remote URL with PAT**:
```bash
git remote set-url origin https://[YOUR-PAT-TOKEN]@github.com/Keiracom/MRC_Project_Vault.git
```

2. **Clear cached credentials**:
```bash
git config --unset credential.helper
```

3. **Test connection**:
```bash
git ls-remote origin
```

## Automated Sync with MCP

According to QUICK_START.md, the project uses automated sync:
1. `filesystem:edit_file` for local changes
2. `github:create_or_update_file` for immediate GitHub backup

This ensures no information loss and clean version history.

## Troubleshooting

### "fatal: could not read Username" Error
This occurs when Git can't authenticate. Solutions:
1. Update remote URL with PAT (see above)
2. Use credential helper
3. Check if PAT is still valid

### "Your branch is ahead of origin" Message
This means local commits haven't been pushed:
```bash
# Check how many commits ahead
git status

# Push commits
git push origin main
```

### Permission Denied
- Verify PAT has correct permissions (repo access)
- Check if PAT hasn't expired
- Ensure correct repository URL

## Security Notes
- **NEVER** commit credentials directly to the repository
- Store PATs securely outside of version control
- Rotate PATs every 90 days
- Use minimal required permissions for PATs

## Integration with Project Workflow

### During Development
1. Make changes locally
2. Test thoroughly
3. Commit with descriptive messages
4. Push to GitHub for backup

### Session Management
- Start: Pull latest changes
- During: Commit frequently
- End: Push all changes

### Collaboration
- All changes sync to GitHub automatically
- Team members can pull latest updates
- Version history maintained for rollback

---
*Last Updated: 2025-01-30*
*Part of MRC Project Documentation*