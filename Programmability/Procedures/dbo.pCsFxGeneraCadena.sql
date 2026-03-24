SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsFxGeneraCadena] (	@sql varchar(200), @cad varchar(200) output) as

  --declare @sql varchar(200)
  create table #tmpof (nomoficina varchar(200))

  declare @s varchar(2000)
  set @s = ' insert into #tmpof '
  set @s = @s + @sql
  exec(@s)

  declare @nom varchar(100)
  --declare @cad varchar(200)
  set @cad=''

  DECLARE genxgrupo CURSOR FOR 
    select nomoficina from #tmpof
  OPEN genxgrupo 
  FETCH NEXT FROM genxgrupo 
  INTO @nom 
  WHILE @@FETCH_STATUS = 0 
  BEGIN 
  set @cad = @cad + ',' + @nom 
  FETCH NEXT FROM genxgrupo 
  INTO @nom 
  END 
  CLOSE genxgrupo 
  DEALLOCATE genxgrupo

  set @cad = substring(@cad,2,len(@cad))

  drop table #tmpof 
  
GO