CREATE TABLE [dbo].[tClZona] (
  [Zona] [char](3) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [CodOficina] [varchar](4) NULL,
  [Responsable] [varchar](50) NULL,
  [Orden] [int] NULL,
  [Activo] [bit] NULL,
  [Nemo] [varchar](10) NULL,
  [codvolante] [varchar](25) NULL,
  CONSTRAINT [PK_tClZona] PRIMARY KEY CLUSTERED ([Zona])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tClZona] TO [marista]
GO

GRANT SELECT ON [dbo].[tClZona] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tClZona] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tClZona] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tClZona] TO [ope_dalvarador]
GO

GRANT SELECT ON [dbo].[tClZona] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tClZona] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tClZona] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tClZona] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tClZona] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tClZona] TO [int_mmartinezp]
GO