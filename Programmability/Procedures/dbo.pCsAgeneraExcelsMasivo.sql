SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsAgeneraExcelsMasivo] @Nomarchivo varchar(100), @ExpSP varchar(700)
as

--declare @Nomarchivo varchar(100), @ExpSP varchar(200)
--set @Nomarchivo='CUM_PRUEBa'
--set @ExpSP ='pCsADatosxAsesorxSucursal ''''20130407'''',''''10'''''--'pCsCboOficinas'

declare @f varchar(2000)

set @f='SELECT * INTO ##TExD1 '
set @f=@f+'FROM OPENROWSET(''MSDASQL'', ''DRIVER={SQL Server};SERVER=10.0.2.17;UID=sa;PWD=$sql$2013'','
set @f=@f+'''SET FMTONLY OFF EXEC finamigoconsolidado.dbo.'+@ExpSP+' '')'
print @f
exec(@f)
--SELECT * INTO ##TExD1
--FROM OPENROWSET('MSDASQL', 'DRIVER={SQL Server};SERVER=10.0.1.17;UID=sa;PWD=$sql$',
--     'EXEC finamigoconsolidado.dbo.'+@ExpSP+' ')

--select * from ##TExD1
--drop table ##TExD1

declare @columnNames varchar(8000), @columnConvert varchar(8000), @sql varchar(8000)

SELECT    @columnNames = COALESCE( @columnNames  + ',', '') + column_name,
        @columnConvert = COALESCE( @columnConvert  + ',', '') + 'convert(nvarchar(4000),' 
        + column_name + case when data_type in ('datetime', 'smalldatetime') then ',121'
                             when data_type in ('numeric', 'decimal') then ',128'
                             when data_type in ('float', 'real', 'money', 'smallmoney') then ',2'
                             when data_type in ('datetime', 'smalldatetime') then ',120'
                             else ''
                        end + ') as ' + column_name
FROM    tempdb.INFORMATION_SCHEMA.Columns
WHERE    table_name = '##TExD1'
--print @columnNames
--print @columnConvert

SELECT    @sql = 'select ' + @columnNames + ' into ##TExD2 from (select ' + @columnConvert + ', ''2'' as [temp##SortID] 
       from ##TExD1 union all select ''' + replace(@columnNames, ',', ''', ''') + ''', ''1'') t order by [temp##SortID]'
--print @sql
exec (@sql)

--select * from ##TExD2
declare @cmd varchar(300)
set @cmd='bcp "Select * from [10.0.2.17].FinamigoConsolidado.dbo.##TExD2" '
set @cmd=@cmd+'queryout "C:\Reportes_eDN\Auto\'+@Nomarchivo+'.xls" -T -c -t\t  '
--set @cmd=@cmd+'queryout "\\10.0.1.9\RepAuto\'+@Nomarchivo+'.xls" -UAdmin -PFNMG$ADM_08 -c '
--Exec Master..xp_cmdshell 'bcp "Select * from [10.0.2.17].FinamigoConsolidado.dbo.##TExD2" queryout "C:\Reportes_eDN\Auto\'+@Nomarchivo+'.xls" -UAdmin -PFNMG$ADM_08 -c' 
Exec Master..xp_cmdshell @cmd

drop table ##TExD1
drop table ##TExD2

GO