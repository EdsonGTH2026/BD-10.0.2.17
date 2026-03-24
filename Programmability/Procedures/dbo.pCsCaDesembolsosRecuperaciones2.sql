SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Drop Procedure pCsCaDesembolsosRecuperaciones2 
-- Exec pCsCaDesembolsosRecuperaciones2  '20110512'
CREATE PROCEDURE  [dbo].[pCsCaDesembolsosRecuperaciones2] 
@Fecha SmalldateTime
AS

CREATE TABLE #Kemy (
	[Fecha] [smalldatetime] NULL ,
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NULL ,
	[DescOficina] [varchar] (40) COLLATE Modern_Spanish_CI_AI NULL ,
	[NroDesembolso] [int] NOT NULL ,
	[Desembolso] [money] NOT NULL ,
	[Nropordesembolsar] [int] NOT NULL ,
	[Pordesembolsar] [money] NOT NULL ,
	[MontoPagado] [money] NOT NULL ,
	[Capital] [money] NOT NULL ,
	[Interes] [money] NOT NULL ,
	[Moratorio] [money] NOT NULL ,
	[CargoxMora] [money] NOT NULL ,
	[IVAInteres] [money] NOT NULL ,
	[IVAMoratorio] [money] NOT NULL ,
	[IVACargoxMora] [money] NOT NULL ,
	[NroOper] [int] NOT NULL,
	[CC] [money] NOT NULL,
	[PKProgramado] [money] NOT NULL ,
	[PKAtrasado] [money] NOT NULL ,
	[PKAdelantado] [money] NOT NULL  
) ON [PRIMARY]

Insert Into #Kemy
Exec  [BD-FINAMIGO-DC].finmas.dbo.pCsCaDesembolsosRecuperaciones @Fecha

CREATE TABLE #Kemy1 (
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[SaldoCapital] [decimal](38, 6) NULL ,
	[InteresTotal] [decimal](38, 6) NULL ,
	[InteresBalance] [decimal](38, 6) NULL ,
	[InteresCtaOrden] [decimal](38, 6) NULL 
) ON [PRIMARY]

Declare @P Int

Set @P = 0
If (Select DateDiff(Day, FechaConsolidacion, @Fecha) From vCsFechaConsolidacion ) = 1
Begin
	Set @P = 1
End

Print @P

If @P = 0
Begin 
	Insert Into #Kemy1
	SELECT        CodOficina, AVG(SaldoCapital) AS SaldoCapital, AVG(InteresTotal) / AVG(SaldoCapital) * 100 AS InteresTotal, AVG(InteresBalance) 
											/ AVG(SaldoCapital) * 100 AS InteresBalance, AVG(InteresCtaOrden) / AVG(SaldoCapital) * 100 AS InteresCtaOrden
	           
	FROM            (SELECT        tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina, SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, 
													  SUM(tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio) AS InteresTotal, 
													  SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
													   AS InteresBalance, SUM(tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioCtaOrden) AS InteresCtaOrden
							FROM            tCsCarteraDet INNER JOIN
													  tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
							WHERE     (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA')) 
							GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina) AS Datos
	GROUP BY CodOficina  
End 

If @P = 1
Begin 
	
	Declare @Contador	Int
	Declare @F			SmallDateTime
	Set @Contador	= 0
	Set @F			= @Fecha
		
	Create Table #K 
	(
		F SmallDateTime
	)

	While @Contador <= 5
	Begin
		Insert Into #K (F) Values(@F)
		Set @F			= DateAdd(Month, -1, @Fecha)
		Set @Contador	= @Contador		+ 1
	End

	Insert Into #Kemy1
	SELECT        CodOficina, AVG(SaldoCapital) AS SaldoCapital, AVG(InteresTotal) / AVG(SaldoCapital) * 100 AS InteresTotal, AVG(InteresBalance) 
											/ AVG(SaldoCapital) * 100 AS InteresBalance, AVG(InteresCtaOrden) / AVG(SaldoCapital) * 100 AS InteresCtaOrden
	           
	FROM            (SELECT        tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina, SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, 
													  SUM(tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio) AS InteresTotal, 
													  SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
													   AS InteresBalance, SUM(tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioCtaOrden) AS InteresCtaOrden
							FROM            tCsCarteraDet INNER JOIN
													  tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
							WHERE       (tCsCarteraDet.Fecha = @Fecha - 1) AND (tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA')) 
							GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina) AS Datos
	GROUP BY CodOficina  

	UPDATE    #Kemy1
	SET			InteresTotal	= 2 * #Kemy1.InteresTotal - Kemy2.InteresTotal,
				InteresBalance	= 2 * #Kemy1.InteresBalance		- Kemy2.InteresBalance,
				InteresCtaOrden	= 2 * #Kemy1.InteresCtaOrden	- Kemy2.InteresCtaOrden					
	FROM         #Kemy1 INNER JOIN
							  (SELECT     CodOficina, AVG(SaldoCapital) AS SaldoCapital, AVG(InteresTotal) / AVG(SaldoCapital) * 100 AS InteresTotal, AVG(InteresBalance) / AVG(SaldoCapital) 
													   * 100 AS InteresBalance, AVG(InteresCtaOrden) / AVG(SaldoCapital) * 100 AS InteresCtaOrden
								FROM          (SELECT     tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina, SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, 
																			   SUM(tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio) AS InteresTotal, 
																			   SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido) 
																			   AS InteresBalance, SUM(tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioCtaOrden) AS InteresCtaOrden
														FROM          tCsCarteraDet INNER JOIN
																			   tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
														--WHERE   (tCsCarteraDet.Fecha <= @Fecha - 2) AND (tCsCarteraDet.Fecha >= @Fecha - 9) AND
														WHERE   (tCsCarteraDet.Fecha IN (Select F From #K)) AND
																(tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA'))
														GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina) AS Datos
								GROUP BY CodOficina) Kemy2 ON #Kemy1.CodOficina = Kemy2.CodOficina COLLATE Modern_Spanish_CI_AI
								
	Drop Table #K								
End
If @P = 0
Begin 
	SELECT     Zona, NomZon, @Fecha AS Fecha, CodOficina, Oficina, NroDesembolso, Desembolso, Nropordesembolsar, Pordesembolsar, MontoPagado, Capital, Interes, 
						  Moratorio, CargoxMora, IVAInteres, IVAMoratorio, IVACargoxMora, NroOper, 0 AS CapitalAyer, CapitalAyer AS CapitalActual, CapitalAyer AS CapitalPendiente, 
						  CapitalAyer * InteresTotal / 100 + CapitalAyer AS SaldoKIM, CapitalAyer * InteresBalance / 100 + CapitalAyer AS SaldoCartera, CC, Tipo, 
						  PKProgramado, PKAtrasado, PKAdelantado
	FROM         (SELECT     tClOficinas.Zona, ISNULL(tClZona.Nombre, 'Zona No Especificada') AS NomZon, [#Kemy1].CodOficina, dbo.fduRellena('0', [#Kemy1].CodOficina, 2, 'D') 
												  + ' ' + tClOficinas.NomOficina AS Oficina, ISNULL([#Kemy].NroDesembolso, 0) AS NroDesembolso, ISNULL([#Kemy].Desembolso, 0) AS Desembolso, 
												  ISNULL([#Kemy].Nropordesembolsar, 0) AS Nropordesembolsar, ISNULL([#Kemy].Pordesembolsar, 0) AS Pordesembolsar, ISNULL([#Kemy].MontoPagado, 
												  0) AS MontoPagado, ISNULL([#Kemy].Capital, 0) AS Capital, ISNULL([#Kemy].Interes, 0) AS Interes, ISNULL([#Kemy].Moratorio, 0) AS Moratorio, 
												  ISNULL([#Kemy].CargoxMora, 0) AS CargoxMora, ISNULL([#Kemy].IVAInteres, 0) AS IVAInteres, ISNULL([#Kemy].IVAMoratorio, 0) AS IVAMoratorio, 
												  ISNULL([#Kemy].IVACargoxMora, 0) AS IVACargoxMora, ISNULL([#Kemy].NroOper, 0) AS NroOper, [#Kemy1].SaldoCapital AS CapitalAyer, 
												  [#Kemy1].InteresTotal, [#Kemy1].InteresBalance, [#Kemy1].InteresCtaOrden, ISNULL([#Kemy].CC, 0) AS CC, tClOficinas.Tipo,
												  ISNULL([#Kemy].PKProgramado, 0)	AS PKProgramado,
												  ISNULL([#Kemy].PKAtrasado, 0)		AS PKAtrasado,
												  ISNULL([#Kemy].PKAdelantado, 0)	AS PKAdelantado
						   FROM          tClOficinas INNER JOIN
												  [#Kemy1] ON tClOficinas.CodOficina = [#Kemy1].CodOficina LEFT OUTER JOIN
												  tClZona ON tClOficinas.Zona = tClZona.Zona LEFT OUTER JOIN
												  [#Kemy] ON [#Kemy1].CodOficina = [#Kemy].CodOficina) AS Datos
	ORDER BY Zona, Oficina
End
If @P = 1
Begin 
	SELECT     tClOficinas.Zona, ISNULL(tClZona.Nombre, 'Zona No Especificada') AS NomZon, @Fecha AS Fecha, Datos.Codoficina, dbo.fduRellena('0', Datos.Codoficina, 2, 'D') 
						  + ' ' + tClOficinas.NomOficina AS Oficina, Datos.NroDesembolso, Datos.Desembolso, Datos.Nropordesembolsar, Datos.Pordesembolsar, Datos.MontoPagado, 
						  Datos.Capital, Datos.Interes, Datos.Moratorio, Datos.CargoxMora, Datos.IVAInteres, Datos.IVAMoratorio, Datos.IVACargoxMora, Datos.NroOper, Datos.CapitalAyer, 
						  Datos.CapitalAyer + Datos.Desembolso - Datos.Capital AS CapitalActual, 
						  Datos.CapitalAyer + Datos.Desembolso + Datos.Pordesembolsar - Datos.Capital - Datos.CC AS CapitalPendiente, 
						  (Datos.CapitalAyer + Datos.Desembolso + Datos.Pordesembolsar - Datos.Capital - Datos.CC) 
						  * Datos.InteresTotal / 100 + (Datos.CapitalAyer + Datos.Desembolso + Datos.Pordesembolsar - Datos.Capital - Datos.CC) AS SaldoKIM, 
						  (Datos.CapitalAyer + Datos.Desembolso + Datos.Pordesembolsar - Datos.Capital - Datos.CC) 
						  * Datos.InteresBalance / 100 + (Datos.CapitalAyer + Datos.Desembolso + Datos.Pordesembolsar - Datos.Capital - Datos.CC) AS SaldoCartera, Datos.CC, 
						  tClOficinas.Tipo, PKProgramado, PKAtrasado, PKAdelantado
	FROM         (SELECT     ISNULL([#Kemy1].CodOficina, [#Kemy].CodOficina) AS Codoficina, ISNULL([#Kemy].NroDesembolso, 0) AS NroDesembolso, ISNULL([#Kemy].Desembolso, 
												  0) AS Desembolso, ISNULL([#Kemy].Nropordesembolsar, 0) AS Nropordesembolsar, ISNULL([#Kemy].Pordesembolsar, 0) AS Pordesembolsar, 
												  ISNULL([#Kemy].MontoPagado, 0) AS MontoPagado, ISNULL([#Kemy].Capital, 0) AS Capital, ISNULL([#Kemy].Interes, 0) AS Interes, 
												  ISNULL([#Kemy].Moratorio, 0) AS Moratorio, ISNULL([#Kemy].CargoxMora, 0) AS CargoxMora, ISNULL([#Kemy].IVAInteres, 0) AS IVAInteres, 
												  ISNULL([#Kemy].IVAMoratorio, 0) AS IVAMoratorio, ISNULL([#Kemy].IVACargoxMora, 0) AS IVACargoxMora, ISNULL([#Kemy].NroOper, 0) AS NroOper, 
												  ISNULL([#Kemy1].SaldoCapital, 0) AS CapitalAyer, ISNULL([#Kemy1].InteresTotal, 0) AS InteresTotal, ISNULL([#Kemy1].InteresBalance, 0) 
												  AS InteresBalance, ISNULL([#Kemy1].InteresCtaOrden, 0) AS InteresCtaOrden, ISNULL([#Kemy].CC, 0) AS CC,
												  ISNULL([#Kemy].PKProgramado, 0)	AS PKProgramado,
												  ISNULL([#Kemy].PKAtrasado, 0)		AS PKAtrasado,
												  ISNULL([#Kemy].PKAdelantado, 0)	AS PKAdelantado
						   FROM          [#Kemy1] FULL OUTER JOIN
												  [#Kemy] ON [#Kemy].CodOficina = [#Kemy1].CodOficina) AS Datos INNER JOIN
						  tClOficinas ON Datos.Codoficina = tClOficinas.CodOficina LEFT OUTER JOIN
						  tClZona ON tClOficinas.Zona = tClZona.Zona
	ORDER BY tClOficinas.Zona, Oficina
End

Drop Table #Kemy
Drop Table #Kemy1


GO