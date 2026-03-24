SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pLDDictaminaEventovs2] @id int,@tipo varchar(30),@CodUsuario varchar(25),@CodSolicitud varchar(20),@CodOficina varchar(3),@DescripcionAlerta varchar(500)
									,@FechaDictamen smalldatetime,@ReportaAComision char(2),@FechaReporteComision smalldatetime,@CodUsuarioAlta varchar(25)
									,@Coincidencia varchar(20),@ProcedeOperacionInusual varchar(2),@Dictamen varchar(1000),@VoBo tinyint
as
	exec [10.0.2.14].FinamigoPLD.dbo.pLDDictaminaEventovs2 @id,@tipo,@CodUsuario,@CodSolicitud,@CodOficina,@DescripcionAlerta,@FechaDictamen,@ReportaAComision
													,@FechaReporteComision,@CodUsuarioAlta,@Coincidencia,@ProcedeOperacionInusual,@Dictamen,@VoBo
GO