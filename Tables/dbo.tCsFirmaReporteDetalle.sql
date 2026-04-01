CREATE TABLE [dbo].[tCsFirmaReporteDetalle] (
  [Firma] [varchar](100) NOT NULL,
  [Identificador] [varchar](100) NOT NULL,
  [Grupo] [varchar](10) NOT NULL,
  [Sujeto] [varchar](100) NULL,
  [EstadoCivil] [varchar](50) NULL,
  [Actividad] [varchar](500) NULL,
  [Ocupacion] [varchar](500) NULL,
  [Direccion] [varchar](1000) NULL,
  [Identificacion] [varchar](50) NULL,
  [Nacionalidad] [varchar](50) NULL,
  [Telefono] [varchar](50) NULL,
  [Fecha1] [datetime] NULL,
  [Fecha2] [datetime] NULL,
  [Saldo1] [decimal](18, 5) NULL,
  [Saldo2] [decimal](18, 5) NULL,
  [Saldo3] [decimal](18, 5) NULL,
  [Saldo4] [decimal](18, 5) NULL,
  [Saldo5] [decimal](18, 5) NULL,
  [Dec1] [decimal](18, 4) NULL,
  [Dec2] [decimal](18, 4) NULL,
  [Dec3] [decimal](18, 4) NULL,
  [Texto] [varchar](8000) NULL
)
ON [PRIMARY]
GO