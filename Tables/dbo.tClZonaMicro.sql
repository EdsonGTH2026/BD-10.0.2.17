CREATE TABLE [dbo].[tClZonaMicro] (
  [CodMicro] [int] NOT NULL,
  [NombreMicro] [varchar](50) NULL,
  [Zona] [char](3) NOT NULL,
  [Responsable] [varchar](20) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tClZonaMicro] PRIMARY KEY CLUSTERED ([CodMicro])
)
ON [PRIMARY]
GO