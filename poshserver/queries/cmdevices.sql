SELECT DISTINCT 
    dbo.v_R_System.ResourceID, 
    dbo.v_R_System.Name0 AS Name, 
    dbo.v_R_System.AD_Site_Name0 AS ADSiteName, 
    dbo.vWorkstationStatus.LastHardwareScan, 
    dbo.vWorkstationStatus.LastDDR, 
    dbo.vWorkstationStatus.LastPolicyRequest, 
    dbo.vWorkstationStatus.LastMPServerName, 
    dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OSName, 
    dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 AS OSBuild, 
    dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 AS Manufacturer, 
    dbo.v_GS_COMPUTER_SYSTEM.Model0 AS Model, 
    dbo.v_GS_COMPUTER_SYSTEM.TotalPhysicalMemory0 AS TotalMemory, 
    dbo.v_GS_PROCESSOR.Name0 AS Processor, 
    dbo.v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 AS ChassisType, 
    dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0 AS SerialNumber
FROM 
    dbo.v_R_System LEFT OUTER JOIN
    dbo.v_GS_SYSTEM_ENCLOSURE ON 
    dbo.v_R_System.ResourceID = dbo.v_GS_SYSTEM_ENCLOSURE.ResourceID LEFT OUTER JOIN
    dbo.v_GS_PROCESSOR ON 
    dbo.v_R_System.ResourceID = dbo.v_GS_PROCESSOR.ResourceID LEFT OUTER JOIN
    dbo.v_GS_COMPUTER_SYSTEM ON 
    dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID LEFT OUTER JOIN
    dbo.v_GS_OPERATING_SYSTEM ON 
    dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID LEFT OUTER JOIN
    dbo.vWorkstationStatus ON 
    dbo.v_R_System.ResourceID = dbo.vWorkstationStatus.ResourceID