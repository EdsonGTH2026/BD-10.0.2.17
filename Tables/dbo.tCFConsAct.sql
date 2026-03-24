CREATE TABLE [dbo].[tCFConsAct] (
  [idCons] [int] NOT NULL CONSTRAINT [DF_tCFConsAct_idCons] DEFAULT (0),
  [CodActDet] [varchar](6) NOT NULL,
  [Servidor] [varchar](50) NOT NULL CONSTRAINT [DF_tCFConsAct_Servidor] DEFAULT (''),
  [BaseDatos] [varchar](50) NOT NULL CONSTRAINT [DF_tCFConsAct_BaseDatos] DEFAULT (''),
  [FAct] [smalldatetime] NULL,
  [Estado] [varchar](15) NOT NULL CONSTRAINT [DF_tCFConsAct_Estado] DEFAULT ('PENDIENTE'),
  [ResultadoExec] [varchar](4000) NOT NULL CONSTRAINT [DF_tCFConsAct_ResultadoExec] DEFAULT (''),
  CONSTRAINT [PK_tCFConsAct] PRIMARY KEY CLUSTERED ([idCons], [CodActDet], [Servidor], [BaseDatos])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCFConsAct] WITH NOCHECK
  ADD CONSTRAINT [FK_tCFConsAct_tCFConsPrjDet] FOREIGN KEY ([idCons], [CodActDet]) REFERENCES [dbo].[tCFConsPrjDet] ([idCons], [CodActDet])
GO