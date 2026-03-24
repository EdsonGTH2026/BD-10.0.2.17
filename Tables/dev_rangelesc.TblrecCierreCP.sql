CREATE TABLE [dev_rangelesc].[TblrecCierreCP] (
  [Representa] [varchar](17) NOT NULL,
  [Fila] [int] IDENTITY,
  [Periodo] [varchar](8) NULL,
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