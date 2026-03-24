CREATE TABLE [dbo].[tCsAArqueosRemotosCajas] (
  [CodOficina] [varchar](3) NOT NULL,
  [sucursal] [varchar](30) NULL,
  [Caja] [int] NOT NULL,
  [CodUsCaja] [varchar](15) NOT NULL,
  [usuario_caja] [varchar](120) NULL,
  [SaldoEnCaja] [money] NULL,
  [SaldoAuditoria] [money] NULL,
  [diferencia] [money] NULL,
  [FechaProgramacion] [datetime] NOT NULL,
  [FechaAuditoria] [datetime] NULL,
  [Estatus] [varchar](20) NOT NULL,
  [CodUsuarioAlta] [varchar](15) NOT NULL,
  [usuario_alta] [varchar](120) NULL,
  [Activa] [tinyint] NOT NULL,
  [Observaciones] [varchar](8000) NULL
)
ON [PRIMARY]
GO