CREATE TABLE [dbo].[tUsClGradoInstruccion] (
  [GradoInstruccion] [varchar](50) NOT NULL,
  [SHF] [int] NULL,
  CONSTRAINT [PK_tUsClGradoInstruccion] PRIMARY KEY CLUSTERED ([GradoInstruccion])
)
ON [PRIMARY]
GO