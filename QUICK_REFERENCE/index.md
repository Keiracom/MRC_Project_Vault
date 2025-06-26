# Quick Reference Guide Index

This directory contains quick reference guides for all critical MRC operations. Each guide is designed for rapid access to key information without searching through lengthy documentation.

## 📋 Available Guides

### [API Limits](api_limits.md)
Complete reference for all API rate limits, quotas, and usage calculations:
- SEMrush, Claude, Email service limits
- Cost per API and optimization strategies
- Rate limiting code examples
- Monthly usage projections

### [Workflow Schedule](workflow_schedule.md)
When everything runs in the MRC system:
- Daily email and LinkedIn operations
- Weekly prospect generation schedule
- Monthly customer report generation
- Real-time triggered workflows
- Follow-up sequence timing

### [Conversion Metrics](conversion_metrics.md)
Target metrics and performance benchmarks:
- Full funnel conversion rates
- Channel performance comparison
- Revenue projections by month
- A/B testing results and priorities
- Warning signs and thresholds

### [Troubleshooting](troubleshooting.md)
Common issues and their solutions:
- Email delivery problems
- Report generation failures
- Database and webhook issues
- Performance optimization
- Emergency procedures

## 🚀 Quick Access Commands

### Check System Status
```bash
# View all running workflows
curl https://n8n.yourdomain.com/api/v1/workflows?active=true

# Database health
psql $DATABASE_URL -c "SELECT COUNT(*) FROM prospects WHERE created_at > NOW() - INTERVAL '1 day'"

# API quotas remaining
curl "https://api.semrush.com/analytics/v1/balance" -H "Authorization: Bearer $SEMRUSH_KEY"
```

### Common Operations
```bash
# Generate report for specific prospect
npm run generate:report -- --domain="example.com"

# Send test email sequence
npm run test:sequence -- --email="test@example.com" --sequence="email_report"

# Check conversion funnel
npm run analytics:funnel -- --days=7
```

## 📊 Key Numbers to Remember

### Daily Limits
- **LinkedIn**: 17 connections/day
- **Email**: 833 emails/day (across 3 domains)
- **Reports**: ~20 on-demand generations

### Target Metrics
- **Email CTR**: 2.5%
- **Report → Trial**: 10%
- **Trial → Paid**: 30%
- **Monthly Churn**: <5%

### Cost Structure
- **Per Report**: $0.97
- **Per Customer**: $4.33/month
- **Gross Margin**: 98.5%

## 🔗 Related Documentation

- **Full Workflows**: [/FOCUS_AREAS/n8n_workflows.md](../FOCUS_AREAS/n8n_workflows.md)
- **Database Schema**: [/DATABASE/report_tracking_schema.sql](../DATABASE/report_tracking_schema.sql)
- **Email Templates**: [/TEMPLATES/follow_up_sequences.md](../TEMPLATES/follow_up_sequences.md)
- **Payment Setup**: [/FOCUS_AREAS/payment_processing.md](../FOCUS_AREAS/payment_processing.md)

## 💡 Pro Tips

1. **Before Debugging**: Always check [troubleshooting.md](troubleshooting.md) first
2. **API Limits**: Stay at 80% of limits to avoid throttling
3. **Conversions**: Focus on Day 0-2 (67% of conversions happen here)
4. **Monitoring**: Set up alerts for any metric outside normal range

## 🚨 Emergency Contacts

- **n8n Issues**: Check workflow logs first
- **Database**: Supabase dashboard → Database → Logs
- **Email**: Instantly.ai → Campaigns → Diagnostics
- **Payments**: Stripe Dashboard → Developers → Logs

---

*Last Updated: [Auto-update with current date]*
*Version: 1.0*