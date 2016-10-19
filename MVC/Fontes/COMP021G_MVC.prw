#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "MSGRAPHI.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GRAFICO_MVC
Exemplo de montagem da modelo e interface para uma estrutura
pai/filho em MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/03/2011
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP021G_MVC()
Local oBrowse

Static oGrafPizza
Static oGrafBar

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA1' )
oBrowse:SetDescription( 'Musicas' )
oBrowse:SetMenuDef( 'COMP021G_MVC' )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
aRotina := FWMVCMenu( 'COMP021G_MVC' )
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZA1 := FWFormStruct( 1, 'ZA1' )
Local oStruZA2 := FWFormStruct( 1, 'ZA2' )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'CMP21G' )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZA1MASTER',, oStruZA1 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZA2DETAIL', 'ZA1MASTER', oStruZA2 )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZA2DETAIL', { { 'ZA2_FILIAL', 'xFilial( "ZA2" )' }, { 'ZA2_MUSICA', 'ZA1_MUSICA' } }, ZA2->( IndexKey( 1 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZA2DETAIL' ):SetUniqueLine( { 'ZA2_AUTOR' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Musicas' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZA1MASTER' ):SetDescription( 'Dados da Musica' )
oModel:GetModel( 'ZA2DETAIL' ):SetDescription( 'Dados do Autor Da Musica'  )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruZA1 := FWFormStruct( 2, 'ZA1' )
Local oStruZA2 := FWFormStruct( 2, 'ZA2' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'COMP021G_MVC' )
Local oView
Local oGrafPizza
Local oGrafBar

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA1', oStruZA1, 'ZA1MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZA2', oStruZA2, 'ZA2DETAIL' )

// Criar um box horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'INFERIOR', 85 )

// Dividir o box inferior em outros 2
oView:CreateVerticalBox(   'INFERIORE', 70, 'INFERIOR'  )
oView:CreateVerticalBox(   'INFERIORD', 30, 'INFERIOR'  )

// Dividir o box da esquerda em outros 2
oView:CreateHorizontalBox( 'GRAFPIZZA', 40, 'INFERIORD' )
oView:CreateHorizontalBox( 'GRAFBARRA', 60, 'INFERIORD' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA1', 'SUPERIOR'  )
oView:SetOwnerView( 'VIEW_ZA2', 'INFERIORE' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZA2', 'ZA2_ITEM' )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_ZA2')

// Cria componentes nao MVC
oView:AddOtherObject("OTHER_PIZZA", {|oPanel,oView| GrafPizza(.F.,oPanel,oView:GetModel())})
oView:SetOwnerView("OTHER_PIZZA",'GRAFPIZZA')

oView:AddOtherObject("OTHER_BARRA", {|oPanel,oView| GrafBarra(.F.,oPanel,oView:GetModel())})
oView:SetOwnerView("OTHER_BARRA",'GRAFBARRA')

oView:SetFieldAction( 'ZA2_AUTOR', { |oView, cIDView, cField, xValue| GraRefresh() } )
oView:SetViewAction( 'DELETELINE'  , { |oView| GraRefresh() } )
oView:SetViewAction( 'UNDELETELINE', { |oView| GraRefresh() } )

Return oView


//-------------------------------------------------------------------
Static Function GrafPizza( lReDraw, oPanel )
Local aArea      := GetArea()
Local aAreaZA0   := ZA0->( GetArea() )
Local nQtd       := 0
Local nQtdInt    := 0
Local nQtdAut    := 0
Local oModel     := FwModelActive()
Local oModelZA2  := oModel:GetModel('ZA2DETAIL')
Local nI

For nI := 1 To oModelZA2:Length()
	If !oModelZA2:IsDeleted( nI )
		nQtd++
		If ZA0->( dbSeek( xFilial( 'ZA0' ) + oModelZA2:GetValue( 'ZA2_AUTOR', nI ) ) )
			If ZA0->ZA0_TIPO == "1"
				nQtdAut++
			Else
				nQtdInt++
			EndIf
		EndIf
	EndIf
Next

If !lReDraw
	oGrafPizza := FWChartFactory():New()
	oGrafPizza := oGrafPizza:GetInstance( PIECHART )
	oGrafPizza:Init( oPanel, .F. )
	oGrafPizza:SetTitle( "Participação", CONTROL_ALIGN_CENTER )
	oGrafPizza:SetLegend( CONTROL_ALIGN_BOTTOM )
Else
	oGrafPizza:Reset()
EndIf

oGrafPizza:addSerie( "Autores"    , nQtdAut/nQtd * 100 )
oGrafPizza:addSerie( "Interpretes", nQtdInt/nQtd * 100 )

oGrafPizza:build()

RestArea( aAreaZA0 )
RestArea( aArea )

Return NIL


//-------------------------------------------------------------------
Function GrafBarra( lReDraw, oPanel )
Local aArea      := GetArea()
Local aAreaZA0   := ZA0->( GetArea() )
Local nQtd       := 0
Local nQtdInt    := 0
Local nQtdAut    := 0
Local oModel     := FwModelActive()
Local oModelZA2  := oModel:GetModel('ZA2DETAIL')
Local nI

For nI := 1 To oModelZA2:Length()
	If !oModelZA2:IsDeleted( nI )
		nQtd ++
		If ZA0->( dbSeek( xFilial( 'ZA0' ) + oModelZA2:GetValue( 'ZA2_AUTOR', nI ) ) )
			If ZA0->ZA0_TIPO == "1"
				nQtdAut++
			Else
				nQtdInt++
			EndIf
		EndIf
	EndIf
Next

If !lReDraw
	oGrafBar := FWChartFactory():New()
	oGrafBar := oGrafBar:GetInstance( BARCHART )
	oGrafBar:Init( oPanel, .F., .F. )
	oGrafBar:SetMaxY( 15 )
	oGrafBar:SetTitle( "Quantidade", CONTROL_ALIGN_CENTER )
	oGrafBar:SetLegend( CONTROL_ALIGN_RIGHT )
Else
	oGrafBar:Reset()
EndIf

oGrafBar:addSerie( "Total"      , nQtd    )
oGrafBar:addSerie( "Autores"    , nQtdAut )
oGrafBar:addSerie( "Interpretes", nQtdInt )

oGrafBar:build()

RestArea( aAreaZA0 )
RestArea( aArea )

Return .T.


//-------------------------------------------------------------------
Static Function GraRefresh()
GrafPizza( .T., oGrafPizza:oOwner )
GrafBarra( .T., oGrafBar:oOwner   )
Return NIL