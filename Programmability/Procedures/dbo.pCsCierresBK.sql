SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*

Exec pCsCierresBK 1, '20110920', '001'
Exec pCsCierresBK 1, '20110920', '002'
Exec pCsCierresBK 1, '20110920', '003'

*/

CREATE Procedure [dbo].[pCsCierresBK]
(
	@Dato	Int,			-- 1: Mensaje de Espacio disponible.
	@Fecha	SmallDateTime,	
	@Config Varchar(3)		-- Depende de la Tabla tCsCierresConfig.
)
As
Declare @Resultado	Varchar(100)	
Declare @Cadena		Varchar(8000)
Declare @Tamaño		Decimal(10,4)
Declare @Libres		Decimal(10,4)
Declare @Servidor	Varchar(50)
Declare @Ruta		Varchar(50)
Declare @Proceso	Varchar(100)
Declare @NB			Int

Truncate Table B

SELECT @Cadena =  'Insert Into B Exec '+ Case When Servidor = '10.0.1.13' Then '' Else '['+ Servidor +']' End +'.master.dbo.XP_CMDSHELL ''DIR "'+ Valor +'"'''
FROM         tCsCierresConfig
WHERE     (Codigo = @Config) AND (Activo = 1)

--Exec master.dbo.XP_CMDSHELL 'DIR "\\10.0.1.5\CONSOLIDADO\"'

Print @Cadena
EXEC (@Cadena)

Select	@Servidor	=	Servidor,
		@Ruta		=	Valor,
		@Proceso	=	Nombre,
		@NB			=	Veces
FROM	tCsCierresConfig
WHERE	(Codigo = @Config) AND (Activo = 1) 

Select @Tamaño = Round((((AVG(T)* @NB)/1024.0000)/1024.0000)/1024.0000, 2)  from (
SELECT     A.Archivo, A.T +  B.T AS T
FROM         (SELECT     T, E, LEFT(Archivo, LEN(Archivo) - 4) AS Archivo, Cadena
					   FROM    (SELECT        Cast(replace(Replace(ltrim(rtrim(Substring (Cadena , Charindex('   ', Cadena, 1), 18))), '.', ''), ',', '') as decimal(30,0)) AS T, RIGHT(Cadena, 3) AS E, Ltrim(Rtrim(Substring (Cadena , Charindex('   ', Cadena, 1)+  18, 100))) AS Archivo, Cadena
											   FROM          B AS B_2) AS A_2
					   WHERE      (E = 'rar')) AS A INNER JOIN
						  (SELECT     T, E, LEFT(Archivo, LEN(Archivo) - 4) AS Archivo, Cadena
							FROM          (SELECT    Cast(replace(Replace(ltrim(rtrim(Substring (Cadena , Charindex('   ', Cadena, 1), 18))), '.', ''), ',', '') as decimal(30,0)) AS T, RIGHT(Cadena, 3) AS E, Ltrim(Rtrim(Substring (Cadena , Charindex('   ', Cadena, 1)+  18, 100))) AS Archivo, Cadena
													FROM          B AS B_1) AS A_1
							WHERE      (E = 'bak')) AS B ON A.Archivo = B.Archivo) Datos 
 
Set @Tamaño = Isnull(@Tamaño, 0)

Print @Tamaño
Print 'Actualiza Dato Historico'

Update	tCsCierresConfig
Set		DatoHistorico = @Tamaño
Where Isnull(DatoHistorico,0) < @Tamaño And (Codigo = @Config) AND (Activo = 1)

Select	@Tamaño		=	Round(Cast(DatoHistorico as decimal(10,4)) * (15/100.0000 + 1), 0)
FROM	tCsCierresConfig
WHERE	(Codigo = @Config) AND (Activo = 1) 

Select @Libres = (T/1073741824.0000) 
From (Select CAST(Replace(REPLACE(SUBSTRING(Cadena, 22, 17), '.', ''), ',', '') AS decimal(30, 0)) AS T, Cadena
FROM         B
Where RIGHT(Cadena, 6) = 'Libres') Datos
    
	
Set @Cadena =			'[Libres: '+ Ltrim(rtrim(str(@Libres, 10,2))) +' GB. **** Se solicita: '+ Ltrim(rtrim(str(@Tamaño, 10,2))) +' GB.]'
Set @Cadena	= @Cadena + '[Servidor: '+ Ltrim(rtrim(@Servidor)) +' **** Ruta: '+ Ltrim(rtrim(@Ruta)) +']'

If @Tamaño >= @Libres
Begin
	Set @Cadena = 'Espacio No Disponible: para '+ @Proceso +' ' + @Cadena
End
Else
Begin
	Set @Cadena = 'Espacio Disponible: para '+ @Proceso +' ' + @Cadena
End		

If @Dato = 1
Begin
	Delete From tCsCierresMensajes
	Where Fecha = @Fecha And CodOficina = @Config
	
	Insert Into tCsCierresMensajes	(Fecha,		CodOficina, Mensaje) 
	Values							(@Fecha,	@Config,	Isnull(@Cadena, ''))	
End
	
GO