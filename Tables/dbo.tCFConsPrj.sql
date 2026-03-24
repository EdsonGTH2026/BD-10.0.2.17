CREATE TABLE [dbo].[tCFConsPrj] (
  [idCons] [int] NOT NULL CONSTRAINT [DF_tCFConsPrj_idCons] DEFAULT (0),
  [CodAct] [varchar](25) NOT NULL CONSTRAINT [DF_tCFConsPrj_CodAct] DEFAULT (''),
  [Descrip] [varchar](200) NOT NULL CONSTRAINT [DF_tCFConsPrj_Descrip] DEFAULT (''),
  [EstadoGEN] [varchar](15) NOT NULL CONSTRAINT [DF_tCFConsPrj_Estado] DEFAULT ('ABIERTO'),
  [EstadoACT] [varchar](15) NOT NULL CONSTRAINT [DF_tCFConsPrj_EstadoACT] DEFAULT ('PENDIENTE'),
  [FApe] [smalldatetime] NULL,
  [FGen] [smalldatetime] NULL,
  [FPub] [smalldatetime] NULL,
  [FApl] [smalldatetime] NULL,
  [RespuestaEnviada] [bit] NOT NULL CONSTRAINT [DF_tCFConsPrj_RespuestaEnviada] DEFAULT (0),
  CONSTRAINT [PK_tCFConsPrj] PRIMARY KEY CLUSTERED ([idCons])
)
ON [PRIMARY]
GO