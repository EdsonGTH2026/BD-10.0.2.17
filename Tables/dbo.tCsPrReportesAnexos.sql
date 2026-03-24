CREATE TABLE [dbo].[tCsPrReportesAnexos] (
  [Reporte] [varchar](10) NOT NULL,
  [CodFila] [varchar](3) NOT NULL,
  [Descripcion] [varchar](400) NULL,
  [Identificador] [varchar](15) NOT NULL,
  [DescIdentificador] [varchar](400) NULL,
  [Agrupado] [varchar](5) NOT NULL,
  [Nivel] [int] NULL,
  [Comentario] [varchar](3) NULL,
  [DetComentario] [varchar](400) NULL,
  [Signo] [char](1) NULL,
  [Cuenta] [varchar](25) NULL,
  [MostrarCuenta] AS ([dbo].[fduCuentaAtexto]([Cuenta])),
  [pInicio] [decimal](30, 5) NULL,
  [PFin] [decimal](30, 5) NULL,
  [Formula] [varchar](1000) NULL,
  [Procedimiento] [varchar](100) NULL,
  [PeriodoAnterior] [int] NULL,
  [Parametros] [varchar](100) NULL,
  [Redondeo] [int] NULL,
  [OtroDato] [varchar](1000) NULL,
  [Columna] [varchar](500) NULL,
  [ProcedimientoV] [varchar](100) NULL,
  [ParametrosV] [varchar](100) NULL,
  CONSTRAINT [PK_tCsReporte6B] PRIMARY KEY CLUSTERED ([Reporte], [CodFila], [Identificador], [Agrupado])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsPrReportesAnexos] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsPrReportesAnexos_tCsPrReporte] FOREIGN KEY ([Reporte]) REFERENCES [dbo].[tCsPrReporte] ([Reporte])
GO