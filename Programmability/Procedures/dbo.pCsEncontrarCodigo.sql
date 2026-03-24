SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Exec pCsEncontrarCodigo '18L-C2509531'
--MHP0606801

CREATE Procedure [dbo].[pCsEncontrarCodigo]

 @Parametro Varchar(30)
As

--Set @Parametro = 'BRF0405451'

--Select * From tCsPadronClientesTipo	Where referencia			= '027-156-06-05-00013' ORDER BY FECHA
--Select * From tCsPadronClientesTipo	Where CodUsuario			= 'MGJ0604671'
--Select * From tCsPadronClientesTipo	Where NombreCompleto		= 'CRUZ RODRIGUEZ JUANA'
--Select * from tCspadronCarteraDet		Where CodUsuario			= 'RCI2206761'
--Select * from tCspadronCarteraDet		Where CodPrestamo			= '027-156-06-05-00013'
--Select * from tCspadronAhorros		Where CodUsuario			= 'STO0101841'
--Select * from tCsPadronClientes		Where CodUsuario			= 'CRJ1309571'
--Select * from tCsPadronClientes		Where NombreCompleto		= 'CRUZ RODRIGUEZ JUANA'

/*

Declare @CodAnterior	Varchar(20)
Declare @CodNuevo		Varchar(20)

Set @CodAnterior	= 'CRJ1309571'
Set @CodNuevo		= 'CRJ1409571'

UPdate tCsPadronCarteraDet		Set CodUsuario	= @CodNuevo	Where CodUsuario	= @CodAnterior
UPdate tCsCarteraDet			Set CodUsuario	= @CodNuevo	Where CodUsuario	= @CodAnterior 
UPdate tCsPadronAhorros			Set CodUsuario	= @CodNuevo	Where CodUsuario	= @CodAnterior 
UPdate tCsClientesAhorrosFecha	Set CodUsCuenta = @CodNuevo	Where CodUsCuenta	= @CodAnterior 
UPdate tCsPadronClientesTipo	Set CodUsuario	= @CodNuevo	Where CodUsuario	= @CodAnterior
UPdate tCsCartera				Set CodUsuario	= @CodNuevo	Where CodUsuario	= @CodAnterior
UPdate tCsCartera				Set CodAsesor	= @CodNuevo	Where CodAsesor		= @CodAnterior

*/


Set @Parametro = Ltrim(Rtrim(@Parametro))

Declare @CodOficina		Varchar(4)
Declare @L1				Varchar(1)
Declare @L2				Varchar(1)
Declare @L3				Varchar(1)

Set @CodOficina = ''

If Len(@Parametro) = 11
Begin
		Set @CodOficina = Left(@Parametro, 1)
End 

If Len(@Parametro) = 12
Begin
		Set @CodOficina = Left(@Parametro, 2)	
End 
Set @Parametro	= Right(@Parametro, 10) 

Set @L1			= SubString(@Parametro, 1, 1)
Set @L2			= SubString(@Parametro, 2, 1)
Set @L3			= SubString(@Parametro, 3, 1)

SELECT        Datos.CodUsuario, Datos.Puntaje, tCsPadronClientes_2.CodOrigen, tCsPadronClientes_2.CodOficina, tCsPadronClientes_2.NombreCompleto
FROM            (SELECT        CodUsuario, Oficina + Iniciales + Nacimiento + NombreC + Dia + Mes + Año +  PP + SP + MP + EP AS Puntaje
                          FROM            (SELECT        @Parametro AS Parametro, CodUsuario, CASE WHEN CodOficina = @CodOficina THEN 3 ELSE 0 END AS Oficina, 
                                                                              CASE	WHEN @L1 + @L2 + @L3 = LEFT(CodUsuario, 3) THEN 6 
																					WHEN 
																						Case @L1 When '-' Then 'X' Else @L1 End + 
																						Case @L2 When '-' Then 'X' Else @L2 End + 
																						Case @L3 When '-' Then 'X' Else @L3 End  
																						 = LEFT(CodUsuario, 3) THEN 6 
																					ELSE 0 
                                                                              END AS Iniciales, CASE WHEN dbo.fduFechaAtexto(FechaNacimiento,
                                                                               'DDMMAA') = LEFT(RIGHT(@Parametro, 7), 6) THEN 3 ELSE 0 END AS Nacimiento, CASE WHEN NombreCompleto LIKE '%' + @L1 + '%' AND 
                                                                              NombreCompleto LIKE '%' + @L2 + '%' AND NombreCompleto LIKE '%' + @L3 + '%' THEN 1 ELSE 0 END AS NombreC, 
                                                                              CASE WHEN dbo.fduFechaAtexto(FechaNacimiento, 'DD') = Substring(RIGHT(@Parametro, 7), 1, 2) THEN 1 ELSE 0 END AS Dia, 
                                                                              CASE WHEN dbo.fduFechaAtexto(FechaNacimiento, 'MM') = Substring(RIGHT(@Parametro, 7), 3, 2) THEN 1 ELSE 0 END AS Mes, 
                                                                              CASE WHEN dbo.fduFechaAtexto(FechaNacimiento, 'AA') = Substring(RIGHT(@Parametro, 7), 5, 2) THEN 1 ELSE 0 END AS Año,
                                                                                                             PP = Case When left(@Parametro, 5)		= Left(ltrim(rtrim(Codusuario)), 5) Then 1 Else 0 End,
                                                                                                             SP = Case When Right(@Parametro, 5)	= Right(ltrim(rtrim(Codusuario)), 5) Then 1 Else 0 End,
                                                                                                             MP = Case When Left(Right(@Parametro, 8), 6)	= Left(Right(ltrim(rtrim(Codusuario)), 8), 6) Then 1 Else 0 End,
                                                                                                             EP = Case When left(@Parametro, 3) + Right(@Parametro, 3) = Left(ltrim(rtrim(Codusuario)), 3) + Right(ltrim(rtrim(Codusuario)), 3) Then 1 Else 0 End

                                                    FROM            tCsPadronClientes) AS Datos_3) AS Datos INNER JOIN
                         tCsPadronClientes AS tCsPadronClientes_2 ON Datos.CodUsuario = tCsPadronClientes_2.CodUsuario
WHERE        (Datos.Puntaje IN
                             (SELECT        MAX(Puntaje) AS Expr1
                               FROM            (SELECT        CodUsuario, Oficina + Iniciales + Nacimiento + NombreC + Dia + Mes + Año +  PP + SP + MP + EP AS Puntaje
                                                         FROM            (SELECT        @Parametro AS Parametro, CodUsuario, CASE WHEN CodOficina = @CodOficina THEN 3 ELSE 0 END AS Oficina, 
                                                                                                             CASE	WHEN @L1 + @L2 + @L3 = LEFT(CodUsuario, 3) THEN 6 
																													WHEN 
																														Case @L1 When '-' Then 'X' Else @L1 End + 
																														Case @L2 When '-' Then 'X' Else @L2 End + 
																														Case @L3 When '-' Then 'X' Else @L3 End  
																														 = LEFT(CodUsuario, 3) THEN 6 
																													ELSE 0 
																											  END AS Iniciales, 
                                                                                                             CASE WHEN dbo.fduFechaAtexto(FechaNacimiento, 'DDMMAA') = LEFT(RIGHT(@Parametro, 7), 6) 
                                                                                                             THEN 3 ELSE 0 END AS Nacimiento, CASE WHEN NombreCompleto LIKE '%' + @L1 + '%' AND 
                                                                                                             NombreCompleto LIKE '%' + @L2 + '%' AND NombreCompleto LIKE '%' + @L3 + '%' THEN 1 ELSE 0 END AS NombreC, 
                                                                                                             CASE WHEN dbo.fduFechaAtexto(FechaNacimiento, 'DD') = Substring(RIGHT(@Parametro, 7), 1, 2) THEN 1 ELSE 0 END AS Dia,
                                                                                                              CASE WHEN dbo.fduFechaAtexto(FechaNacimiento, 'MM') = Substring(RIGHT(@Parametro, 7), 3, 2) 
                                                                                                             THEN 1 ELSE 0 END AS Mes, CASE WHEN dbo.fduFechaAtexto(FechaNacimiento, 'AA') = Substring(RIGHT(@Parametro, 7), 5, 
                                                                                                             2) THEN 1 ELSE 0 END AS Año,
                                                                                                             PP = Case When left(@Parametro, 5)		= Left(ltrim(rtrim(Codusuario)), 5) Then 1 Else 0 End,
                                                                                                             SP = Case When Right(@Parametro, 5)	= Right(ltrim(rtrim(Codusuario)), 5) Then 1 Else 0 End,
                                                                                                             MP = Case When Left(Right(@Parametro, 8), 6)	= Left(Right(ltrim(rtrim(Codusuario)), 8), 6) Then 1 Else 0 End,
                                                                                                             EP = Case When left(@Parametro, 3) + Right(@Parametro, 3) = Left(ltrim(rtrim(Codusuario)), 3) + Right(ltrim(rtrim(Codusuario)), 3) Then 1 Else 0 End
                                                                                   FROM            tCsPadronClientes AS tCsPadronClientes_1) AS Datos_1) AS Datos_2))
                                                                                   
GO