CREATE TABLE [dbo].[tCsPrNivelDiasAtraso] (
  [NivelDiaAtraso] [varchar](2) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Formula] [varchar](100) NULL,
  [Depende] [varchar](2) NULL,
  CONSTRAINT [PK_tCsPrNivelDiasAtraso] PRIMARY KEY CLUSTERED ([NivelDiaAtraso])
)
ON [PRIMARY]
GO