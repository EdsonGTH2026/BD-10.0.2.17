SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsRptCaResumenCarteraGrafico 
CREATE Procedure [dbo].[pCsRptCaResumenCarteraGrafico] 
@PI 			Varchar(6),
@PF				Varchar(6),
@Ubicacion		Varchar(100),
@TipoSaldo		Varchar(1000),
@Intervalo		Varchar(30),
@Segmento		Varchar(100),
@ClaseCartera	Varchar(100),
@Elementos		Decimal(10, 4),
@Usuario		Varchar(50) = 'kvalera'

As
Print 'XXXX: ' +  Isnull(@Usuario, 'Nulo')

--Set @Ubicacion	= 'ZZZ'
--Set @Rubro		= '03'
--Set @TipoSaldo	= '01'
--Set @PI 		= '200712'
--Set @PF		= '200812'
--Set @Intervalo 	= '02'

/*
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@PI', @PI) 		
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@PF', @PF)		
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@Ubicacion', @Ubicacion)	
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@TipoSaldo', @TipoSaldo)	
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@Intervalo', @Intervalo)	
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@Segmento',@Segmento)	
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@ClaseCartera', @ClaseCartera)	
Insert Into E (Fecha, Parametro, Valor) Values(getdate(), '@Elementos', @Elementos)
*/
Declare @PT				Varchar(6)
Declare @Contador		Int
Declare @Contador1		Int
Declare @Consolidacion  SmallDateTime
Declare @Fecha 			SmallDateTime
Declare @FI				SmallDateTime
Declare @FF				SmallDateTime
Declare @Decimal		Decimal(18,4)

Declare @Reporte 		Varchar(10)
Declare @Cadena			Varchar(4000)
Declare @Cadena1		Varchar(4000)

Declare @Dato			Int
Declare @Nivel1			Varchar(50)
Declare @Nivel2			Varchar(50)
Declare @CN1			Varchar(50)
Declare @CN2			Varchar(50)

Exec pGnlCalculaParametros 6, @TipoSaldo, 	@Reporte 	Out, 	@Cadena 	Out,  @Cadena1 Out

Print @Reporte 
Print @TipoSaldo

SELECT   @Consolidacion = FechaConsolidacion
FROM         vCsFechaConsolidacion

If @PI Is Null Or @PF Is Null Or Rtrim(Ltrim(@PI)) = '' Or Rtrim(Ltrim(@PF)) = ''
Begin
	Set @PI = dbo.fduFechaATexto(@Consolidacion, 'AAAAMM')
	Set @PF = dbo.fduFechaATexto(@Consolidacion, 'AAAAMM')
End

If @TipoSaldo Is Null Or Rtrim(Ltrim(@TipoSaldo)) = ''
Begin
	Set @TipoSaldo = '01'
End

If @Intervalo Is Null Or Rtrim(Ltrim(@Intervalo)) = ''
Begin
	Set @Intervalo = '02'
End

Set @PT = @PF
If @PF < @PI 
Begin
	Set @PF = @PI
	Set @PI = @PT
End
Set @PT = @PF

CREATE TABLE #ResumenFechas (	
				[Fecha] 	[smalldatetime] NOT NULL,
				[Activo] 	[Bit] 				NULL)

Print @PI
Print @PT

Set @Nivel1		= @Segmento
Set @Nivel2		= @Segmento

If @Reporte in ('CA01', 'CA99')
Begin
	Set @Cadena1 = 'tCsCartera'
	SELECT    @CN1 = Cartera
	FROM      tCsPrNivel
	WHERE     (Nivel = @Nivel1)
	SELECT    @CN2 = Cartera
	FROM      tCsPrNivel
	WHERE     (Nivel = @Nivel2)
End
If @Reporte = 'AH01'
Begin
	Set @Cadena1 = 'tCsAhorros'
	SELECT    @CN1 = Ahorro
	FROM      tCsPrNivel
	WHERE     (Nivel = @Nivel1)
	SELECT    @CN2 = Ahorro
	FROM      tCsPrNivel
	WHERE     (Nivel = @Nivel2)
End

Print Isnull(@Nivel1, 'Sin Valor Nivel1') 
Print Isnull(@Nivel2, 'Sin Valor Nivel2') 
Print Isnull(@CN1, 'Sin Valor CN1')
Print Isnull(@CN2, 'Sin Valor CN2')

If @PF = dbo.fdufechaatexto(@Consolidacion, 'AAAAMM')
Begin
	Insert Into #ResumenFechas (Fecha, Activo) Values (@Consolidacion, 1)
End
If @Intervalo = '01'
Begin		
	Set @Cadena = 'Insert Into #ResumenFechas ' 
	Set @Cadena = @Cadena + 'SELECT Fecha, Activo = 1 '
	Set @Cadena = @Cadena + 'FROM (SELECT DISTINCT '+ @Cadena1 +'.Fecha '
	Set @Cadena = @Cadena + 'FROM '+ @Cadena1 +' INNER JOIN '
	Set @Cadena = @Cadena + '(SELECT UltimoDia '
	Set @Cadena = @Cadena + 'FROM tClPeriodo '
	Set @Cadena = @Cadena + 'WHERE (Periodo = ''' + @PI + ''')) Inicio ON '+ @Cadena1 +'.Fecha >= Inicio.UltimoDia INNER JOIN '
	Set @Cadena = @Cadena + '(SELECT UltimoDia '
	Set @Cadena = @Cadena + 'FROM tClPeriodo '
	Set @Cadena = @Cadena + 'WHERE (Periodo = ''' + @PT + ''')) Final ON '+ @Cadena1 +'.Fecha <= Final.UltimoDia) Datos '

	Print @Cadena
	Exec (@Cadena)

	If @@RowCount <= 3
	Begin
		SELECT   @Fecha = Max(Fecha)
		FROM         #ResumenFechas
		
		If @Fecha is Null
		Begin
			Set @Fecha = @Consolidacion
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End

		If @Consolidacion > @Fecha
		Begin
			Insert Into #ResumenFechas (Fecha, activo) Values (@Fecha + 1, 1)
		End
		SELECT   @Fecha = Min(Fecha)
		FROM         #ResumenFechas
		Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha - 1, 1)
	End
	
	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos
	If @Contador <= 3
	Begin
		SELECT   @Fecha = Min(Fecha)
		FROM         #ResumenFechas
		Insert Into  #ResumenFechas (Fecha, Activo) Values (@Fecha - 1, 1)
	End
End

If @Intervalo = '02'
Begin	
	Set @Cadena = 'Insert Into #ResumenFechas ' 
	Set @Cadena = @Cadena + 'SELECT Fecha, Activo = 1 '
	Set @Cadena = @Cadena + 'FROM (SELECT DISTINCT '+ @Cadena1 +'.Fecha '
	Set @Cadena = @Cadena + 'FROM '+ @Cadena1 +' INNER JOIN '
	Set @Cadena = @Cadena + '(SELECT UltimoDia '
	Set @Cadena = @Cadena + 'FROM tClPeriodo '
	Set @Cadena = @Cadena + 'WHERE (Periodo >= ''' + @PI + ''') AND (Periodo <= ''' + @PT + ''')) Inicio ON '+ @Cadena1 +'.Fecha = Inicio.UltimoDia) Datos '
	
	Print @Cadena
	Exec (@Cadena)

	if @@RowCount <= 3
	Begin
		SELECT   @Fecha = Max(Fecha)
		FROM         #ResumenFechas
		
		If @Fecha is Null
		Begin
			Set @Fecha = @Consolidacion
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End

		If @Consolidacion > @Fecha And @Consolidacion > DATEADD([day], - 1, DATEADD([month], 1, DATEADD([month], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = DATEADD([day], - 1, DATEADD([month], 1, DATEADD([month], 1, CAST(@PT + '01' AS SmallDateTime))))
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End
		If @Consolidacion > @Fecha And @Consolidacion < DATEADD([day], - 1, DATEADD([month], 1, DATEADD([month], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = @Consolidacion
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End

		SELECT   @Fecha = DATEADD([day], - 1, CAST(dbo.fduFechaATexto(Min(Fecha), 'AAAAMM') + '01' AS SmallDatetime)) 
		FROM         #ResumenFechas

		Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
	End

	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos
	If @Contador <= 3
	Begin
		SELECT   @Fecha = DATEADD([day], - 1, CAST(dbo.fduFechaATexto(Min(Fecha), 'AAAAMM') + '01' AS SmallDatetime)) 
		FROM         #ResumenFechas

		Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
	End
End

If @Intervalo = '03'
Begin
	Set @PI = SubString(@PI, 1, 4) + '12'
	Set @PT = SubString(@PT, 1, 4) + '12'
	
	Print @PI
	Print @PT 
	
	Set @Cadena = 'Insert Into #ResumenFechas ' 
	Set @Cadena = @Cadena + 'SELECT Fecha, Activo = 1 '
	Set @Cadena = @Cadena + 'FROM (SELECT DISTINCT '+ @Cadena1 +'.Fecha '
	Set @Cadena = @Cadena + 'FROM '+ @Cadena1 +' INNER JOIN '
	Set @Cadena = @Cadena + '(SELECT UltimoDia '
	Set @Cadena = @Cadena + 'FROM tClPeriodo '
	Set @Cadena = @Cadena + 'WHERE (Periodo >= ''' + @PI + ''') AND (Periodo <= ''' + @PT + ''') AND (MONTH(UltimoDia) = 12)) Inicio ON '+ @Cadena1 +'.Fecha = Inicio.UltimoDia) Datos '
	
	Print @Cadena
	Exec (@Cadena)

	If @@RowCount <= 3
	Begin
		SELECT   @Fecha = Max(Fecha)
		FROM         #ResumenFechas

		If @Fecha is Null
		Begin
			Set @Fecha = @Consolidacion
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End
		
		If @Consolidacion > @Fecha And @Consolidacion > DATEADD([day], - 1, DATEADD([month], 1, DATEADD([year], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = DATEADD([day], - 1, DATEADD([month], 1, DATEADD([year], 1, CAST(@PT + '01' AS SmallDateTime))))
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End
		If @Consolidacion > @Fecha And @Consolidacion < DATEADD([day], - 1, DATEADD([month], 1, DATEADD([year], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = @Consolidacion
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End

		SELECT   @Fecha = DATEADD([day], - 1, DATEADD([month], 1, Cast(dbo.fduFechaAtexto(DATEADD([year], - 1, CAST(dbo.fduFechaATexto(Min(Fecha), 'AAAAMM') + '01' AS SmallDatetime)), 'AAAA') + '1201' as SmallDateTime))) 
		FROM         #ResumenFechas

		Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
	End
	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos
	If @Contador <= 3
	Begin
		SELECT   @Fecha = DATEADD([day], - 1, DATEADD([month], 1, Cast(dbo.fduFechaAtexto(DATEADD([year], - 1, CAST(dbo.fduFechaATexto(Min(Fecha), 'AAAAMM') + '01' AS SmallDatetime)), 'AAAA') + '1201' as SmallDateTime))) 
		FROM         #ResumenFechas

		Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
	End
End

Delete From #ResumenFechas
Where Fecha < '20071231'

If @Intervalo = '01'
Begin
	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos
	If @Contador <= 3
	Begin
		SELECT   @Fecha = Max(Fecha)
		FROM         #ResumenFechas
		
		If @Consolidacion > @Fecha
		Begin
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha + 1, 1)
		End
	End
End

If @Intervalo = '02'
Begin
	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos
	If @Contador <= 3
	Begin
		SELECT   @Fecha = Max(Fecha)
		FROM         #ResumenFechas
		
		If @Consolidacion > @Fecha And @Consolidacion > DATEADD([day], - 1, DATEADD([month], 1, DATEADD([month], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = DATEADD([day], - 1, DATEADD([month], 1, DATEADD([month], 1, CAST(@PT + '01' AS SmallDateTime))))
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End
		If @Consolidacion > @Fecha And @Consolidacion < DATEADD([day], - 1, DATEADD([month], 1, DATEADD([month], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = @Consolidacion
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End
	End
End

If @Intervalo = '03'
Begin
	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos
	If @Contador <= 3
	Begin
		SELECT   @Fecha = Max(Fecha)
		FROM         #ResumenFechas
		
		If @Consolidacion > @Fecha And @Consolidacion > DATEADD([day], - 1, DATEADD([month], 1, DATEADD([year], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = DATEADD([day], - 1, DATEADD([month], 1, DATEADD([year], 1, CAST(@PT + '01' AS SmallDateTime))))
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End
		If @Consolidacion > @Fecha And @Consolidacion < DATEADD([day], - 1, DATEADD([month], 1, DATEADD([year], 1, CAST(@PT + '01' AS SmallDateTime))))
		Begin
			Set @Fecha = @Consolidacion
			Insert Into #ResumenFechas (Fecha, Activo) Values (@Fecha, 1)
		End
	End
End

SELECT   @FI = Min(Fecha)
FROM         #ResumenFechas
SELECT   @FF = Max(Fecha)
FROM         #ResumenFechas

Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos

If @Contador > @Elementos
Begin
	Update #ResumenFechas
	Set Activo = 0
	
	Set @Decimal 	= Cast(@Contador as Decimal(18,4)) / @Elementos
	Set @Contador1 	= 1
	Set @Contador 	= 1

	Declare curFragmento1 Cursor For 
		Select Distinct Fecha
		From #ResumenFechas		
	Open curFragmento1
	Fetch Next From curFragmento1 Into @Fecha
	While @@Fetch_Status = 0
	Begin 
		If @Fecha = @FI or @Fecha = @FF
		Begin
			Update #ResumenFechas
			Set Activo = 1
			Where Fecha = @Fecha
		End		
		If @Contador1 = Round(@Decimal * @Contador, 0)
		Begin
			Update #ResumenFechas
			Set Activo = 1
			Where Fecha = @Fecha
			Set @Contador = @Contador + 1
		End
		Set @Contador1 = @Contador1 + 1
	Fetch Next From curFragmento1 Into @Fecha
	End 
	Close 		curFragmento1
	Deallocate 	curFragmento1

	Delete From #ResumenFechas where Activo = 0
End

CREATE TABLE #tCsResumenCartera2 (
	[UBI] [varchar] (3) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[TSA] [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[ClaseCartera] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CN1] [varchar] (100) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CN2] [varchar] (100) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[ID] [varchar] (10) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Titulo] [varchar] (100) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[TipoSaldo] [varchar] (500) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Cartera] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Ubicacion] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Fecha] [smalldatetime] NOT NULL ,
	[Nivel1] [varchar] (200) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Nivel2] [varchar] (200) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Reporte] [varchar] (5) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Dato] [int] NOT NULL ,
	[ADesembolso] [decimal](38, 4) NULL ,
	[ASaldo] [decimal](38, 4) NULL ,
	[AClientes] [int] NULL ,
	[APrestamos] [int] NULL ,
	[ACampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[AGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[BDesembolso] [decimal](38, 4) NULL ,
	[BSaldo] [decimal](38, 4) NULL ,
	[BClientes] [int] NULL ,
	[BPrestamos] [int] NULL ,
	[BCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[BGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CDesembolso] [decimal](38, 4) NULL ,
	[CSaldo] [decimal](38, 4) NULL ,
	[CClientes] [int] NULL ,
	[CPrestamos] [int] NULL ,
	[CCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[DDesembolso] [decimal](38, 4) NULL ,
	[DSaldo] [decimal](38, 4) NULL ,
	[DClientes] [int] NULL ,
	[DPrestamos] [int] NULL ,
	[DCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[DGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[EDesembolso] [decimal](38, 4) NULL ,
	[ESaldo] [decimal](38, 4) NULL ,
	[EClientes] [int] NULL ,
	[EPrestamos] [int] NULL ,
	[ECampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[EGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[FDesembolso] [decimal](38, 4) NULL ,
	[FSaldo] [decimal](38, 4) NULL ,
	[FClientes] [int] NULL ,
	[FPrestamos] [int] NULL ,
	[FCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[FGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NOT NULL,
	[GDesembolso] [decimal](38, 4) NULL ,
	[GSaldo] [decimal](38, 4) NULL ,
	[GClientes] [int] NULL ,
	[GPrestamos] [int] NULL ,
	[GCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[GGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NOT NULL 
) ON [PRIMARY]

Set @Dato 		= 1 

--If @Tabla = 1
--Begin
	--Analisis con la Fecha Inicial
	Set @Fecha = @FI
	Select @Contador = Count(*) From (
	Select Distinct Fecha
	From   tCsResumenCartera
	Where Fecha = @Fecha And TSA = @TipoSaldo And UBI = @Ubicacion)  Datos
	
	If @Contador = 1
	Begin	
		Print 'pCsRptCaSituacionCarteraVertical 01'
		Insert Into #tCsResumenCartera2 (UBI, 		TSA, 		ClaseCartera, 	CN1, 		CN2, 		ID, 		Titulo,
					 	TipoSaldo,	Cartera, 	Ubicacion,	Fecha, 		Nivel1, 	Nivel2,		Reporte,
						Dato,		ADesembolso,	ASaldo,		AClientes,	APrestamos, 	ACampo,		AGrupo,
						BDesembolso,	BSaldo,		BClientes,	BPrestamos,	BCampo,		BGrupo,		CDesembolso,
						CSaldo,		CClientes,	CPrestamos,	CCampo,		CGrupo,		DDesembolso,	DSaldo,
						DClientes,	DPrestamos,	DCampo,		DGrupo,		EDesembolso,	ESaldo,		EClientes,
						EPrestamos,	ECampo,		EGrupo,		FDesembolso,	FSaldo,		FClientes,	FPrestamos,
						FCampo,		FGrupo,		GDesembolso,	GSaldo,		GClientes,	GPrestamos,	GCampo,
						GGrupo)
		Exec pCsRptCaSituacionCarteraVertical 
		@Dato			,
		@Fecha 			,
		@Ubicacion		,
		@Nivel1			,
		@Nivel2			,
		@ClaseCartera	,
		@TipoSaldo		,
		@Reporte		,
		@Usuario			
		
		Select @Contador = Count(*) from (
		Select UBI, TSA, ClaseCartera, CN1, CN2, ID, Titulo, TipoSaldo, Cartera, Ubicacion, Fecha, Nivel1, Nivel2, Reporte, 
			ADesembolso, ASaldo, AClientes, APrestamos, ACampo, AGrupo, 
			BDesembolso, BSaldo, BClientes, BPrestamos, BCampo, BGrupo, 
			CDesembolso, CSaldo, CClientes, CPrestamos, CCampo, CGrupo, 
			DDesembolso, DSaldo, DClientes, DPrestamos, DCampo, DGrupo, 
			EDesembolso, ESaldo, EClientes, EPrestamos, ECampo, EGrupo, 
	                      	FDesembolso, FSaldo, FClientes, FPrestamos, FCampo, FGrupo,
			GDesembolso, GSaldo, GClientes, GPrestamos, GCampo, GGrupo 
		From tCsResumenCartera WHERE
		Dato 			= @Dato		And
		UBI 			= @Ubicacion 	And 
		CN1				= @CN1	And
		CN2 			= @CN2	And
		ClaseCartera	= @ClaseCartera	And
		TSA 			= @TipoSaldo	And
		Fecha			= @Fecha 
		UNION
		Select UBI, TSA, ClaseCartera, CN1, CN2, ID, Titulo, TipoSaldo, Cartera, Ubicacion, Fecha, Nivel1, Nivel2, Reporte, ADesembolso, ASaldo, AClientes, APrestamos, ACampo, AGrupo, 
			BDesembolso, BSaldo, BClientes, BPrestamos, BCampo, BGrupo, 
			CDesembolso, CSaldo, CClientes, CPrestamos, CCampo, CGrupo, 
			DDesembolso, DSaldo, DClientes, DPrestamos, DCampo, DGrupo, 
			EDesembolso, ESaldo, EClientes, EPrestamos, ECampo, EGrupo, 
	                      	FDesembolso, FSaldo, FClientes, FPrestamos, FCampo, FGrupo,
			GDesembolso, GSaldo, GClientes, GPrestamos, GCampo, GGrupo  
		From #tCsResumenCartera2 WHERE
		Dato 		= 2		And
		UBI 		= @Ubicacion 	And 
		CN1		= @CN1	And
		CN2 		= @CN2	And
		ClaseCartera	= @ClaseCartera	And
		TSA 		= @TipoSaldo	And
		Fecha		= @Fecha ) Datos
		
		If @Contador > 3
		Begin
			Print 'EL SALDO ENCONTRADO ES DIFERENTE AL QUE EXISTE CALCULADO SE PROCEDERA A CALCULAR NUEVAMENTE'
			Update #ResumenFechas Set Activo = 0
			Where Fecha = @Fecha
		End
	End
	
	--Analisis con la Fecha Final
	Set @Fecha = @FF
	Select @Contador = Count(*) From (
	Select Distinct Fecha
	From   tCsResumenCartera
	Where Fecha = @Fecha And TSA = @TipoSaldo And UBI = @Ubicacion)  Datos
	
	If @Contador = 1
	Begin
		Print 'pCsRptCaSituacionCarteraVertical 02'
		Insert Into #tCsResumenCartera2 (UBI, 		TSA, 		ClaseCartera, 	CN1, 		CN2, 		ID, 		Titulo,
					 	TipoSaldo,	Cartera, 	Ubicacion,	Fecha, 		Nivel1, 	Nivel2,		Reporte,
						Dato,		ADesembolso,	ASaldo,		AClientes,	APrestamos, 	ACampo,		AGrupo,
						BDesembolso,	BSaldo,		BClientes,	BPrestamos,	BCampo,		BGrupo,		CDesembolso,
						CSaldo,		CClientes,	CPrestamos,	CCampo,		CGrupo,		DDesembolso,	DSaldo,
						DClientes,	DPrestamos,	DCampo,		DGrupo,		EDesembolso,	ESaldo,		EClientes,
						EPrestamos,	ECampo,		EGrupo,		FDesembolso,	FSaldo,		FClientes,	FPrestamos,
						FCampo,		FGrupo,		GDesembolso,	GSaldo,		GClientes,	GPrestamos,	GCampo,
						GGrupo)
		Exec pCsRptCaSituacionCarteraVertical 
		@Dato			,
		@Fecha 			,
		@Ubicacion		,
		@Nivel1			,
		@Nivel2			,
		@ClaseCartera	,
		@TipoSaldo		,
		@Reporte		,
		@Usuario		
		
		Select @Contador = Count(*) from (
		Select UBI, TSA, ClaseCartera, CN1, CN2, ID, Titulo, TipoSaldo, Cartera, Ubicacion, Fecha, Nivel1, Nivel2, Reporte, 
			ADesembolso, ASaldo, AClientes, APrestamos, ACampo, AGrupo, 
			BDesembolso, BSaldo, BClientes, BPrestamos, BCampo, BGrupo, 
			CDesembolso, CSaldo, CClientes, CPrestamos, CCampo, CGrupo, 
			DDesembolso, DSaldo, DClientes, DPrestamos, DCampo, DGrupo, 
			EDesembolso, ESaldo, EClientes, EPrestamos, ECampo, EGrupo, 
	                      	FDesembolso, FSaldo, FClientes, FPrestamos, FCampo, FGrupo,
			GDesembolso, GSaldo, GClientes, GPrestamos, GCampo, GGrupo  
		From tCsResumenCartera WHERE
		Dato 		= @Dato		And
		UBI 		= @Ubicacion 		And 
		CN1		= @CN1		And
		CN2 		= @CN2		And
		ClaseCartera	= @ClaseCartera	And
		TSA 		= @TipoSaldo		And
		Fecha		= @Fecha 
		UNION
		Select UBI, TSA, ClaseCartera, CN1, CN2, ID, Titulo, TipoSaldo, Cartera, Ubicacion, Fecha, Nivel1, Nivel2, Reporte, 
			ADesembolso, ASaldo, AClientes, APrestamos, ACampo, AGrupo, 
			BDesembolso, BSaldo, BClientes, BPrestamos, BCampo, BGrupo, 
			CDesembolso, CSaldo, CClientes, CPrestamos, CCampo, CGrupo, 
			DDesembolso, DSaldo, DClientes, DPrestamos, DCampo, DGrupo, 
			EDesembolso, ESaldo, EClientes, EPrestamos, ECampo, EGrupo, 
	                      	FDesembolso, FSaldo, FClientes, FPrestamos, FCampo, FGrupo,
			GDesembolso, GSaldo, GClientes, GPrestamos, GCampo, GGrupo   
		From #tCsResumenCartera2 WHERE
		Dato 		= 2		And
		UBI 		= @Ubicacion 	And 
		CN1		= @CN1		And
		CN2 		= @CN2		And
		ClaseCartera	= @ClaseCartera	And
		TSA 		= @TipoSaldo	And
		Fecha		= @Fecha ) Datos
		
		If @Contador > 3
		Begin
			Print 'EL SALDO ENCONTRADO ES DIFERENTE AL QUE EXISTE CALCULADO SE PROCEDERA A CALCULAR NUEVAMENTE'
			Update #ResumenFechas Set Activo = 0
			Where Fecha = @Fecha
		End
	End
	
	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas Where Activo = 0)Datos
	
	Print 'Contador ' + Cast(@Contador as varchar(10))
	
	Update #ResumenFechas Set Activo = 0
	
	If @Contador > 0 
	Begin
		Update #ResumenFechas Set Activo = 1
	End
	Else
	Begin
		Update #ResumenFechas Set Activo = 1
		Where     (Fecha NOT IN
		          (SELECT DISTINCT Fecha
		            FROM          tCsResumenCartera
		            WHERE      TSA = @TipoSaldo And UBI = @Ubicacion And CN1 = @CN1 And ClaseCartera = @ClaseCartera))
	End
	
	--Select * from #ResumenFechas
	
	Declare curFragmento Cursor For 
		Select Fecha
		From #ResumenFechas
		Where Activo = 1		
	Open curFragmento
	Fetch Next From curFragmento Into @Fecha
	While @@Fetch_Status = 0
	Begin 
		Delete From tCsResumenCartera
		Where 	Dato 		= @Dato		And
			UBI 		= @Ubicacion 		And 
			CN1		= @CN1		And
			CN2 		= @CN2		And
			ClaseCartera	= @ClaseCartera	And
			TSA 		= @TipoSaldo		And
			Fecha		= @Fecha
		Print 'pCsRptCaSituacionCarteraVertical 03'
		Insert Into tCsResumenCartera (UBI, 		TSA, 		ClaseCartera, 	CN1, 		CN2, 		ID, 		Titulo,
					 	TipoSaldo,	Cartera, 	Ubicacion,	Fecha, 		Nivel1, 	Nivel2,		Reporte,
						Dato,		ADesembolso,	ASaldo,		AClientes,	APrestamos, 	ACampo,		AGrupo,
						BDesembolso,	BSaldo,		BClientes,	BPrestamos,	BCampo,		BGrupo,		CDesembolso,
						CSaldo,		CClientes,	CPrestamos,	CCampo,		CGrupo,		DDesembolso,	DSaldo,
						DClientes,	DPrestamos,	DCampo,		DGrupo,		EDesembolso,	ESaldo,		EClientes,
						EPrestamos,	ECampo,		EGrupo,		FDesembolso,	FSaldo,		FClientes,	FPrestamos,
						FCampo,		FGrupo,		GDesembolso,	GSaldo,		GClientes,	GPrestamos,	GCampo,
						GGrupo)
		Exec pCsRptCaSituacionCarteraVertical 
		@Dato			,
		@Fecha 			,
		@Ubicacion		,
		@Nivel1			,
		@Nivel2			,
		@ClaseCartera	,
		@TipoSaldo		,
		@Reporte		,
		@Usuario			
		
		Update tCsResumenCartera
		Set Dato = @Dato
		Where 	UBI 		= @Ubicacion 		And 
			CN1		= @CN1		And
			CN2 		= @CN2		And
			ClaseCartera	= @ClaseCartera	And
			TSA 		= @TipoSaldo		And
			Fecha		= @Fecha	
	
	Fetch Next From curFragmento Into @Fecha
	End 
	Close 		curFragmento
	Deallocate 	curFragmento
--End

SELECT   @Intervalo =  Temporada
FROM         tCsPrIntervalo
WHERE     (Intervalo = @Intervalo)

Print @Ubicacion
Print @TipoSaldo
Print @CN1
Print @CN2
Print @ClaseCartera

If @Usuario <> 'XXXXX'
Begin
	SELECT  tCsResumenCartera.ID, FI = @FI, FF= @FF, Intervalo = @Intervalo, tCsResumenCartera.Fecha, tCsResumenCartera.Ubicacion, tCsResumenCartera.ClaseCartera, tCsResumenCartera.Nivel1, SUM(tCsResumenCartera.ASaldo) AS Saldo, 
						  ROUND(SUM(tCsResumenCartera.FSaldo) / Case When SUM(tCsResumenCartera.ASaldo) = 0 Then 1.0000 else SUM(tCsResumenCartera.ASaldo) end * 100 , 2) AS Vencido, ROUND(SUM(tCsResumenCartera.GSaldo) 
						  / Case When SUM(tCsResumenCartera.ASaldo) = 0 then 1.0000 else SUM(tCsResumenCartera.ASaldo) End * 100, 2) AS MoraGeneral, tCsResumenCartera.CN1, tCsPrTipoSaldo.Nombre, tCsResumenCartera.TipoSaldo, 
						  SUM(tCsResumenCartera.APrestamos) AS Prestamos, SUM(tCsResumenCartera.AClientes) AS Clientes, tCsResumenCartera.ACampo, 
						  tCsResumenCartera.AGrupo, Sum(ADesembolso) as Desembolso
	FROM         tCsResumenCartera INNER JOIN
						  tCsPrTipoSaldo ON tCsResumenCartera.TSA = tCsPrTipoSaldo.TipoSaldo INNER JOIN
						  #ResumenFechas tCsCartera ON tCsResumenCartera.Fecha = tCsCartera.Fecha
	WHERE     (tCsResumenCartera.UBI = @Ubicacion) AND (tCsResumenCartera.TSA = @TipoSaldo) AND (tCsResumenCartera.CN1 = @CN1) And (tCsResumenCartera.ClaseCartera = @ClaseCartera)
	GROUP BY tCsResumenCartera.ID, tCsResumenCartera.Fecha, tCsResumenCartera.Nivel1, tCsResumenCartera.CN1, tCsPrTipoSaldo.Nombre, tCsResumenCartera.Ubicacion, 
						  tCsResumenCartera.TipoSaldo, tCsResumenCartera.ACampo, 
						  tCsResumenCartera.AGrupo, tCsResumenCartera.ClaseCartera
	ORDER BY tCsResumenCartera.Nivel1, tCsResumenCartera.Fecha
End 
Else
Begin
	Insert Into Kike
	SELECT  tCsResumenCartera.ID, FI = @FI, FF= @FF, Intervalo = @Intervalo, tCsResumenCartera.Fecha, tCsResumenCartera.Ubicacion, tCsResumenCartera.ClaseCartera, tCsResumenCartera.Nivel1, SUM(tCsResumenCartera.ASaldo) AS Saldo, 
						  ROUND(SUM(tCsResumenCartera.FSaldo) / Case When SUM(tCsResumenCartera.ASaldo) = 0 Then 1.0000 else SUM(tCsResumenCartera.ASaldo) end * 100 , 2) AS Vencido, ROUND(SUM(tCsResumenCartera.GSaldo) 
						  / Case When SUM(tCsResumenCartera.ASaldo) = 0 then 1.0000 else SUM(tCsResumenCartera.ASaldo) End * 100, 2) AS MoraGeneral, tCsResumenCartera.CN1, tCsPrTipoSaldo.Nombre, tCsResumenCartera.TipoSaldo, 
						  SUM(tCsResumenCartera.APrestamos) AS Prestamos, SUM(tCsResumenCartera.AClientes) AS Clientes, tCsResumenCartera.ACampo, 
						  tCsResumenCartera.AGrupo, Sum(ADesembolso) as Desembolso
	FROM         tCsResumenCartera INNER JOIN
						  tCsPrTipoSaldo ON tCsResumenCartera.TSA = tCsPrTipoSaldo.TipoSaldo INNER JOIN
						  #ResumenFechas tCsCartera ON tCsResumenCartera.Fecha = tCsCartera.Fecha
	WHERE     (tCsResumenCartera.UBI = @Ubicacion) AND (tCsResumenCartera.TSA = @TipoSaldo) AND (tCsResumenCartera.CN1 = @CN1) And (tCsResumenCartera.ClaseCartera = @ClaseCartera)
	GROUP BY tCsResumenCartera.ID, tCsResumenCartera.Fecha, tCsResumenCartera.Nivel1, tCsResumenCartera.CN1, tCsPrTipoSaldo.Nombre, tCsResumenCartera.Ubicacion, 
						  tCsResumenCartera.TipoSaldo, tCsResumenCartera.ACampo, 
						  tCsResumenCartera.AGrupo, tCsResumenCartera.ClaseCartera
	ORDER BY tCsResumenCartera.Nivel1, tCsResumenCartera.Fecha
End
Drop Table #ResumenFechas
Drop Table #tCsResumenCartera2
GO