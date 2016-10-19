#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP023_MVC
Exemplo de montagem da modelo e interface para uma estrutura
pai/filho/neto em MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP023_MVC()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA3' )
oBrowse:SetDescription( 'Albuns' )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.COMP023_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.COMP023_MVC' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.COMP023_MVC' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.COMP023_MVC' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.COMP023_MVC' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.COMP023_MVC' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZA3 := FWFormStruct( 1, 'ZA3', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZA4 := FWFormStruct( 1, 'ZA4', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZA5 := FWFormStruct( 1, 'ZA5', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'COMP023M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZA3MASTER', /*cOwner*/, oStruZA3 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZA4DETAIL', 'ZA3MASTER', oStruZA4, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Carga
//oModel:AddGrid( 'ZA4DETAIL', 'ZA3MASTER', oStruZA4, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, { |oObj, lCopia| LoadZA4( oObj, lCopia )}/*BLoad*/ )

oModel:AddGrid( 'ZA5DETAIL', 'ZA4DETAIL', oStruZA5, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//Exemplo de com Definicao do bloco de Pre-Validacao
//oModel:AddGrid( 'ZA5DETAIL', 'ZA4DETAIL', oStruZA5, { |oMdlG,nLine,cAcao,cCampo| COMP023LPRE( oMdlG, nLine, cAcao, cCampo ) }, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZA4DETAIL', { { 'ZA4_FILIAL', 'xFilial( "ZA4" )' }, { 'ZA4_ALBUM' , 'ZA3_ALBUM'  } } , ZA4->( IndexKey( 1 ) )  )
oModel:SetRelation( 'ZA5DETAIL', { { 'ZA5_FILIAL', 'xFilial( "ZA5" )' }, { 'ZA5_ALBUM' , 'ZA3_ALBUM'  }, { 'ZA5_MUSICA', 'ZA4_MUSICA' } } , ZA5->( IndexKey( 1 ) )  )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZA4DETAIL' ):SetUniqueLine( { 'ZA4_MUSICA' } )
oModel:GetModel( 'ZA5DETAIL' ):SetUniqueLine( { 'ZA5_INTER'  } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Albuns' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZA3MASTER' ):SetDescription( 'Dados do Album' )
oModel:GetModel( 'ZA4DETAIL' ):SetDescription( 'Dados das Musicas do Album'  )
oModel:GetModel( 'ZA5DETAIL' ):SetDescription( 'Interpretes das Musicas do Album'  )

// Nao Permite Incluir, Alterar ou Excluir linhas na formgrid
//oModel:GetModel( 'ZA5DETAIL' ):SetNoInsertLine()
//oModel:GetModel( 'ZA5DETAIL' ):SetNoUpdateLine()
//oModel:GetModel( 'ZA5DETAIL' ):SetNoDeleteLine()

// Adiciona regras de preenchimento
//
// Tipo 1 pre-validacao
// Adiciona uma relação de dependência entre campos do formulário,
// impedindo a atribuição de valor caso os campos de dependëncia
// náo tenham valor atribuido.
//
// Tipo 2 pos-validacao
// Adiciona uma relação de dependência entre a referência de origem e
// destino, provocando uma reavaliação do destino em caso de atualização
// da origem.
//
// Tipo 3 pre e pos-validacao
// oModel:AddRules( 'ZA3MASTER', 'ZA3_DATA', 'ZA3MASTER', 'ZA3_DESCRI', 1 )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
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

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA3', oStruZA3, 'ZA3MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZA4', oStruZA4, 'ZA4DETAIL' )
oView:AddGrid(  'VIEW_ZA5', oStruZA5, 'ZA5DETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' , 20 )
oView:CreateHorizontalBox( 'MEIO'   , 40 )
oView:CreateHorizontalBox( 'EMBAIXO', 40 )

// Criar "box" vertical para receber algum elemento da view
//oView:CreateVerticalBox( 'EMBAIXOESQ', 80, 'EMBAIXO' )
//oView:CreateVerticalBox( 'EMBAIXODIR', 20, 'EMBAIXO' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA3', 'EMCIMA'   )
oView:SetOwnerView( 'VIEW_ZA4', 'MEIO'     )
oView:SetOwnerView( 'VIEW_ZA5', 'EMBAIXO'  )
//oView:SetOwnerView( 'VIEW_ZA5', 'EMBAIXOESQ'  )

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_ZA3' )
oView:EnableTitleView( 'VIEW_ZA4', "MÚSICAS DO ÁLBUM", RGB( 224, 30, 43 )  )
oView:EnableTitleView( 'VIEW_ZA5', "INTERPRETES DAS MÚSICAS", 0 )

// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZA4', "ENABLEDGRIDDETAIL", { 60 } )
//oView:SetViewProperty( 'VIEW_ZA5', "ENABLEDGRIDDETAIL", { 60 } )

// Acrescenta um objeto externo ao View do MVC
// AddOtherObject(cFormModelID,bBloco)
// cIDObject - Id
// bBloco    - Bloco chamado evera ser usado para se criaros objetos de tela externos ao MVC.

//oView:AddOtherObject("OTHER_PANEL", {|oPanel| COMP23BUT(oPanel)})
//oView:SetOwnerView("OTHER_PANEL",'EMBAIXODIR')
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
Static Function COMP023LPRE( oModelGrid, nLinha, cAcao, cCampo )
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


//-------------------------------------------------------------------
Static Function LoadZA4( oGrid, lCopy ) 
Local aArea   := GetArea() 
Local aFields := {}
Local aRet    := {} 
Local cFields := 'R_E_C_N_O_'
Local cTmp    := ''
Local cQuery  := ''

// Pega campos que fazem parte da estrutura do objeto, para otimizar retorno da query
aFields := oGrid:GetStruct():GetFields()
aEval( aFields, { |aX| IIf( !aX[MODEL_FIELD_VIRTUAL], cFields += ',' + aX[MODEL_FIELD_IDFIELD],) } )

cTmp   := GetNextAlias() 
cQuery := ""
cQuery += "SELECT " + cFields + " FROM " + RetSqlName( 'ZA4' ) + " ZA4"
cQuery += " WHERE ZA4_FILIAL='" + xFilial( 'ZA4' ) + "'"
cQuery += " AND ZA4_ALBUM='" + oGrid:GetModel():GetModel( 'ZA3MASTER' ):GetValue( 'ZA3_ALBUM' ) + "'"
cQuery += " AND ZA4.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. ) 

aRet := FWLoadByAlias( oGrid, cTmp ) 

(cTmp)->( dbCloseArea() ) 

RestArea( aArea ) 

Return aRet  