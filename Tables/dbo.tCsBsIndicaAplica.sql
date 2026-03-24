CREATE TABLE [dbo].[tCsBsIndicaAplica] (
  [iCodTipoBS] [int] NOT NULL,
  [Descripcion] [varchar](50) NULL,
  [OrigenDatos] [varchar](200) NULL,
  [Fecha] [smalldatetime] NULL,
  [ConDetalle] [bit] NULL,
  [NCampo] [varchar](50) NULL,
  [ScriptDatos] [varchar](8000) NULL,
  [NDescrip] [varchar](50) NULL,
  [icodtipodsori] [int] NULL,
  CONSTRAINT [PK_tCsBsxTipo] PRIMARY KEY CLUSTERED ([iCodTipoBS])
)
ON [PRIMARY]
GO