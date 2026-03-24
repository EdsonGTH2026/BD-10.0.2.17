SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduOfixZona] ( @zona varchar(5)) 
RETURNS varchar(200) AS  
BEGIN 

declare @cod varchar(500)
set @cod=''
SELECT @cod = @cod+',' + rtrim(codoficina)
FROM tcloficinas
where zona=@zona 
--codoficina<100 and 

return( substring(@cod,2,len(@cod)))

END
GO