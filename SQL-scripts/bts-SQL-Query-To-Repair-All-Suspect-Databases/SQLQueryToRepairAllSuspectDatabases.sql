DECLARE @MyCursor CURSOR;
DECLARE @MyField varchar(100);
DECLARE @SQLQuery AS NVARCHAR(500)
BEGIN
    SET @MyCursor = CURSOR FOR
		SELECT NAME FROM SYS.DATABASES 
		WHERE STATE_DESC='SUSPECT'      

    OPEN @MyCursor 
    FETCH NEXT FROM @MyCursor 
    INTO @MyField

    WHILE @@FETCH_STATUS = 0
    BEGIN
	    SET @SQLQuery = 'ALTER DATABASE [' + @MyField + '] SET EMERGENCY'
		EXECUTE sp_executesql @SQLQuery
		SET @SQLQuery = 'DBCC checkdb([' + @MyField + '])'
		EXECUTE sp_executesql @SQLQuery
		SET @SQLQuery = 'ALTER DATABASE [' + @MyField + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
		EXECUTE sp_executesql @SQLQuery
		SET @SQLQuery = 'DBCC CheckDB ([' + @MyField + '], REPAIR_ALLOW_DATA_LOSS)'
		EXECUTE sp_executesql @SQLQuery
		SET @SQLQuery = 'ALTER DATABASE [' + @MyField + '] SET MULTI_USER'
		EXECUTE sp_executesql @SQLQuery
      FETCH NEXT FROM @MyCursor 
      INTO @MyField 
    END; 

    CLOSE @MyCursor ;
    DEALLOCATE @MyCursor;
END;