CREATE TABLE [dbo].[tINTFEmpleoCP] (
  [Periodo] [varchar](8) NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](478) NOT NULL,
  [Usados] [int] NULL,
  [CodUsuario] [varchar](17) NOT NULL,
  [Empleador] [varchar](105) NOT NULL,
  [PrimerLineaDireccion] [varchar](46) NULL,
  [SegundaLineaDireccion] [varchar](46) NULL,
  [ColoniaProblacion] [varchar](46) NULL,
  [DelegacionMunicipio] [varchar](46) NULL,
  [Ciudad] [varchar](46) NULL,
  [Estado] [varchar](10) NULL,
  [CP] [varchar](11) NULL,
  [NumeroTelefono] [varchar](17) NULL,
  [ExtensionTelefonica] [varchar](14) NULL,
  [NumeroFax] [varchar](17) NULL,
  [CargoOcupacion] [varchar](36) NULL,
  [FechaContratacion] [varchar](14) NULL,
  [ClaveMoneda] [varchar](8) NULL,
  [MontoSueldo] [varchar](15) NULL,
  [PeriodoPago] [varchar](7) NULL,
  [NumeroEmpleado] [varchar](21) NULL,
  [FechaUltimoDiaEmpleo] [varchar](14) NULL,
  [FechaVerificacionEmpleo] [varchar](14) NULL,
  [OrigenRazonSocial] [varchar](8) NOT NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_Periodo]
  ON [dbo].[tINTFEmpleoCP] ([Periodo])
  INCLUDE ([Fila], [Cadena], [CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_Periodo_CodUsuario]
  ON [dbo].[tINTFEmpleoCP] ([Periodo], [CodUsuario])
  INCLUDE ([Fila], [Cadena])
  ON [PRIMARY]
GO