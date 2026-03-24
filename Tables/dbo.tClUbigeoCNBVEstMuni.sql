CREATE TABLE [dbo].[tClUbigeoCNBVEstMuni] (
  [codestado] [varchar](8000) NULL,
  [codlocalidadLargo] [varchar](8000) NULL,
  [codpostal] [varchar](8000) NULL,
  [codpostallargo] [varchar](8000) NULL,
  [descripcion] [varchar](8000) NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEstMuni] TO [jarriagaa]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEstMuni] TO [public]
GO