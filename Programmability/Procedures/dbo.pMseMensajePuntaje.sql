SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pMseMensajePuntaje

Create Procedure [dbo].[pMseMensajePuntaje]
@Fecha SmallDateTime
As
--Declare @Fecha SmallDateTime 
--Set @Fecha = '20080630'

--Truncate Table tMsePuntaje

If Year(@Fecha) < 2008 
Begin 
	Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion
End

If @Fecha = '20080317'
Begin 
	Set @Fecha = '20080318'
End

Declare @Formato 	Varchar(8)
Declare @Grupo		Varchar(100)
Declare @Dias		Int
Declare @TempI		Int
Declare @TempF		SmallDateTime

Declare @Dia		 Bit
Declare @Mes		 Bit
Declare @Año		 Bit

Delete tMsePuntaje Where Fin = @Fecha
Print GetDate()
Set @Formato 	= 'AAAAMMDD'
Set @Grupo	= '01 Diario'

If dbo.fduCalculoFinMes(@Fecha) <> 1			
Begin
	Set 	@Dias		= 1
	If 	@Fecha 		= '20080318'
	Begin 
		Set @Dias 	= 2
	End
	Set @Dia		= 1
	Set @Mes		= 1
	Set @Año		= 1
End
If dbo.fduCalculoFinMes(@Fecha) = 1			
Begin
	Set @Dias	= Day(@Fecha)
	Set @Dia		= 0
	Set @Mes		= 1
	Set @Año		= 1
End
If Day(@Fecha)		= 31 And Month(@Fecha) = 12	
Begin
	Set @Dias	= DateDiff(day, Cast(dbo.fdufechaatexto(DateAdd(Year, -1, @Fecha), 'AAAA') + '12' + '31' as SmallDateTime), @Fecha)
	Set @Dia		= 0
	Set @Mes		= 0
	Set @Año		= 1
End

--/*
If @Dia = 1
Begin
Insert Into   tMsePuntaje (Ubicacion, Inicio, Fin, F, Grupo, P1, P2, PT, PSC, PMV, PMR, PEP, Visible)
SELECT     *, Visible = @Año
FROM         (SELECT     Datos.Ubicacion, Datos.Inicio, Datos.Fin, Datos.F, Datos.Grupo, Datos.Puntaje AS P1, Detalle.Puntaje AS P2, 
                                              Datos.Puntaje * 100 - Detalle.Puntaje AS PT, SC, MV, MR, EP
                       FROM          (SELECT     Ubicacion, MIN(Inicio) AS Inicio, MAX(Fin) AS Fin, SUM(D) / SUM(Factor) AS Puntaje, SUM(Factor) AS F, Grupo = @Grupo
                                               FROM          (SELECT     Ubicacion, Inicio, Fin, Puntaje, DATEDIFF([day], Inicio, Fin) AS Factor, Puntaje * DATEDIFF([day], Inicio, Fin) AS D
                                                                       FROM          tMseMensaje
                                                                       WHERE      (dbo.fduFechaATexto(Fin, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) AND Fin <= @Fecha) Datos
                                               GROUP BY Ubicacion
                                               HAVING      MAX(Fin) = @Fecha AND SUM(Factor) = @Dias
						) Datos INNER JOIN
                                                  (SELECT     Ubicacion, Inicio, Fin, AVG(D) AS Puntaje, SUM(SC) AS SC, SUM(MV) AS MV, SUM(MR) AS MR, SUM(EP) AS EP
							FROM         (SELECT     Ubicacion, MIN(Inicio) AS Inicio, MAX(Fin) AS Fin, P, AVG(D) AS D, AVG(SC) AS SC, AVG(MV) AS MV, AVG(MR) AS MR, AVG(EP) AS EP
							FROM         (SELECT     Ubicacion, Inicio, Fin, P, SUM(D) * CAST(P + '1' AS int) AS D, SUM(SC) AS SC, SUM(MV) AS MV, SUM(MR) AS MR, SUM(EP) AS EP
							                       FROM          (SELECT     *, CASE WHEN CASE WHEN Concepto IN ('Saldo Cartera', 'Saldo Capital') THEN (Valorac - valoran) 
							                                                                      / CASE valoran WHEN 0 THEN ValorAc ELSE valoran END * 100 ELSE valorac - valoran END > 100 THEN 100 ELSE CASE WHEN Concepto IN ('Saldo Cartera',
							                                                                       'Saldo Capital') THEN (Valorac - valoran) / CASE valoran WHEN 0 THEN ValorAc ELSE valoran END * 100 ELSE valorac - valoran END END AS D, 
							                                                                      CASE WHEN Concepto IN ('Saldo Cartera', 'Saldo Capital') THEN '+' ELSE '-' END AS P, CASE WHEN Concepto IN ('Saldo Capital', 
							                                                                      'Saldo Cartera') THEN ValorAc ELSE 0 END AS SC, CASE WHEN Concepto IN ('Mora Vencida') THEN ValorAc ELSE 0 END AS MV, 
							                                                                      CASE WHEN Concepto IN ('Mora Real') THEN ValorAc ELSE 0 END AS MR, CASE WHEN Concepto IN ('Estimación Preventiva') 
							                                                                      THEN ValorAc ELSE 0 END AS EP
							                                               FROM          tMseMensajeDetalle
							                                               WHERE (dbo.fduFechaATexto(Fin, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) AND (Fin <= @Fecha)) 
							                                              Datos
							                       GROUP BY Ubicacion, P, Inicio, Fin) Datos
							GROUP BY Ubicacion, P) Datos
							GROUP BY Ubicacion, Inicio, Fin) Detalle ON Datos.Ubicacion = Detalle.Ubicacion AND Datos.Inicio = Detalle.Inicio AND Datos.Fin = Detalle.Fin) Datos

End
Print GetDate()
Set @Formato 	= 'AAAAMM'
Set @Grupo	= '02 Mensual'

If dbo.fduCalculoFinMes(@Fecha) <> 1			
Begin
	Set @Dias	= DateDiff(day, DateAdd(day, -1, Cast(dbo.fdufechaatexto(@Fecha, 'AAAAMM') + '01' as SmallDateTime)), @Fecha)
End
If dbo.fduCalculoFinMes(@Fecha) = 1			
Begin
	Set @Dias	= Day(@Fecha) * 2 - 1
End
If Day(@Fecha)		= 31 And Month(@Fecha) = 12	
Begin
	Set @Dias	= DateDiff(day, Cast(dbo.fdufechaatexto(DateAdd(Year, -1, @Fecha), 'AAAA') + '12' + '31' as SmallDateTime), @Fecha) + Day(@Fecha) - 1
End
If @Mes = 1
BEgin
Insert Into   tMsePuntaje (Ubicacion, Inicio, Fin, F, Grupo, P1, P2, PT, PSC, PMV, PMR, PEP, Visible)
SELECT     *, Visible = @Año
FROM         (SELECT     Datos.Ubicacion, Datos.Inicio, Datos.Fin, Datos.F, Datos.Grupo, Datos.Puntaje AS P1, Detalle.Puntaje AS P2, 
                                              Datos.Puntaje * 100 - Detalle.Puntaje AS PT, SC, MV, MR, EP
                       FROM          (SELECT     Ubicacion, MIN(Inicio) AS Inicio, MAX(Fin) AS Fin, SUM(D) / SUM(Factor) AS Puntaje, SUM(Factor) AS F, Grupo = @Grupo
                                               FROM          (SELECT     Ubicacion, Inicio, Fin, Puntaje, DATEDIFF([day], Inicio, Fin) AS Factor, Puntaje * DATEDIFF([day], Inicio, Fin) AS D
                                                                       FROM          tMseMensaje
                                                                       WHERE      (dbo.fduFechaATexto(Fin, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) AND Fin <= @Fecha) Datos
                                               GROUP BY Ubicacion
                                               HAVING      MAX(Fin) = @Fecha AND SUM(Factor) = @Dias
						) Datos INNER JOIN
                                                  (SELECT     Ubicacion, Inicio, Fin, AVG(D) AS Puntaje, SUM(SC) AS SC, SUM(MV) AS MV, SUM(MR) AS MR, SUM(EP) AS EP
							FROM         (SELECT     Ubicacion, MIN(Inicio) AS Inicio, MAX(Fin) AS Fin, P, AVG(D) AS D, AVG(SC) AS SC, AVG(MV) AS MV, AVG(MR) AS MR, AVG(EP) AS EP
							FROM         (SELECT     Ubicacion, Inicio, Fin, P, SUM(D) * CAST(P + '1' AS int) AS D, SUM(SC) AS SC, SUM(MV) AS MV, SUM(MR) AS MR, SUM(EP) AS EP
							                       FROM          (SELECT     *, CASE WHEN CASE WHEN Concepto IN ('Saldo Cartera', 'Saldo Capital') THEN (Valorac - valoran) 
							                                                                      / CASE valoran WHEN 0 THEN ValorAc ELSE valoran END * 100 ELSE valorac - valoran END > 100 THEN 100 ELSE CASE WHEN Concepto IN ('Saldo Cartera',
							                                                                       'Saldo Capital') THEN (Valorac - valoran) / CASE valoran WHEN 0 THEN ValorAc ELSE valoran END * 100 ELSE valorac - valoran END END AS D, 
							                                                                      CASE WHEN Concepto IN ('Saldo Cartera', 'Saldo Capital') THEN '+' ELSE '-' END AS P, CASE WHEN Concepto IN ('Saldo Capital', 
							                                                                      'Saldo Cartera') THEN ValorAc ELSE 0 END AS SC, CASE WHEN Concepto IN ('Mora Vencida') THEN ValorAc ELSE 0 END AS MV, 
							                                                                      CASE WHEN Concepto IN ('Mora Real') THEN ValorAc ELSE 0 END AS MR, CASE WHEN Concepto IN ('Estimación Preventiva') 
							                                                                      THEN ValorAc ELSE 0 END AS EP
							                                               FROM          tMseMensajeDetalle
							                                               WHERE (dbo.fduFechaATexto(Fin, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) AND (Fin <= @Fecha)) 
							                                              Datos
							                       GROUP BY Ubicacion, P, Inicio, Fin) Datos
							GROUP BY Ubicacion, P) Datos
							GROUP BY Ubicacion, Inicio, Fin) Detalle ON Datos.Ubicacion = Detalle.Ubicacion AND Datos.Inicio = Detalle.Inicio AND Datos.Fin = Detalle.Fin) Datos
End
--*/
Print GetDate()
Set @Formato 	= 'AAAA'
Set @Grupo	= '03 Anual'

If dbo.fduCalculoFinMes(@Fecha) <> 1			
Begin
	Set @Dias 	= 0
	Set @TempI	= Month(@Fecha) - 1
	Set @TempF	= @Fecha
	While @TempI 	<> 0
	Begin
		Set @Dias = @Dias + Day(DateAdd(day, -1, Cast(dbo.fdufechaatexto(@TempF, 'AAAAMM') + '01' as SmallDateTime)))
		Set @TempI = @TempI - 1
		Set @TempF = Dateadd(month, -1, @TempF)
	End
	Set @Dias 	= DateDiff(day, Cast(dbo.fdufechaatexto(DateAdd(Year, -1, @Fecha), 'AAAA') + '12' + '31' as SmallDateTime), @Fecha) +  @Dias
	Set @Dias	= @Dias - (Month(@Fecha) - 1)
End
If dbo.fduCalculoFinMes(@Fecha) = 1			
Begin
	Set @Dias 	= 0
	Set @TempI	= Month(@Fecha) 
	Set @TempF	= @Fecha
	While @TempI 	<> 0
	Begin
		Set @Dias = @Dias + Day(DateAdd(day, -1, Cast(dbo.fdufechaatexto(DateAdd(Month, 1, @TempF), 'AAAAMM') + '01' as SmallDateTime)))
		Set @TempI = @TempI - 1
		Set @TempF = Dateadd(month, -1, @TempF)
	End
	Set @Dias 	= DateDiff(day, Cast(dbo.fdufechaatexto(DateAdd(Year, -1, @Fecha), 'AAAA') + '12' + '31' as SmallDateTime), @Fecha) +  @Dias
	Set @Dias	= @Dias - (Month(@Fecha))
End
If Day(@Fecha)		= 31 And Month(@Fecha) = 12	
Begin
	Set @Dias 	= 0
	Set @TempI	= Month(@Fecha) - 1 
	Set @TempF	= @Fecha
	While @TempI 	<> 0
	Begin
		Set @Dias = @Dias + Day(DateAdd(day, -1, Cast(dbo.fdufechaatexto(DateAdd(Month, 1, @TempF), 'AAAAMM') + '01' as SmallDateTime)))
		Set @Dias = @Dias + Day(DateAdd(day, -1, Cast(dbo.fdufechaatexto(DateAdd(Month, 1, @TempF), 'AAAAMM') + '01' as SmallDateTime))) - 1
		Set @TempI = @TempI - 1
		Set @TempF = Dateadd(month, -1, @TempF)
	End
	Set @Dias 	= DateDiff(day, Cast(dbo.fdufechaatexto(DateAdd(Year, -1, @Fecha), 'AAAA') + '12' + '31' as SmallDateTime), @Fecha) +  @Dias
	Set @Dias 	= @Dias + 30
End
Print @Dias

If @Año = 1
Begin
Insert Into   tMsePuntaje (Ubicacion, Inicio, Fin, F, Grupo, P1, P2, PT, PSC, PMV, PMR, PEP, Visible)
SELECT     *, Visible = @Año
FROM         (SELECT     Datos.Ubicacion, Datos.Inicio, Datos.Fin, Datos.F, Datos.Grupo, Datos.Puntaje AS P1, Detalle.Puntaje AS P2, 
                                              Datos.Puntaje * 100 - Detalle.Puntaje AS PT, SC, MV, MR, EP
                       FROM          (SELECT     Ubicacion, MIN(Inicio) AS Inicio, MAX(Fin) AS Fin, SUM(D) / SUM(Factor) AS Puntaje, SUM(Factor) AS F, Grupo = @Grupo
                                               FROM          (SELECT     Ubicacion, Inicio, Fin, Puntaje, DATEDIFF([day], Inicio, Fin) AS Factor, Puntaje * DATEDIFF([day], Inicio, Fin) AS D
                                                                       FROM          tMseMensaje
                                                                       WHERE      (dbo.fduFechaATexto(Fin, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) AND Fin <= @Fecha) Datos
                                               GROUP BY Ubicacion
                                               HAVING      MAX(Fin) = @Fecha AND SUM(Factor) = @Dias
						) Datos INNER JOIN
                                                  (SELECT     Ubicacion, Inicio, Fin, AVG(D) AS Puntaje, SUM(SC) AS SC, SUM(MV) AS MV, SUM(MR) AS MR, SUM(EP) AS EP
							FROM         (SELECT     Ubicacion, MIN(Inicio) AS Inicio, MAX(Fin) AS Fin, P, AVG(D) AS D, AVG(SC) AS SC, AVG(MV) AS MV, AVG(MR) AS MR, AVG(EP) AS EP
							FROM         (SELECT     Ubicacion, Inicio, Fin, P, SUM(D) * CAST(P + '1' AS int) AS D, SUM(SC) AS SC, SUM(MV) AS MV, SUM(MR) AS MR, SUM(EP) AS EP
							                       FROM          (SELECT     *, CASE WHEN CASE WHEN Concepto IN ('Saldo Cartera', 'Saldo Capital') THEN (Valorac - valoran) 
							                                                                      / CASE valoran WHEN 0 THEN ValorAc ELSE valoran END * 100 ELSE valorac - valoran END > 100 THEN 100 ELSE CASE WHEN Concepto IN ('Saldo Cartera',
							                                                                       'Saldo Capital') THEN (Valorac - valoran) / CASE valoran WHEN 0 THEN ValorAc ELSE valoran END * 100 ELSE valorac - valoran END END AS D, 
							                                                                      CASE WHEN Concepto IN ('Saldo Cartera', 'Saldo Capital') THEN '+' ELSE '-' END AS P, CASE WHEN Concepto IN ('Saldo Capital', 
							                                                                      'Saldo Cartera') THEN ValorAc ELSE 0 END AS SC, CASE WHEN Concepto IN ('Mora Vencida') THEN ValorAc ELSE 0 END AS MV, 
							                                                                      CASE WHEN Concepto IN ('Mora Real') THEN ValorAc ELSE 0 END AS MR, CASE WHEN Concepto IN ('Estimación Preventiva') 
							                                                                      THEN ValorAc ELSE 0 END AS EP
							                                               FROM          tMseMensajeDetalle
							                                               WHERE (dbo.fduFechaATexto(Fin, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) AND (Fin <= @Fecha)) 
							                                              Datos
							                       GROUP BY Ubicacion, P, Inicio, Fin) Datos
							GROUP BY Ubicacion, P) Datos
							GROUP BY Ubicacion, Inicio, Fin) Detalle ON Datos.Ubicacion = Detalle.Ubicacion AND Datos.Inicio = Detalle.Inicio AND Datos.Fin = Detalle.Fin) Datos

End
Print GetDate()
Delete tMsePuntaje Where Ubicacion = 'ZZZ'

UPDATE    tMsePuntaje
SET              descripcion = nombrecompleto, Grupo = Grupo + ' - Asesor', CodOficina = tCsCartera.CodOficina
FROM         tMsePuntaje INNER JOIN
                      tCsPadronClientes ON tMsePuntaje.Ubicacion = tCsPadronClientes.CodUsuario INNER JOIN
                      tCsCartera ON tMsePuntaje.Ubicacion = tCsCartera.CodAsesor AND tMsePuntaje.Fin = tCsCartera.Fecha
WHERE     (tMsePuntaje.Descripcion IS NULL)

UPDATE    tMsePuntaje
SET              Descripcion = nomoficina, Grupo = Grupo + ' - Oficina', CodOficina = tClOficinas.CodOficina
FROM         tMsePuntaje INNER JOIN
                      tClOficinas ON tMsePuntaje.Ubicacion = dbo.fduRellena('0', tClOficinas.CodOficina, 3, 'D')
Where Descripcion Is Null

UPDATE    tMsePuntaje
SET              Descripcion = Nombre, Grupo = Grupo + ' - Zona'
FROM         tMsePuntaje INNER JOIN
                      tClZona ON tMsePuntaje.Ubicacion = tClZona.Zona
Where Descripcion Is Null

UPDATE    tMsePuntaje
SET              CodOficina = Cast(Datos.Ubicacion AS Int)
FROM         (SELECT     tMsePuntaje.Ubicacion, tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, Filtro.Ubicacion AS D
                       FROM          (SELECT     tClOficinas.Zona AS Ubicacion, tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, MIN(tMsePuntaje.PT) AS PT
                                               FROM          tMsePuntaje INNER JOIN
                                                                      tClOficinas ON tMsePuntaje.CodOficina = tClOficinas.CodOficina
                                               WHERE      (tMsePuntaje.Fin = @Fecha) AND (tMsePuntaje.Grupo LIKE '%Diario%') AND (tMsePuntaje.Grupo LIKE '%Oficina%')
                                               GROUP BY tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, tClOficinas.Zona) Filtro INNER JOIN
                                              tMsePuntaje ON Filtro.Inicio = tMsePuntaje.Inicio AND Filtro.Fin = tMsePuntaje.Fin AND Filtro.F = tMsePuntaje.F AND 
                                              Filtro.Grupo COLLATE Modern_Spanish_CI_AI = tMsePuntaje.Grupo AND Filtro.PT = tMsePuntaje.PT) Datos INNER JOIN
                      tMsePuntaje ON Datos. D COLLATE Modern_Spanish_CI_AI = tMsePuntaje.Ubicacion AND Datos.Inicio = tMsePuntaje.Inicio AND Datos.Fin = tMsePuntaje.Fin AND 
                      Datos.F = tMsePuntaje.F

UPDATE    tMsePuntaje
SET              CodOficina = Cast(Datos.Ubicacion AS Int)
FROM         (SELECT     tMsePuntaje.Ubicacion, tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, Filtro.Ubicacion AS D
                       FROM          (SELECT     tClOficinas.Zona AS Ubicacion, tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, MIN(tMsePuntaje.PT) AS PT
                                               FROM          tMsePuntaje INNER JOIN
                                                                      tClOficinas ON tMsePuntaje.CodOficina = tClOficinas.CodOficina
                                               WHERE      (tMsePuntaje.Fin = @Fecha) AND (tMsePuntaje.Grupo LIKE '%Mensual%') AND (tMsePuntaje.Grupo LIKE '%Oficina%')
                                               GROUP BY tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, tClOficinas.Zona) Filtro INNER JOIN
                                              tMsePuntaje ON Filtro.Inicio = tMsePuntaje.Inicio AND Filtro.Fin = tMsePuntaje.Fin AND Filtro.F = tMsePuntaje.F AND 
                                              Filtro.Grupo COLLATE Modern_Spanish_CI_AI = tMsePuntaje.Grupo AND Filtro.PT = tMsePuntaje.PT) Datos INNER JOIN
                      tMsePuntaje ON Datos. D COLLATE Modern_Spanish_CI_AI = tMsePuntaje.Ubicacion AND Datos.Inicio = tMsePuntaje.Inicio AND Datos.Fin = tMsePuntaje.Fin AND 
                      Datos.F = tMsePuntaje.F

UPDATE    tMsePuntaje
SET              CodOficina = Cast(Datos.Ubicacion AS Int)
FROM         (SELECT     tMsePuntaje.Ubicacion, tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, Filtro.Ubicacion AS D
                       FROM          (SELECT     tClOficinas.Zona AS Ubicacion, tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, MIN(tMsePuntaje.PT) AS PT
                                               FROM          tMsePuntaje INNER JOIN
                                                                      tClOficinas ON tMsePuntaje.CodOficina = tClOficinas.CodOficina
                                               WHERE      (tMsePuntaje.Fin = @Fecha) AND (tMsePuntaje.Grupo LIKE '%Anual%') AND (tMsePuntaje.Grupo LIKE '%Oficina%')
                                               GROUP BY tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.F, tMsePuntaje.Grupo, tClOficinas.Zona) Filtro INNER JOIN
                                              tMsePuntaje ON Filtro.Inicio = tMsePuntaje.Inicio AND Filtro.Fin = tMsePuntaje.Fin AND Filtro.F = tMsePuntaje.F AND 
                                              Filtro.Grupo COLLATE Modern_Spanish_CI_AI = tMsePuntaje.Grupo AND Filtro.PT = tMsePuntaje.PT) Datos INNER JOIN
                      tMsePuntaje ON Datos. D COLLATE Modern_Spanish_CI_AI = tMsePuntaje.Ubicacion AND Datos.Inicio = tMsePuntaje.Inicio AND Datos.Fin = tMsePuntaje.Fin AND 
                      Datos.F = tMsePuntaje.F

UPDATE    tMsePuntaje
SET              CSC = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Fin = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Saldo Capital', 'Saldo Cartera'))

UPDATE    tMsePuntaje
SET              NSC = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Inicio = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Saldo Capital', 'Saldo Cartera'))


UPDATE    tMsePuntaje
SET              CMV = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Fin = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Mora Vencida'))

UPDATE    tMsePuntaje
SET              NMV = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Inicio = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Mora Vencida'))

UPDATE    tMsePuntaje
SET              CMR = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Fin = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Mora Real'))

UPDATE    tMsePuntaje
SET              NMR = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Inicio = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Mora Real'))

UPDATE    tMsePuntaje
SET              CEP = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Fin = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Estimación Preventiva'))

UPDATE    tMsePuntaje
SET              NEP = ValorAc
FROM         tMsePuntaje INNER JOIN
                          (SELECT     Ubicacion, Fin, Concepto, ValorAc
                            FROM          tMseMensajeDetalle) tMseMensajeDetalle ON tMsePuntaje.Ubicacion = tMseMensajeDetalle.Ubicacion AND 
                      tMsePuntaje.Inicio = tMseMensajeDetalle.Fin
WHERE     (tMsePuntaje.Fin = @Fecha) AND (tMseMensajeDetalle.Concepto IN ('Estimación Preventiva'))

UPDATE    tMsePuntaje
SET              Descripcion = 'Llamar a Sistemas', Grupo = Grupo + ' - Desconocido'
FROM         tMsePuntaje 
Where Descripcion Is Null

DELETE FROM tMsePuntaje
WHERE     (Fin = @Fecha) AND (Grupo LIKE '%ASESOR%') AND (CodOficina NOT IN
                          (SELECT DISTINCT CodOficina
                            FROM          tMsePuntaje
                            WHERE      (Fin = @Fecha) AND (Grupo LIKE '%OFICINA%')))
Print GetDate()

SELECT     	tMsePuntaje.Grupo, Case When CharIndex('Llamar a Sistemas', tMsePuntaje.Descripcion, 1) <> 0 Then tMsePuntaje.Ubicacion + ' : ' Else '' End  + tMsePuntaje.Descripcion AS Identificacion, tMsePuntaje.Inicio, tMsePuntaje.Fin, tMsePuntaje.CodOficina, 
                tClOficinas.NomOficina, tMsePuntaje.F, tMsePuntaje.P1, tMsePuntaje.P2, tMsePuntaje.PT, tMsePuntaje.Visible, NSC, NMV, NMR, NEP, CSC, CMV, CMR, CEP, PSC, PMV, PMR, PEP,
	 	DSC = CSC - NSC, DMV = CMV - NMV, DMR = CMR - NMR, DEP = CEP - NEP
FROM         	tMsePuntaje LEFT OUTER JOIN
                tClOficinas ON tMsePuntaje.CodOficina = tClOficinas.CodOficina
WHERE     	(tMsePuntaje.Fin = @Fecha)
ORDER BY 	tMsePuntaje.Grupo, tMsePuntaje.PT
Print GetDate()




GO