SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsVFisicaCarteraActiva]
as
set nocount on   
---- Consulta la fecha de la ultima verificación de la cartera activa al corte.
---- ZCCU 2025.06

set nocount on
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion     

Create table #FechaHistorico (fechaHis smalldatetime)
insert into #FechaHistorico
select UltimoDia
from tClPeriodo where PrimerDia>='20250501'

--------------------------------------- PRESTAMOS
----select top 10* from tcsPadronclientes where codusuario like '%QGM900619F7920%' 
create table #ptmos (codprestamo varchar(25),codusuario varchar(25),CodOrigen varchar(25),codsolicitud varchar(25),codoficina varchar(25))
insert into #ptmos
select distinct c.codprestamo ,RTRIM(c.codusuario),RTRIM(cl.CodOrigen) ,c.codsolicitud,c.codoficina 
from tcscartera c with(nolock)
inner join tcsPadronclientes cl with(nolock) on cl.CodUsuario=c.codusuario
where c.fecha=@fecha 
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina not in('97','230','231','999')
and c.cartera='ACTIVA' 
and c.codprestamo not in ( 
'098-174-06-00-00001',
'098-174-06-00-00002',
'098-174-06-01-00003',
'098-174-06-02-00004'
)

select RTRIM(s.codusuario)codusuario, max(isnull(sv.FechaUltVerificacion,sv.fechaHora))FechaUltVerificacion  --- ZCCU 28.02.2024}
into #ultimaVF 
from [10.0.2.14].[Finmas].[dbo].[tCaSolicitud] s   
left outer join [10.0.2.14].[Finmas].[dbo].[tCaSolicitudVisita] sv on sv.codsolicitud = s.codsolicitud and sv.codoficina = s.codoficina  
where s.codusuario in (select RTRIM(CodOrigen) from #ptmos  with(nolock)) 
and s.codestado not in('TRAMITE','ANULADO')  
group by s.codusuario

/*
select * from #ultimaVF
where codusuario like '%QGM900619F7920%' 

*/

delete from [FNMGConsolidado].[dbo].[tCsCaAcVerificacion]
where fecha not in (select fechaHis from #FechaHistorico  with(nolock))

delete from [FNMGConsolidado].[dbo].[tCsCaAcVerificacion] where fecha =@fecha

insert into [FNMGConsolidado].[dbo].[tCsCaAcVerificacion]
select @fecha Fecha,p.codoficina,P.codusuario,vf.fechaUltVerificacion FechaUltVerificacion,P.codsolicitud,p.codprestamo--* 
from #ptmos p  with(nolock)
left outer join #ultimaVF VF on VF.CodUsuario=P.CodOrigen

drop table #ultimaVF
drop table #ptmos
drop table #FechaHistorico

-----select count(*) from [FNMGConsolidado].[dbo].[tCsCaAcVerificacion] where fecha='20250701'
-----select count(*),FECHA from [FNMGConsolidado].[dbo].[tCsCaAcVerificacion] GROUP BY FECHA


GO