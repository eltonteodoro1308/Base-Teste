#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP024A_MVC
Exemplo de montagem da modelo e interface para uma multiplas
browses em MVC com Folders

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP024A_MVC()
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oBrowseUp, oBrowseLeft, oBrowseRight, oRelacZA4, oRelacZA5

Private oDlgPrinc

Define MsDialog oDlgPrinc Title 'Multiplos FWmBrowse' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

//
// Cria o conteiner onde serão colocados os browses
//
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 50, .F. )                       // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse pedaço do container

//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 50, .F. )                     // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'DOWN' )          // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )     // Pego o objeto desse pedaço do container

oFold := TFolder():New(0,0,{},,oPanelDown,,,,.T.,.F.,0,1000)
oFold:Align := CONTROL_ALIGN_ALLCLIENT
oFold:Hide()
oFold:Show()
oFold:AddItem("Musicas")
oFold:AddItem("Autores")

oAba01 := oFold:aDialogs[1]
oAba02 := oFold:aDialogs[2]


//
// FWmBrowse Superior Albuns
//
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )                          // Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( "Albuns" )
oBrowseUp:SetAlias( 'ZA3' )
oBrowseUp:SetMenuDef( 'COMP024_MVC' )                   // Define de onde virao os botoes deste browse
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()
oBrowseUp:Activate()


//
// Lado Esquerdo Musicas
//
oBrowseLeft:= FWMBrowse():New()
oBrowseLeft:SetOwner( oAba01 )
oBrowseLeft:SetDescription( 'Musicas' )
oBrowseLeft:SetMenuDef( '' )                       // Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
oBrowseLeft:DisableDetails()
oBrowseLeft:SetAlias( 'ZA4' )
oBrowseLeft:SetProfileID( '2' )


//
// Relacionamento entre os Browses
//
oRelacZA4:= FWBrwRelation():New()
oRelacZA4:AddRelation( oBrowseUp  , oBrowseLeft , { { 'ZA4_FILIAL', 'xFilial( "ZA4" )' }, { 'ZA4_ALBUM' , 'ZA3_ALBUM'  } } )
oRelacZA4:Activate()


//
// Ativa o Browse Filho
//
oBrowseLeft:Activate()


//
// Lado Direito Autores/Interpretes
//
oBrowseRight:= FWMBrowse():New()
oBrowseRight:SetOwner( oAba02 )
oBrowseRight:SetDescription( 'Autores/Interpretes' )
oBrowseRight:SetMenuDef( '' )                      // Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
oBrowseRight:DisableDetails()
oBrowseRight:SetAlias( 'ZA5' )
oBrowseRight:SetProfileID( '3' )

//
// Relacionamento entre os Browses
//
oRelacZA5:= FWBrwRelation():New()
oRelacZA5:AddRelation( oBrowseLeft, oBrowseRight, { { 'ZA5_FILIAL', 'xFilial( "ZA5" )' }, { 'ZA5_ALBUM' , 'ZA4_ALBUM'  }, { 'ZA5_MUSICA', 'ZA4_MUSICA' } } )
oRelacZA5:Activate()


// Ativa o Browse Filho
oBrowseRight:Activate()

Activate MsDialog oDlgPrinc Center

Return NIL

Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { 'Visualizar', 'VIEWDEF.COMP024A_MVC', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.COMP024A_MVC', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.COMP024A_MVC', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.COMP024A_MVC', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.COMP024A_MVC', 0, 8, 0, NIL } )
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Utilizo um model que ja existe
Return FWLoadModel( 'COMP023_MVC' )


//-------------------------------------------------------------------
Static Function ViewDef()
// Utilizo uma View que ja existe
Return FWLoadView( 'COMP023_MVC' )
