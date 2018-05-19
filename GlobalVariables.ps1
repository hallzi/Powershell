# Set Baseline services
$global:BaselineServices = (
  "DNS",
  "DHCP",
  "Certificate Authority",
  "RMS",
  "Domain Controller (New Domain)",
  "Domain Controller (Existing Domain)",
  "ADFS",
  "IIS",
  "Fileserver (Standalone)",
  "Filesserver (DFS)",
  "Fileserver (iSCSI)",
  "Hyper-V",
  "NPS",
  "Print",
  "WDS",
  "WSUS",
  "RD Session Broker",
  "RD Gateway",
  "RD Web Access",
  "RD Session Host",
  "RD License",
  "RD Standalone",
  "Failover Clustering",
  "SQL",
  "Citrix Gateway",
  "Citrix Session Host"
 )

 $global:DNSService = "DNS"

$global:BLServices = @(
    [pscustomobject]@{name="DNS";FeatureName="DNS"},
    [pscustomobject]@{name="DHCP";FeatureName="DHCP"},
    [pscustomobject]@{name="Certificate Authority";FeatureName="AD-Certificate"},
    [pscustomobject]@{name="RMS";FeatureName="ADRMS"},
    [pscustomobject]@{name="Domain Controller (New Domain)";FeatureName="AD-Domain-Services"},
    [pscustomobject]@{name="Domain Controller (Existing Domain)";FeatureName="AD-Domain-Services"},
    [pscustomobject]@{name="ADFS";FeatureName="ADFS-Federation"},
    [pscustomobject]@{name="IIS";FeatureName="Web-Server"},
    [pscustomobject]@{name="Fileserver Basic";FeatureName="FS-Fileserver"},
    [pscustomobject]@{name="Fileserver DFS";FeatureName="FS-DFS-Namespace"},
    [pscustomobject]@{name="Fileserver iSCSI";FeatureName="FS-iSCSITarget-Server"},
    [pscustomobject]@{name="Hyper-V";FeatureName="Hyper-V"},
    [pscustomobject]@{name="NPS";FeatureName="NPAS"},
    [pscustomobject]@{name="Printserver";FeatureName="Print-Server"},
    [pscustomobject]@{name="Windows Deployment Services";FeatureName="WDS"},
    [pscustomobject]@{name="WSUS";FeatureName="UpdateServices"},
    [pscustomobject]@{name="RDS Connection Broker";FeatureName="RDS-Connection-Broker"},
    [pscustomobject]@{name="RDS Gateway";FeatureName="DNS"},
    [pscustomobject]@{name="RDS Web Access";FeatureName="DNS"},
    [pscustomobject]@{name="RDS Session Host";FeatureName="DNS"},
    [pscustomobject]@{name="RDS Licensing";FeatureName="DNS"},
    [pscustomobject]@{name="RDS Basic";FeatureName="DNS"},
    [pscustomobject]@{name="Failover Clustering";FeatureName="DNS"}

)