# API Limits & Usage - Quick Reference

## SEMrush API

### Limits
- **Requests**: 10 requests/second
- **Units**: 
  - Free tier: 30,000 units/month
  - Business: 3,000,000 units/month ($449.95)

### Unit Costs
- Domain Overview: 1 unit
- Keyword Overview: 1 unit per keyword
- Organic Research: 10 units
- Advertising Research: 10 units
- Backlinks Overview: 10 units
- Competitors Research: 5 units per domain
- URL Analytics: 1 unit

### MRC Usage
- **Prospect Enrichment**: 1 unit × 5,000 = 5,000 units/week
- **Full Report**: 650 units × 813 reports = 528,450 units/month
- **Total Monthly**: ~550,000 units (well within 3M limit)

## Claude API (Anthropic)

### Limits
- **Rate**: 5 requests/minute
- **Context**: 200,000 tokens
- **Daily**: No hard limit

### Pricing
- **Claude 3 Haiku**: $0.25/1M input, $1.25/1M output
- **Claude 3 Sonnet**: $3/1M input, $15/1M output
- **Claude 3 Opus**: $15/1M input, $75/1M output

### MRC Usage
- **Personalization**: 500 tokens × 5,000 prospects = 2.5M tokens/week
- **Report Generation**: 5,000 tokens × 558 reports = 2.8M tokens/month
- **Total Cost**: ~$72/month using Sonnet

## Email Services

### SendGrid (Transactional)
- **Daily**: 10,000 emails (free tier)
- **Rate**: 100 emails/request
- **Attachments**: 30MB max

### Instantly.ai (Cold Outreach)
- **Warm-up**: 2-4 weeks required
- **Daily Max**: 200-300/domain when warmed
- **Rate**: 50-100/hour during business hours
- **Domains**: 3 domains = 600-900 emails/day

### MRC Usage
- **Daily Outreach**: 833 emails across 3 domains
- **Monthly**: 17,910 emails
- **Delivery Rate**: 95%+ with proper warm-up

## Phantombuster

### Limits (Growth Plan - $69/mo)
- **Execution Time**: 5 hours/month
- **Parallel Phantoms**: 2
- **API Calls**: 50,000/month
- **Storage**: 2GB

### LinkedIn Scraping
- **Profile Scraping**: ~100 profiles/hour
- **Connection Export**: ~500 connections/hour
- **Search Results**: 1000 max per search

### MRC Usage
- **Weekly Scrape**: 500-1000 profiles = 5-10 hours
- **Monthly Time**: 20-40 hours needed
- **Solution**: Use multiple accounts or upgrade

## Apollo.io

### Limits (Basic - $49/mo)
- **Export Credits**: 10,000/month
- **Email Credits**: 1,000/month
- **API Calls**: 100/hour

### Data Points
- **Per Contact**: Uses 1 export credit
- **Enrichment**: Uses 1 email credit
- **Bulk Export**: 1000 contacts max

### MRC Usage
- **Weekly Export**: 4,000-5,000 contacts
- **Monthly Need**: 16,000-20,000 credits
- **Solution**: Professional plan ($99/mo) for 50k credits

## Stripe

### API Limits
- **Rate**: 100 requests/second
- **Webhook Timeout**: 20 seconds
- **Retry**: 3 attempts over 24 hours

### Best Practices
- Always use idempotency keys
- Implement webhook signature verification
- Handle all webhook events async

## Supabase

### Free Tier Limits
- **Database**: 500MB
- **Storage**: 1GB
- **Bandwidth**: 2GB
- **API Requests**: Unlimited
- **Concurrent Connections**: 50

### MRC Usage
- **Reports Storage**: 558 × 175KB = 98MB/month
- **Database**: ~100MB for all tables
- **Well within free tier limits**

## Rate Limiting Strategy

### Concurrent Processing
- SEMrush: Max 5 concurrent requests
- Claude: Sequential with 12s delay
- Email: Batch 50, delay 30s between

### Retry Logic
```javascript
// Standard retry with exponential backoff
const retry = async (fn, retries = 3) => {
  try {
    return await fn();
  } catch (error) {
    if (retries > 0 && error.status === 429) {
      await new Promise(r => setTimeout(r, 2 ** (3 - retries) * 1000));
      return retry(fn, retries - 1);
    }
    throw error;
  }
};
```

### Queue Management
- Use Bull queue for job processing
- Set concurrency limits per API
- Implement circuit breakers

## Cost Optimization

### Monthly API Costs
- SEMrush: $449.95 (Business plan)
- Claude: ~$72
- Phantombuster: $69
- Apollo: $99
- SendGrid: $0 (free tier)
- Instantly: $97 (3 domains)
- **Total**: ~$786.95/month

### Cost Per Report
- 813 reports/month
- $786.95 ÷ 813 = $0.97/report
- Charge $297/month = 306x markup