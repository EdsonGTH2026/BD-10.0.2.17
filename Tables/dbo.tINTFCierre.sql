CREATE TABLE [dbo].[tINTFCierre] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](253) NOT NULL,
  [EtiquetaSegmento] [varchar](4) NOT NULL,
  [TSaldosActuales] [int] NOT NULL,
  [TSaldosVencidos] [int] NOT NULL,
  [TSEncabezado] [int] NOT NULL,
  [TSNombre] [int] NOT NULL,
  [TSDireccion] [int] NOT NULL,
  [TSEmpleo] [int] NOT NULL,
  [TSCuenta] [int] NOT NULL,
  [Bloques] [int] NOT NULL,
  [NombreUsuario] [varchar](16) NOT NULL,
  [DomicilioDevolucion] [varchar](160) NOT NULL,
  CONSTRAINT [PK_tINTFCierre] PRIMARY KEY CLUSTERED ([Periodo], [Fila])
)
ON [PRIMARY]
GO