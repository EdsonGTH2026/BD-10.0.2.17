CREATE TABLE [dbo].[tCaProdMontoPlazo] (
  [CodProducto] [char](3) NOT NULL,
  [Rangos] [bit] NULL CONSTRAINT [DF_tCaProdMontoPlazo_Rangos] DEFAULT (0),
  [EducativoMontos] [bit] NULL CONSTRAINT [DF_tCaProdMontoPlazo_EducativoMontos] DEFAULT (0),
  [EducativoPorc] [bit] NULL CONSTRAINT [DF_tCaProdMontoPlazo_EducativoPorc] DEFAULT (0),
  [CodMoneda] [varchar](2) NULL,
  [RangoMinimo] [money] NULL,
  [RangoMaximo] [money] NULL,
  [PlazoMin] [int] NULL,
  [Plazo] [int] NULL CONSTRAINT [DF_tCaProdMontoPlazo_Plazo] DEFAULT (0),
  [CicloDe] [int] NULL,
  [CicloA] [int] NULL,
  [Secuencia] [int] NULL CONSTRAINT [DF_tCaProdMontoPlazo_Secuencia] DEFAULT (0),
  [PorcentajeInc] [money] NULL,
  [PorcentajeIncAcum] [money] NULL,
  [MontoInc] [money] NULL,
  [MontoIncAcum] [money] NULL,
  [PorSecuencia] [bit] NULL CONSTRAINT [DF_tCaProdMontoPlazo_PorSecuencia] DEFAULT (0),
  [NumSecuencia] [int] NULL CONSTRAINT [DF_tCaProdMontoPlazo_NumSecuencia] DEFAULT (0),
  [RangoSecuencia] [bit] NULL CONSTRAINT [DF_tCaProdMontoPlazo_RangoSecuencia] DEFAULT (0),
  [SecMIN] [int] NULL CONSTRAINT [DF_tCaProdMontoPlazo_SecMIN] DEFAULT (0),
  [SecMAX] [int] NULL CONSTRAINT [DF_tCaProdMontoPlazo_SecMAX] DEFAULT (0),
  [PorRangoMayor] [bit] NULL CONSTRAINT [DF_tCaProdMontoPlazo_PorRangoMayor] DEFAULT (0),
  [RangoMayor] [int] NULL CONSTRAINT [DF_tCaProdMontoPlazo_RangoMayor] DEFAULT (0),
  [Dias] [int] NULL CONSTRAINT [DF_tCaProdMontoPlazo_Dias] DEFAULT (0),
  [CodAutoriza] [varchar](10) NULL,
  [IndicadorCuota] [money] NULL CONSTRAINT [DF_tCaProdMontoPlazo_IndicadorCuota] DEFAULT (0)
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdMontoPlazo]
  ADD CONSTRAINT [FK_tCaProdMontoPlazo_tCaProductoPerfilMonedas] FOREIGN KEY ([CodProducto], [CodMoneda]) REFERENCES [dbo].[tCaProductoPerfilMonedas] ([CodProducto], [CodMoneda])
GO

ALTER TABLE [dbo].[tCaProdMontoPlazo]
  ADD CONSTRAINT [FK_tCaProdMontoPlazo_tClMonedas] FOREIGN KEY ([CodMoneda]) REFERENCES [dbo].[tClMonedas] ([CodMoneda])
GO