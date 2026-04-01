CREATE TABLE [dbo].[tCsFirmaElectronica] (
  [Firma] [varchar](100) NOT NULL,
  [Version] [int] NULL,
  [Usuario] [varchar](50) NULL,
  [Registro] [datetime] NULL,
  [Sistema] [varchar](2) NULL,
  [Dato] [varchar](100) NULL,
  [Secuencia] [int] NULL,
  [Activo] [bit] NULL,
  [Motivo] [varchar](500) NULL
)
ON [PRIMARY]
GO