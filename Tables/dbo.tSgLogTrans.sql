CREATE TABLE [dbo].[tSgLogTrans] (
  [Log] [numeric] NOT NULL,
  [TipoLog] [char](2) NULL,
  [Aplicacion] [varchar](22) NULL,
  [Version] [varchar](30) NULL,
  [Usuario] [varchar](15) NULL CONSTRAINT [DF_tSgLogTrans_Usuario] DEFAULT (suser_sname()),
  [Fecha] [datetime] NULL,
  [Hora] [varchar](20) NULL,
  [Terminal] [varchar](30) NULL,
  [IpMaquina] [varchar](15) NULL,
  [Opcion] [varchar](22) NULL,
  [Tabla] [varchar](50) NULL,
  [Sentencia] [sql_variant] NULL,
  CONSTRAINT [PK_tGnlLog] PRIMARY KEY CLUSTERED ([Log])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tSgLogTrans_Usuario]
  ON [dbo].[tSgLogTrans] ([Usuario])
  ON [PRIMARY]
GO