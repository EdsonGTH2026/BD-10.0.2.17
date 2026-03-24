CREATE TABLE [dbo].[tCsPLD_OperacionesInusualesDetalle] (
  [IdOperacionDetalle] [int] IDENTITY,
  [IdOperacion] [int] NOT NULL,
  [NroTransaccion] [varchar](10) NOT NULL,
  [Tipo] [varchar](10) NOT NULL,
  [Fecha] [datetime] NOT NULL,
  [CodigoCuenta] [varchar](25) NOT NULL,
  [MontoTotalTran] [money] NOT NULL,
  [NomOficina] [varchar](100) NOT NULL,
  [DescripcionTran] [varchar](1000) NOT NULL,
  [FechaCreacion] [datetime] NOT NULL,
  [CodUsuarioCreacion] [varchar](15) NOT NULL,
  [Activo] [bit] NOT NULL,
  CONSTRAINT [PK_tCsPLD_OperacionesInusualesDetalle] PRIMARY KEY CLUSTERED ([IdOperacionDetalle])
)
ON [PRIMARY]
GO