CREATE TABLE [dbo].[tCsPrRegulatorios] (
  [Fecha] [smalldatetime] NOT NULL,
  [Reporte] [varchar](10) NOT NULL,
  [Descripcion] [varchar](1400) NULL,
  [Identificador] [varchar](15) NOT NULL,
  [DescIdentificador] [varchar](400) NULL,
  [Agrupado] [varchar](5) NOT NULL,
  [Nivel] [int] NULL,
  [Comentario] [varchar](3) NULL,
  [DetComentario] [varchar](400) NULL,
  [Saldo] [decimal](38, 4) NULL,
  [OtroDato] [varchar](1000) NULL,
  [Columna] [varchar](500) NULL,
  [Generacion] [datetime] NULL,
  CONSTRAINT [PK_tCsPrR21A2111] PRIMARY KEY CLUSTERED ([Fecha], [Reporte], [Identificador])
)
ON [PRIMARY]
GO