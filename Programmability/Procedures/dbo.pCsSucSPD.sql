SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext [pCsOpCaCubSucursalMov]

CREATE procedure [dbo].[pCsSucSPD] @zona varchar(5)
as
--set nocount on--off

--declare @zona varchar(5)
--set @zona='Z1

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fefin smalldatetime
select @fefin=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
select @fecini=dateadd(day,(-1)*day(@fecha),@fecha) 

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codoficina
from tcloficinas
where zona=@zona

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha<=@fefin and fecha >= @fecini
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)--> son clientes que no son de Finamigo
and codoficina in(select codigo from @sucursales)

   select sucursal
   ,@FEFIN FECHA
   ,sum(FECINI) FECINI 
   ,sum(FEFIN) FEFIN
   ,(sum(PROM)/ (datediff(d,@fecini,@fefin))) SPD
   ,(sum (FEFIN) - sum (FECINI)) CRECIMIENTO
   into #Cubeta
   from (
     SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
            ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 and c.Fecha=@fefin then cd.saldocapital else 0 end FEFIN
             ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 and c.Fecha=@fecini then cd.saldocapital else 0 end FECINI    
             ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 and c.Fecha>@fecini and c.Fecha<=@fefin then cd.saldocapital else 0 end PROM        
     FROM tCsCartera c with(nolock)
     inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
     inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
     where c.fecha<=@fefin and c.fecha>=@fecini and c.cartera='ACTIVA'
     and c.codprestamo in(select codprestamo from #ptmos)       
   ) a

 group by sucursal
 order by sucursal


select * from #cubeta



drop table #ptmos
drop table #cubeta

GO