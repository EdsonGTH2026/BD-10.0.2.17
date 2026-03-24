CREATE TABLE [dbo].[tCsCierresMensajes] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [int] NOT NULL,
  [Mensaje] [varchar](892) NOT NULL,
  CONSTRAINT [PK_tCsCierresMensajes] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [Mensaje])
)
ON [PRIMARY]
GO