CREATE TABLE [dbo].[TblrecDireccionCP] (
  [Representa] [varchar](19) NOT NULL,
  [Fila] [int] IDENTITY,
  [CodUsuario] [varchar](25) NOT NULL,
  [Direccion1] [varchar](40) NULL,
  [Direccion2] [varchar](8000) NULL,
  [x] [varchar](8000) NULL,
  [Colonia] [varchar](60) NOT NULL,
  [Municipio] [varchar](60) NOT NULL,
  [Ciudad] [varchar](150) NOT NULL,
  [Estado] [varchar](4) NULL,
  [CodigoPostal] [varchar](10) NULL,
  [FechaResidencia] [varchar](1) NOT NULL,
  [Telefono] [varchar](1) NOT NULL,
  [Extencion] [varchar](1) NOT NULL,
  [Fax] [varchar](1) NOT NULL,
  [Tipo] [varchar](1) NOT NULL,
  [Indicador] [varchar](1) NOT NULL,
  [CodUbigeo] [varchar](6) NULL,
  [OrigenDomicilio] [varchar](2) NOT NULL
)
ON [PRIMARY]
GO