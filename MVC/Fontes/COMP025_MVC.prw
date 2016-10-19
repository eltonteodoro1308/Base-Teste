#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP025_MVC
Exemplo de montagem da modelo e interface de marcacao para uma
tabela em MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP025_MVC()
Private oMark

oMark := FWMarkBrowse():New()
oMark:SetAlias('ZA0')
oMark:SetSemaphore(.T.)
oMark:SetDescription('Seleção do Cadastro de Autor/Interprete')
oMark:SetFieldMark( 'ZA0_OK' )
oMark:SetAllMark( { || oMark:AllMark() } )
oMark:AddLegend( "ZA0_TIPO=='1'", "YELLOW", "Autor"       )
oMark:AddLegend( "ZA0_TIPO=='2'", "BLUE"  , "Interprete"  )
oMark:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.COMP025_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Processar'  ACTION 'U_COMP25PROC()'      OPERATION 2 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Utilizo um model que ja existe
Return FWLoadModel( 'COMP011_MVC' )


//-------------------------------------------------------------------
Static Function ViewDef()
// Utilizo uma View que ja existe
Return FWLoadView( 'COMP011_MVC' )


//-------------------------------------------------------------------
User Function COMP25PROC()
Local aArea    := GetArea()
Local cMarca   := oMark:Mark()
Local lInverte := oMark:IsInvert()
Local nCt      := 0

ZA0->( dbGoTop() )
While !ZA0->( EOF() )
	If oMark:IsMark(cMarca)
		nCt++
	EndIf

	ZA0->( dbSkip() )
End

ApMsgInfo( 'Foram marcados ' + AllTrim( Str( nCt ) ) + ' registros.' )

RestArea( aArea )

Return NIL
