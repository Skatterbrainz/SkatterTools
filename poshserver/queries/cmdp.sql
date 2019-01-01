SELECT 
	DPID,
	ServerName,
	Description,
	NALPath,
	ShareName,
	SMSSiteCode as SiteCode,
	case when (IsPXE=1) then 'Yes' else 'No' end as PXE,
	case when (SccmPXE=1) then 'Yes' else 'No' end as SCCMPXE,
	case when (IsActive=1) then 'Yes' else 'No' end as Active,
	case when (IsPeerDP=1) then 'Yes' else 'No' end as PeerDP,
	case when (IsPullDP=1) then 'Yes' else 'No' end as PullDP,
	case when (IsPullDPInstalled=1) then 'Yes' else 'No' end as PullDPInstalled,
	case when (IsFileStreaming=1) then 'Yes' else 'No' end as FileStreaming,
	case when (IsBITS=1) then 'Yes' else 'No' end as BITS,
	case when (IsMulticast=1) then 'Yes' else 'No' end as MultiCast,
	case when (IsProtected=1) then 'Yes' else 'No' end as Protected,
	RemoveWDS,
	case when (AnonymousEnabled=1) then 'Yes' else 'No' end as AnonEnabled,
	case when (TokenAuthEnabled=1) then 'Yes' else 'No' end as TokenAuth,
	case 
		when (SslState=0) then 'HTTP'
		when (SslState=1) then 'HTTPS'
		when (SslState=2) then 'N/A'
		when (SslState=3) then 'Always HTTPS'
		when (SslState=4) then 'Always HTTP'
		else 'Unknown' end as SSL,
	DPType,
	case when (PreStagingAllowed=1) then 'Yes' else 'No' end as PreStaging,
	DPDrive,
	MinFreeSpace,
	Type,
	Action,
	State,
	DPFlags,
	DPCRC,
	ResponseDelay,
	case 
		when (UdaSetting=0) then 'Disabled'
		when (UdaSetting=1) then 'Allow user device affinity with manual approval'
		when (UdaSetting=2) then 'Allow user device affinity woth automatic approval'
		end as UDA,
	case 
		when (BindPolicy=0) then 'Respond on All Network Interfaces'
		when (BindPolicy=1) then 'Respond on Specific Network Interfaces'
		end as BindPolicy,
	SupportUnknownMachines,
	IdentityGUID,
	BindExcept,
	case 
		when (CertificateType=0) then 'Self-Signed'
		else 'Imported' end as CertType,
	Account,
	Priority,
	TransferRate,
	ISVString,
	Flags,
	MaintenanceMode,
	RoleCapabilities
FROM 
	v_DistributionPoints