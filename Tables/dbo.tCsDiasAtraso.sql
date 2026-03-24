CREATE TABLE [dbo].[tCsDiasAtraso] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOficina] [varchar](3) NULL,
  [Saldo] [decimal](9, 2) NULL,
  [Aceptado] [bit] NULL,
  [DiasAtraso] [smallint] NOT NULL,
  [Porcentaje] [smallmoney] NULL,
  [Acumulado] [smallmoney] NULL,
  [IAtrasoDia] [char](1) NULL,
  [IAtrasoMes] [char](1) NULL,
  [IAtrasoAño] [char](1) NULL,
  [CodAnterior] [varchar](15) NULL,
  CONSTRAINT [PK_tCsDiasAtraso] PRIMARY KEY CLUSTERED ([Fecha], [CodUsuario], [DiasAtraso])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsDiasAtraso]
  ON [dbo].[tCsDiasAtraso] ([CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsDiasAtraso_1]
  ON [dbo].[tCsDiasAtraso] ([CodOficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsDiasAtraso_2]
  ON [dbo].[tCsDiasAtraso] ([IAtrasoDia])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsDiasAtraso_3]
  ON [dbo].[tCsDiasAtraso] ([IAtrasoMes])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsDiasAtraso_4]
  ON [dbo].[tCsDiasAtraso] ([IAtrasoAño])
  ON [PRIMARY]
GO