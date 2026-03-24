CREATE TABLE [dbo].[tCsCoPlantillaHistorico] (
  [Periodo] [varchar](6) NOT NULL,
  [Reporte] [char](2) NOT NULL,
  [Codigo] [varchar](10) NOT NULL,
  [TipoValor] [varchar](2) NULL,
  [BaseDatos] [varchar](2) NULL,
  [Operacion] [varchar](500) NULL,
  [CuentaCampo] [varchar](500) NULL,
  [TipoCampo] [varchar](20) NULL,
  CONSTRAINT [PK_tCsCoPlantillaHistorico] PRIMARY KEY CLUSTERED ([Periodo], [Reporte], [Codigo])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCoPlantillaHistorico] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsCoPlantillaHistorico_tCsCoPlantilla] FOREIGN KEY ([Reporte], [Codigo]) REFERENCES [dbo].[tCsCoPlantilla] ([Reporte], [Codigo]) ON UPDATE CASCADE
GO