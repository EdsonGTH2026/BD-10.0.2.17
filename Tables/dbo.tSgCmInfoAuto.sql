CREATE TABLE [dbo].[tSgCmInfoAuto] (
  [idcola] [int] NOT NULL,
  [baseini] [varchar](500) NULL,
  [tipop] [int] NULL CONSTRAINT [DF_tSgCmInfoAuto_tipop] DEFAULT (0),
  [pini1] [varchar](200) NULL,
  [store] [varchar](200) NULL,
  [psto1] [varchar](200) NULL,
  [psto2] [varchar](200) NULL,
  [psto3] [varchar](200) NULL,
  [sigla] [varchar](10) NULL,
  [Activo] [bit] NULL CONSTRAINT [DF_tSgCmInfoAuto_Activo] DEFAULT (1),
  [PerioEnvio] [varchar](15) NULL,
  CONSTRAINT [PK_tSgCmInfoAuto] PRIMARY KEY CLUSTERED ([idcola])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Sp inicial donde se sacaran los parametros', 'SCHEMA', N'dbo', 'TABLE', N'tSgCmInfoAuto', 'COLUMN', N'baseini'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0: ninguno; 1: valor fijo; 2: obtenido sp', 'SCHEMA', N'dbo', 'TABLE', N'tSgCmInfoAuto', 'COLUMN', N'tipop'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'parametro en texto', 'SCHEMA', N'dbo', 'TABLE', N'tSgCmInfoAuto', 'COLUMN', N'pini1'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'donde se aplica el bucle', 'SCHEMA', N'dbo', 'TABLE', N'tSgCmInfoAuto', 'COLUMN', N'store'
GO