CREATE TABLE [dbo].[tCsCFDI_log_error_cfdi] (
  [ID] [int] IDENTITY,
  [RFC] [varchar](13) NOT NULL,
  [Nombre] [varchar](70) NOT NULL,
  [CodUsuario] [varchar](50) NOT NULL,
  [Constancia_creada] [bit] NOT NULL,
  [Fecha_creacion] [datetime] NOT NULL,
  [Error] [nvarchar](4000) NULL
)
ON [PRIMARY]
GO