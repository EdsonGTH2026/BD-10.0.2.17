CREATE TABLE [dbo].[tCaProdInteresRelacion] (
  [ID] [int] IDENTITY,
  [Secuencial] [tinyint] NULL CONSTRAINT [DF_tCaProdInteresRelacion_Secuencial] DEFAULT (0),
  [CodProducto] [char](3) NULL,
  [CodMoneda] [varchar](2) NULL CONSTRAINT [DF_tCaProdInteresRelacion_CodMoneda] DEFAULT ('-'),
  [CodGarantia] [varchar](10) NULL CONSTRAINT [DF_tCaProdInteresRelacion_CodGarantia] DEFAULT ('-'),
  [CodDestino] [varchar](15) NULL,
  [GrupoAgencia] [char](1) NULL CONSTRAINT [DF_tCaProdInteresRelacion_GrupoAgencia] DEFAULT ('-'),
  [PlazoMin] [smallint] NULL CONSTRAINT [DF_tCaProdInteresRelacion_PlazoMin] DEFAULT (0),
  [Plazo] [int] NULL CONSTRAINT [DF_tCaProdInteresRelacion_Plazo] DEFAULT (0),
  [MontoMIN] [varchar](6) NULL CONSTRAINT [DF_tCaProdInteresRelacion_MontoMIN] DEFAULT (0),
  [MontoMAX] [varchar](15) NULL CONSTRAINT [DF_tCaProdInteresRelacion_MontoMAX] DEFAULT (0),
  [INTEAnual] [smallmoney] NULL CONSTRAINT [DF_tCaProdInteresRelacion_INTEAnual] DEFAULT (0),
  [INTENegMin] [smallmoney] NULL CONSTRAINT [DF_tCaProdInteresRelacion_INTENegMin] DEFAULT (0),
  [INTENegMax] [smallmoney] NULL CONSTRAINT [DF_tCaProdInteresRelacion_INTENegMax] DEFAULT (0),
  [Estado] [varchar](10) NULL CONSTRAINT [DF_tCaProdInteresRelacion_Estado] DEFAULT ('REGISTRADO'),
  CONSTRAINT [PK_tCaProdInteresRelacion] PRIMARY KEY CLUSTERED ([ID])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdInteresRelacion] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdInteresRelacion_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO

ALTER TABLE [dbo].[tCaProdInteresRelacion] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdInteresRelacion_tClMonedas] FOREIGN KEY ([CodMoneda]) REFERENCES [dbo].[tClMonedas] ([CodMoneda])
GO