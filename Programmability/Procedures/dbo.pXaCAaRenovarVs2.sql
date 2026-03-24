SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----pXaCAaRenovarVs2_QA '308','LFA801001F17I1'
CREATE procedure [dbo].[pXaCAaRenovarVs2] @codoficina varchar(4),@codasesor varchar(15)
as
set nocount on
--declare @codoficina varchar(3)
--set @codoficina='301'
--declare @codasesor varchar(15)
--set @codasesor='DAA1009871     '
------select * from tcloficinas where nomoficina like '%omete%'
------select * from tcsempleados where nombres+' '+paterno+' '+materno like '%Angel Lorenzo%'
--select * from tsgusuarios where usuario='adorantesa'
--set @codasesor=null
--VER 04122020 BGMA AÑADIR VALIDACIÓN DE EXCEPCIONES
--VER 07122020 BGMA AÑADIR TIPO DE EXCEPCIÓN

declare @fecha smalldatetime
--set @fecha='20190507'
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
declare @fecfin smalldatetime

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'--'20190501'
set @fecfin=@fecha

--BGMA 04122020 VALIDACIÓN EXCEPCIONES
SELECT MAX(l.secuenciaCliente) AS ciclo ,e.codusuario
INTO #excepciones
FROM [10.0.2.14].finmas.dbo.tCaPoliticasExcepciones e
INNER JOIN tCsACaLIQUI_RR l
	ON l.codUsuario = e.codUsuario
WHERE convert(VARCHAR(8), e.fechaLimiteActualizacion, 112) = convert(VARCHAR(8), getDate(), 112)
AND idTipoExcepcion = 1
GROUP BY e.codUsuario
ORDER BY e.codUsuario

UPDATE tCsACaLIQUI_RR 
SET atrasomaximo = 30
FROM #excepciones e
INNER JOIN tCsACaLIQUI_RR l
	ON l.codUsuario = e.codUsuario
	AND l.secuenciaCliente = e.ciclo
-- ---

select s.codsolicitud,s.codusuario,s.fechadesembolso,s.montoaprobado--,case when a.codsolicitud is null then 0 else 1 end enapp
into #panel
from [10.0.2.14].finmas.dbo.tcasolicitud s
left outer join [10.0.2.14].finmas.dbo.tcasolicitudproce p on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina
where p.estado not in(9,10,11,70,71) and s.codoficina=@codoficina 
and s.codestado<>'ANULADO'

update #panel
set codusuario=p.codusuario
from tcspadronclientes p with(nolock) inner join #panel x on x.codusuario=p.codorigen

--select p.*,l.*
update tCsACaLIQUI_RR
--set estado=case when p.enapp=1 then 'En App' else 'En proceso' end,nuevomonto=p.montoaprobado,nuevodesembolso=p.fechadesembolso,codprestamonuevo=p.codsolicitud
set estado='En proceso',nuevomonto=p.montoaprobado,nuevodesembolso=p.fechadesembolso,codprestamonuevo=p.codsolicitud
from #panel p
inner join tCsACaLIQUI_RR l on l.codusuario=p.codusuario
where l.estado='Sin Renovar' and l.codoficina=@codoficina

/*Actualiza una solicitud anulada en liqr*/
--select l.*,p.*
update tCsACaLIQUI_RR
set estado='Sin Renovar',nuevomonto=null,nuevodesembolso=null,codprestamonuevo=null
from tCsACaLIQUI_RR l
left outer join #panel p on l.codusuario=p.codusuario
where l.estado='En proceso' and p.codusuario is null
and l.codoficina=@codoficina

--select l.*,p.*
update tCsACaLIQUI_RR
set estado='Sin Renovar',nuevomonto=null,nuevodesembolso=null,codprestamonuevo=null
from tCsACaLIQUI_RR l
left outer join #panel p on l.codusuario=p.codusuario
where l.estado not in('Reactivado','Renovado','Sin Renovar')--='En proceso' 
and p.codusuario is null
and l.codoficina=@codoficina


select s.codsolicitud,s.codoficina,s.codusuario,s.fechadesembolso,s.montoaprobado
into #panel2
from [10.0.2.14].finmas.dbo.tcasolicitud s
inner join [10.0.2.14].finmas.dbo.tCaSolicitudApp a on s.codsolicitud=a.codsolicitud and s.codoficina=a.codoficina
left outer join [10.0.2.14].finmas.dbo.tCaSolicitudproce p on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina
where s.codoficina=@codoficina and p.idproceso is null and s.codestado='TRAMITE'

update #panel2
set codusuario=p.codusuario
from tcspadronclientes p with(nolock) inner join #panel2 x on x.codusuario=p.codorigen

--select p.*,l.*
update tCsACaLIQUI_RR
set estado=case when p.codsolicitud is not null then 'En App' else estado end
	,nuevomonto=p.montoaprobado,nuevodesembolso=p.fechadesembolso,codprestamonuevo=p.codsolicitud
from tCsACaLIQUI_RR l
inner join #panel2 p on l.codusuario=p.codusuario
where l.estado='Sin Renovar' and l.codoficina=@codoficina

select case when l.codpromotor is not null then
			case when l.cancelacion>=@fecini and l.cancelacion<=@fecfin+1 then 'Renovaciones' else 'Reactivaciones' end 
	   else 
			case when datediff(month,l.cancelacion,@fecha)<=1 then 'Huerfano 0 a 1 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=2 and datediff(month,l.cancelacion,@fecha)<=3 then 'Huerfano 2 a 3 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=4 and datediff(month,l.cancelacion,@fecha)<=6 then 'Huerfano 4 a 6 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=7 and datediff(month,l.cancelacion,@fecha)<=9 then 'Huerfano 7 a 9 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=10 and datediff(month,l.cancelacion,@fecha)<=12 then 'Huerfano 10 a 12 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=13 then 'Huerfano +13 Meses'
			else 'Por definir' end 
	   end origen
,l.cliente,l.fechavencimiento,l.codprestamo,l.atrasomaximo diasmora,l.fechadesembolso fechafesembolso,l.monto montofesembolso,c.nrocuotas cuotas
,c.codsolicitud,l.codoficina,substring(l.codprestamo,5,3) codproducto,isnull(l.codpromotor,'') codasesor,isnull(l.codprestamonuevo,'') newcodsolicitud,l.coordinador promotor,l.secuenciacliente+1 ciclo
--,l.cancelacion
--,datediff(month,l.cancelacion,@fecha) dif
from tCsACaLIQUI_RR l with(nolock)
inner join tcscartera c with(nolock) on c.codprestamo=l.codprestamo and c.fecha=l.cancelacion-1--l.fechadesembolso
--left outer join tcspadronclientes cl with(nolock) on l.codusuario=cl.codusuario
where l.codoficina=@codoficina 
--and (l.codpromotor in(@codasesor) or l.codpromotor is null)--'AGJ1104961'--and coordinador='ARCE GONZALEZ JACQUELINE'
and l.estado not in('Renovado','Reactivado','En Proceso')
and l.atrasomaximo>=0 and l.atrasomaximo<=89
and l.cancelacion>='20200401'
--and l.cliente like '%velazquez%'
--and datediff(year,cl.fechanacimiento,'20201110')>=25 and datediff(year,cl.fechanacimiento,'20201110')<=75
--and l.tiporeprog<>'REEST'
union
select case when l.codpromotor is not null then
			case when l.cancelacion>=@fecini and l.cancelacion<=@fecfin+1 then 'Renovaciones' else 'Reactivaciones' end 
	   else 
			case when datediff(month,l.cancelacion,@fecha)<=1 then 'Huerfano 0 a 1 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=2 and datediff(month,l.cancelacion,@fecha)<=3 then 'Huerfano 2 a 3 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=4 and datediff(month,l.cancelacion,@fecha)<=6 then 'Huerfano 4 a 6 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=7 and datediff(month,l.cancelacion,@fecha)<=9 then 'Huerfano 7 a 9 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=10 and datediff(month,l.cancelacion,@fecha)<=12 then 'Huerfano 10 a 12 Meses'
				 when datediff(month,l.cancelacion,@fecha)>=13 then 'Huerfano +13 Meses'
			else 'Por definir' end 
	   end origen
,l.cliente,l.fechavencimiento,l.codprestamo,l.atrasomaximo diasmora,l.fechadesembolso fechafesembolso,l.monto montofesembolso,c.nrocuotas cuotas
,c.codsolicitud,l.codoficina,substring(l.codprestamo,5,3) codproducto,isnull(l.codpromotor,'') codasesor,isnull(l.codprestamonuevo,'') newcodsolicitud,l.coordinador promotor,l.secuenciacliente+1 ciclo
--,l.cancelacion
--,datediff(month,l.cancelacion,@fecha) dif
from tCsACaLIQUI_RR l with(nolock)
inner join tcscartera c with(nolock) on c.codprestamo=l.codprestamo and c.fecha=l.cancelacion-1--l.fechadesembolso
--left outer join tcspadronclientes cl with(nolock) on l.codusuario=cl.codusuario
where l.codoficina=@codoficina 
--and (l.codpromotor in(@codasesor) or l.codpromotor is null)--'AGJ1104961'--and coordinador='ARCE GONZALEZ JACQUELINE'
and l.estado not in('Renovado','Reactivado','En Proceso')
and l.atrasomaximo>=0 and l.atrasomaximo<=30
and l.cancelacion<='20200331'
--and l.cliente like '%velazquez cabrera%'
--and datediff(year,cl.fechanacimiento,'20201110')>=25 and datediff(year,cl.fechanacimiento,'20201110')<=75
--and l.tiporeprog<>'REEST'
--order by (case when l.codpromotor is not null then
--			case when l.cancelacion>=@fecini and l.cancelacion<=@fecfin then 'Renovaciones' else 'Reactivaciones' end 
--	   else 
--			case when datediff(month,l.cancelacion,@fecha)<=1 then 'Huerfano 0 a 1 Meses'
--				 when datediff(month,l.cancelacion,@fecha)>=2 and datediff(month,l.cancelacion,@fecha)<=3 then 'Huerfano 2 a 3 Meses'
--				 when datediff(month,l.cancelacion,@fecha)>=4 and datediff(month,l.cancelacion,@fecha)<=6 then 'Huerfano 4 a 6 Meses'
--				 when datediff(month,l.cancelacion,@fecha)>=7 and datediff(month,l.cancelacion,@fecha)<=9 then 'Huerfano 7 a 9 Meses'
--				 when datediff(month,l.cancelacion,@fecha)>=10 and datediff(month,l.cancelacion,@fecha)<=12 then 'Huerfano 10 a 12 Meses'
--				 when datediff(month,l.cancelacion,@fecha)>=13 then 'Huerfano +13 Meses'
--			else 'Por definir' end 
--	   end)

drop table #panel
drop table #panel2
drop table #excepciones
--313
--select * from tCsACaLIQUI_RR where codoficina=308 and estado not in('Renovado','Reactivado') and codpromotor='GAA1701981' 

--origen		cliente						fechavencimiento	codprestamo			diasmora	fechafesembolso	montofesembolso	cuotas	codsolicitud	codoficina	codproducto	codasesor		newcodsolicitud		promotor				ciclo
--Activos		CASTILLO GARCIA EDMUNDO		16/05/19			004-170-06-08-01231		0		16/11/18			12000.00	6		SOL-0015874			4			170		4MLB2111751    						MOYAO LOREDO BALDEMAR	18
--Liquidados	GONZALEZ GUTIERREZ PAOLA	01/05/19			004-170-06-01-01343		0		08/01/19			10000.00	16		SOL-0016006			4			170		4MLB2111751    						MOYAO LOREDO BALDEMAR	2
--Liquidados	HERNANDEZ PORFIRIO JUAN		03/05/19			004-170-06-00-01388		0		29/01/19			26000.00	16		SOL-0016058			4			170		4MLB2111751    						MOYAO LOREDO BALDEMAR	5
GO