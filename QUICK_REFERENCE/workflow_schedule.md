# MRC Workflow Schedule - Quick Reference

## Daily Workflows

### Morning (9:00 AM - 12:00 PM)
- **Email Outreach** (10:00 AM)
  - Send 833 emails across 3 domains
  - 200 emails/hour/domain rate limit
  - Complete by 11:30 AM

### Afternoon (2:00 PM - 5:00 PM)
- **LinkedIn Connections** (2:00 PM)
  - Send 17 connection requests (daily limit)
  - Personalized messages from Sunday batch
  - Track acceptances

### Evening (6:00 PM - 8:00 PM)
- **Report Generation** (As needed)
  - Generate reports for email clicks
  - Average 15-20 reports/day
  - 3-5 minutes per report

## Weekly Workflows

### Sunday Night (6:00 PM - Monday 2:00 AM)
- **6:00 PM - 10:00 PM**: Prospect Scraping
  - Phantombuster: 500-1000 LinkedIn profiles
  - Apollo.io: 4,000-5,000 email prospects
  
- **10:00 PM - Monday 6:00 AM**: Enrichment
  - SEMrush baseline data (1 unit per prospect)
  - Industry categorization
  - Competitor identification

- **Monday 6:00 AM - 8:00 AM**: LinkedIn Report Pre-generation
  - Generate 85 reports for the week
  - 650 SEMrush units per report
  - Store with 7-day TTL

## Monthly Workflows

### 1st of Month
- **Customer Report Generation** (12:00 AM)
  - Generate reports for all paying customers
  - Email delivery by 6:00 AM
  - Update next_report_date

### 15th of Month
- **Mid-month Analytics Review**
  - Calculate conversion rates
  - Update A/B test results
  - Adjust personalization templates

### Last Day of Month
- **Cleanup & Archive**
  - Archive reports older than 30 days
  - Clean up expired sessions
  - Backup engagement data

## Real-Time Workflows

### Triggered Immediately
- **Email Click Handler**
  - Validate click tracking
  - Generate report if not cached
  - Send report email
  - Start follow-up sequence

- **Stripe Payment Webhook**
  - Create customer record
  - Generate first report
  - Send welcome email
  - Schedule monthly reports

- **LinkedIn Connection Accepted**
  - Send report link
  - Start LinkedIn follow-up sequence
  - Track engagement

## Follow-Up Sequences

### Email Prospects
- Day 0: Report delivered
- Day 2: Implementation tip
- Day 5: Case study
- Day 10: Competitor update
- Day 14: Expiry warning
- Day 21: Final offer

### LinkedIn Connections
- Day 0: Report link sent
- Day 2: Check-in message
- Day 5: Quick insight
- Day 10: Special offer
- Day 14: Final reminder

## API Rate Limits

### SEMrush
- 10 requests/second
- 30,000 units/month (free tier)
- 3,000,000 units/month (paid tier)

### Email Services
- SendGrid: 100 emails/request
- Instantly.ai: 200/hour/domain

### Claude API
- 5 requests/minute
- Context window: 200k tokens

### Stripe
- 100 requests/second
- Webhook timeout: 20 seconds

## Performance Targets

- Email CTR: 2.5%
- LinkedIn acceptance: 30%
- Report to trial: 10%
- Trial to paid: 30%
- Monthly churn: <5%