SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATE PROCEDURE dbo.pCsDistribucionPagos  @fecini smalldatetime,@fecha smalldatetime        
--as      
--set nocount on

CREATE PROCEDURE [dbo].[BI_DetallePagos] as
--ALTER procedure BI_DetallePagos as         

declare @fechacorte smalldatetime              
select @fechacorte = fechaconsolidacion from vcsfechaconsolidacion              
--set @fechacorte = '20241013'    

select
d.FECHA,
LEFT(d.codigocuenta, 3) AS CodOficina,
COUNT(d.codigocuenta) NroPagos,
case when d.codsistema = 'CA' and d.tipotransacnivel3 = 104 and d.coddestino = 'DB' then 'Pago de credito bancos'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 104 and d.coddestino <> 'DB' then 'Pago de credito efectivo'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino = 'DB'then 'Liquidación de credito Bancos'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino not in ('DC','DB','7') then 'Liquidación de credito efectivo'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino in ('7') then 'Liquidación de credito - Garantía'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino in ('DC') then 'Liquidación de credito renovacion'
     else '' end Tipooperación,
case when d.Coddestino = 'DB' and d.NroCheque = '1153337760' then 'c.Banorte'
     when d.Coddestino = 'DB' and d.NroCheque = '110553840' then 'b.Bancomer/BBVA'
     when d.CodDestino = 'DC' then 'Interno'
     when d.CodDestino = '7' then 'Interno'
     when d.CodDestino = '2' then 'd.Campo'
     when d.CodDestino = '1' then 'a.Sucursal'
     else 'OTRO' end Referencia
,sum(d.MontoCapitalTran) MontoCapitalTranD
,sum(d.MontoInteresTran) MontoInteresTran
,sum(d.MontoCargos) MontoCargos
,sum(d.MontoOtrosTran) MontoOtrosTran
,sum(d.MontoImpuestos) MontoImpuestos
,sum(d.MontoTotalTran) MontoTotal
--,o.EsVirtual
from tCsTransaccionDiaria d with(nolock)
--inner join tcloficinas o with(nolock) on o.codoficina = d.codigocuenta
where d.fecha >= '20250101'
and d.fecha <= @fechacorte
and d.TipoTransacNivel3 in (104,105)
and d.codsistema = 'CA'
and d.codoficina not in ('999') 
and d.Extornado = 0

GROUP BY FECHA,
LEFT(d.codigocuenta, 3),
case when d.codsistema = 'CA' and d.tipotransacnivel3 = 104 and d.coddestino = 'DB' then 'Pago de credito bancos'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 104 and d.coddestino <> 'DB' then 'Pago de credito efectivo'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino = 'DB'then 'Liquidación de credito Bancos'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino not in ('DC','DB','7') then 'Liquidación de credito efectivo'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino  in ('7') then 'Liquidación de credito - Garantía'
     when d.codsistema = 'CA' and d.tipotransacnivel3 = 105 and d.coddestino in ('DC') then 'Liquidación de credito renovacion'
     else '' end,
case when d.Coddestino = 'DB' and d.NroCheque= '1153337760' then 'c.Banorte'
     when d.Coddestino = 'DB' and d.NroCheque = '110553840' then 'b.Bancomer/BBVA'
     when d.CodDestino = 'DC' then 'Interno'
     when d.CodDestino = '7' then 'Interno'
     when d.CodDestino = '2' then 'd.Campo'
     when d.CodDestino = '1' then 'a.Sucursal'
     else 'OTRO' end  

order by d.FECHA, d.CodOficina
GO