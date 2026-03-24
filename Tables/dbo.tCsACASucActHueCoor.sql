CREATE TABLE [dbo].[tCsACASucActHueCoor] (
  [fecha] [smalldatetime] NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](30) NULL,
  [codusuario] [varchar](15) NULL,
  [coordinador] [varchar](300) NULL,
  [ingreso] [smalldatetime] NULL,
  [montocolocado] [money] NULL,
  [SaldoCapital] [money] NULL,
  [nrototal] [int] NULL,
  [VigenteSaldoHuerfano] [money] NULL,
  [VigenteSaldoActivo] [money] NULL,
  [VigenteNroHuerfano] [int] NULL,
  [VigenteNroActivo] [int] NULL,
  [VencidoSaldoHuerfano] [money] NULL,
  [VencidoSaldoActivo] [money] NULL,
  [VencidoNroHuerfano] [int] NULL,
  [VencidoNroActivo] [int] NULL,
  [CastigadoSaldoHuerfano] [money] NULL,
  [CastigadoSaldoActivo] [money] NULL,
  [CastigadoNroHuerfano] [int] NULL,
  [CastigadoNroActivo] [int] NULL,
  [ReasignadoVigente] [money] NULL,
  [ReasignadoVencido] [money] NULL,
  [ReasignadoNroVigente] [int] NULL,
  [ReasignadoNroVencido] [int] NULL
)
ON [PRIMARY]
GO