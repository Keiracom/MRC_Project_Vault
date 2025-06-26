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

#### High Priority for Distribution (UPDATED 2024-12-27)
1. **Weekly LinkedIn Report Pre-Generator (#4-Modified)** - Sunday batch for 85 LinkedIn prospects ONLY
2. **On-Demand Report Generator (#4-New)** - Triggered by email click, generates individual reports
3. **Report Generation Engine (#6)** - Core report creation logic (uses LangChain nodes, not HTTP)
4. **LinkedIn Orchestrator (#8)** - 1 account/85 weekly with pre-generated reports
5. **Email Campaign Manager (#9)** - Generates unique prospect links, no pre-generation
6. **Report Request Handler (#9-Sub)** - Webhook handler for email clicks → triggers #4-New

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

### Volume Reality (Critical for Next Session)
- **LinkedIn**: 1 account × 17/day = 85/WEEK (not 85/day as architecture suggests)
- **Email**: 833/day = 4,165/week
- **Report Generation**: ~415/month (340 LinkedIn pre-gen + 75 email on-demand)

### Report Generation Strategy
- **LinkedIn**: Pre-generate all 85 reports Sunday night for the week
- **Email**: Generate on-demand when link clicked (3-5 min process)
- **Paid customers**: Generate immediately upon payment (not 48 hours)

### Key Architecture Documents
- **Full 20-Workflow Architecture**: `C:\Users\dvids\MRC\MRC N8N Workflow Architecture.md`
- **Business Operations Schema**: `C:\Users\dvids\MRC\MRC Business Operations Schema - Production Ready.md`
- **Distribution Implementation Plan**: `C:\Users\dvids\MRC\MRC_Project_Vault\FOCUS_AREAS\distribution_implementation.md`

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

## Next Session Focus
When working on n8n workflows:
1. Check [[MISTAKES_AND_FIXES/n8n_errors]] for known issues
2. Remember LinkedIn is 85/week not 85/day
3. Payment → Report must be immediate
4. Most workflows already defined in architecture
5. Focus on adjusting volumes, not creating new workflows