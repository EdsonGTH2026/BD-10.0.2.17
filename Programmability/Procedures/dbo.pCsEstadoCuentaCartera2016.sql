SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsEstadoCuentaCartera2016]  
    @CodPrestamo char(19),  
    @FechaIni datetime,  
    @FechaCorte datetime  
AS  
  
/*  
    Noel Paricollo - 2016 10 06  
    CUM 11.2020  
*/    
--declare    @CodPrestamo char(19)  
--declare    @FechaIni datetime  
--declare    @FechaCorte datetime  
--set @CodPrestamo='008-170-06-08-06287'  
--set @FechaIni='20221206'  
--set @FechaCorte='20230301'  

  
  
declare    @FechaIni2 smalldatetime  
declare    @FechaCorte2 smalldatetime  
set @FechaIni2 = @FechaIni--'2022/12/06'  
set @FechaCorte2 = @FechaCorte---'2023/03/01'  

  
SET NOCOUNT ON  
  
create table #Pagos(  
 CodPrestamo varchar(20),  
 FechaPago datetime,  
 CodOficina varchar(3),  
 SecPago int,  
 SecCuota tinyint,  
 CodConcepto varchar(10),  
 MontoPagado money,  
 OrdenAfecta tinyint  
)  
insert into #Pagos  
exec [10.0.2.14].finmas.dbo.pCsCaEstadoCuentaTx @CodPrestamo,@FechaIni2,@FechaCorte2  
/*  
select R.CodPrestamo, R.FechaPago, R.CodOficina, R.SecPago, D.SecCuota, D.CodConcepto, D.MontoPagado, -- A.OrdenAfecta  
isnull(A.OrdenAfecta,0) as OrdenAfecta --OSC  
into #Pagos  
from [10.0.2.14].Finmas.dbo.tCaPagoReg R   
inner join [10.0.2.14].Finmas.dbo.tCaPagoDet D on R.CodOficina = D.CodOficina and R.SecPago = D.SecPago  
--inner join [10.0.2.14].Finmas.dbo.tCaPrestamoConceptoAplica A on R.CodPrestamo = A.CodPrestamo and D.CodConcepto = A.CodConcepto --OSC  
left join [10.0.2.14].Finmas.dbo.tCaPrestamoConceptoAplica A on R.CodPrestamo = A.CodPrestamo and D.CodConcepto = A.CodConcepto  
where R.CodPrestamo = @CodPrestamo  
and R.FechaPago between @FechaIni2 and @FechaCorte2 and R.Extornado = 0  
*/  
  
--declare @Comisiones smallmoney  
--select @Comisiones = sum(MontoDevengado)  
--from tCaPagoReg R  
--inner join tCaPagoDet D on R.CodOficina = D.CodOficina and R.SecPago = D.SecPago  
--where CodPrestamo = @CodPrestamo  
--and R.FechaPago between @FechaIni2 and @FechaCorte2 and D.CodConcepto = 'PAGTA'  
  
/*  
 select dbo.fduCATPrestamo(3, 6000, 7 * 24 / 30., 114,0)  
 select dbo.fduCATPrestamo(3, 6000, 5.6, 114/12,0)  
*/ 

select * 
into #TmpCartera
from tCsCartera with(nolock)
where codprestamo = @CodPrestamo    


declare @UltimaFechaCartera smalldatetime  
if exists (select 1 from #TmpCartera with(nolock) where fecha = @FechaCorte2 and codprestamo = @Codprestamo)  
    set @UltimaFechaCartera = @FechaCorte2  
else  
    select @UltimaFechaCartera = max(Fecha) from #TmpCartera with(nolock) where codprestamo = @Codprestamo  

declare @cat float
set @cat= dbo.fdu_CAT(@CodPrestamo) 
--select @cat

-----select @UltimaFechaCartera
select P.CodPrestamo, L.NombreCompleto, PR.NombreProd, CAT = @cat---dbo.fdu_CAT(P.CodPrestamo) 
       ,Direccion = L.DireccionDirFamPri + ', ' + NumExtFam + ', ' + NumIntFam + ', ' + GC.DescUbiGeo + ', ' + GM.DescUbiGeo + ', ' + GE.DescUbiGeo + ', C.P.' + CodPostalFam,  
       Oficina = O.NomOficina, FechaCorte = @FechaCorte2, FechaDesembolso = P.Desembolso,   
       Plazo = cast(P.NroCuotas as char(4)) + Z.Plural, Moneda = 'Pesos Mexicanos',  
       ca.TasaIntCorriente, PD.FechaPago, CodOficina = PD.CodOficina + '-' + O2.NomOficina, PD.SecPago, PD.SecCuota, PD.MontoPagado, CO.DescConcepto, CA.TasaINPE  
       --TD.MontoCapitalTran, TD.MontoInteresTran, TD.MontoINPETran, TD.MontoCargos, TD.MontoOtrosTran, TD.MontoImpuestos, TD.MontoTotalTran  
       ,CA.MontoDesembolso  
--select *
from tCsPadronCarteraDet P with(nolock)  
--left join tCsCartera  CA with(nolock) on P.CodPrestamo = CA.CodPrestamo and CA.Fecha = @UltimaFechaCartera  
left outer join #TmpCartera   CA with(nolock) on P.CodPrestamo = CA.CodPrestamo and CA.Fecha = @UltimaFechaCartera  
left outer join tCsPadronClientes L with(nolock) on P.CodUsuario = L.CodUsuario  
left outer join tClUbigeo        GC with(nolock) on GC.CodUbigeo = L.CodUbiGeoDirFamPri  
left outer join tClUbigeo        GM with(nolock) on GM.CodArbolConta = left(GC.CodArbolConta, 19) and GM.codubigeotipo='MUNI'  
left outer join tClUbigeo        GE with(nolock) on GE.CodArbolConta = left(GM.CodArbolConta, 13)  
left outer join tClOficinas       O with(nolock) on P.CodOficina = O.CodOficina  
left outer join tCaClTipoPlaz     Z with(nolock) on Ca.ModalidadPlazo = Z.CodTipoPlaz  
left outer join #Pagos       PD with(nolock) on PD.Codprestamo = P.CodPrestamo --and PD.Fecha between @FechaIni2 and @FechaCorte2 and PD.Extornado = 0  
left outer join tCaClConcepto    CO with(nolock) on CO.CodConcepto = PD.CodConcepto  
left  outer join tCaProducto      PR with(nolock) on PR.CodProducto = P.CodProducto  
left outer join tClOficinas      O2 with(nolock) on PD.CodOficina  = O2.CodOficina  
where P.CodPrestamo = @CodPrestamo  
ORDER BY PD.FechaPago, PD.SecPago, PD.OrdenAfecta, PD.SecCuota  


drop table #Pagos  
drop table #TmpCartera
GO