CREATE TABLE [dbo].[tCRAuditoria] (
  [Empresa] [varchar](2) NOT NULL,
  [PeriodoI] [varchar](6) NOT NULL,
  [PeriodoF] [varchar](6) NOT NULL,
  [Nro] [float] NOT NULL,
  [Nombre] [varchar](100) NULL,
  [RFC] [varchar](20) NULL,
  [Usuario] [varchar](50) NULL,
  [Fid] [varchar](50) NULL,
  [Folio] [float] NULL,
  [Consulta] [smalldatetime] NULL,
  [Direccion] [varchar](255) NULL,
  [Colonia] [varchar](255) NULL,
  [Delegacion] [varchar](255) NULL,
  [Ciudad] [varchar](255) NULL,
  [Estado] [varchar](255) NULL,
  [CodigoPostal] [float] NULL,
  [CodOficina] [varchar](4) NULL,
  [ClienteP] [varchar](20) NULL,
  [DatoP] [varchar](100) NULL,
  [ClienteSD] [varchar](20) NULL,
  [Sonido1] [varchar](4) NULL,
  [Sonido2] [varchar](4) NULL,
  [Diferencia] [int] NULL,
  CONSTRAINT [PK_tCRAuditoria] PRIMARY KEY CLUSTERED ([Empresa], [PeriodoI], [PeriodoF], [Nro])
)
ON [PRIMARY]
GO