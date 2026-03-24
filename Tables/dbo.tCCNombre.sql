CREATE TABLE [dbo].[tCCNombre] (
  [RFC] [varchar](18) NOT NULL,
  [CURP] [varchar](18) NULL,
  [Paterno] [varchar](30) NULL,
  [Materno] [varchar](30) NULL,
  [ApAdicional] [varchar](30) NULL,
  [Nombres] [varchar](50) NULL,
  [FechaNacimiento] [smalldatetime] NULL,
  [Nacionalidad] [varchar](2) NULL,
  [Residencia] [int] NULL,
  [EstadoCivil] [char](1) NULL,
  [Sexo] [char](1) NULL,
  [ClaveElectorIFE] [varchar](20) NULL,
  [NumDependientes] [int] NULL,
  [FechaDefuncion] [smalldatetime] NULL,
  [Archivo] [varchar](20) NULL
)
ON [PRIMARY]
GO