CREATE TABLE [dbo].[tCmClEstados] (
  [CodEstado] [varchar](2) NOT NULL,
  [Estado] [varchar](30) NULL,
  [CodAnt] [char](1) NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NOT NULL
)
ON [PRIMARY]
GO