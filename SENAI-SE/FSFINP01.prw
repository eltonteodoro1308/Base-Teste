#Include 'Protheus.ch'
#Include "XMLXFun.ch"

//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSFINP01
Fonte para atualizar os dados contabeis via WS (RM)
        
@author 	Leandro de Faria
@since 		22/07/2014
@version 	P11
@obs  		Projeto FS007171 - Req. 03
@return	Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
18/08/2014 Claudio Silva		Ajustes no fonte (Tratamento multiempresa)
19/09/2014 Fábio Consentino	Ajustes no fonte (Validação dos campos a serem alterados na SE1)
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
User Function FSFINP01(aParam) 

Local cCodEmp	:= ""
Local cCodFil	:= ""
Local cAlias 	:= ""	
Local cErrWs	:= ""
Local lWsRet 	:= .T.
Local aDadCnt	:= {}

Default aParam:= {'03','01'}

cCodEmp:= aParam[1]
cCodFil:= aParam[2]

ConOut("***********************************************************")
ConOut("* Iniciando o processo de atualização contabil na empresa "+cCodEmp+". Aguarde! "+DToC(Date())+" "+Time() )
ConOut("***********************************************************")

If (U_FSSemaf("FSFINP01."+cCodEmp+cCodFil))

	//Conecta na filial 01 para iniciar o Job
	RpcSetType(3)
	RpcSetEnv(cCodEmp,cCodFil)
	
	cFilOld:= cFilAnt

	//Alias temporario
	cAlias := GetNextAlias()

	//Funcao para carregar os titulos a serem atualizados
	FQryTit(@cAlias)
	
	//Verifica se foram encontrados registros
	If ((cAlias)->(!Eof()))
	
		//Varre os titulos
		While ((cAlias)->(!Eof()))
			cErrWs	:= ""
			aDadCnt:= {}
			
			//Funcao para consumir o WS do RM
			lWsRet := FWsRm((cAlias)->TIT_COLIGADA,(cAlias)->E1_FILIAL,Val((cAlias)->TIT_IDLAN),(cAlias)->E1_PREFIXO,;
						  		(cAlias)->E1_NUM,(cAlias)->E1_PARCELA,(cAlias)->E1_TIPO,(cAlias)->E1_CLIENTE,(cAlias)->E1_LOJA,;
						  		@cErrWs,@aDadCnt)

//			aAdd(aDadCnt,{"E1_CCC"		,"1231 "		,Nil}) 	//Centro de Custo Credito
//			aAdd(aDadCnt,{"E1_ITEMC"		,"10030106C"	,Nil}) 	//Item Credito
//			aAdd(aDadCnt,{"E1_CLVLCR"	,"3 "			,Nil})		//Classe de Valor Credito
//			aAdd(aDadCnt,{"E1_CREDIT"	,"11305001 "	,Nil}) 	//Contra Credito
//			aAdd(aDadCnt,{"E1_DEBITO"	,"11305002 "	,Nil}) 	//Classe de Valor Credito

			//Caso nao tenha erros ao consumir o WS, chama a rotina para atualizar o titulo posicionado
			If (lWsRet)

				cFilAnt:= (cAlias)->E1_FILIAL
			
				//Atualiza os dados na SE1
				FAtuSE1(@aDadCnt,(cAlias)->SE1RECNO,(cAlias)->TIT_IDLAN,@cErrWs)
			
			EndIf
			
			//Limpa variaveis de controle
			cErrWs := ""	
			
			(cAlias)->(dbSkip())	
		EndDo
	
	Else	
		ConOut("***********************************************************")
		ConOut("* Não existe titulos a serem atualizados. !	    			  ")
		ConOut("***********************************************************")	
	EndIf

	cFilAnt:= cFilOld

	//Fecha a conexao
	RpcClearEnv()
	
EndIf

ConOut("***********************************************************")
ConOut("* Fim do processo de atualização cotabil. Aguarde!	    	  ")
ConOut("***********************************************************")

Return(Nil)

//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FQryTit
Funcao para executar a query, onde sera selecionados os titulos
        
@author 		Leandro de Faria
@since 			22/07/2014
@version 		P11
@param			cAlias - Alias da tabela temporaria
@obs  			Projeto FS007171 - Req. 03
@return		Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
Static Function FQryTit(cAlias)

Local nColigada:= Iif(cEmpAnt=='99',1,Val(cEmpAnt))

//Executa a query
BEGINSQL ALIAS cAlias

SELECT	DISTINCT	E1.E1_FILIAL,
					TI.TIT_COLIGADA,
					TI.TIT_IDLAN,
					TI.TIT_COLIGADA,
					E1.E1_PREFIXO,
					E1.E1_NUM,
					E1.E1_PARCELA,
					E1.E1_TIPO,
					E1.E1_CLIENTE,
					E1.E1_LOJA,
					E1.E1_NOMCLI,
					E1.E1_VALOR,
					E1.E1_EMISSAO,
					E1.R_E_C_N_O_ SE1RECNO
				
	FROM %table:SE1% E1 INNER JOIN INT_TITULO TI ON (	E1.E1_FILIAL	= TI.TIT_FILIAL
															AND E1.E1_IDLAN = TI.TIT_IDLAN)

	WHERE E1.%notDel%
	AND (E1.E1_ZATINT = ' ' OR E1.E1_ZATINT = '2')
	AND TI.TIT_COLIGADA = %Exp:nColigada%
 	AND E1.E1_IDLAN<>0
	AND E1.E1_LA<>'S'
	AND (E1.E1_CCC=' ' OR E1_ITEMC=' ' OR E1_CLVLCR=' ' OR 
		E1_CREDIT=' ' OR E1_DEBITO=' ')
		
	ORDER BY E1.E1_FILIAL,E1.E1_PREFIXO,E1.E1_NUM,E1.E1_PARCELA,E1.E1_TIPO

ENDSQL

Return(Nil)

//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWsRm
Funcao para consumiro WS do RM
        
@author 		Leandro de Faria
@since 			22/07/2014
@version 		P11
@param			nEmpTit 	- Empresa 
@param			cFilTit	- Filial posicionada
@param			nIdLan		- ID do lancamento na tabela de integracao
@param			cPrefixo	- Prefixo
@param			cNum		- Numero
@param			cParcela	- Parcela
@param			cTipo		- Tipo
@param			cCliente	- Cliente
@param			cLoja		- Loja
@param			cErrWs		- Mensagem de erro retornada do WS
@param			aDadCnt	- Armazena o retorno dos dados contabeis
@obs  			Projeto FS007171 - Req. 03
@return		lWsRet		- .T. Retorno OK do RM
							  .F. Erro ao consumir o WS	
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
Static Function FWsRm(nEmpTit,cFilTit,nIdLan,cPrefixo,cNum,cParcela,cTipo,cCliente,cLoja,cErrWs,aDadCnt)

Local lWsRet		:= .T.
Local oWsRM 		:= Nil
Local cError   	:= ""
Local cWarning 	:= ""
Local oXml			:= Nil
Local cXml			:= ""

//Cria o objeto do WS RM
oWsRM := WSwsIntegracaoContabil():New()

//Passa os parametros para o WS RM
oWsRM:ncodColigada 	:= nEmpTit
oWsRM:nidLan		:= nIdLan
oWsRM:BuscaDadosContabeis(nEmpTit,nidLan)

//Retorno do WS RM
cXml := oWsRM:cBuscaDadosContabeisResult

//Retornando NIL
If Empty(cXml)
	//Retorno do WS	
	ConOut("***********************************************************")
	ConOut("* Erro ao consumir WS RM - IdLan: "+cValToChar(nIdLan)+" Erro: Retorno Nulo")
	ConOut("***********************************************************")
	Return(.F.)
EndIf

//Convertte o Xml para o padrao UTF-8,
cXml := StrTran(cXml,"utf-16","ISO-8859-1")

//Gera o Objeto XML
oXml := XmlParser(cXml, "_", @cError, @cWarning)

//Verifica se retornou o objeto
If (oXml <> Nil)

	//Verifica se retornou erro na integracao
	If (AllTrim(oXml:_DADOSCONTABEIS:_STATUS:TEXT) == "S")
		
		ConOut("***********************************************************")
		ConOut("* Carregando os dados contabeis do titulo - IdLan: "+cValToChar(nIdLan))
		ConOut("***********************************************************")
		
		aAdd(aDadCnt,{"E1_CCC"		,oXml:_DADOSCONTABEIS:_E1_CCC:TEXT			,Nil}) 	//Centro de Custo Credito
		aAdd(aDadCnt,{"E1_ITEMC"		,oXml:_DADOSCONTABEIS:_E1_ITEMC:TEXT		,Nil}) 	//Item Credito
		aAdd(aDadCnt,{"E1_CLVLCR"	,oXml:_DADOSCONTABEIS:_E1_CLVLCR:TEXT		,Nil})		//Classe de Valor Credito
		aAdd(aDadCnt,{"E1_CREDIT"	,oXml:_DADOSCONTABEIS:_E1_CREDIT:TEXT		,Nil}) 	//Contra Credito
		aAdd(aDadCnt,{"E1_DEBITO"	,oXml:_DADOSCONTABEIS:_E1_DEBITO:TEXT		,Nil}) 	//Classe de Valor Credito
		aAdd(aDadCnt,{"E1_NCCZ4"		,oXml:_DADOSCONTABEIS:_E1_NCCZ4:TEXT		,Nil}) 	//Número do Cartão de Crédito 
		aAdd(aDadCnt,{"E1_TITZ4"		,oXml:_DADOSCONTABEIS:_E1_TITZ4:TEXT		,Nil})		//Nome do Titular do Cartão 		
	Else	
		//Retorno do WS
		cErrWs := AllTrim(oXml:_DADOSCONTABEIS:_MENSAGEM:TEXT)
		lWsRet := .F.
		
		ConOut("***********************************************************")
		ConOut("* Erro ao consumir WS RM - IdLan: "+cValToChar(nIdLan)+" Erro: "+AllTrim(cErrWs))
		ConOut("***********************************************************")		
	EndIf

Else	
	//Retorno do WS
	cErrWs := "Erro no retorno do WS: "+cError
	lWsRet := .F.
	
	ConOut("***********************************************************")
	ConOut("* Erro ao consumir WS RM - IdLan: "+cValToChar(nIdLan)+" Erro: "+AllTrim(cErrWs))
	ConOut("***********************************************************")
EndIf

Return(lWsRet)

//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuSE1
Funcao para atualizar os dados na tabela SE1
        
@author 		Leandro de Faria
@since 			24/07/2014
@version 		P11
@param			aDadCnt 	- Dados contabeis
@param			nSE1Rec 	- Recno do registro na SE1
@param			nIdLan		- ID do lancamento na tabela de integracao
@param			cErrWs		- Mensagem de erro retornada do WS
@return		Nil
@obs  			Projeto FS007171 - Req. 03
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
Static Function FAtuSE1(aDadCnt,nSE1Rec,nIdLan,cErrWs)

Local aAreas 	:= {SE1->(GetArea()),GetArea()}
Local lLinOk	:= .F.
Local lGrvOk	:= .F.

SE1->(dbGoTo(nSE1Rec))

BeginTran()
	
	//Validação dos registros
	If lLinOk := FValCpos(aDadCnt,nIdLan)
		//Gravação dos registros
		lGrvOk	:= U_FSGrvReg(aDadCnt,.F.,"SE1")
	EndIf
	
	//Verifica se ocorreu algum erro
	If !lGrvOk
		
		// Libera sequencial
		DisarmTransaction() 
		
		ConOut("***********************************************************")
		ConOut("* Erro ao atualizar campos - IdLan: "+cValToChar(nIdLan)+" Erro: "+MemoRead(NomeAutoLog()))
		ConOut("***********************************************************")
	
		//Apaga historio do execauto
		FERASE(NomeAutoLog())	
	Else
	
		//Atualiza o flag do registro, somente se todos os campos estiverem preenchidos - Fábio Consentino 19/09/14 
		If !Empty(SE1->E1_CCC) .And. !Empty(SE1->E1_ITEMC) .And. !Empty(SE1->E1_CLVLCR) .And. !Empty(SE1->E1_CREDIT) .And. !Empty(SE1->E1_DEBITO)
			SE1->(RecLock("SE1",.F.))
			SE1->E1_ZATINT := "1"
			SE1->(MsUnLock())  
			
			ConOut("***********************************************************")
			ConOut("* Titulo atualizado - IdLan: "+cValToChar(nIdLan))
			ConOut("***********************************************************")
		Else
			ConOut("***********************************************************")
			ConOut("* O titulo foi processado, mas não foi totalmente atualizado - IdLan: "+cValToChar(nIdLan))
			ConOut("***********************************************************")
		EndIf

		//Fim
		EndTran()
	
	EndIf	  
	
MsUnlockAll()

//Restaura a area padrao
AEval(aAreas, {|x| RestArea(x)})

Return(Nil)

//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSGrvReg
Função usada para gravacao de registros em tabelas

@author claudiol
@since 06/05/2014
@version 1.0
@param aDados, array, Vetor com informações de campos e valores {campo, valor}
@param lModo, logico, Informa o modo de travacao, T=Novo registro, F=Alteracao
@param cAlias, character, Nome da tabela a ser modificada
@param nRecno, numérico, Recno do registro
@return lRet, .T. efetuado lock com sucesso .F. falha na execucao do lock
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------------------------------------------------------------------------
User Function FSGrvReg(aDados,lModo,cAlias,nRecno,lExclui)

Local  aAreAtu 	:= {GetArea()} //Salva todas as areas num array
Local 	nXi			:= 0
Local	lRet		:= .T.
Local 	nPosCmp	:= 0

Default aDados	:= {}
Default lModo		:= .T.
Default nRecno	:= 0
Default lExclui	:= .F.

If (lRet:=(cAlias)->(RecLock(cAlias,lModo)))
	If !lExclui
		For nXi:=1 To Len(aDados)
			If (nPosCmp:=(cAlias)->(FieldPos(aDados[nXi][1])) ) > 0
				//Verifica se o tipo de dado a ser gravado é o mesmo do campo
				If ValType((cAlias)->(FieldGet(nPosCmp)))==ValType(aDados[nXi][2])		
					(cAlias)->(FieldPut(nPosCmp,aDados[nXi][2]))
				EndIf
			EndIf
		Next nXi
		nRecno:= (cAlias)->(Recno())
	Else
		(cAlias)->(dbDelete())
	EndIf  
   (cAlias)->(MsUnlock())
EndIf

aEval(aAreAtu, {|x| RestArea(x) }) // restaurando todas as areas dentro do array.

Return(lRet)

//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FValCpos
Funcao para validar os campos que serão alterados
        
@author 		Fábio Consentino
@since 			19/09/2014
@version 		P11
@param			aDadCnt 	- Dados contabeis
@param			nIdLan		- ID do lancamento na tabela de integracao
@return		lRetFun	- .T. ou .F.
@obs  			Projeto FS007171 - Req. 03
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
Static Function FValCpos(aDadCnt,nIdLan)

Local aAreas 	:= {GetArea(),CTT->(GetArea()),CT1->(GetArea()),CTH->(GetArea()),CTD->(GetArea())}
Local lRetFun	:= .T.
Local cTabVal	:= ""
Local cCpoInv	:= ""
Local nX		:= 0
		
For nX := 1 To Len(aDadCnt)

	If aDadCnt[nX,1] == "E1_CCC"	
		cTabVal	:= "T"
	ElseIf aDadCnt[nX,1] $ "E1_CREDIT,E1_DEBITO"	
		cTabVal	:= "1"
	ElseIf aDadCnt[nX,1] == "E1_CLVLCR"	
		cTabVal	:= "H"	
	ElseIf aDadCnt[nX,1] == "E1_ITEMC"	
		cTabVal	:= "D"	
	Else
		cTabVal	:= ""
	EndIf
	
	If !Empty(cTabVal)
		("CT"+cTabVal)->(DBSetOrder(1))
		If !Empty(aDadCnt[nX,2])
			If !("CT"+cTabVal)->(DBSeek(xFilial("CT"+cTabVal)+aDadCnt[nX,2])) 
				lRetFun := .F.
				cCpoInv += aDadCnt[nX,1]+", "
			EndIf
		EndIf
	EndIf
	
Next nX

If !lRetFun
	ConOut("***********************************************************")
	ConOut("* Valor(es) inválido(s) no(s)' campo(s): "+cCpoInv+"' - IdLan: "+cValToChar(nIdLan))
	ConOut("***********************************************************")
EndIf

//Restaura a area padrao
AEval(aAreas, {|x| RestArea(x)})

Return(lRetFun)
