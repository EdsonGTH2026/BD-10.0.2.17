SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pRieCredNoPagadosDia_SMS] @diaminimo int,@diamaximo int,@mensaje varchar(150)
as
	exec [10.0.2.14].finmas.dbo.pCoCANoPagosDiaProgramado_SMS @diaminimo,@diamaximo,@mensaje
GO

GRANT EXECUTE ON [dbo].[pRieCredNoPagadosDia_SMS] TO [jmartinezc]
GO

GRANT EXECUTE ON [dbo].[pRieCredNoPagadosDia_SMS] TO [ayescasc]
GO