SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaTransSucursal] @fecini smalldatetime,@fecha smalldatetime,@sucursal varchar(5)
---- consultar ingresos y egresos por sucursal -----------  ZCCU 2023.04.20
as   
set nocount on  

----declare @fecha smalldatetime
----set @fecha='20230301'
----declare @fecini smalldatetime
----set @fecini='20230301'
----declare @sucursal varchar(5)
----set @sucursal='309'
---------------------------------
select t.fecha fechaPago
--,t.nombrecliente
,t.codigocuenta codprestamo
--,t.renovado
,t.montototaltran
--,tipotransacnivel3,tipotransacnivel2
,case when tipotransacnivel1='I' then 'INGRESO' when tipotransacnivel1='E' then 'EGRESO' END 'Tipo' 
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
INTO #BASE
--select top 10*	
from tcstransacciondiaria t with(nolock)--where codoficina='467'
where t.fecha>=@fecini
and t.fecha<=@fecha
and codsistema='CA'
and tipotransacnivel3 not in(2,3,0)
and codoficina<>'999'
--and codoficina=@sucursal

select codprestamo 
into #ca
from #Base with(nolock)

select codprestamo,pcd.codoficina ,o.nomoficina
into #ofi
from tcspadroncarteraDet pcd with(nolock)
inner join tcloficinas o  with(nolock)on o.codoficina=pcd.codoficina 
where codprestamo in (select codprestamo from #ca with(nolock))
and pcd.codoficina=@sucursal

select b.*,nomoficina
from #base b  with(nolock)
inner join #ofi o on o.codprestamo=b.codprestamo

drop table #Base
drop table #ca
drop table #ofi
GO