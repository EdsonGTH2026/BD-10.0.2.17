CREATE TABLE [dbo].[tCsFraseDia] (
  [Año] [int] NULL,
  [Mes] [int] NULL,
  [Dia] [int] NULL,
  [Descripcion] [varchar](4000) NULL,
  [Aleatorio] [bit] NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsFraseDia]
  ON [dbo].[tCsFraseDia] ([Año], [Mes], [Dia])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsFraseDia_2]
  ON [dbo].[tCsFraseDia] ([Mes])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsFraseDia_3]
  ON [dbo].[tCsFraseDia] ([Dia])
  ON [PRIMARY]
GO