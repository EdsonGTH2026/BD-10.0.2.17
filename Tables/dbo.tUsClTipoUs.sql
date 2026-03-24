CREATE TABLE [dbo].[tUsClTipoUs] (
  [CodTipoUs] [varchar](5) NOT NULL,
  [NomTipoUs] [varchar](20) NULL,
  [DescTipoUs] [varchar](50) NULL,
  [TieneOtrosDatos] [bit] NOT NULL,
  [CodSistema] [char](2) NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [tinyint] NULL
)
ON [PRIMARY]
GO