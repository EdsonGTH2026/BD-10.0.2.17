CREATE TABLE [dbo].[tSATExentasArchivo] (
  [Generado] [datetime] NOT NULL,
  [Consulta] [smallint] NOT NULL,
  [Empresa] [varchar](5) NOT NULL,
  [Corte] [smalldatetime] NOT NULL,
  [Archivo] [varchar](16) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [RFC] [varchar](13) NOT NULL,
  [Estado] [char](1) NULL,
  CONSTRAINT [PK_tSATExentas] PRIMARY KEY CLUSTERED ([Generado], [Consulta], [Empresa], [Corte], [Archivo], [CodUsuario], [RFC])
)
ON [PRIMARY]
GO