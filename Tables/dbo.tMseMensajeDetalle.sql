CREATE TABLE [dbo].[tMseMensajeDetalle] (
  [Ubicacion] [varchar](50) NOT NULL,
  [Inicio] [smalldatetime] NOT NULL,
  [Fin] [smalldatetime] NOT NULL,
  [Concepto] [varchar](50) NOT NULL,
  [ValorAn] [decimal](18, 4) NULL,
  [ValorAc] [decimal](18, 4) NULL
)
ON [PRIMARY]
GO