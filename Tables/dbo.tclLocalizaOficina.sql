CREATE TABLE [dbo].[tclLocalizaOficina] (
  [CodOficina] [varchar](5) NULL,
  [latitud] [varchar](30) NULL,
  [longitud] [varchar](30) NULL,
  [Correo] [varchar](200) NULL,
  [Telefono] [varchar](15) NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tclLocalizaOficina] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tclLocalizaOficina] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tclLocalizaOficina] TO [rie_rgonzalezc]
GO