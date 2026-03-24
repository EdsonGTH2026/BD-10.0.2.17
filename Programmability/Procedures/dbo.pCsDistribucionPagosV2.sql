SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsDistribucionPagosV2]  @fecini smalldatetime,@fecha smalldatetime  with encryption    
as    
set nocount on    
-----ZCCU
--++++++++++++++++++++++++++++++++++++++++++++  Distribución de pagos  para AUDITORIA    +++++++++++++++++++++++++++
----declare @fecha smalldatetime
----set @fecha='20250930'

----declare @fecini smalldatetime
----set @fecini='20250901'
-----------------------------------
select 
FECHA,t.CodOficina,codigocuenta Codprestamo,D.secuenciaCliente ciclo,
case when codsistema='CA' and tipotransacnivel3 = 104 and coddestino='DB' then 'Pago de credito bancos'
            when codsistema='CA' and tipotransacnivel3 = 104 and coddestino  in('7') then 'Liquidación de credito - Garantía'
			when codsistema='CA' and tipotransacnivel3 = 104 and coddestino<>'DB' then 'Pago de credito efectivo'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino='DB'then 'Liquidación de credito Bancos'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino not in('DC','DB','7') then 'Liquidación de credito efectivo'
            when codsistema='CA' and tipotransacnivel3 = 105 and coddestino  in('7') then 'Liquidación de credito - Garantía'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino in ('DC') then 'Liquidación de credito renovacion'
			else '' end Tipooperación,
case when coddestino='DB' and NroCheque='1153337760' then 'Banorte'
	  when coddestino='DB' and NroCheque='110553840' then 'Bancomer/BBVA'
	  when coddestino='DB' and NroCheque='110821985' then 'Bancomer/BBVA'

	  when CodDestino = 'DC' then 'Interno'
	  when CodDestino = '7' then 'Interno'
	  when CodDestino = '2' then 'Campo'
	  when CodDestino in( '1','DI','DR') then 'Sucursal'
	  else 'OTRO' end 'Referencia'
,MontoCapitalTran
,MontoInteresTran
,MontoCargos
,MontoOtrosTran
,MontoImpuestos
,MontoTotalTran MontoTotal
from tCsTransaccionDiaria t with(nolock)
inner join tCsPadronCarteraDet d on d.CodPrestamo=t.CodigoCuenta 
where fecha>=@fecini--'20230101' --
and fecha<=@fecha--'20230131'--
and TipoTransacNivel3 in (104,105)
and codsistema='CA'
and t.codoficina<>'999'
and Extornado = 0 
AND TipoTransacNivel1 NOT IN ('O')
GROUP BY FECHA,t.CodOficina,codigocuenta,D.secuenciaCliente,codsistema,coddestino,NroCheque,tipotransacnivel3
,MontoCapitalTran
,MontoInteresTran
--,MontoINVETran
--,MontoINPETran
,MontoCargos
,MontoOtrosTran
,MontoImpuestos
,MontoTotalTran 


GO