#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP021_MVC
Exemplo de montagem da modelo e interface para uma estrutura
pai/filho em MVC

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP021_MVC()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA1' )
oBrowse:SetDescription( 'Musicas' )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.COMP021_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.COMP021_MVC' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.COMP021_MVC' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.COMP021_MVC' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.COMP021_MVC' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      Action 'VIEWDEF.COMP021_MVC' OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Autor'       Action 'VIEWDEF.COMP011_MVC' OPERATION 3 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZA1 := FWFormStruct( 1, 'ZA1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZA2 := FWFormStruct( 1, 'ZA2', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

FWMemoVirtual( oStruZA2, { { 'ZA2_CDSYP1', 'ZA2_MMSYP1' }, { 'ZA2_CDSYP2', 'ZA2_MMSYP2' } } )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'COMP021M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New( 'COMP021M', /*bPreValidacao*/, { | oMdl | COMP021POS( oMdl ) } , /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZA1MASTER', /*cOwner*/, oStruZA1 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZA2DETAIL', 'ZA1MASTER', oStruZA2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//oModel:AddGrid( 'ZA2DETAIL', 'ZA1MASTER', oStruZA2, /*bLinePre*/,  { | oMdlG | COMP021LPOS( oMdlG ) } , /*bPreVal*/, /*bPosVal*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZA2DETAIL', { { 'ZA2_FILIAL', 'xFilial( "ZA2" )' }, { 'ZA2_MUSICA', 'ZA1_MUSICA' } }, ZA2->( IndexKey( 1 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZA2DETAIL' ):SetUniqueLine( { 'ZA2_AUTOR' } )

// Indica que é opcional ter dados informados na Grid
//oModel:GetModel( 'ZA2DETAIL' ):SetOptional(.T.)
//oModel:GetModel( 'ZA2DETAIL' ):SetOnlyView(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Musicas' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZA1MASTER' ):SetDescription( 'Dados da Musica' )
oModel:GetModel( 'ZA2DETAIL' ):SetDescription( 'Dados do Autor Da Musica'  )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruZA1 := FWFormStruct( 2, 'ZA1' )
Local oStruZA2 := FWFormStruct( 2, 'ZA2' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'COMP021_MVC' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA1', oStruZA1, 'ZA1MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZA2', oStruZA2, 'ZA2DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA1', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZA2', 'INFERIOR' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZA2', 'ZA2_ITEM' )

// Criar novo botao na barra de botoes
oView:AddUserButton( 'Inclui Autor', 'CLIPS', { |oView| COMP021BUT() } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZA2')
oView:EnableTitleView('VIEW_ZA2','MUSICAS')

// Liga a Edição de Campos na FormGrid
oView:SetViewProperty( 'VIEW_ZA2', "ENABLEDGRIDDETAIL", { 50 } )

Return oView


//-------------------------------------------------------------------
Static Function COMP021LPOS( oModelGrid )
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel( 'ZA2DETAIL' )
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
	If Mod( Val( FwFldGet( 'ZA2_AUTOR' )  ) , 2 )  <> 0
		Help( ,, 'Help',, 'So sao permitidos codigos pares', 1, 0 )
		lRet := .F.
	EndIf
	
EndIf

Return lRet


//-------------------------------------------------------------------
Static Function COMP021POS( oModel )
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaZA0   := ZA0->( GetArea() )
Local nOperation := oModel:GetOperation()
Local oModelZA2  := oModel:GetModel( 'ZA2DETAIL' )
Local nI         := 0
Local nCt        := 0
Local lAchou     := .F.
Local aSaveLines := FWSaveRows()

ZA0->( dbSetOrder( 1 ) )

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
	For nI := 1 To  oModelZA2:Length()
		
		oModelZA2:GoLine( nI )
		
		If !oModelZA2:IsDeleted()
			If ZA0->( dbSeek( xFilial( 'ZA0' ) + oModelZA2:GetValue( 'ZA2_AUTOR' ) ) ) .AND. ZA0->ZA0_TIPO == '1'
				lAchou := .T.
				Exit
			EndIf
		EndIf
		
	Next nI
	
	If !lAchou
		Help( ,, 'Help',, 'Deve haver pelo menos 1 Autor', 1, 0 )
		lRet := .F.
	EndIf
	
	If lRet
		
		For nI := 1 To oModelZA2:Length()
			
			oModelZA2:GoLine( nI )
			
			If oModelZA2:IsInserted() .AND. !oModelZA2:IsDeleted() // Verifica se é uma linha nova
				nCt++
			EndIf
			
		Next nI
		
		If nCt > 2
			Help( ,, 'Help',, 'É permitida a inclusão de apenas 2 novos Autores/interpretes de cada vez', 1, 0 )
			lRet := .F.
		EndIf
		
	EndIf
	
EndIf

FWRestRows( aSaveLines )

RestArea( aAreaZA0 )
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
Static Function COMP021BUT()
Local oModel     := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aArea      := GetArea()
Local aAreaZA0   := ZA0->( GetArea() )
Local lOk        := .F.

//FWExecView( /*cTitulo*/, /*cFonteModel*/, /*nAcao*/, /*bOk*/ )

If     nOperation == MODEL_OPERATION_INSERT // Inclusao
	lOk := ( FWExecView('Inclusao por FWExecView','COMP011_MVC', nOperation, , { || .T. } ) == 0 )
	
ElseIf nOperation == MODEL_OPERATION_UPDATE
	
	ZA0->( dbSetOrder( 1 ) )
	If ZA0->( dbSeek( xFilial( 'ZA0' ) + FwFldGet( 'ZA2_AUTOR' ) ) )
		lOk := ( FWExecView('Alteracao por FWExecView','COMP011_MVC', nOperation, , { || .T. } ) == 0 )
	EndIf
	
EndIf

If lOk
	Help( ,, 'Help',, 'Foi confirmada a manutencao do Autor', 1, 0 )
Else
	Help( ,, 'Help',, 'Foi cancelada a manutencao do Autor', 1, 0 )
EndIf

RestArea( aAreaZA0 )
RestArea( aArea )

Return lOk
