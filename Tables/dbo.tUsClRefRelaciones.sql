CREATE TABLE [dbo].[tUsClRefRelaciones] (
  [CodRefRelacion] [char](3) NOT NULL,
  [Relacion] [varchar](30) NULL,
  [Orden] [tinyint] NULL,
  [Activa] [bit] NOT NULL
)
ON [PRIMARY]
GO