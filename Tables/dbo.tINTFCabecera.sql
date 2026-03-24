CREATE TABLE [dbo].[tINTFCabecera] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](150) NOT NULL,
  [Usados] [int] NULL,
  [EtiquetaSegmento] [varchar](4) NOT NULL,
  [Version] [int] NOT NULL,
  [ClaveUsuario] [varchar](10) NOT NULL,
  [NombreUsuario] [varchar](16) NOT NULL,
  [NumeroCiclo] [varchar](2) NOT NULL,
  [FechaReporte] [int] NOT NULL,
  [UsoFuturo] [int] NOT NULL,
  [InformacionAdicional] [varchar](98) NOT NULL
)
ON [PRIMARY]
GO