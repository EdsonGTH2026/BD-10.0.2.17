CREATE TABLE [dbo].[tRhClObsMarcado] (
  [IdObservacion] [int] NOT NULL,
  [Observacion] [varchar](80) NULL,
  [EnviaMail] [bit] NULL CONSTRAINT [DF_tRhClObsMarcado_EnviaMail] DEFAULT (0),
  [MailAdm] [bit] NULL,
  [MailResp] [bit] NULL,
  [MailUsuario] [bit] NULL,
  [AlMarcar] [bit] NULL CONSTRAINT [DF_tRhClObsMarcado_AlMarcar] DEFAULT (0),
  CONSTRAINT [PK_tRhClObsMarcado] PRIMARY KEY CLUSTERED ([IdObservacion])
)
ON [PRIMARY]
GO