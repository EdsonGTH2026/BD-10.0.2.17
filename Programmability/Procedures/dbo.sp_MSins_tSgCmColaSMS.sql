SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[sp_MSins_tSgCmColaSMS] @c1 int,@c2 varchar(5),@c3 varchar(1000),@c4 smalldatetime,@c5 datetime,@c6 int,@c7 varchar(8000),@c8 varchar(50),@c9 int,@c10 smalldatetime,@c11 datetime,@c12 varchar(500)

AS
BEGIN


insert into "dbo"."tSgCmColaSMS"( 
"idcola", "CodSistema", "NroCelular", "Fecha", "Hora", "TipoMsj", "Mensaje", "IdRespuesta", "IdRespuestaNeg", "FechaEnv", "HoraEnv", "DescripcionErr"
 )

values ( 
@c1, @c2, @c3, @c4, @c5, @c6, @c7, @c8, @c9, @c10, @c11, @c12
 )


END
GO