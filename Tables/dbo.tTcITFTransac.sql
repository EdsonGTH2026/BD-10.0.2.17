CREATE TABLE [dbo].[tTcITFTransac] (
  [IdTrans] [int] NOT NULL,
  [FechaTrans] [datetime] NULL,
  [CodOficina] [varchar](4) NULL,
  [CodMoneda] [varchar](2) NULL,
  [CodSistemaEn] [char](2) NULL,
  [idTipoOperEn] [varchar](5) NULL,
  [CodFormaTransEn] [smallint] NULL,
  [ITFCliente] [money] NOT NULL,
  [ITFEmpresa] [money] NOT NULL,
  [TransRef] [varchar](25) NULL,
  [Glosa] [varchar](250) NULL,
  [CodUsAutoriza] [char](15) NULL,
  [CodIndice] [varchar](2) NULL,
  [MontoTransac] [money] NULL,
  [IdEstadoExtorno] [int] NULL,
  [CodCuenta] [varchar](25) NULL,
  [IdTipoOperOri] [varchar](5) NULL,
  [CodImpuesto] [varchar](8) NOT NULL
)
ON [PRIMARY]
GO