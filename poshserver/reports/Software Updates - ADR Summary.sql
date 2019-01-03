SELECT DISTINCT 
    AutoDeploymentID,
    Name as RuleName,
    Description,
    AutoDeploymentEnabled,
    LastRunTime 
FROM 
    vSMS_AutoDeployments