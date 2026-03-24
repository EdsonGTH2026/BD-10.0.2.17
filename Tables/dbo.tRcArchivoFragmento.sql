CREATE TABLE [dbo].[tRcArchivoFragmento] (
  [ArchivoFragmento] [varchar](3) NOT NULL,
  [EstructuraArchivo] [varchar](2) NULL,
  [Orden] [int] NULL,
  [DatoRelacionador] [bit] NULL,
  [Requerido] [bit] NULL,
  [Etiqueta] [varchar](50) NULL,
  [UsarEtiqueta] [bit] NULL,
  [Nombre] [varchar](50) NULL,
  [Tamaño] [int] NULL,
  [UsarTamaño] [bit] NULL,
  [FormatoTamaño] [char](1) NULL,
  [LongitudTamaño] [int] NULL,
  [RellenoTamaño] [char](1) NULL,
  [AlineadoTamaño] [char](1) NULL,
  [Descripcion] [varchar](100) NULL,
  [TipoDato] [char](1) NULL,
  [ValorDefecto] [varchar](100) NULL,
  [CampoDato] [varchar](50) NULL,
  [Ascii1] [int] NULL,
  [Ascii2] [int] NULL,
  [EsCorrelativo] [bit] NULL,
  [Rellenado] [bit] NULL,
  [CaracterRelleno] [char](1) NULL,
  [Alineado] [char](1) NULL,
  [MantenerTilde] [bit] NULL,
  [CaracterÑ] [varchar](50) NULL,
  [CInicio] [varchar](100) NULL,
  [CFin] [varchar](100) NULL,
  CONSTRAINT [PK_tRcArchivoFragmento] PRIMARY KEY CLUSTERED ([ArchivoFragmento])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tRcArchivoFragmento] WITH NOCHECK
  ADD CONSTRAINT [FK_tRcArchivoFragmento_tRcEstructuraArchivo] FOREIGN KEY ([EstructuraArchivo]) REFERENCES [dbo].[tRcEstructuraArchivo] ([EstructuraArchivo])
GO