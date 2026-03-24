CREATE TABLE [dbo].[TablaRecorrido] (
  [Representa] [varchar](11) NOT NULL,
  [Fila] [int] IDENTITY,
  [Periodo] [varchar](6) NOT NULL,
  [Contador] [int] NULL,
  [SaldoActual] [varchar](18) NULL,
  [SaldoVencido] [varchar](18) NULL,
  [Abreviatura] [varchar](16) NULL,
  [Direccion] [varchar](100) NULL,
  [Cabecera] [int] NOT NULL,
  [Empleo] [int] NOT NULL,
  [Bloques] [int] NOT NULL
)
ON [PRIMARY]
GO