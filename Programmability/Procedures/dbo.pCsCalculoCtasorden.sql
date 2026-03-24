SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsCalculoCtasorden

CREATE Procedure [dbo].[pCsCalculoCtasorden]
@Fecha SmallDateTime, @Cartera Varchar(50), @Especifico Varchar(50) 
--Declare @Fecha 		SmallDateTime
--Declare @Cartera 	Varchar(50)
--Declare @Especifico 	Varchar(50)

--Set @Fecha 		= '20090917'
--Set @Cartera 		= 'ACTIVA'
--Set @Especifico 	= '010-122-06-00-00223'

AS
Declare @GeneraTablas	Bit

If Ltrim(Rtrim(@Especifico)) = '' 
Begin
	Set @GeneraTablas	= 0
End
Else
Begin
	Set @GeneraTablas	= 1
End

--Set nocount on

--Truncate Table tCsAnalisisCtaOrden
--Truncate Table  tCsAnalisisCtaOrdenDetalle

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DATOS1]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[DATOS1] end 


CREATE TABLE [dbo].[DATOS1] (
	[Dia] [Int] NULL ,	
	[CorteDataNegocio] [smalldatetime] NOT NULL ,
	[ProcesoFinmas] [smalldatetime] NOT NULL ,
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodUsuario] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Cuota] [int] NULL,
	[NroDiasAtraso] [int] NULL,
	[DK] [Decimal] (18, 8) NULL	 ,
	[SaldoK] [Decimal] (18, 8) NULL,
	[PagoK] [Decimal] (18, 8) NULL,
	[DIC] [Decimal] (18, 8) NULL	 ,
	[SaldoIC] [Decimal] (18, 8) NULL,
	[PagoIC] [Decimal] (18, 8) NULL,
	[SICCB] [Decimal] (18, 8) NULL,
	[SICCO] [Decimal] (18, 8) NULL,
	[DIM] [Decimal] (18, 8) NULL	 ,
	[SaldoIM] [Decimal] (18, 8) NULL,
	[PagoIM] [Decimal] (18, 8) NULL,
	[SIMCB] [Decimal] (18, 8) NULL,
	[SIMCO] [Decimal] (18, 8) NULL,
	[Observacion] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL 
) ON [PRIMARY]

ALTER TABLE [dbo].[DATOS1] WITH NOCHECK ADD 
	CONSTRAINT [PK_DATOS1] PRIMARY KEY  CLUSTERED 
	(
		[ProcesoFinmas],
		[CodPrestamo],
		[CodUsuario]
	)  ON [PRIMARY] 

Declare @FI 		SmallDateTime
Declare @FF 		SmallDateTime
Declare @PVC 		SmallDateTime
Declare @PVM 		SmallDateTime

Declare @CodPrestamo 	Varchar(50)
Declare @CodUsuario	Varchar(15)
Declare @Dia		Int
Declare @DIC		Decimal(18, 8)
Declare @DIM		Decimal(18, 8)
Declare @PI		Decimal(18, 8)
Declare @CT		Int
Declare @CP		Int
Declare @CA		Int

Declare @TIM		Decimal(18, 8)		 
Declare @NDA		Int

Declare @TempD		Decimal(18, 8)
Declare @TempDD		Decimal(18, 8)
Declare @TempI		Int
Declare @TempII		Int

Declare @Cadena		Varchar(4000)
Declare @UltimoDia	Int

--Variables creadas para soportar proceso en forma diaria
Declare @Contador	Int
Declare @tempFI		SmallDateTime
Declare @Antiguo	Varchar(25)
Declare @Nuevo		Varchar(25)

Set @FF = @Fecha

Declare curFragmento Cursor For 	
	SELECT  Datos.CodPrestamo, Datos.CodUsuario, Inicio.Inicio, Datos.NroCuotas, Datos.NroCuotasPagadas
	FROM         (SELECT     tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCarteraDet.CodUsuario, tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas
	                       FROM          tCsCarteraDet INNER JOIN
	                                              tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	                       WHERE      (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Cartera = @Cartera) AND (tCsCartera.Estado = 'VENCIDO')) Datos LEFT OUTER JOIN
	                          (SELECT     CodPrestamo, MIN(FechaInicio) AS Inicio
	                            FROM          tCsPadronPlanCuotas
	                            GROUP BY CodPrestamo) Inicio ON Datos.CodPrestamo = Inicio.CodPrestamo COLLATE Modern_Spanish_CI_AI	
	--Where Datos.codPrestamo like '%'+ @Especifico +'%'
	--Where Datos.codPrestamo in (select distinct codPrestamo from tcsanalisisctaorden where cortedatanegocio <> @Fecha ) --And Datos.CodUsuario = 'DCA2507601'
	WHERE     (Datos.CodPrestamo NOT IN (SELECT DISTINCT CodPrestamo FROM  tCsAnalisisCtaordenDetalle))
Open curFragmento
Fetch Next From curFragmento Into @CodPrestamo, @CodUsuario, @FI, @CT, @CP
While @@Fetch_Status = 0
Begin 
	Print 'CodPrestamo 	: ' + @CodPrestamo 
	Print 'CodUsuario	: ' + @CodUsuario

	Set @Antiguo 	= Null
	Set @Nuevo 	= Null

	SELECT  @Antiguo = MAX(Pago), @Nuevo = MAX(Padron) 
	FROM         (SELECT     Filtro.CodUsuario AS Pago, tCsPadronCarteraDet.CodUsuario AS Padron, ISNULL(Filtro.CodPrestamo, tCsPadronCarteraDet.CodPrestamo) 
	                                              AS CodPrestamo
	                       FROM          (SELECT DISTINCT CodPrestamo, CodUsuario
	                                               FROM          tCsPagoDet
	                                               WHERE      (CodPrestamo = @CodPrestamo)) Filtro FULL OUTER JOIN
	                                                  (SELECT     *
	                                                    FROM          tCsPadronCarteraDet
	                                                    WHERE      (tCsPadronCarteraDet.CodPrestamo = @CodPrestamo)) tCsPadronCarteraDet ON 
	                                              Filtro.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND 
	                                              Filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodUsuario
	                       WHERE      (Filtro.CodUsuario IS NULL) OR
	                                              (tCsPadronCarteraDet.CodUsuario IS NULL)) Datos
	GROUP BY CodPrestamo
	HAVING      (COUNT(*) = 2)


	If @Antiguo Is Not Null And @Nuevo Is Not Null
	Begin
		UPDATE tCsCartera		Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo
		UPDATE tCsCartera01		Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo
		UPDATE tCsCarteraDet		Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo
		UPDATE tCsCaSegCartera	Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo
		UPDATE tCsOpRecuperablesDet	Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo	
		UPDATE tCsPadronPlanCuotas	Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo	
		UPDATE tCsPlanCuotas		Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo
		UPDATE tCsPrestamoCodeudor	Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodPrestamo = @CodPrestamo	
		UPDATE tCsTransaccionDiaria	Set CodUsuario = @Nuevo Where CodUsuario = @Antiguo And CodigoCuenta = @CodPrestamo
	End

	SELECT  @TIM =  TasaINPE
	FROM         tCsCartera
	WHERE     (CodPrestamo = @CodPrestamo) AND (Fecha = @FF)

	Update tCscartera
	Set TasaINPE =  @TIM
	WHERE     (CodPrestamo = @CodPrestamo) And TasaINPE <> @TIM

	Set @NDA	= 0 
	Set @Contador 	= 0

	SELECT     @Contador = Count(*), @Dia = Filtro.Dia
	FROM         (SELECT     codprestamo, CodUsuario, MAX(Dia) AS Dia
	                       FROM          tCsAnalisisCtaOrdenDetalle
	                       WHERE      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)
	                       GROUP BY codprestamo, Codusuario) filtro INNER JOIN
	                      tCsAnalisisCtaOrdenDetalle ON filtro.codprestamo COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodPrestamo AND 
	                      filtro.Dia = tCsAnalisisCtaOrdenDetalle.Dia AND filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodUsuario
	WHERE     (tCsAnalisisCtaOrdenDetalle.Observacion = '[0.00000000]-[0.00000000]-[0.00000000]')
	GROUP BY filtro.Dia, tCsAnalisisCtaOrdenDetalle.NroDiasAtraso
	
	If @Contador Is Null Begin Set @Contador = 0 End

	If @Contador = 0
	Begin
		Print 'Eliminacion Total'
		Delete From tCsAnalisisCtaOrdenDetalle Where Codprestamo = @CodPrestamo And CodUsuario = @CodUsuario
	End
	Else
	Begin
		Print 'Eliminacion Parcial'
		Delete From tCsAnalisisCtaOrdenDetalle Where Codprestamo = @CodPrestamo And CodUsuario = @CodUsuario and Dia = @Dia
	End	

	Set @Dia = Null

	SELECT @Dia = Filtro.Dia +  1, @tempFI = tCsAnalisisCtaOrdenDetalle.ProcesoFinmas + 1, @NDA = tCsAnalisisCtaOrdenDetalle.NroDiasAtraso 
	FROM         (SELECT     CodPrestamo, CodUsuario, MAX(Dia) AS Dia
	                       FROM          tCsAnalisisCtaOrdenDetalle
	                       WHERE      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)
	                       GROUP BY CodPrestamo, CodUsuario) Filtro INNER JOIN
	                      tCsAnalisisCtaOrdenDetalle ON Filtro.Dia = tCsAnalisisCtaOrdenDetalle.Dia AND 
	                      Filtro.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodPrestamo AND 
	                      Filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodUsuario	
	
	Print '@Dia: ' 	+  Cast(@Dia as Varchar(10))
	Print '@FI: ' 	+  Cast(@FI as Varchar(50))	

	If @Dia Is Null 
	Begin 
		Set @Dia 	= 1 
	End
	Else
	Begin
		Set @FI 	= @tempFI	
	End
	If @Dia = 1 Or @NDA Is Null
	Begin
		Set @NDA 	= 0
	End	
	If @NDA >= 90
	Begin
		Set @PVC		= @FI - @NDA + 90 - 1	--
		Set @PVM		= @FI - @NDA + 90 - 1	--
	End 
	Else
	Begin
		Set @PVC		= @Fecha + 1	--
		Set @PVM		= @Fecha + 1	--
	End
	Print '@Dia: ' 	+  Cast(@Dia as Varchar(10))
	Print '@FI: ' 	+  Cast(@FI as Varchar(50))	

	SELECT @TempI = Min(SecCuota)
	FROM tCsPadronPlanCuotas
	WHERE (CodPrestamo = @CodPrestamo) AND (FechaInicio <= @FI) AND (FechaVencimiento >= @FI)

	If @TempI Is Null Begin Set @TempI = 0  End
	
	If @TempI <> 0
	Begin
		SELECT   @TempDD = tCsAnalisisCtaOrdenDetalle.SaldoK
		FROM         (SELECT     CodPrestamo, CodUsuario, MAX(Dia) AS Dia
		                       FROM          tCsAnalisisCtaOrdenDetalle
		                       WHERE      (Cuota <> @TempI)
		                       GROUP BY CodPrestamo, CodUsuario
		                       HAVING      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)) corte INNER JOIN
		                      tCsAnalisisCtaOrdenDetalle ON corte.Dia = tCsAnalisisCtaOrdenDetalle.Dia AND 
		                      corte.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodPrestamo AND 
		                      corte.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodUsuario
	End
	Else
	Begin
		SELECT   @TempDD = tCsAnalisisCtaOrdenDetalle.SaldoK
		FROM         (SELECT     CodPrestamo, CodUsuario, MAX(Dia) AS Dia
		                       FROM          tCsAnalisisCtaOrdenDetalle
		                       WHERE      (Cuota = @TempI)
		                       GROUP BY CodPrestamo, CodUsuario
		                       HAVING      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)) corte INNER JOIN
		                      tCsAnalisisCtaOrdenDetalle ON corte.Dia = tCsAnalisisCtaOrdenDetalle.Dia AND 
		                      corte.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodPrestamo AND 
		                      corte.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrdenDetalle.CodUsuario
	End

	If @TempI = 1 Begin Set @TempDD = 0 end 

	If @TempDD Is Null Begin Set @TempDD 	= 0  End
	Set @TempII				= 0		--
	Set @TempD				= 0		--		
	Set @UltimoDia 				= 0		--

	SELECT  @DIC = AVG(MontoCuota / DATEDIFF([day], FechaInicio, FechaVencimiento)) 
	FROM         tCsPadronPlanCuotas
	WHERE     (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (CodConcepto IN ('INTE'))

	--Se actualizan pagos del FINMAS 
	--[BD-FINAMIGO-SRV].Finmas.dbo.
	--[DC-FINAMIGO-SRV].Finamigo_Conta_AAs.dbo.
	/*
	INSERT INTO tCsPagoDet
	                      (Fecha, CodOficina, CodPrestamo, SecPago, SecCuota, CodConcepto, CodUsuario, MontoPagado, OficinaTransaccion, Extornado)
	SELECT     R.FechaPago, P.CodOficina, P.CodPrestamo, D.SecPago, D.SecCuota, D.CodConcepto, (CASE WHEN isnumeric(LEFT(D.CodUsuario, 2)) 
	                      = 1 THEN substring(D.CodUsuario, 3, 13) ELSE substring(D.CodUsuario, 2, 14) END) AS CodUsuario, D.MontoPagado, D.CodOficina AS Expr1, R.Extornado
	FROM         [BD-FINAMIGO-SRV].Finmas.dbo.tCaPagoDet D INNER JOIN
	                      [BD-FINAMIGO-SRV].Finmas.dbo.tCaPagoReg R ON D.CodOficina = R.CodOficina AND D.SecPago = R.SecPago INNER JOIN
	                      [BD-FINAMIGO-SRV].Finmas.dbo.tCaPrestamos P ON R.CodPrestamo = P.CodPrestamo
	WHERE     (R.CodPrestamo = @CodPrestamo) AND (R.FechaPago IN
	                          (SELECT DISTINCT Datos.UltimoMovimiento
	                            FROM          (SELECT DISTINCT CodPrestamo, UltimoMovimiento
	                                                    FROM          tCsCarteraDet
	                                                    WHERE      (CodPrestamo = @CodPrestamo)) Datos LEFT OUTER JOIN
	                                                   tCsPagoDet ON Datos.UltimoMovimiento = tCsPagoDet.Fecha AND 
	                                                   Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPagoDet.CodPrestamo
	                            WHERE      (tCsPagoDet.Fecha IS NULL)))
	*/
	Insert Into Datos1 
	Select * from tCsAnalisisCtaOrdenDetalle
	Where Codprestamo = @CodPrestamo And CodUsuario = @CodUsuario 

	Print @@RowCount

	While @FI <= @FF + 1
	Begin	
		If @Dia = 140
		Begin
			Print 'Pare @Dia : ' 	+  Cast(@Dia as Varchar(10))		
		End
		Print '@Dia: ' 	+  Cast(@Dia as Varchar(10))
		Print '@FI: ' 	+  Cast(@FI as Varchar(50))	
		If @Dia = 1
		Begin		
			Insert Into Datos1 (Dia, ProcesoFinmas, CorteDataNegocio, CodPrestamo, CodUsuario, DIC, Observacion) VALUES (@Dia, @FI, @FI- 1, @CodPrestamo, @CodUsuario, 0, 'Ingreso primer día')
		End
		Else
		Begin
			Insert Into Datos1 (Dia, ProcesoFinmas, CorteDataNegocio, CodPrestamo, CodUsuario, DIC, Observacion) VALUES (@Dia, @FI, @FI- 1, @CodPrestamo, @CodUsuario, @DIC, 'Ingreso Normal')
		End		
		If @FI = @FF + 1
		Begin
			Set @UltimoDia = 1
		End

		SELECT @CA = Min(SecCuota)
	        FROM tCsPadronPlanCuotas
	        WHERE (CodPrestamo = @CodPrestamo) AND (FechaInicio <= @FI) AND (FechaVencimiento >= @FI)

		If @CA is null Begin Set @CA = 0 end
		Print '@CA: ' +  Cast(@CA as Varchar(50))
		If @CA <> 0
		Begin
			Print 'Calculando Cuota'
			Update Datos1
			Set Cuota = @CA, Observacion = 'Calculando Cuota'
			Where Cuota Is null and Codprestamo = @Codprestamo and CodUsuario = @CodUsuario and ProcesoFinmas = @FI
		End
		Else
		Begin
			Print 'Fuera del Rango del Plan de Cuotas'			
			Update Datos1
			Set Cuota = @CA, DIC = 0, Observacion = 'Fuera del Rango del Plan de Cuotas'
			Where Cuota Is null and Codprestamo = @Codprestamo and CodUsuario = @CodUsuario and ProcesoFinmas = @FI
		End
		--Analizando Capital
		Set @PI = 0
		SELECT  @PI	=  MontoCuota
		FROM         (SELECT     FechaInicio + 1 AS Fecha, MontoCuota
		                       FROM          tCsPadronPlanCuotas
		                       WHERE      (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (CodConcepto = 'CAPI')) Datos
		WHERE     (Fecha = @FI)
		
		If @PI Is null Begin Set @PI = 0 End
				
		UPDATE 	Datos1
		SET 	DK = @PI
		WHERE 	(DATOS1.ProcesoFinmas = @FI)  And (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)		

		SELECT 	@PI  = SUM(MontoPagado)
		FROM 	tCsPagoDet
		WHERE 	(CodPrestamo = @CodPrestamo) AND (Extornado = 0) AND (CodUsuario = @Codusuario) AND (CodConcepto = 'CAPI') AND (Fecha = @FI)

		If @PI Is null Begin Set @PI = 0 End
		
		Set @TempD = @PI

		UPDATE    datos1
		SET       PagoK = @PI
		WHERE     (DATOS1.ProcesoFinmas = @FI)  And (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)				

		UPDATE    datos1
		SET              SaldoK = Round(D.SaldoIC, 2)
		FROM         (SELECT     SUM(DK) - Sum(PagoK) AS SaldoIC, CodPrestamo, CodUsuario
		                       FROM          DATOS1
		                       WHERE      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (ProcesoFinmas <= @FI)
		                       GROUP BY CodPrestamo, CodUsuario) D INNER JOIN
		                      DATOS1 ON D .CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
		                      D .CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
		WHERE     (DATOS1.ProcesoFinmas = @FI) 

		--Analizando Interes Corriente
		SELECT   @PI  = Isnull(SUM(MontoPagado), 0)
		FROM         tCsPagoDet
		WHERE     (CodPrestamo = @CodPrestamo) AND (Extornado = 0) AND (CodUsuario = @Codusuario) AND (CodConcepto = 'INTE') AND (Fecha = @FI)

		If @PI Is null Begin Set @PI = 0 End
		
		SELECT   @PI  = Isnull(SUM(MontoOp), 0) + @PI
		FROM         tCsOpRecuperablesDet
		WHERE     (CodPrestamo = @CodPrestamo) AND (CodUsuario = @Codusuario) AND (CodConcepto = 'INTE') AND (Fecha = @FI)

		If @PI Is null Begin Set @PI = 0 End

		UPDATE    datos1
		SET              PagoIC = @PI
		WHERE     (DATOS1.ProcesoFinmas = @FI)  And (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)
		
		UPDATE    datos1
		SET              SaldoIC = Round(D.SaldoIC, 2)
		FROM         (SELECT     Round(SUM(DIC), 2) - Round(Sum(PagoIC), 2) AS SaldoIC, CodPrestamo, CodUsuario
		                       FROM          DATOS1
		                       WHERE      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (ProcesoFinmas <= @FI)
		                       GROUP BY CodPrestamo, CodUsuario) D INNER JOIN
		                      DATOS1 ON D .CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
		                      D .CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
		WHERE     (DATOS1.ProcesoFinmas = @FI) 	

		SELECT  @PI  = SaldoIC
		FROM         DATOS1
		WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)

		If Abs(@PI) = 0.01 
		Begin
			UPDATE    Datos1
			SET              DIC = DATOS1.PagoIC - Datos.SaldoIC
			FROM         (SELECT     procesofinmas = procesofinmas + 1, CodPrestamo, CodUsuario, SaldoIC
			                       FROM          DATOS1
			                       WHERE      (procesofinmas = @FI - 1) AND (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)) Datos INNER JOIN
			                      DATOS1 ON Datos.procesofinmas = DATOS1.ProcesoFinmas AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
			                      Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario   

			UPDATE    datos1
			SET              SaldoIC = Round(D.SaldoIC, 2)
			FROM         (SELECT     SUM(DIC) - Sum(PagoIC) AS SaldoIC, CodPrestamo, CodUsuario
			                       FROM          DATOS1
			                       WHERE      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (ProcesoFinmas <= @FI)
			                       GROUP BY CodPrestamo, CodUsuario) D INNER JOIN
			                      DATOS1 ON D .CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
			                      D .CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
			WHERE     (DATOS1.ProcesoFinmas = @FI) 	
		End
		Print '@TempI = ' + Cast(@TempI as Varchar(50)) + ', @CA = ' + Cast(@CA as Varchar(50)) + ', @CP = ' + Cast(@CP as Varchar(50)) + ', @TempD = ' + Cast(@TempD as Varchar(50)) 
		UPDATE    Datos1
		SET       Observacion  = '@TempI = ' + Cast(@TempI as Varchar(50)) + ', @CA = ' + Cast(@CA as Varchar(50)) + ', @CP = ' + Cast(@CP as Varchar(50)) + ', @TempD = ' + Cast(@TempD as Varchar(50)) 
		WHERE     (DATOS1.ProcesoFinmas = @FI)  And (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)

		--Analizando Interes Moratorio		
		If @TempI <> @CA 
		Begin
			SELECT  @PI  = SaldoK
			FROM         DATOS1
			WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI - 1)	
			
			Set @TempDD = @PI
			Set @TempI  = @TempI + 1			
		End
		If @TempDD < 0 Begin Set @TempDD = 0 End
		If @TempDD > 0 
		Begin
			Set @NDA = @NDA + 1
		End
		Else
		Begin
			Set @NDA = 0
		End
		Print '@TIM/360/100*@TempDD = ' + Cast(@TIM as Varchar(50)) +  '/360/100*' + Cast(@TempDD as Varchar(50))
		Update Datos1
		Set DIM = @TIM / 360 / 100 * @TempDD,
		Observacion = '@TIM/360/100*@TempDD = ' + Cast(@TIM as Varchar(50)) +  '/360/100*' + Cast(@TempDD as Varchar(50)),
		NroDiasAtraso = @NDA
		Where Codprestamo = @Codprestamo and CodUsuario = @CodUsuario and ProcesoFinmas = @FI
		
		Set @TempDD = @TempDD - @TempD

		SELECT   @PI  = Isnull(SUM(MontoPagado), 0)
		FROM         tCsPagoDet
		WHERE     (CodPrestamo = @CodPrestamo) AND (Extornado = 0) AND (CodUsuario = @Codusuario) AND (CodConcepto = 'INPE') AND (Fecha = @FI)
		
		If @PI Is null Begin Set @PI = 0 End

		SELECT   @PI  = Isnull(SUM(MontoOp), 0) + @PI
		FROM         tCsOpRecuperablesDet
		WHERE     (CodPrestamo = @CodPrestamo) AND (CodUsuario = @Codusuario) AND (CodConcepto = 'INPE') AND (Fecha = @FI)

		If @PI Is null Begin Set @PI = 0 End
		
		UPDATE    datos1
		SET              PagoIM = @PI
		WHERE     (DATOS1.ProcesoFinmas = @FI)  And (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)
		
		UPDATE    datos1
		SET              SaldoIM = Round(D.SaldoIC, 2)
		FROM         (SELECT     SUM(DIM) - Sum(PagoIM) AS SaldoIC, CodPrestamo, CodUsuario
		                       FROM          DATOS1
		                       WHERE      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (ProcesoFinmas <= @FI)
		                       GROUP BY CodPrestamo, CodUsuario) D INNER JOIN
		                      DATOS1 ON D .CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
		                      D .CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
		WHERE     (DATOS1.ProcesoFinmas = @FI) 	

		SELECT  @PI  = SaldoIM
		FROM         DATOS1
		WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)

		If Abs(@PI) = 0.01 
		Begin
			UPDATE    Datos1
			SET              DIM = DATOS1.PagoIM - Datos.SaldoIM
			FROM         (SELECT     procesofinmas = procesofinmas + 1, CodPrestamo, CodUsuario, SaldoIM
			                       FROM          DATOS1
			                       WHERE      (procesofinmas = @FI - 1) AND (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)) Datos INNER JOIN
			                      DATOS1 ON Datos.procesofinmas = DATOS1.ProcesoFinmas AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
			                      Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario   
			Where DATOS1.PagoIM - Datos.SaldoIM <> 0

			UPDATE    datos1
			SET              SaldoIM = Round(D.SaldoIC, 2)
			FROM         (SELECT     SUM(DIM) - Sum(PagoIM) AS SaldoIC, CodPrestamo, CodUsuario
			                       FROM          DATOS1
			                       WHERE      (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (ProcesoFinmas <= @FI)
			                       GROUP BY CodPrestamo, CodUsuario) D INNER JOIN
			                      DATOS1 ON D .CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
			                      D .CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
			WHERE     (DATOS1.ProcesoFinmas = @FI) 	
		End

		If @UltimoDia = 1
		Begin
		 	--Print 'INGRESO A ULTIMO DIA'
			Set @PI = 0 

			Select @PI = tCsCarteraDet.SaldoInteres
			FROM         DATOS1 INNER JOIN
			                      tCsCarteraDet ON DATOS1.CorteDataNegocio = tCsCarteraDet.Fecha AND DATOS1.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
			                      DATOS1.CodUsuario = tCsCarteraDet.CodUsuario
			WHERE   (DATOS1.CodPrestamo = @CodPrestamo) AND (DATOS1.CodUsuario = @CodUsuario) AND (DATOS1.ProcesoFinmas = @FI) 
				And ABS(DATOS1.SaldoIC - tCsCarteraDet.SaldoInteres) <= 0.05 
			--Print @FI
			--Print @PI
			If @PI is null Begin Set @PI = 0 End
						
			If @PI <> 0 
			Begin
				Update DATOS1
				Set SaldoIC = @PI 
				WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)
				
				UPDATE    Datos1
				SET              DIC = DATOS1.SaldoIC - filtro.SaldoIC + DATOS1.PagoIC
				FROM         (SELECT     ProcesoFinmas + 1 AS ProcesoFinmas, CodPrestamo, CodUsuario, SaldoIC
				                       FROM          DATOS1
				                       WHERE      (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI - 1)) filtro INNER JOIN
				                      DATOS1 ON filtro.ProcesoFinmas = DATOS1.ProcesoFinmas AND filtro.CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
				                      filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
			End

			Set @PI = 0 

			Select @PI = tCsCarteraDet.SaldoMoratorio
			FROM         DATOS1 INNER JOIN
			                      tCsCarteraDet ON DATOS1.CorteDataNegocio = tCsCarteraDet.Fecha AND DATOS1.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
			                      DATOS1.CodUsuario = tCsCarteraDet.CodUsuario
			WHERE   (DATOS1.CodPrestamo = @CodPrestamo) AND (DATOS1.CodUsuario = @CodUsuario) AND (DATOS1.ProcesoFinmas = @FI) 
				And ABS(DATOS1.SaldoIM - tCsCarteraDet.SaldoMoratorio) <= 0.05 
			--Print @FI
			--Print @PI
			If @PI is null Begin Set @PI = 0 End
						
			If @PI <> 0 
			Begin
				Update DATOS1
				Set SaldoIM = @PI 
				WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)
				
				UPDATE    Datos1
				SET              DIM = DATOS1.SaldoIM - filtro.SaldoIM + DATOS1.PagoIM
				FROM         (SELECT     ProcesoFinmas + 1 AS ProcesoFinmas, CodPrestamo, CodUsuario, SaldoIM
				                       FROM          DATOS1
				                       WHERE      (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI - 1)) filtro INNER JOIN
				                      DATOS1 ON filtro.ProcesoFinmas = DATOS1.ProcesoFinmas AND filtro.CodPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
				                      filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
			End


		End
		
		If @NDA = 90 
		Begin 
			Set @PVC = @FI 
			Set @PVM = @FI
		End		
		If @NDA < 90 
		Begin 
			Set @PVC = @Fecha +  1
			Set @PVM = @Fecha +  1 
		End	

		UPDATE    datos1
		SET              SICCB = round(DATOS1.SaldoIC - ISNULL(Datos.CO, 0), 2), SICCO = Round(ISNULL(Datos.CO, 0), 2)
			--, Observacion = Cast(@PVC as Varchar(100))
		FROM         (SELECT     codPrestamo, codusuario, Case When SUM(DIC) - sum(PagoIC) <= 0 Then 0 else SUM(DIC) - sum(PagoIC) End  AS CO
		                       FROM          DATOS1
		                       WHERE      (ProcesoFinmas >= @PVC) AND (ProcesoFinmas <= @FI) AND codprestamo = @CodPrestamo AND codusuario = @CodUsuario
		                       GROUP BY codusuario, codprestamo) Datos RIGHT OUTER JOIN
		                      DATOS1 ON Datos.codPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
		                      Datos.codusuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
		WHERE     (DATOS1.ProcesoFinmas = @FI)	

		UPDATE    datos1
		SET             SIMCB = Round(DATOS1.SaldoIM - ISNULL(Datos.CO, 0), 2), SIMCO = Round(ISNULL(Datos.CO, 0), 2) 
		FROM         (SELECT     codPrestamo, codusuario, Case When SUM(DIM) - sum(PagoIM) <= 0 Then 0 else SUM(DIM) - sum(PagoIM) End  AS CO
		                       FROM          DATOS1
		                       WHERE      (ProcesoFinmas >= @PVM) AND (ProcesoFinmas <= @FI) AND codprestamo = @CodPrestamo AND codusuario = @CodUsuario
		                       GROUP BY codusuario, codprestamo) Datos RIGHT OUTER JOIN
		                      DATOS1 ON Datos.codPrestamo COLLATE Modern_Spanish_CI_AI = DATOS1.CodPrestamo AND 
		                      Datos.codusuario COLLATE Modern_Spanish_CI_AI = DATOS1.CodUsuario
		WHERE     (DATOS1.ProcesoFinmas = @FI)	

		SELECT  @PI  = SICCO
		FROM         DATOS1
		WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)

		If @PI = 0 
		Begin
			Set @PVC = @FI + 1
		End

		SELECT  @PI  = SIMCO
		FROM         DATOS1
		WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)

		If @PI = 0 
		Begin
			Set @PVM = @FI + 1 
		End
		--CALCULO DE CUENTA DE BALANCE IC
		UPDATE    DATOS1
		SET SICCB = SaldoIC - SICCO
		WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (SICCB + SICCO <> SaldoIC) And ProcesoFinmas = @FI 	

		SELECT  @PI  = SICCB
		FROM         DATOS1
		WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)

		If @PI < 0 
		Begin
			UPDATE    DATOS1
			SET SICCO = SICCO + @PI
			WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) And ProcesoFinmas = @FI 	
			UPDATE    DATOS1
			SET SICCB = 0
			WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) And ProcesoFinmas = @FI 	
		End
		
		UPDATE    DATOS1
		SET 	SICCO = SICCO + 0.01, SICCB = 0
		WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) And ProcesoFinmas = @FI And SICCO > 0 and SICCB = 0.01 
		
		--CALCULO DE CUENTA DE BALANCE IM
		UPDATE    DATOS1
		SET SIMCB = SaldoIM - SIMCO
		WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) AND (SIMCB + SIMCO <> SaldoIM) And ProcesoFinmas = @FI 	

		SELECT  @PI  = SIMCB
		FROM         DATOS1
		WHERE     (CodUsuario = @CodUsuario) AND (CodPrestamo = @CodPrestamo) AND (ProcesoFinmas = @FI)

		If @PI < 0 
		Begin
			UPDATE    DATOS1
			SET SIMCO = SIMCO + @PI
			WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) And ProcesoFinmas = @FI 	
			UPDATE    DATOS1
			SET SIMCB = 0
			WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) And ProcesoFinmas = @FI 	
		End
		
		UPDATE    DATOS1
		SET 	SIMCO = SIMCO + 0.01, SIMCB = 0
		WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario) And ProcesoFinmas = @FI And SIMCO > 0 and SIMCB = 0.01 	

		Set @FI 	= @FI 	+ 1
		Set @Dia 	= @Dia 	+ 1
	End

	UPDATE    datos1
	Set 	DIM = DIM - (DATOS1.SaldoIM - tCsCarteraDet.SaldoMoratorio)
	FROM         DATOS1 INNER JOIN
	                      tCsCarteraDet ON DATOS1.CorteDataNegocio = tCsCarteraDet.Fecha AND DATOS1.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
	                      DATOS1.CodUsuario = tCsCarteraDet.CodUsuario
	WHERE   (DATOS1.CodPrestamo = @CodPrestamo) AND (DATOS1.CodUsuario = @CodUsuario) AND (DATOS1.CorteDataNegocio = @FF) 
		And ABS(DATOS1.SaldoIM - tCsCarteraDet.SaldoMoratorio) = 0.01

	UPDATE    datos1
	SET              Observacion ='[' + CAST(DATOS1.SaldoK - tCsCarteraDet.SaldoCapital AS Varchar(50)) + ']-[' + CAST(DATOS1.SaldoIC - tCsCarteraDet.SaldoInteres AS Varchar(50)) + ']-[' + CAST(DATOS1.SaldoIM - tCsCarteraDet.SaldoMoratorio AS Varchar(50)) + ']'
	FROM         DATOS1 INNER JOIN
	                      tCsCarteraDet ON DATOS1.CorteDataNegocio = tCsCarteraDet.Fecha AND DATOS1.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
	                      DATOS1.CodUsuario = tCsCarteraDet.CodUsuario
	WHERE     (DATOS1.CodPrestamo = @CodPrestamo) AND (DATOS1.CodUsuario = @CodUsuario) AND (DATOS1.CorteDataNegocio = @FF)

	Delete From tCsAnalisisCtaOrden WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)

	Insert Into tCsAnalisisCtaOrden
	SELECT     DATOS1.Dia, DATOS1.CorteDataNegocio, DATOS1.ProcesoFinmas, DATOS1.CodPrestamo, DATOS1.CodUsuario, DATOS1.Cuota, DATOS1.NroDiasAtraso, DATOS1.DK, 
	                      DATOS1.SaldoK, DATOS1.PagoK, DATOS1.DIC, DATOS1.SaldoIC, DATOS1.PagoIC, DATOS1.SICCB, DATOS1.SICCO, DATOS1.DIM, DATOS1.SaldoIM, DATOS1.PagoIM, 
	                      DATOS1.SIMCB, DATOS1.SIMCO, DATOS1.Observacion, tCsCarteraDet.SaldoCapital, tCsCarteraDet.InteresVigente, tCsCarteraDet.InteresVencido, tCsCarteraDet.InteresCtaOrden, 
	                      tCsCarteraDet.MoratorioVigente, tCsCarteraDet.MoratorioVencido, tCsCarteraDet.MoratorioCtaOrden
	FROM         DATOS1 INNER JOIN
	                      tCsCarteraDet ON DATOS1.CodPrestamo = tCsCarteraDet.CodPrestamo AND DATOS1.CodUsuario = tCsCarteraDet.CodUsuario AND 
	                      DATOS1.CorteDataNegocio = tCsCarteraDet.Fecha
	WHERE     (DATOS1.CodPrestamo = @CodPrestamo) AND (DATOS1.CodUsuario = @CodUsuario) AND (DATOS1.CorteDataNegocio = @FF)

	UPDATE    tcsanalisisctaorden
	SET              SaldoK = Saldo
	FROM         (SELECT     tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.CodUsuario, tCsPadronCarteraDet.Monto - ISNULL(Datos.Pago, 0) AS Saldo
	                       FROM          (SELECT     CodPrestamo, CodUsuario, SUM(MontoPagado) AS Pago
	                                               FROM          tCsPagoDet
	                                               WHERE      (CodPrestamo = @CodPrestamo) AND (CodConcepto = 'CAPI') AND (Extornado = 0) AND (CodUsuario = @CodUsuario) AND 
	                                                                      (Fecha <= @FF)
	                                               GROUP BY CodPrestamo, CodUsuario
	                                               UNION
	                                               SELECT     tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodUsuario, SUM(tCsOpRecuperablesDet.MontoOp) AS Condonado
	                                               FROM         tCsOpRecuperablesDet INNER JOIN
	                                                                     tCsOpRecuperables ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND 
	                                                                     tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND 
	                                                                     tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo
	                                               WHERE     (tCsOpRecuperables.TipoOp = '002') AND (tCsOpRecuperablesDet.Fecha <= @FF) AND (tCsOpRecuperablesDet.CodConcepto = 'CAPI')
	                                               GROUP BY tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodUsuario
	                                               HAVING      (tCsOpRecuperablesDet.CodPrestamo = @CodPrestamo) AND (tCsOpRecuperablesDet.CodUsuario = @CodUsuario)) 
	                                              Datos RIGHT OUTER JOIN
	                                              tCsPadronCarteraDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND 
	                                              Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodUsuario
	                       WHERE      (tCsPadronCarteraDet.CodPrestamo = @CodPrestamo) AND (tCsPadronCarteraDet.CodUsuario = @CodUsuario)) Datos INNER JOIN
	                      tCsAnalisisCtaOrden ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrden.CodPrestamo AND 
	                      Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsAnalisisCtaOrden.CodUsuario
	WHERE     (tCsAnalisisCtaOrden.CorteDataNegocio = @FF) AND Observacion <> '[0.00000000]-[0.00000000]-[0.00000000]'

	UPDATE    tCsAnalisisCtaOrden
	SET              Observacion ='[' + CAST(tCsAnalisisCtaOrden.SaldoK - tCsCarteraDet.SaldoCapital AS Varchar(50)) + ']-[' + CAST(tCsAnalisisCtaOrden.SaldoIC - tCsCarteraDet.SaldoInteres AS Varchar(50)) + ']-[' + CAST(tCsAnalisisCtaOrden.SaldoIM - tCsCarteraDet.SaldoMoratorio AS Varchar(50)) + ']'
	FROM     tCsAnalisisCtaOrden INNER JOIN
	                      tCsCarteraDet ON tCsAnalisisCtaOrden.CorteDataNegocio = tCsCarteraDet.Fecha AND tCsAnalisisCtaOrden.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
	                      tCsAnalisisCtaOrden.CodUsuario = tCsCarteraDet.CodUsuario
	WHERE     (tCsAnalisisCtaOrden.CodPrestamo = @CodPrestamo) AND (tCsAnalisisCtaOrden.CodUsuario = @CodUsuario) AND (tCsAnalisisCtaOrden.CorteDataNegocio = @FF)

	If exists (select * from dbo.sysobjects where id = object_id(N'[dbo].['+ @CodPrestamo + @CodUsuario  +']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin Set @Cadena = 'drop table ['+ @CodPrestamo + @CodUsuario  +']' Exec(@Cadena) end 
	
	If @GeneraTablas = 1
	Begin
		Set @Cadena = 'Select * Into [' + @CodPrestamo + @CodUsuario  + '] from Datos1'
		Exec (@Cadena)
	End	

	Delete From tCsAnalisisCtaOrdenDetalle WHERE (CodPrestamo = @CodPrestamo) AND (CodUsuario = @CodUsuario)
 
	Insert Into tCsAnalisisCtaOrdenDetalle
	Select * From Datos1

	UPDATE    tCsAnalisisCtaOrdenDetalle
	SET              Observacion = tCsAnalisisCtaOrden.Observacion
	FROM         tCsAnalisisCtaOrden INNER JOIN
	                      tCsAnalisisCtaOrdenDetalle ON tCsAnalisisCtaOrden.Dia = tCsAnalisisCtaOrdenDetalle.Dia AND 
	                      tCsAnalisisCtaOrden.CorteDataNegocio = tCsAnalisisCtaOrdenDetalle.CorteDataNegocio AND 
	                      tCsAnalisisCtaOrden.ProcesoFinmas = tCsAnalisisCtaOrdenDetalle.ProcesoFinmas AND 
	                      tCsAnalisisCtaOrden.CodPrestamo = tCsAnalisisCtaOrdenDetalle.CodPrestamo AND tCsAnalisisCtaOrden.CodUsuario = tCsAnalisisCtaOrdenDetalle.CodUsuario AND 
	                      tCsAnalisisCtaOrden.Cuota = tCsAnalisisCtaOrdenDetalle.Cuota AND tCsAnalisisCtaOrden.NroDiasAtraso = tCsAnalisisCtaOrdenDetalle.NroDiasAtraso
	WHERE     (tCsAnalisisCtaOrden.CodPrestamo = @CodPrestamo) AND (tCsAnalisisCtaOrden.CodUsuario = @CodUsuario)

	Truncate Table Datos1	

	UPDATE    tCsCarteraDet
	SET              InteresVigente = CASE estado WHEN 'VIGENTE' THEN SICCB ELSE 0 END, InteresVencido = CASE estado WHEN 'VENCIDO' THEN SICCB ELSE 0 END, 
	                      InteresCtaOrden = tCsAnalisisCtaOrden.SICCO, MoratorioVigente = CASE estado WHEN 'VIGENTE' THEN SIMCB ELSE 0 END, 
	                      MoratorioVencido = CASE estado WHEN 'VENCIDO' THEN SIMCB ELSE 0 END, MoratorioCtaOrden = tCsAnalisisCtaOrden.SIMCO
	FROM         tCsAnalisisCtaOrden INNER JOIN
	                      tCsCarteraDet ON tCsAnalisisCtaOrden.CorteDataNegocio = tCsCarteraDet.Fecha AND tCsAnalisisCtaOrden.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
	                      tCsAnalisisCtaOrden.CodUsuario = tCsCarteraDet.CodUsuario INNER JOIN
	                      tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	WHERE     (tCsAnalisisCtaOrden.Observacion = '[0.00000000]-[0.00000000]-[0.00000000]') AND (tCsAnalisisCtaOrden.CodPrestamo = @CodPrestamo) AND 
	                      (tCsAnalisisCtaOrden.CodUsuario = @Codusuario)

	UPDATE    tcscartera
	SET              saldoInteVig = CASE estado WHEN 'VIGENTE' THEN SICCB ELSE 0 END, SaldoInpeVig = CASE estado WHEN 'VIGENTE' THEN SIMCB ELSE 0 END, 
	                      saldoInteSus = SICCO, saldoinpesus = SIMCO
	FROM         (SELECT     CorteDataNegocio, CodPrestamo, SUM(SICCB) AS SICCB, SUM(SICCO) AS SICCO, SUM(SIMCB) AS SIMCB, SUM(SIMCO) AS SIMCO
	                       FROM          tCsAnalisisCtaOrden
	                       WHERE      (Observacion = '[0.00000000]-[0.00000000]-[0.00000000]')
	                       GROUP BY CorteDataNegocio, CodPrestamo
	                       HAVING      (CodPrestamo = @CodPrestamo)) Datos INNER JOIN
	                      tCsCartera ON Datos.CorteDataNegocio = tCsCartera.Fecha AND Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo

Fetch Next From curFragmento Into @CodPrestamo, @CodUsuario, @FI, @CT, @CP
End 
Close 		curFragmento
Deallocate 	curFragmento

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Datos1]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [Datos1]end 

SELECT DISTINCT Observacion
FROM         tCsAnalisisCtaOrden

SELECT     SUM(SICCO + SIMCO) AS [Real], SUM(InteresCtaOrden + MoratorioCtaOrden) AS Actual, SUM(SICCO + SIMCO) - SUM(InteresCtaOrden + MoratorioCtaOrden) AS Diferencia
FROM         tCsAnalisisCtaOrden
GO