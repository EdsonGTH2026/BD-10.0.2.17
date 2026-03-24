CREATE TABLE [dbo].[tINTFDireccionCP] (
  [Periodo] [varchar](8) NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](269) NOT NULL,
  [Usados] [int] NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [Direccion1] [varchar](44) NOT NULL,
  [Direccion2] [varchar](44) NOT NULL,
  [Colonia] [varchar](44) NOT NULL,
  [Municipio] [varchar](44) NOT NULL,
  [Ciudad] [varchar](44) NOT NULL,
  [Estado] [varchar](8) NOT NULL,
  [CodigoPostal] [varchar](14) NOT NULL,
  [FechaResidencia] [varchar](12) NOT NULL,
  [Telefono] [varchar](15) NOT NULL,
  [Extencion] [varchar](12) NOT NULL,
  [Fax] [varchar](15) NOT NULL,
  [TipoDomicilio] [varchar](5) NOT NULL,
  [Indicador] [varchar](5) NOT NULL,
  [OrigenDomicilio] [varchar](10) NOT NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_Periodo_CodUsuario_2]
  ON [dbo].[tINTFDireccionCP] ([Periodo], [CodUsuario])
  INCLUDE ([Fila], [Cadena], [Estado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_Periodo_Estado]
  ON [dbo].[tINTFDireccionCP] ([Periodo], [Estado])
  INCLUDE ([Fila], [Cadena], [CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_Periodo_Estado_Fila]
  ON [dbo].[tINTFDireccionCP] ([Periodo], [Estado])
  INCLUDE ([Fila], [Cadena], [CodUsuario])
  ON [PRIMARY]
GO