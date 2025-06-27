-- Enhanced MRC Database Schema with UUID Approach and QC
-- Created: 2025-06-27
-- Purpose: Complete schema for prospect tracking, report generation, and quality control

-- =====================================================
-- ENHANCED PROSPECTS TABLE
-- =====================================================
-- Add new columns to existing prospects table
ALTER TABLE prospects ADD COLUMN IF NOT EXISTS (
  -- Universal report link UUID
  report_uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
  
  -- Source identification
  is_linkedin BOOLEAN DEFAULT FALSE,
  
  -- LinkedIn-specific enrichment data (only for LinkedIn prospects)
  linkedin_url TEXT,
  linkedin_headline TEXT,
  linkedin_recent_post TEXT,
  linkedin_recent_post_date TIMESTAMP,
  linkedin_mutual_connections INTEGER,
  linkedin_company_growth TEXT,
  linkedin_employee_count_change INTEGER,
  
  -- SEMrush enrichment data (all prospects)
  domain_authority INTEGER,
  organic_traffic_estimate INTEGER,
  paid_traffic_estimate INTEGER,
  organic_keywords_count INTEGER,
  paid_keywords_count INTEGER,
  ad_spend_estimate DECIMAL(10,2),
  top_competitors JSONB, -- Array of top 6 competitors with basic data
  main_traffic_source TEXT, -- 'organic', 'paid', 'social', 'direct'
  
  -- Message generation fields
  generated_message TEXT,
  generated_subject TEXT,
  message_generated_at TIMESTAMP,
  message_generation_time_ms INTEGER,
  
  -- Quality control fields
  message_qc_status TEXT DEFAULT 'pending', -- 'pending', 'passed', 'fixed', 'failed'
  message_qc_checked_at TIMESTAMP,
  message_qc_issues TEXT[],
  final_message TEXT,
  final_subject TEXT,
  
  -- Scheduling fields
  ready_to_send BOOLEAN DEFAULT FALSE,
  scheduled_send_date DATE,
  actual_sent_at TIMESTAMP,
  sent_via TEXT -- 'instantly', 'phantombuster', 'sendgrid'
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_prospects_report_uuid ON prospects(report_uuid);
CREATE INDEX IF NOT EXISTS idx_prospects_is_linkedin ON prospects(is_linkedin);
CREATE INDEX IF NOT EXISTS idx_prospects_ready_to_send ON prospects(ready_to_send, scheduled_send_date);
CREATE INDEX IF NOT EXISTS idx_prospects_qc_status ON prospects(message_qc_status);

-- =====================================================
-- GENERATED REPORTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS generated_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  prospect_uuid UUID UNIQUE REFERENCES prospects(report_uuid),
  
  -- Report content
  html_content TEXT NOT NULL,
  report_data JSONB, -- Structured data used to generate report
  competitors_analyzed JSONB, -- Array of 6 competitors with full data
  
  -- Generation metadata
  generated_at TIMESTAMP DEFAULT NOW(),
  generation_time_ms INTEGER,
  semrush_units_used INTEGER DEFAULT 650,
  claude_tokens_used INTEGER,
  
  -- Quality control
  qc_status TEXT DEFAULT 'pending', -- 'pending', 'passed', 'fixed', 'failed'
  qc_checked_at TIMESTAMP,
  qc_issues TEXT[],
  qc_fixed_by TEXT,
  final_html_content TEXT, -- QC-approved version
  ready_for_delivery BOOLEAN DEFAULT FALSE,
  
  -- Access tracking
  access_count INTEGER DEFAULT 0,
  first_accessed_at TIMESTAMP,
  last_accessed_at TIMESTAMP,
  
  -- Lifecycle
  expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '30 days',
  delivery_channel TEXT, -- 'linkedin', 'email', 'direct'
  
  -- Performance metrics
  total_keywords_found INTEGER,
  total_opportunity_value DECIMAL(10,2),
  quick_wins_count INTEGER
);

CREATE INDEX IF NOT EXISTS idx_generated_reports_prospect ON generated_reports(prospect_uuid);
CREATE INDEX IF NOT EXISTS idx_generated_reports_qc_status ON generated_reports(qc_status);
CREATE INDEX IF NOT EXISTS idx_generated_reports_expires ON generated_reports(expires_at);

-- =====================================================
-- EMAIL TRACKING TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS email_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  prospect_uuid UUID REFERENCES prospects(report_uuid),
  campaign_id UUID REFERENCES outreach_campaigns(id),
  
  -- Email metadata
  email_subject TEXT,
  email_template_used TEXT,
  from_email TEXT,
  from_name TEXT,
  
  -- Delivery tracking
  sent_at TIMESTAMP DEFAULT NOW(),
  delivered_at TIMESTAMP,
  bounced_at TIMESTAMP,
  bounce_type TEXT,
  
  -- Engagement tracking
  opened_at TIMESTAMP,
  open_count INTEGER DEFAULT 0,
  clicked_at TIMESTAMP,
  click_count INTEGER DEFAULT 0,
  
  -- Report generation tracking
  report_requested_at TIMESTAMP,
  report_generated_at TIMESTAMP,
  report_delivered_at TIMESTAMP,
  report_generation_error TEXT,
  
  -- Conversion tracking
  converted_at TIMESTAMP,
  conversion_value DECIMAL(10,2),
  subscription_id TEXT,
  
  -- Device/location data
  ip_address INET,
  user_agent TEXT,
  device_type TEXT,
  country TEXT,
  city TEXT
);

CREATE INDEX IF NOT EXISTS idx_email_tracking_prospect ON email_tracking(prospect_uuid);
CREATE INDEX IF NOT EXISTS idx_email_tracking_sent ON email_tracking(sent_at);
CREATE INDEX IF NOT EXISTS idx_email_tracking_engagement ON email_tracking(clicked_at, converted_at);

-- =====================================================
-- REPORT QC LOG TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS report_qc_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  report_id UUID REFERENCES generated_reports(id),
  prospect_uuid UUID REFERENCES prospects(report_uuid),
  
  -- QC results
  qc_type TEXT NOT NULL, -- 'message', 'report', 'real_time'
  qc_result TEXT NOT NULL, -- 'approved', 'fixed', 'blocked'
  issues_found TEXT[],
  fixes_applied JSONB,
  
  -- Performance
  qc_duration_ms INTEGER,
  claude_tokens_used INTEGER,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  qc_prompt_version TEXT DEFAULT 'v1'
);

CREATE INDEX IF NOT EXISTS idx_qc_log_report ON report_qc_log(report_id);
CREATE INDEX IF NOT EXISTS idx_qc_log_created ON report_qc_log(created_at);
CREATE INDEX IF NOT EXISTS idx_qc_log_result ON report_qc_log(qc_result);

-- =====================================================
-- SUNDAY BATCH LOG TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS sunday_batch_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  batch_date DATE NOT NULL UNIQUE,
  
  -- Collection phase
  linkedin_prospects_collected INTEGER DEFAULT 0,
  email_prospects_collected INTEGER DEFAULT 0,
  collection_completed_at TIMESTAMP,
  
  -- Enrichment phase
  prospects_enriched INTEGER DEFAULT 0,
  enrichment_errors INTEGER DEFAULT 0,
  enrichment_completed_at TIMESTAMP,
  semrush_units_used INTEGER DEFAULT 0,
  
  -- Generation phase
  messages_generated INTEGER DEFAULT 0,
  reports_generated INTEGER DEFAULT 0,
  generation_completed_at TIMESTAMP,
  
  -- QC phase
  messages_qc_passed INTEGER DEFAULT 0,
  messages_qc_fixed INTEGER DEFAULT 0,
  messages_qc_failed INTEGER DEFAULT 0,
  reports_qc_passed INTEGER DEFAULT 0,
  reports_qc_fixed INTEGER DEFAULT 0,
  reports_qc_failed INTEGER DEFAULT 0,
  qc_completed_at TIMESTAMP,
  
  -- Final status
  total_ready_to_send INTEGER DEFAULT 0,
  batch_status TEXT DEFAULT 'running', -- 'running', 'completed', 'failed'
  error_details JSONB,
  
  -- Timing
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  total_duration_minutes INTEGER
);

-- =====================================================
-- USEFUL VIEWS
-- =====================================================

-- Sunday night progress monitor
CREATE OR REPLACE VIEW v_sunday_progress AS
SELECT 
  'Current Batch Status' as metric,
  (SELECT COUNT(*) FROM prospects WHERE message_generated_at > CURRENT_DATE - INTERVAL '1 day') as messages_generated,
  (SELECT COUNT(*) FROM prospects WHERE message_qc_status IN ('passed', 'fixed') AND message_generated_at > CURRENT_DATE - INTERVAL '1 day') as messages_ready,
  (SELECT COUNT(*) FROM generated_reports WHERE generated_at > CURRENT_DATE - INTERVAL '1 day') as reports_generated,
  (SELECT COUNT(*) FROM generated_reports WHERE qc_status IN ('passed', 'fixed') AND generated_at > CURRENT_DATE - INTERVAL '1 day') as reports_ready;

-- Email click funnel
CREATE OR REPLACE VIEW v_email_funnel AS
SELECT 
  DATE(sent_at) as date,
  COUNT(*) as emails_sent,
  COUNT(CASE WHEN opened_at IS NOT NULL THEN 1 END) as opened,
  COUNT(CASE WHEN clicked_at IS NOT NULL THEN 1 END) as clicked,
  COUNT(CASE WHEN report_generated_at IS NOT NULL THEN 1 END) as reports_generated,
  COUNT(CASE WHEN converted_at IS NOT NULL THEN 1 END) as converted,
  ROUND(COUNT(CASE WHEN opened_at IS NOT NULL THEN 1 END)::DECIMAL / NULLIF(COUNT(*), 0) * 100, 2) as open_rate,
  ROUND(COUNT(CASE WHEN clicked_at IS NOT NULL THEN 1 END)::DECIMAL / NULLIF(COUNT(*), 0) * 100, 2) as ctr,
  ROUND(COUNT(CASE WHEN converted_at IS NOT NULL THEN 1 END)::DECIMAL / NULLIF(COUNT(CASE WHEN clicked_at IS NOT NULL THEN 1 END), 0) * 100, 2) as conversion_rate
FROM email_tracking
WHERE sent_at > CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(sent_at)
ORDER BY date DESC;

-- QC performance metrics
CREATE OR REPLACE VIEW v_qc_performance AS
SELECT 
  qc_type,
  qc_result,
  COUNT(*) as count,
  AVG(qc_duration_ms) as avg_duration_ms,
  ARRAY_AGG(DISTINCT unnest(issues_found)) as common_issues
FROM report_qc_log
WHERE created_at > CURRENT_DATE - INTERVAL '7 days'
GROUP BY qc_type, qc_result;

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to get next batch of prospects to send
CREATE OR REPLACE FUNCTION get_daily_send_batch(
  p_channel TEXT, -- 'email' or 'linkedin'
  p_limit INTEGER
) RETURNS TABLE (
  prospect_id UUID,
  report_uuid UUID,
  email TEXT,
  final_message TEXT,
  final_subject TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id as prospect_id,
    p.report_uuid,
    p.email,
    p.final_message,
    p.final_subject
  FROM prospects p
  WHERE p.ready_to_send = TRUE
    AND p.scheduled_send_date = CURRENT_DATE
    AND p.actual_sent_at IS NULL
    AND CASE 
      WHEN p_channel = 'linkedin' THEN p.is_linkedin = TRUE
      WHEN p_channel = 'email' THEN p.is_linkedin = FALSE
      ELSE FALSE
    END
  ORDER BY p.lead_score DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function to check if report needs generation
CREATE OR REPLACE FUNCTION needs_report_generation(p_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM generated_reports 
    WHERE prospect_uuid = p_uuid 
    AND ready_for_delivery = TRUE
    AND expires_at > NOW()
  ) INTO v_exists;
  
  RETURN NOT v_exists;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PERMISSIONS
-- =====================================================
-- Grant appropriate permissions for n8n service role
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO service_role;