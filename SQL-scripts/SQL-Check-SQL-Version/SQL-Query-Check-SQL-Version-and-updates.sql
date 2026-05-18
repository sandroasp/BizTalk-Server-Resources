-- =================================================================================================================
-- Author:		Sandro Pereira
-- Create date: 2026/05/06
-- Description:	SQL Server Query that checks SQL Server Version and Updates
-- =================================================================================================================

SELECT  
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('ProductVersion') AS Version,
    CASE 
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '8%'  THEN 'SQL Server 2000'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '9%'  THEN 'SQL Server 2005'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '10.0%' THEN 'SQL Server 2008'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '10.5%' THEN 'SQL Server 2008 R2'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '11%' THEN 'SQL Server 2012'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '12%' THEN 'SQL Server 2014'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '13%' THEN 'SQL Server 2016'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '14%' THEN 'SQL Server 2017'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '15%' THEN 'SQL Server 2019'
        WHEN CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(20)) LIKE '16%' THEN 'SQL Server 2022'
        ELSE 'Unknown'
    END AS SQLServerVersion,
	SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('ProductUpdateLevel') AS ProductUpdateLevel;

