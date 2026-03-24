CREATE TABLE [dbo].[tCsCaCartaPtmosEspeciales] (
  [codprestamo] [varchar](25) NOT NULL,
  [fecini] [smalldatetime] NOT NULL,
  [fecfin] [smalldatetime] NULL,
  [codpromotor] [varchar](15) NULL,
  CONSTRAINT [PK_tCsCaCartaPtmosEspeciales] PRIMARY KEY CLUSTERED ([codprestamo], [fecini])
)
ON [PRIMARY]
GO