CREATE TABLE [dbo].[tCsClientesAhorrosFecha] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodCuenta] [char](20) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [CodUsCuenta] [varchar](15) NOT NULL,
  [Coordinador] [bit] NULL,
  [idEstado] [char](2) NULL,
  [FormaManejo] [tinyint] NULL,
  [CodUsuario] [varchar](15) NULL,
  [Capital] [money] NULL,
  [Interes] [money] NULL,
  [InteresDia] [money] NULL,
  [Observacion] [varchar](300) NULL,
  CONSTRAINT [PK_tCsClientesAhorrosFecha] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodCuenta], [FraccionCta], [Renovado], [CodUsCuenta])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesAhorrosFecha_1]
  ON [dbo].[tCsClientesAhorrosFecha] ([CodCuenta], [FraccionCta], [Renovado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesAhorrosFecha_4]
  ON [dbo].[tCsClientesAhorrosFecha] ([CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesAhorrosFecha_5]
  ON [dbo].[tCsClientesAhorrosFecha] ([idEstado])
  ON [PRIMARY]
GO