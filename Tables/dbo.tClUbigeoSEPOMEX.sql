CREATE TABLE [dbo].[tClUbigeoSEPOMEX] (
  [Codubigeo] [varchar](1002) NULL,
  [CodUbigeoTipo] [varchar](4) NOT NULL,
  [NomUbigeo] [varchar](150) NULL,
  [DescUbigeo] [varchar](150) NULL,
  [Campo1] [varchar](10) NULL,
  [Campo2] [varchar](10) NULL,
  [Campo3] [varchar](67) NOT NULL,
  [CodarbolConta] [varchar](3007) NULL,
  [Codestado] [varchar](2) NOT NULL,
  [CodMunicipio] [varchar](3) NOT NULL,
  [IDLugar] [int] NOT NULL,
  [Observacion] [char](1) NOT NULL,
  [Activa] [int] NOT NULL,
  [Anterior] [char](1) NOT NULL,
  [ClaveSugerida] [char](1) NOT NULL
)
ON [PRIMARY]
GO