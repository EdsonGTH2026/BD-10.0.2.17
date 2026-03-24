CREATE TABLE [dbo].[tSgLogAccesos] (
  [Log] [numeric] NOT NULL,
  [TipoLog] [char](2) NULL,
  [Aplicacion] [varchar](22) NULL,
  [Version] [varchar](20) NULL,
  [Usuario] [varchar](50) NULL CONSTRAINT [DF_tSgLogAccesos_Usuario] DEFAULT (suser_sname()),
  [Fecha] [datetime] NULL,
  [Hora] [varchar](20) NULL,
  [Terminal] [varchar](30) NULL,
  [IpMaquina] [varchar](15) NULL,
  CONSTRAINT [PK_tSgLogAccesos] PRIMARY KEY CLUSTERED ([Log])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_USuario_TipoLog]
  ON [dbo].[tSgLogAccesos] ([Usuario], [TipoLog], [Fecha], [Hora], [Terminal], [IpMaquina])
  ON [PRIMARY]
GO