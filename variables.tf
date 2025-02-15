variable "name" {
  type        = string
  description = "The resource name"
  nullable    = false
}

variable "location" {
  type        = string
  description = "Resource location."
  nullable    = false
}

variable "type" {
  type        = string
  description = "The resource type."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The ID of the azure resource in which this resource is created."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Resource tags."
}

variable "sqlBestPracticesAssessmentEnabled" {
  type        = bool
  default     = false
  description = ""
}

variable "logAnalyticsWorkspaceSettings" {
  type = object({
    defaultDataCollectionRuleResourceId = optional(string)
    forceCmkForQuery                    = optional(bool)
    publicNetworkAccessForIngestion     = optional(string)
    publicNetworkAccessForQuery         = optional(string)
    retentionInDays                     = optional(number)
    features = optional(object({
      clusterResourceId                           = optional(string)
      disableLocalAuth                            = optional(bool)
      enableDataExport                            = optional(bool)
      enableLogAccessUsingOnlyResourcePermissions = optional(bool)
      immediatePurgeDataOn30Days                  = optional(bool)
    }))
    sku = optional(object({
      capacityReservationLevel = optional(number)
      name                     = string
    }))
    workspaceCapping = optional(object({
      dailyQuotaGb = optional(number)
    }))
  })
  default     = {}
  description = <<-EOT
 - `defaultDataCollectionRuleResourceId` - The resource ID of the default Data Collection Rule to use for this workspace.
 - `forceCmkForQuery` - Indicates whether customer managed storage is mandatory for query management.
 - `publicNetworkAccessForIngestion` - The network access type for accessing Log Analytics ingestion.
 - `publicNetworkAccessForQuery` - The network access type for accessing Log Analytics query.
 - `retentionInDays` - The workspace data retention in days. Allowed values are per pricing plan.

 ---
 `features` block supports the following:
 - `clusterResourceId` - Dedicated LA cluster resourceId that is linked to the workspaces.
 - `disableLocalAuth` - Disable Non-AAD based Auth.
 - `enableDataExport` - Flag that indicate if data should be exported.
 - `enableLogAccessUsingOnlyResourcePermissions` - Flag that indicate which permission to use - resource or workspace or both.
 - `immediatePurgeDataOn30Days` - Flag that describes if we want to remove the data after 30 days.

 ---
 `sku` block supports the following:
 - `capacityReservationLevel` - The capacity reservation level in GB for this workspace, when CapacityReservation sku is selected.
 - `name` - The name of the SKU. Defaults to `PerGB2018`.

 ---
 `workspaceCapping` block supports the following:
 - `dailyQuotaGb` - The workspace daily quota for ingestion.
EOT
  nullable    = false
}

variable "tableSettings" {
  type = map(object({
    plan                 = optional(string)
    retentionInDays      = optional(number)
    totalRetentionInDays = optional(number)
    restoredLogs = optional(object({
      endRestoreTime   = optional(string)
      sourceTable      = optional(string)
      startRestoreTime = optional(string)
    }))
    schema = optional(object({
      description = optional(string)
      displayName = optional(string)
      name        = optional(string)
      columns = optional(list(object({
        dataTypeHint = optional(string)
        description  = optional(string)
        displayName  = optional(string)
        name         = string
        type         = string
      })))
    }))
    searchResults = optional(object({
      description     = optional(string)
      endSearchTime   = optional(string)
      limit           = optional(number)
      query           = optional(string)
      startSearchTime = optional(string)
    }))
  }))
  default     = {}
  description = <<EOT
- `plan` - 	Instruct the system how to handle and charge the logs ingested to this table.
- `retentionInDays` - The table retention in days, between 4 and 730. Setting this property to -1 will default to the workspace retention.
- `totalRetentionInDays` - The table total retention in days, between 4 and 4383. Setting this property to -1 will default to table retention.

---
`restoredLogs` block supports the following:
- `endRestoreTime` - The timestamp to end the restore by (UTC).
- `sourceTable` - The source table to restore from.
- `startRestoreTime` - The timestamp to start the restore from (UTC).

---
`schema` block supports the following:
- `description` - The description of the table schema.
- `displayName` - The display name of the table schema.
- `name` - The name of the table schema.

---
`columns` - A list of table custom columns.
- dataTypeHint - Column data type logical hint.
- description - Column description.
- displayName - Column display name.
- name - Column name.
- type - Column data type.

---
`searchResults` block supports the following:
- `description` - Search job Description.
- `endSearchTime` - The timestamp to end the search by (UTC)
- `limit` - Limit the search job to return up to specified number of rows.
- `query` - The query to run.
- `startSearchTime` - The timestamp to start the search from (UTC).
EOT
  nullable    = false
}

variable "dataCollectionEndpoint" {
  type = object({
    description = optional(string)
    immutableId = optional(string)
    networkAcls = optional(object({
      publicNetworkAccess = optional(string)
    }))
  })
  default     = {}
  description = <<EOT
- `description` - The description of the data collection endpoint.
- `immutableId` - The immutable ID of this data collection endpoint resource. This property is READ-ONLY.

---
- `networkAcls` block supports the following:
  - `publicNetworkAccess` - The network access type for accessing Log Analytics ingestion. Allowed values are `Enabled` and `Disabled`.
EOT
}

# TODO: Currently not used inside this module. Needs to be refactored with the right intendation.
# variable "dataCollectionRules" {
#   type = object({
#     streamDeclarations = optional(object({
#       Custom-SqlAssessment_CL = optional(object({
#         columns = optional(list(object({
#           name = optional(string)
#           type = optional(string)
#         })))
#       }))
#       dataFlows = optional(list(object({
#         outputStream = optional(string)
#         streams      = optional(list(string))
#         transformKql = optional(string)
#         destinations = optional(list(string))
#       })))
#       dataSources = optional(object({
#         logFiles = optional(list(object({
#           filePatterns = optional(list(string))
#           format       = optional(string)
#           name         = optional(string)
#           settings = optional(object({
#             text = optional(object({
#               recordStartTimestampFormat = optional(string)
#             }))
#           }))
#         })))
#       }))
#       description = optional(string)
#     }))
#   })
#   default     = {}
#   description = <<EOT
# `streamDeclarations` block supports the following:
#   - `Custom-SqlAssessment_CL` - Custom stream declaration for SQL assessment.
#     - `columns` - List of columns for the stream.
#       - `name` - Column name.
#       - `type` - Column data type.

# ---
# `dataFlows` block supports the following:
#   - `outputStream` - The output stream of the data flow.
#   - `streams` - List of streams.
#   - `transformKql` - The KQL query to transform the data.
#   - `destinations` - List of destinations.

# ---
# `dataSources` block supports the following:
#   - `logFiles` - List of log files.
#     - `filePatterns` - List of file patterns.
#     - `format` - The format of the log file.
#     - `name` - The name of the log file.
#     - `settings` - Log file settings.
#       - `text` - Text settings.
#         - `recordStartTimestampFormat` - The record start timestamp format.

# ---
# - `description` - The description of the data collection rule.
# EOT
# }

variable "mssqlVirtualMachineSettings" {
  type = object({
    enableAutomaticUpgrade           = optional(bool)
    leastPrivilegeMode               = optional(string)
    sqlImageOffer                    = optional(string)
    sqlImageSku                      = optional(string)
    sqlManagement                    = optional(string)
    sqlServerLicenseType             = optional(string)
    sqlVirtualMachineGroupResourceId = optional(string)
    virtualMachineResourceId         = optional(string)
    wsfcStaticIp                     = optional(string)
    assessmentSettings = optional(object({
      enable         = optional(bool)
      runImmediately = optional(bool)
      schedule = optional(object({
        dayOfWeek         = optional(string)
        enable            = optional(bool)
        monthlyOccurrence = optional(number)
        startTime         = optional(string)
        weeklyInterval    = optional(number)
      }))
    }))
    autoBackupSettings = optional(object({
      backupScheduleType    = optional(string)
      backupSystemDbs       = optional(bool)
      daysOfWeek            = optional(list(string))
      enable                = optional(bool)
      enableEncryption      = optional(bool)
      fullBackupFrequency   = optional(string)
      fullBackupStartTime   = optional(number)
      fullBackupWindowHours = optional(number)
      logBackupFrequency    = optional(number)
      password              = optional(string)
      retentionPeriod       = optional(number)
      storageAccessKey      = optional(string)
      storageAccountUrl     = optional(string)
      storageContainerName  = optional(string)
    }))
    autoPatchingSettings = optional(object({
      additionalVmPatch             = optional(string)
      dayOfWeek                     = optional(string)
      enable                        = optional(bool)
      maintenanceWindowDuration     = optional(number)
      maintenanceWindowStartingHour = optional(number)
    }))
    keyVaultCredentialSettings = optional(object({
      azureKeyVaultUrl       = optional(string)
      credentialName         = optional(string)
      enable                 = optional(bool)
      servicePrincipalName   = optional(string)
      servicePrincipalSecret = optional(string)
    }))
    serverConfigurationsManagementSettings = optional(object({
      additionalFeaturesServerConfigurations = optional(object({
        isRServicesEnabled = optional(bool)
      }))
      azureAdAuthenticationSettings = optional(object({
        clientId = optional(string)
      }))
      sqlConnectivityUpdateSettings = optional(object({
        connectivityType      = optional(string)
        port                  = optional(number)
        sqlAuthUpdatePassword = optional(string)
        sqlAuthUpdateUserName = optional(string)
      }))
      sqlInstanceSettings = optional(object({
        collation                          = optional(string)
        isIfiEnabled                       = optional(bool)
        isLpimEnabled                      = optional(bool)
        isOptimizeForAdHocWorkloadsEnabled = optional(bool)
        maxDop                             = optional(number)
        maxServerMemoryMB                  = optional(number)
        minServerMemoryMB                  = optional(number)
      }))
      sqlStorageUpdateSettings = optional(object({
        diskConfigurationType = optional(string)
        diskCount             = optional(number)
        startingDeviceId      = optional(number)
      }))
      sqlWorkloadTypeUpdateSettings = optional(object({
        sqlWorkloadType = optional(string)
      }))
    }))
    storageConfigurationSettings = optional(object({
      diskConfigurationType    = optional(string)
      enableStorageConfigBlade = optional(bool)
      sqlSystemDbOnDataDisk    = optional(bool)
      storageWorkloadType      = optional(string)
      sqlDataSettings = optional(object({
        defaultFilePath = optional(string)
        luns            = optional(list(number))
        useStoragePool  = optional(bool)
      }))
      sqlLogSettings = optional(object({
        defaultFilePath = optional(string)
        luns            = optional(list(number))
        useStoragePool  = optional(bool)
      }))
      sqlTempDbSettings = optional(object({
        dataFileCount     = optional(number)
        dataFileSize      = optional(number)
        dataGrowth        = optional(number)
        defaultFilePath   = optional(string)
        logFileSize       = optional(number)
        logGrowth         = optional(number)
        luns              = optional(list(number))
        persistFolder     = optional(bool)
        persistFolderPath = optional(string)
        useStoragePool    = optional(bool)
      }))
    }))
    virtualMachineIdentitySettings = optional(object({
      resourceId = optional(string)
      type       = optional(string)
    }))
    wsfcDomainCredentials = optional(object({
      clusterBootstrapAccountPassword = optional(string)
      clusterOperatorAccountPassword  = optional(string)
      sqlServiceAccountPassword       = optional(string)
    }))
  })
  default     = {}
  description = <<DESC
- `enableAutomaticUpgrade` - Enable automatic upgrade of SQL IaaS extension Agent.
- `leastPrivilegeMode` - SQL IaaS Agent least privilege mode.
- `sqlImageOffer` - SQL image offer. Examples include SQL2016-WS2016, SQL2017-WS2016.
- `sqlImageSku` - SQL Server edition type.
- `sqlManagement` - SQL Server Management type. NOTE: This parameter is not used anymore. API will automatically detect the Sql Management, refrain from using it.
- `sqlServerLicenseType` - SQL Server license type.
- `sqlVirtualMachineGroupResourceId` - ARM resource id of the SQL virtual machine group this SQL virtual machine is or will be part of.
- `virtualMachineResourceId` - ARM Resource id of underlying virtual machine created from SQL marketplace image.
- `wsfcStaticIp` - Domain credentials for setting up Windows Server Failover Cluster for SQL availability group.

---
`assessmentSettings` block supports the following:
- `enable` - Enable or disable SQL best practices Assessment feature on SQL virtual machine.
- `runImmediately` - Run SQL best practices Assessment immediately on SQL virtual machine.

---
`schedule` block supports the following:
- `dayOfWeek` - Day of the week to run assessment.
- `enable` - Enable or disable schedule for SQL best practices Assessment feature on SQL virtual machine.
- `monthlyOccurrence` - Occurrence of the DayOfWeek day within a month to schedule assessment. Takes values: 1,2,3,4 and -1. Use -1 for last DayOfWeek day of the month.
- `startTime` - Time of the day in HH:mm format. Eg. 17:30.
- `weeklyInterval` - Number of weeks to schedule between 2 assessment runs. Takes value from 1-6.

---
`autoBackupSettings` block supports the following:
- `backupScheduleType` - Backup schedule type.
- `backupSystemDbs` - Include or exclude system databases from auto backup.
- `daysOfWeek` - Days of the week for the backups when FullBackupFrequency is set to Weekly.
- `enable` - Enable or disable autobackup on SQL virtual machine.
- `enableEncryption` - Enable or disable encryption for backup on SQL virtual machine.
- `fullBackupFrequency` - Frequency of full backups. In both cases, full backups begin during the next scheduled time window.
- `fullBackupStartTime` - Start time of a given day during which full backups can take place. 0-23 hours.
- `fullBackupWindowHours` - Duration of the time window of a given day during which full backups can take place. 1-23 hours.
- `logBackupFrequency` - Frequency of log backups. 5-60 minutes.
- `password` - Password for encryption on backup.
- `retentionPeriod` - Retention period of backup: 1-90 days.
- `storageAccessKey` - Storage account key where backup will be taken to.
- `storageAccountUrl` - Storage account url where backup will be taken to.
- `storageContainerName` - Storage container name where backup will be taken to.

---
`autoPatchingSettings` block supports the following:
- `additionalVmPatch` - Additional Patch to be enable or enabled on the SQL Virtual Machine.
- `dayOfWeek` - Day of week to apply the patch on.
- `enable` - Enable or disable autopatching on SQL virtual machine.
- `maintenanceWindowDuration` - Duration of patching.
- `maintenanceWindowStartingHour` - Hour of the day when patching is initiated. Local VM time.

---
`keyVaultCredentialSettings` block supports the following:
- `azureKeyVaultUrl` - Azure Key Vault url.
- `credentialName` - Credential name.
- `enable` - Enable or disable key vault credential setting.
- `servicePrincipalName` - Service principal name to access key vault.
- `servicePrincipalSecret` - Service principal name secret to access key vault.

---
`serverConfigurationsManagementSettings` block supports the following:
- `additionalFeaturesServerConfigurations` - Additional SQL feature settings.
- `azureAdAuthenticationSettings` - Azure AD authentication settings.
- `sqlConnectivityUpdateSettings` - SQL connectivity type settings.
- `sqlInstanceSettings` - SQL instance settings.
- `sqlStorageUpdateSettings` - SQL storage update settings.
- `sqlWorkloadTypeUpdateSettings` - SQL workload type update settings.

---
`additionalFeaturesServerConfigurations` block supports the following:
- `isRServicesEnabled` - Enable or disable R services on SQL virtual machine (SQL 2016 onwards).

---
`azureAdAuthenticationSettings` block supports the following:
- `clientId` - The client Id of the Managed Identity to query Microsoft Graph API. An empty string must be used for the system assigned Managed Identity.

---
`sqlConnectivityUpdateSettings` block supports the following:
- `connectivityType` - SQL Server connectivity option.
- `port` - SQL Server port.
- `sqlAuthUpdatePassword` - SQL Server sysadmin login password.
- `sqlAuthUpdateUserName` - SQL Server sysadmin login to create.

---
`sqlInstanceSettings` block supports the following:
- `collation` - SQL Server Collation.
- `isIfiEnabled` - SQL Server IFI.
- `isLpimEnabled` - SQL Server LPIM.
- `isOptimizeForAdHocWorkloadsEnabled` - SQL Server Optimize for AdHoc Workloads.
- `maxDop` - SQL Server MaxDop.
- `maxServerMemoryMB` - SQL Server Max Server Memory.
- `minServerMemoryMB` - SQL Server Min Server Memory.

---
`sqlStorageUpdateSettings` block supports the following:
- `diskConfigurationType` - Disk configuration to apply to SQL Server.
- `diskCount` - Virtual machine disk count.
- `startingDeviceId` - Device id of the first disk to be updated.

---
`sqlWorkloadTypeUpdateSettings` block supports the following:
- `sqlWorkloadType` - SQL Server workload type.

---
`storageConfigurationSettings` block supports the following:
- `diskConfigurationType` - Disk configuration to apply to SQL Server.
- `enableStorageConfigBlade` - Enable SQL IaaS Agent storage configuration blade in Azure Portal.
- `sqlSystemDbOnDataDisk` - SQL Server SystemDb Storage on DataPool if true.
- `storageWorkloadType` - Storage workload type.

---
`sqlDataSettings` block supports the following:
- `defaultFilePath` - SQL Server default file path.
- `luns` - Logical Unit Numbers for the disks.
- `useStoragePool` - Use storage pool to build a drive if true or not provided.

---
`sqlLogSettings` block supports the following:
- `defaultFilePath` - SQL Server default file path.
- `luns` - Logical Unit Numbers for the disks.
- `useStoragePool` - Use storage pool to build a drive if true or not provided.

---
`sqlTempDbSettings` block supports the following:
- `dataFileCount` - Number of data files for tempdb.
- `dataFileSize` - Size of data file for tempdb.
- `dataGrowth` - 	SQL Server tempdb data file autoGrowth size.
- `defaultFilePath` - SQL Server default file path.
- `logFileSize` - Size of log file for tempdb.
- `logGrowth` - SQL Server tempdb log file autoGrowth size.
- `luns` - Logical Unit Numbers for the disks.
- `persistFolder` - Persist tempdb folder if true.
- `persistFolderPath` - Persist tempdb folder path.
- `useStoragePool` - Use storage pool to build a drive if true or not provided.

---
`virtualMachineIdentitySettings` block supports the following:
- `resourceId` - ARM Resource Id of the identity. Only required when UserAssigned identity is selected.
- `type` - Identity type of the virtual machine. Specify None to opt-out of Managed Identities.

---
`wsfcDomainCredentials` block supports the following:
- `clusterBootstrapAccountPassword` - Cluster bootstrap account password.
- `clusterOperatorAccountPassword` - Cluster operator account password.
- `sqlServiceAccountPassword` - SQL service account password.
DESC
  nullable    = false
}

variable "update_settings" {
  type = object({
    serverConfigurationsManagementSettings = optional(object({
      azureAdAuthenticationSettings = optional(object({
        clientId = optional(string, "")
      }))
    }))
    keyVaultCredentialSettings = optional(object({
      enable                 = optional(bool)
      azureKeyVaultUrl       = optional(string)
      credentialName         = optional(string)
      servicePrincipalName   = optional(string)
      servicePrincipalSecret = optional(string)
    }))
  })
  default     = {}
  description = <<DESC
`azureAdAuthenticationSettings` block supports the following:
- `clientId` - The client Id of the Managed Identity to query Microsoft Graph API. An empty string must be used for the system assigned Managed Identity.

---
`keyVaultCredentialSettings` block supports the following:
- `enable` - Enable or disable key vault credential setting.
- `azureKeyVaultUrl` - Azure Key Vault url.
- `credentialName` - Credential name.
- `servicePrincipalName` - Service principal name to access key vault.
- `servicePrincipalSecret` - Service principal name secret to access key vault.
DESC
}
