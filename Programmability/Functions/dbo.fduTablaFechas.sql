SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduTablaFechas] (@periodo varchar(6))
RETURNS @dias table (dia smalldatetime)  AS  
BEGIN 

	--declare @periodo varchar(6)
	--set @periodo='201402'
	--declare @dias table (dia smalldatetime)
	
	declare @f smalldatetime
	declare @ud smalldatetime
	select @f=primerdia from tclperiodo where periodo=@periodo
	select @ud=ultimodia from tclperiodo where periodo=@periodo
	
	insert into @dias
	values (@f)
	  
	while @f<>@ud
	begin
	  set @f = dateadd(day,1,@f)
	  
	  insert into @dias
	  values (@f)  
	end
	
	--select * from @dias
	return
END
GO