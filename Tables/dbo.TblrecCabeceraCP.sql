CREATE TABLE [dbo].[TblrecCabeceraCP] (
  [Representa] [varchar](19) NOT NULL,
  [Fila] [int] IDENTITY,
  [ClaveUsuario] [varchar](1006) NULL,
  [NombreUsuario] [varchar](50) NULL,
  [FechaReporte] [varchar](50) NULL,
  [Corte] [smalldatetime] NOT NULL,
  [Periodo] [varchar](8) NULL,
  [Abreviatura] [varchar](16) NULL,
  [Direccion] [varchar](100) NULL
)
ON [PRIMARY]
GO