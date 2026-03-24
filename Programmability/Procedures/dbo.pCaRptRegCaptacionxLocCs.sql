SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCaRptRegCaptacionxLocCs](
		 @Fecha as smalldatetime
		 )

with encryption
AS
set nocount on 

declare @curDepoVis as money
declare @intDepoVisNro as int
declare @curDepoAho as money
declare @intDepoAhoNro as int
declare @curDepoRet as money 
declare @intDepoRetNro as int
declare @curPresBanMul as money
declare @intPresBanMulNro as int
declare @curPresBanDes as money
declare @intPresBanDesNro as int
declare @curPresBanExt as money
declare @intPresBanExtNro as int
declare @curPresFide as money
declare @intPresFideNro as int
declare @curPresLiq as money
declare @intPresLiqNro as int
declare @curPresOtro as money
declare @intPresOtroNro as int

declare @PresBanNumTot As int
declare @PresBanTot As money
declare @DepoPlazNumTot As int
declare @DepoPlazTot As money
declare @DepoExInmNumTot As int
declare @DepoExInmTot As money

	------------------- VISTA -----------------------
	exec pCoObtieneSaldosyNroCs @Fecha,1,'',@curDepoVis out , @intDepoVisNro out 
	------------------- AHORROS -----------------------
	exec pCoObtieneSaldosyNroCs @Fecha,2,'',@curDepoAho out ,@intDepoAhoNro out 
	------------------- RET -----------------------
	exec pCoObtieneSaldosyNroCs @Fecha,3,'',@curDepoRet out ,@intDepoRetNro out 
	------------------ FINANCIAMIENTO -----------------
	exec pCoObtieneSaldosyNroCs @Fecha,4,'001',@curPresBanMul out ,@intPresBanMulNro out 
	exec pCoObtieneSaldosyNroCs @Fecha,4,'002',@curPresBanDes out ,@intPresBanDesNro out 
	exec pCoObtieneSaldosyNroCs @Fecha,4,'003',@curPresBanExt out ,@intPresBanExtNro  out 
	exec pCoObtieneSaldosyNroCs @Fecha,4,'004',@curPresFide out ,@intPresFideNro out 
	exec pCoObtieneSaldosyNroCs @Fecha,4,'005',@curPresLiq out ,@intPresLiqNro out 
	exec pCoObtieneSaldosyNroCs @Fecha,4,'006',@curPresOtro out ,@intPresOtroNro out 
	---------------------------------------------------	
	
	set @PresBanNumTot = @intPresBanMulNro + @intPresBanDesNro + @intPresBanExtNro + @intPresFideNro
                             + @intPresLiqNro + @intPresOtroNro
        set @PresBanTot = @curPresBanMul + @curPresBanDes + @curPresBanExt + @curPresFide
                          + @curPresLiq + @curPresOtro
        set @DepoPlazNumTot = @intDepoRetNro
        set @DepoPlazTot = @curDepoRet
        set @DepoExInmNumTot = @intDepoVisNro + @intDepoAhoNro
        set @DepoExInmTot = @curDepoVis + @curDepoAho

	select isnull(@PresBanNumTot,0) As PresBanNumTot, isnull(@PresBanTot,0) As PresBanTot, 
               isnull(@DepoPlazNumTot,0) As DepoPlazNumTot, isnull(@DepoPlazTot,0) As DepoPlazTot, 
               isnull(@DepoExInmNumTot,0) As DepoExInmNumTot, isnull(@DepoExInmTot,0) As DepoExInmTot

GO