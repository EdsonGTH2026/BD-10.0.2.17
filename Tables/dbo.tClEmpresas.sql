CREATE TABLE [dbo].[tClEmpresas] (
  [CodEmpresa] [tinyint] NOT NULL,
  [CodUsuario] [varchar](25) NULL,
  [KOB] [varchar](2) NULL,
  [SHF] [varchar](3) NULL,
  [CASFIM] [varchar](6) NULL,
  [ATLAS] [varchar](3) NULL,
  [Nivel] [varchar](3) NULL,
  [Abreviatura] [varchar](16) NULL,
  [DescEmpresa] [varchar](100) NOT NULL,
  [Sigla] [varchar](6) NOT NULL,
  [NroInstitucion] [varchar](4) NULL,
  [OficinaPrincipal] [varchar](4) NULL,
  [Direccion] [varchar](100) NOT NULL,
  [Telefono] [varchar](30) NOT NULL,
  [Fax] [varchar](30) NOT NULL,
  [CodFondoxDefecto] [varchar](2) NOT NULL,
  [NombreActividad] [varchar](50) NULL,
  [Activo] [bit] NULL,
  [LineaGratuita] [varchar](50) NULL,
  CONSTRAINT [PK_tClEmpresas] PRIMARY KEY CLUSTERED ([CodEmpresa])
)
ON [PRIMARY]
GO