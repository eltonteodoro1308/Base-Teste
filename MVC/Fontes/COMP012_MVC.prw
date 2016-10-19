#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP012_MVC
Exemplo de montagem da modelo e interface para um tabela em MVC
com montagem da estrutura de dados manualmente

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP012_MVC()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA0' )
oBrowse:SetDescription( 'Cadastro de Autor/Interprete' )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.COMP012_MVC' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.COMP012_MVC' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.COMP012_MVC' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.COMP012_MVC' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.COMP012_MVC' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.COMP012_MVC' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruZA0 := DefStrModel( 'ZA0' )

oStruZA0:RemoveField( 'ZA4_FILIAL' )

oModel := MPFormModel():New( 'COMP012M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New( 'COMP012MODEL', /*bPreValidacao*/, { | oMdl | COMP012POS( oMdl ) } , /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZA0MASTER', /*cOwner*/, oStruZA0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados de Autor/Interprete' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZA0MASTER' ):SetDescription( 'Dados de Dados de Autor/Interprete' )

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActive( { | oModel | COMP012ACT( oModel ) } )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'COMP012_MVC' )
Local oStruZA0 := DefStrView( 'ZA0' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA0', oStruZA0, 'ZA0MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA0', 'TELA' )

Return oView


//-------------------------------------------------------------------
Static Function COMP012POS( oModel )
Local nOperation := oModel:GetOperation()
Local lRet       := .T.

If nOperation == MODEL_OPERATION_INSERT
	If Empty( oModel:GetValue( 'ZA0MASTER', 'ZA0_DTAFAL' ) )
		Help( ,, 'Help',, 'Informe a data', 1, 0 )
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
Static Function COMP012ACT( oModel )  // Passa o model sem dados
Local nOperation := oModel:GetOperation()
Local aArea      := GetArea()
Local lRet       := .T.
Local cZA0       := ''
Local cQuery     := ''

If nOperation == MODEL_OPERATION_DELETE .AND. lRet

	cZA0    := GetNextAlias()

	cQuery  := ""
	cQuery  += "SELECT ZA0_CODIGO FROM " + RetSqlName( 'ZA0' ) + " ZA0 "
	cQuery  += " WHERE EXISTS ( "
	cQuery  += "       SELECT 1 FROM " + RetSqlName( 'ZA2' ) + " ZA2 "
	cQuery  += "        WHERE ZA2_AUTOR = ZA0_CODIGO"
	cQuery  += "          AND ZA2.D_E_L_E_T_ = ' ' ) "
	cQuery  += "   AND ZA0_CODIGO = '" + ZA0->ZA0_CODIGO  + "' "
	cQuery  += "   AND ZA0.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cZA0, .F., .T. )

	lRet := ( cZA0 )->( EOF() )

	( cZA0 )->( dbCloseArea() )

	If lRet
		cQuery  := ""
		cQuery  += "SELECT ZA0_CODIGO FROM " + RetSqlName( 'ZA0' ) + " ZA0 "
		cQuery  += " WHERE EXISTS ( "
		cQuery  += "       SELECT 1 FROM " + RetSqlName( 'ZA5' ) + " ZA5 "
		cQuery  += "        WHERE ZA5_INTER = ZA0_CODIGO"
		cQuery  += "          AND ZA5.D_E_L_E_T_ = ' ' ) "
		cQuery  += "   AND ZA0_CODIGO = '" + ZA0->ZA0_CODIGO  + "' "
		cQuery  += "   AND ZA0.D_E_L_E_T_ = ' ' "

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cZA0, .F., .T. )

		lRet := ( cZA0 )->( EOF() )

		( cZA0 )->( dbCloseArea() )

	EndIf

	If !lRet
		Help( ,, 'Help',, 'Este Autor/interprete nao pode ser excluido.', 1, 0 )
	EndIf

EndIf

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
Static Function DefStrModel( cAlias )
Local aArea    := GetArea()
Local aAreaSX3 := SX2->( GetArea() )
Local aAreaSIX := SX3->( GetArea() )
Local aAreaSX7 := SX7->( GetArea() )
Local aAreaSX2 := SIX->( GetArea() )
Local bValid   := { || }
Local bWhen    := { || }
Local bRelac   := { || }
Local aAux     := {}

oStruct := FWFormModelStruct():New()

//-------------------------------------------------------------------
// Tabela
//-------------------------------------------------------------------
SX2->( dbSetOrder( 1 ) )
SX2->( dbSeek( cAlias ) )

oStruct:AddTable( ;
SX2->X2_CHAVE                , ;  // [01] Alias da tabela
StrTokArr( SX2->X2_UNICO, '+'   ) , ;                // [02] Array com os campos que correspondem a primary key
SX2->X2_NOME    )                 // [03] Descrição da tabela


//-------------------------------------------------------------------
// Indices
//-------------------------------------------------------------------
SIX->( dbSetOrder( 1 ) )
SIX->( dbSeek( cAlias ) )
nOrdem := 0

While ! SIX->( EOF() ) .AND. SIX->INDICE  == cAlias

	oStruct:AddIndex( ;
	nOrdem++      , ;             // [01] Ordem do indice
	SIX->ORDEM    , ;             // [02] ID
	SIX->CHAVE    , ;             // [03] Chave do indice
	SIXDescricao() , ;             // [04] Descrição do indice
	SIX->F3       , ;             // [05] Expressão de lookUp dos campos de indice
	SIX->NICKNAME , ;             // [06] Nickname do indice
	( SIX->SHOWPESQ <> 'N' ) )      // [07] Indica se o indice pode ser utilizado pela interface

	SIX->( dbSkip() )
End


//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
SX3->( dbSetOrder( 1 ) )
SX3->( dbSeek( cAlias ) )

While ! SX3->( EOF() ) .AND. SX3->X3_ARQUIVO == cAlias

	bValid := FwBuildFeature( 1, SX3->X3_VALID   )
	bWhen  := FwBuildFeature( 2, SX3->X3_WHEN )
	bRelac := FwBuildFeature( 3, SX3->X3_RELACAO )

	oStruct:AddField( ;
	AllTrim( X3Titulo()  )         , ;              // [01] Titulo do campo
	AllTrim( X3Descric() )         , ;              // [02] ToolTip do campo
	AllTrim( SX3->X3_CAMPO )       , ;              // [03] Id do Field
	SX3->X3_TIPO                   , ;              // [04] Tipo do campo
	SX3->X3_TAMANHO                , ;              // [05] Tamanho do campo
	SX3->X3_DECIMAL                , ;              // [06] Decimal do campo
	bValid                         , ;              // [07] Code-block de validação do campo
	bWhen                          , ;              // [08] Code-block de validação When do campo
	StrTokArr( AllTrim( X3CBox() ), ';') , ;        // [09] Lista de valores permitido do campo
	X3Obrigat( SX3->X3_CAMPO )     , ;              // [10] Indica se o campo tem preenchimento obrigatório
	bRelac                         , ;              // [11] Code-block de inicializacao do campo
	NIL                            , ;              // [12] Indica se trata-se de um campo chave
	NIL                            , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
	( SX3->X3_CONTEXT == 'V' )     )                // [14] Indica se o campo é virtual

	SX3->( dbSkip() )

End


//-------------------------------------------------------------------
// Gatilhos
//-------------------------------------------------------------------
cPrefCpo := PrefixoCpo( cAlias )

SX7->( dbSetOrder( 1 ) )
SX7->( dbSeek( cPrefCpo ) )

While ! SX7->( EOF() ) .AND. SubStr( SX7->X7_CAMPO, 1, 3 ) == cPrefCpo

	aAux :=	FwStruTrigger(;
	SX7->X7_CAMPO    ,;
	SX7->X7_CDOMIN   ,;
	SX7->X7_REGRA    ,;
	SX7->X7_SEEK=='S',;
	SX7->X7_ALIAS    ,;
	SX7->X7_ORDEM    ,;
	SX7->X7_CHAVE    ,;
	SX7->X7_CONDIC   ,;
	SX7->X7_SEQUENC   )

	oStruct:AddTrigger( ;
	aAux[1]  , ;  // [01] Id do campo de origem
	aAux[2]  , ;  // [02] Id do campo de destino
	aAux[3]  , ;  // [03] Bloco de codigo de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de codigo de execução do gatilho

	SX7->( dbSkip() )
End


RestArea( aAreaSX2 )
RestArea( aAreaSX3 )
RestArea( aAreaSX7 )
RestArea( aAreaSIX )
RestArea( aArea )

Return oStruct


//-------------------------------------------------------------------
Static Function DefStrView( cAlias )
Local aArea     := GetArea()
Local aAreaSX3  := SX3->( GetArea() )
Local aAreaSXA  := SXA->( GetArea() )
Local oStruct   := FWFormViewStruct():New()
Local aCombo    := {}
Local nInitCBox := 0
Local nMaxLenCb := 0
Local aAux      := {}
Local nI        := 0
Local cGSC      := ''


//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
SX3->( dbSetOrder( 1 ) )
SX3->( dbSeek( cAlias ) )

While ! SX3->( EOF() ) .AND. SX3->X3_ARQUIVO == cAlias
	If !( '_FILIAL' $ SX3->X3_CAMPO )
		aCombo := {}

		If !Empty( X3Cbox() )

			nInitCBox := 0
			nMaxLenCb := 0

			aAux := RetSX3Box( X3Cbox() , @nInitCBox, @nMaxLenCb, SX3->X3_TAMANHO )

			For nI := 1 To Len( aAux )
				aAdd( aCombo, aAux[nI][1] )
			Next nI

		EndIf

		bPictVar := FwBuildFeature( 4, SX3->X3_PICTVAR )

		cGSC     := IIf( Empty( X3Cbox() ) , IIf( SX3->X3_TIPO == 'L', 'CHECK', 'GET' ) , 'COMBO' )

		oStruct:AddField( ;
		AllTrim( SX3->X3_CAMPO  )    , ;                // [01] Campo
		SX3->X3_ORDEM                , ;                // [02] Ordem
		AllTrim( X3Titulo()  )       , ;                // [03] Titulo
		AllTrim( X3Descric() )       , ;                // [04] Descricao
		NIL                          , ;                // [05] Help
		cGSC                         , ;                // [06] Tipo do campo   COMBO, Get ou CHECK
		SX3->X3_PICTURE              , ;                // [07] Picture
		bPictVar                     , ;                // [08] PictVar
		SX3->X3_F3                   , ;                // [09] F3
		SX3->X3_VISUAL <> 'V'   	 , ;                // [10] Editavel
		SX3->X3_FOLDER               , ;                // [11] Folder
		SX3->X3_FOLDER               , ;                // [12] Group
		aCombo                       , ;                // [13] Lista Combo
		nMaxLenCb                    , ;                // [14] Tam Max Combo
		SX3->X3_INIBRW               , ;                // [15] Inic. Browse
		( SX3->X3_CONTEXT == 'V' )     )                // [16] Virtual

	EndIf
	SX3->( dbSkip() )

End


//-------------------------------------------------------------------
// Folders
//-------------------------------------------------------------------
SXA->( dbSetOrder( 1 ) )
SXA->( dbSeek( cAlias ) )

While ! SXA->( EOF() ) .AND. SXA->XA_ALIAS == cAlias

	oStruct:AddFolder(  ;
	SXA->XA_ORDEM     , ;                            // [01] Codigo
	SXA->XA_DESCRIC   )                              // [02] Descrição

	SXA->( dbSkip() )

End

RestArea( aAreaSX3 )
RestArea( aAreaSXA )
RestArea( aArea )

Return oStruct
