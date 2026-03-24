CREATE TABLE [dbo].[tSgAutorizaciones] (
  [CodAutoriza] [char](6) NOT NULL,
  [DescAutoriza] [varchar](50) NULL,
  [CodSistema] [char](2) NULL,
  [NivelAutoriza] [char](1) NULL,
  [TipoAutoriza] [char](1) NULL,
  [CodUsAutoriza] [varchar](15) NULL,
  [CodComite] [char](5) NULL,
  [Campo1Desc] [varchar](30) NULL,
  [Campo1Tipo] [char](1) NULL,
  [Campo2Desc] [varchar](30) NULL,
  [Campo2Tipo] [char](1) NULL,
  [CorreoInforma] [varchar](200) NULL,
  [Activa] [bit] NOT NULL
)
ON [PRIMARY]
GO