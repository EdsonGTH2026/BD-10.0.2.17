CREATE TABLE [dbo].[tASSISTTransactionGroup] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](108) NOT NULL,
  [Usados] [int] NULL,
  [CodigoGrupo] [varchar](8) NOT NULL,
  [Descripcion] [varchar](100) NOT NULL
)
ON [PRIMARY]
GO