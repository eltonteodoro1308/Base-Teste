#Include 'Totvs.Ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} PCOA099
Rotina de Cadastro de Transposição de Saldos entre contas.
@author Elton Teododo Alves
@since 05/07/2019
@version 12.1.23

@TODO Definir a distribuição do total de saldo de origem para o saldo de destino com as regras de distribuição.
@TODO Nas tabelas ZK2 e ZK3 definir campos para classe de valor, operação, unidade orçamentária
@TODO Definir o processamento da transposição efetivando os lançamentos orçamentários.
/*/
User Function PCOA099()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('ZK1')

	oBrowse:SetDescription( 'Transposição de Saldos' )

	oBrowse:AddLegend( 'ZK1_PROCES==.T.' , 'RED'  , 'Transposição Processada'     )
	oBrowse:AddLegend( 'ZK1_PROCES==.F.' , 'GREEN', 'Transposição Não Processada' )

	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Gera o array com as rotinas que estarão disponíveis no Browser.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@return Array, Array com as rotinas que estarão disponíveis no Browser.
/*/
Static Function MenuDef()

	Local aRotina := FWMVCMenu( 'PCOA099' )

	aAdd( aRotina, { 'Processar a Transposição', 'U_PCOM099()', 0, 6, 0, NIL } )

Return aRotina

/*/{Protheus.doc} ModelDef
Gera o objeto que representa o modelo de dados.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@return Objeto, Objeto que representa o modelo de dados.
/*/
Static Function ModelDef()

	Local oModel    := MPFormModel():New('PCOA099M', { | oModel | PreOk( oModel ) }, { | oModel | TudoOk( oModel ) } )
	Local oStrCabec := FWFormStruct(1,'ZK1')
	Local oStrItens := FWFormStruct(1,'ZK2')

	oModel:addFields( 'CABEC',, oStrCabec )

	oModel:addGrid( 'GRID_SLD_ORIG', 'CABEC', oStrItens )
	oModel:GetModel('GRID_SLD_ORIG'):SetUniqueLine( { 'ZK2_CO', 'ZK2_CLASSE', 'ZK2_OPER', 'ZK2_CC', 'ZK2_ITCTB', 'ZK2_CLVLR', 'ZK2_UNIORC' } )
	oModel:SetRelation('GRID_SLD_ORIG', { { 'ZK2_FILIAL', 'xFilial("ZK2")' }, { 'ZK2_CODIGO', 'ZK1_CODIGO' }, { 'ZK2_ORIDES', '"1"' } }, ZK2->(IndexKey(1)) )

	oModel:addGrid( 'GRID_SLD_DEST', 'CABEC', oStrItens )
	oModel:GetModel('GRID_SLD_DEST'):SetUniqueLine( { 'ZK2_CO', 'ZK2_CLASSE', 'ZK2_OPER', 'ZK2_CC', 'ZK2_ITCTB', 'ZK2_CLVLR', 'ZK2_UNIORC' } )
	oModel:SetRelation('GRID_SLD_DEST', { { 'ZK2_FILIAL', 'xFilial("ZK2")' }, { 'ZK2_CODIGO', 'ZK1_CODIGO' }, { 'ZK2_ORIDES', '"2"' } }, ZK2->(IndexKey(1)) )

	oModel:SetDescription( 'Transposição de Saldos' )
	oModel:getModel( 'CABEC' ):SetDescription( 'Transposição'            )
	oModel:getModel( 'GRID_SLD_ORIG' ):SetDescription( 'Origem da Transposição'  )
	oModel:getModel( 'GRID_SLD_DEST' ):SetDescription( 'Destino da Transposição' )

	oModel:AddCalc( 'CALC_SLD_ORIG', 'CABEC', 'GRID_SLD_ORIG', 'ZK2_VALOR', 'ZK2_VALOR_SUM', 'SUM',,,'Total da Transposição de Origem' )
	oModel:AddCalc( 'CALC_SLD_DEST', 'CABEC', 'GRID_SLD_DEST', 'ZK2_VALOR', 'ZK2_VALOR_SUM', 'SUM',,,'Total da Transposição de Destino' )

Return oModel

/*/{Protheus.doc} ViewDef
Gera o objeto que representa a view do modelo de dados.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@return Objeto, Objeto que representa a view do modelo de dados.
/*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := ModelDef()
	Local oStrCabec  := FWFormStruct(2, 'ZK1')
	Local oStrItens  := FWFormStruct(2, 'ZK2')
	Local oStrZK2Clc := FWCalcStruct( oModel:GetModel('CALC_SLD_ORIG') )
	Local oStrZK3Clc := FWCalcStruct( oModel:GetModel('CALC_SLD_DEST') )

	oView:SetModel(oModel)

	//-- Definindo as sub view´s

	oView:AddField('CABEC' , oStrCabec,'CABEC' )

	oView:AddGrid('GRID_SLD_ORIG' , oStrItens,'GRID_SLD_ORIG')
	oView:AddGrid('GRID_SLD_DEST' , oStrItens,'GRID_SLD_DEST')


	oView:AddIncrementField( 'GRID_SLD_ORIG', 'ZK2_ITEM' )
	oView:AddIncrementField( 'GRID_SLD_DEST', 'ZK2_ITEM' )

	oView:AddField('CALC_SLD_DEST', oStrZK3Clc,'CALC_SLD_DEST')
	oView:AddField('CALC_SLD_ORIG', oStrZK2Clc,'CALC_SLD_ORIG')

	//-- Definindo Botões

	// oView:AddUserButton('Aplicar Regra de Distribuição','',{ |oView| Distribuir( oView ) },;
	// 'Aplica uma regra de distribuição ao valor total a ser transposto.',286,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})

	//-- Os Boxes da tela

	oView:CreateHorizontalBox( 'BOX_HOR_CABEC', 35)
	oView:CreateHorizontalBox( 'BOX_HOR_MEIO' , 50)
	oView:CreateHorizontalBox( 'BOX_HOR_RODAP', 15)

	oView:CreateFolder( 'FOLDER', 'BOX_HOR_MEIO' )

	oView:AddSheet( 'FOLDER', 'ABA_SLD_ORIG', 'Valores de Origem da Transposição'  )
	oView:AddSheet( 'FOLDER', 'ABA_SLD_DEST', 'Valores de Destino da Transposição' )

	oView:CreateHorizontalBox( 'BOX_HOR_ABA_SLD_ORIG', 100,,, 'FOLDER', 'ABA_SLD_ORIG' )
	oView:CreateHorizontalBox( 'BOX_HOR_ABA_SLD_DEST', 100,,, 'FOLDER', 'ABA_SLD_DEST' )

	oView:CreateVerticalBox( 'BOX_VER_MEIO_ESQ', 50, 'BOX_HOR_RODAP' )
	oView:CreateVerticalBox( 'BOX_VER_MEIO_DIR', 50, 'BOX_HOR_RODAP' )

	//-- Posicionando as view´s e seus boxe´s correspondenetes

	oView:SetOwnerView('CABEC','BOX_HOR_CABEC')

	oView:SetOwnerView('GRID_SLD_ORIG','BOX_HOR_ABA_SLD_ORIG')
	oView:SetOwnerView('GRID_SLD_DEST','BOX_HOR_ABA_SLD_DEST')

	oView:SetOwnerView('CALC_SLD_ORIG','BOX_VER_MEIO_ESQ')
	oView:SetOwnerView('CALC_SLD_DEST','BOX_VER_MEIO_DIR')

Return oView

/*/{Protheus.doc} Distribuir
Faz a distribuição do saldo total de transposição de origem para a transposição de destino
com base nos percentuais de uma Regra de Distribuição cadastrada.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@param oView, Objeto, Objeto que representa a view do modelo de dados
/*/
//Static Function Distribuir( oView )
//
//	ApMsgInfo( 'Aplicar Regra de Distribuição' )
//
//Return

/*/{Protheus.doc} PCOM099
Processa a transposição gerando os lançamentos orçamentários.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
/*/
User Function PCOM099()

	Local aArea     := GetArea()
	Local cSeek     := xFilial( 'ZK2' ) + ZK1->ZK1_CODIGO
	Local cMsg1     := If( ! ZK1->ZK1_PROCES, 'Deseja Processar a Transposição ?', 'Transposição já processada, deseja cancelar o processamento ?' )
	Local cMsg2     := If( ! ZK1->ZK1_PROCES, 'Transposição Processada.', 'Processamento da Transposição Cancelado.' )
	Local aParambox := {}
	Local aRet      := {}
	Local aAux      := {}

	aAdd( aAux, GetSx3Cache( 'AKB_PROCES', 'X3_TITULO'  ) )
	aAdd( aAux, GetSx3Cache( 'AKB_PROCES', 'X3_TAMANHO' ) )
	aAdd( aAux, GetSx3Cache( 'AKB_PROCES', 'X3_PICTURE' ) )

	aAdd( aParambox, { 1, aAux[1], Space( aAux[2] ), aAux[3],'.T.','AKB','.T.',, .T. } )

	aSize( aAux, 0 )

	aAdd( aAux, GetSx3Cache( 'AKB_ITEM', 'X3_TITULO'  ) )
	aAdd( aAux, GetSx3Cache( 'AKB_ITEM', 'X3_TAMANHO' ) )
	aAdd( aAux, GetSx3Cache( 'AKB_ITEM', 'X3_PICTURE' ) )

	aAdd( aParambox, { 1, aAux[1], Space( aAux[2] ), aAux[3], '.T.',,'.T.',, .T. } )

	aAdd( aParambox, { 2, 'Deseja exibir os lançamentos', 1, { 'Sim', 'Não' },, '.T.', .F. } )

	If ApMsgYesNo( cMsg1, 'PCOM099' ) .And. ParamBox( aParamBox, '', @aRet,,,,,,, 'PCOA099',.T.,.T.)

		DbSelectArea( 'ZK2' )
		ZK2->( DbSetOrder( 1 ) ) //ZK2_FILIAL, ZK2_CODIGO, ZK2_ORIDES, ZK2_ITEM

		If DbSeek( cSeek )

			PcoIniLan( aRet[1], .T. )

			Do While ZK2->( ! Eof() ) .And. ZK2->( xFilial() + ZK2->ZK2_CODIGO ) == cSeek

				PcoDetLan( aRet[1], aRet[2], 'PCOA099', ZK1->ZK1_PROCES )

				ZK2->( DbSkip() )

			EndDo

			PcoFinLan( aRet[1], aRet[3] == 1, .T., .T. )

		EndIf

		RecLock( 'ZK1', .F. )

		ZK1->ZK1_PROCES := ! ZK1->ZK1_PROCES

		MsUnlock()

		ApMsgInfo( cMsg2, 'PCOM099' )

	EndIf

	RestArea( aArea )

Return

/*/{Protheus.doc} TudoOk
Validação do model, onde é verificado se os saldos de origem e destino da transposição são iguais e
bloqueia a excçlusão de uma transposição já processada.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@param oModel, objeto, Obejto que representa o modelo de dados.
@return Lógico, Indica se o Model é válido.
/*/
Static Function TudoOk( oModel )

	Local oMdSldOrig := oModel:GetModel( 'CALC_SLD_ORIG' )
	Local oMdSldDest := oModel:GetModel( 'CALC_SLD_DEST' )
	Local lRet       := .T.

	If oMdSldOrig:GetValue('ZK2_VALOR_SUM') # oMdSldDest:GetValue('ZK2_VALOR_SUM')

		Help( ,, 'PCOA099',, 'Os Saldos de Origem e de Destino da Transposição devem ser iguais.',;
		1, 0,,,,,, { 'Verifique os valores de digitados de Origem e de Destino da Transposição.' } )

		lRet := .F.

	ElseIf ZK1->ZK1_PROCES .And. oModel:GetOperation() == MODEL_OPERATION_DELETE

		Help( ,, 'PCOA099',, 'Não é permitido excluir uma transposição já processada.',;
		1, 0,,,,,, { 'Cancele o processamento da transposição antes de excluí-la.' } )

		lRet := .F.

	End If

Return lRet

/*/{Protheus.doc} PreOk
Pré Validação do model, onde é bloqueado a alteração transposições já processadas.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@param oModel, objeto, Obejto que representa o modelo de dados.
@return Lógico, Indica se é permitido excluir ou alterar a transposição.
/*/
Static Function PreOk( oModel )

	Local lRet       := .T.

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. oModel:IsCopy()

		// Quando feita cópia de uma transposição, define:
		// A DataBase como data da transposição
		// O usuário corrente como autor da transposição
		// Que a Transposição não foi processada

		oModel:GetModel('CABEC'):SetValue( 'ZK1_DATA'  , dDataBase                  )
		oModel:GetModel('CABEC'):SetValue( 'ZK1_USERID', RetCodUsr()                )
		oModel:GetModel('CABEC'):SetValue( 'ZK1_USERNM', UsrFullName( RetCodUsr() ) )
		oModel:GetModel('CABEC'):SetValue( 'ZK1_PROCES', .F.                        )

	End If

	If ZK1->ZK1_PROCES .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		Help( ,, 'PCOA099',, 'Não é permitido Alterar uma transposição já processada.',;
		1, 0,,,,,, { 'Cancele o processamento da transposição antes de alterá-la.' } )

		lRet := .F.

	End If

Return lRet

/*/{Protheus.doc} P99VLENT
Função utilizada na validação dos campos
ZK2_CO, ZK3_CO, ZK2_CC, ZK3_CC, ZK2_ITCTB, ZK3_ITCTB, ZK2_CLVLR, ZK3_CLVLR.
É verificado se entidade existe no cadastro e se não é sintética.
Se o campo estiver vazio retorna verdadeiro.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@return Lógico, Indica se o campo é válido ou não
/*/
User Function P99VLENT()

	Local cVarNome   := StrTran( ReadVar(), 'M->', '' ) // Nome do campo de origem da validação.
	Local cVarTitulo := GetSx3Cache( cVarNome, 'X3_TITULO' ) // Título do campo de origem da validação.
	Local cTabTpEnt  := '' // Nome da tabela de cadastro da entidade
	Local cVarTpEnt  := '' // Nome do campo do cadastro da entidade que indica se é analítica ou sintética
	Local cSeek      := ''
	Local lRet       := .T.

	// Verifica se o campo está vazio
	If ! Vazio()

		// Define o nome do campo do cadastro da entidade que indica se ela é analítica ou sintética
		If cVarNome == 'ZK2_CO'

			cVarTpEnt := 'AK5_TIPO'

		ElseIf cVarNome == 'ZK2_CC'

			cVarTpEnt := 'CTT_CLASSE'

		ElseIf cVarNome == 'ZK2_ITCTB'

			cVarTpEnt := 'CTD_CLASSE'

		ElseIf cVarNome == 'ZK2_CLVLR'

			cVarTpEnt :='CTH_CLASSE'

		EndIf

		// Define a tabela de cadastro da entidade
		cTabTpEnt := StrTokArr2( cVarTpEnt, '_', .T. )[1]

		// Verifica se a Entidade existe no cadastro
		If lRet := ExistCpo( cTabTpEnt, FwFldGet( cVarNome ) )

			// Verifica se a entidade é analítica.

			cSeek := xFilial( cTabTpEnt ) + FwFldGet( cVarNome )

			If Posicione( cTabTpEnt, 1, cSeek, cVarTpEnt ) == '1'

				lRet := .F.

				Help( ,, 'PCOA099',, 'Foi informada um entidade sintética no campo ' +;
				cVarTitulo + ' (' + cVarNome + ')' + '.',;
				1, 0,,,,,, { 'Informe uma entidade analítica.' } )

			End If

		End If

	EndIf

Return lRet