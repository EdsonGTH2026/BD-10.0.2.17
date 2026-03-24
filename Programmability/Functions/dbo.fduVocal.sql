SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduVocal]( @cad varchar(50),@pos int)
RETURNS char(1) AS  
BEGIN 

--declare @cad varchar(50)
declare @res varchar(50)
declare @val int
--declare @pos int
--set @pos=2
--set @cad='URBIZAGASTEGUI'
set @cad=substring(@cad,@pos,50)

select @val=len(@cad)
while (@val<>0)
begin
  set @res=substring(@cad,1,1)
  if(@res in ('A','E','I','O','U','a','e','i','o','u'))
    begin
      break
    end
  set @cad=substring(@cad,2,50)
  set @val=@val-1
end

return (@res)

END
GO