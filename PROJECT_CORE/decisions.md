# Architecture Decisions - System Design Choices

## Core Technology Stack

### Decision: n8n Cloud vs Self-Hosted
**Date**: 2024-12-15  
**Decision**: Use n8n Cloud ($50/month) instead of self-hosting  
**Reasoning**: 
- Reduces maintenance overhead and technical complexity
- Provides professional support and automatic updates
- Cost justified for business use case ($50 vs weeks of setup/maintenance)
- Better reliability and uptime than self-managed instance
**Alternatives Considered**: Self-hosted n8n, Zapier, Make.com
**Impact**: Faster deployment, reduced technical risk, ongoing maintenance cost
**Links**: [[n8n-workflows]] [[business-operations]]

### Decision: Supabase Database Platform  
**Date**: 2024-12-10  
**Decision**: Use Supabase as primary database and backend service
**Reasoning**:
- PostgreSQL with modern developer experience
- Built-in authentication, real-time features, and API generation
- Row Level Security for data protection
- Better pricing and features than Firebase for B2B use case
**Alternatives Considered**: Firebase, PlanetScale, direct PostgreSQL
**Impact**: Comprehensive backend solution, faster development, built-in security
**Links**: [[supabase-schema]] [[database-operations]]

### Decision: Claude API for AI Processing
**Date**: 2024-12-12  
**Decision**: Use Claude API with hybrid model approach (Sonnet + Opus)
**Reasoning**:
- Sonnet 4: Cost-effective for business logic and routing ($3/$15 per million tokens)
- Opus 4: Premium quality for customer-facing content ($15/$75 per million tokens)  
- 80/20 split reduces costs while maintaining quality
- Better instruction following than GPT-4 for business reports
**Alternatives Considered**: OpenAI GPT-4, Google Gemini, local LLMs
**Impact**: Balanced cost vs quality, reliable report generation
**Links**: [[claude-integration]] [[report-generation]]

## Service Architecture

### Decision: Three-Tier Subscription Model
**Date**: 2024-12-14  
**Decision**: Startup ($297) / Growth ($697) / Enterprise ($1,297) monthly tiers
**Reasoning**:
- Aligns with customer business stage and growth journey
- Creates natural upgrade path as businesses scale
- Growth tier as "Goldilocks" option drives 60% selection rate
- Tier names communicate target customer clearly
**Alternatives Considered**: Usage-based pricing, one-time payments, custom pricing
**Impact**: Predictable revenue, clear value progression, simplified sales process
**Links**: [[business-operations]] [[customer-tiers]]

### Decision: Competitor Limits by Tier
**Date**: 2024-12-14  
**Decision**: Hard limits - Startup (3), Growth (10), Enterprise (25+)
**Reasoning**:
- Creates natural upgrade triggers when customers hit limits
- Prevents billing disputes with clear expectations
- 25+ marketed as "unlimited" while maintaining practical limits
- Aligns with typical business competitive landscape needs
**Alternatives Considered**: Unlimited all tiers, usage-based pricing, soft limits
**Impact**: Clear upgrade incentives, predictable resource usage, simplified sales
**Links**: [[customer-lifecycle]] [[pricing-strategy]]

### Decision: Delivery Method Differentiation
**Date**: 2024-12-14  
**Decision**: Email (Startup) → Dashboard (Growth) → Platform Integration (Enterprise)
**Reasoning**:
- Clear value progression more compelling than feature lists
- Dashboard access justifies 2.3x price increase (Growth vs Startup)
- Platform integration (OAuth) creates enterprise moat
- Each tier serves different customer sophistication levels
**Alternatives Considered**: Feature-based differentiation, support-level differentiation
**Impact**: Clear upgrade justification, simple positioning, natural customer progression
**Links**: [[dashboard-development]] [[service-delivery]]

## Technical Implementation

### Decision: HTTP Request vs Basic LLM Chain for Claude
**Date**: 2024-12-16  
**Decision**: Always use HTTP Request nodes for Claude API integration
**Reasoning**:
- Basic LLM Chain nodes consistently hang and block execution
- HTTP Request provides better error handling and timeout control
- More reliable for production workflows
- Easier debugging and monitoring
**Alternatives Considered**: Basic LLM Chain, AI Agent nodes, custom integrations
**Impact**: Reliable workflow execution, better error handling, easier maintenance
**Links**: [[n8n-errors]] [[claude-api-integration]]

### Decision: Complete JSON Workflow Configuration
**Date**: 2024-12-16  
**Decision**: All n8n workflows must be complete JSON with no manual UI work
**Reasoning**:
- Matches developer workflow preference (copy/paste vs UI clicking)
- Enables version control of workflow configurations
- Faster deployment and consistent results
- Easier to document and share workflow patterns
**Alternatives Considered**: UI-based configuration, hybrid approach, workflow templates
**Impact**: Faster development, version-controlled workflows, consistent deployment
**Links**: [[n8n-development-standards]] [[workflow-automation]]

### Decision: Bubble vs Retool for Dashboard
**Date**: 2024-12-17  
**Decision**: Use Bubble for customer-facing dashboard development
**Reasoning**:
- Better for customer-facing applications (design flexibility, branding)
- Superior mobile responsiveness (50%+ users on mobile)
- Better pricing model for customer access ($32/month vs $10/user)
- Native user authentication and management
- 85% of mockup features implementable without workarounds
**Alternatives Considered**: Retool, custom React app, low-code alternatives
**Impact**: Beautiful customer dashboard, mobile-optimized, cost-effective scaling
**Links**: [[dashboard-development]] [[customer-experience]]

## Business Strategy

### Decision: Target Business Owners, Not Marketing Professionals
**Date**: 2024-12-18  
**Decision**: Focus messaging and service delivery on business outcomes vs marketing metrics
**Reasoning**:
- Business owners care about customers/revenue, not keywords/rankings
- Competitive advantage vs agencies who speak marketing jargon
- Larger addressable market (all business owners vs marketing professionals)
- Better pricing power with business outcome focus
**Alternatives Considered**: Marketing professional focus, dual-audience approach
**Impact**: Differentiated positioning, clearer value proposition, larger market
**Links**: [[business-operations]] [[customer-communication]]

### Decision: Position Against Agencies, Not Tools
**Date**: 2024-12-18  
**Decision**: Compete with marketing agencies/consultants ($5-10K/month) not tools
**Reasoning**:
- Tools serve different buyer (marketing professional vs business owner)
- 88% cost advantage vs agency retainers more compelling than tool comparisons
- Agencies have incentive to increase spend, MRC helps reduce waste
- Better profit margins competing on value vs features
**Alternatives Considered**: Tool comparison, consultant positioning, hybrid approach
**Impact**: Clearer competitive positioning, better profit margins, differentiated value
**Links**: [[competitive-positioning]] [[pricing-strategy]]

### Decision: Prescription Model Service Delivery
**Date**: 2024-12-18  
**Decision**: Diagnose problems → Prescribe solutions → Show ROI (like doctor visits)
**Reasoning**:
- Business owners familiar with this model from healthcare/professional services
- Creates clear value demonstration and action orientation
- Justifies premium pricing vs raw data delivery
- Positions as trusted advisor vs vendor
**Alternatives Considered**: Data delivery, consulting model, self-service tools
**Impact**: Premium positioning, clear value delivery, customer success orientation
**Links**: [[service-delivery]] [[customer-success]]

### Decision: Obsidian + GitHub + MCP Project Management System
**Date**: 2024-12-19  
**Decision**: Implement Obsidian vault with GitHub sync and Claude Desktop MCP integration for project memory
**Reasoning**:
- Solves information overload problem with large single Memory.md files
- Modular documentation prevents Claude from glossing over important details
- GitHub MCP + Git MCP + Filesystem MCP create automated documentation workflow
- Bidirectional linking in Obsidian shows project relationships visually
- "Route and save" commands automatically save information to correct files
- Version control tracks all decisions and changes over time
- Perfect session handoffs with focused context per work area
**Alternatives Considered**: Single Memory.md file, Notion database, Linear issues, Airtable base, pure GitHub
**Impact**: No information loss, no repeated mistakes, perfect Claude session continuity, scalable complexity management
**Links**: [[obsidian-integration]] [[github-mcp]] [[project-memory]]

## Infrastructure & Operations

### Decision: Multi-Domain Email Strategy
**Date**: 2024-12-19  
**Decision**: Primary domain (keiracom.com) for business, alternate domains for outreach
**Reasoning**:
- Protects primary domain reputation from spam complaints
- One spam report can destroy ALL email deliverability including transactional
- Alternate domains for cold outreach, primary for customer communication
- Industry best practice for email marketing at scale
**Alternatives Considered**: Single domain, subdomain strategy, third-party sending
**Impact**: Protected email deliverability, scalable outreach, professional image
**Links**: [[email-infrastructure]] [[outreach-strategy]]

### Decision: SEMrush as Primary Data Source
**Date**: 2024-12-19  
**Decision**: Start with SEMrush Business ($500/month), add other tools based on ROI
**Reasoning**:
- SEMrush covers 80% of competitive intelligence needs for Startup/Growth tiers
- Profitable from first customer ($297 > $500 with other costs)
- Add Ahrefs, SimilarWeb only when Enterprise tier justifies cost
- Prevents over-engineering before revenue validation
**Alternatives Considered**: All tools from start, usage-based API costs, free alternatives
**Impact**: Lower initial costs, faster profitability, scalable data infrastructure
**Links**: [[data-sources]] [[cost-management]]

---

## Decision Review Process

### Quarterly Architecture Review
- **Q1 2025**: Review technology stack performance and costs
- **Q2 2025**: Evaluate service tier effectiveness and customer feedback
- **Q3 2025**: Assess scaling challenges and infrastructure needs
- **Q4 2025**: Plan next year technology and business strategy

### Decision Change Criteria
1. **Cost exceeds 20% of MRR**: Re-evaluate expensive decisions
2. **Customer feedback indicates problems**: Review service delivery decisions
3. **Technical limitations block growth**: Re-assess technology choices
4. **New alternatives significantly better**: Consider migration paths

### Documentation Requirements
- **All major decisions** documented in this file
- **Reasoning preserved** for future reference
- **Impact tracking** on business metrics
- **Regular reviews** scheduled and completed

---

### Decision: LangChain Nodes for Report Generation Engine
**Date**: 2025-06-26  
**Decision**: Use n8n LangChain nodes (not HTTP Request) for Report Generation Engine workflow
**Reasoning**:
- Native integration with Claude API through nodes-langchain.lmChatAnthropic
- Better error handling and retry logic built into LangChain nodes
- Easier to implement complex report generation logic with AI Agent nodes
- Previous HTTP Request advice was for simple Claude calls, not complex workflows
**Alternatives Considered**: HTTP Request nodes, custom Code nodes, external services
**Impact**: More reliable report generation, easier maintenance, better integration
**Links**: [[report-generation-engine]] [[n8n-workflows]] [[claude-integration]]

### Decision: Volume-Based Report Generation Strategy
**Date**: 2025-06-26  
**Decision**: Pre-generate LinkedIn reports weekly, generate email reports on-demand
**Reasoning**:
- LinkedIn: Only 365 reports/month, can batch process Sunday nights
- Email: 448 potential reports/month but only 2.5% click rate justifies on-demand
- Reduces wasted compute and API calls by 95% for email campaign
- 3-5 minute generation time acceptable for on-demand email reports
**Alternatives Considered**: Pre-generate all reports, all on-demand, hybrid by tier
**Impact**: 95% reduction in unnecessary report generation, cost optimization
**Links**: [[distribution-strategy]] [[workflow-optimization]] [[cost-management]]

**Note**: These decisions represent the foundation of the MRC platform. Changes should be carefully considered and documented to maintain system coherence and business strategy alignment.