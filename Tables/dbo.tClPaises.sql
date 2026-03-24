CREATE TABLE [dbo].[tClPaises] (
  [CodPais] [varchar](4) NOT NULL,
  [Pais] [varchar](40) NULL,
  [Nacionalidad] [varchar](30) NULL,
  [Continente] [varchar](20) NULL,
  [Activo] [bit] NOT NULL,
  [INTF] [varchar](2) NULL,
  [SWIFT] [varchar](3) NULL,
  [Riesgo] [int] NULL,
  CONSTRAINT [PK_tClPaises] PRIMARY KEY CLUSTERED ([CodPais])
)
ON [PRIMARY]
GO