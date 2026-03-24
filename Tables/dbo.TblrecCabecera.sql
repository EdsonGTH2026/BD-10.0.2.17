CREATE TABLE [dbo].[TblrecCabecera] (
  [Representa] [varchar](17) NOT NULL,
  [Fila] [int] IDENTITY,
  [ClaveUsuario] [varchar](1006) NULL,
  [NombreUsuario] [varchar](50) NULL,
  [FechaReporte] [varchar](50) NULL,
  [Corte] [smalldatetime] NOT NULL,
  [Periodo] [varchar](6) NULL,
  [Abreviatura] [varchar](16) NULL,
  [Direccion] [varchar](100) NULL
)
ON [PRIMARY]
GO