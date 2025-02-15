resource "azapi_resource" "log_analytics_workspace" {
  count = var.sqlBestPracticesAssessmentEnabled == true ? 1 : 0

  type = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = var.logAnalyticsWorkspaceSettings
  }
  location  = var.location
  name      = "law-${var.name}"
  parent_id = var.parent_id
  tags      = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"

  depends_on = [
    azapi_resource.log_analytics_workspace,
  ]
}

resource "azapi_resource" "log_analytics_workspace_table" {
  for_each = var.sqlBestPracticesAssessmentEnabled == true ? var.tableSettings : tomap({})

  type = "Microsoft.OperationalInsights/workspaces/tables@2023-09-01"
  body = {
    properties = each.value
  }
  name      = each.key
  parent_id = azapi_resource.log_analytics_workspace[0].id

  lifecycle {
    ignore_changes = [
      body
    ]
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

resource "azapi_resource" "data_collection_endpoint" {
  count = var.sqlBestPracticesAssessmentEnabled == true ? 1 : 0

  type = "Microsoft.Insights/dataCollectionEndpoints@2023-03-11"
  body = {
    properties = var.dataCollectionEndpoint
  }
  location  = var.location
  name      = "${var.location}-DCE-1"
  parent_id = var.parent_id
  tags      = var.tags

  lifecycle {
    ignore_changes = [
      body
    ]
  }
}

resource "azapi_resource" "data_collection_rules" {
  count = var.sqlBestPracticesAssessmentEnabled == true ? 1 : 0

  type = "Microsoft.Insights/dataCollectionRules@2023-03-11"
  body = {
    properties = {
      streamDeclarations = {
        Custom-SqlAssessment_CL = {
          columns = [
            {
              name = "TimeGenerated"
              type = "datetime"
            },
            {
              type = "string"
              name = "RawData"
            }
          ]
        }
      }
      dataCollectionEndpointId = azapi_resource.data_collection_endpoint[0].id
      dataFlows = [
        {
          outputStream = "Custom-SqlAssessment_CL"
          streams = [
            "Custom-SqlAssessment_CL"
          ]
          transformKql = "source"
          destinations = [
            azapi_resource.log_analytics_workspace[0].name
          ]
        }
      ]
      dataSources = {
        logFiles = [
          {
            filePatterns = [
              "C:\\Windows\\System32\\config\\systemprofile\\AppData\\Local\\Microsoft SQL Server IaaS Agent\\Assessment\\*.csv"
            ]
            format = "text"
            name   = "Custom-SqlAssessment_CL"
            settings = {
              text = {
                recordStartTimestampFormat = "ISO 8601"
              }
            }
            streams = [
              "Custom-SqlAssessment_CL"
            ]
          }
        ]
      }
      description = ""
      destinations = {
        logAnalytics = [
          {
            name                = azapi_resource.log_analytics_workspace[0].name
            workspaceResourceId = azapi_resource.log_analytics_workspace[0].id
          }
        ]
      }
    }
  }
  location  = var.location
  name      = "${azapi_resource.log_analytics_workspace[0].output.properties.customerId}_${var.location}_DCR_1"
  parent_id = var.parent_id
  tags      = var.tags

  lifecycle {
    ignore_changes = [
      body,
      name
    ]
  }

  depends_on = [
    azapi_resource.log_analytics_workspace_table
  ]
}

resource "azapi_resource" "data_collection_association" {
  count = var.sqlBestPracticesAssessmentEnabled == true ? 1 : 0

  type = "Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01"
  body = {
    properties = {
      dataCollectionRuleId = azapi_resource.data_collection_rules[0].id
    }
  }
  name      = "${azapi_resource.log_analytics_workspace[0].output.properties.customerId}_${var.location}_DCRA_1"
  parent_id = var.mssqlVirtualMachineSettings.virtualMachineResourceId

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "azapi_resource" "mssql_virtual_machine" {
  type = var.type
  body = {
    properties = var.mssqlVirtualMachineSettings
  }
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  tags      = var.tags

  depends_on = [
    azapi_resource.data_collection_association
  ]
}

resource "azapi_update_resource" "mssql_virtual_machine" {
  type        = azapi_resource.mssql_virtual_machine.type
  resource_id = azapi_resource.mssql_virtual_machine.id
  body = {
    properties = var.update_settings
  }

  depends_on = [
    azapi_resource.mssql_virtual_machine
  ]
}
