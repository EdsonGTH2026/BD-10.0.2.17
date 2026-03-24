CREATE TABLE [dbo].[tSATRespuestas] (
  [Archivo] [varchar](50) NOT NULL,
  [Registro] [datetime] NULL,
  [RFC] [varchar](50) NOT NULL,
  [Estado] [char](1) NULL,
  CONSTRAINT [PK_tSATRespuestas] PRIMARY KEY CLUSTERED ([Archivo], [RFC])
)
ON [PRIMARY]
GO