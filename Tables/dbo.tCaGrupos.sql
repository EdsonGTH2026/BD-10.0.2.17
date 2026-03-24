CREATE TABLE [dbo].[tCaGrupos] (
  [CodGrupo] [char](15) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [NombreGrupo] [varchar](50) NOT NULL,
  [FechaCreaGru] [smalldatetime] NOT NULL,
  [SecPrestamo] [int] NULL,
  [CodEstado] [varchar](10) NULL,
  [UltPrestamo] [varchar](25) NULL,
  [CodMoneda] [varchar](2) NULL,
  [MontoSolicita] [money] NULL,
  [CuotaPrestamo] [money] NULL,
  [FechaDesemb] [smalldatetime] NULL,
  [AtrUltPrest] [int] NULL,
  [AtrMaxUltPre] [int] NULL,
  [AtrAcuGrupo] [int] NULL,
  [AtrMaxGrupo] [int] NULL,
  [EstadoGrupo] [varchar](10) NULL,
  [CodAsesor] [varchar](15) NULL,
  [CodProducto] [char](3) NULL,
  [CuentaGru] [varchar](25) NULL CONSTRAINT [DF_tCaGrupos_CuentaGru] DEFAULT (''),
  [Telefono] [varchar](50) NULL CONSTRAINT [DF_tCaGrupos_Telefono] DEFAULT (''),
  [Direccion] [varchar](60) NULL CONSTRAINT [DF_tCaGrupos_Direccion] DEFAULT (''),
  [CodigoPostal] [char](15) NULL CONSTRAINT [DF_tCaGrupos_CodigoPostal] DEFAULT (''),
  [CodUbiGeo] [varchar](6) NULL CONSTRAINT [DF_tCaGrupos_CodUbiGeo] DEFAULT (''),
  [CodAnteriorGrupo] [int] NULL CONSTRAINT [DF_tCaGrupos_CodAnteriorGrupo] DEFAULT (0),
  [Centralizado] [bit] NULL CONSTRAINT [DF_tCaGrupos_Centralizado] DEFAULT (0),
  CONSTRAINT [PK_tCaGrupos] PRIMARY KEY CLUSTERED ([CodGrupo])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaGrupos] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaGrupos_tClOficinas] FOREIGN KEY ([CodOficina]) REFERENCES [dbo].[tClOficinas] ([CodOficina])
GO