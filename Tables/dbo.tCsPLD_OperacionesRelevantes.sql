CREATE TABLE [dbo].[tCsPLD_OperacionesRelevantes] (
  [IdOperacionRelevante] [int] IDENTITY,
  [Tipo] [varchar](12) NOT NULL,
  [FechaInicial] [datetime] NOT NULL,
  [FechaFinal] [datetime] NOT NULL,
  [CodCliente] [varchar](20) NOT NULL,
  [CodCuenta] [varchar](20) NOT NULL,
  [CodOficina] [varchar](3) NOT NULL,
  [TipoCambio] [money] NOT NULL,
  [MontoLimite] [money] NOT NULL,
  [ArchivoDictamenLocal] [varchar](200) NOT NULL,
  [ArchivoDictamenServidor] [varchar](200) NOT NULL,
  [FechaDictamen] [datetime] NULL,
  [Reportar] [varchar](2) NOT NULL,
  [ArchivoAcuseLocal] [varchar](200) NULL,
  [ArchivoAcuseServidor] [varchar](200) NULL,
  [FechaAcuse] [datetime] NULL,
  [FechaAlta] [datetime] NOT NULL,
  [CodUsuarioAlta] [varchar](20) NOT NULL,
  CONSTRAINT [PK_tCsPLD_OperacionesRelevantes] PRIMARY KEY CLUSTERED ([IdOperacionRelevante])
)
ON [PRIMARY]
GO