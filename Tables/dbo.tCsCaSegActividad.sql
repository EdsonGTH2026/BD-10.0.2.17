CREATE TABLE [dbo].[tCsCaSegActividad] (
  [codactividad] [int] NOT NULL,
  [descripcion] [varchar](200) NULL,
  [estado] [char](1) NULL CONSTRAINT [DF_tCsCaSegActividad_estado] DEFAULT (1),
  CONSTRAINT [PK_tCsCaSegActividad] PRIMARY KEY CLUSTERED ([codactividad])
)
ON [PRIMARY]
GO