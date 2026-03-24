SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pcsIntCobradoCartaGte] @fecha smalldatetime

as
set nocount on 

--declare @fecha smalldatetime
--select @fecha='20221219' --from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes

create table  #Coa (
          fecha smalldatetime,
          codprestamo varchar(25),
          interes money,
          dias int,fehaCa smalldatetime)
insert into #Coa
select d.fecha, codigocuenta,montointerestran interes,nrodiasatraso dias,c.fecha
from tcstransacciondiaria d with(nolock)
left outer  join tcscartera c with(nolock) on (c.fecha-1)=d.fecha and c.codprestamo=d.codigocuenta 
where  d.fecha>=@fecini and d.fecha<@fecha
and d.codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
and d.codoficina not in('97','231','230','999')

declare @consulta smalldatetime
select @consulta=fechaconsolidacion from vcsfechaconsolidacion


if @consulta = @fecha
 begin
  insert into #Coa
  select d.fecha, codigocuenta,montointerestran interes,c.diasmora, d.fecha
  from tcstransacciondiaria d with(nolock)
  left outer  join [10.0.2.14].finmas.dbo.tcaprestamos c  on  c.codprestamo=d.codigocuenta 
  where d.fecha=@fecha
  and d.codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
  and d.codoficina not in('97','231','230','999')
 end
else
 begin
  insert into #Coa
  select d.fecha, codigocuenta,montointerestran interes,nrodiasatraso dias,c.fecha
  from tcstransacciondiaria d with(nolock)
  left outer  join tcscartera c with(nolock) on (c.fecha-1)=d.fecha and c.codprestamo=d.codigocuenta 
  where  d.fecha=@fecha
  and d.codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
  and d.codoficina not in('97','231','230','999')
 end


select fecha,codprestamo,interes ,case when dias is null then 0 else dias end dias
into #co2a        
from #coa
where isnull(dias,0) <= 30
 

declare @Caa table(codprestamo varchar(25),Codoficina varchar(4))
insert into @Caa
select p.codprestamo, p.CodOficina
from tcspadroncarteradet p with(nolock)
where p.codprestamo in(select distinct codprestamo from #co2a)


--declare @inteCobrados table(fecha smalldatetime
--							,codoficina varchar(3)
--							,interesCobrado money) 
--insert into @inteCobrados
select t.fecha,c.codoficina,sum(interes) interes
from #Co2a t
inner join @Caa c on t.codprestamo=c.codprestamo
inner join tcloficinas j with(nolock) on j.codoficina=c.codoficina
group by t.fecha,
c.codoficina


drop table #Coa
drop table #co2a	
GO