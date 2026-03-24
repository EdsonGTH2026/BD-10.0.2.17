CREATE TABLE [dbo].[tClPeriodo] (
  [Periodo] [varchar](6) NOT NULL,
  [Año] AS (convert(float,substring([periodo],1,4))),
  [Mes] AS (convert(float,substring([periodo],5,2))),
  [Descripcion] AS (rtrim(ltrim(([dbo].[fdunombremes](convert(float,substring([periodo],5,2))) + replicate(' ',(12 - len([dbo].[fdunombremes](convert(float,substring([periodo],5,2)))))) + substring([periodo],1,4))))),
  [Empresa] [varchar](11) NULL,
  [EstaCerrado] [bit] NULL CONSTRAINT [DF_tClPeriodo_EstaCerrado] DEFAULT (0),
  [FechaCierre] [smalldatetime] NULL,
  [PrimerDia] AS ([dbo].[fduPrimerDia]([periodo])),
  [UltimoDia] AS ([dbo].[fduUltimoDia]([periodo])),
  [UltimoDiaTexto] AS ([dbo].[fduUltimoDiatexto]([periodo])),
  [Registro] [char](3) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tClPeriodo] PRIMARY KEY CLUSTERED ([Periodo])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tClPeriodo] TO [marista]
GO

GRANT SELECT ON [dbo].[tClPeriodo] TO [public]
GO