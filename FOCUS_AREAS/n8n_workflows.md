# n8n Workflows Focus Area - Updated

## Overview
n8n handles all automation, data processing, and workflow orchestration for the MRC platform.

**Instance**: n8n Cloud  
**Cost**: $50/month  
**Integration**: Claude API, Supabase, SEMrush, Stripe, SendGrid

## Current Workflow Status

### ✅ Active Workflows

#### 1. Payment Processing & Onboarding
- **Status**: ✅ Complete and Active (NEEDS MODIFICATION)
- **Required Change**: Remove 48-hour delay, implement immediate report generation
- **Purpose**: Handles Stripe webhooks, creates customer records, initiates competitive analysis
- **Trigger**: Stripe payment webhooks (checkout.session.completed, customer.subscription.created)
- **Data Flow**: 
  - Stripe Event → Extract customer data → Create Supabase record → SEMrush analysis → Store competitors → **IMMEDIATE Report Generation** → Welcome email → Dashboard access (Growth/Enterprise)
- **Dependencies**: [[supabase-customers-table]] [[semrush-api]] [[sendgrid-email]]
- **File**: `01-payment-processing-onboarding.json`
- **Last Updated**: 2024-12-19

### ⏳ Planned Workflows (From Architecture - 20 Total)

#### High Priority for Distribution (UPDATED 2025-01-30)
1. **Weekly LinkedIn Report Pre-Generator (#4-Modified)** - Sunday night batch for 85 prospects
   - Runs every Sunday at 10 PM
   - Generates all 85 reports in parallel batches
   - Stores HTML reports in Supabase for week
   - 6 competitors per report (650 units each)

2. **Email Click Report Generator (#4-New)** - On-demand generation
   - Webhook triggered by email link clicks
   - Generates report in 3-5 minutes
   - Caches for 24 hours to prevent duplicates
   - Tracks conversion metrics

3. **Report Generation Engine (#6)** - Core HTML report creation
   - **Inputs**: Customer domain + 6 competitor domains
   - **Process**: 21 parallel SEMrush API calls (650 units total)
   - **Template**: Uses MRC_Startup_Tier_Template.md structure
   - **Output**: HTML report with inline CSS (no PDF)
   - **Features**: Executive summary, competitive analysis, keyword gaps, ROI projections

4. **LinkedIn Orchestrator (#8)** - Daily distribution
   - Sends 17 pre-generated reports/day (Mon-Fri)
   - Pulls from Sunday batch
   - Tracks opens and engagement

5. **Email Campaign Manager (#9)** - High-volume outreach
   - Sends 833 emails/day with unique tracking links
   - No report generation (only on click)
   - A/B testing capabilities

6. **API Resource Manager (#18)** - Critical for cost control
   - Tracks 650 units per report
   - Monthly budget: 528,450 units
   - Alerts at 80% usage
   - Rate limiting: 10 requests/second

#### Current Workflow Availability
- Payment Processing (#1) - ✅ Active (needs delay removal)
- Subscription Management (#2) - ✅ JSON available
- Partner Commission (#3) - ✅ JSON available  
- Report Generation Engine (#6) - 🚨 MUST CREATE - Critical path
- Email Click Handler (#4-New) - 🚨 MUST CREATE - For conversions
- LinkedIn Pre-Generator (#4-Mod) - 🚨 MUST CREATE - For efficiency
- API Resource Manager (#18) - 🚨 MUST CREATE - For cost control
- Sunday Message QC (#21) - 🚨 MUST CREATE - Quality control for 5,000 messages
- Sunday Report QC (#22) - 🚨 MUST CREATE - Quality control for 85 reports
- Real-time Email QC (#23) - 🚨 MUST CREATE - QC for on-demand reports

#### Additional Workflows in Architecture
- Subscription Management (#2)
- Partner Commission Calculator (#3)
- Customer Competition Monitor (#5)
- Market Intelligence Tracker (#7)
- Facebook Lead Processor (#10)
- Conversion Tracker (#11)
- Lead Scoring & Router (#12)
- 4-Stage QC System (#13)
- Report Delivery Manager (#14)
- Customer Success Monitor (#15)
- Master Controller Hub (#16)
- Error Handler & Recovery (#17)
- API Resource Manager (#18)
- Compliance & Data Manager (#19)
- Analytics & Reporting (#20)

## Distribution Implementation Details

### Volume Reality (Updated 2025-01-30 - FINAL CORRECTED)
- **LinkedIn**: 365 pre-generated reports/month (85/week × 4.3 weeks)
- **Email**: 448 on-demand reports/month (17,910 emails × 2.5% CTR)
- **Total Reports**: 813 reports/month
- **Competitors per report**: 6 (optimized from 8)
- **SEMrush API Units**: 528,450 units/month (650 units per report)
- **API Cost**: ~$26.42/month additional (beyond included 10,000 units)
- **Total SEMrush Cost**: $476.42/month ($450 plan + $26.42 overage)
- **Cost per report**: $0.0325 (3.25 cents)
- **Note**: No 7-day trial - direct to paid conversion

### Report Generation Strategy (FINAL)
- **LinkedIn**: Pre-generate all 85 reports Sunday night 10 PM
  - Batch process for efficiency
  - Store in Supabase with 7-day TTL
  - Include all 6 competitors per industry
- **Email**: Generate on-demand when link clicked
  - 3-5 minute generation time
  - Cache for 24 hours
  - Track conversion funnel
- **Paid customers**: Generate immediately upon payment
  - Remove ALL delays
  - Deliver within 5 minutes
  - Include onboarding sequence

### Key Architecture Documents
- **Full 20-Workflow Architecture**: `C:\Users\dvids\MRC\MRC N8N Workflow Architecture.md`
- **Business Operations Schema**: `C:\Users\dvids\MRC\MRC Business Operations Schema - Production Ready.md`
- **Distribution Implementation Plan**: `C:\Users\dvids\MRC\MRC_Project_Vault\FOCUS_AREAS\distribution_implementation.md`
- **Free Report Distribution Workflow**: [[free_report_distribution_workflow]]

## Technical Configuration

### Claude API Integration (UPDATED 2024-12-27)
- **Method**: Use LangChain nodes (nodes-langchain.lmChatAnthropic) - NOT HTTP Request
- **Model Strategy**: Hybrid approach
  - Claude 3.5 Sonnet: Business logic, routing, data processing
  - Claude 3 Opus: Final reports, quality control, customer-facing content
- **Node Configuration**: Anthropic Chat Model connected to Basic LLM Chain or AI Agent
- **Error Handling**: All Claude calls include try/catch with fallback responses
- **CRITICAL**: Previous advice about HTTP Request was wrong - use proper LangChain integration

### SEMrush API Setup
- **Service**: SEMrush Business ($500/month)
- **Endpoints Used**:
  - `domain_organic` - Domain overview and keyword data
  - `domain_organic_organic` - Competitor discovery
  - `domain_overview` - Traffic and ranking data
- **Rate Limits**: 10,000 units/month included
- **Error Handling**: Continue on fail with mock data fallback

### Supabase Integration
- **Tables Used**: `customers`, `customer_competitors`, `dashboard_users`, `workflow_logs`, `prospects`, `prospect_intelligence`
- **Security**: RLS policies enabled for all tables
- **API Key**: Service key for n8n operations
- **Backup**: All operations logged to `workflow_logs` table

## Workflow Development Standards

### JSON Configuration Requirements
- **Complete Setup**: All nodes fully configured with parameters
- **No Manual Work**: Import → Save → Test (no UI configuration)
- **Error Handling**: Continue on fail for external APIs
- **Logging**: Success/failure logged to Supabase
- **Testing**: Include test data and expected outputs

### Expression Patterns
```javascript
// Accessing previous node data
$node["Node Name"].json.fieldName

// Error handling in Code nodes
try {
  // Main logic
  return result;
} catch (error) {
  console.error('Error:', error);
  return { error: error.message };
}

// Conditional logic
{{ $json.tier === 'enterprise' ? true : false }}
```

## Common Issues & Solutions

### Issue: Basic LLM Chain Hanging
- **Problem**: Basic LLM Chain nodes block execution
- **Solution**: Use HTTP Request to Claude API directly
- **Links**: [[claude-api-http-integration]]

### Issue: Stripe Webhook Delays
- **Problem**: Customer creation before webhook processing
- **Solution**: Use webhook queuing and retry logic
- **Links**: [[stripe-webhook-reliability]]

### Issue: SEMrush Rate Limiting
- **Problem**: API quota exceeded during batch processing
- **Solution**: Implement delay between requests and priority queuing
- **Links**: [[semrush-rate-limits]]

## Architecture Decisions

### Why n8n Cloud over Self-Hosted
- **Decision**: Use n8n Cloud ($50/month) instead of self-hosting
- **Reasoning**: Reduces maintenance, provides reliability, worth the cost for business use
- **Impact**: Faster deployment, professional support, automatic updates

### Why HTTP Request over Basic LLM
- **Decision**: Direct HTTP requests to Claude API instead of Basic LLM Chain nodes
- **Reasoning**: Better reliability, error control, and performance
- **Impact**: More stable workflows, easier debugging

## Monitoring & Maintenance

### Workflow Health Checks
- **Daily**: Check execution logs for failures
- **Weekly**: Review API usage and costs
- **Monthly**: Optimize workflows based on customer feedback

### Performance Metrics
- **Execution Time**: Target <30 seconds for payment processing
- **Success Rate**: Target >99% for critical workflows
- **API Costs**: Monitor Claude and SEMrush usage

### Scaling Considerations
- **Customer Growth**: Plan for 100+ customers by month 3
- **API Limits**: Monitor and scale SEMrush plan as needed
- **Execution Limits**: n8n Cloud handles up to 5,000 executions/month

---

## Detailed Workflow Architectures (2025-01-30)

### Report Generation Engine (#6) - CRITICAL PATH
```
[Input: Customer + 6 Competitors]
    ↓
[Parallel API Branch]
├── Customer Analysis (20 units)
│   ├── Domain Organic
│   └── Domain Adwords
├── Competitor Analysis (120 units) 
│   ├── 6x Domain Organic
│   └── 6x Domain Adwords
├── Keyword Analysis (30 units)
│   ├── Top 10 keywords
│   └── Gap analysis
├── Backlinks (350 units)
│   ├── Customer backlinks
│   └── 6x Competitor backlinks
└── Ad Copy (60 units)
    └── 6x Competitor ads
    ↓
[Merge Results] - 650 units total
    ↓
[Claude LangChain Node]
├── Template: MRC_Startup_Tier_Template.md
├── Model: Claude 3 Opus
└── Output: HTML with inline CSS
    ↓
[Store in Supabase]
└── [Return HTML Report]
```

### Email Click Handler Workflow
```
[Webhook: /report/{encoded_params}]
    ↓
[Decode Parameters]
├── Prospect domain
├── Industry
└── Tracking ID
    ↓
[Check Cache]
├── If exists → Return cached
└── If not → Continue
    ↓
[Get Industry Competitors]
└── Top 6 for their industry
    ↓
[Call Report Generation Engine]
    ↓
[Track Event]
├── Log click in Supabase
├── Start conversion timer
└── Send to analytics
    ↓
[Return HTML Report]
```

### Sunday LinkedIn Pre-Generator
```
[Cron: Sunday 10 PM]
    ↓
[Get Week's Prospects]
└── 85 LinkedIn connections
    ↓
[Batch Process - 5 parallel]
├── Batch 1: Reports 1-17
├── Batch 2: Reports 18-34
├── Batch 3: Reports 35-51
├── Batch 4: Reports 52-68
└── Batch 5: Reports 69-85
    ↓
[For Each Prospect]
├── Get industry
├── Get 6 competitors
├── Generate HTML report
└── Store with metadata
    ↓
[Schedule Distribution]
└── 17/day Mon-Fri
```

## Critical Implementation Notes

### API Efficiency
- **Parallel calls**: Maximum 10 requests/second
- **Batch size**: 5 reports concurrently for pre-generation
- **Caching**: 24-hour cache for email, 7-day for LinkedIn
- **Error handling**: Retry 3x with exponential backoff

### Report Storage
- **Format**: HTML with inline CSS (no external dependencies)
- **Size**: ~150-200KB per report
- **Storage**: Supabase JSONB field or S3 with CDN
- **Indexing**: By domain, industry, generation date

### Cost Tracking
- **Per report**: Log 650 units used
- **Monthly dashboard**: Track against 528,450 budget
- **Alerts**: 80%, 90%, 95% usage warnings
- **Overage handling**: Automatic purchase of additional units

## Next Session Focus
When working on n8n workflows:
1. Create Report Generation Engine (#6) FIRST - it's the core
2. Remove 48-hour delay from Payment Processing (#1)
3. Build Email Click Handler for conversions
4. Setup Sunday LinkedIn Pre-Generator
5. All workflows must handle 6 competitors and output HTML

## Payment Processing Workflow (Detailed)

### Stripe Webhook → Customer Onboarding Flow
**Trigger**: Stripe webhooks (checkout.session.completed, customer.subscription.created)
**Process**:

```
[Stripe Webhook Event]
    ↓
[Validate Webhook Signature]
    ↓
[Extract Customer Data]
├── email
├── name
├── subscription_tier
├── payment_method_id
└── amount_paid
    ↓
[Create/Update Customer in Supabase]
    ↓
[Immediate Report Generation] (NO DELAY)
├── Get customer domain
├── Find 6 competitors
├── Generate full report (650 units)
└── Store in database
    ↓
[Send Welcome Email]
├── Report link
├── Dashboard credentials
└── Next steps guide
    ↓
[Create Dashboard Access]
├── Generate secure password
├── Create user account
└── Set permissions by tier
    ↓
[Log Transaction]
└── [Notify Slack/Team]
```

### Payment Error Handling
- **Failed payments**: Retry 3x over 7 days
- **Disputed charges**: Pause account, notify team
- **Refunds**: Process automatically, revoke access
- **Upgrades/Downgrades**: Prorate and adjust immediately

## Report Tracking & Analytics System

### Report Generation Metrics
```sql
report_analytics {
  report_id: UUID
  customer_id: UUID
  generation_time_ms: integer
  api_units_used: integer
  report_type: enum ['free', 'startup', 'growth', 'enterprise']
  competitors_analyzed: integer
  keywords_found: integer
  opportunities_identified: integer
  generated_at: timestamp
  delivery_method: enum ['email', 'dashboard', 'api']
}
```

### Engagement Tracking
```sql
report_engagement {
  report_id: UUID
  opened_at: timestamp
  time_on_page_seconds: integer
  scroll_depth_percentage: integer
  clicks: jsonb {
    total: integer
    competitor_links: integer
    cta_clicks: integer
    download_pdf: boolean
  }
  shared: boolean
  conversion_event: enum ['trial_started', 'demo_requested', 'purchased']
}
```

### Real-time Analytics Dashboard
- **Daily Active Reports**: Track views, engagement
- **Conversion Funnel**: Report view → Trial → Paid
- **API Usage**: Real-time unit consumption
- **Revenue Attribution**: Which reports drive sales
- **A/B Testing**: Report format variations

## Follow-Up Automation Sequences

### Free Report Viewers (Email/LinkedIn)
**Day 0**: Report delivered
```
Subject: Your MRC Competitive Analysis is Ready
- Report link (expires in 7 days)
- 3 key insights preview
- CTA: "See Full Analysis"
```

**Day 3**: Engagement Check
```
Subject: Did you see where [Competitor] is beating you?
- Specific metric from their report
- Implementation tip
- CTA: "Get Weekly Updates" → Paid tier
```

**Day 7**: Value Demonstration
```
Subject: Your competitors gained 2,400 visits this week
- What changed since last report
- Urgency: "Report expires tonight"
- CTA: "Keep Monitoring" → 50% off first month
```

**Day 14**: Final Conversion Push
```
Subject: Last chance: Your competitive advantage
- Success story from similar company
- Limited time offer
- CTA: "Start Free Trial" → Actually paid tier
```

### Paid Customer Success Sequence
**Day 1**: Welcome & Onboarding
- Video walkthrough
- Best practices guide
- Calendar link for success call

**Week 1**: First Value Check
- Usage analytics
- Additional insights found
- Tips for maximum value

**Month 1**: Optimization Review
- ROI report
- Expansion opportunities
- Referral program invite

### Churn Prevention Automation
**Low Usage Alert** (< 2 logins in 14 days)
- Email: "Missing opportunities" with fresh insights
- In-app: Popup with new competitor alert
- SMS: For Growth/Enterprise only

**Pre-Renewal Sequence** (14 days before)
- Value summary: Insights delivered, ROI achieved
- New features announcement
- Loyalty discount for annual upgrade

## Advanced Workflow Features

### Dynamic Competitor Selection
```javascript
// Instead of fixed 6 competitors, adapt by tier:
function selectCompetitors(customer, allCompetitors) {
  if (customer.tier === 'enterprise') {
    // Include international competitors
    return [...allCompetitors.domestic.slice(0,4), 
            ...allCompetitors.international.slice(0,2)];
  } else if (customer.tier === 'growth') {
    // Focus on direct competitors
    return allCompetitors.direct.slice(0,6);
  } else {
    // Startup: Mix of aspirational and direct
    return [...allCompetitors.direct.slice(0,3),
            ...allCompetitors.aspirational.slice(0,3)];
  }
}
```

### Smart Report Caching
```javascript
// Cache strategy to reduce API calls
const cacheRules = {
  'free_report': {
    ttl: 24 * 60 * 60 * 1000, // 24 hours
    maxViews: 5,
    regenerateIfStale: false
  },
  'paid_startup': {
    ttl: 7 * 24 * 60 * 60 * 1000, // 7 days
    maxViews: unlimited,
    regenerateIfStale: true
  },
  'paid_growth': {
    ttl: 24 * 60 * 60 * 1000, // 24 hours
    maxViews: unlimited,
    regenerateIfStale: true
  }
};
```

### Intelligent Rate Limiting
```javascript
// Prevent API abuse while ensuring good UX
const rateLimits = {
  semrush: {
    requestsPerSecond: 10,
    dailyLimit: 20000,
    burstAllowance: 50,
    queueStrategy: 'priority' // Enterprise first
  },
  claude: {
    requestsPerMinute: 60,
    tokensPerDay: 1000000,
    fallbackModel: 'claude-instant' // If limits hit
  },
  reportGeneration: {
    concurrentReports: 10,
    queueTimeout: 300000, // 5 minutes
    retryAttempts: 3
  }
};
```

## Quality Control Workflows (NEW - Critical for Quality)

### 21. Sunday Message QC Workflow
- **Purpose**: Review and fix all 5,000 generated messages before sending
- **Trigger**: Runs Sunday 2 AM after message generation
- **Process**:
  1. Query prospects WHERE message_qc_status = 'pending'
  2. Send each message to Claude for review
  3. Check for: placeholders, grammar, personalization accuracy
  4. Update final_message and qc_status
  5. Set ready_to_send = TRUE when passed
- **Performance**: Process in batches of 100, ~2 hours total

### 22. Sunday Report QC Workflow  
- **Purpose**: Quality check all 85 pre-generated LinkedIn reports
- **Trigger**: Runs Sunday 3 AM after report generation
- **Process**:
  1. Query generated_reports WHERE qc_status = 'pending'
  2. Validate data accuracy, formatting, calculations
  3. Check for missing sections or broken elements
  4. Update final_html_content and ready_for_delivery
- **Critical Checks**: Competitor data, ROI calculations, CTA links

### 23. Real-time Email Report QC
- **Purpose**: QC reports generated from email clicks before delivery
- **Trigger**: After report generation, before email send
- **Process**:
  1. Quick validation (30-60 seconds)
  2. Check critical errors only
  3. If blocked, send apology email and queue for manual review
  4. Log all QC results for analysis
- **SLA**: Must complete within 60 seconds

## Free Report Distribution Implementation

### Phase 1: Weekly Prospect Discovery (Sunday Night)

#### LinkedIn Prospect Scraping (8 PM)
**Volume**: 500-1000 prospects/week via Phantombuster
**Data Collected**:
- Full name, LinkedIn URL, Position
- Company name, domain, size
- Industry, Location

**n8n Workflow**: LinkedIn Prospect Processor
```
[Phantombuster Webhook] → [Data Validation] → [Domain Extraction] → [Store in Supabase]
```

#### Email Prospect Discovery (9 PM)
**Volume**: 4,000-5,000 prospects/week via Apollo.io
**Filters**:
- Revenue: $1M-$50M
- Technologies: WordPress, Shopify, HubSpot
- Ad spend indicators present
- No existing SEO tools

#### Competitive Intelligence Enrichment (10 PM - 2 AM)
**Process**: Limited SEMrush enrichment (7 units per prospect)
```javascript
for (const prospect of prospects) {
  // Minimal API calls for enrichment
  const enrichment = {
    domainOverview: await semrush.getDomain(prospect.domain), // 1 unit
    topCompetitors: await semrush.getCompetitors(prospect.domain, 5), // 5 units
    estimatedAdSpend: await semrush.getAdSpend(prospect.domain), // 1 unit
  };
  
  // Calculate opportunity score
  prospect.opportunityScore = calculateScore(enrichment);
  prospect.enrichmentStatus = 'completed';
}
```

### Phase 2: Personalized Outreach

#### LinkedIn Daily Outreach (Mon-Fri, 9 AM)
**Volume**: 17 connections/day (85/week total)
**Claude Personalization**:
```
Prompt: "Create a 250-character LinkedIn connection request that:
- Mentions their company by name
- References their top competitor
- Hints at missed opportunity without details
- Sounds human, not salesy"

Example: "Hi Sarah, noticed HealthyPets is competing with Chewy. 
Found 3 keywords they're ranking for that you're missing - 
could be worth 500+ visits/month. Happy to share the data."
```

#### Email Campaign (Mon-Fri, 10 AM - 2 PM)
**Volume**: 833 emails/day
**Industry Templates**:
- SaaS: "Competitor feature comparison"
- E-commerce: "Missed revenue keywords" 
- Healthcare: "Patient acquisition gaps"
- Services: "Local search opportunities"

### Phase 3: Report Generation Strategy

#### LinkedIn: Pre-generate Sunday Night
- Generate all 85 reports in parallel batches
- Store HTML in database with 7-day TTL
- Link to prospect records

#### Email: Generate On-Click Only
- Unique tracking link per email
- 3-5 minute generation time
- 24-hour cache to prevent duplicates
- Loading page with progress bar

### Unique Link Security
```javascript
function generateSecureReportLink(prospect) {
  const payload = {
    prospect_id: prospect.id,
    domain: prospect.company_domain,
    ip_hash: hash(request.ip),
    fingerprint: generateDeviceFingerprint(),
    valid_for_hours: 168, // 7 days
    single_use: false,
    max_views: 5
  };
  
  const token = jwt.sign(payload, process.env.JWT_SECRET);
  return `${BASE_URL}/report/${token}`;
}
```

### Success Metrics & Conversion Funnel
- **Discovery**: 5,000 prospects/week
- **Enrichment**: 95% success rate  
- **Email CTR**: 2.5% = 448 clicks/month
- **LinkedIn accepts**: 30% = 110/month
- **Total report views**: 558/month
- **Paid conversions**: 10% of viewers = 56/month
- **MRR Growth**: $2,240/month (56 × $40 average)

### Critical Implementation Constraints
1. **NO bulk email report generation** - Only generate on click
2. **LinkedIn limits**: Stay under 100 connections/week
3. **SEMrush budget**: 30,000 units/month during free phase
4. **Email reputation**: Never send from primary domain
5. **GDPR compliance**: Include unsubscribe, honor immediately