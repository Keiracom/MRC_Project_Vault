# Supabase Common Errors - Database Issues & Solutions

## 🚨 CRITICAL DATABASE ERRORS

### 1. Row Level Security (RLS) Blocking Access
**❌ Error**: "Invalid API key" or "Permission denied" even with correct credentials
**Problem**: RLS policies not configured or incorrect policy rules
**✅ Solution**: Enable RLS and create appropriate policies
```sql
-- Enable RLS on table
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Create service role policy (for n8n)
CREATE POLICY "Service role full access" ON table_name
FOR ALL USING (auth.role() = 'service_role');

-- Create public read policy (if needed)
CREATE POLICY "Public read access" ON table_name  
FOR SELECT USING (true);
```

### 2. Using Wrong API Key Type
**❌ Error**: Service key showing "Invalid API key" errors
**Problem**: In some environments, anon key works better than service key
**✅ Solution**: Try anon key with proper RLS policies
```javascript
// In n8n HTTP Request node:
Headers:
- apikey: [SUPABASE_ANON_KEY]  // Try this if service key fails
- authorization: Bearer [SUPABASE_ANON_KEY]
```

### 3. Foreign Key Constraint Violations
**❌ Error**: "violates foreign key constraint" on inserts
**Problem**: Referenced record doesn't exist or ID mismatch
**✅ Solution**: Verify parent records exist first
```sql
-- Check if customer exists before creating dependent record
SELECT id FROM customers WHERE email = 'customer@example.com';

-- Use UPSERT for safer operations
INSERT INTO customers (email, domain, tier) 
VALUES ($1, $2, $3)
ON CONFLICT (email) DO UPDATE SET 
  domain = EXCLUDED.domain,
  tier = EXCLUDED.tier;
```

### 4. JSON Field Formatting Issues
**❌ Error**: "invalid input syntax for type json"
**Problem**: Passing invalid JSON to JSONB fields
**✅ Solution**: Validate JSON before database operations
```javascript
// In n8n Code node:
try {
  const jsonData = JSON.stringify(dataObject);
  return { json_field: jsonData };
} catch (error) {
  return { json_field: '{}' }; // fallback empty object
}
```

## 🔧 CONNECTION & AUTHENTICATION FIXES

### Connection String Issues
**Problem**: Connection timeouts or "could not connect" errors
**Solutions**:
1. **Check connection pooling**: Supabase has connection limits
2. **Verify URL format**: `https://[project-ref].supabase.co`
3. **Test with Postman**: Verify API access outside n8n
4. **Check firewall**: Ensure n8n can reach Supabase

### API Key Management
```javascript
// Correct headers for different operations:

// For most operations (use anon key):
Headers:
- apikey: sk-[anon-key]
- authorization: Bearer sk-[anon-key] 
- content-type: application/json

// For admin operations (use service key):
Headers:
- apikey: sk-[service-key]
- authorization: Bearer sk-[service-key]
- content-type: application/json
```

### RLS Policy Debugging
```sql
-- Check existing policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';

-- Test policy with specific role
SET ROLE anon;
SELECT * FROM your_table LIMIT 1;
RESET ROLE;
```

## 📊 DATA OPERATION PATTERNS

### Safe Insert Pattern
```sql
-- Use UPSERT to avoid duplicate key errors
INSERT INTO customers (email, domain, tier, status)
VALUES ($1, $2, $3, $4)
ON CONFLICT (email) DO UPDATE SET
  domain = EXCLUDED.domain,
  tier = EXCLUDED.tier,
  status = EXCLUDED.status,
  updated_at = NOW();
```

### Batch Operations
```sql
-- Insert multiple competitors efficiently
INSERT INTO customer_competitors (customer_id, competitor_domain, overlap_score)
SELECT $1, unnest($2::text[]), unnest($3::decimal[]);
```

### JSON Operations
```sql
-- Update specific JSON field
UPDATE customers 
SET metadata = jsonb_set(metadata, '{last_login}', '"2024-01-01"')
WHERE id = $1;

-- Query JSON fields
SELECT * FROM customers 
WHERE metadata->>'industry' = 'dental';
```

## ⚠️ SCHEMA MANAGEMENT ISSUES

### Migration Problems
**Problem**: Schema changes breaking existing workflows
**Solutions**:
1. **Test migrations**: Use staging environment first
2. **Backward compatibility**: Keep old columns during transition
3. **Version control**: Track all schema changes in git
4. **Rollback plan**: Always have rollback scripts ready

### Index Performance
**Problem**: Slow queries as data grows
**Solutions**:
```sql
-- Add indexes for frequently queried columns
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_tier_status ON customers(tier, status);
CREATE INDEX idx_outreach_log_prospect_sent ON outreach_log(prospect_id, sent_at);

-- Monitor query performance
EXPLAIN ANALYZE SELECT * FROM customers WHERE email = 'test@example.com';
```

### Function Errors
**Problem**: Custom functions failing or not found
**Solutions**:
1. **Check function syntax**: PostgreSQL function requirements
2. **Verify permissions**: Ensure execution privileges
3. **Test individually**: Run functions in SQL editor first
4. **Error handling**: Include proper exception handling

## 🔄 WORKFLOW INTEGRATION FIXES

### n8n Supabase Node Configuration
```json
{
  "parameters": {
    "operation": "insert",
    "tableId": "customers",
    "dataToSend": "defineBelow",
    "fieldsToSend": {
      "values": [
        {
          "fieldName": "email",
          "fieldValue": "={{ $json.email }}"
        },
        {
          "fieldName": "tier", 
          "fieldValue": "={{ $json.tier }}"
        }
      ]
    },
    "options": {
      "upsert": {
        "column": "email"  // Use upsert to avoid duplicates
      }
    }
  }
}
```

### Error Handling in n8n
```javascript
// In Code node for Supabase operations:
try {
  const result = await supabaseOperation(data);
  return { success: true, data: result };
} catch (error) {
  console.error('Supabase error:', error);
  
  // Handle specific error types
  if (error.message.includes('violates foreign key')) {
    return { success: false, error: 'FOREIGN_KEY_VIOLATION', retry: false };
  }
  
  if (error.message.includes('duplicate key')) {
    return { success: false, error: 'DUPLICATE_KEY', retry: false };
  }
  
  // Generic error with retry
  return { success: false, error: error.message, retry: true };
}
```

## 📋 PRE-OPERATION CHECKLIST

Before any Supabase operation:

### ✅ Schema Verification
- [ ] Table exists and has correct structure
- [ ] Required columns are present
- [ ] Data types match expected input
- [ ] Foreign key relationships are valid

### ✅ Security Check
- [ ] RLS policies are enabled and configured
- [ ] Correct API key type for operation
- [ ] User permissions are appropriate
- [ ] Test access with expected role

### ✅ Data Validation
- [ ] Required fields are not null
- [ ] JSON fields are valid JSON
- [ ] Foreign key references exist
- [ ] Data types match schema expectations

### ✅ Error Handling
- [ ] Include try/catch in workflow logic
- [ ] Plan for constraint violations
- [ ] Handle network timeouts
- [ ] Log errors for debugging

## 🚨 EMERGENCY RECOVERY PROCEDURES

### Database Locked/Unresponsive
1. **Check Supabase status**: Visit status.supabase.com
2. **Verify connection limits**: Too many concurrent connections
3. **Kill long-running queries**: Check for blocking queries
4. **Contact Supabase support**: If infrastructure issue

### Data Corruption/Loss
1. **Stop all write operations** immediately
2. **Check recent backups** availability
3. **Identify scope of corruption**
4. **Plan recovery strategy** with point-in-time restore
5. **Test recovery** in staging environment first

### Schema Migration Failure
1. **Rollback migration** using prepared rollback script
2. **Identify failure cause** from error logs
3. **Fix migration script** and test in staging
4. **Re-run migration** with proper testing

---

## 📈 PERFORMANCE OPTIMIZATION

### Query Optimization Tips
```sql
-- Use EXPLAIN ANALYZE to understand query performance
EXPLAIN ANALYZE SELECT * FROM customers WHERE email = 'test@example.com';

-- Create covering indexes for frequent queries
CREATE INDEX idx_customers_lookup ON customers(email, tier, status);

-- Use partial indexes for filtered queries
CREATE INDEX idx_active_customers ON customers(email) WHERE status = 'active';
```

### Connection Management
- **Pool connections**: Don't create new connections for each operation
- **Close connections**: Always clean up connections in n8n
- **Monitor usage**: Track connection count and query performance
- **Timeout settings**: Set appropriate timeouts for operations

### Data Archival Strategy
```sql
-- Archive old data to maintain performance
INSERT INTO customers_archive SELECT * FROM customers WHERE created_at < NOW() - INTERVAL '2 years';
DELETE FROM customers WHERE created_at < NOW() - INTERVAL '2 years';

-- Vacuum and analyze after large operations
VACUUM ANALYZE customers;
```

---

**Remember**: Supabase errors often cascade - one authentication issue can cause multiple workflow failures. Always start debugging with connection and authentication verification before diving into specific query issues.