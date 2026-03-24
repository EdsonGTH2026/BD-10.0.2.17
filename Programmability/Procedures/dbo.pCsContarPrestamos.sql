SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsContarPrestamos]
@Fecha 		SmallDateTime,
@Formato 	Varchar(6),
@Indicador	Int,
@Cartera	Varchar(50),
@Valor Decimal(18,4) OUTPUT

AS
--set  @Fecha = '20090228'
--Set @Formato 	= 'AAAA' 
--Set @Indicador  = 1

Create Table #Saldo (Valor [decimal](18,4) null)


If @Indicador = 1 --Numero de Prestamos
Begin
	If Rtrim(Ltrim(@formato)) <> ''
	Begin
		Insert Into #Saldo
		SELECT     COUNT(CodPrestamo) AS Expr1
				FROM         (SELECT     tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Desembolso, SUM(tCsCarteraDet.MontoDesembolso) AS Monto
		FROM         tCsPadronCarteraDet INNER JOIN
		                      tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
		                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
		WHERE     (tCsPadronCarteraDet.CarteraOrigen = @Cartera)
		GROUP BY tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Desembolso) Datos
				WHERE     (dbo.fduFechaATexto(Desembolso, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) and Desembolso <= @Fecha
	End
	If Rtrim(Ltrim(@formato)) = ''
	Begin
		Insert Into #Saldo
		SELECT     COUNT(CodPrestamo) AS Expr1
				FROM         (SELECT     tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Desembolso, SUM(tCsCarteraDet.MontoDesembolso) AS Monto
		FROM         tCsPadronCarteraDet INNER JOIN
		                      tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
		                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
		WHERE     (tCsPadronCarteraDet.CarteraOrigen = @Cartera)
				GROUP BY tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Desembolso) Datos
				WHERE     Desembolso <= @Fecha
	End 
End
If @Indicador = 2 --Monto Desembolso
Begin
	Insert Into #Saldo
	SELECT     Sum(Monto) AS Expr1
	FROM         (SELECT     tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Desembolso, SUM(tCsCarteraDet.MontoDesembolso) AS Monto
	FROM         tCsPadronCarteraDet INNER JOIN
	                      tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
	                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
	WHERE     (tCsPadronCarteraDet.CarteraOrigen = @Cartera)
	GROUP BY tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Desembolso) Datos
	WHERE     (dbo.fduFechaATexto(Desembolso, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato))  and Desembolso <= @Fecha
End

If @Indicador = 3 --Numero de Registros
Begin
	If Rtrim(Ltrim(@formato)) <> ''
	Begin
		Insert Into #Saldo
		SELECT     COUNT(*) AS Expr1
			FROM         (SELECT     tCsPadronCarteraDet.CodPrestamo + tCsPadronCarteraDet.Codusuario as CodPrestamo, tCsPadronCarteraDet.Desembolso, SUM(tCsCarteraDet.MontoDesembolso) AS Monto
		FROM         tCsPadronCarteraDet INNER JOIN
		                      tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
		                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
		WHERE     (tCsPadronCarteraDet.CarteraOrigen = @Cartera)
						GROUP BY tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Codusuario, tCsPadronCarteraDet.Desembolso) Datos
				WHERE     (dbo.fduFechaATexto(Desembolso, @Formato) = dbo.fduFechaATexto(@Fecha, @Formato)) and Desembolso <= @Fecha
	End
	If Rtrim(Ltrim(@formato)) = ''
	Begin
		Insert Into #Saldo
		SELECT     COUNT(*) AS Expr1
			FROM         (SELECT     tCsPadronCarteraDet.CodPrestamo + tCsPadronCarteraDet.Codusuario as CodPrestamo, tCsPadronCarteraDet.Desembolso, SUM(tCsCarteraDet.MontoDesembolso) AS Monto
		FROM         tCsPadronCarteraDet INNER JOIN
		                      tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
		                      tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha 
		WHERE     (tCsPadronCarteraDet.CarteraOrigen = @Cartera)
						GROUP BY tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Codusuario, tCsPadronCarteraDet.Desembolso) Datos
				WHERE     Desembolso <= @Fecha
	End 
End

Set @Valor = 0
Select @Valor = Isnull(Valor,0) From #Saldo

Print @Valor

Drop Table #Saldo
GO