CREATE TABLE [dbo].[tCsCierres] (
  [Fecha] [smalldatetime] NOT NULL,
  [Cargado] [bit] NULL,
  [Cerrado] [bit] NULL,
  [Responsable] [varchar](50) NULL,
  [SelloElectronico] [varchar](100) NULL,
  CONSTRAINT [PK_tCsCierres] PRIMARY KEY CLUSTERED ([Fecha])
)
ON [PRIMARY]
GO