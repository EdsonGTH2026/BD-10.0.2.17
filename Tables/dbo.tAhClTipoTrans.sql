CREATE TABLE [dbo].[tAhClTipoTrans] (
  [idTipoTrans] [smallint] NOT NULL,
  [EsDebito] [bit] NOT NULL,
  [Descripcion] [varchar](50) NOT NULL,
  [NemoTecnico] [varchar](20) NOT NULL,
  [SeContabiliza] [bit] NULL,
  [idEstado] [char](2) NULL,
  [ContaCodigo] [varchar](25) NULL,
  [EnOperacion] [smallint] NULL,
  [EsComision] [bit] NULL,
  [EsExtornable] [bit] NULL,
  [IdTransExtorno] [smallint] NULL,
  CONSTRAINT [PK_tAhClTipoTrans] PRIMARY KEY CLUSTERED ([idTipoTrans])
)
ON [PRIMARY]
GO