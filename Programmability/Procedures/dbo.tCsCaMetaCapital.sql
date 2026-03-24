SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Exec tCsCaMetaCapital '201011', '2'
--Drop Procedure tCsCaMetaCapital
Create Procedure [dbo].[tCsCaMetaCapital]
@Periodo	Varchar(6),
@Ubicacion	Varchar(100)
As

--Declare @Periodo	Varchar(6)
--Declare @Ubicacion	Varchar(100)


--Set @Periodo	= '201011'
--Set @Ubicacion	= 'ZZZ'

Declare @Corte			SmallDateTime
Declare @Proximo		SmallDateTime
Declare @CUbicacion		Varchar(500)
Declare @OtroDato		Varchar(1000)
Declare @Cadena			Varchar(4000)
Declare @CodOficina		Varchar(4)
Declare @Legal			Varchar(15)

Set @Corte		= DateAdd(Day, -1, Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, Cast(@Periodo + '01' as SmallDateTime)), 'AAAAMM') + '01' as SmallDateTime))

If @Corte > (Select FechaConsolidacion from vCsFechaConsolidacion)
Begin
	Select @Corte = FechaConsolidacion from vCsFechaConsolidacion
End

Set @Periodo	= dbo.FduFechaATexto(@Corte, 'AAAAMM')
Set @Proximo	= DateAdd(Day, -1, Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, Cast(@Periodo + '01' as SmallDateTime)), 'AAAAMM') + '01' as SmallDateTime))

Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out

Create Table #Oficinas
(CodOficina Varchar(4))

CREATE TABLE #Cartera (
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

CREATE TABLE #Cartera1 (
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

Set @Cadena = 'Insert Into #Oficinas Select CodOficina From tClOficinas Where CodOFicina in ('+ @CUbicacion +')'
Exec(@Cadena)

Declare CurOficina1 Cursor For 
	SELECT    CodOficina
	FROM       tClOficinas
	WHERE    CodOficina in (Select CodOficina From #Oficinas)
Open CurOficina1
Fetch Next From CurOficina1 Into @CodOficina
While @@Fetch_Status = 0
Begin
	Insert Into #Cartera
	Exec pCsRptCaSituacionCarteraVertical 1, @Corte, @CodOficina, 'Asesor', 'Asesor', 'ACTIVA', '02', 'CA01'
	
	Truncate Table #Cartera1
	
	Insert Into #Cartera1
	Exec pCsRptCaSituacionCarteraVertical 1, @Corte, @CodOficina, 'Asesor', 'Asesor', 'ACTIVA', '01', 'CA01'
	
	UPDATE    #Cartera
	SET       BSaldo = #Cartera1.ASaldo, FSaldo = #Cartera1.FSaldo
	FROM      #Cartera INNER JOIN
						  #Cartera1 ON #Cartera.UBI = #Cartera1.UBI AND #Cartera.CN1 = #Cartera1.CN1 AND #Cartera.CN2 = #Cartera1.CN2 AND #Cartera.Nivel1 = #Cartera1.Nivel1 AND 
						  #Cartera.Nivel2 = #Cartera1.Nivel2 AND #Cartera.Fecha = #Cartera1.Fecha AND #Cartera.Cartera = #Cartera1.Cartera AND #Cartera.Ubicacion = #Cartera1.Ubicacion AND 
						  #Cartera.ClaseCartera = #Cartera1.ClaseCartera
	Where (#Cartera.UBI In (@CodOficina))						  
	
	Update #Cartera 
	Set Nivel1 = 'MORA LEGAL',
		Nivel2 = 'MORA LEGAL'
	from #Cartera Inner Join (SELECT     tCsEmpleados.CodUsuario, tCsPadronClientes.Nombre1 + ', ' + tCsPadronClientes.Paterno AS MarcoLegal
	FROM         tCsEmpleados INNER JOIN
						  tCsPadronClientes ON tCsEmpleados.CodUsuario = tCsPadronClientes.CodUsuario
	WHERE     (tCsEmpleados.CodPuesto IN (15, 26, 37)) And Estado = 1) Empleados On Empleados.MarcoLegal = #Cartera.Nivel1 
	Where (#Cartera.UBI In (@CodOficina))
					
Fetch Next From CurOficina1 Into  @CodOficina
End 
Close 		CurOficina1
Deallocate 	CurOficina1

--Select * Into Cartera from #Cartera

--Select Fecha, UBI, Ubicacion, Titulo, Nivel1, Nivel2,  ASaldo
--from #Cartera 

SELECT      Fecha = Isnull(Datos.Fecha, @Corte), Cast(Datos.CodOficina as Int) as CodOficina, tClOficinas.NomOficina, Datos.Asesor, Datos.Nivel2, Datos.ASaldo, Datos.Capital,
			Avance = Case Capital When 0 then 0 Else Asaldo End/Case Capital When 0 then 1 Else Capital End * 100,	 
			Observacion =	Case 
								When Datos.Fecha Is Null	Then '02. Asesor no existe en el Padrón de Cartera al '  + dbo.FduFechaAtexto(@Corte, 'DD') + '/' + dbo.FduFechaAtexto(@Corte, 'MM') + '/' + dbo.FduFechaAtexto(@Corte, 'AAAA') 
								When Datos.Capital = 0		Then '03. No se tiene registro de la Meta del Asesor '
								Else '01. Datos Consistentes' 
							End,
			Gerente = R.Gerente, Datos.SaldoCartera, Datos.SaldoMora
FROM            (SELECT        Cartera.Fecha, ISNULL(Cartera.UBI, E.CodOficina) AS CodOficina, Cartera.Titulo, ISNULL(Cartera.Nivel1, E.Asesor) AS Asesor, Cartera.Nivel2, 
                                                    Isnull(Cartera.ASaldo, 0) as ASaldo, Isnull(E.Capital, 0) as Capital, Isnull(Cartera.BSaldo, 0) as SaldoCartera, Isnull(Cartera.FSaldo, 0) as SaldoMora
                          FROM            (SELECT        tCsMetas.Fecha, tCsMetas.CodOficina, tCsMetas.Sistema, tCsMetas.Capital, 
                                                                              ISNULL(tCsPadronClientes.Nombre1 + ', ' + tCsPadronClientes.Paterno, tCsMetas.Referencia) AS Asesor
                                                    FROM            tCsMetas LEFT OUTER JOIN
                                                                              tCsPadronClientes ON tCsMetas.CodUsuario = tCsPadronClientes.CodUsuario
                                                    WHERE        (tCsMetas.CodOficina IN
                                                                                  (SELECT DISTINCT UBI
                                                                                    FROM            #Cartera AS Cartera_1)) AND (tCsMetas.Fecha = @Proximo)) AS E FULL OUTER JOIN
                                                        (SELECT        Fecha, UBI, Ubicacion, Titulo, Nivel1, Nivel2, SUM(ASaldo) AS ASaldo, SUM(BSaldo) AS BSaldo, SUM(FSaldo) AS FSaldo
                                                          FROM            #Cartera AS Cartera_2
                                                          GROUP BY Fecha, UBI, Ubicacion, Titulo, Nivel1, Nivel2) AS Cartera ON E.CodOficina = Cartera.UBI AND E.Asesor = Cartera.Nivel1) 
                         AS Datos INNER JOIN
                         tClOficinas ON Datos.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN (SELECT     Datos.CodOficina, Max(Datos.Gerente) As Gerente
FROM         (SELECT     CodOficina, MAX(Contador) AS Contador
                       FROM          (SELECT     tCsFirmaReporteDetalle.EstadoCivil AS CodOficina, tCsFirmaReporteDetalle.Direccion AS Gerente, COUNT(*) AS Contador
                                               FROM          tCsFirmaReporteDetalle INNER JOIN
                                                                      tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma
                                               WHERE      (tCsFirmaReporteDetalle.Grupo = 'G') AND (dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAAMM') = @Periodo) AND 
                                                                      (tCsFirmaReporteDetalle.Identificador = 1)
                                               GROUP BY tCsFirmaReporteDetalle.EstadoCivil, tCsFirmaReporteDetalle.Direccion) Datos
                       GROUP BY CodOficina) T INNER JOIN
                          (SELECT     tCsFirmaReporteDetalle.EstadoCivil AS CodOficina, tCsFirmaReporteDetalle.Direccion AS Gerente, COUNT(*) AS Contador
                            FROM          tCsFirmaReporteDetalle INNER JOIN
                                                   tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma
                            WHERE      (tCsFirmaReporteDetalle.Grupo = 'G') AND (dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAAMM') = @Periodo) AND 
                                                   (tCsFirmaReporteDetalle.Identificador = 1)
                            GROUP BY tCsFirmaReporteDetalle.EstadoCivil, tCsFirmaReporteDetalle.Direccion) Datos ON T.CodOficina = Datos.CodOficina AND T.Contador = Datos.Contador Group by Datos.CodOficina) R ON
                            R.CodOficina = Datos.CodOficina
Drop Table #Oficinas
Drop Table #Cartera
Drop Table #Cartera1

GO