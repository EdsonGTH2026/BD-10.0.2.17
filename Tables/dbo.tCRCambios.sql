CREATE TABLE [dbo].[tCRCambios] (
  [ID] [int] NOT NULL,
  [Cambio] [datetime] NOT NULL,
  [IDReal] [int] NOT NULL,
  [Empresa] [varchar](2) NOT NULL,
  [ClaveOtorgante] [varchar](50) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Asignado] [varchar](100) NULL,
  [Contraseña] [varchar](50) NULL,
  [Expira] [smalldatetime] NULL,
  [Consulta] [smalldatetime] NULL,
  [Estado] [varchar](25) NOT NULL,
  [EnviaCorreo] [bit] NULL
)
ON [PRIMARY]
GO