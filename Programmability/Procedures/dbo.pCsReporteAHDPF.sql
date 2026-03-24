SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsReporteAHDPF
CREATE Procedure [dbo].[pCsReporteAHDPF]
@CodCuenta 	Varchar(50),
@Usuario	Varchar(50)
As
--Set @CodCuenta = '007-203-06-2-8-00042-0-0'

--Declare @Usuario 	Varchar(50)
Declare @Sistema	Varchar(2)
Declare @Dato		Varchar(100)
Declare @Firma		Varchar(100) 

--Set @Usuario 	= 'KVALERA'
Set @Sistema 	= 'AH'
Set @Dato 	= Substring(Ltrim(rtrim(@CodCuenta)), 1, 20)

CREATE TABLE #AAAA (
	[F] [int] NOT NULL ,
	[Firma] [varchar] (34) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[NombreCompleto] [varchar] (120) COLLATE Modern_Spanish_CI_AI NULL ,
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NULL ,
	[NomOficina] [varchar] (30) COLLATE Modern_Spanish_CI_AI NULL ,
	[idProducto] [int] NOT NULL ,
	[Producto] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[Cuenta] [varchar] (47) COLLATE Modern_Spanish_CI_AI NULL ,
	[CodCuenta] [varchar] (45) COLLATE Modern_Spanish_CI_AI NULL ,
	[Capital] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[DescMoneda] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[DescTipoInt] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[FechaApertura] [datetime] NULL ,
	[FechaVcmto] [datetime] NULL ,
	[DescManejo] [varchar] (30) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[PlazoDias] [numeric](18, 0) NULL ,
	[DescTPersona] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[TasaAnual] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL,
	[Titulo] [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL,
	[Comentario] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL,
	[DescRenovacion] [varchar] (150) COLLATE Modern_Spanish_CI_AI NULL,	 
) 

Exec pCsFirmaElectronica @Usuario, @Sistema, @Dato, @Firma Out

Insert Into #AAAA ( F, Firma, NombreCompleto, CodOficina, NomOficina, idProducto, Producto, Cuenta, CodCuenta, Capital, DescMoneda, DescTipoInt, FechaApertura, FechaVcmto, DescManejo,
		     PlazoDias, DescTPersona, TasaAnual, DescRenovacion) 
SELECT  F = 1,  @Firma AS Firma, *
FROM         [BD-FINAMIGO-DC].Finmas.dbo.vAhCuentasAhorros vAhCuentasAhorros_1
WHERE     (CodCuenta = @CodCuenta)

Insert Into #AAAA ( F, Firma, NombreCompleto, CodOficina, NomOficina, idProducto, Producto, Cuenta, CodCuenta, Capital, DescMoneda, DescTipoInt, FechaApertura, FechaVcmto, DescManejo,
		     PlazoDias, DescTPersona, TasaAnual, DescRenovacion)
SELECT  F = 2,  @Firma AS Firma, *
FROM         [BD-FINAMIGO-DC].Finmas.dbo.vAhCuentasAhorros vAhCuentasAhorros_1
WHERE     (CodCuenta = @CodCuenta)

UPDATE   #AAAA
SET              Titulo = rtitulo, Comentario = rcomentario
FROM         #AAAA INNER JOIN
                      tAhProductos ON #AAAA.idProducto = tAhProductos.idProducto

Select * from #AAAA

Drop Table #AAAA
GO