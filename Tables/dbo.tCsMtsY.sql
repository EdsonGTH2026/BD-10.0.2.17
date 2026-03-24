CREATE TABLE [dbo].[tCsMtsY] (
  [CodigoY] [varchar](50) NOT NULL,
  [CodEntidad] [int] NOT NULL,
  PRIMARY KEY NONCLUSTERED ([CodigoY], [CodEntidad])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsMtsY]
  ADD FOREIGN KEY ([CodEntidad]) REFERENCES [dbo].[tCsMtsEntidad] ([CodEntidad])
GO