CREATE TABLE [dbo].[tCsACAReestructurasCCESegVs2] (
  [codoficina] [varchar](4) NOT NULL,
  [sucursal] [varchar](50) NULL,
  [region] [varchar](50) NOT NULL,
  [codprestamo] [char](19) NOT NULL,
  [cliente] [varchar](200) NULL,
  [CELULAR] [varchar](50) NULL,
  [promotor] [varchar](200) NULL,
  [F_REESTRUCTURA] [datetime] NULL,
  [F_VENCIMIENTO] [smalldatetime] NULL,
  [DIAS_MORA_REEST] [int] NULL,
  [CUOTAS_REEST] [smallint] NULL,
  [TIPO_PAGO] [char](1) NOT NULL,
  [DIA_DE_PAGO] [varchar](9) NOT NULL,
  [MONTO_CUOTA] [money] NULL,
  [SALDO_TOTAL_ACTUAL] [money] NULL,
  [F_ULTIMO_PAGO] [smalldatetime] NULL,
  [MONTO_ULTIMO_PAGO] [money] NULL,
  [F_PROXIMO_CORTE] [smalldatetime] NULL,
  [DIAS_MORA_ACTUAL] [smallint] NULL,
  [ESTATUS_CREDITO] [varchar](20) NOT NULL,
  [diasmora_inicio_mes] [int] NULL
)
ON [PRIMARY]
GO