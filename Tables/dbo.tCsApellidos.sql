CREATE TABLE [dbo].[tCsApellidos] (
  [Apellido] [varchar](50) NOT NULL,
  [Extraño] [bit] NULL,
  [Verificado] [bit] NULL CONSTRAINT [DF_tCsApellidos_Verificado] DEFAULT (0),
  [CodOficina] [varchar](4) NULL,
  [Registro] [smalldatetime] NULL,
  [Referencia] [varchar](100) NULL,
  [Cantidad] [int] NULL,
  CONSTRAINT [PK_tCsApellidos] PRIMARY KEY CLUSTERED ([Apellido])
)
ON [PRIMARY]
GO