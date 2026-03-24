CREATE TABLE [dbo].[tSgCmColaSMS] (
  [idcola] [int] NOT NULL,
  [CodSistema] [varchar](5) NULL,
  [NroCelular] [varchar](1000) NULL,
  [Fecha] [smalldatetime] NULL,
  [Hora] [datetime] NULL,
  [TipoMsj] [int] NULL CONSTRAINT [DF_tSgCmColaSMS_TipoMsj] DEFAULT (1),
  [Mensaje] [varchar](8000) NULL,
  [IdRespuesta] [varchar](50) NULL,
  [IdRespuestaNeg] [int] NULL,
  [FechaEnv] [smalldatetime] NULL,
  [HoraEnv] [datetime] NULL,
  [DescripcionErr] [varchar](500) NULL,
  CONSTRAINT [PK_tSgCmColaSMS_2] PRIMARY KEY CLUSTERED ([idcola])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1: Normal 2: Store Procedure', 'SCHEMA', N'dbo', 'TABLE', N'tSgCmColaSMS', 'COLUMN', N'TipoMsj'
GO