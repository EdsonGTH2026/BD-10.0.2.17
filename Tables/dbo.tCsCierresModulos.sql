CREATE TABLE [dbo].[tCsCierresModulos] (
  [Consolidacion] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Modulo] [varchar](50) NOT NULL,
  [Verificador] [varchar](100) NULL,
  CONSTRAINT [PK_tCsCierresModulos] PRIMARY KEY CLUSTERED ([Consolidacion], [CodOficina], [Modulo])
)
ON [PRIMARY]
GO