CREATE TABLE [dbo].[tCsCarteraReservaFallecido] (
  [fecha] [smalldatetime] NOT NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [codusuario] [varchar](15) NOT NULL,
  [nrodiasatraso] [int] NOT NULL,
  [tiporeprog] [varchar](5) NOT NULL,
  [MontoGarLiq] [decimal](16, 6) NOT NULL,
  [SaldoCalificacion] [decimal](16, 6) NOT NULL,
  [ParteCubierta] [decimal](16, 6) NOT NULL,
  [ParteExpuesta] [decimal](16, 6) NOT NULL,
  [PorcParteCubierta] [decimal](16, 6) NOT NULL,
  [PorcParteExpuesta] [decimal](16, 6) NOT NULL,
  [EPRC_ParteCubierta] [decimal](16, 6) NOT NULL,
  [EPRC_ParteExpuesta] [decimal](16, 6) NOT NULL,
  [EPRC_InteresesVencidos] [decimal](16, 6) NOT NULL,
  [EPRC_TOTAL] AS ([EPRC_ParteCubierta] + [EPRC_ParteExpuesta] + [EPRC_InteresesVencidos]),
  CONSTRAINT [PK_tCsCarteraReservaFallecido] PRIMARY KEY CLUSTERED ([fecha], [codprestamo], [codusuario]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO