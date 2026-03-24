CREATE TABLE [dbo].[tCsMtsConceptos] (
  [CodConceptos] [int] NOT NULL,
  [CodSistema] [char](2) NULL,
  [Descripcion] [varchar](100) NULL,
  CONSTRAINT [PK__tCsMtsConceptos__3F7150CD] PRIMARY KEY NONCLUSTERED ([CodConceptos])
)
ON [PRIMARY]
GO