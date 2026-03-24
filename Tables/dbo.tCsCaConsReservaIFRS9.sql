CREATE TABLE [dbo].[tCsCaConsReservaIFRS9] (
  [fecha] [smalldatetime] NOT NULL,
  [codusuario] [varchar](15) NOT NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [CodProducto] [int] NULL,
  [TipoCredito] [varchar](30) NULL,
  [nrodiasatraso] [int] NOT NULL,
  [tiporeprog] [varchar](5) NOT NULL,
  [MontoGarLiq] [decimal](16, 6) NOT NULL,
  [EtapaCredito] [varchar](30) NULL,
  [IngresoTerceraEtapa] [varchar](30) NULL,
  [MesesTerceraEtapa] [int] NULL,
  [SaldoCalificacion] [decimal](16, 6) NOT NULL,
  [ParteCubierta] [decimal](16, 6) NOT NULL,
  [ParteExpuesta] [decimal](16, 6) NOT NULL,
  [PorcParteCubierta] [decimal](16, 6) NOT NULL,
  [PorcParteExpuesta] [decimal](16, 6) NOT NULL,
  [EPRC_ParteCubierta] [decimal](16, 6) NOT NULL,
  [EPRC_ParteExpuesta] [decimal](16, 6) NOT NULL,
  [EPRC_InteresesTerceraEtapa] [decimal](16, 6) NOT NULL,
  [EPRC_TOTAL] AS (([EPRC_ParteCubierta]+[EPRC_ParteExpuesta])+[EPRC_InteresesTerceraEtapa]),
  CONSTRAINT [PK_tCsCaConsReservaIFRS9] PRIMARY KEY CLUSTERED ([fecha], [codprestamo], [codusuario]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsCaConsReservaIFRS9] TO [rie_jalvarezc]
GO