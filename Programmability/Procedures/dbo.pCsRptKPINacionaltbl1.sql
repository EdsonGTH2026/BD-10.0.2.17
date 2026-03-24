SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsRptKPINacionaltbl1] @fecha smalldatetime
as   
set nocount on 

--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

--Tabla con los porcentajes

declare @imorBase table ( region varchar(30)
						,Imor1 money
						,Imor8 money
						,Imor16 money
						,Imor30 money
						,Imor31 money
						,Imor90 money)
insert into @imorBase						
select region,Imor1,Imor8,Imor16,Imor30,Imor31,Imor90
from fnmgconsolidado.dbo.tcareportekpi with(nolock)
where nomoficina='zz' and fecha=@fecha and region<>'Pro exito'
union
--TABLA PARA CALCULAR LOS TOTALES
select  'zTOTAL',(sum(case when c.nrodiasatraso>=1 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor1  
,(sum(case when c.nrodiasatraso>=8 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor8  
,(sum(case when c.nrodiasatraso>=16 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor16 
,(sum(case when c.nrodiasatraso>=30 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor30
,(sum(case when c.nrodiasatraso>=31 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor31 
,(sum(case when c.nrodiasatraso>=90 then i.saldocapital else 0 end)/sum(i.saldocapital))*100 Imor90
from tcscartera c with(nolock)
inner join tcscarteradet i with(nolock) on c.fecha=i.fecha and c.codprestamo=i.codprestamo 
inner join tcloficinas o on o.codoficina=c.codoficina
where c.fecha=@fecha 
and  cartera='ACTIVA' and c.codprestamo not in(select codprestamo from tCsCarteraAlta with(nolock)) 
and c.codoficina <>'501' and o.tipo <>'cerrada' 

--TABLA CON EL MONTO COLOCADO y METAS DE COLOCACION
declare @montoskpi table(zona varchar(30),colocado money,meta money)
insert into @montoskpi
select region,montoentrega,montocolocacion
from fnmgconsolidado.dbo.tcareportekpi with(nolock)
where nomoficina='zz' and fecha=@fecha and region<>'Pro exito'


declare @metabase table(region varchar(30),colocado money,metaColocacion money,PorAlcance money)
insert into @metabase
select zona region,sum(colocado) colocado,sum(meta) metaColocacion
,case when isnull(sum(meta),0)=0 then 0 else (sum(colocado)/sum(meta))*100 end PorAlcance
from @montoskpi  group by zona
union
select 'zTOTAL',sum(colocado),sum(meta),case when isnull(sum(meta),0)=0 then 0 else (sum(colocado)/sum(meta))*100 end PorAlcance
from @montoskpi


select i.*,colocado,metacolocacion,porAlcance 
from @imorBase i
inner join @metabase me on me.region=i.region
GO