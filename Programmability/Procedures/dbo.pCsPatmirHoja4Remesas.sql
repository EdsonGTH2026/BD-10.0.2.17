SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--DROP PROC pCsPatmirHoja4Remesas
--EXEC pCsPatmirHoja4Remesas '20140201', '20140228'
CREATE PROCEDURE [dbo].[pCsPatmirHoja4Remesas]
               ( @FecIni SMALLDATETIME ,
                 @FecFin SMALLDATETIME )
AS                 
--DECLARE @fecini SMALLDATETIME
--DECLARE @fecfin SMALLDATETIME
--SET @fecini='20140401'
--SET @fecfin='20140430'

--HOJA REMESAS
SELECT /*''''+*/'0468' AS FolioIF,
       --cl.nomoficina,
       t.codusuario,
       case when t.TipoTransacNivel1 = 'I' then 'RECEPCION' else 'ENVIO' end AS Transaccion,
       t.montototaltran,
       case when t.tipotransacnivel3 = 6 then 'NACIONAL' else 'INTERNACIONAL' end AS Tipo
       --case when t.tipotransacnivel3 in (1,6,11,22,26,23,31) then 'REMESAS' else 'SEGURO DE VIDA' end tipo_servicio,
       --isnull(t.nrotransaccion,'') id,
       --cast(year(t.fecha)as char(4)) +'/'+ replicate('0',2-len(cast(month(t.fecha)as varchar(2)))) + cast(month(t.fecha) as varchar(2)) +'/'+ replicate('0',2-len(cast(day(t.fecha)as varchar(2)))) + cast(day(t.fecha) as varchar(2)) Fechaapertura,
       --case when t.tipotransacnivel3 in (1,6,11,22,26,23,31) then '' else        cast(year(dateadd(year,1,t.fecha))as char(4)) +'/'+ replicate('0',2-len(cast(month(dateadd(year,1,t.fecha))as varchar(2)))) + cast(month(dateadd(year,1,t.fecha)) as varchar(2)) +'/'+ replicate('0',2-len(cast(day(dateadd(year,1,t.fecha))as varchar(2)))) + cast(day(dateadd(year,1,t.fecha)) as varchar(2)) end Fechavencimiento,
  FROM tcstransacciondiaria t with(nolock) 
--inner join #clientes c on c.codusuario=t.codusuario
--left outer join tCsTransaccionDiariaOtros ot wit(nolock) on t.fecha=ot.fecha and t.codsistema=ot.codsistema and t.codoficina=ot.codoficina 
--and t.nrotransaccion=ot.nrotransaccion 
inner join tcspadronclientes cl with(nolock) on cl.codusuario=t.codusuario
--inner join tcloficinas o with(nolock) on o.codoficina=cl.codoficina
where t.fecha>=@FecIni and t.fecha<=@FecFin and codsistema='TC'
and t.tipotransacnivel3 in (1,6,11,22,26--remesas
,23--oportunidades
,31)--extrabajadores migrantes
and t.extornado=0
--AND  t.codusuario not in('RAM0411751')
and t.codusuario in (Select CodUsuario From tCsFondReportados Where CodFondo = 'PT')--(select cvesociocte from #hoja11)
--I ingreso --RECEPCION
GO