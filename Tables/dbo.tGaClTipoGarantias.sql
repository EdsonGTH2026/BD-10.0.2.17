CREATE TABLE [dbo].[tGaClTipoGarantias] (
  [TipoGarantia] [varchar](5) NOT NULL,
  [GrupoTipoGar] [varchar](6) NULL,
  [NemGarantia] [varchar](200) NULL,
  [DescGarantia] [varchar](200) NULL,
  [TieneSeguro] [bit] NOT NULL,
  [TieneAvaluo] [bit] NOT NULL,
  [CodTipoAvaluo] [int] NOT NULL,
  [TieneReemplazo] [bit] NOT NULL,
  [Tipo] [varchar](50) NULL,
  [Activo] [bit] NOT NULL,
  CONSTRAINT [PK_tGaClTipoGarantias] PRIMARY KEY CLUSTERED ([TipoGarantia])
)
ON [PRIMARY]
GO