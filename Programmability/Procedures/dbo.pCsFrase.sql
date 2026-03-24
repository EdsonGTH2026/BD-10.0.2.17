SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsFrase] 
@Frase Varchar(4000) OUTPUT
As
Declare @Top		Int
Declare @Cadena	Varchar(1000)
Declare @Contador	Int

Update tCsFrase
Set Aleatorio = 0 
Where Aleatorio <> 1 or Aleatorio Is Null

SELECT   @Top = CAST(SUBSTRING(LTRIM(STR(RAND({ fn SECOND(GETDATE()) }), 20, 15)), 15, 3) AS int) * 100 / 999 
FROM     tCsFrase
WHERE     (Aleatorio = 0)

Select @Contador = Count(*)
FROM     tCsFrase
WHERE     (Aleatorio = 0)

If @Contador = 0
Begin
Update tCsFrase Set Aleatorio = 0
End

Set @Cadena = 'UPDATE tCsFrase Set Aleatorio = 2, Fecha = '''+ dbo.fduFechaATexto(GetDate(), 'AAAAMMDD') +''' Where Secuencial in (Select Max(Secuencial) as Secuencial from (Select Top ' + cast(@Top as Varchar(5)) + ' PERCENT * FROM tCsFrase Where Aleatorio = 0 ORDER BY SECUENCIAL) Datos)'

Exec (@Cadena)

Select @Frase =  CAST(Frase AS varchar(4000))  + Char(13) + 'Autor: ' + Autor 
From tCsFrase Where Aleatorio = 2

Update 	tCsFrase 
Set 	Aleatorio = 1 , 
	Veces 	 =  Isnull(Veces, 0) + 1
Where 	Aleatorio = 2

Print @Top
Print @Frase
GO