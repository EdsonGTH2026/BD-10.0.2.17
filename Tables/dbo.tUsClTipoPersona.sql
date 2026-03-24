CREATE TABLE [dbo].[tUsClTipoPersona] (
  [CodTPersona] [varchar](2) NOT NULL,
  [IDE] [varchar](2) NULL,
  [IVA] [varchar](2) NULL,
  [Tipo] [varchar](50) NULL,
  [NomTPersona] [varchar](15) NULL,
  [DescTPersona] [varchar](50) NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NOT NULL,
  [FinesLucro] [bit] NOT NULL,
  CONSTRAINT [PK_tUsClTipoPersona] PRIMARY KEY CLUSTERED ([CodTPersona])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tUsClTipoPersona] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tUsClTipoPersona] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tUsClTipoPersona] TO [rie_jalvarezc]
GO