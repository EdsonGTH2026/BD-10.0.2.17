CREATE TABLE [dbo].[tTcClCortesMoneda] (
  [CodMoneda] [varchar](2) NOT NULL,
  [Tipo] [char](1) NOT NULL,
  [Corte] [money] NOT NULL,
  [Descripcion] [varchar](20) NULL,
  [Vigente] [bit] NOT NULL
)
ON [PRIMARY]
GO