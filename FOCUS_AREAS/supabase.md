# Supabase Database - Data Foundation

## Overview
Supabase serves as the single source of truth for all customer data, competitive intelligence, and business operations.

**Instance**: Supabase Cloud  
**Database**: PostgreSQL with Row Level Security  
**Integration**: n8n workflows, dashboard, Claude API

## Schema Status

### ✅ Production Ready Schema
- **File**: `MRC Business Operations Schema - Production Ready.md`
- **Status**: Complete with all tables, indexes, RLS policies, and functions
- **Tables**: 14 core tables covering entire business operations
- **Security**: RLS enabled with service role access for n8n

### Core Tables Summary

#### Customer Management
- **`customers`**: Core customer records with tier, subscription, status
- **`customer_competitors`**: Competitor assignments per customer
- **`dashboard_users`**: Dashboard access control for Growth/Enterprise

#### Business Operations  
- **`prospects`**: Lead management and qualification pipeline
- **`outreach_campaigns`**: Marketing campaign configuration
- **`outreach_log`**: Detailed outreach activity tracking
- **`conversion_funnel`**: Customer journey tracking
- **`workflow_logs`**: n8n execution logging

#### Partner & Referral System
- **`partners`**: Partner/affiliate management
- **`partner_referrals`**: Referral tracking and commission calculation
- **`commission_payments`**: Automated commission processing

#### Content & Delivery
- **`category_reports`**: Industry-specific report templates
- **`report_requests`**: Free report delivery tracking
- **`email_domains`**: Multi-domain email management
- **`linkedin_accounts`**: LinkedIn automation account management
- **`facebook_campaigns`**: Facebook advertising integration

## Key Configurations

### Row Level Security (RLS)
```sql
-- Service role has full access (for n8n)
CREATE POLICY "Service role full access" ON [table] 
FOR ALL USING (auth.role() = 'service_role');

-- Public access limited to specific use cases
CREATE POLICY "Public view category reports" ON category_reports
FOR SELECT USING (status = 'active');
```

### Critical Functions

#### Lead Scoring Algorithm
```sql
-- Calculates lead score based on:
-- Company size (25 points), Industry (25 points), 
-- Marketing spend (25 points), Engagement (25 points)
SELECT calculate_lead_score(prospect_uuid);
```

#### Automated Outreach Management
```sql
-- Gets next available LinkedIn account
SELECT * FROM get_next_linkedin_account();

-- Records outreach activity
SELECT record_email_sent(domain_id, prospect_id, campaign_id, subject, content);
```

#### Business Operations Logging
```sql
-- Centralized logging for all operations
SELECT log_business_operation('operation_name', 'status', 'message', json_details);
```

## Integration Points

### n8n Workflow Connections
- **Payment Processing**: Creates/updates `customers` table
- **Competitor Analysis**: Populates `customer_competitors` 
- **Outreach**: Manages `prospects` and `outreach_log`
- **Reporting**: Logs to `workflow_logs` for monitoring

### Dashboard Data Flow
```
n8n Workflows → Supabase Tables → Dashboard Display
Customer Data ← Real-time Updates ← User Actions
```

### Claude API Integration
- **Report Generation**: Reads customer and competitor data
- **Lead Scoring**: Uses business logic functions
- **Quality Control**: Logs AI processing results

## Business Logic Implementation

### Customer Tier Management
```sql
-- Tier-based competitor limits
Startup: 3 competitors max
Growth: 10 competitors max  
Enterprise: 25 competitors max (marketed as unlimited)
```

### Automated Commission Calculation
```sql
-- 30% commission on first month only
-- Tracked in partner_referrals with status progression
-- Automated via commission_payments table
```

### Report Request Flow
```sql
-- Free reports tracked via report_requests
-- UUID acts as security token
-- Conversion tracking to paid subscriptions
```

## Data Privacy & Security

### Customer Data Protection
- **PII Encryption**: Email and personal data properly secured
- **Access Control**: RLS policies limit data access by role
- **Audit Trail**: All operations logged with timestamps
- **GDPR Compliance**: Data retention and deletion policies

### API Security
- **Service Keys**: Different keys for different access levels
- **Rate Limiting**: Prevented at application layer
- **Input Validation**: All functions validate inputs

## Performance & Scaling

### Indexing Strategy
- **Primary Indexes**: All foreign keys and frequently queried fields
- **Composite Indexes**: Multi-column queries optimized
- **Text Search**: Full-text search on content fields

### Query Optimization
- **Views**: Pre-computed for dashboard performance
- **Functions**: Batch operations for efficiency
- **Partitioning**: Ready for future large dataset partitioning

### Backup & Recovery
- **Automated Backups**: Supabase handles daily backups
- **Point-in-Time Recovery**: Available for disaster recovery
- **Schema Versioning**: All changes tracked in git

## Current Configuration Status

### Connection Details
- **URL**: [Supabase project URL]
- **API Keys**: Configured in n8n and dashboard
- **Database**: PostgreSQL 14+
- **Extensions**: uuid-ossp enabled

### Active Policies
- **14 tables** with RLS enabled
- **Service role access** for automation
- **Public read access** for category reports and report requests
- **Audit policies** for sensitive operations

## Common Operations

### Customer Creation (from n8n)
```sql
INSERT INTO customers (email, domain, tier, subscription_id, stripe_customer_id, status)
VALUES ($1, $2, $3, $4, $5, 'onboarding');
```

### Competitor Assignment
```sql
INSERT INTO customer_competitors (customer_id, competitor_domain, overlap_score)
SELECT customer_id, unnest(competitor_domains), unnest(overlap_scores);
```

### Dashboard Access Setup
```sql
INSERT INTO dashboard_users (customer_id, email, role, dashboard_access, api_access)
VALUES ($1, $2, 'owner', true, $tier = 'enterprise');
```

## Monitoring & Maintenance

### Daily Checks
- **Query Performance**: Monitor slow queries
- **Storage Usage**: Track database growth
- **Connection Pool**: Monitor n8n connections

### Weekly Reviews
- **Data Integrity**: Validate business logic
- **Security Logs**: Review access patterns
- **Backup Verification**: Ensure backup success

### Monthly Optimization
- **Index Analysis**: Add indexes for new query patterns
- **Function Performance**: Optimize business logic functions
- **Schema Evolution**: Plan schema updates based on business needs

---

## Development Notes

### Schema Evolution Process
1. **Test Changes**: Use staging environment first
2. **Migration Scripts**: Version all schema changes
3. **Backward Compatibility**: Ensure n8n workflows continue working
4. **Documentation**: Update this file with all changes

### Integration Testing
- **n8n Workflows**: Test all database operations
- **Dashboard Queries**: Verify performance with test data  
- **API Endpoints**: Validate response times and accuracy

---

## Next Session Focus
When working with Supabase:
1. Check [[MISTAKES_AND_FIXES/supabase_errors]] for known issues
2. Use service keys for n8n operations
3. Test RLS policies with different roles
4. Document all schema changes