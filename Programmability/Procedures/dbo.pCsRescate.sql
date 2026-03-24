SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsRescate
CREATE Procedure [dbo].[pCsRescate]
@Encargado 	Varchar(100),
@FInicio	SmallDateTime,
@FFin		SmallDateTime
As

Declare @Rubro	Varchar(1000)
Declare @Ubicacion 	Varchar(500)
Declare @CUbicacion	Varchar(1000)
Declare @Cadena	Varchar(4000)
Declare @OtroDato	Varchar(500)

Declare @FI		SmallDateTime
Declare @FF		SmallDateTime
Declare @Cartera	Varchar(50)

Set @Rubro = @Encargado

SELECT  @Ubicacion = CodOficina, @FI = Inicio, @FF = Fin, @Cartera = Cartera
FROM         tCsProyectoRescate
WHERE     (Rubro = @Rubro)

If @FI 		> @FInicio 	Begin Set @FInicio 	= @FI 		End
If @FF 		< @FFin 	Begin Set @FFin 	= @FF 		End
If @FInicio 	> @FFin	
Begin 
	Set @FI		= @FInicio 
	Set @FInicio	= @FFin 
	Set @FFin 	= @FI
End 

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out

CREATE TABLE #Oficinas (
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL ,	
	[NomOficina] [varchar] (30) COLLATE Modern_Spanish_CI_AI NULL)

Set @Cadena = 'Insert Into #Oficinas (CodOficina, NomOficina) Select CodOficina, Nomoficina From tClOficinas Where CodOficina IN ('+ @CUbicacion +')'
Exec(@Cadena)

SELECT  Inicio = @FInicio, Fin = @FFin, Datos.CodOficina, Datos.Oficina, Datos.Inicio, Datos.Fin, Datos.Encargado, Datos.Corte, Datos.DiasAtraso, Datos.CondonacionInteres, Datos.CondonacionOtros, 
                      Datos.CodPrestamo, Datos.ClienteGrupo, Datos.Asesor, tCsPadronCarteraDet.EstadoCalculado AS EstadoActual, Datos.FechaDesembolso, Datos.MontoDesembolso, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN tCsPadronCarteraDet.FechaCorte + 1 ELSE tCsPadronCarteraDet.FechaCorte END AS FechaCorte,
                       CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.SaldoCapital) END AS SaldoCapital, 
                      SUM(tCsCarteraDet.InteresVigente) AS InteresVigente, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.InteresVencido) END AS InteresVencido, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.InteresCtaOrden) END AS InteresCtaOrden, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.MoratorioVigente) END AS MoratorioVigente, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.MoratorioVencido) END AS MoratorioVencido, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.MoratorioCtaOrden) END AS MoratorioCtaOrden, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.CargoMora) END AS CargoMora, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.Impuestos) END AS Impuestos, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE SUM(tCsCarteraDet.OtrosCargos) END AS OtrosCargos, 
                      CASE WHEN tCsPadronCarteraDet.EstadoCalculado = 'CANCELADO' THEN 0 ELSE tCsCartera.NroDiasAtraso END AS NroDiasAtraso, Datos.ObjetivoDias, 
                      Isnull(Pagos.Pago, 0) as Pago, Datos.PorcComisionSinIVA
FROM         (SELECT     tClOficinas.CodOficina, tClOficinas.NomOficina AS Oficina, tCsProyectoRescate.Inicio, tCsProyectoRescate.Fin, tCsProyectoRescate.Rubro AS Encargado, 
                                              tCsProyectoRescate.Corte, '[' + CAST(daI AS varchar(10)) + '-' + CAST(daF AS varchar(10)) + ']' AS DiasAtraso, tCsProyectoRescate.CondonacionInteres, 
                                              tCsProyectoRescate.CondonacionOtros, tCsCartera.CodPrestamo, ISNULL(tCsCarteraGrupos.NombreGrupo, tCsPadronClientes.NombreCompleto) 
                                              AS ClienteGrupo, tCsPadronClientes_1.NombreCompleto AS Asesor, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso, ObjetivoDias, PorcComisionSinIVA
                       FROM          tCsCartera INNER JOIN
                                              tCsProyectoRescate ON tCsCartera.Fecha = tCsProyectoRescate.Corte AND tCsCartera.NroDiasAtraso >= tCsProyectoRescate.DAI AND 
                                              tCsCartera.NroDiasAtraso <= tCsProyectoRescate.DAF INNER JOIN
                                             #Oficinas  tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
                                              tCsPadronClientes tCsPadronClientes_1 ON tCsCartera.CodAsesor = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN
                                              tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                                              tCsCarteraGrupos ON tCsCartera.CodOficina = tCsCarteraGrupos.CodOficina AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo
                       WHERE      (tCsProyectoRescate.Rubro = @Rubro) AND (tCsProyectoRescate.Activo = 1) And tCsCartera.Cartera IN (@Cartera)) Datos INNER JOIN
                      tCsPadronCarteraDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo INNER JOIN
                      tCsCarteraDet ON tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario INNER JOIN
                      tCsCartera ON tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsCarteraDet.Fecha = tCsCartera.Fecha LEFT OUTER JOIN
                          (SELECT     CodPrestamo, SUM(MontoPagado) AS Pago
                            FROM          tCsPagoDet
                            WHERE      (Extornado = 0) AND (CodConcepto NOT LIKE 'IVA%') AND (Fecha >= @FInicio) AND (Fecha <= @FFin)
                            GROUP BY CodPrestamo) Pagos ON tCsPadronCarteraDet.CodPrestamo = Pagos.CodPrestamo COLLATE Modern_Spanish_CI_AI
GROUP BY Datos.CodOficina, Datos.Oficina, Datos.Inicio, Datos.Fin, Datos.Encargado, Datos.Corte, Datos.DiasAtraso, Datos.CondonacionInteres, Datos.CondonacionOtros, 
                      Datos.CodPrestamo, Datos.ClienteGrupo, Datos.Asesor, Datos.FechaDesembolso, Datos.MontoDesembolso, tCsPadronCarteraDet.FechaCorte, 
                      tCsPadronCarteraDet.EstadoCalculado, tCsCartera.NroDiasAtraso, Datos.ObjetivoDias, Pagos.Pago, Datos.PorcComisionSinIVA

Drop Table #Oficinas
GO