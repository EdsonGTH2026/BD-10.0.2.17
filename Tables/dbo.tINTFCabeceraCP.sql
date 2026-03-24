CREATE TABLE [dbo].[tINTFCabeceraCP] (
  [Periodo] [varchar](8) NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](150) NOT NULL,
  [Usados] [int] NULL,
  [EtiquetaSegmento] [varchar](4) NOT NULL,
  [Version] [int] NOT NULL,
  [ClaveUsuario] [varchar](10) NOT NULL,
  [NombreUsuario] [varchar](16) NOT NULL,
  [NumeroCiclo] [varchar](2) NULL,
  [FechaReporte] [int] NOT NULL,
  [UsoFuturo] [int] NULL,
  [InformacionAdicional] [varchar](98) NOT NULL,
  [Reservado] [varchar](2) NULL,
  [Reservado2] [varchar](50) NULL
)
ON [PRIMARY]
GO