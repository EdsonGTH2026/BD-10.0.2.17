CREATE TABLE [dbo].[tCsPLD_ClasificacionRiesgoConsolidado] (
  [Periodo] [varchar](6) NOT NULL,
  [CodCliente] [varchar](20) NOT NULL,
  [NivelRiesgoSistema] [varchar](20) NULL,
  [NivelRiesgoManual] [varchar](20) NULL,
  [ArchivoDictamenLocal] [varchar](200) NOT NULL,
  [ArchivoDictamenServidor] [varchar](200) NOT NULL,
  [FechaDictamen] [datetime] NULL,
  [FechaAlta] [datetime] NOT NULL,
  [CodUsuarioAlta] [varchar](20) NOT NULL,
  CONSTRAINT [PK_tCsPLDClasificacionRiesgoConsolidado] PRIMARY KEY CLUSTERED ([Periodo], [CodCliente])
)
ON [PRIMARY]
GO