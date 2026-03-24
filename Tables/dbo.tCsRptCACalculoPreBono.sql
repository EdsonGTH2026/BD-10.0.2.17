CREATE TABLE [dbo].[tCsRptCACalculoPreBono] (
  [fecha] [smalldatetime] NULL,
  [codasesor] [varchar](25) NULL,
  [sucursal] [varchar](250) NULL,
  [nombrepromotor] [varchar](250) NULL,
  [puesto] [varchar](250) NULL,
  [O_CCBM] [money] NULL,
  [O_CAM] [money] NULL,
  [O_CER7] [money] NULL,
  [O_CER60] [money] NULL,
  [O_NCre60] [int] NULL,
  [A_CCBM] [money] NULL,
  [A_CAM] [money] NULL,
  [A_CER7] [money] NULL,
  [A_CER60] [money] NULL,
  [A_NCre60] [int] NULL,
  [nro60] [int] NULL,
  [saldo60] [money] NULL,
  [nro7a59] [int] NULL,
  [saldo7a59] [money] NULL,
  [nro1a6] [int] NULL,
  [saldo1a6] [money] NULL
)
ON [PRIMARY]
GO