SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pPLDOperacionesahorro] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20220228'
declare @fecini smalldatetime
set @fecini=cast(year(@fecha) as varchar(4))+'0101'
----set @fecini='20220201'

--Número de cliente
--Nombre del cliente
--Número de cuenta o contrato;
--Tipo de operación (depósito, retiro, pago de crédito, etc)
--Fecha de pago
--Importe de pago
--Instrumento monetario.

--select * from tCsClTipoTransacNivel3 where codsistema='AH'
create table #tx(
codusuario varchar(20),
nombrecliente varchar(200),
codcuenta varchar(25),
tipotransacnivel1 char(1),
tipotransacnivel2 varchar(10),
tipotransacnivel3 tinyint,
Tipooperación varchar(50),
fecha datetime,
monto money,
coddestino varchar(15),
Instrumento varchar(20)
)
insert into #tx
select p.codusuario,t.nombrecliente
,t.codigocuenta+'-'+t.fraccioncta+'-'+cast(t.renovado as varchar(3)) codcuenta
,tipotransacnivel1,tipotransacnivel2,tipotransacnivel3
,case when codsistema='AH' and tipotransacnivel3 = 3 then 'Transferencias Cargo'
			when codsistema='AH' and tipotransacnivel3 = 4 then 'Transferencias Abono'
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'EFEC' then 'Efectivo sucursales Retiro'
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'EFEC' then 'Efectivo sucursales Deposito'
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'SIST' then 'Interno sucursales Retiro'
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'SIST' then 'Interno sucursales Deposito'
			when codsistema='AH' and tipotransacnivel3 = 16 then 'Mantenimiento de cuenta'
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'CHEQ' then 'Transferencia Deposito'
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'CHEQ' then 'Retiro inversion transferencia'
			when codsistema='AH' and tipotransacnivel3 = 7 and tipotransacnivel2 = 'CHEQ' then 'Pago intereses inversion transferencia'
			when codsistema='AH' and tipotransacnivel3 = 7 and tipotransacnivel2 = 'EFEC' then 'Pago intereses inversion efectivo'
			when codsistema='AH' and tipotransacnivel3 = 7 and tipotransacnivel2 = 'INTERNO' then 'Pago intereses inversion transferencia' --> eliminar del excel
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'INTERNO' then 'Renovacion interna retiro' --> eliminar del excel
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'INTERNO' then 'Renovacion interna deposito' --> eliminar del excel
			when codsistema='AH' and tipotransacnivel3 = 11 then 'Operación anulada' --> eliminar del excel
			--renovaciones de capital
			else '' end Tipooperación

,t.fecha
,t.montototaltran
,t.coddestino
,case when codsistema='AH' and tipotransacnivel3 = 3 then 'Transferencias'
			when codsistema='AH' and tipotransacnivel3 = 4 then 'Transferencias'
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'EFEC' then 'Efectivo'
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'EFEC' then 'Efectivo'
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'SIST' then 'Interno'
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'SIST' then 'Interno'
			when codsistema='AH' and tipotransacnivel3 = 16 then 'Interno'
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'CHEQ' then 'Transferencia'
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'CHEQ' then 'Transferencia'
			when codsistema='AH' and tipotransacnivel3 = 7 and tipotransacnivel2 = 'CHEQ' then 'Transferencia'
			when codsistema='AH' and tipotransacnivel3 = 7 and tipotransacnivel2 = 'EFEC' then 'Efectivo'
			when codsistema='AH' and tipotransacnivel3 = 7 and tipotransacnivel2 = 'INTERNO' then 'Transferencia' --> eliminar del excel
			when codsistema='AH' and tipotransacnivel3 = 1 and tipotransacnivel2 = 'INTERNO' then 'Interno' --> eliminar del excel
			when codsistema='AH' and tipotransacnivel3 = 2 and tipotransacnivel2 = 'INTERNO' then 'Interno' --> eliminar del excel
			when codsistema='AH' and tipotransacnivel3 = 11 then 'Anulado' --> eliminar del excel
			else '' end Instrumento
from tcstransacciondiaria t with(nolock)
inner join tcspadronahorros p with(nolock) on p.codcuenta=t.codigocuenta and p.fraccioncta=t.fraccioncta and p.renovado=t.renovado
where t.fecha>=@fecini--'20210101' 
and t.fecha<=@fecha--'20211031'
and codsistema='AH'
and tipotransacnivel3 not in(15,16,62,63)
--and t.tipotransacnivel2<>'INTERNO'

----select *
delete from #tx
where substring(codcuenta,5,1)='2'
and tipotransacnivel3 in(1,2)
and tipotransacnivel2='INTERNO'

select @fecha fecha,codusuario,nombrecliente,codcuenta,Tipooperación,fecha,monto,Instrumento
from #tx
----where substring(codcuenta,5,1)='2'

drop table #tx
GO