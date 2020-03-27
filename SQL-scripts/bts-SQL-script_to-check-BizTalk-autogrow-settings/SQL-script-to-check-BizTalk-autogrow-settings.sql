USE Master
GO

SELECT	DB_NAME(mf.database_id) AS 'Database Name', 
		CASE mf.type_desc 
			WHEN 'ROWS'	THEN 'DATA' 
						ELSE 'LOG'
		END AS [File Type], 
		CONVERT (DECIMAL (20,2), (CONVERT(DECIMAL, mf.size)/128)) [File Size (MB)], 
		CASE mf.is_percent_growth 
			WHEN 1	THEN 'Yes' 
					ELSE 'No'
		END AS [Autogrowth set in Percent], 
		CASE mf.is_percent_growth
			WHEN 1	THEN CONVERT(VARCHAR, mf.growth) + '%'
			WHEN 0	THEN CONVERT(VARCHAR, mf.growth/128) + ' MB'
		END AS [Autogrowth Increment of], 
		CASE mf.is_percent_growth
			WHEN 1	THEN CONVERT(DECIMAL(20,2), (((CONVERT(DECIMAL, size)*growth)/100)*8)/1024)
			WHEN 0	THEN CONVERT(DECIMAL(20,2), (CONVERT(DECIMAL, growth)/128))
		END AS [Next Growth Block (MB)], 
		CASE mf.max_size
			WHEN -1	THEN 'No maximum value defined (until disk is full)'
			WHEN 0 THEN 'Fixed size value (no growth allowed)'
					ELSE CONVERT(VARCHAR, mf.max_size)
		END AS [Max Growth Size]
FROM sys.master_files mf
WHERE DB_NAME(mf.database_id) like '%BizTalk%' 
	OR DB_NAME(mf.database_id) like '%SSO%'
	OR DB_NAME(mf.database_id) like '%BAM%'
ORDER BY DB_NAME(mf.database_id) 