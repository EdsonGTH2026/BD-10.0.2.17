SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  User Defined Function dbo.SecConsultas    Script Date: 08/03/2023 09:14:54 pm ******/
create function [dbo].[SecConsultas] (@rfc varchar(15))
returns int
as
begin
  return (
    SELECT count(item) + 1 ultimo
    FROM tCCConsultas
    where rfc=@rfc
  )
end
GO