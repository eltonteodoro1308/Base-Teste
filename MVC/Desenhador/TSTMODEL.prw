#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author elton.alves

@since 02/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStr1:= Nil
oModel := MPFormModel():New('LOGCDCF',bPre,bPos,bCommit,bCancel)

oModel:SetDescription('LOG CDCF')

oModel:SetVldActivate(bVldActivate)
oModel:SetLoadXML(bLoadXML)
oModel:SetActivate(bActivate)
oModel:SetDeActivate(bDeActivate)
oModel:SetOnDemand(.T.)
oModel:addFields('FIELD1',,oStr1)
oModel:getModel('FIELD1'):SetDescription('FIELD1')


Return oModel