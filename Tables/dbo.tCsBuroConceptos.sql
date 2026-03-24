CREATE TABLE [dbo].[tCsBuroConceptos] (
  [CodConcepto] [varchar](2) NOT NULL,
  [Concepto] [varchar](50) NULL,
  [Mascara] [varchar](50) NULL,
  [Abreviatura] [varchar](3) NULL,
  CONSTRAINT [PK_tCsBuroConceptos] PRIMARY KEY CLUSTERED ([CodConcepto])
)
ON [PRIMARY]
GO