SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCAHorasAgendaAse] @codusuario varchar(15), @fecha smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

--declare @codusuario varchar(15)
--declare @fecha datetime

create table #tbAux
(
	hora			datetime,
	horafin		datetime,
	titulo    varchar(200),
	descripcion varchar(200)
)

insert #tbAux
SELECT hora,horafin,titulo,descripcion
FROM tCsCaSegAgenda 
where codusuario=@codusuario and fecha=@fecha
--and estado=1 
order by hora 

declare @i int
set  @i = 8

WHILE @i < 20
BEGIN
   declare @hora varchar(10)
   set @hora = replicate('0',2-len(cast(@i as varchar(2)))) + cast(@i as varchar(2)) + ':00:00'
   IF (select count(*) from #tbAux where hora=cast(@hora as datetime)) = 0
      begin
        insert #tbAux (hora)
        values (replicate('0',2-len(cast(@i as varchar(2)))) +cast(@i as varchar(2))+ ':00:00')
      end
   set @i = @i + 1
END

select * from #tbAux order by hora
drop table #tbAux


END
GO