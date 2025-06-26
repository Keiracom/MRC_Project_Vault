# MRC Startup Tier Template - Data Sources & Formulas

## Delivery Method
- **Format:** PDF Email Report Only
- **Frequency:** Monthly
- **Competitors Analyzed:** 8 maximum

## Data Sources Required

### SEMrush API Calls
```
1. GET /analytics/v1/domain_organic?domain={client_domain}
2. GET /analytics/v1/domain_adwords?domain={client_domain}
3. GET /analytics/v1/domain_organic_organic?domain={client_domain}&limit=20
4. GET /analytics/v1/domain_organic?domain={competitor1_domain}
5. GET /analytics/v1/domain_organic?domain={competitor2_domain}
6. GET /analytics/v1/domain_organic?domain={competitor3_domain}
7. GET /analytics/v1/domain_organic?domain={competitor4_domain}
8. GET /analytics/v1/domain_organic?domain={competitor5_domain}
9. GET /analytics/v1/domain_organic?domain={competitor6_domain}
10. GET /analytics/v1/domain_organic?domain={competitor7_domain}
11. GET /analytics/v1/domain_organic?domain={competitor8_domain}
12. GET /analytics/v1/domain_adwords?domain={competitor1_domain}
13. GET /analytics/v1/domain_adwords?domain={competitor2_domain}
14. GET /analytics/v1/domain_adwords?domain={competitor3_domain}
15. GET /analytics/v1/domain_adwords?domain={competitor4_domain}
16. GET /analytics/v1/domain_adwords?domain={competitor5_domain}
17. GET /analytics/v1/domain_adwords?domain={competitor6_domain}
18. GET /analytics/v1/domain_adwords?domain={competitor7_domain}
19. GET /analytics/v1/domain_adwords?domain={competitor8_domain}
20. GET /analytics/v1/backlinks_overview?target={client_domain}
21. GET /analytics/v1/keyword_gap?targets={client_domain,competitor1,competitor2,competitor3,competitor4,competitor5,competitor6,competitor7,competitor8}
```

## Template Cards & Tables

### Card 1: Your Current Position
**Data Sources:**
- SEMrush: Client organic keywords count
- SEMrush: Client paid keywords count
- SEMrush: Estimated monthly organic traffic
- SEMrush: Domain Authority Score

**Formula:**
```
Position Score = (Total Keywords / 100) + (Domain Authority / 10) + (Est Traffic / 1000)
Competitive Rank = Compare position score vs 8 competitors
```

**Card Display:**
```
Current Market Position: #X of 9
Total Keywords: XX
Domain Authority: XX
Est. Monthly Traffic: X,XXX
```

### Card 2: Missed Opportunities
**Data Sources:**
- SEMrush: Competitor keywords NOT in client keywords
- SEMrush: Search volume for missed keywords
- SEMrush: Estimated CPC for missed keywords

**Formula:**
```
Missed Keywords = competitor1_keywords ∪ competitor2_keywords ∪ competitor3_keywords ∪ competitor4_keywords ∪ competitor5_keywords ∪ competitor6_keywords ∪ competitor7_keywords ∪ competitor8_keywords - client_keywords
Total Missed Volume = SUM(search_volume) for missed keywords
Opportunity Score = Total Missed Volume × Average CPC × 0.1 (conservative capture rate)
```

**Card Display:**
```
Missed Keywords: XX
Total Search Volume: X,XXX/month
Est. Opportunity Value: $X,XXX/month
```

### Card 3: Budget Efficiency
**Data Sources:**
- SEMrush: Client estimated ad spend by keyword
- SEMrush: Client ranking positions
- SEMrush: Competitor ranking positions for same keywords

**Formula:**
```
Inefficient Spend = 0
For each client paid keyword:
    if client_position > 5 AND competitor_count_above_client >= 2:
        inefficient_spend += estimated_monthly_spend × 0.6
Efficiency Score = (Total Ad Spend - Inefficient Spend) / Total Ad Spend × 100
```

**Card Display:**
```
Ad Spend Efficiency: XX%
Potentially Wasted: $XXX/month
Suggested Reallocation: $XXX
```

### Card 4: Content Gaps
**Data Sources:**
- SEMrush: Content gap analysis
- SEMrush: Competitor top content by traffic
- SEMrush: Search volume for content gap keywords

**Formula:**
```
Content Gaps = keywords where competitors rank 1-5 AND client has no ranking
High-Value Gaps = content gaps WHERE search_volume > 100 AND keyword_difficulty < 50
Content Opportunity = SUM(search_volume × $2 estimated value) for high-value gaps
```

**Card Display:**
```
Content Gaps Identified: XX
High-Value Opportunities: XX
Est. Traffic Potential: X,XXX/month
```

## Main Tables

### Table 1: Competitive Overview
**Data Sources:**
- SEMrush: Organic keywords count per competitor
- SEMrush: Paid keywords count per competitor
- SEMrush: Estimated monthly organic traffic
- SEMrush: Estimated monthly ad spend

**Columns:**
```
Competitor | Organic Keywords | Paid Keywords | Est. Traffic | Est. Ad Spend | Keyword Overlap
```

**Formulas:**
```
Keyword Overlap = COUNT(competitor_keywords ∩ client_keywords) / COUNT(client_keywords) × 100
```

### Table 2: Your Top Underperforming Keywords
**Data Sources:**
- SEMrush: Client keyword rankings
- SEMrush: Competitor rankings for same keywords
- SEMrush: Search volume
- SEMrush: Estimated CPC

**Columns:**
```
Keyword | Your Position | Best Competitor Position | Search Volume | Est. CPC | Competitors Ahead
```

**Formula:**
```
Underperforming = keywords WHERE client_position > 5 AND best_competitor_position <= 3
Priority Score = search_volume × CPC / (client_position - best_competitor_position)
```

**Limit:** Top 10 by Priority Score

### Table 3: Biggest Keyword Opportunities
**Data Sources:**
- SEMrush: Competitor keywords not targeted by client
- SEMrush: Search volume
- SEMrush: Keyword difficulty/competition
- SEMrush: Estimated CPC

**Columns:**
```
Keyword | Search Volume | Competitors Using | Est. CPC | Opportunity Score | Industry
```

**Formula:**
```
Opportunity Score = (search_volume × CPC × competitor_count) / keyword_difficulty
Filter: search_volume >= 50 AND keyword_difficulty <= 60
```

**Limit:** Top 15 by Opportunity Score

## ROI Calculations (Industry Estimates)

### Formula 1: Keyword Opportunity ROI
**Data Required:**
- SEMrush: Search volume
- SEMrush: Estimated CPC
- Industry conversion rate (hardcoded by industry)
- Industry average order value (hardcoded by industry)

**Formula:**
```
Conservative Market Capture = 0.10 (10%)
Monthly Clicks = search_volume × market_capture
Monthly Conversions = monthly_clicks × industry_conversion_rate
Monthly Revenue = monthly_conversions × industry_avg_order_value
Annual Revenue = monthly_revenue × 12

Implementation Cost = (CPC × monthly_clicks × 6) + content_creation_cost
ROI = (annual_revenue - implementation_cost) / implementation_cost × 100
```

**Industry Benchmarks (Hardcoded):**
```
Dental: conversion_rate = 0.035, avg_order_value = $650
Legal: conversion_rate = 0.028, avg_order_value = $2800
SaaS: conversion_rate = 0.042, avg_order_value = $150
Professional Services: conversion_rate = 0.031, avg_order_value = $1200
```

### Formula 2: Waste Elimination ROI
**Data Required:**
- SEMrush: Current estimated ad spend by keyword
- SEMrush: Client position vs competitors

**Formula:**
```
Wasted Spend = 0
For each paid keyword:
    if client_position >= 6 AND competitor_positions.count(<=3) >= 2:
        wasted_spend += monthly_spend × 0.5

Annual Waste = wasted_spend × 12
Implementation Cost = $500 (optimization time)
ROI = (annual_waste - implementation_cost) / implementation_cost × 100
```

### Formula 3: Content Gap ROI
**Data Required:**
- SEMrush: Content gap keywords
- SEMrush: Search volume for gap keywords
- Industry benchmarks

**Formula:**
```
Content Revenue = 0
For each content gap keyword:
    if search_volume >= 100:
        estimated_traffic = search_volume × 0.15 × 0.3 (rank 3-5, 30% CTR)
        conversions = estimated_traffic × industry_conversion_rate
        monthly_revenue = conversions × industry_avg_order_value
        content_revenue += monthly_revenue

Annual Content Revenue = content_revenue × 12
Content Creation Cost = gap_count × $400
ROI = (annual_revenue - creation_cost) / creation_cost × 100
```

## Report Structure

### Executive Summary
```
- Current competitive position: #X of 9 competitors
- Biggest opportunity: [Highest opportunity score keyword]
- Immediate savings available: $X,XXX annually
- Total revenue opportunity: $XX,XXX annually
- Conservative ROI: XXX%
```

### Recommendations Section
**Priority 1 (High Impact, Low Effort):**
```
- Add negative keywords → Save $XXX/month
- Target [keyword] → $XXX monthly revenue potential
```

**Priority 2 (High Impact, Medium Effort):**
```
- Create content for [keyword gaps] → $XXX annual revenue
- Optimize [underperforming keywords] → $XXX savings
```

**Priority 3 (Medium Impact, High Effort):**
```
- Competitive repositioning for [keywords]
- Long-term content strategy
```

## Quality Thresholds
```
Minimum search volume for inclusion: 50 monthly searches
Minimum opportunity score for recommendations: 100
Maximum keyword difficulty for content recommendations: 60
Minimum confidence level for ROI projections: 70%
```