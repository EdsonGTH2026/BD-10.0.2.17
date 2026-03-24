CREATE TABLE [dbo].[tSHFLineaCredito] (
  [Linea] [int] NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Abreviatura] [varchar](2) NULL,
  [Inicio] [smalldatetime] NULL,
  [Fin] [smalldatetime] NULL,
  CONSTRAINT [PK_tSHFLineaCredito] PRIMARY KEY CLUSTERED ([Linea])
)
ON [PRIMARY]
GO