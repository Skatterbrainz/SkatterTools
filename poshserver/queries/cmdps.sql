SELECT DISTINCT 
    DPID,
    ServerName as [DPName],
    [Description],
    SMSSiteCode,
    IsPXE,
    SccmPXE,
    RemoveWDS,
    DPType,
    [Type]
FROM 
    v_DistributionPoints