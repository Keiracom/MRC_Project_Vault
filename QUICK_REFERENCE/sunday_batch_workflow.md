# Sunday Night Batch Workflow - Complete Timeline

## Overview
Every Sunday night, the MRC system processes 5,000 prospects, generates personalized messages, creates 85 reports, and performs quality control - all ready for the week's distribution.

## Master Timeline

```
Sunday Evening → Monday Morning
6:00 PM ────────────────────────────────► 6:00 AM
   │          │          │          │          │
   ▼          ▼          ▼          ▼          ▼
Collection  Generation    QC      Ready    Scheduled
(6-10 PM)  (10 PM-2 AM) (2-6 AM) (6 AM)   (Mon-Fri)
```

## Detailed Phase Breakdown

### Phase 1: Data Collection (6:00 PM - 10:00 PM)

#### 6:00 PM - Start Collection Workflows

**Workflow #1A: LinkedIn Collection via Phantombuster**
```javascript
// Phantombuster Configuration
{
  scraper: "LinkedIn Search Export",
  search_queries: [
    "CEO marketing software",
    "CMO B2B SaaS", 
    "VP Marketing technology"
  ],
  limit: 500,
  data_points: [
    "name", "headline", "company", "location",
    "connections", "recent_activity", "post_content"
  ]
}

// Rich data collected:
- Full name and position
- Company details and growth
- Recent posts and topics
- Mutual connections
- Profile changes
```

**Workflow #1B: Email Collection via Apollo.io**
```javascript
// Apollo API Configuration
{
  search_filters: {
    job_titles: ["CEO", "CMO", "VP Marketing"],
    company_size: [10, 500],
    industries: ["Software", "E-commerce", "Healthcare"],
    technologies: ["Shopify", "Stripe", "HubSpot"]
  },
  limit: 4500,
  data_points: [
    "email", "name", "company", "revenue",
    "employee_count", "technologies"
  ]
}

// Basic data collected:
- Verified email addresses
- Company fundamentals
- Technology stack
- Revenue estimates
```

#### 8:00 PM - SEMrush Enrichment

**Workflow #2: Baseline Competitor Intelligence**
```javascript
// For ALL 5,000 prospects
async function enrichProspect(prospect) {
  const data = await semrush.getDomainOverview(prospect.domain);
  
  return {
    organic_traffic: data.organic_traffic,
    paid_traffic: data.paid_traffic,
    top_competitors: data.competitors.slice(0, 6),
    main_keywords: data.keywords.slice(0, 5),
    ad_spend_estimate: data.adwords_budget
  };
}

// Store in prospects table
// Uses only 1 unit per prospect = 5,000 units total
```

### Phase 2: Content Generation (10:00 PM - 2:00 AM)

#### 10:00 PM - Message Generation

**Workflow #3A: LinkedIn Message Generation (500 messages)**
```javascript
const linkedinMessagePrompt = `
Create a 250-character LinkedIn connection request that:

PROSPECT DATA:
- Name: ${prospect.first_name}
- Company: ${prospect.company_name}
- Headline: ${prospect.linkedin_headline}
- Recent Post: "${prospect.linkedin_recent_post}"
- Posted: ${prospect.linkedin_recent_post_date}
- Mutual Connections: ${prospect.linkedin_mutual_connections}

REQUIREMENTS:
- Reference their specific recent activity
- Mention a relevant competitor insight
- Natural, conversational tone
- Include reason for connecting
- End with soft value prop

EXAMPLE OUTPUT:
"Hi Sarah, your post on Shopify conversion struggles resonated. 
Noticed BeautyBrand just hit 18% CVR using specific checkout 
optimizations you might find interesting. Worth connecting to 
share what's working in cosmetics e-commerce?"
`;

// Process in batches of 50
// Total time: ~1 hour for 500
```

**Workflow #3B: Email Message Generation (4,500 messages)**
```javascript
const emailMessagePrompt = `
Create email subject and body (150 words max):

PROSPECT DATA:
- Name: ${prospect.first_name}
- Company: ${prospect.company_name}
- Industry: ${prospect.industry}
- Top Competitor: ${prospect.top_competitors[0].domain}
- Traffic Gap: ${competitorTraffic - prospectTraffic}
- Ad Spend: ${prospect.ad_spend_estimate}

SUBJECT REQUIREMENTS:
- Include company name
- Mention specific metric or competitor
- Create curiosity without clickbait

BODY REQUIREMENTS:
- Personal greeting
- Specific insight about their competition
- Quantified opportunity
- Clear value proposition
- Single CTA to view report
- Professional signature

EXAMPLE OUTPUT:
Subject: "TechStartup losing 2,400 visits/month to Competitor.io"

Body:
"Hi Mike,

Quick question - did you know Competitor.io is capturing 2,400 
organic visits/month from keywords TechStartup should own?

I noticed you're spending ~$8K/month on Google Ads, but missing 
these free organic opportunities.

Generated a free competitive analysis showing:
• 47 keywords Competitor.io ranks for (you don't)
• Your missed traffic value: $4,200/month
• 3 quick wins you could implement this week

Want to see the specific keywords and action plan?

[View Your Free Analysis]

Best,
Sarah from MRC
P.S. The report shows exactly how to outrank them - takes 2 min to review."
`;

// Process in batches of 100
// Total time: ~3 hours for 4,500
```

#### 12:00 AM - Report Pre-Generation

**Workflow #4: LinkedIn Report Generation (85 reports)**
```javascript
// Select top 85 LinkedIn prospects for the week
const linkedinBatch = await supabase
  .from('prospects')
  .select('*')
  .eq('is_linkedin', true)
  .eq('ready_to_send', false)
  .order('lead_score', { ascending: false })
  .limit(85);

// For each prospect, generate full report
for (const prospect of linkedinBatch) {
  const report = await generateCompetitiveReport({
    company: prospect.company_domain,
    competitors: prospect.top_competitors.slice(0, 6),
    industry: prospect.industry,
    includeData: {
      organic_analysis: true,
      paid_analysis: true,
      keyword_gaps: true,
      quick_wins: true,
      roi_projection: true
    }
  });
  
  // Save to generated_reports
  await supabase.from('generated_reports').insert({
    prospect_uuid: prospect.report_uuid,
    html_content: report.html,
    competitors_analyzed: report.competitors,
    total_keywords_found: report.metrics.keywords,
    generation_time_ms: report.generationTime,
    semrush_units_used: 650
  });
}

// Total time: ~2 hours for 85 reports
// Uses 55,250 SEMrush units (650 × 85)
```

### Phase 3: Quality Control (2:00 AM - 6:00 AM)

#### 2:00 AM - Message QC

**Workflow #5: Message Quality Control**
```javascript
// Process all 5,000 messages through QC
const messageQCBatch = await supabase
  .from('prospects')
  .select('*')
  .eq('message_qc_status', 'pending')
  .gt('message_generated_at', sundayStart);

// Batch process through Claude
for (const batch of chunks(messageQCBatch, 100)) {
  const qcResults = await Promise.all(
    batch.map(prospect => claudeQC(prospect))
  );
  
  // Update database with results
  await supabase.from('prospects').upsert(
    qcResults.map(result => ({
      id: result.prospect_id,
      message_qc_status: result.status,
      final_message: result.final_message,
      final_subject: result.final_subject,
      ready_to_send: result.status !== 'failed'
    }))
  );
}

// Expected results:
// - 90% approved as-is
// - 8% auto-fixed
// - 2% flagged for manual review
```

#### 4:00 AM - Report QC

**Workflow #6: Report Quality Control**
```javascript
// QC all 85 pre-generated reports
const reportQCBatch = await supabase
  .from('generated_reports')
  .select('*')
  .eq('qc_status', 'pending');

for (const report of reportQCBatch) {
  const qcResult = await claudeReportQC(report);
  
  if (qcResult.status === 'failed') {
    // Alert for manual intervention
    await notifyTeam({
      report_id: report.id,
      issues: qcResult.critical_errors
    });
  } else {
    // Update with QC results
    await supabase.from('generated_reports').update({
      qc_status: qcResult.status,
      final_html_content: qcResult.final_html || report.html_content,
      ready_for_delivery: true
    }).eq('id', report.id);
  }
}
```

### Phase 4: Final Preparation (5:00 AM - 6:00 AM)

#### 5:00 AM - Schedule Week's Sending

**Workflow #7: Distribution Scheduling**
```javascript
// Schedule LinkedIn messages (17/day, Mon-Fri)
const linkedinReady = await getReadyLinkedInProspects();
let dayIndex = 0;

for (const [index, prospect] of linkedinReady.entries()) {
  if (index > 0 && index % 17 === 0) dayIndex++;
  
  await supabase.from('prospects').update({
    scheduled_send_date: addDays(monday, dayIndex)
  }).eq('id', prospect.id);
}

// Schedule email messages (833/day, Mon-Fri)
const emailReady = await getReadyEmailProspects();
dayIndex = 0;

for (const [index, prospect] of emailReady.entries()) {
  if (index > 0 && index % 833 === 0) dayIndex++;
  
  await supabase.from('prospects').update({
    scheduled_send_date: addDays(monday, dayIndex)
  }).eq('id', prospect.id);
}
```

#### 5:30 AM - Final Verification

**Workflow #8: Batch Completion Check**
```javascript
// Log batch summary
const batchSummary = {
  batch_date: currentSunday,
  linkedin_prospects_collected: linkedinCount,
  email_prospects_collected: emailCount,
  messages_generated: 5000,
  messages_qc_passed: passedCount,
  reports_generated: 85,
  reports_qc_passed: reportPassedCount,
  total_ready_to_send: readyCount,
  batch_status: 'completed'
};

await supabase.from('sunday_batch_log').insert(batchSummary);

// Send summary email
await sendBatchSummaryEmail({
  to: 'team@mrcinsights.com',
  subject: 'Sunday Batch Complete - Week of ' + weekStart,
  metrics: batchSummary
});
```

## Monitoring Queries

### Real-Time Progress Check
```sql
-- Run anytime Sunday night to see progress
SELECT * FROM v_sunday_progress;

-- Detailed phase status
SELECT 
  CASE 
    WHEN EXTRACT(HOUR FROM NOW()) BETWEEN 18 AND 22 THEN 'Collection Phase'
    WHEN EXTRACT(HOUR FROM NOW()) BETWEEN 22 AND 2 THEN 'Generation Phase'
    WHEN EXTRACT(HOUR FROM NOW()) BETWEEN 2 AND 6 THEN 'QC Phase'
    ELSE 'Complete'
  END as current_phase,
  (SELECT COUNT(*) FROM prospects WHERE created_at > CURRENT_DATE) as prospects_collected,
  (SELECT COUNT(*) FROM prospects WHERE message_generated_at > CURRENT_DATE) as messages_generated,
  (SELECT COUNT(*) FROM prospects WHERE message_qc_status != 'pending' AND message_generated_at > CURRENT_DATE) as messages_qcd,
  (SELECT COUNT(*) FROM generated_reports WHERE generated_at > CURRENT_DATE) as reports_generated;
```

### Quality Metrics
```sql
-- QC pass rates
SELECT 
  'Messages' as type,
  COUNT(*) as total,
  COUNT(CASE WHEN message_qc_status = 'approved' THEN 1 END) as approved,
  COUNT(CASE WHEN message_qc_status = 'fixed' THEN 1 END) as fixed,
  COUNT(CASE WHEN message_qc_status = 'failed' THEN 1 END) as failed
FROM prospects
WHERE message_generated_at > CURRENT_DATE - INTERVAL '1 day'

UNION ALL

SELECT 
  'Reports' as type,
  COUNT(*) as total,
  COUNT(CASE WHEN qc_status = 'approved' THEN 1 END) as approved,
  COUNT(CASE WHEN qc_status = 'fixed' THEN 1 END) as fixed,
  COUNT(CASE WHEN qc_status = 'failed' THEN 1 END) as failed
FROM generated_reports
WHERE generated_at > CURRENT_DATE - INTERVAL '1 day';
```

## Resource Usage

### API Consumption
- **Phantombuster**: ~2 hours execution time
- **Apollo.io**: 4,500 export credits
- **SEMrush**: 60,250 units total
  - Enrichment: 5,000 units (1 per prospect)
  - Reports: 55,250 units (650 × 85)
- **Claude API**: ~15,000 API calls
  - Messages: 5,000 generations + 5,000 QC
  - Reports: 85 generations + 85 QC

### Time Requirements
- **Total Duration**: 12 hours (6 PM - 6 AM)
- **Active Processing**: ~10 hours
- **Buffer Time**: 2 hours for delays/retries

### Cost Breakdown (Weekly)
- **Phantombuster**: $17.25 (included in $69/mo plan)
- **Apollo.io**: $49 (weekly portion of monthly plan)
- **SEMrush**: $15.06 (60,250 units × $0.00025)
- **Claude API**: ~$15 (15,000 calls)
- **Total Weekly**: ~$96.31

## Troubleshooting Guide

### Common Issues

1. **Phantombuster Timeout**
   - Solution: Reduce batch size to 100
   - Fallback: Use Apollo for more prospects

2. **SEMrush Rate Limit**
   - Solution: Add 100ms delay between calls
   - Monitor: Check usage at 80% threshold

3. **Claude API Errors**
   - Solution: Retry with exponential backoff
   - Fallback: Queue for manual review

4. **Database Locks**
   - Solution: Use smaller batch updates
   - Monitor: Check active connections

### Emergency Procedures

```javascript
// If batch fails at any point
async function resumeBatch(fromPhase) {
  switch(fromPhase) {
    case 'collection':
      // Resume from enrichment
      await startEnrichment();
      break;
    case 'generation':
      // Resume from QC
      await startQC();
      break;
    case 'qc':
      // Just finish QC
      await completeQC();
      break;
  }
}
```

## Success Criteria

### Must Complete By 6 AM
- ✅ 5,000 prospects collected and enriched
- ✅ 5,000 messages generated and QC'd
- ✅ 85 reports generated and QC'd
- ✅ All content scheduled for the week
- ✅ Batch summary logged and sent

### Quality Standards
- Message QC pass rate >95%
- Report QC pass rate >98%
- Zero placeholders in final content
- All links properly formatted
- No duplicate sends scheduled

---

*This is your complete Sunday night playbook. Follow this timeline for consistent weekly execution.*