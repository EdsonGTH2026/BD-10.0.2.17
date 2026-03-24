SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  User Defined Function dbo.SecDomicilios    Script Date: 08/03/2023 09:14:54 pm ******/
create function [dbo].[SecDomicilios] (@rfc varchar(15))
returns int
as
begin
  return (
    SELECT count(item) + 1 ultimo
    FROM tCCDomicilios
    where rfc=@rfc
  )
end
GO