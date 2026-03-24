CREATE TABLE [dbo].[tCsMtsCruzados] (
  [Periodo] [varchar](6) NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  [CodigoX] [varchar](50) NOT NULL,
  [CodEntidadX] [int] NOT NULL,
  [CodigoY] [varchar](50) NOT NULL,
  [CodEntidadY] [int] NOT NULL,
  [Monto] [decimal](16, 4) NULL,
  CONSTRAINT [PK__tCsMtsxOficinas__4159993F] PRIMARY KEY NONCLUSTERED ([Periodo], [CodSistema], [CodigoX], [CodigoY], [CodEntidadX], [CodEntidadY])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsMtsCruzados] WITH NOCHECK
  ADD CONSTRAINT [FK__tCsMtsxOficinas__480696CE] FOREIGN KEY ([Periodo], [CodSistema]) REFERENCES [dbo].[tCsMtsCorporativo] ([Periodo], [CodSistema]) ON DELETE CASCADE ON UPDATE CASCADE
GO