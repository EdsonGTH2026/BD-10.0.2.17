CREATE TABLE [dbo].[tSgReportesParametros] (
  [CodReporte] [int] NOT NULL,
  [CodParametro] [int] NOT NULL,
  [Nombre] [varchar](20) NULL,
  [TipoDato] [int] NULL,
  [Etiqueta] [varchar](50) NULL,
  [FuenteDatos] [varchar](400) NULL,
  [CampoMostrar] [varchar](20) NULL,
  [CampoValor] [varchar](20) NULL,
  [Visible] [bit] NULL CONSTRAINT [DF_tSgReportesParametros_Visible] DEFAULT (1),
  [PorDefecto] [varchar](50) NULL,
  [TipoObjeto] [varchar](50) NULL,
  [Comillas] [char](1) NULL CONSTRAINT [DF_tSgReportesParametros_Comillas] DEFAULT (0),
  [ParamFiltro] [varchar](50) NULL,
  [ParamValor] [varchar](50) NULL,
  [ObjAjax] [varchar](200) NULL,
  [CodParametroDepen] [int] NULL,
  [RespMinima] [int] NULL CONSTRAINT [DF_tSgReportesParametros_RespMinima] DEFAULT (1),
  CONSTRAINT [PK_tSgReportesParametros] PRIMARY KEY CLUSTERED ([CodReporte], [CodParametro])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tSgReportesParametros] WITH NOCHECK
  ADD CONSTRAINT [FK_tSgReportesParametros_tSgReportes] FOREIGN KEY ([CodReporte]) REFERENCES [dbo].[tSgReportes] ([CodReporte]) ON DELETE CASCADE ON UPDATE CASCADE
GO