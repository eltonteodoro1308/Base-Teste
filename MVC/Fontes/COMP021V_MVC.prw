#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP021V_MVC
Exemplo de montagem da modelo e interface para uma estrutura
pai/filho em MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP021V_MVC()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA1' )
oBrowse:SetDescription( 'Musicas' )
oBrowse:SetMenuDef( 'COMP021V_MVC' )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
aRotina := FWMVCMenu( 'COMP021V_MVC' )
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Utilizo um model que ja existe
Return FWLoadModel( 'COMP021_MVC' )

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruZA1 := FWFormStruct( 2, 'ZA1' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'COMP021V_MVC' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA1', oStruZA1, 'ZA1MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA1', 'TELA' )

// Criar novo botao na barra de botoes
oView:AddUserButton( 'Aut./Inter.', 'CLIPS', { |oView, lCopy| COMP021VBUT(oView, lCopy) } )

Return oView


//-------------------------------------------------------------------
Static Function COMP021VBUT( oView, lCopy )
Local oStruZA2 := FWFormStruct( 2, 'ZA2' )
Local oModel   := oView:GetModel()
Local aCoors   := FWGetDialogSize( oMainWnd )
Local oNewView, oFWMVCWindow


// Cria o objeto de View
oNewView := FWFormView():New( oView )

// Define qual o Modelo de dados será utilizado
oNewView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oNewView:AddGrid(  'VIEW_ZA2', oStruZA2, 'ZA2DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oNewView:CreateHorizontalBox( 'SUBTELA', 100 )

// Relaciona o ID da View com o "box" para exibicao
oNewView:SetOwnerView( 'VIEW_ZA2', 'SUBTELA' )

// Define campos que terao Auto Incremento
oNewView:AddIncrementField( 'VIEW_ZA2', 'ZA2_ITEM' )

// Liga a identificacao do componente
oNewView:EnableTitleView('VIEW_ZA2')

// Liga a Edição de Campos na FormGrid
oNewView:SetViewProperty( 'VIEW_ZA2', "ENABLEDGRIDDETAIL", { 50 } )

// Desliga a navegacao interna de registros
oNewView:setUseCursor( .F. )

// Define fechamento da tela
oNewView:SetCloseOnOk( {||.T.} )

// Criacao do Tela
oFWMVCWindow := FWMVCWindow():New()
oFWMVCWindow:SetPos( aCoors[1], aCoors[2] )
oFWMVCWindow:SetSize( aCoors[3] * 0.7, aCoors[4] * 0.7 )
oFWMVCWindow:SetTitle( 'Autores e Interpretes' )
oFWMVCWindow:SetUseControlBar( .T. )
oFWMVCWindow:SetView( oNewView )
oFWMVCWindow:Activate( ,,, lCopy)

Return NIL
