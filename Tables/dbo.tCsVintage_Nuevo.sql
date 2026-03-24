CREATE TABLE [dbo].[tCsVintage_Nuevo] (
  [Item] [int] NOT NULL,
  [Ubicacion] [varchar](4) NOT NULL,
  [Cartera] [varchar](50) NOT NULL,
  [Desembolso] [varchar](8) NOT NULL,
  [Periodo] [varchar](6) NOT NULL,
  [Corte] [varchar](8) NOT NULL,
  [Proceso] [smalldatetime] NOT NULL,
  [Total] [int] NULL,
  [Buenos] [int] NULL,
  [Malos] [int] NULL,
  [Terminados] [int] NULL,
  [Vencidos] [int] NULL,
  [Ratio1] [decimal](20, 5) NULL,
  [Ratio2] [decimal](20, 5) NULL,
  [MntoTotal] [decimal](20, 4) NULL,
  [MntoBuenos] [decimal](20, 4) NULL,
  [MntoMalos] [decimal](20, 4) NULL,
  [MntoTerminados] [decimal](20, 4) NULL,
  [MntoVencidos] [decimal](20, 4) NULL,
  [MntoNuevosBuenos] [decimal](20, 4) NULL,
  [MntoNuevosMalos] [decimal](20, 4) NULL,
  [MntoNuevosTerminados] [decimal](20, 4) NULL,
  [MntoNuevosVencidos] [decimal](20, 4) NULL,
  [MntoRepresBuenos] [decimal](20, 4) NULL,
  [MntoRepresMalos] [decimal](20, 4) NULL,
  [MntoRepresTerminados] [decimal](20, 4) NULL,
  [MntoRepresVencidos] [decimal](20, 4) NULL,
  [SaldoTotal] [decimal](20, 4) NULL,
  [SaldoBuenos] [decimal](20, 4) NULL,
  [SaldoMalos] [decimal](20, 4) NULL,
  [SaldoTerminados] [decimal](20, 4) NULL,
  [SaldoVencidos] [decimal](20, 4) NULL,
  CONSTRAINT [PK_tCsVintage_Nuevo_1] PRIMARY KEY CLUSTERED ([Item], [Ubicacion], [Cartera], [Desembolso], [Periodo], [Corte], [Proceso])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsVintage_Nuevo_Proceso_Periodo_Item]
  ON [dbo].[tCsVintage_Nuevo] ([Proceso], [Periodo], [Item])
  ON [PRIMARY]
GO