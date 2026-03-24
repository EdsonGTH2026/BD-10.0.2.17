SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBICumplimientoPromotores] 
as 
    
  declare @fecha smalldatetime  
select @fecha =fechaconsolidacion from vcsfechaconsolidacion  
  
declare @inimes smalldatetime  
select @inimes=dateadd(day,((-1)*day(@fecha)),@fecha)  
  
declare @act smalldatetime  
select @act=dateadd(day,1,@inimes)  
  
declare @tot smalldatetime  
select @tot =dateadd(day,1,@inimes)  
  
  
  
declare @ultimodia smalldatetime  
select @ultimodia = (select ultimodia from tclperiodo with(nolock) where primerdia=dateadd(day,1,@inimes) and ultimodia>=@fecha) 

declare @primerdia smalldatetime
select @primerdia = (select primerdia from tclperiodo with(nolock) where primerdia<=@fecha and ultimodia>=@fecha) 
  
declare @actual table(actual smalldatetime)  
while(@act<=@Fecha)  
begin  
          if(datepart(weekday,@act) not in (1,7))  
          begin  
                    declare @x int  
                    select @x=count(*) from tcaclfechasnoven with(nolock) where fechanoven=@act  
                    if (@x=0)  
                    begin  
                              insert into @actual  
                              select @act  
                    end   
          end  
          set @act=@act+1  
end  
  
declare @dha integer  
select @dha=count(*)  
from @actual  
  
declare @final table(final smalldatetime)  
while(@tot<=@ultimodia)  
begin  
            
          if(datepart(weekday,@tot) not in (1,7))  
          begin  
                    declare @y int  
                    select @y=count(*) from tcaclfechasnoven with(nolock) where fechanoven=@tot  
                    if (@y=0)  
                    begin  
                              insert into @final  
                              select @tot  
                    end   
          end  
          set @tot=@tot+1  
end  
  
declare @dht integer  
select @dht=count(*)  
from @final  

		CREATE TABLE #cancelaciones 
		(ultimoasesor varchar(200)
		,codusuario varchar(200)
		,codprestamo varchar(200))
		
		INSERT INTO #Cancelaciones
		
		select cd.ultimoasesor,cd.codusuario, cd.codprestamo from tcspadroncarteradet cd with(nolock)  
		where cd.cancelacion > @inimes and cd.cancelacion <= @fecha
		
		CREATE TABLE #Renovaciones
		( ultimoasesor varchar(200)
		  ,cancelados varchar(200)
		  ,codprestamo varchar(200)
		  ,renovados varchar(200))
		  
		  INSERT INTO #Renovaciones
		  
		  select c.ultimoasesor, c.codprestamo, pcd.codprestamo ,case when isnull(pcd.codprestamo,'a')='a' then 'No renovado' else 'Renovado' end Renovados
		  from #cancelaciones c
		  left outer join tcspadroncarteradet pcd with(nolock) on c.codusuario=pcd.codusuario and pcd.desembolso>@inimes and pcd.desembolso<=@fecha

		CREATE TABLE #Rencan
		( codasesor varchar(50)
		,cancelaciones money
		,renovaciones money)
		INSERT INTO #Rencan
		select r.ultimoasesor,count(r.cancelados) cancelaciones, sum(case when r.renovados = 'Renovado' then 1 else 0 end) Renovaciones from #renovaciones r
		group by r.ultimoasesor
  
  create table #ptmos (codprestamo varchar(25))  
insert into #ptmos  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@fecha   
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta)  

  create table #ptmosini (codprestamo varchar(25))  
insert into #ptmosini  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@inimes   
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta)
  
create table #Actual  
( Sucursal varchar (200)  
 ,Oficina varchar(5)  
 ,Region varchar(200)  
 ,SaldoTotal money  
 ,codasesor varchar(50)  
 ,Promotor varchar(200)  
 ,D0a7saldo money  
 ,D8a30saldo money  
 ,D30saldo money
 ,Ingreso smalldatetime)  
   
 Insert into #Actual  
    
  SELECT   
  o.nomoficina Sucursal  
  ,o.codoficina Oficina  
  ,z.nombre Region  
  ,sum(cd.saldocapital) SaldoTotal  
  ,c.CodAsesor  
  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end promotor  
  ,sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end else 0 end) D0a7saldo  
  ,sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>7 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end) D8a30saldo  
  , sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>30 then cd.saldocapital else 0 end else 0 end) D30saldo  
  , emp.ingreso Ingreso
    
    FROM tCsCartera c with(nolock)  
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
  inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
  inner join tclzona z on z.zona=o.zona  
  inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario=c.CodAsesor  
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha  
  left outer join tcsempleados emp with(nolock) on c.codasesor = emp.codusuario 
  where c.fecha=@fecha  
  and c.codprestamo in(select codprestamo from #ptmos)  
group by c.codasesor ,o.nomoficina, o.codoficina, z.nombre  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end   , emp.ingreso
  
create table #Inicio(  
 codasesor varchar(50)  
 ,D0a30saldo money  
 ,D31saldo money)  
   
 Insert into #Inicio  
    
  SELECT   
   c.CodAsesor  
  ,sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end) D0a30saldo  
  ,sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end else 0 end) D31saldo  
    
    FROM tCsCartera c with(nolock)  
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
  inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
  inner join tclzona z on z.zona=o.zona  
  inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario=c.CodAsesor  
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@inimes  
  where c.fecha=@inimes  
  and c.codprestamo in(select codprestamo from #ptmosini)  
  group by c.codasesor  
  
create table #Desembolso  
( region varchar(25)  
  ,sucursal varchar(25)  
  ,promotor varchar(50)  
  ,montodesembolsado money  
  ,nroprestamos money  
  ,semana1 integer
  ,semana2 integer
  ,semana3 integer
  ,semana4 integer
  ,estatus varchar(25)  
  ,puesto varchar(25)  
  ,Nuevos money  )
  --,Reactivaciones money  
  --,Renovaciones money)  
    
insert into #Desembolso  
  
select z.Nombre region, o.NomOficina sucursal, co.NombreCompleto promotor  
, sum(p.Monto) montoDesembolsado, count(p.CodPrestamo) nroprestamos
,sum(case when p.desembolso <='20200408' then 1 else 0 end) semana1 
,sum(case when p.desembolso >'20200408' and p.desembolso <='20200415' then 1 else 0 end) semana2
,sum(case when p.desembolso <='20200424' and p.desembolso > '20200414' then 1 else 0 end) semana3
,sum(case when p.desembolso <='20200430' and p.desembolso > '20200424' then 1 else 0 end) semana4
,case when e.CodPuesto is null  then 'BAJA' else 'ACTIVO' end estatus  
,case when e.CodPuesto is null  then 'BAJA' when e.CodPuesto='66' then 'PROMOTOR' else 'OTRO' end puesto  
,sum(case when isnull(p.cancelacionanterior,0)= 0 then 1  
 else 0 end) Nuevos  
 --,sum(case when isnull (p.cancelacionanterior,0) = 0 then 0 else case when p.cancelacionanterior<= @inimes then 1 end end ) Reactivaciones  
 --,sum(case when isnull (p.cancelacionanterior,0) = 0 then 0 else case when p.cancelacionanterior> @inimes then 1 end end ) Renovaciones
  
  
from tcspadroncarteradet p with(nolock)  
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina  
inner join tclzona z with(nolock) on z.zona=o.zona  
left outer join tcspadronclientes co with(nolock) on co.codusuario=p.primerasesor   
left outer join tCsempleadosfecha e with(nolock) on e.CodUsuario=p.PrimerAsesor and e.Fecha=@fecha--@fecfin  
where p.Desembolso>@inimes and p.Desembolso<=@fecha   
 and p.CodOficina<>97 and (p.tiporeprog<>'REEST' or p.tiporeprog is null)   
 group by co.nombrecompleto,o.nomoficina,z.nombre,case when e.CodPuesto is null  then 'BAJA' else 'ACTIVO' end  
 ,case when e.CodPuesto is null  then 'BAJA' when e.CodPuesto='66' then 'PROMOTOR' else 'OTRO' end  
   
 Create table #Bono  
 (promotor varchar(200)  
 ,objetivo integer  
 ,bono money  
 ,desembolsos integer  
 ,PorcRen money)  
   
 Insert into #bono  
   
 select a.Promotor  
 --,(a.D0a7saldo/a.SaldoTotal) Porc0a7  
 --,isnull(i.d0a30saldo,0) saldo0a30  
 ,case when isnull(i.d0a30saldo,0)>2000000 then 80   
 when isnull(i.d0a30saldo,0)>1500000 then 72  
 when isnull(i.d0a30saldo,0)>1200000 then 60  
 when isnull(i.d0a30saldo,0)>900000 then 52  
 when isnull(i.d0a30saldo,0)>600000 then 40  
 when isnull(i.d0a30saldo,0)>300000 then 32  
 else 20 end Objetivo  
  ,case when isnull(i.d0a30saldo,0)>2500000 then 18000   
 when isnull(i.d0a30saldo,0)>2000000 then 15000  
 when isnull(i.d0a30saldo,0)>1500000 then 12000  
 when isnull(i.d0a30saldo,0)>1200000 then 8500  
 when isnull(i.d0a30saldo,0)>900000 then 5500  
 when isnull(i.d0a30saldo,0)>600000 then 2500  
 when isnull(i.d0a30saldo,0)>300000 then 1500  
 else 1000 end Bono  
 ,isnull(d.nroprestamos,0) Desembolsos  
 ,case when isnull(d.nroprestamos,0) = 0 then 0  
 when isnull(rc.cancelaciones,0)=0 then 1  
 else (isnull(rc.renovaciones,0)/rc.cancelaciones) end PorRen  
    
 from #Actual a with(nolock)  
 left outer join #Inicio i on a.codasesor=i.codasesor  
 left outer join #desembolso d on a.promotor = d.promotor 
 left outer join #rencan rc on a.codasesor = rc.codasesor 
 where a.promotor <> 'Huerfano'  
   
 create table #bonocol  
(promotor varchar(200)  
,porccoloc money  
,porcbonocol money)  
  
insert into #bonocol  
select promotor  
,(convert(money,desembolsos))/objetivo porccoloc  
,case when (convert(money,desembolsos))/objetivo >= 1.3 then 1.25  
when (convert(money,desembolsos))/objetivo >= 1.0 then 1.1  
when (convert(money,desembolsos))/objetivo >= 0.9 then 1.0  
when (convert(money,desembolsos))/objetivo >= 0.8 then 0.9  
when (convert(money,desembolsos))/objetivo >= 0.7 then 0.6  
else 0.0 end PorcBonoCol  
from #bono  
  
 create table #bonocal  
(promotor varchar(200)  
,porc0a7 money  
,porcbonocal money)  
  
insert into #bonocal  
  
select a.promotor, (a.D0a7saldo/a.SaldoTotal) Porc0a7  
,case when (a.D0a7saldo/a.SaldoTotal) >= 0.98 then 1.30  
 when (a.D0a7saldo/a.SaldoTotal) >= 0.96 then 1.20  
 when (a.D0a7saldo/a.SaldoTotal) >= 0.94 then 1.0  
 when (a.D0a7saldo/a.SaldoTotal) >= 0.92 then 0.80  
 when (a.D0a7saldo/a.SaldoTotal) >= 0.90 then 0.50  
 else 0.0 end PorcBonoCal  
 from #Actual a with(nolock)  
 where a.promotor <> 'Huerfano'  
   
  create table #bonoren  
(promotor varchar(200)  
,nroprestamos money   
,porcbonoren money)  
  
insert into #bonoren  
   
 select d.promotor, d.nroprestamos    
  ,case when b.porcren>=0.90 then 1.10  
   when b.porcren>=0.80 then 1.00  
   when b.porcren>=0.70 then 0.90  
   when b.porcren>=0.50 then 0.70  
   else 0.0 end Porcbonoren  
 from #desembolso d   
 left outer join #Bono b with(nolock) on d.promotor=b.promotor  
   
 select distinct a.promotor,a.ingreso, a.sucursal, a.region, b.objetivo/4 objetivo,  
 convert(int,((convert(money,b.objetivo)/@dht)*@dha)) ObjAlDia  
 ,b.bono,b.desembolsos,isnull(ini.d0a30saldo,0) VigIni, isnull(ini.d31saldo,0) VenIni  
 , a.d30saldo VenAct, (a.d0a7saldo + a.d8a30saldo) VigAct  
 , isnull(dm.nuevos,0) NUEVOS, isnull(rc.renovaciones,0) Renovaciones, isnull(rc.cancelaciones,0) Cancelaciones
 , bc.porccoloc,bc.porcbonocol,bca.porc0a7,bca.porcbonocal,b.porcren, isnull(br.porcbonoren,0) Porcbonoren  
 ,(b.bono*bc.porcbonocol*bca.porcbonocal*(isnull(br.porcbonoren,0))) BonoGanado
 , ((convert(money,(isnull(b.desembolsos,0))))/(Convert(money,@dha))) Productividad
 , case when datediff(month,a.ingreso,@primerdia)>= 12 then 'e.12+m'
        when datediff(month,a.ingreso,@primerdia)>= 9 then 'd.9-12m'
        when datediff(month,a.ingreso,@primerdia)>= 6 then 'c.6-9m'
        when datediff(month,a.ingreso,@primerdia)>= 3 then 'b.3-6m'
        else 'a.0-3m' end Antiguedad
 ,isnull(dm.semana1,0) semana1
 , isnull(dm.semana2,0) semana2
 ,isnull(dm.semana3,0) semana3 
 ,isnull(dm.semana4,0) semana4 
  from #Actual a   
 left outer join #bono b on a.promotor=b.promotor   
 left outer join #bonocol bc on a.promotor=bc.promotor  
 left outer join #bonocal bca on a.promotor=bca.promotor  
 left outer join #bonoren br on a.promotor=br.promotor  
 left outer join #desembolso dm on a.promotor =dm.promotor  
 left outer join #inicio ini on ini.codasesor=a.codasesor  
 left outer join #rencan rc on a.codasesor = rc.codasesor 
 where a.promotor <> 'Huerfano'  and a.promotor <> 'GARCIA JAIMES JAIME'
  
   
  drop table #ptmos  
  drop table #ptmosini  
  drop table #Actual  
  drop table #Inicio  
  drop table #desembolso  
  drop table #Bono  
  drop table #bonocol  
  drop table #bonocal  
  drop table #bonoren 
  drop table #cancelaciones
  drop table #Renovaciones
  drop table #RenCan
GO