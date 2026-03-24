CREATE TABLE [dbo].[tCsMtsCorporativo] (
  [Periodo] [varchar](6) NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  PRIMARY KEY NONCLUSTERED ([Periodo], [CodSistema])
)
ON [PRIMARY]
GO