# MRC Implementation Decisions - 2025-06-27

## Overview
This document captures all critical implementation decisions made for the MRC platform, providing rationale and technical details for future reference.

## 1. UUID-Based Prospect Tracking

### Decision
Each prospect gets ONE permanent `report_uuid` that works for all channels (email and LinkedIn).

### Implementation
```sql
ALTER TABLE prospects 
ADD COLUMN report_uuid UUID DEFAULT uuid_generate_v4() UNIQUE;
```

### Benefits
- **Simplicity**: One UUID per prospect, no complex tracking tables
- **Permanence**: Links never expire or change
- **Universal**: Same link works for email and LinkedIn
- **Clean**: No redundant data or multiple IDs

### Example Flow
```
Prospect: Mike from TechStartup
UUID: 7f3b4e89-1234-5678-90ab-cdef12345678

Email link: mrcinsights.com/report/7f3b4e89-1234-5678-90ab-cdef12345678
LinkedIn link: Same exact URL
```

## 2. Sunday Batch Processing Architecture

### Decision
Generate ALL content (5,000 messages + 85 reports) on Sunday nights with comprehensive QC.

### Timeline
```
6:00 PM - 10:00 PM: Data Collection
├── Phantombuster → 500 LinkedIn prospects (rich data)
└── Apollo.io → 4,500 email prospects (basic data)

10:00 PM - 2:00 AM: Generation Phase
├── 5,000 personalized messages via Claude
└── 85 LinkedIn reports (pre-generated)

2:00 AM - 6:00 AM: Quality Control
├── QC all 5,000 messages
└── QC all 85 reports

6:00 AM Monday: Everything ready for the week
```

### Rationale
- **Efficiency**: Batch processing more cost-effective than real-time
- **Quality**: Time for comprehensive QC before sending
- **Monitoring**: Can review everything before it goes out
- **Debugging**: If something breaks, messages are safe in database

## 3. Quality Control Framework

### Decision
Every message and report goes through automated QC before reaching prospects.

### Three-Layer System
1. **Sunday Message QC**: Review 5,000 messages for errors
2. **Sunday Report QC**: Validate 85 pre-generated reports
3. **Real-time Email QC**: Quick check for on-demand reports (30-60 sec)

### QC Checks
- **Messages**: Placeholders, personalization, grammar, length
- **Reports**: Data accuracy, completeness, formatting, business logic
- **Real-time**: Critical errors only (speed priority)

### Failure Handling
```javascript
if (qc_status === 'blocked') {
  // Send apology email
  // Queue for manual review
  // Log for analysis
} else if (qc_status === 'fixed') {
  // Use Claude's corrected version
  // Log what was fixed
}
```

## 4. Email Click Flow & Timing

### Decision
4-6 minute total delivery time from click to inbox, including real-time QC.

### User Experience Flow
```
0 sec: Click link → See loading page
30 sec: Receive confirmation email
3-5 min: Report generation
30-60 sec: Quality control
4-6 min: Full report in inbox
```

### Loading Page Strategy
- **Immediate response**: No blank page or 404
- **Set expectations**: "Takes 3-5 minutes"
- **Build anticipation**: Show what's being analyzed
- **Reduce anxiety**: Confirm email address

### Why This Timing
- **Psychology**: Strike while interest is hot
- **Technical**: 21 SEMrush API calls take time
- **Quality**: Too fast seems generic
- **Conversion**: 67% happen in first 48 hours

## 5. Database Schema Design

### Decision
Extend existing schema rather than create new tables where possible.

### Key Additions
```sql
-- Prospects table extensions
- report_uuid (universal identifier)
- LinkedIn-specific columns (headline, recent_post, etc.)
- Message generation fields
- QC tracking fields

-- New tables only where necessary
- generated_reports (for pre-generated content)
- email_tracking (for engagement metrics)
- report_qc_log (for QC analytics)
```

### Design Principles
- **Single source of truth**: Most data in prospects table
- **Avoid joins**: Denormalize for query performance
- **Track everything**: Comprehensive audit trail
- **Plan for scale**: Indexes on all filter fields

## 6. Report Generation Strategy

### Decision
Hybrid approach: Pre-generate for LinkedIn, on-demand for email.

### LinkedIn (Pre-generated)
- **Why**: Immediate value when connection accepted
- **Volume**: 85/week pre-generated Sunday night
- **Storage**: 7-day TTL in generated_reports table

### Email (On-demand)
- **Why**: 97.5% never click - waste to pre-generate
- **Volume**: ~448/month generated on click
- **Cache**: 24 hours to handle multiple visits

### Cost Optimization
- **Total reports**: 813/month (365 LinkedIn + 448 email)
- **Not**: 5,000/week (would be wasteful)
- **Savings**: 95% reduction in API costs

## 7. Message Personalization Levels

### Decision
Two-tier personalization based on data availability.

### LinkedIn Messages (High Personalization)
```javascript
// Rich data available
- Recent post topic
- Headline changes
- Mutual connections
- Company milestones
```

### Email Messages (Semi-Personalization)
```javascript
// Basic data only
- Company name
- Industry
- Top competitor
- Estimated metrics
```

### Example Difference
**LinkedIn**: "Hi Sarah, saw your post about struggling with Shopify conversion rates. Noticed you're competing with BeautyBrand who just hit 18% CVR..."

**Email**: "Hi Mike, noticed TechStartup uses Stripe + React stack similar to CompetitorX who's capturing 2,400 visits/month..."

## 8. Infrastructure Decisions

### Pending Setup (Before Launch)
1. **Phantombuster**: Growth plan ($69/mo) for LinkedIn scraping
2. **Email Domains**: 3 total for rotation
3. **SendGrid**: Transactional emails (reports, welcome)
4. **Instantly.ai**: Cold outreach (rotating domains)
5. **SEMrush Business**: $449.95/mo for 3M units
6. **Bubble Dashboard**: 4-6 hours to implement

### Workflow Priority
1. Report Generation Engine (#6) - Foundation
2. Email Click Handler (#4-New) - Conversions
3. LinkedIn Pre-Generator (#4-Mod) - Efficiency
4. QC Workflows (#21-23) - Quality
5. Dashboard - Monitoring

## 9. Conversion Optimization

### Decision
Multiple touchpoints with decreasing intervals.

### Email Sequence Timing
- Day 0: Report delivered
- Day 2: Implementation tip
- Day 5: Case study
- Day 10: Competitor update
- Day 14: Expiry warning
- Day 21: Final offer

### Psychological Triggers
- **Urgency**: "Report expires in 14 days"
- **Social Proof**: "47 agencies in [industry] subscribe"
- **Loss Aversion**: "Competitors gaining 2,400 visits"
- **Authority**: "Based on 147M keyword database"

## 10. Monitoring & Analytics

### Decision
Real-time visibility into all metrics via Supabase views.

### Key Dashboards
```sql
- v_sunday_progress (batch processing status)
- v_email_funnel (conversion metrics)
- v_qc_performance (quality metrics)
- v_daily_send_batch (operational view)
```

### Alert Thresholds
- QC failure rate >5%
- Email CTR <1.5%
- API usage >80%
- Report generation >10 min

## Quick Decision Reference

| Decision | Choice | Alternative Considered | Why |
|----------|--------|----------------------|-----|
| Tracking | UUID per prospect | Click ID per email | Simpler, permanent |
| Generation | Sunday batch | Real-time all | Quality control |
| QC | 100% automated | Sample checking | Brand protection |
| Email timing | 4-6 minutes | Instant or hours | Optimal engagement |
| Reports | Hybrid approach | All pre-generated | Cost efficiency |
| Database | Extend existing | New architecture | Faster to implement |
| Personalization | Two-tier | Same for all | Data availability |
| Dashboard | Bubble | Custom React | Speed to market |

## Implementation Status

### Completed
- ✅ Database schema design
- ✅ UUID tracking system
- ✅ QC framework design
- ✅ Workflow architecture
- ✅ Decision documentation

### Pending
- ⏳ n8n workflow creation
- ⏳ Infrastructure setup
- ⏳ Dashboard implementation
- ⏳ Testing & optimization

---

*Last Updated: 2025-06-27*
*Next Review: Post-implementation (est. 30 days)*