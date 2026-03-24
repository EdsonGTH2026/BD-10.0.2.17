SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


----SP: trae la informacion por cliente para la constancia fiscal
CREATE PROCEDURE [dbo].[pCsCFDIConstanciaFiscal2023] @RFC varchar(13)
AS
begin
----------DESCOMENTAR PARA PRUEBA
--declare @RFC varchar(13)
--set @RFC='AEAN731012333'


select 
codUsTitular  Auxiliar_Codusuario
,TipoPersona  Auxiliar_TipoPersona
---RETENCIONES
,'2.0'        Retencion_Version
,'DD/MM/AAAA' RET_FechaExp
,'01090'      RET_LugarExpRetenc
---EMISOR
,'EKU9003173C9' Emisor_RFC
,'ESCUELA KEMPER URGATE SA DE CV' Emisor_NombreDenRazonSoc
,'601' Emisor_RegimenFiscal
---RECEPTOR
,'Nacional' NACIONALIDAD

---Retenciones RECEPTOR 
,NOMBRECOMPLETO     Receptor_NomDenRazSoc 
,PATERNO			Receptor_Paterno
,MATERNO			Receptor_Materno
,NOMBRES			Receptor_Nombres
,RFC                Receptor_RFC
,CURP               Receptor_CURP
,DOMICILIOFISCAL_CP Receptor_DomicilioFiscal

----PERIODO
,'01'     Periodo_MesIni
,'12' Periodo_MesFin
,Año         Periodo_Ejercicio

----RETENCIONES TOTALES -- POR CLIENTE
,MONTOISR       Totales_ISR
,MONTOGRAVADO   Totales_MontoTotGrav
,MONTOEXCENTO   Totales_MontoTotExcent
,MONTOISR       Totales_MontoTotRet
,MONTOINVERSION Totales_MontoTotOperacion

----------- RETENCIONES TOTALES IMP.RETENIDOS
,MONTOINVERSION         ImpRetenidos_BaseRet
,'001'					ImpRetenidos_ImpuestoRet
,MONTOISR				ImpRetenidos_MontoRet
,'04'					ImpRetenidos_TipoPagoRet
,'16'					ImpRetenidos_CveRetenc
,'Retenciones 2023'           DescRetenc
-------------INTERESES
,'1.0'              Intereses_Version
,'SI'               Intereses_SisFinanciero
,'SI'               Intereses_RETIRO
,'SI'               Intereses_OperFinancDerivad
,MontoInteres           Intereses_MontoIntNominal
,interesReal            Intereses_MontoIntReal
,perdidaReal            Intereses_Perdida
-------------ADICIONAL
,''            UsoCFDI
--,codUsTitular  Codusuario
from FnmgConsolidado.dbo.tCsConstanciaFiscal with(nolock)
where RFC=@RFC

end
GO