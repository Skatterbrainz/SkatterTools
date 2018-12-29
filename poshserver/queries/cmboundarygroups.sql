SELECT DISTINCT 
    Name as BGName,
    GroupID,
    Description,
    Flags,
    DefaultSiteCode,
    CreatedOn,
    MemberCount as Boundaries,
    SiteSystemCount as SiteSystems
FROM vSMS_BoundaryGroup