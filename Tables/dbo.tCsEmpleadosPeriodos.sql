CREATE TABLE [dbo].[tCsEmpleadosPeriodos] (
  [CURP] [varchar](50) NOT NULL,
  [RFC] [varchar](50) NOT NULL,
  [FechaAlta] [smalldatetime] NOT NULL,
  [FechaBaja] [smalldatetime] NULL,
  [CodOficina] [varchar](4) NULL,
  [CodPuesto] [int] NULL,
  CONSTRAINT [PK_tCsEmpleadosPeriodos] PRIMARY KEY CLUSTERED ([CURP], [RFC], [FechaAlta])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosPeriodos] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosPeriodos] TO [rie_ldomingueze]
GO