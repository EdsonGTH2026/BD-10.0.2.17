SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext [pCsOpCaCubSucursalMov]

CREATE procedure [dbo].[pCsRegSPD] 
as
--set nocount on--off

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fefin smalldatetime
select @fefin=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
select @fecini=dateadd(day,(-1)*day(@fecha),@fecha) 


create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha<=@fefin and fecha >= @fecini
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)--> son clientes que no son de Finamigo

   select region
   ,sum(FECINI) FECINI 
   ,sum(FEFIN) FEFIN
   ,(sum(PROM)/ (datediff(d,@fecini,@fefin))) SPD
   ,(sum (FEFIN) - sum (FECINI)) CRECIMIENTO
   into #Cubeta
   from (
     SELECT pd.secuenciacliente, c.Fecha,cd.codusuario, c.CodPrestamo,o.nomoficina,z.nombre region, cd.saldocapital
            ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 and c.Fecha=@fefin then cd.saldocapital else 0 end FEFIN
             ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 and c.Fecha=@fecini then cd.saldocapital else 0 end FECINI    
             ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 and c.Fecha>@fecini and c.Fecha<=@fefin then cd.saldocapital else 0 end PROM        
      FROM tCsCartera c with(nolock)
         inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
         inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
         inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
         inner join tclzona z on z.zona=o.zona
      where c.fecha>=@fecini and c.fecha<=@fefin
         and c.codprestamo in(select codprestamo from #ptmos)     
   ) a
group by region


select * from #cubeta where region <> 'Zona Cerradas'



drop table #ptmos
drop table #cubeta

GO