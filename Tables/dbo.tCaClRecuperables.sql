CREATE TABLE [dbo].[tCaClRecuperables] (
  [TipoOp] [varchar](5) NOT NULL,
  [Descripcion] [varchar](30) NULL,
  [NroVeces] [smallint] NULL,
  [PorCuota] [bit] NULL,
  [PorTotal] [bit] NULL,
  [Estado] [varchar](15) NULL,
  [ExpConceptos] [char](6) NULL,
  [EsRecuperable] [bit] NULL,
  [TasaInteres] [bit] NOT NULL,
  [TasaIntDe] [money] NOT NULL,
  [TasaIntA] [money] NOT NULL
)
ON [PRIMARY]
GO