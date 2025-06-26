# n8n Common Errors - READ BEFORE ANY n8n WORK

## 🚨 CRITICAL MISTAKES (Never Repeat These)

### 1. Basic LLM Chain Nodes - NEVER USE
**❌ Error**: Using Basic LLM Chain nodes for Claude API integration
**Problem**: These nodes consistently hang and block workflow execution
**✅ Solution**: Always use HTTP Request nodes for Claude API calls
**Implementation**:
```javascript
// HTTP Request Node Configuration
URL: https://api.anthropic.com/v1/messages
Method: POST
Headers:
- x-api-key: {{ $credentials.claudeApi.apiKey }}
- content-type: application/json
- anthropic-version: 2023-06-01

Body:
{
  "model": "claude-3-sonnet-20241022",
  "max_tokens": 2000,
  "messages": [
    {
      "role": "user", 
      "content": "{{ $json.prompt }}"
    }
  ]
}
```

### 2. Manual UI Configuration Post-Import
**❌ Error**: Importing JSON workflows then manually configuring nodes in UI
**Problem**: Defeats the purpose of automated workflow creation
**✅ Solution**: Create complete JSON workflows with all parameters configured
**Requirements**:
- All node parameters must be set in JSON
- All expressions properly formatted with {{ }}
- All connections explicitly defined
- No manual work required after import

### 3. Execute Workflow Nodes for Inter-Workflow Communication  
**❌ Error**: Using Execute Workflow nodes to call other workflows
**Problem**: "Missing node to start execution" errors and unreliable execution
**✅ Solution**: Use HTTP Request to webhook endpoints
**Pattern**:
```javascript
// Instead of Execute Workflow node:
URL: https://keiracom.app.n8n.cloud/webhook/target-workflow
Method: POST
Body: { "data": "{{ $json.payload }}" }
```

### 4. Stripe Webhook Routing Errors
**❌ Error**: Routing payment webhooks directly to wrong workflows
**Problem**: Payments processed incorrectly, customer creation fails
**✅ Solution**: Always route through Universal Claude Processor for decision-making
**Flow**: `Stripe Webhook → Universal Claude Processor → Appropriate Action`

### 5. Missing Error Handling on External APIs
**❌ Error**: Not setting "Continue on Fail" for external API calls
**Problem**: Entire workflow fails when external service is down
**✅ Solution**: Always enable "Continue on Fail" for SEMrush, Claude, and other external APIs
**Implementation**: Include fallback logic and mock data responses

## 🔧 TECHNICAL FIXES THAT WORK

### Switch Node Expression Issues
**Problem**: Switch nodes not evaluating expressions properly
**Solutions**:
1. **Use Set nodes before Switch**: Restructure data first
2. **Try hardcoding values**: Test with static values first
3. **Check expression syntax**: `{{ $json.field }}` vs `{{$json.field}}`
4. **Consider IF nodes**: Sometimes more reliable for simple routing

### Node Reference Errors
**Problem**: "Referenced node doesn't exist" errors
**Solution**: Use exact node names in expressions
```javascript
// Correct format:
$('Node Name').item.json.property

// Common mistakes:
$json.property // refers to current node input
$node['Wrong Name'].json.property // node name mismatch
```

### JSON Parsing from Claude Responses
**Problem**: Claude returns mixed text + JSON, causing parse errors
**Solution**: Extract JSON using regex
```javascript
// Extract JSON from mixed response:
const text = $('HTTP Request').item.json.content[0].text;
const jsonMatch = text.match(/\{[\s\S]*\}/);
const jsonData = jsonMatch ? JSON.parse(jsonMatch[0]) : {};
```

### Merge Node Configuration
**Problem**: Merge nodes creating nested objects instead of combining data
**Solution**: Use multiplex mode and access via `$input.first().json`
```javascript
// After merge with multiplex:
const mergedData = $input.first().json;
// NOT: $input.all()[0].json
```

## ⚠️ CONFIGURATION PATTERNS

### Webhook Node Setup
```json
{
  "parameters": {
    "httpMethod": "POST",
    "path": "unique-endpoint-name",  
    "responseMode": "responseNode",
    "options": {}
  }
}
```

### HTTP Request to Claude API
```json
{
  "parameters": {
    "url": "https://api.anthropic.com/v1/messages",
    "authentication": "predefinedCredentialType",
    "nodeCredentialType": "claudeApi",
    "method": "POST",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        {
          "name": "anthropic-version",
          "value": "2023-06-01"
        }
      ]
    },
    "sendBody": true,
    "bodyContentType": "json", 
    "jsonBody": "={{ JSON.stringify({\n  \"model\": \"claude-3-sonnet-20241022\",\n  \"max_tokens\": 2000,\n  \"messages\": [{\n    \"role\": \"user\",\n    \"content\": $json.prompt\n  }]\n}) }}"
  }
}
```

### Error Handling Pattern
```javascript
// In Code nodes:
try {
  // Main workflow logic
  const result = processData($input.all());
  return { success: true, data: result };
} catch (error) {
  console.error('Workflow error:', error);
  return { 
    success: false, 
    error: error.message,
    fallback: 'default-value'
  };
}
```

## 📋 PRE-WORK CHECKLIST

Before creating or modifying any n8n workflow:

### ✅ Planning Phase
- [ ] Check this error document for known issues
- [ ] Identify all external API dependencies
- [ ] Plan error handling for each external call
- [ ] Design webhook endpoints and data flow
- [ ] Verify all required credentials exist

### ✅ Development Phase  
- [ ] Use HTTP Request for all Claude API calls
- [ ] Enable "Continue on Fail" for external APIs
- [ ] Include comprehensive error handling
- [ ] Test expressions in Set nodes before Switch nodes
- [ ] Use exact node names in all references

### ✅ Testing Phase
- [ ] Test with valid data inputs
- [ ] Test with invalid/missing data
- [ ] Test external API failure scenarios
- [ ] Verify webhook endpoints respond correctly
- [ ] Check execution logs for any warnings

### ✅ Deployment Phase
- [ ] Document any new patterns or solutions
- [ ] Update this error document if new issues found
- [ ] Verify production credentials are configured
- [ ] Test end-to-end flow with real data

## 🔄 WORKFLOW ARCHITECTURE PATTERNS

### Standard Webhook Workflow
```
Webhook Trigger → Extract Data → Validate Input → Process Logic → External APIs → Store Results → Respond
```

### Inter-Workflow Communication
```
Source Workflow → HTTP Request → Target Webhook → Process → Response
```

### Error Recovery Pattern
```
Main Process → (Error) → Log Error → Fallback Logic → Continue/Retry → Success Response
```

## 🚨 WHEN THINGS GO WRONG

### Workflow Hanging
1. **Check Basic LLM Chain nodes** - Replace with HTTP Request
2. **Check infinite loops** - Verify conditional logic
3. **Check external API timeouts** - Add timeout settings
4. **Check expression evaluation** - Test in Set nodes first

### Webhook Not Responding
1. **Verify webhook URL format**: `https://instance.n8n.cloud/webhook/path`
2. **Check workflow activation status**
3. **Verify HTTP method matches** (POST vs GET)
4. **Check execution logs** for error details

### Data Not Flowing Between Nodes
1. **Check node connections** in workflow JSON
2. **Verify node names match** in expressions
3. **Check data structure** - use console.log to debug
4. **Verify expression syntax** - {{ }} wrapper required

---

## 📝 KNOWN LIMITATIONS

### n8n Cloud Limitations
- **API Limitations**: Cannot programmatically create complex node configurations
- **Execution Limits**: 5,000 executions/month on standard plan
- **Memory Limits**: Large data processing may hit memory limits
- **Credential Sharing**: Limited sharing between workflows

### Integration Challenges
- **SEMrush API**: CSV response format requires parsing
- **Stripe Webhooks**: Event handling requires careful data extraction
- **Claude API**: Response parsing needs regex extraction
- **Supabase**: RLS policies must be configured correctly

---

**Remember**: Every error in this document represents time lost and problems solved. Always reference this before starting n8n work, and update it when you find new issues!