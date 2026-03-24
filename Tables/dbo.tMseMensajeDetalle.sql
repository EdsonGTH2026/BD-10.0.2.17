CREATE TABLE [dbo].[tMseMensajeDetalle] (
  [Ubicacion] [varchar](50) NOT NULL,
  [Inicio] [smalldatetime] NOT NULL,
  [Fin] [smalldatetime] NOT NULL,
  [Concepto] [varchar](50) NOT NULL,
  [ValorAn] [decimal](18, 4) NULL,
  [ValorAc] [decimal](18, 4) NULL,
  CONSTRAINT [PK_tMseMensajeDetalle] PRIMARY KEY CLUSTERED ([Ubicacion], [Inicio], [Fin], [Concepto])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tMseMensajeDetalle]
  ON [dbo].[tMseMensajeDetalle] ([Fin])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[tMseMensajeDetalle] WITH NOCHECK
  ADD CONSTRAINT [FK_tMseMensajeDetalle_tMseMensaje] FOREIGN KEY ([Ubicacion], [Inicio], [Fin]) REFERENCES [dbo].[tMseMensaje] ([Ubicacion], [Inicio], [Fin]) ON UPDATE CASCADE
GO