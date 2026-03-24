SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsEstadoCuentaAH_Resumen] @Usuario		Varchar(50),@Cuenta			Varchar(25), @PrimerCorte	SmallDateTime, @UltimoCorte	SmallDateTime
as


/*
declare	@Usuario		Varchar(50)
declare	@Cuenta			Varchar(25)
set @Usuario='curbiza'
set @Cuenta='098-209-06-2-0-00001-0-0' 
--set @Cuenta='098-211-06-2-7-00070-0-1'
Declare @UltimoCorte	SmallDateTime
Declare @PrimerCorte	SmallDateTime
set @PrimerCorte='20170505'
set @UltimoCorte='20190128'
--set @PrimerCorte='20170929'
--set @UltimoCorte='20180118'
*/

set @PrimerCorte = convert(varchar,@PrimerCorte, 112)
set @UltimoCorte = convert(varchar,@UltimoCorte, 112)

--<<<<<<<<<<<<<<<<<<<
declare @fechaMax as SmallDateTime
declare @FechaApertura smalldatetime

select 
@fechaMax = isnull(FecCancelacion,''), 
@FechaApertura = FecApertura
from tCsPadronAhorros where codcuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta

print 'fecha max: ' + convert(varchar,@fechaMax)

if @fechaMax > '19000101'
	begin  
		if @fechaMax <= @UltimoCorte   --Si la fechaMax en menor igual a la fecha corte
			begin
				--set @fechaMax = dateadd( d, -1, @fechaMax)
				--print 'ajusta la fecha max = FechaCancelacion -1 dia: ' + convert(varchar,@fechaMax)

				select @fechaMax = max(Fecha) from tCsAhorros where codcuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta
				print 'obtiene la fechamax de tCsAhorros: ' + convert(varchar,@fechaMax)

			end
		else
			begin
				set @fechaMax = @UltimoCorte
				print 'ajusta la fecha max = fecha ultimo corte: ' + convert(varchar,@fechaMax)
			end
	end
else
	begin
		set @fechaMax = @UltimoCorte
		print 'ajusta la fecha max = FechaCorte ' + convert(varchar,@fechaMax)
	end

print 'fecha max: ' + convert(varchar,@fechaMax)
print 'fecha Apertura: ' + convert(varchar,@FechaApertura)


if @FechaApertura > @PrimerCorte
	begin
		set @PrimerCorte = @FechaApertura
		print 'Fecha Apertura mayor a fecha inicial ' 
		--select @DiasPeriodo = datediff(d, @FechaApertura, @UltimoCorte)
	end 
else
	begin		
		print 'Fecha Apertura menor a fecha incial' 
		--select @DiasPeriodo = datediff(d, @PrimerCorte, @UltimoCorte)
	end

print 'Fecha Primer Corte: ' + convert(varchar,@PrimerCorte)

-->>>>>>>>>>>>>>>>>>>

--POR EL MOMENTO NO SE UTILIZA LA VARIABLE @DATO
Declare @Firma			Varchar(100)
Declare @Parametro		Varchar(50)
Declare @AnteriorCorte	SmallDateTime
Declare @LimitePago		Varchar(20)
Declare @Devengado		Decimal(20,4)
Declare @SaldoAnterior	Decimal(20,4)
Declare @CAT			Decimal(10,4)

Declare @GATnominal		money
Declare @GATreal		money
declare @RendimientosPeriodo money
declare @UDI money
declare @ValorUDIsEnPesos money
declare @SaldoInicialPeriodo money
declare @SaldoPromedio money
declare @DiasPeriodo int
declare @SaldoPromedioDiarios money
declare @ImpuestosPeriodo money


If Ltrim(Rtrim(@Usuario)) = ''
Begin 
	Select TOP 1 @Usuario = Usuario from tSgUsuarios
	Where Activo = 1 And ltrim(rtrim(Usuario)) <> ''
	Order by NewId()
End
If Ltrim(Rtrim(@Cuenta)) = ''
Begin 
	Select Top 1 @Cuenta = CodPrestamo from (
	Select Distinct CodPrestamo From tCsPadronCarteraDet
	Where EstadoCalculado Not In ('CANCELADO')) Datos
	Order by Newid()
End


Set		@AnteriorCorte	= DateAdd(day,-1,@PrimerCorte)
/*pendiente*/
Exec	pCsEstadoCuentaCronograma		2,	@Cuenta, @UltimoCorte
Exec	pCsEstadoCuentaCronograma		2,	@Cuenta, @AnteriorCorte
Exec	pCsEstadoCuentaCAMovimientos	2,	@Cuenta, @PrimerCorte,		@UltimoCorte

--Print	@AnteriorCorte
--Print	@UltimoCorte

	SELECT   
top 1
 @CAT = dbo.fduCATPrestamo(4, SaldoCuenta, DATEDIFF(Day, @PrimerCorte, @UltimoCorte), TasaInteres, 0) 
	FROM         tCsAhorros
	WHERE     (CodCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta) AND (Fecha <= @UltimoCorte)
order by Fecha desc


CREATE TABLE #Saldos(
	[CodPrestamo]		[varchar](25) NOT NULL,
	[Concepto]			[varchar](100) NULL,
	[SaldoCapital]		[money] NULL,
	[InteresOrdinario]	[money] NULL,
	[InteresMoratorio]	[money] NULL,
	[OtrosCargos]		[money] NULL,
	[ComisionIVA]		[money] NULL
) ON [PRIMARY]

Insert Into #Saldos
Exec pCsEstadoCuentaCASaldos 1, @Cuenta, @UltimoCorte,		'Vigente Actual'
Insert Into #Saldos
Exec pCsEstadoCuentaCASaldos 2, @Cuenta, @UltimoCorte,		'Atraso Actual'

Set @Parametro	= Replace(@Cuenta, '-', '')

Set @Parametro	= Upper(dbo.fduNombreMes(Month(@UltimoCorte)) + ' ' + Cast(Year(@UltimoCorte) as Varchar(4)))

Select @SaldoAnterior = Sum(Devengado-Pago) from tCsEstadoCuentaCronograma
Where Corte = @AnteriorCorte and CodPrestamo = @Cuenta

--OSC, Obtiene el GAT Real y Nominal
select  @GATnominal = GatNominal, @GATreal = GatReal from [10.0.2.14].finmas.dbo.vAhGatNominalReal where codcuenta2 = @Cuenta

--OSC-- Print @SaldoAnterior

--OSC, obtiene los interese en el periodo
select @RendimientosPeriodo = sum(MontoTotalTran) from tCsTransaccionDiaria 
where 
(CodigoCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta)
and Fecha >= @PrimerCorte and Fecha <= @UltimoCorte
and TipoTransacNivel1 = 'I' and TipoTransacNivel3 = 15

--OSC, obtiene los impuestos en el periodo
select @ImpuestosPeriodo = isnull(sum(MontoTotalTran),0) from tCsTransaccionDiaria 
where 
(CodigoCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta)
and Fecha >= @PrimerCorte and Fecha <= @UltimoCorte
and TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (62)

--OSC, obtiene el valor de udis en pesos
select top 1 @UDI = UDI from tcsudis where Fecha <= @UltimoCorte order by Fecha desc
set @ValorUDIsEnPesos = @UDI * 25000

--OSC, obtiene el saldo inicial del periodo
select top 1 @SaldoInicialPeriodo = SaldoCuenta --, Fecha, CodCuenta, FraccionCta, Renovado 
from tCsAhorros 
where (CodCuenta  + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta) 
and fecha <= @PrimerCorte order by fecha desc

--OSC, obtiene el saldo promedio del periodo
set @SaldoPromedio	= (Select AVG(SaldoCuenta) from tcsahorros Where CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) )

--OSC, obtiene el numero de dias del periodo
--select @PrimerCorte, @UltimoCorte
		select @DiasPeriodo = datediff(d, @PrimerCorte, @UltimoCorte)
--set @DiasPeriodo = @DiasPeriodo + 1
--select @DiasPeriodo

--OSC, obtiene el saldo promedio diario
set @SaldoPromedioDiarios = @SaldoPromedio --@SaldoPromedio / @DiasPeriodo

Set @LimitePago = 'INMEDIATO'

--OSC 24-01-2019
set @SaldoInicialPeriodo = 0

--<<<<<<<<<<<<<< OSC, 15-05-2018, calculo de resumen operaciones
declare @ResumenAbonos money
declare @ResumenRendimientos money
declare @ResumenCargos money
declare @ResumenImpuestos money
declare @ResumenSaldoFinal money

select 
@ResumenAbonos = sum(x.Abonos), --as Abonos, 
@ResumenRendimientos = sum(x.Rendimientos), -- as Rendimientos, 
@ResumenCargos = sum(x.Cargos), -- as Cargos, 
@ResumenImpuestos = sum(x.Impuestos), -- as Impuestos,  

--@ResumenSaldoFinal = (sum(x.Abonos) + sum(x.Rendimientos)- sum(x.Cargos)-sum(x.Impuestos)) -- as SaldoFinal
@ResumenSaldoFinal =(case 
                     when left(right(left(@Cuenta,7),3),1) = '2' 
                     then @SaldoInicialPeriodo + @ResumenRendimientos - @ResumenCargos
                     else
		             (sum(x.Abonos) + sum(x.Rendimientos)- sum(x.Cargos)-sum(x.Impuestos))
                     end)
from
(
	SELECT   
	
	CASE 
	WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'I' and TipoTransacNivel3 in (2) THEN tCsTransaccionDiaria.MontoTotalTran  
	ELSE 0 END AS Abonos, 
	
	CASE 
	--WHEN (tCsTransaccionDiaria.TipoTransacNivel1 = 'I' and TipoTransacNivel3 in (15,7)) or (tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (63)) THEN tCsTransaccionDiaria.MontoTotalTran  
	WHEN (TipoTransacNivel3 in (15,7, 63)) THEN tCsTransaccionDiaria.MontoTotalTran  
	ELSE 0 END AS Rendimientos, 
	
	CASE 
	--WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (1)  THEN tCsTransaccionDiaria.MontoTotalTran  
	WHEN TipoTransacNivel3 in (1, 7)  THEN tCsTransaccionDiaria.MontoTotalTran  
	ELSE 0 END AS Cargos, 
	
	CASE 
	WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (62) THEN tCsTransaccionDiaria.MontoTotalTran  
	ELSE 0 END AS Impuestos
	
		FROM         
	tCsTransaccionDiaria with(nolock) 
	LEFT OUTER JOIN tClOficinas with(nolock) ON tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina 
	LEFT OUTER JOIN tAhClTipoTrans with(nolock) ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
	left join tCsAhorros as a with(nolock) on a.codcuenta = tCsTransaccionDiaria.CodigoCuenta and a.FraccionCta = tCsTransaccionDiaria.FraccionCta and a.Renovado = tCsTransaccionDiaria.Renovado and a.Fecha = tCsTransaccionDiaria.Fecha 
	WHERE     
	(tCsTransaccionDiaria.Fecha >= @PrimerCorte) 
	AND (tCsTransaccionDiaria.Fecha <= @ultimoCorte) 
	AND (tCsTransaccionDiaria.CodSistema = 'AH') 
	and (tCsTransaccionDiaria.CodigoCuenta + '-' + tCsTransaccionDiaria.FraccionCta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) = @Cuenta )
	--order by tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.NroTransaccion
) as x


/* boorar
select 
@SaldoInicialPeriodo = 
(
isnull(sum(
case  
   when tt.EsDebito = 0 then td.MontoTotalTran 
   else 0 
end
),0)
) 
-
(
isnull(sum(
case  
   when tt.EsDebito = 1 then td.MontoTotalTran 
   else 0 
end
),0)
)
from tCsTransaccionDiaria as td
inner join tAhClTipoTrans as tt on tt.idTipoTrans = td.TipoTransacNivel3
where (td.CodigoCuenta  + '-' + td.FraccionCta + '-' + CAST(td.Renovado AS varchar(5)) = @Cuenta) 
and td.Fecha < @Inicio

*/
--OSC, 24-01-2019
if  substring(@Cuenta, 5,3) <> '209'
begin
	select @ResumenRendimientos = sum(InteresCalculado) from tcsahorros
	where 
	--CodCuenta = '098-211-06-2-0-00153' and FraccionCta = 0 and Renovado = 0
	(CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta )
	and Fecha >= @PrimerCorte
	and Fecha <= @ultimoCorte
end
-->>>>>>>>>>>>>>

--<<<<<<<<<<<<<
--OSC, 26-01-2019
declare @InteresBrutoPeriodo money
set @InteresBrutoPeriodo = 0

select 
@InteresBrutoPeriodo = sum(v.InteresPeriodo)
from [10.0.2.14].finmas.dbo.tAhIntPeriodicos as ip 
left join [10.0.2.14].finmas.dbo.tAhIntPeriodicosDetVariable as v on v.CodCuenta = ip.CodCuenta and v.NroPago = ip.NroPago 
where 
(ip.CodCuenta + '-' + ip.FraccionCta + '-' + CAST(ip.Renovado AS varchar(5)) = @Cuenta )
and convert(varchar,Fecha,112) <= convert(varchar,@ultimoCorte,112)
--and convert(varchar,FechaPagado,112) <= convert(varchar,@ultimoCorte,112)
and ip.TipoPago = 'INT'
--------------------------------------------

declare @ResumenInteresCapitalizado money
set @ResumenInteresCapitalizado = 0

select 
@ResumenInteresCapitalizado = sum(v.InteresReinvertir)
from [10.0.2.14].finmas.dbo.tAhIntPeriodicos as ip 
left join [10.0.2.14].finmas.dbo.tAhIntPeriodicosDetVariable as v on v.CodCuenta = ip.CodCuenta and v.NroPago = ip.NroPago 
where 
(ip.CodCuenta + '-' + ip.FraccionCta + '-' + CAST(ip.Renovado AS varchar(5)) = @Cuenta )
and convert(varchar,Fecha,112) <= convert(varchar,@ultimoCorte,112)
--and convert(varchar,FechaPagado,112) <= convert(varchar,@ultimoCorte,112)
and ip.TipoPago = 'INT'

---------------------------------------------
declare @PagoAmoCapitalPeriodo money
set @PagoAmoCapitalPeriodo = 0

select 
@PagoAmoCapitalPeriodo = sum(isnull(ip.Monto,0))
from [10.0.2.14].finmas.dbo.tAhIntPeriodicos as ip 
left join [10.0.2.14].finmas.dbo.tAhIntPeriodicosDetVariable as v on v.CodCuenta = ip.CodCuenta and v.NroPago = ip.NroPago 
where 
(ip.CodCuenta + '-' + ip.FraccionCta + '-' + CAST(ip.Renovado AS varchar(5)) = @Cuenta )
--and Fecha < '20190105'
and convert(varchar,Fecha,112) <= convert(varchar,@ultimoCorte,112)
--and convert(varchar,FechaPagado,112) <= convert(varchar,@ultimoCorte,112)
and ip.TipoPago = 'AMO'

-->>>>>>>>>>>>>>


SELECT	

@PrimerCorte AS Inicio, @UltimoCorte AS Corte, DATEDIFF(Day, @PrimerCorte, @UltimoCorte) AS Dias, @Parametro AS Periodo
			, @Firma AS Firma, 
			CodPrestamo = @Cuenta
			, tCsClientesAhorrosFecha_2.CodUsCuenta as CodUsuario, NombreProdCorto = tAhProductos.Abreviatura, NombreProd = tAhProductos.Nombre
			,tCsPadronClientes.UsRFCBD
			, tCsPadronAhorros.CodOficina, tClOficinas.Tipo, ProximoVencimiento = @UltimoCorte
			,tAhClFormaManejo.Nombre AS Veridico 
			, LEFT(General.ClienteGrupo, 35) AS ClienteGrupo
			,General.DescMoneda
			, tCsAhorros.FechaApertura AS FechaDesembolso
			, FechaVencimiento = Case When tCsAhorros.FechaVencimiento Is Null Then 'INDEFINIDO' 
			                          Else dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'DD') +  '-' + lower(Left(dbo.fduNombreMes(Month(tCsAhorros.FechaVencimiento)), 3)) + '-' + dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'AAAA') 
                                 End

			, FechaVencimiento2 = Case When tCsAhorros.FechaVencimiento Is Null Then 'INDEFINIDO' 
			                          Else  convert(varchar,tCsAhorros.FechaVencimiento,103)
                                  End

			,tCsAhorros.TasaInteres AS TasaIntCorriente
			, @CAT AS CAT
            ,tCsAhorros.SaldoCuenta AS SaldoCapital
			, 0 AS CargoMora, 0 AS OtrosCargos, 
--0 AS Impuestos
@ImpuestosPeriodo as Impuestos
			,CASE WHEN (ISNULL(Atrasado.SaldoCapital, 0) + ISNULL(Atrasado.InteresOrdinario, 0) + ISNULL(Atrasado.InteresMoratorio, 0) + ISNULL(Atrasado.OtrosCargos, 0) 
            + ISNULL(Atrasado.ComisionIVA, 0)) > 0 THEN 'INMEDIATO' ELSE '' END AS LimitePago
			, isnull(@SaldoAnterior,0) AS SaldoAnterior

, Isnull(Cargos.CK, 0) as CK
, Isnull(Cargos.CKC, 0) as CKC
, Isnull(Cargos.CKI, 0) as CKI
, ISNULL(Abonos.AK, 0) AS AK

			, tCsPadronClientes.NombreCompleto
			, tAhProductos.AlternativaUso
			, cast(Replace(isnull(case when tAhProductos.SaldoMinimo='NO APLICA' then '0' else tAhProductos.SaldoMinimo end,'0'), '$', '') as decimal(8,2)) SaldoMinimo
          ,  SaldoPromedio	= (Select AVG(SaldoCuenta) from tcsahorros Where CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS varchar(5)) = @Cuenta AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) )
       ,   MontoBloqueado	= tCsAhorros.MontoBloqueado

,SaldoDisponible = (case tCsPadronAhorros.EstadoCalculado when 'CC' then 0
					else
						tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado - (case when tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado<(case when tAhProductos.SaldoMinimo='NO APLICA' then 0 
																																					else Cast(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') As Decimal(18,4)) 
																																					end)
				  																	then 0 
																					else (case when tAhProductos.SaldoMinimo='NO APLICA' 
																							then 0 
																							else Cast(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') As Decimal(18,4)) 
																							end) 
																					 end)
					end)



,tCsPadronAhorros.MonApertura as SaldoApertura
,isnull(tCsPadronAhorros.MonCancelacion,tCsAhorros.SaldoCuenta) as SaldoCancelacion
,case when isnull(tCsPadronAhorros.MonCancelacion,0) = 0 then 0 else tCsAhorros.IntAcumulado end as InteresAcumulado
,tCsAhorros.MontoRetenido

,isnull(tCsAhorros.Plazo,0) as Plazo
,isnull(convert(varchar,tCsAhorros.Plazo),'NO APLICA') as Plazo2

,case when isnull(tCsPadronAhorros.MonCancelacion,0) = 0 then tCsAhorros.IntAcumulado  else 0 end as InteresAcumulado2
,@GATnominal as GATnominal
,@GATreal as GATreal
,isnull(@RendimientosPeriodo,0) as RendimientosPeriodo
,@ValorUDIsEnPesos as UDISenPesos
,isnull(@SaldoInicialPeriodo,0) as SaldoInicialPeriodo

,isnull(@SaldoPromedioDiarios,0) as SaldoPromedioDiarios
,isnull(@DiasPeriodo,0) as DiasPeriodo,

@ResumenAbonos as ResumenAbonos ,
@ResumenRendimientos as ResumenRendimientos,
@ResumenCargos as ResumenCargos,
@ResumenImpuestos as ResumenImpuestos,
@ResumenSaldoFinal  as ResumenSaldoFinal,
@InteresBrutoPeriodo as ResumenInteBrutoPerido,
@PagoAmoCapitalPeriodo as ResumenPagoCapitalAmo,
@ResumenInteresCapitalizado as ResumenInteresCapitalizado
FROM 
   (SELECT     *
		  FROM          [#Saldos] AS [#Saldos_1]
		  WHERE      (Concepto = 'Atraso Actual')
   ) AS Atrasado 
	RIGHT OUTER JOIN (SELECT     CodCuenta, FraccionCta, Renovado, SUM(AK) AS AK, SUM(AI) AS AI, SUM(AM) AS AM, SUM(AC) AS AC, SUM(AIVA) AS AIVA
					  FROM (SELECT     CodCuenta, FraccionCta, Renovado, CASE CodConcepto WHEN 'CAPI' THEN Pago ELSE 0 END AS AK, 
							CASE CodConcepto WHEN 'INTE' THEN Pago ELSE 0 END AS AI, CASE CodConcepto WHEN 'INPE' THEN Pago ELSE 0 END AS AM, 
							CASE CodConcepto WHEN 'MORA' THEN Pago ELSE 0 END AS AC, CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') 
							THEN Pago ELSE 0 END AS AIVA
							FROM (SELECT     tCsTransaccionDiaria.CodigoCuenta AS CodCuenta, tCsTransaccionDiaria.FraccionCta, 
								  tCsTransaccionDiaria.Renovado, 'CAPI' AS CodConcepto, SUM(tCsTransaccionDiaria.MontoTotalTran) AS Pago
									FROM tCsTransaccionDiaria LEFT OUTER JOIN tClOficinas AS tClOficinas_1 ON tCsTransaccionDiaria.CodOficina = tClOficinas_1.CodOficina 
									LEFT OUTER JOIN tAhClTipoTrans ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
									WHERE (tCsTransaccionDiaria.TipoTransacNivel1 = 'E') AND (tCsTransaccionDiaria.Fecha >= @PrimerCorte) AND 
											(tCsTransaccionDiaria.Fecha <= @UltimoCorte) AND (tCsTransaccionDiaria.CodSistema = 'AH') AND 											
											(tCsTransaccionDiaria.CodigoCuenta + '-' + tCsTransaccionDiaria.FraccionCta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) = @Cuenta)
									GROUP BY tCsTransaccionDiaria.CodigoCuenta, tCsTransaccionDiaria.FraccionCta, tCsTransaccionDiaria.Renovado
									) AS Datos_3) 
							AS Datos_4
							GROUP BY CodCuenta, FraccionCta, Renovado
					) AS Abonos 

	RIGHT OUTER JOIN (SELECT     CodPrestamo, SUM(CK) AS CK, SUM(CKC) AS CKC, SUM(CKI) AS CKI, SUM(CI) AS CI, SUM(CM) AS CM, SUM(CC) AS CC, SUM(CIVA) AS CIVA
					  FROM          (SELECT     Cuenta AS CodPrestamo, 
												CASE WHEN CodConcepto IN ('CAPI') THEN CargoD ELSE 0 END AS CK, 
                                                CASE WHEN CodConcepto IN ('CAPI') and Concepto not like '%Capitalizacion%' THEN CargoD ELSE 0 END AS CKC, 
                                                CASE WHEN CodConcepto IN ('CAPI') and Concepto like '%Capitalizacion%' THEN CargoD ELSE 0 END AS CKI,
                                                CASE WHEN CodConcepto IN ('INTE') THEN CargoD ELSE 0 END AS CI, 
                                                CASE WHEN CodConcepto IN ('INPE') THEN CargoD ELSE 0 END AS CM, 
												CASE WHEN CodConcepto IN ('MORA') THEN CargoD ELSE 0 END AS CC, 
                                                CASE WHEN CodConcepto IN ('IVAIT', 'IVACM', 'IVAMO') THEN CargoD ELSE 0 END AS CIVA
									 FROM          tCsEstadoCuentaMO
									 WHERE      (Cuenta = @Cuenta) AND (Fecha >= @PrimerCorte) AND (Fecha <= @UltimoCorte) AND (Sistema = 'AH')
                                    ) AS Datos
								GROUP BY CodPrestamo
                     ) AS Cargos RIGHT OUTER JOIN

						  tCsAhorros INNER JOIN
						  tClOficinas INNER JOIN
						  tCsPadronAhorros ON tClOficinas.CodOficina = tCsPadronAhorros.CodOficina INNER JOIN
						  tAhProductos ON tCsPadronAhorros.CodProducto = tAhProductos.idProducto ON tCsAhorros.CodCuenta = tCsPadronAhorros.CodCuenta AND 
						  tCsAhorros.FraccionCta = tCsPadronAhorros.FraccionCta AND tCsAhorros.Renovado = tCsPadronAhorros.Renovado 
	INNER JOIN
		(SELECT tCsAhorros_1.CodCuenta, tCsAhorros_1.FraccionCta, tCsAhorros_1.Renovado, tCsClientesAhorrosFecha_1.CodUsCuenta AS CodUsuario, 
		 tCsAhorros_1.SaldoCuenta AS MontoDesembolso, tCsClientesAhorrosFecha_1.Capital AS Monto, 
		 tCsClientesAhorrosFecha_1.Capital / tCsAhorros_1.SaldoCuenta * 100.000 AS Concentracion, tCsPadronCarteraDet.Integrantes, 
		 tCsPadronCarteraDet.ClienteGrupo, tClMonedas.DescMoneda
	FROM (SELECT     CodCuenta, FraccionCta, Renovado, COUNT(*) AS Integrantes, MAX(ClienteGrupo) AS ClienteGrupo
			   FROM (SELECT     tCsAhorros_2.CodCuenta, tCsAhorros_2.FraccionCta, tCsAhorros_2.Renovado, 
					 tCsClientesAhorrosFecha.CodUsCuenta AS CodUsuario, ISNULL(tCsPadronClientes_1.NombreCompleto, '') AS ClienteGrupo
					 FROM tCsClientesAhorrosFecha INNER JOIN
					tCsAhorros AS tCsAhorros_2 ON tCsClientesAhorrosFecha.Fecha = tCsAhorros_2.Fecha AND 
					tCsClientesAhorrosFecha.CodCuenta = tCsAhorros_2.CodCuenta AND 
					tCsClientesAhorrosFecha.FraccionCta = tCsAhorros_2.FraccionCta AND 
					tCsClientesAhorrosFecha.Renovado = tCsAhorros_2.Renovado LEFT OUTER JOIN
					tCsPadronClientes AS tCsPadronClientes_1 ON tCsAhorros_2.CodUsuario = tCsPadronClientes_1.CodUsuario
					WHERE 
                    --(tCsAhorros_2.Fecha = @UltimoCorte) AND (tCsAhorros_2.CodCuenta + '-' + CAST(tCsAhorros_2.Renovado AS varchar(5)) + '-' + tCsAhorros_2.FraccionCta = @Cuenta) ERROR
                    -- (tCsAhorros_2.Fecha = @UltimoCorte) --cambiado para soportar un rango mayo de fecha
						(tCsAhorros_2.Fecha = @fechaMax) 
                       AND (tCsAhorros_2.CodCuenta + '-' + tCsAhorros_2.FraccionCta + '-' + CAST(tCsAhorros_2.Renovado AS varchar(5)) = @Cuenta)
                     ) AS Datos_2
				GROUP BY CodCuenta, FraccionCta, Renovado
			) AS tCsPadronCarteraDet 
	INNER JOIN tCsAhorros AS tCsAhorros_1 ON tCsPadronCarteraDet.CodCuenta = tCsAhorros_1.CodCuenta AND tCsPadronCarteraDet.FraccionCta = tCsAhorros_1.FraccionCta AND tCsPadronCarteraDet.Renovado = tCsAhorros_1.Renovado
	INNER JOIN tClMonedas ON tClMonedas.CodMoneda = tCsAhorros_1.CodMoneda 
	INNER JOIN tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_1 
				ON tCsClientesAhorrosFecha_1.CodCuenta = tCsAhorros_1.CodCuenta AND 
				tCsClientesAhorrosFecha_1.FraccionCta = tCsAhorros_1.FraccionCta AND tCsClientesAhorrosFecha_1.Renovado = tCsAhorros_1.Renovado AND 
				tCsClientesAhorrosFecha_1.Fecha = tCsAhorros_1.Fecha 
	
								WHERE      (tCsAhorros_1.CodCuenta + '-' + tCsAhorros_1.FraccionCta + '-' + CAST(tCsAhorros_1.Renovado AS varchar(5)) = @Cuenta) AND 
													   --(tCsAhorros_1.Fecha = @UltimoCorte)
														(tCsAhorros_1.Fecha = @fechaMax) --cambiado para soportar un rango mayo de fecha

	) AS General INNER JOIN
						  tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_2 ON General.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta AND 
						  General.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta 
AND General.Renovado = tCsClientesAhorrosFecha_2.Renovado 
                          AND General.CodUsuario = tCsClientesAhorrosFecha_2.CodUsCuenta 
                 --INNER JOIN
left join
						  tCsPadronClientes ON tCsClientesAhorrosFecha_2.CodUsCuenta = tCsPadronClientes.CodUsuario 
INNER JOIN
						  tAhClFormaManejo ON tCsClientesAhorrosFecha_2.FormaManejo = tAhClFormaManejo.FormaManejo ON tCsAhorros.Fecha = tCsClientesAhorrosFecha_2.Fecha AND 
						  tCsAhorros.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta AND tCsAhorros.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta AND 
						  tCsAhorros.Renovado = tCsClientesAhorrosFecha_2.Renovado ON 
						  Cargos.CodPrestamo = tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) ON 
						  Abonos.CodCuenta = tCsPadronAhorros.CodCuenta AND Abonos.FraccionCta = tCsPadronAhorros.FraccionCta AND Abonos.Renovado = tCsPadronAhorros.Renovado 
						  --ON tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = Vigente.CodPrestamo
						  ON tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = Atrasado.CodPrestamo
	WHERE    (tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = @Cuenta) AND 
			 --(tCsClientesAhorrosFecha_2.Fecha = @UltimoCorte)
				(tCsClientesAhorrosFecha_2.Fecha = @fechaMax) --cambiado para soportar un rango mayo de fecha
--End

and tCsClientesAhorrosFecha_2.coordinador = 1

Drop Table #Saldos





GO