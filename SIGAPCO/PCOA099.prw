#Include 'Totvs.Ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} PCOA099
Rotina de Cadastro de Transposi��o de Saldos entre contas.
@author Elton Teododo Alves
@since 05/07/2019
@version 12.1.23

@TODO Definir a distribui��o do total de saldo de origem para o saldo de destino com as regras de distribui��o.
@TODO Nas tabelas ZK2 e ZK3 definir campos para classe de valor, opera��o, unidade or�ament�ria
@TODO Definir o processamento da transposi��o efetivando os lan�amentos or�ament�rios.
/*/
User Function PCOA099()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('ZK1')

	oBrowse:SetDescription( 'Transposi��o de Saldos' )

	oBrowse:AddLegend( 'ZK1_PROCES==.T.' , 'RED'  , 'Transposi��o Processada'     )
	oBrowse:AddLegend( 'ZK1_PROCES==.F.' , 'GREEN', 'Transposi��o N�o Processada' )

	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Gera o array com as rotinas que estar�o dispon�veis no Browser.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@return Array, Array com as rotinas que estar�o dispon�veis no Browser.
/*/
Static Function MenuDef()

	Local aRotina := FWMVCMenu( 'PCOA099' )

	aAdd( aRotina, { 'Processar a Transposi��o', 'U_PCOM099()', 0, 6, 0, NIL } )

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

	oModel:SetDescription( 'Transposi��o de Saldos' )
	oModel:getModel( 'CABEC' ):SetDescription( 'Transposi��o'            )
	oModel:getModel( 'GRID_SLD_ORIG' ):SetDescription( 'Origem da Transposi��o'  )
	oModel:getModel( 'GRID_SLD_DEST' ):SetDescription( 'Destino da Transposi��o' )

	oModel:AddCalc( 'CALC_SLD_ORIG', 'CABEC', 'GRID_SLD_ORIG', 'ZK2_VALOR', 'ZK2_VALOR_SUM', 'SUM',,,'Total da Transposi��o de Origem' )
	oModel:AddCalc( 'CALC_SLD_DEST', 'CABEC', 'GRID_SLD_DEST', 'ZK2_VALOR', 'ZK2_VALOR_SUM', 'SUM',,,'Total da Transposi��o de Destino' )

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

	//-- Definindo as sub view�s

	oView:AddField('CABEC' , oStrCabec,'CABEC' )

	oView:AddGrid('GRID_SLD_ORIG' , oStrItens,'GRID_SLD_ORIG')
	oView:AddGrid('GRID_SLD_DEST' , oStrItens,'GRID_SLD_DEST')


	oView:AddIncrementField( 'GRID_SLD_ORIG', 'ZK2_ITEM' )
	oView:AddIncrementField( 'GRID_SLD_DEST', 'ZK2_ITEM' )

	oView:AddField('CALC_SLD_DEST', oStrZK3Clc,'CALC_SLD_DEST')
	oView:AddField('CALC_SLD_ORIG', oStrZK2Clc,'CALC_SLD_ORIG')

	//-- Definindo Bot�es

	// oView:AddUserButton('Aplicar Regra de Distribui��o','',{ |oView| Distribuir( oView ) },;
	// 'Aplica uma regra de distribui��o ao valor total a ser transposto.',286,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})

	//-- Os Boxes da tela

	oView:CreateHorizontalBox( 'BOX_HOR_CABEC', 35)
	oView:CreateHorizontalBox( 'BOX_HOR_MEIO' , 50)
	oView:CreateHorizontalBox( 'BOX_HOR_RODAP', 15)

	oView:CreateFolder( 'FOLDER', 'BOX_HOR_MEIO' )

	oView:AddSheet( 'FOLDER', 'ABA_SLD_ORIG', 'Valores de Origem da Transposi��o'  )
	oView:AddSheet( 'FOLDER', 'ABA_SLD_DEST', 'Valores de Destino da Transposi��o' )

	oView:CreateHorizontalBox( 'BOX_HOR_ABA_SLD_ORIG', 100,,, 'FOLDER', 'ABA_SLD_ORIG' )
	oView:CreateHorizontalBox( 'BOX_HOR_ABA_SLD_DEST', 100,,, 'FOLDER', 'ABA_SLD_DEST' )

	oView:CreateVerticalBox( 'BOX_VER_MEIO_ESQ', 50, 'BOX_HOR_RODAP' )
	oView:CreateVerticalBox( 'BOX_VER_MEIO_DIR', 50, 'BOX_HOR_RODAP' )

	//-- Posicionando as view�s e seus boxe�s correspondenetes

	oView:SetOwnerView('CABEC','BOX_HOR_CABEC')

	oView:SetOwnerView('GRID_SLD_ORIG','BOX_HOR_ABA_SLD_ORIG')
	oView:SetOwnerView('GRID_SLD_DEST','BOX_HOR_ABA_SLD_DEST')

	oView:SetOwnerView('CALC_SLD_ORIG','BOX_VER_MEIO_ESQ')
	oView:SetOwnerView('CALC_SLD_DEST','BOX_VER_MEIO_DIR')

Return oView

/*/{Protheus.doc} Distribuir
Faz a distribui��o do saldo total de transposi��o de origem para a transposi��o de destino
com base nos percentuais de uma Regra de Distribui��o cadastrada.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@param oView, Objeto, Objeto que representa a view do modelo de dados
/*/
//Static Function Distribuir( oView )
//
//	ApMsgInfo( 'Aplicar Regra de Distribui��o' )
//
//Return

/*/{Protheus.doc} PCOM099
Processa a transposi��o gerando os lan�amentos or�ament�rios.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
/*/
User Function PCOM099()

	Local aArea     := GetArea()
	Local cSeek     := xFilial( 'ZK2' ) + ZK1->ZK1_CODIGO
	Local cMsg1     := If( ! ZK1->ZK1_PROCES, 'Deseja Processar a Transposi��o ?', 'Transposi��o j� processada, deseja cancelar o processamento ?' )
	Local cMsg2     := If( ! ZK1->ZK1_PROCES, 'Transposi��o Processada.', 'Processamento da Transposi��o Cancelado.' )
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

	aAdd( aParambox, { 2, 'Deseja exibir os lan�amentos', 1, { 'Sim', 'N�o' },, '.T.', .F. } )

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
Valida��o do model, onde � verificado se os saldos de origem e destino da transposi��o s�o iguais e
bloqueia a exc�lus�o de uma transposi��o j� processada.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@param oModel, objeto, Obejto que representa o modelo de dados.
@return L�gico, Indica se o Model � v�lido.
/*/
Static Function TudoOk( oModel )

	Local oMdSldOrig := oModel:GetModel( 'CALC_SLD_ORIG' )
	Local oMdSldDest := oModel:GetModel( 'CALC_SLD_DEST' )
	Local lRet       := .T.

	If oMdSldOrig:GetValue('ZK2_VALOR_SUM') # oMdSldDest:GetValue('ZK2_VALOR_SUM')

		Help( ,, 'PCOA099',, 'Os Saldos de Origem e de Destino da Transposi��o devem ser iguais.',;
		1, 0,,,,,, { 'Verifique os valores de digitados de Origem e de Destino da Transposi��o.' } )

		lRet := .F.

	ElseIf ZK1->ZK1_PROCES .And. oModel:GetOperation() == MODEL_OPERATION_DELETE

		Help( ,, 'PCOA099',, 'N�o � permitido excluir uma transposi��o j� processada.',;
		1, 0,,,,,, { 'Cancele o processamento da transposi��o antes de exclu�-la.' } )

		lRet := .F.

	End If

Return lRet

/*/{Protheus.doc} PreOk
Pr� Valida��o do model, onde � bloqueado a altera��o transposi��es j� processadas.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@param oModel, objeto, Obejto que representa o modelo de dados.
@return L�gico, Indica se � permitido excluir ou alterar a transposi��o.
/*/
Static Function PreOk( oModel )

	Local lRet       := .T.

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. oModel:IsCopy()

		// Quando feita c�pia de uma transposi��o, define:
		// A DataBase como data da transposi��o
		// O usu�rio corrente como autor da transposi��o
		// Que a Transposi��o n�o foi processada

		oModel:GetModel('CABEC'):SetValue( 'ZK1_DATA'  , dDataBase                  )
		oModel:GetModel('CABEC'):SetValue( 'ZK1_USERID', RetCodUsr()                )
		oModel:GetModel('CABEC'):SetValue( 'ZK1_USERNM', UsrFullName( RetCodUsr() ) )
		oModel:GetModel('CABEC'):SetValue( 'ZK1_PROCES', .F.                        )

	End If

	If ZK1->ZK1_PROCES .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		Help( ,, 'PCOA099',, 'N�o � permitido Alterar uma transposi��o j� processada.',;
		1, 0,,,,,, { 'Cancele o processamento da transposi��o antes de alter�-la.' } )

		lRet := .F.

	End If

Return lRet

/*/{Protheus.doc} P99VLENT
Fun��o utilizada na valida��o dos campos
ZK2_CO, ZK3_CO, ZK2_CC, ZK3_CC, ZK2_ITCTB, ZK3_ITCTB, ZK2_CLVLR, ZK3_CLVLR.
� verificado se entidade existe no cadastro e se n�o � sint�tica.
Se o campo estiver vazio retorna verdadeiro.
@author Elton Teodoro Alves
@since 05/07/2019
@version 12.1.23
@return L�gico, Indica se o campo � v�lido ou n�o
/*/
User Function P99VLENT()

	Local cVarNome   := StrTran( ReadVar(), 'M->', '' ) // Nome do campo de origem da valida��o.
	Local cVarTitulo := GetSx3Cache( cVarNome, 'X3_TITULO' ) // T�tulo do campo de origem da valida��o.
	Local cTabTpEnt  := '' // Nome da tabela de cadastro da entidade
	Local cVarTpEnt  := '' // Nome do campo do cadastro da entidade que indica se � anal�tica ou sint�tica
	Local cSeek      := ''
	Local lRet       := .T.

	// Verifica se o campo est� vazio
	If ! Vazio()

		// Define o nome do campo do cadastro da entidade que indica se ela � anal�tica ou sint�tica
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

			// Verifica se a entidade � anal�tica.

			cSeek := xFilial( cTabTpEnt ) + FwFldGet( cVarNome )

			If Posicione( cTabTpEnt, 1, cSeek, cVarTpEnt ) == '1'

				lRet := .F.

				Help( ,, 'PCOA099',, 'Foi informada um entidade sint�tica no campo ' +;
				cVarTitulo + ' (' + cVarNome + ')' + '.',;
				1, 0,,,,,, { 'Informe uma entidade anal�tica.' } )

			End If

		End If

	EndIf

Return lRet