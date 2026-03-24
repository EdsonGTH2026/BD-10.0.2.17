SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsCboAHCA
--Exec pCsCboAHCA '70'
CREATE Procedure [dbo].[pCsCboAHCA]
@CodOficina Varchar(4)
As
--Declare @CodOficina Varchar(4)
--Set @CodOficina = '10' 

Declare @Contador Int

CREATE TABLE #vAhDiaAperturas (
	[Sistema] [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodUsCuenta] [varchar] (15) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodCuenta] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NULL ,
	[idManejo] [smallint] NULL ,
	[NombreCompleto] [varchar] (120) COLLATE Modern_Spanish_CI_AI NULL ,
	[idTipoProd] [smallint] NULL,
	[FechaApertura] [SmallDateTime] NULL 
) ON [PRIMARY]

CREATE TABLE #vCaDiaAperturas (
	[Sistema] [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodUsuario] [char] (15) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[NombreCompleto] [varchar] (120) COLLATE Modern_Spanish_CI_AI NULL,
	[FechaDesembolso] [SmallDateTime] NULL 
) ON [PRIMARY]

CREATE TABLE #vAhDiaCancelaciones (
	[Sistema] [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodUsCuenta] [varchar] (15) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodCuenta] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NULL ,
	[idManejo] [smallint] NULL ,
	[NombreCompleto] [varchar] (120) COLLATE Modern_Spanish_CI_AI NULL ,
	[idTipoProd] [smallint] NULL,
	[FechaApertura] [SmallDateTime] NULL  
) ON [PRIMARY]

CREATE TABLE #vCaDiaCancelaciones (
	[Sistema] [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodUsuario] [char] (15) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[NombreCompleto] [varchar] (120) COLLATE Modern_Spanish_CI_AI NULL,
	[FechaDesembolso] [SmallDateTime] NULL  
) ON [PRIMARY]

Insert Into #vAhDiaAperturas
Select * 
from [BD-FINAMIGO-DC].Finmas.dbo.vAhDiaAperturas
Where CodOficina = @CodOficina

Insert Into #vCaDiaAperturas
Select * 
from [BD-FINAMIGO-DC].Finmas.dbo.vCaDiaAperturas
Where CodOficina = @CodOficina

Insert Into #vAhDiaCancelaciones
Select * 
from [BD-FINAMIGO-DC].Finmas.dbo.vAhDiaCancelaciones
Where CodOficina = @CodOficina

Insert Into #vCaDiaCancelaciones
Select  Sistema, CodUsuario, CodPrestamo, CodOficina, NombreCompleto, FechaDesembolso
from [BD-FINAMIGO-DC].Finmas.dbo.vCaDiaCancelaciones
Where CodOficina = @CodOficina

Set @Contador = 0

SELECT   @Contador = COUNT(*) 
FROM         (SELECT     *
                       FROM          tCsCboAH
                       WHERE      CodOficina = @CodOficina) tCsCboAH RIGHT OUTER JOIN
                        (SELECT * FROM #vAhDiaAperturas
			 UNION
			 SELECT * FROM #vAhDiaCancelaciones) vAHDiaAperturas ON tCsCboAH.Sistema = vAHDiaAperturas.Sistema COLLATE Modern_Spanish_CI_AI AND 
                      tCsCboAH.CodUsCuenta = vAHDiaAperturas.CodUsCuenta COLLATE Modern_Spanish_CI_AI AND 
                      tCsCboAH.CodCuenta = vAHDiaAperturas.CodCuenta COLLATE Modern_Spanish_CI_AI AND 
                      tCsCboAH.CodOficina = vAHDiaAperturas.CodOficina COLLATE Modern_Spanish_CI_AI AND tCsCboAH.idManejo = vAHDiaAperturas.idManejo AND 
                      tCsCboAH.NombreCompleto = vAHDiaAperturas.NombreCompleto COLLATE Modern_Spanish_CI_AI AND tCsCboAH.idTipoProd = vAHDiaAperturas.idTipoProd
WHERE     (tCsCboAH.Sistema IS NULL)

IF @Contador Is null Begin Set @Contador = 0 End

SELECT  @Contador = COUNT(*) + @Contador
FROM         (SELECT     *
                       FROM          tCsCboCA
                       WHERE      CodOficina = @CodOficina) tCsCboCA RIGHT OUTER JOIN
                         (SELECT * FROM #vCaDiaAperturas
			 UNION
			 SELECT * FROM #vCaDiaCancelaciones) vCADiaAperturas ON tCsCboCA.Sistema = vCADiaAperturas.Sistema AND tCsCboCA.CodUsuario = vCADiaAperturas.CodUsuario AND 
                      tCsCboCA.CodOficina = vCADiaAperturas.CodOficina AND tCsCboCA.CodPrestamo = vCADiaAperturas.CodPrestamo AND 
                      tCsCboCA.NombreCompleto = vCADiaAperturas.NombreCompleto
WHERE     (tCsCboCA.Sistema IS NULL)

IF @Contador Is null Begin Set @Contador = 0 End

If (SELECT COUNT(*) FROM tCsCboAHCA WHERE (CodOficina = @CodOficina)) = 0
Begin
	Set @Contador = 100
End

IF @Contador > 0
Begin
	Print 'Se encontro movimiento en la agencia '+ @Codoficina + ' Contador: ' + Cast(@Contador as Varchar(50))
	
	DELETE FROM tCsCboAHCA Where CodOficina = @CodOficina
	DELETE FROM tCsCboAH Where CodOficina = @CodOficina
	DELETE FROM tCsCboCA Where CodOficina = @CodOficina	

	Insert Into tCsCboAH
	Select * from (SELECT * FROM #vAhDiaAperturas
			 UNION
			 SELECT * FROM #vAhDiaCancelaciones) AH

	Insert Into tCsCboCA
	Select * from (SELECT * FROM #vCaDiaAperturas
			 UNION
			 SELECT * FROM #vCaDiaCancelaciones) CA
	
	
	Insert Into tCsCboAHCA
	SELECT CodOficina = @CodOficina, Ahorros.CodOrigen, Ahorros.CodCuenta, Creditos.CodPrestamo, Ahorros.FormaManejo, Creditos.NombreCompleto, FechaApertura, FechaDesembolso
	FROM            (SELECT        Sistema, CodOrigen, CodCuenta, CodOficina, FormaManejo, NombreCompleto, idTipoProd, FechaApertura
	                          FROM            (SELECT DISTINCT 
	                                                                              'AH' AS Sistema, tCsPadronClientes.CodOrigen, tCsClientesAhorrosFecha.CodCuenta, tCsClientesAhorrosFecha.CodOficina, 
	                                                                              tCsAhorros.FormaManejo, tCsPadronClientes.NombreCompleto, tAhProductos.idTipoProd, FechaApertura
	                                                    FROM            tCsClientesAhorrosFecha with(nolock) INNER JOIN
	                                                                              vCsFechaConsolidacion ON tCsClientesAhorrosFecha.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN
	                                                                              tCsAhorros with(nolock) ON tCsClientesAhorrosFecha.CodCuenta = tCsAhorros.CodCuenta AND tCsClientesAhorrosFecha.Fecha = tCsAhorros.Fecha AND 
	                                                                              tCsClientesAhorrosFecha.FraccionCta = tCsAhorros.FraccionCta AND tCsClientesAhorrosFecha.Renovado = tCsAhorros.Renovado INNER JOIN
	                                                                              tAhProductos ON tCsAhorros.CodProducto = tAhProductos.idProducto INNER JOIN
	                                                                              tCsPadronClientes with(nolock) ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronClientes.CodUsuario
	                                                    WHERE        (tCsClientesAhorrosFecha.CodOficina = @CodOficina) AND (tAhProductos.idTipoProd = 1)
	                                                    UNION
	                                                    SELECT        Sistema, CodUsCuenta, CodCuenta, CodOficina, idManejo, NombreCompleto, idTipoProd, FechaApertura
	                                                    FROM          #vAhDiaAperturas
	                                                    WHERE        (CodOficina = @CodOficina) AND (idTipoProd = 1)) AS Datos
	                          WHERE        (CodCuenta NOT IN
	                                                        (SELECT        CodCuenta
	                                                          FROM           #vAhDiaCancelaciones
	                                                          WHERE        (CodOficina = @CodOficina) AND (idTipoProd = 1)
					     --UNION Select Cuenta From tCsFirmaDocumentos Where CodSistema = 'AH' And CodOficina = @CodOficina And Tipo = 'Adendum Ahorros'	
						))) AS Ahorros INNER JOIN
	                             (SELECT        Sistema, CodOrigen, CodPrestamo, CodOficina, NombreCompleto, FechaDesembolso
	                               FROM            (SELECT DISTINCT 
	                                                                                   'CA' AS Sistema, tCsPadronClientes_1.CodOrigen, tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.CodOficina, 
	                                                                                   tCsPadronClientes_1.NombreCompleto, Desembolso as FechaDesembolso
	                                                         FROM            tCsPadronCarteraDet with(nolock) INNER JOIN
	                                                                                   vCsFechaConsolidacion AS vCsFechaConsolidacion_1 ON 
	                                                                                   tCsPadronCarteraDet.FechaCorte = vCsFechaConsolidacion_1.FechaConsolidacion INNER JOIN
	                                                                                   tCsPadronClientes  AS tCsPadronClientes_1 with(nolock) ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes_1.CodUsuario
	                                                         WHERE        (tCsPadronCarteraDet.EstadoCalculado NOT IN ('CANCELADO')) AND (tCsPadronCarteraDet.CodOficina IN (SELECT DISTINCT tCsPadronCarteraDet.CodOficina
FROM            tCsClientesAhorrosFecha with(nolock) INNER JOIN
                         vCsFechaConsolidacion ON tCsClientesAhorrosFecha.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN
                         tCsPadronCarteraDet with(nolock) ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronCarteraDet.CodUsuario
WHERE        (tCsClientesAhorrosFecha.CodOficina = @CodOficina)) Or tCsPadronCarteraDet.CodOficina in (@CodOficina))
	                                                         UNION
	                                                         SELECT        Sistema, CodUsuario, CodPrestamo, CodOficina, NombreCompleto, FechaDesembolso
	                                                         FROM          #vCaDiaAperturas
	                                                         WHERE        (CodOficina = @CodOficina)) AS Datos_1
	                               WHERE        (CodPrestamo NOT IN
	                                                             (SELECT        CodPrestamo
	                                                               FROM            #vCaDiaCancelaciones
	                                                               WHERE        (CodOficina = @CodOficina)))) AS Creditos ON Ahorros.CodOrigen = Creditos.CodOrigen
End

Delete From tCsCboAHCA Where Left(CodPrestamo, 3) = '000'
--Select * from tCsCboAHCA Where CodOficina = @CodOficina

Drop Table #vAhDiaAperturas
Drop Table #vCaDiaAperturas
Drop Table #vAhDiaCancelaciones
Drop Table #vCaDiaCancelaciones
GO