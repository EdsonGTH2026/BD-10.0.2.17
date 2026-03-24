CREATE TABLE [dbo].[tcsgrafanamiio] (
  [desembolso] [smalldatetime] NULL,
  [CODPRESTAMO] [varchar](25) NOT NULL,
  [monto] [decimal](18, 4) NULL,
  [rangoCiclo] [varchar](9) NOT NULL,
  [CICLO] [int] NULL
)
ON [PRIMARY]
GO