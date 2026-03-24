SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsSMSSolicitudes
--drop procedure [pCsSMSSolicitudes]
CREATE procedure [dbo].[pCsSMSSolicitudes]
as
Declare @Fecha 		SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

SELECT p.codsolicitud,p.codoficina
,p.estado codestadoactual
,case when p.estado = 1 then 'Solicitado Preliminar'
		when p.estado in(2,21,22) then 'Solicitado'
		when p.estado = 3 then 'Credito'
		--when p.estado = 21 then 'Solicitado - Lider'
		when p.estado = 24 then 'Solicitado - Regional'
		when p.estado = 4 then 'Mesa de Control'
		--when p.estado = 22 then 'Solicitado - Lider'
		when p.estado = 5 then 'Aceptado - Lider'
		when p.estado = 11 then 'Cancelado'
		when p.estado = 23 then 'Solicitado - Regional'
		when p.estado = 31 then 'Credito'
		when p.estado = 6 then 'Fondeo'
		when p.estado = 7 then 'Entrega'
		when p.estado = 8 then 'Préstamo Entregado'
		when p.estado = 9 then 'Revisión de expediente'
		when p.estado = 10 then 'Expediente completo'
		when p.estado = 12 then 'Regional'
		when p.estado = 61 then 'Fondeo Progresemos'
		else 'No definido' end estadoactual
,case when datediff(day,p.fechahora,(@Fecha+1))<15 then 1 else 0 end Menor15
,case when datediff(day,p.fechahora,(@Fecha+1))>=15 then 1 else 0 end Mayor15
,s.montoaprobado
into #sol
FROM [10.0.2.14].finmas.dbo.tCaSolicitudProce p --with(nolock)
inner join [10.0.2.14].finmas.dbo.tcasolicitud s --with(nolock) 
on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina and s.codproducto=p.codproducto
where p.estado in (3,4,24,23,21,22,31,6,61,7,5,1,2)

create table #sol2(
	i int identity(1,1) not null,
	Estado varchar(30),
	Menor15 int,
	Mayor15 int,
	Monto money
)
insert into #sol2 (estado,menor15,mayor15,monto)
select estadoactual,menor15,mayor15,montoaprobado
from (
select case when estadoactual='Solicitado - regional' then 1
			when estadoactual='Credito' then 2
			when estadoactual='Mesa de Control' then 3
			when estadoactual='Aceptado - Lider' then 4
			when estadoactual='Fondeo' then 5
			when estadoactual='Fondeo progresemos' then 6
			when estadoactual='Entrega' then 7
			else 8 end orden
,estadoactual,sum(Menor15) Menor15,sum(Mayor15) Mayor15,sum(montoaprobado) montoaprobado
from #sol
group by estadoactual
) a 
order by orden

declare @c varchar(1000)

declare @count int
declare @sec int
--select * from #sol2
select @count=count(*) from #sol2
set @sec=1

declare @estado varchar(30)
declare @menor int
declare @mayor int
declare @monto money

set @c='<table width=''400px'' style=''font-family: Arial;font-weight:bold; font-size: 10px;''><tr style=''font-weight: bold;''><td>Estado</td><td>#Menor15</td><td>#Mayor15</td><td>Monto</td><tr>'

while (@sec<>@count+1)
begin
	select @estado=estado,@menor=menor15,@mayor=mayor15,@monto=monto from #sol2 where i=@sec
		
	set @c=@c+'<tr>'
	set @c=@c+'<td>'+@estado+'</td>'
	set @c=@c+'<td>'+ltrim(rtrim(str(@menor)))+'</td>'
	set @c=@c+'<td>'+ltrim(rtrim(str(@mayor)))+'</td>'
	--set @c=@c+'<td>'+ltrim(rtrim(str(@monto,16,2)))+'</td>'
	set @c=@c+'<td>'+ltrim(rtrim(CONVERT(VARCHAR(50),CAST(@monto AS MONEY),1)))+'</td>'
	 
	set @c=@c+'</tr>'

	set @sec=@sec+1
end
set @c=@c+'</table>'

drop table #sol
drop table #sol2
--print @c

Declare @Sistema 		Varchar(2)
Declare @Celular		Varchar(50)
Declare @FechaSMS			Varchar(15)
Declare @Hora			Varchar(15)

Set @FechaSMS 	= dbo.FduFechaATexto(GetDate(), 'AAAA')+ dbo.FduFechaATexto(GetDate(), 'MM') + dbo.FduFechaATexto(GetDate(), 'DD')
Set @Hora	= CONVERT(VARCHAR(20), GETDATE(), 114)

Set @Celular 	= '5515325837'--'5538774833'
Set @Sistema 	= 'CI'

set @c='Solicitudes al día:'+dbo.fdufechaatexto(@Fecha+1,'DD/MM/AAAA')+'|'+@c
exec pSgInsertaEnColaServicio @Sistema,3,'maristav@finamigo.com.mx;grazoc@finamigo.com.mx,curbizagastegui@finamigo.com.mx',@FechaSMS,@Hora,@c
--exec pSgInsertaEnColaServicio @Sistema,3,'curbizagastegui@finamigo.com.mx',@FechaSMS,@Hora,@c

--exec pCsSMSSolicitudes

--Crédito
--Mesa de control
--Gerente Regional
--Aceptado
--Fondeo
--Fondeo Progresemos
--Entrega
GO

GRANT EXECUTE ON [dbo].[pCsSMSSolicitudes] TO [marista]
GO