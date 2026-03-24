CREATE TABLE [dbo].[tCsAHorarioAperturaCierreCajas] (
  [fecha] [smalldatetime] NULL,
  [codoficina] [varchar](4) NOT NULL,
  [bov_encargado] [varchar](200) NULL,
  [bov_apertura] [varchar](30) NULL,
  [bov_cierre] [varchar](30) NULL,
  [caj_Apertura] [varchar](30) NULL,
  [caj_Cierre] [varchar](30) NULL,
  [cajera_apertura] [varchar](200) NULL,
  [cajera_cierre] [varchar](200) NULL,
  [horatrans] [varchar](30) NOT NULL,
  [observaciones] [varchar](300) NOT NULL
)
ON [PRIMARY]
GO