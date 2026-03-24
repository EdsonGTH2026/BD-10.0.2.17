SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsDistribucionPagos]  @fecini smalldatetime,@fecha smalldatetime      
as    
set nocount on    

--++++++++++++++++++++++++++++++++++++++++++++  Distribución de pagos      +++++++++++++++++++++++++++
--declare @fecha smalldatetime
--set @fecha='20241031'

--declare @fecini smalldatetime
--set @fecini='20241001'

select 
FECHA,CodOficina,codigocuenta,
case when codsistema='CA' and tipotransacnivel3 = 104 and coddestino='DB' then 'Pago de credito bancos'
			when codsistema='CA' and tipotransacnivel3 = 104 and coddestino<>'DB' then 'Pago de credito efectivo'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino='DB'then 'Liquidación de credito Bancos'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino not in('DC','DB','7') then 'Liquidación de credito efectivo'
            when codsistema='CA' and tipotransacnivel3 = 105 and coddestino  in('7') then 'Liquidación de credito - Garantía'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino in ('DC') then 'Liquidación de credito renovacion'
			else '' end Tipooperación,
case when coddestino='DB' and NroCheque='1153337760' then 'Banorte'
	  when coddestino='DB' and NroCheque='110553840' then 'Bancomer/BBVA'
	  when CodDestino = 'DC' then 'Interno'
	  when CodDestino = '7' then 'Interno'
	  when CodDestino = '2' then 'Campo'
	  when CodDestino = '1' then 'Sucursal'
	  else 'OTRO' end 'Referencia'
,MontoCapitalTran
,MontoInteresTran
--,MontoINVETran
--,MontoINPETran
,MontoCargos
,MontoOtrosTran
,MontoImpuestos
,MontoTotalTran MontoTotal

--,COUNT (case when coddestino='DB' and NroCheque='1153337760' then 1
--	  when coddestino='DB' and NroCheque='110553840' then 1
--	  when CodDestino = 'DC' then 1
--	  when CodDestino = '7' then 1
--	  when CodDestino = '2' then 1
--	  when CodDestino = '1' then 1
--	  else 1 end) 'Referencia'
--,* 
from tCsTransaccionDiaria with(nolock)
where fecha>=@fecini--'20230101' --
and fecha<=@fecha--'20230131'--
and TipoTransacNivel3 in (104,105)
and codsistema='CA'
and codoficina<>'999'
and Extornado = 0 
GROUP BY FECHA,CodOficina,codigocuenta,codsistema,coddestino,NroCheque,tipotransacnivel3
,MontoCapitalTran
,MontoInteresTran
--,MontoINVETran
--,MontoINPETran
,MontoCargos
,MontoOtrosTran
,MontoImpuestos
,MontoTotalTran 


--and NumCuenta='1153337760'--Banorte
--and NumCuenta='110553840'-- Bancomer/BBVA


/****** Script para el comando SelectTopNRows de SSMS  *****
SELECT TOP 1000 [codorigenpago]
      ,[descripcion]
      ,[activo]
      ,[MuestraCJ]
  FROM [Finmas].[dbo].[tCaClOrigenPagos]
  */
GO

GRANT EXECUTE ON [dbo].[pCsDistribucionPagos] TO [mchavezs2]
GO