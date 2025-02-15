module "azapi_mssql_virtual_machine" {
  source = "../"

  name      = "vm-test-002"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-compute-001"
  type      = "Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-10-01"
  location  = "westeurope"

  sqlBestPracticesAssessmentEnabled = true

  tableSettings = {
    SqlAssessment_CL = {
      plan                 = "Analytics"
      retentionInDays      = 30
      totalRetentionInDays = 30
      schema = {
        name = "SqlAssessment_CL"
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
  }

  mssqlVirtualMachineSettings = {
    virtualMachineResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-compute-001/providers/Microsoft.Compute/virtualMachines/vm-test-001"

    sqlImageOffer          = "SQL2022-WS2022"
    sqlServerLicenseType   = "PAYG"
    sqlManagement          = "Full"
    leastPrivilegeMode     = "Enabled"
    sqlImageSku            = "Developer"
    enableAutomaticUpgrade = true

    autoPatchingSettings = {
      additionalVmPatch = "WUMU"
    }

    virtualMachineIdentitySettings = {
      type = "SystemAssigned"
    }

    serverConfigurationsManagementSettings = {
      sqlConnectivityUpdateSettings = {
        port = 1433
      }
    }

    storageConfigurationSettings = {
      diskConfigurationType = "NEW"
      sqlSystemDbOnDataDisk = false
      storageWorkloadType   = "GENERAL"

      sqlDataSettings = {
        defaultFilePath = "F:\\data"
        luns            = [0]
      }

      sqlLogSettings = {
        defaultFilePath = "G:\\log"
        luns            = [1]
      }

      sqlTempDbSettings = {
        defaultFilePath = "H:\\tempdb"
        luns            = [2]
      }
    }

    autoPatchingSettings = {
      enable                        = true
      dayOfWeek                     = "Sunday"
      maintenanceWindowDuration     = 60
      maintenanceWindowStartingHour = 2
      additionalVmPatch             = "MicrosoftUpdate"
    }

    assessmentSettings = {
      enable         = true
      runImmediately = true
      schedule = {
        dayOfWeek      = "Sunday"
        enable         = true
        startTime      = "20:00"
        weeklyInterval = 1
      }
    }

  }

  update_settings = {
    serverConfigurationsManagementSettings = {
      azureAdAuthenticationSettings = {
        clientId = ""
      }
    }

    keyVaultCredentialSettings = {
      enable                 = true
      azureKeyVaultUrl       = ""
      credentialName         = "credential-vm-test-001"
      servicePrincipalName   = "vm-test-001"
      servicePrincipalSecret = "vm-test-001-password"
    }
  }
}
