#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP027_MVC
Exemplo de montagem da modelo e interface para uma estrutura
pai/filho/neto em MVC usando TREE

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP027_MVC()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA3' )
oBrowse:SetDescription( 'Albuns' )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.COMP027_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.COMP027_MVC' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.COMP027_MVC' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.COMP027_MVC' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.COMP027_MVC' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.COMP027_MVC' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ViewDef()
Local aTreeInfo:={}
// Cria a estrutura a ser usada na View
Local oStruZA3 := FWFormStruct( 2, 'ZA3' )
Local oStruZA4 := FWFormStruct( 2, 'ZA4' )
Local oStruZA5 := FWFormStruct( 2, 'ZA5' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'COMP023_MVC' )
Local oView

// Remove campos da estrutura
oStruZA4:RemoveField( 'ZA4_ALBUM' )
oStruZA5:RemoveField( 'ZA5_ALBUM' )
oStruZA5:RemoveField( 'ZA5_MUSICA' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields
oView:AddField( 'VIEW_ZA3', oStruZA3, 'ZA3MASTER' )
//oView:AddGrid(  'VIEW_ZA4', oStruZA4, "ZA4DETAIL" )
//oView:AddGrid(  'VIEW_ZA5', oStruZA5, "ZA5DETAIL" )

// Cria a estrutura das grids em formato de árvore
//    [1] ID do Model
//    [2] Array de 1 dimensão com os IDs dos campos que iram aparecer no tree.
//    [3] Objeto do tipo FWViewStruct com a Estruturas dos campos
aAdd( aTreeInfo, { "ZA4DETAIL", { "ZA4_MUSICA", "ZA4_TITULO" }, oStruZA4 } )
aAdd( aTreeInfo, { "ZA5DETAIL", { "ZA5_INTER" }               , oStruZA5 } )

// oView:AddTreeGrid( IDTree, Grids em Tree, IDDetail )
oView:AddTreeGrid( "TREE", aTreeInfo, "DETAIL_TREE" )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 20 )
oView:CreateHorizontalBox( 'EMBAIXO', 80 )

// Criar "box" vertical para receber algum elemento da view
oView:CreateVerticalBox( 'EMBAIXOESQ', 30, 'EMBAIXO' )
oView:CreateVerticalBox( 'EMBAIXODIR', 70, 'EMBAIXO' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA3'   , 'EMCIMA'     )
oView:SetOwnerView( 'TREE'       , 'EMBAIXOESQ' )
oView:SetOwnerView( 'DETAIL_TREE', 'EMBAIXODIR' )

Return oView


//-------------------------------------------------------------------
Static Function COMP23BUT( oPanel )
Local lOk := .F.

@ 10, 10 Button 'Estatistica'   Size 36, 13 Message 'Contagem da FormGrid' Pixel Action COMP23ACAO( 'ZA4DETAIL', 'Existem na Grid de Musicas'     ) of oPanel
@ 30, 10 Button 'Autor/Inter.'  Size 36, 13 Message 'Inclui Autor/Interprete' Pixel Action FWExecView('Inclusao por FWExecView','COMP011_MVC', MODEL_OPERATION_INSERT, , { || .T. } ) of oPanel
Return NIL


//-------------------------------------------------------------------
Static Function COMP23ACAO( cIdGrid, cMsg )
Local oModel      := FWModelActive()
Local oModelFilho := oModel:GetModel( cIdGrid )
Local nI          := 0
Local nCtInc      := 0
Local nCtAlt      := 0
Local nCtDel      := 0
Local aSaveLines  := FWSaveRows()

For nI := 1 To oModelFilho:Length()
	oModelFilho:GoLine( nI )

	If     oModelFilho:IsDeleted()
		nCtDel++
	ElseIf oModelFilho:IsInserted()
		nCtInc++
	ElseIf oModelFilho:IsUpdated()
		nCtAlt++
	EndIf

Next


Help( ,, 'HELP',, cMsg + CRLF + ;
Alltrim( Str( nCtInc ) ) + ' linhas incluidas' + CRLF + ;
Alltrim( Str( nCtAlt ) ) + ' linhas alteradas' + CRLF + ;
Alltrim( Str( nCtDel ) ) + ' linhas deletadas' + CRLF  ;
, 1, 0)

FWRestRows( aSaveLines )

Return NIL


//-------------------------------------------------------------------
Static Function COMP027LPRE( oModelGrid, nLinha, cAcao, cCampo )
Local lRet   := .T.
Local oModel     := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

// Valida se pode ou nao deletar uma linha do Grid
If cAcao == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE
	lRet := .F.
	Help( ,, 'Help',, 'Nao permitido apagar linhas na alteracao.' + CRLF + ;
	'Voce esta na linha ' + Alltrim( Str( nLinha ) ), 1, 0 )
EndIf

Return lRet
