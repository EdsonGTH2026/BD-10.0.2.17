CREATE TABLE [dbo].[tCsEmpleados] (
  [CURP] [varchar](50) NOT NULL,
  [RFC] [varchar](50) NOT NULL,
  [Paterno] [varchar](50) NULL,
  [Materno] [varchar](50) NULL,
  [Nombres] [varchar](50) NULL,
  [Nacimiento] [smalldatetime] NULL,
  [Ingreso] [smalldatetime] NULL,
  [Salida] [smalldatetime] NULL,
  [CodUsuario] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  [Correo] [varchar](100) NULL,
  [CopiaCorreo] [varchar](100) NULL,
  [DataNegocio] [varchar](50) NULL,
  [CodEmpleado] [varchar](50) NULL,
  [CodOficinaNom] [varchar](4) NULL,
  [CodPuesto] [int] NULL,
  [Estado] [char](1) NULL CONSTRAINT [DF_tCsEmpleados_Estado] DEFAULT (1),
  [CE] [varchar](20) NULL,
  [Domicilio] [varchar](100) NULL,
  [Ubicacion] [text] NULL,
  [Tiempo] [int] NULL,
  [EstadoCivil] [char](1) NULL,
  [Escolaridad] [varchar](50) NULL,
  [TipoPropiedad] [char](3) NULL,
  [Celular] [varchar](15) NULL,
  [CodCuenta] [varchar](50) NULL,
  [FraccionCta] [varchar](8) NULL,
  [Renovado] [int] NULL,
  [Nomina] [decimal](18, 2) NULL,
  [ReferenciaNomitec] [varchar](50) NULL,
  [CodMBaja] [int] NULL,
  [NumCelular] [varchar](10) NULL,
  CONSTRAINT [PK_tCsEmpleados] PRIMARY KEY CLUSTERED ([CURP], [RFC])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE INDEX [IX_CodUsuario]
  ON [dbo].[tCsEmpleados] ([CodUsuario], [CodEmpleado], [CodOficinaNom], [CodPuesto], [Estado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados]
  ON [dbo].[tCsEmpleados] ([CURP], [CodPuesto])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados_CodOficinaNom_CodPuesto]
  ON [dbo].[tCsEmpleados] ([CodOficinaNom], [CodPuesto])
  INCLUDE ([CodUsuario], [Estado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados_CodPuesto]
  ON [dbo].[tCsEmpleados] ([CodPuesto])
  INCLUDE ([CodUsuario], [CodOficinaNom], [Estado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados_CodPuestoV2]
  ON [dbo].[tCsEmpleados] ([CodPuesto])
  INCLUDE ([Paterno], [Materno], [Nombres], [CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados_CodUsuario]
  ON [dbo].[tCsEmpleados] ([CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados_EstadoUsuarioOficinaPuesto]
  ON [dbo].[tCsEmpleados] ([Estado], [CodUsuario], [CodOficina], [CodPuesto])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados_Ingreso]
  ON [dbo].[tCsEmpleados] ([Ingreso])
  INCLUDE ([Paterno], [Materno], [Nombres], [CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleados_Paterno_Materno_Nombres]
  ON [dbo].[tCsEmpleados] ([Paterno], [Materno], [Nombres])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsEmpleados] TO [int_mmartinezp]
GO