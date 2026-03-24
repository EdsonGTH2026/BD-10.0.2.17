SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCscosechaflujomiio]  
as    
declare @fechacosecha smalldatetime   --Tabla que contiene los meses de las cosechas a consultar 

select distinct(mescosecha) as 'mescosecha',0 as 'estado' 
into #tabmescosecha from tcsCierremesMiio where mescosecha>'20220601' --fecha de inicio 
order by mescosecha   --Tabla con la informacion final 

create table  #cosechaflujo (periodo varchar(15),saldo money,mescosecha varchar(15))--Definimos las variables para el ciclo  
Declare @contador as int 
set @contador = 1  

Declare @fin as int 
set @fin = (select count(*) from #tabmescosecha)  --Cilco para llenar la tabla 

while @contador<=@fin 
begin 
	set @fechacosecha= (select top 1 mescosecha from #tabmescosecha 
	where estado=0 order by mescosecha)  
	select  dbo.fdufechaaperiodo(fecha) periodo 
	,isnull(sum(SaldoCapital),0) as 'SaldoCapital' 
	,@fechacosecha as 'mescosecha' 
	into #primermes 
	from tcsCierremesMiio with(nolock) 
	where cer=1 and mescosecha=@fechacosecha 
	Group by dbo.fdufechaaperiodo(fecha) 
	order by dbo.fdufechaaperiodo(fecha) ASC  

	select  dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) periodo ,isnull(sum(SaldoCapital),0) as 'SaldoCapital' 
	into #segundomes 
	from tcsCierremesMiio with(nolock) 
	where cer=1 and mescosecha=@fechacosecha 
	Group by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) 
	order by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) ASC   

	insert into #cosechaflujo select a.periodo
	,cast(isnull(round(a.saldocapital-b.saldocapital,0),a.saldocapital) as int) as saldo
	,dbo.fdufechaaperiodo(a.mescosecha) 
	from #primermes a  with(nolock) 
	left outer join #segundomes b on b.periodo=a.periodo   

	drop table #primermes 
	drop table #segundomes 

	update #tabmescosecha 
	set estado=1 
	where mescosecha=@fechacosecha   

	set @contador = @contador+1  
end  

select * from #cosechaflujo where periodo<>'202210'   

drop table #tabmescosecha 
drop table #cosechaflujo  
GO