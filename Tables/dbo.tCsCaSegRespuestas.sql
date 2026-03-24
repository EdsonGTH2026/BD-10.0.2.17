CREATE TABLE [dbo].[tCsCaSegRespuestas] (
  [fecha] [smalldatetime] NOT NULL,
  [hora] [datetime] NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [Codigo] [int] NOT NULL,
  [NroEncuesta] [int] NOT NULL,
  [CodGrupo] [int] NOT NULL,
  [CodPregunta] [int] NOT NULL,
  [CodAlternativa] [int] NOT NULL,
  [Codprestamo] [varchar](20) NOT NULL,
  [Valor] [varchar](300) NULL,
  CONSTRAINT [PK_tCsCaSegRespuestas] PRIMARY KEY CLUSTERED ([fecha], [hora], [CodUsuario], [Codigo], [NroEncuesta], [CodGrupo], [CodPregunta], [CodAlternativa])
)
ON [PRIMARY]
GO