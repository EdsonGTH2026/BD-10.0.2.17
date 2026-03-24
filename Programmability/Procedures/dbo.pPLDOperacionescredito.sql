SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pPLDOperacionescredito] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20220228'
declare @fecini smalldatetime
set @fecini=cast(year(@fecha) as varchar(4))+'0101'
----set @fecini='20220201'

----codusuario	nombrecliente	codcuenta	Tipooperación	fecha	montototaltran	Instrumento
select t.fecha,t.nombrecliente,t.codigocuenta,t.renovado
,t.montototaltran monto
--,tipotransacnivel3,tipotransacnivel2,tipotransacnivel1
,case when codsistema='CA' and tipotransacnivel3 = 104 and coddestino='DB' then 'Pago de credito bancos'
			when codsistema='CA' and tipotransacnivel3 = 104 and coddestino<>'DB' then 'Pago de credito efectivo'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino='DB'then 'Liquidación de credito Bancos'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino not in('DC','DB') then 'Liquidación de credito efectivo'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino='DC' then 'Liquidación de credito renovacion'
			when codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='OPR' then 'Desembolso OPR'
			when codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='EFEC' then 'Desembolso efectivo'
			when codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2 in('SIST','TRANS','CHEQ') then 'Desembolso transferencia'
			when codsistema='CA' and tipotransacnivel3 = 0 then 'Deposito de garantia credito'
			else '' end Tipooperación
--,'Pesos' moneda
--,t.coddestino
,case when codsistema='CA' and tipotransacnivel3 = 104 and coddestino='DB' then 'Bancos'
			when codsistema='CA' and tipotransacnivel3 = 104 and coddestino<>'DB' then 'Efectivo'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino='DB'then 'Bancos'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino not in('DC','DB') then 'Efectivo'
			when codsistema='CA' and tipotransacnivel3 = 105 and coddestino='DC' then 'Interno'
			when codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='OPR' then 'OPR'
			when codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2='EFEC' then 'Efectivo'
			when codsistema='CA' and tipotransacnivel3 = 102 and tipotransacnivel2 in('SIST','TRANS','CHEQ') then 'Transferencia'
			when codsistema='CA' and tipotransacnivel3 = 0 then 'Efectivo'
			else '' end instrumento
from tcstransacciondiaria t with(nolock)
--inner join (select codusuario,sum(saldo) saldo from #tmp with(nolock) group by codusuario) u on u.codusuario=t.codusuario
where t.fecha>=@fecini--'20210101' 
and t.fecha<=@fecha--'20211031'
--and t.codusuario in(select distinct codusuario from #tmp with(nolock))
and codsistema='CA'
and tipotransacnivel3 not in(2,3,0)

GO