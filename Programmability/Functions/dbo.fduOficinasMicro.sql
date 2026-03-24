SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduOficinasMicro] (@zona varchar(2))  
RETURNS varchar(2000) AS  
BEGIN 

--declare @zona varchar(2)
----set @zona  = 'Z01'
--set @zona  = '%'

DECLARE @cad varchar(2000) 
DECLARE @cod varchar(20) 

SELECT @cad= COALESCE( @cad  + ',', '')+CodOficina
FROM tcloficinas with(nolock) 
where (codoficina<=100 or codoficina>=300) 
and	(cast(codmicro as varchar(2)) like @zona)
and tipo<>'CERRADA'
and codoficina not in('99','97','98')

--SELECT @cad 
--print @cad 
return (@cad )

END
GO