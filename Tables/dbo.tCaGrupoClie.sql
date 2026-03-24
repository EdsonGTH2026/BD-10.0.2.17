CREATE TABLE [dbo].[tCaGrupoClie] (
  [CodGrupo] [char](15) NOT NULL,
  [CodCliente] [char](15) NOT NULL,
  [Coordinador] [bit] NULL CONSTRAINT [DF_tCaGrupoClie_Coordinador] DEFAULT (0),
  [MontoCliente] [money] NULL,
  [CodDestino] [varchar](3) NULL,
  [CodTipoPlan] [char](1) NULL,
  [MontoCuota] [money] NULL,
  [EstadoCliente] [varchar](10) NULL,
  [CodCuenta] [varchar](25) NULL,
  [FraccionCta] [varchar](8) NULL,
  [Renovado] [tinyint] NULL,
  CONSTRAINT [PK_tCaGrupoClie] PRIMARY KEY CLUSTERED ([CodGrupo], [CodCliente])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaGrupoClie] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaGrupoClie_tCaGrupos] FOREIGN KEY ([CodGrupo]) REFERENCES [dbo].[tCaGrupos] ([CodGrupo])
GO