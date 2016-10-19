#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMP022_MVC
Exemplo de montagem da modelo e interface para uma estrutura
pai/filho em MVC com estrutura de calculo, interceptacao da
gravacao dos dados (COMMIT) e folders

@author Ernani Forastieri e Rodrigo Antonio Godinho
@since 05/10/2009
@version P10
/*/
//-------------------------------------------------------------------
User Function COMP022_MVC()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZA1' )
oBrowse:SetDescription( 'Musicas' )
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { 'Visualizar', 'VIEWDEF.COMP022_MVC', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.COMP022_MVC', 0, 3, 0, NIL } )
aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.COMP022_MVC', 0, 4, 0, NIL } )
aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.COMP022_MVC', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 'VIEWDEF.COMP022_MVC', 0, 8, 0, NIL } )
aAdd( aRotina, { 'Copiar'    , 'VIEWDEF.COMP022_MVC', 0, 9, 0, NIL } )

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZA1 := FWFormStruct( 1, 'ZA1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZA2 := FWFormStruct( 1, 'ZA2', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'COMP022M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New( 'COMP022M', /*bPreValidacao*/, /*bPosValidacao*/, { |oMdl| COMP022CM2( oMdl ) }, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZA1MASTER', NIL, oStruZA1 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZA2DETAIL', 'ZA1MASTER', oStruZA2, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Adiciona ao modelo uma estrutura de formulário de campos calculados
// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond
oModel:AddCalc( 'COMP022CALC1', 'ZA1MASTER', 'ZA2DETAIL', 'ZA2_AUTOR', 'ZA2__TOT01', 'COUNT', { | oFW | COMP022CAL( oFW, .T. ) },,'Total Pares' )
oModel:AddCalc( 'COMP022CALC1', 'ZA1MASTER', 'ZA2DETAIL', 'ZA2_AUTOR', 'ZA2__TOT02', 'COUNT', { | oFW | COMP022CAL( oFW, .F. ) },,'Total Impares' )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZA2DETAIL', { { 'ZA2_FILIAL', 'xFilial( "ZA2" ) ' } , { 'ZA2_MUSICA', 'ZA1_MUSICA' } } , ZA2->( IndexKey( 1 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZA2DETAIL' ):SetUniqueLine( { 'ZA2_AUTOR' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Musicas' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZA1MASTER' ):SetDescription( 'Dados da Musica' )
oModel:GetModel( 'ZA2DETAIL' ):SetDescription( 'Dados do Autor'  )


Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruZA1 := FWFormStruct( 2, 'ZA1' )
Local oStruZA2 := FWFormStruct( 2, 'ZA2' )

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'COMP022_MVC' )
Local oView
Local oCalc1


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA1' , oStruZA1, 'ZA1MASTER'   )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_ZA2' , oStruZA2, 'ZA2DETAIL'   )

// Cria o objeto de Estrutura
oCalc1 := FWCalcStruct( oModel:GetModel( 'COMP022CALC1') )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
//oView:AddField( 'VIEW_CALC', oCalc1, 'COMP022CALC1' )
oView:AddField( 'VIEW_CALC', oCalc1, 'COMP022CALC1' )

// Cria Folder na view
oView:CreateFolder( 'PASTAS' )

// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', 'Cabeçalho' )
oView:AddSheet( 'PASTAS', 'ABA02', 'Item'      )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL'  , 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'CORPO'  ,  80,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'RODAPE',   20,,, 'PASTAS', 'ABA02' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA1' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_ZA2' , 'CORPO'  )
oView:SetOwnerView( 'VIEW_CALC', 'RODAPE' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZA2', 'ZA2_ITEM' )


Return oView


//-------------------------------------------------------------------
Static Function COMP022CAL( oFW, lPar )
Local lRet := .T.

If lPar
	lRet := ( Mod( Val( oFw:GetValue( 'ZA2DETAIL', 'ZA2_AUTOR' ) ) , 2 ) == 0 )
Else
	lRet := ( Mod( Val( oFw:GetValue( 'ZA2DETAIL', 'ZA2_AUTOR' ) ) , 2 ) <> 0 )
EndIf
Return lRet

//-------------------------------------------------------------------
Static Function COMP022CM1( oModel )
Local aArea      := GetArea()
Local aAreaZA0   := ZA0->( GetArea() )
Local nOperation := oModel:GetOperation()
Local nI         := 0

If     nOperation == MODEL_OPERATION_INSERT

	oModelZA2 := oModel:GetModel( 'ZA2DETAIL' )

	For nI := 1 To oModelZA2:Length()

		ZA0->( dbSetOrder( 1 ) )

		If ZA0->( dbSeek( xFilial( 'ZA0' ) + oModel:GetModel('ZA2DETAIL'):GetValue( 'ZA2_AUTOR', nI ) ) )
			RecLock( 'ZA0', .F. )
			ZA0->ZA0_QTDMUS++
			MsUnlock()
		EndIf

	Next

ElseIf nOperation == MODEL_OPERATION_DELETE

	oModelZA2 := oModel:GetModel( 'ZA2DETAIL' )

	For nI := 1 To oModelZA2:Length()

		ZA0->( dbSetOrder( 1 ) )

		If ZA0->( dbSeek( xFilial( 'ZA0' ) + FwFldGet( 'ZA2_AUTOR', nI ) ) )
			RecLock( 'ZA0', .F. )
			ZA0->ZA0_QTDMUS := Max( 0, ZA0->ZA0_QTDMUS - 1 )
			MsUnlock()
		EndIf

	Next

EndIf

FWFormCommit( oModel )

RestArea( aAreaZA0 )
RestArea( aArea )
Return NIL



//-------------------------------------------------------------------
Static Function COMP022CM2( oModel )
Local aArea      := GetArea()
Local aAreaZA0   := ZA0->( GetArea() )
Local nI         := 0
Local nOperation := oModel:GetOperation()
Local lOk        := .T.
Local aSaveLines := FWSaveRows()

oModelZA0 := FWLoadModel( 'COMP011_MVC' )
oModelZA0:SetOperation( MODEL_OPERATION_UPDATE )

oModelZA2 := oModel:GetModel( 'ZA2DETAIL' )

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

	For nI := 1 To oModelZA2:Length()

		oModelZA2:GoLine( nI )

		If oModelZA2:IsUpdated() .OR. oModelZA2:IsDeleted() .OR. oModelZA2:IsUpdated()

			ZA0->( dbSetOrder( 1 ) )

			If ZA0->( dbSeek( xFilial( 'ZA0' ) + oModelZA2:GetValue( 'ZA2_AUTOR', nI, oModel ) ) )

				If oModelZA0:Activate()

					// Verifica se á uma nova linha no FORMGRID
					If      !oModelZA2:IsDeleted() .AND. oModelZA2:IsInserted()

						// Soma um 1 dos total de Musicas no modelo de Autor/Interprete
						If !oModelZA0:SetValue( 'ZA0MASTER', 'ZA0_QTDMUS', oModelZA0:GetValue( 'ZA0MASTER', 'ZA0_QTDMUS' ) + 1 )
							lOk := .F.
							Help( ,, 'Help',, 'Erro ao gravar quantidade', 1, 0 )
						EndIf

						// Verifica se á uma linha deleteada no FORMGRID
					ElseIf  oModelZA2:IsDeleted()

						// Subtrai um 1 dos total de Musicas no modelo de Autor/Interprete
						If !oModelZA0:SetValue( 'ZA0MASTER', 'ZA0_QTDMUS', Max( 0, oModelZA0:GetValue( 'ZA0MASTER', 'ZA0_QTDMUS' ) - 1 ) )
							lOk := .F.
							Help( ,, 'Help',, 'Erro ao gravar quantidade', 1, 0 )
						EndIf

					EndIf

				Else
					lOk := .F.

					Help( ,, 'Help',, 'Restricao de ativacao do Modelo', 1, 0 )

				EndIf

				If lOk
					If ( lOk  := oModelZA0:VldData() )
						If !oModelZA0:CommitData()
							lOk := .F.
							Help( ,, 'Help',, 'Erro ao gravar dados do modelo', 1, 0 )
						EndIf
					Else
						Help( ,, 'Help',, 'Erro ao gravar quantidade', 1, 0 )
						Exit
					EndIf

				Else
					Exit

				EndIf

				oModelZA0:DeActivate()

			EndIf

		EndIf

	Next

ElseIf nOperation == MODEL_OPERATION_DELETE

	For nI := 1 To oModelZA2:Length()

		oModelZA2:GoLine( nI )

		ZA0->( dbSetOrder( 1 ) )

		If ZA0->( dbSeek( xFilial( 'ZA0' ) + oModelZA2:GetValue( 'ZA2_AUTOR', nI, oModel ) ) )

			If oModelZA0:Activate()

				// Subtrai um 1 dos total de Musicas no modelo de Autor/Interprete
				If !oModelZA0:SetValue( 'ZA0MASTER', 'ZA0_QTDMUS', oModelZA0:GetValue( 'ZA0MASTER', 'ZA0_QTDMUS' ) - 1  )
					lOk := .F.
					Help( ,, 'Help',, 'Erro ao gravar quantidade', 1, 0 )
				EndIf

			Else
				lOk := .F.

				Help( ,, 'Help',, 'Restricao de ativacao do Modelo', 1, 0 )

			EndIf


			If lOk
				If ( lOk  := oModelZA0:VldData() )
					If !oModelZA0:CommitData()
						lOk := .F.
						Help( ,, 'Help',, 'Erro ao gravar dados do modelo', 1, 0 )
					EndIf
				Else
					Help( ,, 'Help',, 'Erro ao gravar quantidade', 1, 0 )
					Exit
				EndIf

			Else
				Exit

			EndIf

			oModelZA0:DeActivate()

		EndIf

	Next

EndIf

FWModelActive( oModel )

FWFormCommit( oModel )

FWRestRows( aSaveLines )

RestArea( aAreaZA0 )
RestArea( aArea )

Return NIL

