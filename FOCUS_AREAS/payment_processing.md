# Stripe Payment Integration Workflow

## Overview
This document outlines the complete Stripe payment integration workflow for subscription-based services, including webhook configuration, customer management, subscription handling, and automated communications.

## 1. Webhook Configuration for Payment Success

### 1.1 Stripe Webhook Setup
Configure webhooks in Stripe Dashboard to listen for critical payment events:

```javascript
// Required webhook events
const WEBHOOK_EVENTS = [
  'checkout.session.completed',
  'payment_intent.succeeded',
  'payment_intent.payment_failed',
  'customer.subscription.created',
  'customer.subscription.updated',
  'customer.subscription.deleted',
  'invoice.payment_succeeded',
  'invoice.payment_failed'
];
```

### 1.2 Webhook Endpoint Implementation
```javascript
// webhook-handler.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

app.post('/webhook/stripe', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutComplete(event.data.object);
      break;
    case 'payment_intent.succeeded':
      await handlePaymentSuccess(event.data.object);
      break;
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object);
      break;
    // Add other event handlers
  }

  res.json({received: true});
});
```

### 1.3 Payment Success Handler
```javascript
async function handlePaymentSuccess(paymentIntent) {
  const customerId = paymentIntent.customer;
  const amount = paymentIntent.amount;
  const currency = paymentIntent.currency;
  
  // Log payment details
  await logPayment({
    stripeCustomerId: customerId,
    amount: amount / 100, // Convert from cents
    currency,
    paymentIntentId: paymentIntent.id,
    status: 'succeeded',
    timestamp: new Date()
  });
  
  // Update customer status
  await updateCustomerPaymentStatus(customerId, 'active');
}
```

## 2. Customer Creation in Supabase

### 2.1 Database Schema
```sql
-- customers table
CREATE TABLE customers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  stripe_customer_id TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  subscription_status TEXT DEFAULT 'pending',
  subscription_tier TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- subscriptions table
CREATE TABLE subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES customers(id),
  stripe_subscription_id TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL,
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- payment_history table
CREATE TABLE payment_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES customers(id),
  stripe_payment_intent_id TEXT UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 2.2 Customer Creation Function
```javascript
// supabase-customer.js
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

async function createOrUpdateCustomer(stripeCustomer) {
  const customerData = {
    stripe_customer_id: stripeCustomer.id,
    email: stripeCustomer.email,
    name: stripeCustomer.name || stripeCustomer.metadata.name,
    subscription_status: 'active',
    updated_at: new Date()
  };

  const { data, error } = await supabase
    .from('customers')
    .upsert(customerData, {
      onConflict: 'stripe_customer_id',
      returning: 'representation'
    });

  if (error) {
    console.error('Error creating/updating customer:', error);
    throw error;
  }

  return data[0];
}
```

### 2.3 Checkout Session Handler
```javascript
async function handleCheckoutComplete(session) {
  // Retrieve full customer details from Stripe
  const customer = await stripe.customers.retrieve(session.customer);
  
  // Create or update customer in Supabase
  const dbCustomer = await createOrUpdateCustomer(customer);
  
  // If subscription exists, create subscription record
  if (session.subscription) {
    const subscription = await stripe.subscriptions.retrieve(session.subscription);
    await createSubscriptionRecord(dbCustomer.id, subscription);
  }
  
  // Trigger welcome email
  await sendWelcomeEmail(dbCustomer);
}
```

## 3. Subscription Management

### 3.1 Subscription Creation
```javascript
async function createSubscriptionRecord(customerId, stripeSubscription) {
  const subscriptionData = {
    customer_id: customerId,
    stripe_subscription_id: stripeSubscription.id,
    status: stripeSubscription.status,
    current_period_start: new Date(stripeSubscription.current_period_start * 1000),
    current_period_end: new Date(stripeSubscription.current_period_end * 1000),
    cancel_at_period_end: stripeSubscription.cancel_at_period_end
  };

  const { data, error } = await supabase
    .from('subscriptions')
    .upsert(subscriptionData, {
      onConflict: 'stripe_subscription_id'
    });

  if (error) {
    console.error('Error creating subscription record:', error);
    throw error;
  }

  return data[0];
}
```

### 3.2 Subscription Update Handler
```javascript
async function handleSubscriptionUpdate(subscription) {
  // Update subscription record
  const { error } = await supabase
    .from('subscriptions')
    .update({
      status: subscription.status,
      current_period_start: new Date(subscription.current_period_start * 1000),
      current_period_end: new Date(subscription.current_period_end * 1000),
      cancel_at_period_end: subscription.cancel_at_period_end,
      updated_at: new Date()
    })
    .eq('stripe_subscription_id', subscription.id);

  if (error) {
    console.error('Error updating subscription:', error);
    throw error;
  }

  // Update customer subscription status
  await updateCustomerSubscriptionStatus(subscription.customer, subscription.status);
}
```

### 3.3 Subscription Cancellation
```javascript
async function handleSubscriptionCancellation(subscriptionId) {
  // Mark subscription as cancelled
  const { error } = await supabase
    .from('subscriptions')
    .update({
      status: 'cancelled',
      updated_at: new Date()
    })
    .eq('stripe_subscription_id', subscriptionId);

  if (error) {
    console.error('Error cancelling subscription:', error);
    throw error;
  }

  // Send cancellation confirmation email
  const customer = await getCustomerBySubscriptionId(subscriptionId);
  await sendCancellationEmail(customer);
}
```

## 4. Welcome Email Automation

### 4.1 Email Template Structure
```html
<!-- welcome-email-template.html -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Welcome to {{company_name}}</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; background-color: #f9f9f9; }
    .button { display: inline-block; padding: 12px 24px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Welcome to {{company_name}}!</h1>
    </div>
    <div class="content">
      <h2>Hi {{customer_name}},</h2>
      <p>Thank you for subscribing to {{subscription_tier}}!</p>
      <p>Your subscription is now active and you have access to all premium features.</p>
      
      <h3>What's Next?</h3>
      <ul>
        <li>Access your dashboard to manage your subscription</li>
        <li>Download our mobile app for on-the-go access</li>
        <li>Check out our getting started guide</li>
      </ul>
      
      <p style="text-align: center; margin-top: 30px;">
        <a href="{{dashboard_url}}" class="button">Go to Dashboard</a>
      </p>
      
      <p>If you have any questions, feel free to reply to this email or contact our support team.</p>
      
      <p>Best regards,<br>The {{company_name}} Team</p>
    </div>
  </div>
</body>
</html>
```

### 4.2 Email Sending Function
```javascript
// email-service.js
const nodemailer = require('nodemailer');
const handlebars = require('handlebars');
const fs = require('fs').promises;

// Configure email transporter
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: true,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  }
});

async function sendWelcomeEmail(customer) {
  try {
    // Load email template
    const templateHtml = await fs.readFile('./templates/welcome-email.html', 'utf8');
    const template = handlebars.compile(templateHtml);
    
    // Prepare template data
    const templateData = {
      company_name: process.env.COMPANY_NAME,
      customer_name: customer.name || customer.email.split('@')[0],
      subscription_tier: customer.subscription_tier || 'Premium',
      dashboard_url: `${process.env.APP_URL}/dashboard`
    };
    
    // Generate HTML
    const html = template(templateData);
    
    // Send email
    const mailOptions = {
      from: `"${process.env.COMPANY_NAME}" <${process.env.FROM_EMAIL}>`,
      to: customer.email,
      subject: `Welcome to ${process.env.COMPANY_NAME}!`,
      html: html,
      text: `Welcome to ${process.env.COMPANY_NAME}! Thank you for subscribing.`
    };
    
    await transporter.sendMail(mailOptions);
    console.log(`Welcome email sent to ${customer.email}`);
    
    // Log email sent
    await logEmailSent(customer.id, 'welcome_email');
    
  } catch (error) {
    console.error('Error sending welcome email:', error);
    throw error;
  }
}
```

### 4.3 Email Automation with n8n
```json
{
  "name": "Welcome Email Workflow",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "webhook/new-customer",
        "responseMode": "responseNode",
        "options": {}
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "position": [250, 300]
    },
    {
      "parameters": {
        "resource": "customer",
        "operation": "get",
        "customerId": "={{$json.customer_id}}"
      },
      "name": "Get Customer Details",
      "type": "n8n-nodes-base.stripe",
      "position": [450, 300]
    },
    {
      "parameters": {
        "fromEmail": "noreply@company.com",
        "toEmail": "={{$json.email}}",
        "subject": "Welcome to {{$node.parameters.company_name}}!",
        "html": true,
        "htmlTemplate": "welcome-email.html",
        "attachments": []
      },
      "name": "Send Welcome Email",
      "type": "n8n-nodes-base.emailSend",
      "position": [650, 300]
    }
  ]
}
```

## 5. Monthly Report Scheduling

### 5.1 Report Generation Function
```javascript
// report-generator.js
async function generateMonthlyReport(customerId, month, year) {
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0);
  
  // Fetch customer data
  const customer = await getCustomerById(customerId);
  
  // Fetch subscription data
  const subscription = await getCurrentSubscription(customerId);
  
  // Fetch payment history
  const payments = await getPaymentHistory(customerId, startDate, endDate);
  
  // Fetch usage statistics (if applicable)
  const usage = await getUsageStatistics(customerId, startDate, endDate);
  
  // Generate report data
  const reportData = {
    customer,
    subscription,
    payments,
    usage,
    period: {
      month: month,
      year: year,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString()
    },
    summary: {
      totalPayments: payments.reduce((sum, p) => sum + p.amount, 0),
      paymentCount: payments.length,
      subscriptionStatus: subscription.status
    }
  };
  
  return reportData;
}
```

### 5.2 PDF Report Generation
```javascript
// pdf-generator.js
const PDFDocument = require('pdfkit');
const fs = require('fs');

async function generatePDFReport(reportData) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument();
    const filename = `report_${reportData.customer.id}_${reportData.period.year}_${reportData.period.month}.pdf`;
    const stream = fs.createWriteStream(`./reports/${filename}`);
    
    doc.pipe(stream);
    
    // Header
    doc.fontSize(20).text('Monthly Subscription Report', 50, 50);
    doc.fontSize(12).text(`${reportData.period.month}/${reportData.period.year}`, 50, 80);
    
    // Customer Information
    doc.moveDown();
    doc.fontSize(16).text('Customer Information', 50, 120);
    doc.fontSize(12)
      .text(`Name: ${reportData.customer.name}`, 50, 150)
      .text(`Email: ${reportData.customer.email}`, 50, 170)
      .text(`Customer ID: ${reportData.customer.stripe_customer_id}`, 50, 190);
    
    // Subscription Details
    doc.moveDown();
    doc.fontSize(16).text('Subscription Details', 50, 230);
    doc.fontSize(12)
      .text(`Status: ${reportData.subscription.status}`, 50, 260)
      .text(`Tier: ${reportData.subscription.tier}`, 50, 280)
      .text(`Current Period: ${new Date(reportData.subscription.current_period_start).toLocaleDateString()} - ${new Date(reportData.subscription.current_period_end).toLocaleDateString()}`, 50, 300);
    
    // Payment Summary
    doc.moveDown();
    doc.fontSize(16).text('Payment Summary', 50, 340);
    doc.fontSize(12)
      .text(`Total Payments: $${reportData.summary.totalPayments.toFixed(2)}`, 50, 370)
      .text(`Number of Transactions: ${reportData.summary.paymentCount}`, 50, 390);
    
    // Payment History
    if (reportData.payments.length > 0) {
      doc.moveDown();
      doc.fontSize(16).text('Payment History', 50, 430);
      let yPosition = 460;
      
      reportData.payments.forEach(payment => {
        doc.fontSize(10)
          .text(`${new Date(payment.created_at).toLocaleDateString()} - $${payment.amount.toFixed(2)} - ${payment.status}`, 50, yPosition);
        yPosition += 20;
      });
    }
    
    doc.end();
    
    stream.on('finish', () => {
      resolve(filename);
    });
    
    stream.on('error', reject);
  });
}
```

### 5.3 Scheduled Report Job
```javascript
// scheduled-jobs.js
const cron = require('node-cron');

// Schedule monthly reports - runs on the 1st of each month at 9 AM
cron.schedule('0 9 1 * *', async () => {
  console.log('Starting monthly report generation...');
  
  try {
    // Get all active customers
    const activeCustomers = await getActiveCustomers();
    
    // Get current month and year
    const now = new Date();
    const lastMonth = now.getMonth() === 0 ? 11 : now.getMonth() - 1;
    const year = now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();
    
    // Generate reports for each customer
    for (const customer of activeCustomers) {
      try {
        // Generate report data
        const reportData = await generateMonthlyReport(customer.id, lastMonth + 1, year);
        
        // Generate PDF
        const pdfFilename = await generatePDFReport(reportData);
        
        // Send report email
        await sendMonthlyReportEmail(customer, pdfFilename, reportData);
        
        // Log report generation
        await logReportGeneration(customer.id, pdfFilename, 'monthly_report');
        
      } catch (error) {
        console.error(`Error generating report for customer ${customer.id}:`, error);
        await logError('monthly_report_generation', customer.id, error);
      }
    }
    
    console.log('Monthly report generation completed');
    
  } catch (error) {
    console.error('Error in monthly report job:', error);
  }
});
```

### 5.4 Report Email Template
```javascript
async function sendMonthlyReportEmail(customer, pdfFilename, reportData) {
  const templateHtml = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f9f9f9; }
        .summary { background-color: white; padding: 15px; margin: 20px 0; border-radius: 5px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Your Monthly Report</h1>
          <p>${reportData.period.month}/${reportData.period.year}</p>
        </div>
        <div class="content">
          <h2>Hi ${customer.name || customer.email},</h2>
          <p>Your monthly subscription report is ready!</p>
          
          <div class="summary">
            <h3>Quick Summary</h3>
            <p><strong>Subscription Status:</strong> ${reportData.subscription.status}</p>
            <p><strong>Total Payments:</strong> $${reportData.summary.totalPayments.toFixed(2)}</p>
            <p><strong>Transaction Count:</strong> ${reportData.summary.paymentCount}</p>
          </div>
          
          <p>Please find your detailed report attached to this email.</p>
          
          <p>If you have any questions about your subscription or this report, please don't hesitate to contact us.</p>
          
          <p>Best regards,<br>The ${process.env.COMPANY_NAME} Team</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const mailOptions = {
    from: `"${process.env.COMPANY_NAME}" <${process.env.FROM_EMAIL}>`,
    to: customer.email,
    subject: `Your Monthly Report - ${reportData.period.month}/${reportData.period.year}`,
    html: templateHtml,
    attachments: [
      {
        filename: `monthly_report_${reportData.period.month}_${reportData.period.year}.pdf`,
        path: `./reports/${pdfFilename}`
      }
    ]
  };

  await transporter.sendMail(mailOptions);
}
```

## Implementation Checklist

### Initial Setup
- [ ] Create Stripe account and obtain API keys
- [ ] Set up Supabase project and database schema
- [ ] Configure environment variables
- [ ] Install required npm packages

### Webhook Configuration
- [ ] Register webhook endpoint in Stripe Dashboard
- [ ] Implement webhook signature verification
- [ ] Create event handlers for all required events
- [ ] Test webhook endpoint with Stripe CLI

### Database Setup
- [ ] Create customers table in Supabase
- [ ] Create subscriptions table
- [ ] Create payment_history table
- [ ] Set up Row Level Security (RLS) policies

### Email Integration
- [ ] Configure SMTP settings
- [ ] Create email templates
- [ ] Test welcome email automation
- [ ] Set up monthly report email template

### Report Generation
- [ ] Implement report data aggregation
- [ ] Set up PDF generation
- [ ] Configure cron job for monthly scheduling
- [ ] Test report generation and delivery

### Testing
- [ ] Test complete payment flow
- [ ] Verify customer creation in database
- [ ] Confirm email delivery
- [ ] Validate report generation
- [ ] Test subscription lifecycle events

### Monitoring
- [ ] Set up error logging
- [ ] Configure webhook failure notifications
- [ ] Monitor email delivery rates
- [ ] Track report generation success

## Security Considerations

1. **API Key Management**
   - Store all API keys in environment variables
   - Never commit keys to version control
   - Use separate keys for development and production

2. **Webhook Security**
   - Always verify webhook signatures
   - Implement idempotency for webhook handlers
   - Use HTTPS for webhook endpoints

3. **Database Security**
   - Enable Row Level Security in Supabase
   - Use service role key only on backend
   - Implement proper authentication

4. **Payment Data**
   - Never store raw credit card information
   - Use Stripe's secure payment methods
   - Log only necessary payment information

## Error Handling

```javascript
// Global error handler for payment operations
async function handlePaymentError(error, context) {
  console.error(`Payment error in ${context}:`, error);
  
  // Log to error tracking service
  await logError({
    type: 'payment_error',
    context: context,
    error: error.message,
    stack: error.stack,
    timestamp: new Date()
  });
  
  // Notify admin if critical
  if (error.critical) {
    await notifyAdmin('Critical payment error', error);
  }
  
  // Return user-friendly error
  return {
    success: false,
    error: 'Payment processing error. Please try again or contact support.'
  };
}
```

## Support and Maintenance

1. **Regular Updates**
   - Keep Stripe SDK updated
   - Monitor Stripe API changes
   - Update webhook handlers as needed

2. **Monitoring**
   - Set up alerts for failed payments
   - Monitor subscription churn
   - Track email delivery rates

3. **Documentation**
   - Keep API documentation current
   - Document any custom implementations
   - Maintain changelog for updates