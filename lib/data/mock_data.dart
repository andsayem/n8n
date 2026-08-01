class MockData {
  static Map<String, dynamic> data = {
    "workflows_response": {
      "data": [
        {
          "id": "1",
          "name": "Daily Report Sender",
          "active": true,
          "createdAt": "2024-01-10T10:00:00Z",
          "updatedAt": "2024-03-28T08:00:00Z",
          "tags": ["Reporting", "Email"],
          "nodes": [
            {"name": "Schedule Trigger", "type": "n8n-nodes-base.scheduleTrigger"},
            {"name": "MySQL", "type": "n8n-nodes-base.mySql"},
            {"name": "HTML Extract", "type": "n8n-nodes-base.html"},
            {"name": "Gmail", "type": "n8n-nodes-base.gmail"}
          ],
          "lastExecutionStatus": "success",
          "lastExecutionAt": "2024-03-28T08:00:07Z"
        },
        {
          "id": "2",
          "name": "Slack Notification Pipeline",
          "active": true,
          "createdAt": "2024-02-15T12:00:00Z",
          "updatedAt": "2024-03-28T09:15:00Z",
          "tags": ["Slack", "Webhook", "DevOps"],
          "nodes": [
            {"name": "Webhook", "type": "n8n-nodes-base.webhook"},
            {"name": "If", "type": "n8n-nodes-base.if"},
            {"name": "Slack", "type": "n8n-nodes-base.slack"}
          ],
          "lastExecutionStatus": "error",
          "lastExecutionAt": "2024-03-28T09:15:01Z"
        },
        {
          "id": "3",
          "name": "E-commerce Order Sync",
          "active": false,
          "createdAt": "2024-03-01T09:00:00Z",
          "updatedAt": "2024-03-25T14:30:00Z",
          "tags": ["Shopify", "Google Sheets"],
          "nodes": [
            {"name": "Shopify Trigger", "type": "n8n-nodes-base.shopifyTrigger"},
            {"name": "Google Sheets", "type": "n8n-nodes-base.googleSheets"},
            {"name": "Discord", "type": "n8n-nodes-base.discord"}
          ],
          "lastExecutionStatus": "success",
          "lastExecutionAt": "2024-03-25T14:30:05Z"
        },
        {
          "id": "4",
          "name": "Customer Onboarding",
          "active": true,
          "createdAt": "2024-03-10T15:00:00Z",
          "updatedAt": "2024-03-28T10:30:00Z",
          "tags": ["CRM", "Onboarding"],
          "nodes": [
            {"name": "Webhook", "type": "n8n-nodes-base.webhook"},
            {"name": "HubSpot", "type": "n8n-nodes-base.hubspot"},
            {"name": "Wait", "type": "n8n-nodes-base.wait"},
            {"name": "SendEmail", "type": "n8n-nodes-base.emailSend"}
          ],
          "lastExecutionStatus": "running",
          "lastExecutionAt": "2024-03-28T10:30:00Z"
        },
        {
          "id": "5",
          "name": "Backup to Dropbox",
          "active": false,
          "createdAt": "2023-12-20T08:00:00Z",
          "updatedAt": "2024-03-20T11:00:00Z",
          "tags": ["Backup", "Files"],
          "nodes": [
            {"name": "Cron", "type": "n8n-nodes-base.cron"},
            {"name": "FTP", "type": "n8n-nodes-base.ftp"},
            {"name": "Dropbox", "type": "n8n-nodes-base.dropbox"}
          ],
          "lastExecutionStatus": "success",
          "lastExecutionAt": "2024-03-20T11:00:10Z"
        }
      ]
    },
    "executions_response": {
      "data": [
        {
          "id": "101",
          "workflowId": "1",
          "status": "success",
          "startedAt": "2024-03-28T08:00:05.000Z",
          "stoppedAt": "2024-03-28T08:00:07.500Z",
          "executionTime": 2500,
          "finished": true,
          "mode": "trigger",
          "workflowName": "Daily Report Sender"
        },
        {
          "id": "102",
          "workflowId": "2",
          "status": "error",
          "startedAt": "2024-03-28T09:15:00.000Z",
          "stoppedAt": "2024-03-28T09:15:01.200Z",
          "executionTime": 1200,
          "finished": true,
          "mode": "webhook",
          "workflowName": "Slack Notification Pipeline"
        },
        {
          "id": "103",
          "workflowId": "4",
          "status": "running",
          "startedAt": "2024-03-28T10:30:00.000Z",
          "stoppedAt": null,
          "executionTime": null,
          "finished": false,
          "mode": "webhook",
          "workflowName": "Customer Onboarding"
        }
      ]
    },
    "tags_response": {
      "data": [
        { "id": "tag-1", "name": "Reporting" },
        { "id": "tag-2", "name": "Email" },
        { "id": "tag-3", "name": "Slack" },
        { "id": "tag-4", "name": "Webhook" },
        { "id": "tag-5", "name": "DevOps" },
        { "id": "tag-6", "name": "CRM" },
        { "id": "tag-7", "name": "Backup" }
      ]
    },
    "credentials_response": {
      "data": [
        {
          "id": "cred-1",
          "name": "Gmail Account",
          "type": "gmail",
          "isManaged": true,
          "scopes": ["credential:update", "credential:delete"],
          "createdAt": "2024-03-28T08:00:00.000Z",
          "updatedAt": "2024-03-28T08:00:00.000Z"
        },
        {
          "id": "cred-2",
          "name": "Team Slack",
          "type": "slack",
          "isManaged": false,
          "scopes": ["credential:update", "credential:delete"],
          "createdAt": "2024-03-25T10:30:00.000Z",
          "updatedAt": "2024-03-25T10:30:00.000Z"
        },
        {
          "id": "cred-3",
          "name": "PostgreSQL Production",
          "type": "postgres",
          "isManaged": false,
          "scopes": ["credential:update", "credential:delete"],
          "createdAt": "2024-03-20T09:15:00.000Z",
          "updatedAt": "2024-03-20T09:15:00.000Z"
        },
        {
          "id": "cred-4",
          "name": "GitHub OAuth",
          "type": "github",
          "isManaged": false,
          "scopes": ["credential:update", "credential:delete"],
          "createdAt": "2024-03-15T14:00:00.000Z",
          "updatedAt": "2024-03-15T14:00:00.000Z"
        },
        {
          "id": "cred-5",
          "name": "Stripe Live",
          "type": "stripe",
          "isManaged": false,
          "scopes": ["credential:update", "credential:delete"],
          "createdAt": "2024-03-10T11:45:00.000Z",
          "updatedAt": "2024-03-10T11:45:00.000Z"
        }
      ]
    }
  };
}