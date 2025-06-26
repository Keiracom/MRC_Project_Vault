# QUICK START - MRC Project Overview

## 🎯 Project Purpose
Multi-platform competitive intelligence service with automated reporting, dashboard, and customer management.

**Core Service**: Automated competitive analysis reports for businesses spending $5-15K/month on marketing.

## 📊 Current Status  
**Last Updated**: 2025-01-30

### System Status
- **Website**: Live at keiracom.com with Stripe payments ✅
- **Database**: Supabase configured with business operations schema ✅
- **n8n Workflows**: 1 active (Payment Processing - needs modification) ✅
- **Tech Stack**: Complete - SEMrush API, Claude API, Supabase, n8n ✅
- **Project Management**: Obsidian + GitHub + MCP integration ✅
- **Revenue**: $0 (system ready for customers)

### Critical Implementation Notes
- **LinkedIn Distribution**: 365 pre-generated reports/month
- **Email Distribution**: 448 on-demand reports/month (1.8% click → 20% convert)
- **Total Reports**: 813/month at ~$26.42 API cost (6 competitors)
- **Report Strategy**: LinkedIn pre-generated Sunday nights, Email on-demand
- **Payment Flow**: Must be immediate report delivery (remove 48hr delay)
- **API Costs**: $0.00005/unit = $0.0325 per report (650 units × 6 competitors)
- **Report Format**: HTML with PDF download option (not PDF primary)

### Completed This Session
- ✅ SEMrush API cost analysis corrected (4,000x error found) - 2025-01-30
- ✅ Final decision: 6 competitors optimal (650 units, $0.0325/report) - 2025-01-30
- ✅ HTML report format chosen over PDF for speed/flexibility - 2025-01-30
- ✅ Report Generation Engine (#6) requirements defined - 2025-01-30
- ✅ All critical session decisions documented - 2025-01-30

### Service Tiers
- **Startup**: $297/month - Monthly reports, 1-3 competitors
- **Growth**: $697/month - Weekly alerts + dashboard, 5-10 competitors  
- **Enterprise**: $1,297/month - Daily optimization, 25+ competitors

### Business Model
- **Target Market**: Small-medium businesses with $5-15K monthly marketing spend
- **Value Proposition**: 88% cheaper than direct tools, actionable insights vs raw data
- **Competitive Position**: Against agencies/consultants ($5-10K/month), not tools

## 🚨 Current Focus
**Today's Priority**: All major decisions finalized - ready to build Report Generation Engine (#6)

**This Week**: 
1. Modify Payment Processing for immediate reports
2. Adjust LinkedIn Orchestrator for correct volume
3. Implement report pre-generation for LinkedIn

**Immediate Priorities**:
1. Test complete payment → immediate report generation → delivery flow
2. Implement LinkedIn pre-generation (85 weekly)
3. Test email click → report generation flow
4. Monitor API usage with realistic volumes

## 🔧 Critical Information

### Tech Stack
- **Automation**: n8n Cloud ($50/month)
- **Database**: Supabase (business operations schema)
- **AI Processing**: Claude API (~$100/month)
- **Data Sources**: SEMrush Business ($465.45/month total - includes API units)
- **Payments**: Stripe (3% fees)
- **Email**: SendGrid for transactional
- **CRM**: HubSpot Free tier
- **Outreach**: Instantly.ai + Apollo.io + LinkedIn

### Key APIs & Services
- **SEMrush API**: Competitive data, keywords, traffic estimates
- **Claude API**: Report generation, analysis, quality control
- **Stripe**: Subscription management and webhooks
- **Supabase**: Customer data, competitors, report history

### Deployment Status
- **Primary Domain**: keiracom.com (website, payments)
- **Business Domain**: mrcinsights.com (email, outreach)
- **Infrastructure**: Vercel (website), n8n Cloud (workflows)

## 🚨 Critical Rules & Constraints

### Technical
- Use LangChain nodes for Report Generation Engine (#6) - NOT HTTP Request
- Use HTTP Request nodes for simple Claude API calls only
- All n8n workflows must be complete JSON (no manual UI work)
- Supabase requires RLS policies for security
- Never use primary domain for cold outreach
- **LinkedIn**: 17 connections/day maximum (85/week total)

### Business
- **Language**: Business outcomes not marketing metrics
- **Target Customer**: Business owners, not marketing professionals  
- **Value Delivery**: Prescriptive solutions not just data
- **Quality Control**: All client content gets human review
- **Distribution**: Free reports first month, immediate delivery

### Architecture
- **n8n**: Handles all automation and data processing
- **Claude**: Makes all business logic decisions
- **Supabase**: Single source of truth for customer data
- **Stripe**: Subscription and payment management
- **20 workflows already defined** in architecture document

## 📍 Quick Navigation
- **n8n Workflows**: [[FOCUS_AREAS/n8n_workflows]]
- **Distribution Implementation**: [[FOCUS_AREAS/distribution_implementation]]
- **Dashboard Development**: [[FOCUS_AREAS/dashboard]]
- **Database Schema**: [[FOCUS_AREAS/supabase]]
- **Business Operations**: [[FOCUS_AREAS/business_operations]]
- **Common Errors**: [[MISTAKES_AND_FIXES/]]
- **Architecture Decisions**: [[PROJECT_CORE/decisions]]
- **Key Learnings**: [[PROJECT_CORE/learnings]]
- **Credentials Location**: [[PROJECT_CORE/credentials_location]]

## 🎯 Session Guidance

### Starting a Session
1. Read this QUICK_START.md for current status
2. Navigate to relevant FOCUS_AREAS for specific context
3. Check MISTAKES_AND_FIXES for known issues in your area
4. Update "Today's Priority" with current focus

### During Work
- Use "Route and save: [information]" for all updates
- Create [[bidirectional-links]] between related concepts
- Document decisions as you make them
- **CRITICAL**: Claude automatically syncs to GitHub after each save using:
  1. `filesystem:edit_file` for local changes
  2. `github:create_or_update_file` for immediate GitHub backup
  3. This ensures no information loss and clean version history

### Ending a Session
- Update current status and progress
- Note any blockers or issues discovered
- Set next session priorities

---
*This is your project dashboard - keep it current and refer to it every session.*