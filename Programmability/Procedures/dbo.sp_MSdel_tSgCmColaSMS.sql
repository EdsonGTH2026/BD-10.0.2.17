SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[sp_MSdel_tSgCmColaSMS] @pkc1 int
as
delete "dbo"."tSgCmColaSMS"
where "idcola" = @pkc1
if @@rowcount = 0
	if @@microsoftversion>0x07320000
		exec sp_MSreplraiserror 20598
GO