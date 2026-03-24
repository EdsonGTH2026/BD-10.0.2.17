SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Drop Procedure pCsCaRptRecuperaciones2
Create Procedure [dbo].[pCsCaRptRecuperaciones2]
@Fecha 		SmallDateTime,
@Ubicacion	Varchar(500),
@Agrupado1	Varchar(100),
@Agrupado2	Varchar(100),
@ClaseCartera	Varchar(500)
As
--Set @Fecha 		= '20100626'
--Set @Ubicacion		= 'ZZZ'
--Set @Agrupado1		= 'Tecnologia'
--Set @Agrupado2		= 'Oficina'
--Set @ClaseCartera	= 'ACTIVA'

Declare @Ayer		SmallDateTime

Set @Ayer		= DateAdd(Day, -1, @Fecha)

CREATE TABLE #tCsResumenCartera (
	[UBI] [varchar] (3) COLLATE Modern_Spanish_CI_AI NULL ,
	[TSA] [varchar] (2) COLLATE Modern_Spanish_CI_AI NULL ,
	[ClaseCartera] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[CN1] [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL ,
	[CN2] [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL ,
	[ID] [varchar] (10) COLLATE Modern_Spanish_CI_AI NULL ,
	[Titulo] [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL ,
	[TipoSaldo] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Cartera] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Ubicacion] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Fecha] [smalldatetime] NULL ,
	[Nivel1] [varchar] (200) COLLATE Modern_Spanish_CI_AI NULL ,
	[Nivel2] [varchar] (200) COLLATE Modern_Spanish_CI_AI NULL ,
	[Reporte] [varchar] (5) COLLATE Modern_Spanish_CI_AI NULL ,
	[Dato] [int] NULL ,
	[ADesembolso] [decimal](38, 4) NULL ,
	[ASaldo] [decimal](38, 4) NULL ,
	[AClientes] [int] NULL ,
	[APrestamos] [int] NULL ,
	[ACampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[AGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NULL ,
	[BDesembolso] [decimal](38, 4) NULL ,
	[BSaldo] [decimal](38, 4) NULL ,
	[BClientes] [int] NULL ,
	[BPrestamos] [int] NULL ,
	[BCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[BGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NULL ,
	[CDesembolso] [decimal](38, 4) NULL ,
	[CSaldo] [decimal](38, 4) NULL ,
	[CClientes] [int] NULL ,
	[CPrestamos] [int] NULL ,
	[CCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[CGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NULL ,
	[DDesembolso] [decimal](38, 4) NULL ,
	[DSaldo] [decimal](38, 4) NULL ,
	[DClientes] [int] NULL ,
	[DPrestamos] [int] NULL ,
	[DCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[DGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NULL ,
	[EDesembolso] [decimal](38, 4) NULL ,
	[ESaldo] [decimal](38, 4) NULL ,
	[EClientes] [int] NULL ,
	[EPrestamos] [int] NULL ,
	[ECampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[EGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NULL ,
	[FDesembolso] [decimal](38, 4) NULL ,
	[FSaldo] [decimal](38, 4) NULL ,
	[FClientes] [int] NULL ,
	[FPrestamos] [int] NULL ,
	[FCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[FGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NULL,
	[GDesembolso] [decimal](38, 4) NULL ,
	[GSaldo] [decimal](38, 4) NULL ,
	[GClientes] [int] NULL ,
	[GPrestamos] [int] NULL ,
	[GCampo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[GGrupo] [varchar] (400) COLLATE Modern_Spanish_CI_AI NULL 
) ON [PRIMARY]

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsRptCaSituacionCarteraVertical 1, @Ayer, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, ''24'', ''CA01'''

Insert Into #tCsResumenCartera
Exec pCsRptCaSituacionCarteraVertical 1, @Ayer, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, '24', 'CA01'

CREATE TABLE #VALIDACION (
	[ClaseCartera] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[CN1] [varchar] (100) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CN2] [varchar] (100) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Titulo] [varchar] (100) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Cartera] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Ubicacion] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Nivel1] [varchar] (200) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Nivel2] [varchar] (200) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Capital] [decimal](18, 4) NULL ,
	[InteresesBalance] [decimal](18, 4) NULL ,
	[SaldoCartera] AS ([Capital] + [InteresesBalance]) ,
	[InteresesCtaOrden] AS ([SaldoCIM] - ([Capital] + [InteresesBalance])) ,
	[SaldoCIM] [decimal](38, 4) NULL ,
	[Clientes] [int] NULL ,
	[Prestamos] [int] NULL ,
	[Desembolsos] [decimal](18, 4) NULL ,
	[DesembolsosP] [int] NULL ,
	[RecuperacionesC] [decimal](18, 4) NULL ,
	[RecuperacionesI] [decimal](18, 4) NULL ,
	[RecuperacionesP] [int] NULL ,
	[CondonacionesC] [decimal](18, 4) NULL ,
	[CondonacionesI] [decimal](18, 4) NULL ,
	[CondonacionesP] [int] NULL ,
	[CastigosC] [decimal](18, 4) NULL ,
	[CastigosI] [decimal](18, 4) NULL ,
	[CastigosP] [int] NULL ,
	[Devengado] [decimal](18, 4) NULL ,
	[DevengadoP] [int] NULL ,
	[Capital1] [decimal](18, 4) NULL ,
	[InteresesBalance1] [decimal](18, 4) NULL ,
	[SaldoCartera1] AS ([Capital1] + [InteresesBalance1]) ,
	[InteresesCtaOrden1] AS ([SaldoCIM1] - ([Capital1] + [InteresesBalance1])) ,
	[SaldoCIM1] [decimal](38, 4) NULL ,
	[Clientes1] [int] NULL ,
	[Prestamos1] [int] NULL,
	[CapitalM] AS (isnull([Capital],0) + isnull([Desembolsos],0) - isnull([RecuperacionesC],0) - isnull([CondonacionesC],0) - isnull([castigosC],0)) ,
	[InteresesM] AS (isnull([SaldoCIM],0) - isnull([Capital],0) - isnull([RecuperacionesI],0) - isnull([CondonacionesI],0) - isnull([CastigosI],0) + isnull([Devengado],0)) ,
	[CapitalD] AS (isnull([Capital1],0) - (isnull([Capital],0) + isnull([Desembolsos],0) - isnull([RecuperacionesC],0) - isnull([CondonacionesC],0) - isnull([castigosC],0))) ,
	[InteresesD] AS (isnull([SaldoCIM1],0) - isnull([Capital1],0) - isnull([SaldoCIM],0) + isnull([Capital],0) + isnull([RecuperacionesI],0) + isnull([CondonacionesI],0) + isnull([CastigosI],0) - isnull([Devengado],0))  
)

Insert Into #Validacion (ClaseCartera, CN1, CN2, Titulo, Cartera, Ubicacion, Nivel1, Nivel2, SaldoCIM, Clientes, Prestamos )
Select ClaseCartera, CN1, CN2, Titulo, Cartera, Ubicacion, Nivel1, Nivel2, ASaldo, AClientes, APrestamos 
From #tCsResumenCartera 

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsRptCaSituacionCarteraVertical 1, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, ''24'', ''CA01'''

Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera
Exec pCsRptCaSituacionCarteraVertical 1, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, '24', 'CA01'

INSERT INTO #VALIDACION (ClaseCartera, CN1, CN2, Titulo, Cartera, Ubicacion, Nivel1, Nivel2)
SELECT   tCsResumenCartera.ClaseCartera, tCsResumenCartera.CN1, tCsResumenCartera.CN2, tCsResumenCartera.Titulo, 
                      tCsResumenCartera.Cartera, tCsResumenCartera.Ubicacion, tCsResumenCartera.Nivel1, tCsResumenCartera.Nivel2
FROM     #VALIDACION VALIDACION RIGHT OUTER JOIN #tCsResumenCartera tCsResumenCartera ON VALIDACION.ClaseCartera = tCsResumenCartera.ClaseCartera COLLATE Modern_Spanish_CI_AI AND 
                      VALIDACION.CN1 = tCsResumenCartera.CN1 COLLATE Modern_Spanish_CI_AI AND VALIDACION.CN2 = tCsResumenCartera.CN2 COLLATE Modern_Spanish_CI_AI AND 
                      VALIDACION.Nivel1 = tCsResumenCartera.Nivel1 COLLATE Modern_Spanish_CI_AI AND 
                      VALIDACION.Nivel2 = tCsResumenCartera.Nivel2 COLLATE Modern_Spanish_CI_AI
WHERE     (VALIDACION.ClaseCartera IS NULL)

UPDATE  #VALIDACION
SET     SaldoCIM1 	= ASaldo, 
	Clientes1	= AClientes, 
	Prestamos1	= APrestamos
FROM         #VALIDACION VALIDACION INNER JOIN
                      #tCsResumenCartera ON VALIDACION.ClaseCartera = #tCsResumenCartera.ClaseCartera AND 
                      VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
                      VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2


Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsRptCaSituacionCarteraVertical 1, @Ayer, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, ''02'', ''CA01'''
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera
Exec pCsRptCaSituacionCarteraVertical 1, @Ayer, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, '02', 'CA01'

UPDATE    #VALIDACION
SET              Capital = ASaldo
FROM         #VALIDACION VALIDACION INNER JOIN
                      #tCsResumenCartera ON VALIDACION.ClaseCartera = #tCsResumenCartera.ClaseCartera AND 
                      VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
                      VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsRptCaSituacionCarteraVertical 1, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, ''02'', ''CA01'''
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera
Exec pCsRptCaSituacionCarteraVertical 1, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, '02', 'CA01'

UPDATE    #VALIDACION
SET              Capital1 = ASaldo
FROM         #VALIDACION VALIDACION INNER JOIN
                      #tCsResumenCartera ON VALIDACION.ClaseCartera = #tCsResumenCartera.ClaseCartera AND 
                      VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
                      VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2


Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsRptCaSituacionCarteraVertical 1, @Ayer, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, ''07'', ''CA01'''
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera
Exec pCsRptCaSituacionCarteraVertical 1, @Ayer, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, '07', 'CA01'

UPDATE    #VALIDACION
SET              InteresesBalance = ASaldo
FROM         #VALIDACION VALIDACION INNER JOIN
                      #tCsResumenCartera ON VALIDACION.ClaseCartera = #tCsResumenCartera.ClaseCartera AND 
                      VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
                      VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsRptCaSituacionCarteraVertical 1, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, ''07'', ''CA01'''
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera
Exec pCsRptCaSituacionCarteraVertical 1, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera, '07', 'CA01'

UPDATE    #VALIDACION
SET              InteresesBalance1 = ASaldo
FROM         #VALIDACION VALIDACION INNER JOIN
                      #tCsResumenCartera ON VALIDACION.ClaseCartera = #tCsResumenCartera.ClaseCartera AND 
                      VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
                      VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsCaRptRecuperaciones1 2, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera'
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera (Cartera, CN1, CN2, Nivel1, NIvel2, Fecha, ASaldo, BSaldo, CSaldo, APrestamos)
Exec pCsCaRptRecuperaciones1 2, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera

UPDATE  #VALIDACION
SET     Desembolsos = ASaldo,
	DesembolsosP = APrestamos
FROM    #VALIDACION VALIDACION INNER JOIN
	#tCsResumenCartera ON 
        VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
        VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsCaRptRecuperaciones1 1, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera'
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera (Cartera, CN1, CN2, Nivel1, NIvel2, Fecha, ASaldo, BSaldo, CSaldo, APrestamos)
Exec pCsCaRptRecuperaciones1 1, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera

UPDATE  #VALIDACION
SET     RecuperacionesC	= ASaldo,
	RecuperacionesP = APrestamos,
	RecuperacionesI = BSaldo
FROM    #VALIDACION VALIDACION INNER JOIN
	#tCsResumenCartera ON 
        VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
        VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsCaRptRecuperaciones1 3, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera'
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera (Cartera, CN1, CN2, Nivel1, NIvel2, Fecha, ASaldo, BSaldo, CSaldo, APrestamos)
Exec pCsCaRptRecuperaciones1 3, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera

UPDATE  #VALIDACION
SET     CondonacionesC	= ASaldo,
	CondonacionesP	= APrestamos,
	CondonacionesI 	= BSaldo
FROM    #VALIDACION VALIDACION INNER JOIN
	#tCsResumenCartera ON 
        VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
        VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2


Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsCaRptRecuperaciones1 5, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera'
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera (Cartera, CN1, CN2, Nivel1, NIvel2, Fecha, ASaldo, BSaldo, CSaldo, APrestamos)
Exec pCsCaRptRecuperaciones1 5, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera

UPDATE  #VALIDACION
SET     CastigosC	= ASaldo,
	CastigosP	= APrestamos,
	CastigosI 	= BSaldo
FROM    #VALIDACION VALIDACION INNER JOIN
	#tCsResumenCartera ON 
        VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
        VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2

Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'Exec pCsCaRptRecuperaciones1 4, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera'
Truncate Table #tCsResumenCartera
Insert Into #tCsResumenCartera (Cartera, CN1, CN2, Nivel1, NIvel2, Fecha, ASaldo, BSaldo, CSaldo, APrestamos)
Exec pCsCaRptRecuperaciones1 4, @Fecha, @Fecha, @Ubicacion, @Agrupado1, @Agrupado2, @ClaseCartera


Print 'TIEMPO RECUPERACIONES 2'
Print getdate()
Print 'FIN'
UPDATE  #VALIDACION
SET    	DevengadoP	= APrestamos,
	Devengado 	= BSaldo
FROM    #VALIDACION VALIDACION INNER JOIN
	#tCsResumenCartera ON 
        VALIDACION.CN1 = #tCsResumenCartera.CN1 AND VALIDACION.CN2 = #tCsResumenCartera.CN2 AND VALIDACION.Nivel1 = #tCsResumenCartera.Nivel1 AND 
        VALIDACION.Nivel2 = #tCsResumenCartera.Nivel2


Select Fecha = @Fecha, Ayer = @Ayer, * From #VALIDACION

Drop Table #tCsResumenCartera
Drop Table #VALIDACION

GO