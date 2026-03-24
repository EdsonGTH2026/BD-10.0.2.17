CREATE TABLE [dbo].[tCsBsCartera] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodAsesor] [varchar](15) NOT NULL,
  [CodProducto] [smallint] NOT NULL,
  [MontoDesembolso] [decimal](18, 6) NULL,
  [SaldoCartera] [decimal](18, 6) NULL,
  [Saldo0Dias] [decimal](18, 6) NULL,
  [Saldo90Dias] [decimal](18, 6) NULL,
  [Recuperacion] [decimal](18, 6) NULL,
  [Estimacion] [decimal](18, 6) NULL,
  CONSTRAINT [PK_tCsBsCartera] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodProducto], [CodAsesor])
)
ON [PRIMARY]
GO