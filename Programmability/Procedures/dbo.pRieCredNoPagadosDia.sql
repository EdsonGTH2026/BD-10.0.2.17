SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pRieCredNoPagadosDia] @diaminimo int,@diamaximo int
as
	exec [10.0.2.14].finmas.dbo.pCoCANoPagosDiaProgramado @diaminimo ,@diamaximo
GO

GRANT EXECUTE ON [dbo].[pRieCredNoPagadosDia] TO [jmartinezc]
GO

GRANT EXECUTE ON [dbo].[pRieCredNoPagadosDia] TO [ayescasc]
GO