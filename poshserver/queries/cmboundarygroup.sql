SELECT 
    [Name] as BGName,
    DefaultSiteCode,
    GroupID,
    GroupGUID,
    [Description],
    Flags,
    CreatedBy,
    CreatedOn,
    ModifiedBy,
    ModifiedOn,
    MemberCount,
    SiteSystemCount,
    case 
        when (Shared = 1) then 'Yes'
        else 'No' end as Shared
FROM vSMS_BoundaryGroup