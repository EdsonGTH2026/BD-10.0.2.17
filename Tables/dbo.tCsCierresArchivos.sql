CREATE TABLE [dbo].[tCsCierresArchivos] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Tabla] [varchar](50) NOT NULL,
  [Registros] [int] NULL,
  [Observacion] [varchar](100) NULL,
  CONSTRAINT [PK_tCsArchivosCierre] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [Tabla])
)
ON [PRIMARY]
GO