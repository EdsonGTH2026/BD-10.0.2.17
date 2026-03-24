CREATE TABLE [dbo].[tSgSistemas] (
  [CodSistema] [char](2) NOT NULL,
  [Nombre] [varchar](30) NULL,
  [Descripcion] [varchar](80) NULL,
  [UltVerMayor] [smallint] NULL,
  [UltVerMenor] [smallint] NULL,
  [UltVerRevision] [smallint] NULL,
  [FechaUltAct] [smalldatetime] NULL,
  [FechaReg] [smalldatetime] NULL,
  [Activo] [bit] NULL,
  [FechaInactivo] [smalldatetime] NULL,
  CONSTRAINT [PK_tSgSistemas] PRIMARY KEY CLUSTERED ([CodSistema])
)
ON [PRIMARY]
GO