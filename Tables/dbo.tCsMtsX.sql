CREATE TABLE [dbo].[tCsMtsX] (
  [CodEntidad] [int] NOT NULL,
  [CodigoX] [varchar](20) NOT NULL,
  PRIMARY KEY NONCLUSTERED ([CodEntidad], [CodigoX])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsMtsX]
  ADD FOREIGN KEY ([CodEntidad]) REFERENCES [dbo].[tCsMtsEntidad] ([CodEntidad])
GO