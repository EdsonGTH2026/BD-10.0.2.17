CREATE TABLE [dbo].[tClUbigeoCNBVLocalidades] (
  [codpais] [varchar](8000) NULL,
  [pais] [varchar](8000) NULL,
  [codestado] [varchar](8000) NULL,
  [estado] [varchar](8000) NULL,
  [codmunicipio] [varchar](8000) NULL,
  [municipio] [varchar](8000) NULL,
  [codlocalidad] [varchar](8000) NULL,
  [localidad] [varchar](8000) NULL,
  [codlocalidadLargo] [varchar](8000) NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVLocalidades] TO [public]
GO