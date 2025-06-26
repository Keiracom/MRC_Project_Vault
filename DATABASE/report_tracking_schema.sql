-- Report Tracking and Follow-up Sequences Schema
-- Created: 2025-06-26
-- Purpose: Track report engagement, automate follow-ups, and measure conversions

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS conversion_tracking CASCADE;
DROP TABLE IF EXISTS follow_up_sequences CASCADE;
DROP TABLE IF EXISTS report_tracking CASCADE;

-- Create report_tracking table
-- This table tracks all engagement metrics for distributed reports
CREATE TABLE report_tracking (
    tracking_id SERIAL PRIMARY KEY,
    report_id INTEGER NOT NULL,
    recipient_email VARCHAR(255) NOT NULL,
    recipient_name VARCHAR(255),
    company_name VARCHAR(255),
    industry VARCHAR(100),
    
    -- Delivery metrics
    sent_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivered_timestamp TIMESTAMP WITH TIME ZONE,
    bounced BOOLEAN DEFAULT FALSE,
    bounce_type VARCHAR(50), -- 'hard', 'soft', 'blocked'
    bounce_reason TEXT,
    
    -- Engagement metrics
    first_opened_timestamp TIMESTAMP WITH TIME ZONE,
    last_opened_timestamp TIMESTAMP WITH TIME ZONE,
    open_count INTEGER DEFAULT 0,
    unique_open_count INTEGER DEFAULT 0,
    
    -- Click tracking
    first_clicked_timestamp TIMESTAMP WITH TIME ZONE,
    last_clicked_timestamp TIMESTAMP WITH TIME ZONE,
    click_count INTEGER DEFAULT 0,
    unique_click_count INTEGER DEFAULT 0,
    clicked_links JSONB DEFAULT '[]'::JSONB, -- Array of {link_url, click_count, first_clicked, last_clicked}
    
    -- Download tracking
    downloaded_timestamp TIMESTAMP WITH TIME ZONE,
    download_count INTEGER DEFAULT 0,
    download_format VARCHAR(20), -- 'pdf', 'excel', 'powerpoint'
    
    -- Engagement scoring
    engagement_score DECIMAL(5,2) DEFAULT 0.00, -- 0-100 score
    engagement_level VARCHAR(20), -- 'cold', 'warm', 'hot', 'engaged'
    time_spent_seconds INTEGER DEFAULT 0,
    pages_viewed INTEGER DEFAULT 0,
    scroll_depth_percentage DECIMAL(5,2) DEFAULT 0.00,
    
    -- Device and location tracking
    device_type VARCHAR(50), -- 'desktop', 'mobile', 'tablet'
    browser VARCHAR(50),
    operating_system VARCHAR(50),
    ip_address INET,
    country VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    
    -- UTM parameters
    utm_source VARCHAR(255),
    utm_medium VARCHAR(255),
    utm_campaign VARCHAR(255),
    utm_term VARCHAR(255),
    utm_content VARCHAR(255),
    
    -- Follow-up status
    follow_up_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'opted_out'
    last_follow_up_sent TIMESTAMP WITH TIME ZONE,
    follow_up_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_engagement_score CHECK (engagement_score >= 0 AND engagement_score <= 100),
    CONSTRAINT chk_scroll_depth CHECK (scroll_depth_percentage >= 0 AND scroll_depth_percentage <= 100),
    CONSTRAINT chk_counts_non_negative CHECK (
        open_count >= 0 AND 
        click_count >= 0 AND 
        download_count >= 0 AND 
        time_spent_seconds >= 0 AND 
        pages_viewed >= 0 AND
        follow_up_count >= 0
    )
);

-- Create follow_up_sequences table
-- This table defines automated follow-up sequences and tracks their execution
CREATE TABLE follow_up_sequences (
    sequence_id SERIAL PRIMARY KEY,
    tracking_id INTEGER NOT NULL REFERENCES report_tracking(tracking_id) ON DELETE CASCADE,
    sequence_name VARCHAR(255) NOT NULL,
    sequence_type VARCHAR(50) NOT NULL, -- 'engagement_based', 'time_based', 'action_based'
    
    -- Sequence configuration
    sequence_config JSONB NOT NULL, -- Stores the full sequence definition
    total_steps INTEGER NOT NULL,
    current_step INTEGER DEFAULT 0,
    
    -- Timing
    start_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    next_action_timestamp TIMESTAMP WITH TIME ZONE,
    completed_timestamp TIMESTAMP WITH TIME ZONE,
    
    -- Status tracking
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- 'active', 'paused', 'completed', 'cancelled', 'failed'
    pause_reason TEXT,
    cancellation_reason TEXT,
    
    -- Email tracking
    emails_sent INTEGER DEFAULT 0,
    emails_opened INTEGER DEFAULT 0,
    emails_clicked INTEGER DEFAULT 0,
    last_email_sent_timestamp TIMESTAMP WITH TIME ZONE,
    
    -- Response tracking
    response_received BOOLEAN DEFAULT FALSE,
    response_timestamp TIMESTAMP WITH TIME ZONE,
    response_type VARCHAR(50), -- 'reply', 'meeting_booked', 'download', 'unsubscribe'
    response_details JSONB,
    
    -- Performance metrics
    sequence_engagement_score DECIMAL(5,2) DEFAULT 0.00,
    sequence_conversion_rate DECIMAL(5,2) DEFAULT 0.00,
    
    -- A/B testing
    variant_id VARCHAR(50),
    variant_name VARCHAR(255),
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    
    -- Constraints
    CONSTRAINT chk_current_step CHECK (current_step >= 0 AND current_step <= total_steps),
    CONSTRAINT chk_sequence_scores CHECK (
        sequence_engagement_score >= 0 AND sequence_engagement_score <= 100 AND
        sequence_conversion_rate >= 0 AND sequence_conversion_rate <= 100
    )
);

-- Create conversion_tracking table
-- This table tracks conversions and attribution from report engagement
CREATE TABLE conversion_tracking (
    conversion_id SERIAL PRIMARY KEY,
    tracking_id INTEGER NOT NULL REFERENCES report_tracking(tracking_id) ON DELETE CASCADE,
    sequence_id INTEGER REFERENCES follow_up_sequences(sequence_id) ON DELETE SET NULL,
    
    -- Conversion details
    conversion_type VARCHAR(100) NOT NULL, -- 'meeting_scheduled', 'demo_requested', 'quote_requested', 'purchase', 'subscription', 'custom'
    conversion_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    conversion_value DECIMAL(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    
    -- Attribution
    attribution_model VARCHAR(50) DEFAULT 'last_touch', -- 'first_touch', 'last_touch', 'linear', 'time_decay', 'position_based'
    touchpoint_sequence JSONB, -- Array of all touchpoints leading to conversion
    days_to_conversion INTEGER,
    interactions_before_conversion INTEGER,
    
    -- Source attribution
    primary_source VARCHAR(255),
    primary_medium VARCHAR(255),
    primary_campaign VARCHAR(255),
    referring_url TEXT,
    landing_page_url TEXT,
    
    -- Lead scoring
    lead_score_at_conversion DECIMAL(5,2),
    lead_temperature VARCHAR(20), -- 'cold', 'warm', 'hot'
    
    -- Sales cycle
    opportunity_id VARCHAR(255),
    deal_stage VARCHAR(100),
    probability_percentage DECIMAL(5,2),
    expected_close_date DATE,
    actual_close_date DATE,
    
    -- Customer details
    customer_id VARCHAR(255),
    customer_lifetime_value DECIMAL(15,2),
    is_new_customer BOOLEAN DEFAULT TRUE,
    previous_purchases INTEGER DEFAULT 0,
    
    -- ROI metrics
    campaign_cost DECIMAL(15,2),
    roi_percentage DECIMAL(10,2),
    payback_period_days INTEGER,
    
    -- Notes and metadata
    notes TEXT,
    tags JSONB DEFAULT '[]'::JSONB,
    custom_fields JSONB DEFAULT '{}'::JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by VARCHAR(255),
    
    -- Constraints
    CONSTRAINT chk_conversion_value CHECK (conversion_value >= 0),
    CONSTRAINT chk_probability CHECK (probability_percentage >= 0 AND probability_percentage <= 100),
    CONSTRAINT chk_lead_score CHECK (lead_score_at_conversion >= 0 AND lead_score_at_conversion <= 100)
);

-- Create indexes for report_tracking table
CREATE INDEX idx_report_tracking_report_id ON report_tracking(report_id);
CREATE INDEX idx_report_tracking_recipient_email ON report_tracking(recipient_email);
CREATE INDEX idx_report_tracking_company_name ON report_tracking(company_name);
CREATE INDEX idx_report_tracking_sent_timestamp ON report_tracking(sent_timestamp);
CREATE INDEX idx_report_tracking_engagement_score ON report_tracking(engagement_score DESC);
CREATE INDEX idx_report_tracking_engagement_level ON report_tracking(engagement_level);
CREATE INDEX idx_report_tracking_follow_up_status ON report_tracking(follow_up_status);
CREATE INDEX idx_report_tracking_utm_campaign ON report_tracking(utm_campaign);
CREATE INDEX idx_report_tracking_device_type ON report_tracking(device_type);
CREATE INDEX idx_report_tracking_country ON report_tracking(country);

-- Composite indexes for common queries
CREATE INDEX idx_report_tracking_engagement ON report_tracking(report_id, engagement_score DESC, open_count, click_count);
CREATE INDEX idx_report_tracking_timeline ON report_tracking(sent_timestamp, first_opened_timestamp, first_clicked_timestamp);

-- Create indexes for follow_up_sequences table
CREATE INDEX idx_follow_up_sequences_tracking_id ON follow_up_sequences(tracking_id);
CREATE INDEX idx_follow_up_sequences_status ON follow_up_sequences(status);
CREATE INDEX idx_follow_up_sequences_next_action ON follow_up_sequences(next_action_timestamp) WHERE status = 'active';
CREATE INDEX idx_follow_up_sequences_sequence_type ON follow_up_sequences(sequence_type);
CREATE INDEX idx_follow_up_sequences_variant ON follow_up_sequences(variant_id);

-- Create indexes for conversion_tracking table
CREATE INDEX idx_conversion_tracking_tracking_id ON conversion_tracking(tracking_id);
CREATE INDEX idx_conversion_tracking_sequence_id ON conversion_tracking(sequence_id);
CREATE INDEX idx_conversion_tracking_type ON conversion_tracking(conversion_type);
CREATE INDEX idx_conversion_tracking_timestamp ON conversion_tracking(conversion_timestamp);
CREATE INDEX idx_conversion_tracking_value ON conversion_tracking(conversion_value DESC);
CREATE INDEX idx_conversion_tracking_customer ON conversion_tracking(customer_id);
CREATE INDEX idx_conversion_tracking_opportunity ON conversion_tracking(opportunity_id);

-- Composite indexes for conversion analysis
CREATE INDEX idx_conversion_tracking_attribution ON conversion_tracking(primary_source, primary_medium, primary_campaign);
CREATE INDEX idx_conversion_tracking_performance ON conversion_tracking(conversion_type, conversion_value DESC, roi_percentage DESC);

-- Create update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update timestamp triggers
CREATE TRIGGER update_report_tracking_updated_at BEFORE UPDATE ON report_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_follow_up_sequences_updated_at BEFORE UPDATE ON follow_up_sequences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversion_tracking_updated_at BEFORE UPDATE ON conversion_tracking
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to calculate engagement score
CREATE OR REPLACE FUNCTION calculate_engagement_score(
    p_open_count INTEGER,
    p_click_count INTEGER,
    p_download_count INTEGER,
    p_time_spent_seconds INTEGER,
    p_pages_viewed INTEGER,
    p_scroll_depth DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    v_score DECIMAL := 0;
BEGIN
    -- Base score from opens (max 20 points)
    v_score := v_score + LEAST(p_open_count * 4, 20);
    
    -- Click score (max 30 points)
    v_score := v_score + LEAST(p_click_count * 10, 30);
    
    -- Download score (max 20 points)
    v_score := v_score + LEAST(p_download_count * 20, 20);
    
    -- Time spent score (max 15 points)
    v_score := v_score + LEAST(p_time_spent_seconds / 60.0 * 3, 15);
    
    -- Pages viewed score (max 10 points)
    v_score := v_score + LEAST(p_pages_viewed * 2, 10);
    
    -- Scroll depth score (max 5 points)
    v_score := v_score + (p_scroll_depth / 100.0 * 5);
    
    RETURN LEAST(v_score, 100);
END;
$$ LANGUAGE plpgsql;

-- Create view for engagement summary
CREATE OR REPLACE VIEW v_engagement_summary AS
SELECT 
    rt.report_id,
    rt.company_name,
    COUNT(DISTINCT rt.recipient_email) as total_recipients,
    COUNT(DISTINCT CASE WHEN rt.first_opened_timestamp IS NOT NULL THEN rt.recipient_email END) as unique_opens,
    COUNT(DISTINCT CASE WHEN rt.first_clicked_timestamp IS NOT NULL THEN rt.recipient_email END) as unique_clicks,
    COUNT(DISTINCT CASE WHEN rt.downloaded_timestamp IS NOT NULL THEN rt.recipient_email END) as unique_downloads,
    AVG(rt.engagement_score) as avg_engagement_score,
    SUM(rt.open_count) as total_opens,
    SUM(rt.click_count) as total_clicks,
    SUM(rt.download_count) as total_downloads,
    AVG(rt.time_spent_seconds) as avg_time_spent_seconds,
    COUNT(DISTINCT ct.conversion_id) as total_conversions,
    SUM(ct.conversion_value) as total_conversion_value
FROM report_tracking rt
LEFT JOIN conversion_tracking ct ON rt.tracking_id = ct.tracking_id
GROUP BY rt.report_id, rt.company_name;

-- Create view for follow-up sequence performance
CREATE OR REPLACE VIEW v_sequence_performance AS
SELECT 
    fs.sequence_name,
    fs.sequence_type,
    fs.variant_name,
    COUNT(DISTINCT fs.sequence_id) as total_sequences,
    COUNT(DISTINCT CASE WHEN fs.status = 'completed' THEN fs.sequence_id END) as completed_sequences,
    COUNT(DISTINCT CASE WHEN fs.response_received = TRUE THEN fs.sequence_id END) as sequences_with_response,
    AVG(fs.emails_sent) as avg_emails_sent,
    AVG(CASE WHEN fs.emails_sent > 0 THEN fs.emails_opened::DECIMAL / fs.emails_sent * 100 ELSE 0 END) as avg_open_rate,
    AVG(CASE WHEN fs.emails_opened > 0 THEN fs.emails_clicked::DECIMAL / fs.emails_opened * 100 ELSE 0 END) as avg_click_rate,
    AVG(fs.sequence_engagement_score) as avg_engagement_score,
    AVG(fs.sequence_conversion_rate) as avg_conversion_rate
FROM follow_up_sequences fs
GROUP BY fs.sequence_name, fs.sequence_type, fs.variant_name;

-- Grant appropriate permissions (adjust as needed)
-- GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO your_app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO your_app_user;
-- GRANT SELECT ON v_engagement_summary, v_sequence_performance TO your_readonly_user;

-- Add comments for documentation
COMMENT ON TABLE report_tracking IS 'Tracks all engagement metrics for distributed reports including opens, clicks, downloads, and device information';
COMMENT ON TABLE follow_up_sequences IS 'Manages automated follow-up sequences with configuration, timing, and performance tracking';
COMMENT ON TABLE conversion_tracking IS 'Records conversions with full attribution, ROI metrics, and sales cycle tracking';
COMMENT ON COLUMN report_tracking.engagement_score IS 'Calculated score 0-100 based on open, click, download, time spent, and scroll depth metrics';
COMMENT ON COLUMN follow_up_sequences.sequence_config IS 'JSON configuration defining sequence steps, timing, conditions, and content templates';
COMMENT ON COLUMN conversion_tracking.touchpoint_sequence IS 'Chronological array of all interactions leading to conversion for multi-touch attribution';