CREATE TABLE [dbo].[tCsEmpleadosVaca] (
  [CURP] [varchar](50) NOT NULL,
  [RFC] [varchar](50) NOT NULL,
  [Año] [int] NOT NULL,
  [Item] [int] NOT NULL,
  [NumeroDias] [int] NULL,
  [FecIni] [smalldatetime] NULL,
  [FecFinal] [smalldatetime] NULL,
  CONSTRAINT [PK_tCsEmpleadosVaca] PRIMARY KEY CLUSTERED ([CURP], [RFC], [Año], [Item])
)
ON [PRIMARY]
GO