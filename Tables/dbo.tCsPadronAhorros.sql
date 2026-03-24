CREATE TABLE [dbo].[tCsPadronAhorros] (
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [CU] [varchar](20) NULL,
  [CodOficina] [varchar](4) NULL,
  [CodUsuario] [varchar](15) NULL,
  [CodProducto] [varchar](3) NULL,
  [FechaCorte] [smalldatetime] NULL,
  [EstadoOriginal] [varchar](5) NULL,
  [EstadoCalculado] [varchar](5) NULL,
  [FecApertura] [smalldatetime] NULL,
  [TipApertura] [int] NULL,
  [TraApertura] [float] NULL,
  [MonApertura] [float] NULL,
  [FecCancelacion] [smalldatetime] NULL,
  [TipCancelacion] [int] NULL,
  [TraCancelacion] [float] NULL,
  [MonCancelacion] [float] NULL,
  [CodSiaff] [float] NULL,
  [AbonoPenultimo] [smalldatetime] NULL,
  [AbonoUltimo] [smalldatetime] NULL,
  [CargoPenultimo] [smalldatetime] NULL,
  [CargoUltimo] [smalldatetime] NULL,
  [TotalAbonos] [float] NULL,
  [TotalRetiros] [float] NULL,
  [EstadoCuenta] [int] NULL,
  CONSTRAINT [PK_tCsPadronAhorros] PRIMARY KEY CLUSTERED ([CodCuenta], [FraccionCta], [Renovado])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronAhorros_1]
  ON [dbo].[tCsPadronAhorros] ([FechaCorte])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronAhorros_5]
  ON [dbo].[tCsPadronAhorros] ([FecCancelacion])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronAhorros_6]
  ON [dbo].[tCsPadronAhorros] ([CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronAhorros_CodOficina]
  ON [dbo].[tCsPadronAhorros] ([CodOficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronAhorros_EstadoCalculado_CodUsuario_FechaCorte]
  ON [dbo].[tCsPadronAhorros] ([EstadoCalculado], [CodUsuario], [FechaCorte])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronAhorros_FecApertura]
  ON [dbo].[tCsPadronAhorros] ([FecApertura])
  INCLUDE ([CodCuenta], [FraccionCta], [Renovado], [FechaCorte])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsPadronAhorros] TO [jmartinezc]
GO

GRANT SELECT ON [dbo].[tCsPadronAhorros] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsPadronAhorros] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsPadronAhorros] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsPadronAhorros] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsPadronAhorros] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsPadronAhorros] TO [Int_dreyesg]
GO