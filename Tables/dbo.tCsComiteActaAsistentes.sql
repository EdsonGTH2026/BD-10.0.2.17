CREATE TABLE [dbo].[tCsComiteActaAsistentes] (
  [Tipo] [varchar](5) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Acta] [varchar](50) NOT NULL,
  [Registro] [datetime] NULL,
  [Hora] [varchar](20) NULL,
  [DescOficina] [varchar](50) NULL,
  [TipoActa] [varchar](100) NULL,
  [CodUsuario] [varchar](50) NOT NULL,
  [Nombre] [varchar](503) NULL,
  [Puesto] [int] NOT NULL,
  [Grupo] [varchar](2) NULL,
  [PMinimo] [numeric](18, 2) NULL,
  [MontoSolicitado] [money] NULL,
  CONSTRAINT [PK_tCsComiteActaAsistentes] PRIMARY KEY CLUSTERED ([Acta], [CodUsuario], [Puesto])
)
ON [PRIMARY]
GO