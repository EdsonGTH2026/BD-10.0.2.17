SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[sp_MSupd_tSgCmColaSMS] 
 @c1 int,@c2 varchar(5),@c3 varchar(1000),@c4 smalldatetime,@c5 datetime,@c6 int,@c7 varchar(8000),@c8 varchar(50),@c9 int,@c10 smalldatetime,@c11 datetime,@c12 varchar(500),@pkc1 int
,@bitmap binary(2)
as
if substring(@bitmap,1,1) & 1 = 1
begin
update "dbo"."tSgCmColaSMS" set
"idcola" = case substring(@bitmap,1,1) & 1 when 1 then @c1 else "idcola" end
,"CodSistema" = case substring(@bitmap,1,1) & 2 when 2 then @c2 else "CodSistema" end
,"NroCelular" = case substring(@bitmap,1,1) & 4 when 4 then @c3 else "NroCelular" end
,"Fecha" = case substring(@bitmap,1,1) & 8 when 8 then @c4 else "Fecha" end
,"Hora" = case substring(@bitmap,1,1) & 16 when 16 then @c5 else "Hora" end
,"TipoMsj" = case substring(@bitmap,1,1) & 32 when 32 then @c6 else "TipoMsj" end
,"Mensaje" = case substring(@bitmap,1,1) & 64 when 64 then @c7 else "Mensaje" end
,"IdRespuesta" = case substring(@bitmap,1,1) & 128 when 128 then @c8 else "IdRespuesta" end
,"IdRespuestaNeg" = case substring(@bitmap,2,1) & 1 when 1 then @c9 else "IdRespuestaNeg" end
,"FechaEnv" = case substring(@bitmap,2,1) & 2 when 2 then @c10 else "FechaEnv" end
,"HoraEnv" = case substring(@bitmap,2,1) & 4 when 4 then @c11 else "HoraEnv" end
,"DescripcionErr" = case substring(@bitmap,2,1) & 8 when 8 then @c12 else "DescripcionErr" end
where "idcola" = @pkc1
if @@rowcount = 0
	if @@microsoftversion>0x07320000
		exec sp_MSreplraiserror 20598
end
else
begin
update "dbo"."tSgCmColaSMS" set
"CodSistema" = case substring(@bitmap,1,1) & 2 when 2 then @c2 else "CodSistema" end
,"NroCelular" = case substring(@bitmap,1,1) & 4 when 4 then @c3 else "NroCelular" end
,"Fecha" = case substring(@bitmap,1,1) & 8 when 8 then @c4 else "Fecha" end
,"Hora" = case substring(@bitmap,1,1) & 16 when 16 then @c5 else "Hora" end
,"TipoMsj" = case substring(@bitmap,1,1) & 32 when 32 then @c6 else "TipoMsj" end
,"Mensaje" = case substring(@bitmap,1,1) & 64 when 64 then @c7 else "Mensaje" end
,"IdRespuesta" = case substring(@bitmap,1,1) & 128 when 128 then @c8 else "IdRespuesta" end
,"IdRespuestaNeg" = case substring(@bitmap,2,1) & 1 when 1 then @c9 else "IdRespuestaNeg" end
,"FechaEnv" = case substring(@bitmap,2,1) & 2 when 2 then @c10 else "FechaEnv" end
,"HoraEnv" = case substring(@bitmap,2,1) & 4 when 4 then @c11 else "HoraEnv" end
,"DescripcionErr" = case substring(@bitmap,2,1) & 8 when 8 then @c12 else "DescripcionErr" end
where "idcola" = @pkc1
if @@rowcount = 0
	if @@microsoftversion>0x07320000
		exec sp_MSreplraiserror 20598
end
GO