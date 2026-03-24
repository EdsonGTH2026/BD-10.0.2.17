CREATE TABLE [dbo].[tCsBsIndicadores] (
  [iCodIndicador] [int] NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [NombreCampo] [varchar](50) NULL,
  CONSTRAINT [PK_tCsBsIndicadores] PRIMARY KEY CLUSTERED ([iCodIndicador])
)
ON [PRIMARY]
GO