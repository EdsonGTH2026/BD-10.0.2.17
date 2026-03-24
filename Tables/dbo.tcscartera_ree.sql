CREATE TABLE [dbo].[tcscartera_ree] (
  [fecha] [datetime] NOT NULL,
  [codprestamo] [char](19) NOT NULL,
  [nrodiasatraso] [int] NULL,
  [intdev] [money] NULL,
  [pago] [tinyint] NULL,
  [capital] [money] NULL,
  [interes] [money] NULL,
  [ivainteres] [money] NULL
)
ON [PRIMARY]
GO