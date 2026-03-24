CREATE TABLE [dbo].[Aval] (
  [Sistema] [varchar](2) NOT NULL,
  [NombreCompleto] [varchar](120) NULL,
  [Sexo] [bit] NOT NULL,
  [CodTPersona] [varchar](2) NOT NULL,
  [CodEstadoCivil] [char](1) NULL,
  [LabActividad] [varchar](50) NULL,
  [UsOcupacion] [varchar](30) NULL,
  [CodDocIden] [varchar](5) NOT NULL,
  [DI] [varchar](20) NULL,
  [CodUbiGeo] [varchar](6) NOT NULL,
  [Direccion] [varchar](150) NOT NULL,
  [NumExterno] [varchar](10) NULL,
  [NumInterno] [varchar](10) NULL,
  [CodPostal] [varchar](10) NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodPais] [varchar](4) NULL,
  [CodCuenta] [varchar](40) NULL,
  [MoAFavor] [money] NOT NULL,
  [CodMOneda] [varchar](2) NULL
)
ON [PRIMARY]
GO