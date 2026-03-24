CREATE TABLE [dbo].[tCsBuroMOP] (
  [MOP] [varchar](2) NOT NULL,
  [Entero] [int] NULL,
  [Inicio] [int] NULL,
  [Fin] [int] NULL,
  [Descripcion] [varchar](100) NULL,
  [Observacion] [varchar](200) NULL,
  [CNBV] [char](5) NULL,
  CONSTRAINT [PK_tCsBuroMOP] PRIMARY KEY CLUSTERED ([MOP])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsBuroMOP_Fin]
  ON [dbo].[tCsBuroMOP] ([Fin])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsBuroMOP_Inicio]
  ON [dbo].[tCsBuroMOP] ([Inicio])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsBuroMOP] TO [rie_jaguilar]
GO

GRANT SELECT ON [dbo].[tCsBuroMOP] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsBuroMOP] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsBuroMOP] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsBuroMOP] TO [rie_blozanob]
GO