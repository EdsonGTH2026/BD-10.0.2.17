CREATE TABLE [dbo].[tCsEnviosDelgadoArchivos] (
  [CodArchivo] [varchar](50) NOT NULL,
  [NomArchivo] [varchar](50) NULL,
  [TamArchivo] [int] NULL,
  [FechaHora] [datetime] NULL,
  [Atributos] [varchar](50) NULL,
  [CadDetalle] [varchar](200) NULL,
  CONSTRAINT [PK_tCsEnviosDelgadoArchivos] PRIMARY KEY CLUSTERED ([CodArchivo])
)
ON [PRIMARY]
GO