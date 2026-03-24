SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[spReindexaBD]
@Database varchar(400)
AS

DECLARE @Name varchar(255),
@Tabla varchar(255),
@avg_fragmentacion decimal(9,3),
@index_id integer,
@Command varchar(4000),
@Base integer
set @Base=DB_ID(@Database)
DECLARE reindex_cursor CURSOR FOR 
SELECT a.index_id, QUOTENAME(b.name), avg_fragmentation_in_percent,QUOTENAME(o.name)
FROM sys.dm_db_index_physical_stats (@Base, NULL, NULL, NULL, NULL) AS a
    JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id INNER JOIN sys.objects o
    ON o.object_id =a.object_id 
	order by 3 desc;

OPEN reindex_cursor;
FETCH NEXT FROM reindex_cursor 
INTO @index_id, @Name,@avg_fragmentacion,@Tabla;

WHILE @@FETCH_STATUS = 0
BEGIN
IF @avg_fragmentacion>=5 and @avg_fragmentacion<=30
	BEGIN
			SET @Command= N'ALTER INDEX ' + @Name + N' ON '  + @Tabla + N' REORGANIZE ';
			exec(@Command)
			PRINT @Command
	END
	
IF @avg_fragmentacion>=31 
	BEGIN
			SET @Command= N'ALTER INDEX ' + @Name + N' ON '  + @Tabla + N' REBUILD ';
			exec(@Command)
			PRINT @Command
	END	
	FETCH NEXT FROM reindex_cursor 
	INTO @index_id, @Name,@avg_fragmentacion,@Tabla;
		
END
CLOSE reindex_cursor;
DEALLOCATE reindex_cursor;
GO