CREATE TABLE [dbo].[tTcBovPlaniArqueo] (
  [IdPlaniArqueo] [int] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [FechaPro] [smalldatetime] NOT NULL,
  [NumBovTrans] [int] NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [Tipo] [char](1) NOT NULL,
  [Corte] [money] NOT NULL,
  [Cantidad] [int] NULL,
  [EsEntradaBoveda] [bit] NOT NULL,
  [EsCierreCaja] [bit] NOT NULL,
  [Anulada] [bit] NOT NULL
)
ON [PRIMARY]
GO