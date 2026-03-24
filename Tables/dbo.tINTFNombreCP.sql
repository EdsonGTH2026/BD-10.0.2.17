CREATE TABLE [dbo].[tINTFNombreCP] (
  [Periodo] [varchar](8) NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](303) NOT NULL,
  [Usados] [int] NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [ApellidoPaterno] [varchar](30) NOT NULL,
  [ApellidoMaterno] [varchar](30) NOT NULL,
  [ApellidoAdicional] [varchar](30) NOT NULL,
  [PrimerNombre] [varchar](30) NOT NULL,
  [SegundoNombre] [varchar](30) NOT NULL,
  [FechaNacimiento] [varchar](12) NOT NULL,
  [NumeroRFC] [varchar](17) NOT NULL,
  [PrefijoPersonal] [varchar](8) NOT NULL,
  [Sufijo] [varchar](8) NOT NULL,
  [Nacionalidad] [varchar](6) NOT NULL,
  [Residencia] [varchar](6) NOT NULL,
  [LicenciaConducir] [varchar](24) NOT NULL,
  [EstadoCivil] [varchar](5) NULL,
  [Sexo] [varchar](5) NOT NULL,
  [NumeroSeguridadSocial] [varchar](20) NULL,
  [CedulaProfesional] [varchar](24) NULL,
  [IFE] [varchar](24) NOT NULL,
  [CURP] [varchar](24) NOT NULL,
  [ClaveOtroPais] [varchar](6) NOT NULL,
  [NumeroDependientes] [varchar](6) NOT NULL,
  [EdadesDependientes] [varchar](34) NOT NULL,
  [DefuncionFecha] [varchar](12) NOT NULL,
  [DefuncionIndicador] [varchar](5) NOT NULL,
  [Codprestamo] [varchar](29) NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_Periodo]
  ON [dbo].[tINTFNombreCP] ([Periodo])
  INCLUDE ([Fila], [Cadena], [CodUsuario], [Codprestamo])
  ON [PRIMARY]
GO