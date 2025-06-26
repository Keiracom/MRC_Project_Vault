# Troubleshooting Guide - Quick Reference

## Common Issues & Solutions

### Email Delivery Problems

#### Low Delivery Rate (<90%)
**Symptoms**: High bounce rate, emails going to spam
**Solutions**:
1. Check domain reputation at sender.score
2. Verify SPF, DKIM, DMARC records
3. Warm up domains properly (2-4 weeks)
4. Reduce sending volume temporarily
5. Clean email list for invalid addresses

#### Emails Going to Spam
**Solutions**:
```bash
# Check DNS records
dig TXT yourdomain.com | grep -E "spf|dkim|dmarc"

# Test email deliverability
mail-tester.com or glockapps.com
```

### Report Generation Failures

#### SEMrush API Errors
**Error**: "Rate limit exceeded"
**Solution**:
```javascript
// Add delay between requests
await new Promise(resolve => setTimeout(resolve, 100));

// Implement retry logic
if (error.code === 'RATE_LIMIT') {
  await delay(2000);
  return retry(request);
}
```

#### Claude API Timeout
**Error**: "Context length exceeded"
**Solution**:
- Reduce competitor count from 6 to 4
- Summarize data before sending to Claude
- Use Claude Haiku for summaries

#### Report Takes >5 Minutes
**Causes & Solutions**:
1. Too many API calls → Batch requests
2. Sequential processing → Use Promise.all()
3. Large data processing → Stream responses
4. Memory issues → Increase n8n memory limit

### Database Issues

#### Supabase Connection Errors
**Error**: "Too many connections"
**Solution**:
```javascript
// Use connection pooling
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(url, key, {
  db: { pooling: true, max: 10 }
});
```

#### Slow Queries
**Common Culprits**:
1. Missing indexes on prospect_id, domain
2. Full table scans on large tables
3. Complex joins without optimization

**Solution**:
```sql
-- Add indexes
CREATE INDEX idx_prospects_domain ON prospects(company_domain);
CREATE INDEX idx_tracking_prospect ON report_tracking(prospect_id);

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM your_slow_query;
```

### Webhook Failures

#### Stripe Webhook Not Firing
**Checklist**:
1. Verify webhook URL is public
2. Check webhook signing secret
3. Ensure n8n webhook is active
4. Test with Stripe CLI

```bash
# Test locally
stripe listen --forward-to localhost:5678/webhook/stripe
stripe trigger payment_intent.succeeded
```

#### Click Tracking Not Working
**Debug Steps**:
1. Check if tracking pixel loads
2. Verify webhook endpoint responds
3. Check for CORS issues
4. Test with curl:

```bash
curl -X POST https://your-webhook-url/track \
  -H "Content-Type: application/json" \
  -d '{"reportId":"test","action":"open"}'
```

### Follow-up Sequence Issues

#### Sequences Not Sending
**Common Causes**:
1. Cron job not running
2. Sequence marked as completed
3. Prospect unsubscribed
4. Time zone issues

**Debug Query**:
```sql
SELECT * FROM follow_up_sequences 
WHERE next_send_at < NOW() 
  AND completed = false 
  AND stopped_reason IS NULL;
```

#### Duplicate Emails Sent
**Prevention**:
```javascript
// Use idempotency keys
const emailKey = `${prospectId}-${sequenceStep}-${date}`;
if (await redis.get(emailKey)) return; // Already sent
await redis.setex(emailKey, 86400, 'sent'); // 24hr TTL
```

### Performance Issues

#### n8n Workflow Slow
**Optimization Steps**:
1. Increase memory: `NODE_OPTIONS=--max-old-space-size=4096`
2. Use webhook instead of polling triggers
3. Implement pagination for large datasets
4. Use Redis for caching

#### Report Page Load Slow
**Solutions**:
1. Implement CDN for static assets
2. Lazy load images and charts
3. Cache generated reports for 24 hours
4. Compress HTML with gzip

### Authentication Problems

#### "Invalid Token" Errors
**Quick Fixes**:
1. Regenerate JWT secret
2. Check token expiration time
3. Verify timezone settings
4. Clear browser cache

```javascript
// Proper JWT validation
jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ['HS256'],
  maxAge: '7d'
});
```

### Monitoring & Alerts

#### Set Up Health Checks
```javascript
// n8n health check workflow
const checks = {
  database: await checkDatabase(),
  semrush: await checkSEMrushAPI(),
  email: await checkEmailService(),
  stripe: await checkStripeWebhook()
};

if (Object.values(checks).some(v => !v)) {
  await sendAlert('System health check failed', checks);
}
```

#### Key Metrics to Monitor
1. API success rates (>99%)
2. Email delivery rates (>95%)
3. Report generation time (<5 min)
4. Conversion rates (>10%)
5. Error rates (<1%)

### Emergency Procedures

#### High Error Rate
1. Enable maintenance mode
2. Check error logs
3. Rollback recent changes
4. Scale down operations
5. Notify affected users

#### Data Loss Prevention
```bash
# Daily backups
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# Test restore process monthly
pg_restore -d test_db backup_20240115.sql
```

#### Incident Response Template
```markdown
## Incident: [Description]
**Time**: [Start - End]
**Impact**: [# of users affected]
**Root Cause**: [Technical explanation]
**Resolution**: [Steps taken]
**Prevention**: [Future measures]
```

## Quick Debug Commands

```bash
# Check n8n logs
docker logs n8n --tail 100 -f

# Test API endpoints
curl -X GET "https://api.semrush.com/test" \
  -H "Authorization: Bearer $SEMRUSH_KEY"

# Database connection test
psql $DATABASE_URL -c "SELECT 1"

# Email service test
npm run test:email -- --to test@example.com

# Full system health check
npm run health:check
```

## Support Escalation

### Level 1: Common Issues
- Use this guide first
- Check error logs
- Restart services

### Level 2: Complex Issues
- Review recent changes
- Check system resources
- Analyze patterns

### Level 3: Critical Issues
- Page on-call engineer
- Create incident channel
- Begin live debugging