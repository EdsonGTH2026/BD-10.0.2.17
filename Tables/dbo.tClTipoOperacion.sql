CREATE TABLE [dbo].[tClTipoOperacion] (
  [idTipoOper] [varchar](5) NOT NULL,
  [CodSistema] [char](2) NULL,
  [Nemotecnico] [varchar](50) NULL,
  [Descripcion] [varchar](50) NULL,
  [idEstado] [char](2) NULL
)
ON [PRIMARY]
GO