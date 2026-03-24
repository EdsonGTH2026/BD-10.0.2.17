CREATE TABLE [dbo].[tCsPdnPasoProduccion] (
  [CURP] [varchar](50) NULL,
  [SelloElectronico] [varchar](100) NOT NULL,
  [Sistema] [varchar](5) NULL,
  [VMayor] [int] NULL,
  [VMenor] [int] NULL,
  [VRevision] [int] NULL,
  [Ambiente] [varchar](100) NULL,
  [Cuerpo] [varchar](8000) NULL,
  CONSTRAINT [PK_pCsPdnPasoProduccion] PRIMARY KEY CLUSTERED ([SelloElectronico])
)
ON [PRIMARY]
GO