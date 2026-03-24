CREATE TABLE [dbo].[TmpActualizaRiesgoMensual] (
  [sec] [int] IDENTITY,
  [codusuario] [varchar](15) NULL,
  [codoficina] [varchar](4) NULL,
  [idProducto] [int] NULL,
  [CodTPersona] [varchar](3) NULL,
  [FechaNacimiento] [smalldatetime] NULL,
  [Edad] [int] NULL,
  [MontoTotalTran] [money] NULL,
  [ACTUALIZADO] [int] NULL
)
ON [PRIMARY]
GO