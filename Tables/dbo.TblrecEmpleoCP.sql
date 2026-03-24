CREATE TABLE [dbo].[TblrecEmpleoCP] (
  [Representa] [varchar](14) NOT NULL,
  [Fila] [int] IDENTITY,
  [tipo] [varchar](15) NOT NULL,
  [codusuario] [varchar](25) NOT NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [TipoEmpleo] [varchar](40) NOT NULL,
  [Empleador] [varchar](40) NOT NULL
)
ON [PRIMARY]
GO