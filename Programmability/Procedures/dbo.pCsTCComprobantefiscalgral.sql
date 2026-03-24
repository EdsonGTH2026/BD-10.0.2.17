SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobantefiscalgral] @fecha smalldatetime, @codoficina varchar(4)
AS
BEGIN
	SET NOCOUNT ON;


--declare @fecha smalldatetime
declare @impuesto decimal(16,2)
declare @imp decimal(16,2)
--declare @codoficina varchar(4)

--set @fecha = '20100531'
set @impuesto = 1.16
set @imp = 0.16
--set @codoficina = 70

CREATE TABLE #Plantilla (
  CodSistema    varchar(5),
	Operacion 	  varchar(200),
  monto         decimal(16,2),
  impuesto         decimal(16,2),
  total         decimal(16,2)
)

--AHORROS
insert into #Plantilla (codsistema,operacion,monto,impuesto,total)
SELECT 'AH' Codsistema, t.descripcion Operacion, SUM(a.MontoTotal)/@impuesto as monto,
SUM(a.MontoTotal) - (SUM(a.MontoTotal)/@impuesto) as Imp, SUM(a.MontoTotal) total
FROM [10.0.2.14].Finmas.dbo.tAhTransaccionMaestra a
inner join [10.0.2.14].Finmas.dbo.tAhClTipoTrans t on t.idtipotrans=a.codtipotrans
where dbo.fduFechaAAAAMMDD(a.fecha)=@fecha and a.codoficina=@codoficina
and a.codtipotrans in (21,22,23,24,25,26,16)
--      ,a.IdFactura
group by t.descripcion

--CARTERA
insert into #Plantilla (codsistema,operacion,monto,impuesto,total)
SELECT 'CA' Codsistema,DescConcepto, SUM(monto) monto, SUM(impuesto) impuesto, SUM(total) total from (
SELECT d.DescConcepto,d.monto,d.impuesto,d.total
  FROM [10.0.2.14].Finmas.[dbo].[tCaPagoReg] p
  inner join (SELECT pd.CodOficina, pd.SecPago,con.DescConcepto, sum(pd.MontoPagado) monto, 
  sum(pd.MontoPagado)*0.16 as impuesto,sum(pd.MontoPagado) + sum(pd.MontoPagado)*0.16 total
  FROM [10.0.2.14].Finmas.dbo.tCaPagoDet pd
  inner join [10.0.2.14].Finmas.[dbo].[tCaClConcepto] con on con.codconcepto=pd.codconcepto
  where pd.codconcepto not in ('IVAMO','IVAIT','IVACM') --and secpago= 1625 and codoficina=20
  group by pd.SecPago,con.DescConcepto,pd.CodOficina) d on d.codoficina=p.codoficina and d.secpago=p.secpago
  where p.fechapago=@fecha and p.codoficina=@codoficina and p.extornado=0) a
  group by DescConcepto
  --p.[Factura]
insert into #Plantilla (codsistema,operacion,monto,impuesto,total)
select 'CA' Codsistema,'PAGO ANTICIPADO CREDITO' descconcepto, sum(MontoPago)/@impuesto monto, 
SUM(MontoPago) - (SUM(MontoPago)/@impuesto) impuesto, sum(MontoPago) total
from [10.0.2.14].Finmas.dbo.tCaPagoParcialAnticipado
where fechapago=@fecha and codoficina=@codoficina and extornado=0

     --,[IdFactura]
     -- ,[IdFacturaComision]
insert into #Plantilla (codsistema,operacion,monto,impuesto,total)
select codsistema, nombre operacion,sum(monto) monto, sum(impuesto) impuesto,sum(total) total from (
SELECT 'TC' codsistema,t.nombre, s.MontoTotal monto ,s.Itf impuesto , s.MontoTotal + s.Itf total
FROM [10.0.2.14].Finmas.[dbo].[tTcServiciosTrans] s
inner join [10.0.2.14].Finmas.[dbo].[tTcClServicios] t on t.codoficina=s.codoficina and t.codservicio=s.codservicio
where s.fecha=@fecha and s.codoficina=@codoficina and s.estado='CANCELADO' and s.tiposervicio=1
and s.codservicio in('7','12','8') and montocomision = 0) a
group by codsistema,nombre
union 
select codsistema, nombre operacion,sum(monto) monto, sum(impuesto) impuesto,sum(total) total from (
SELECT 'TC' codsistema,t.nombre, s.montocomision monto ,s.Itf impuesto , s.montocomision + s.Itf total
FROM [10.0.2.14].Finmas.[dbo].[tTcServiciosTrans] s
inner join [10.0.2.14].Finmas.[dbo].[tTcClServicios] t on t.codoficina=s.codoficina and t.codservicio=s.codservicio
where s.fecha=@fecha and s.codoficina=@codoficina and s.estado='CANCELADO' and s.tiposervicio=1
and s.codservicio in('18') and s.montocomision <> 0) a
group by codsistema,nombre

select * from #Plantilla 
drop table #Plantilla 


END
GO