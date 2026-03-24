CREATE TABLE [dbo].[tCsFirmaElectronica] (
  [Firma] [varchar](100) NOT NULL,
  [Version] [int] NULL,
  [Usuario] [varchar](50) NULL,
  [Registro] [datetime] NULL,
  [Sistema] [varchar](2) NULL,
  [Dato] [varchar](100) NULL,
  [Secuencia] [int] NULL,
  [Activo] [bit] NULL CONSTRAINT [DF_tCsFirmaElectronica_Activo] DEFAULT (0),
  [Motivo] [varchar](500) NULL,
  CONSTRAINT [PK_tCsFirmaElectronica] PRIMARY KEY CLUSTERED ([Firma])
)
ON [PRIMARY]
GO