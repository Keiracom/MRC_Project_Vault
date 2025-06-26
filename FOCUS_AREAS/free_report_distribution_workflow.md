# Free Report Distribution Workflow - Detailed Process

## Overview
This document details the complete workflow for free report distribution during the pre-launch phase, focusing on the Startup tier prospects. The system generates prospects weekly but only creates reports when engagement is confirmed.

## Phase 1: Weekly Prospect Discovery & Enrichment (Sunday Night)

### 1.1 LinkedIn Prospect Scraping via Phantombuster
**Timing**: Every Sunday 8 PM
**Volume**: 500-1000 LinkedIn prospects per week

**Phantombuster Setup**:
- **Tool**: LinkedIn Sales Navigator Search Export
- **Search Criteria**:
  - Company size: 10-200 employees
  - Industries: SaaS, E-commerce, Professional Services, Healthcare
  - Decision makers: CEO, CMO, Marketing Director, Founder
  - Location: US major metros

**Data Collected**:
```
- Full name
- LinkedIn profile URL
- Current position
- Company name
- Company LinkedIn URL
- Company website (if available)
- Company size
- Industry
- Location
```

**n8n Workflow: LinkedIn Prospect Processor**:
1. **Phantombuster Webhook** → n8n receives CSV export
2. **Data Validation** → Clean and standardize data
3. **Company Domain Extraction** → Use clearbit/hunter.io to find domains
4. **Store in Supabase** `prospects` table:
   ```sql
   prospects {
     id: UUID
     full_name: string
     linkedin_url: string
     position: string
     company_name: string
     company_domain: string
     company_size: string
     industry: string
     location: string
     source: 'linkedin'
     created_at: timestamp
     enrichment_status: 'pending'
   }
   ```

### 1.2 Email Prospect Discovery via Apollo.io
**Timing**: Sunday 9 PM (after LinkedIn)
**Volume**: 4,000-5,000 prospects per week

**Apollo.io API Process**:
- **Search Filters**:
  - Company revenue: $1M-$50M
  - Technologies used: WordPress, Shopify, HubSpot, Salesforce
  - Ad spend indicators: Google Ads, Facebook Ads pixels
  - No existing SEO tools detected

**Data Collected**:
```
- Contact email
- Full name
- Title
- Company domain
- Industry
- Employee count
- Estimated revenue
- Technologies detected
- Social media profiles
```

**n8n Workflow: Apollo Prospect Processor**:
1. **Apollo API** → Batch search (500 records at a time)
2. **Email Validation** → Verify deliverability
3. **Merge/Dedupe** → Check against existing prospects
4. **Store in Supabase** with additional fields:
   ```sql
   prospects {
     email: string
     phone: string (if available)
     technologies: array
     revenue_estimate: string
     apollo_score: integer
     source: 'apollo'
   }
   ```

### 1.3 Competitive Intelligence Enrichment
**Timing**: Sunday 10 PM - Monday 2 AM
**Process**: Enrich ALL prospects with baseline competitive data

**n8n Workflow: Prospect Intelligence Gatherer**:
```
For each prospect domain:
├── SEMrush API calls (limited):
│   ├── Domain Overview (1 unit)
│   ├── Top 5 organic competitors (5 units)
│   └── Estimated ad spend (1 unit)
├── Store in prospect_intelligence:
│   ├── domain
│   ├── monthly_traffic_estimate
│   ├── top_competitors: array[5]
│   ├── estimated_ad_spend
│   ├── main_traffic_source
│   └── opportunity_score: 1-10
└── Mark enrichment_status: 'completed'
```

**Critical**: This is NOT full report generation - just enough data to personalize outreach

## Phase 2: Personalized Outreach Generation

### 2.1 LinkedIn Connection Requests (Monday-Friday)
**Daily Volume**: 17 connections/day (85/week total)
**Timing**: 9 AM local time

**n8n Workflow: LinkedIn Daily Personalizer**:
1. **Select Today's Prospects**:
   ```sql
   SELECT * FROM prospects 
   WHERE source = 'linkedin' 
   AND contacted_at IS NULL
   AND enrichment_status = 'completed'
   ORDER BY opportunity_score DESC
   LIMIT 17
   ```

2. **Generate Personalized Messages via Claude**:
   ```
   Input to Claude:
   - Prospect name, position, company
   - Their top competitor
   - One key insight from enrichment
   
   Claude Prompt:
   "Create a 250-character LinkedIn connection request that:
   - Mentions their company by name
   - References their competitor {competitor_name}
   - Hints at missed opportunity without giving away details
   - Sounds human, not salesy"
   
   Example Output:
   "Hi Sarah, noticed HealthyPets is competing with Chewy. 
   Found 3 keywords they're ranking for that you're missing - 
   could be worth 500+ visits/month. Happy to share the data."
   ```

3. **Generate Unique Report Link**:
   ```javascript
   const reportId = generateUUID();
   const encodedParams = base64Encode({
     prospect_id: prospect.id,
     domain: prospect.company_domain,
     industry: prospect.industry,
     competitors: prospect.top_competitors,
     valid_until: Date.now() + 7_days
   });
   
   const uniqueLink = `https://app.mrcinsights.com/report/${reportId}/${encodedParams}`;
   ```

4. **Pre-generate LinkedIn Reports** (Sunday night only):
   - Generate all 85 reports for the week
   - Store HTML in `generated_reports` table
   - Link to prospect record

5. **Store Outreach Record**:
   ```sql
   outreach_attempts {
     prospect_id: UUID
     channel: 'linkedin'
     message_sent: string
     report_link: string
     sent_at: timestamp
     opened_at: timestamp
     clicked_at: timestamp
   }
   ```

### 2.2 Email Campaigns (Monday-Friday)
**Daily Volume**: 833 emails/day
**Timing**: Staggered 10 AM - 2 PM

**n8n Workflow: Email Campaign Personalizer**:
1. **Select Today's Email Batch**:
   ```sql
   SELECT * FROM prospects 
   WHERE source = 'apollo' 
   AND email IS NOT NULL
   AND contacted_at IS NULL
   AND enrichment_status = 'completed'
   ORDER BY opportunity_score DESC
   LIMIT 833
   ```

2. **Segment by Industry** for template selection:
   - SaaS → "Competitor feature comparison"
   - E-commerce → "Missed revenue keywords"
   - Healthcare → "Patient acquisition gaps"
   - Services → "Local search opportunities"

3. **Generate Personalized Email via Claude**:
   ```
   Input to Claude:
   - Company name, industry
   - Top 2 competitors
   - Main traffic source
   - Estimated ad spend
   - Email template for industry
   
   Claude Prompt:
   "Personalize this email template with specific data:
   - Use actual competitor names
   - Reference their estimated ad spend if >$5k/month
   - Mention specific traffic source (organic/paid)
   - Keep under 150 words
   - Make subject line mention their company name"
   
   Example Output:
   Subject: "TechStartup losing 2,400 visits/month to Competitor.io"
   
   Body:
   "Hi Mike,
   
   Quick question - did you know Competitor.io is capturing 2,400 
   organic visits/month from keywords TechStartup should own?
   
   I noticed you're spending ~$8K/month on Google Ads, but missing 
   these free organic opportunities.
   
   Generated a free competitive analysis showing:
   - 47 keywords Competitor.io ranks for (you don't)
   - Your missed traffic value: $4,200/month
   - 3 quick wins you could implement this week
   
   Want to see the data? Takes 2 min to review:
   [UNIQUE LINK]
   
   Best,
   Sarah from MRC"
   ```

4. **Generate Unique Click Links** (NOT pre-generated reports):
   ```javascript
   // Each email gets unique tracking link
   const clickId = generateUUID();
   const trackingParams = encrypt({
     prospect_id: prospect.id,
     email_campaign_id: campaign.id,
     sent_at: Date.now(),
     expires_at: Date.now() + 30_days
   });
   
   const clickLink = `https://app.mrcinsights.com/free-report/${clickId}?t=${trackingParams}`;
   ```

5. **Send via SendGrid/Instantly.ai**:
   - Track opens, clicks, bounces
   - Update outreach_attempts record

## Phase 3: Report Generation (Only on Engagement)

### 3.1 LinkedIn Report Access
**When**: Connection accepted → prospect visits pre-generated report link
**Process**: 
1. Webhook captures visit
2. Retrieve pre-generated HTML from `generated_reports`
3. Track engagement in analytics
4. Start 7-day follow-up sequence

### 3.2 Email Click Handler (On-Demand Generation)
**When**: Email recipient clicks unique link
**Process**:

**n8n Workflow: Report Generation Trigger**:
1. **Webhook receives click**:
   ```
   GET /free-report/{clickId}?t={trackingParams}
   ```

2. **Validate & Decode**:
   - Verify link hasn't expired
   - Decode prospect information
   - Check if report already generated (24hr cache)

3. **If no cached report, generate NOW**:
   ```
   Trigger: Report Generation Engine
   Input: {
     domain: prospect.company_domain,
     competitors: prospect.top_competitors.slice(0, 6),
     industry: prospect.industry,
     report_type: 'startup_tier_free'
   }
   ```

4. **Report Generation Engine** (3-5 minutes):
   - 21 SEMrush API calls (650 units)
   - Claude processes data into insights
   - Generate HTML report
   - Store in cache for 24 hours

5. **Deliver Report**:
   - Show loading page with progress bar
   - Stream report when ready
   - Track time-on-page, scroll depth
   - Capture email for follow-up

### 3.3 Conversion Tracking
**Track prospect journey**:
```sql
prospect_journey {
  prospect_id: UUID
  stage: enum ['discovered', 'enriched', 'contacted', 'engaged', 'report_viewed', 'trial_interest', 'converted']
  timestamp: timestamp
  channel: string
  details: jsonb
}
```

## Phase 4: Follow-Up Sequences

### 4.1 Report Viewers (High Intent)
- **Day 1**: Report delivered
- **Day 3**: "Did you see the keyword gaps?" email
- **Day 7**: "Here's how to fix the top issue" email
- **Day 14**: "Limited time: 50% off first month" offer

### 4.2 Non-Engaged (No Click)
- **Day 7**: Different angle email
- **Day 21**: Final attempt with urgency
- **Day 30**: Move to quarterly newsletter list

## Key Technical Details

### Unique Link Generation Security
```javascript
// Prevent link sharing/abuse
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

### Rate Limiting & Queueing
- LinkedIn: Max 17/day, queue Sunday's batch
- Email: 200/hour per domain, rotate 3 domains
- SEMrush API: 10 requests/second max
- Report generation: Max 10 concurrent

### Data Retention
- Prospects: Permanent
- Enrichment data: 90 days
- Generated reports: 30 days
- Tracking events: 180 days
- Personal data: GDPR compliant deletion

## Success Metrics
- **Discovery**: 5,000 prospects/week
- **Enrichment**: 95% success rate
- **Email delivery**: 97% delivered
- **Email clicks**: 2.5% CTR = 448 clicks/month
- **LinkedIn accepts**: 30% = 110/month
- **Report views**: 558/month total
- **Trial conversions**: 10% = 56 trials/month
- **Paid conversions**: 30% of trials = 17 customers/month

## Critical Constraints
1. **NO bulk report pre-generation for email** (would need 17,910 reports!)
2. **LinkedIn limits**: 100 connections/week max, we do 85 for safety
3. **SEMrush API**: Must stay under 30,000 units/month during free phase
4. **Email reputation**: Never send from primary domain
5. **GDPR/CAN-SPAM**: Include unsubscribe, honor immediately

This workflow ensures we only use resources (API calls, Claude tokens, storage) for engaged prospects while maintaining personalization at scale.