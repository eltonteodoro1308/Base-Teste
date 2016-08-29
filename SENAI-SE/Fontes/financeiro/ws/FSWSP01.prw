#Include 'Protheus.ch'
#Include "TBIConn.ch"
#Include "APWEBSRV.CH"


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSWSP01
WS principal para inclusao de titulos a receber
        
@author 		Leandro de Faria
@since 		15/07/2014
@version 		P11
@param
@obs  			Projeto FS007168 - Req. 03
@return		Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
WSSERVICE FSWSP01 DESCRIPTION "Inclusão de Títulos a receber"

//Atributos do WS
WSDATA cEmpTit	AS STRING
WSDATA cFilTit	AS STRING
WSDATA cParcela	AS STRING
WSDATA cCliente	AS STRING
WSDATA dDtVenc	AS DATE
WSDATA nValor		AS FLOAT
WSDATA nVlCruz	AS FLOAT
WSDATA cCcc		AS STRING
WSDATA cItmC		AS STRING
WSDATA cClVrl		AS STRING
WSDATA cCredit	AS STRING	
WSDATA cDebito	AS STRING
WSDATA cCcd		AS STRING
WSDATA cItEmd		AS STRING
WSDATA cClVldb	AS STRING	
WSDATA cNccZ4 	AS STRING
WSDATA cTitZ4 	AS STRING
WSDATA cNumCtr  	AS STRING
WSDATA cEmpCnt	AS STRING
WSDATA cFilCnt  	AS STRING
WSDATA cContrato	AS STRING
  
//Retorno do processamento do titulo
WSDATA TITRESULT	AS FSWSP01_TITRESULT

//Retorno da consulta do titulo
WSDATA LOCATIT	AS FSWSP01_LOCATIT

//Metodo para inserir o titulo
WSMETHOD FSWSP01_GRVTIT DESCRIPTION "Grava o título no Contas a Receber (SE1)"

//Metodo para consultar o titulo
WSMETHOD FSWSP01_CONTIT DESCRIPTION "Consulta Titulo"

ENDWSSERVICE


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSWSP01_TITRESULT
Metodo para o retorno da inclusao do titulo
        
@author 		Leandro de Faria
@since 		15/07/2014
@version 		P11
@param
@obs  			Projeto FS007168 - Req. 03
@return		Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
WSSTRUCT FSWSP01_TITRESULT

WSDATA LGRVTIT	AS BOOLEAN
WSDATA CMSGRET	AS STRING

ENDWSSTRUCT


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSWSP01_LOCATIT
Metodo para o retorno da consulta do titulo
        
@author 		Leandro de Faria
@since 		17/07/2014
@version 		P11
@param
@obs  			Projeto FS007168 - Req. 03
@return		Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
WSSTRUCT FSWSP01_LOCATIT

WSDATA LTITGRV	AS BOOLEAN

ENDWSSTRUCT


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSWSP01_GRVTIT
Metodo para gravar o titulo na tabela SE1 (Contas a Receber)
        
@author 		Leandro de Faria
@since 			15/07/2014
@version 		P11
@param			cFilTit 	- Filial do Titulo
@param			cParcela 	- Parcela
@param			cCliente	- Cliente
@param			dDtVenc	- Data Vencimento
@param			nValor		- Valor do Titulo
@param			nVlCruz	- Valor da Parcela
@param			cCcc		- Centro de Custo Credito
@param			cItmC		- Item Credito
@param			cClVrl		- Classe de Valor
@param			cCredit	- Contra Credito	
@param			cDebito	- Conta Debito
@param			cCcd		- Centro de Custo Debito
@param			cItEmd		- Item Contabil a Debito
@param			cClVldb	- Classe de Valor a Debito
@param			cNccZ4		- Número do Cartão de Crédito 
@param			cTitZ4		- Nome do Titular do Cartão 
@param			cNumCtr   - Numero do Contrato do RM
@obs  			Projeto FS007168 - Req. 03
@return		.T.
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
WSMETHOD FSWSP01_GRVTIT WSRECEIVE 	 cEmpTit,cFilTit,cParcela,cCliente,dDtVenc,nValor,nVlCruz,cCcc, cItmC, cClVrl, cCredit,;	
											 cDebito,cNccZ4,cTitZ4,cNumCtr WSSEND TITRESULT WSSERVICE FSWSP01

Local lVld 	:= .F.
Local cMsg	:= "" 
 
//Efetua validacoes antes de iniciar o processo de gravacao
FVldGrv(@lVld,@cMsg,cEmpTit,cFilTit,cParcela,cCliente,cNumCtr,nValor,nVlCruz,dDtVenc)

//Caso nao encontre erros, inicia o processo de gravacao
If (lVld) 
     
	cEmpTit := StrZero(Val(cEmpTit),2)
	cFilTit := StrZero(Val(cFilTit),2)
	
	RpcSetType(3)
	RpcSetEnv(cEmpTit, cFilTit)

	//Funcao para gerar o titulo na SE1
	lVld := FGerTit( @cMsg,cEmpTit,cFilTit,cParcela,cCliente,dDtVenc,nValor,nVlCruz,cCcc, cItmC, cClVrl, cCredit,;	
						 cDebito,"","","",cNccZ4,cTitZ4,cNumCtr)
	
	RpcClearEnv() 
	
	//Verifica se o titulo foi gravado com sucesso
	If (lVld)
	
		//Gravacao com exito
		::TITRESULT:LGRVTIT 	:= .T. 
		::TITRESULT:CMSGRET 	:= "Título gravado com sucesso."
		
	EndIf	

EndIf

//Retorna o erro para RM
If(!lVld)

	//Gravacao com erro
	::TITRESULT:LGRVTIT 	:= .F. 
	::TITRESULT:CMSGRET 	:= cMsg

EndIf

Return (.T.)


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSWSP01_CONTIT
Metodo para verificar se o titulo existe a partir do contrato 
        
@author 		Leandro de Faria
@since 		17/07/2014
@version 		P11
@param			cFilCnt 		- Filial do Contrato
@param			cContrato		- Numero do contrato
@obs  			Projeto FS007168 - Req. 03
@return		Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
WSMETHOD FSWSP01_CONTIT WSRECEIVE cEmpCnt,cFilCnt,cContrato WSSEND LOCATIT WSSERVICE FSWSP01

Local aAreas 	:= {}

If !Empty(cEmpCnt) .And. !Empty(cFilCnt) .And. !Empty(AllTrim(cContrato)) 
     
	cEmpCnt := StrZero(Val(cEmpCnt),2)
	cFilCnt := StrZero(Val(cFilCnt),2)

	RpcSetType(3)
	RpcSetEnv(cEmpCnt, cFilCnt)
    
	aAreas 	:= {SE1->(GetArea()), GetArea()}
	
	//Verifica se o titulo esta incluido
	SE1->(dbOrderNickName("FSIND001E1"))
	If (SE1->(dbSeek(cFilCnt+PadR(cContrato,TamSx3("E1_ZNUMCT")[1]))))
	
		//Parcela nao podera ser excluida no RM
		::LOCATIT:LTITGRV := .T.
	
	Else
	
		//Parcela podera ser excluida no RM
		::LOCATIT:LTITGRV := .F.
		
	EndIf

	//Restaura a area padrao
	AEval(aAreas, {|x| RestArea(x)})

	RpcClearEnv() 

Else	

	//Titulo nao localizado
	::LOCATIT:LTITGRV := .F.
	
EndIf	

Return (.T.)


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FVldGrv
Funcao para efetuar as validacoes antes da gravacao do titulo
        
@author 		Leandro de Faria
@since 		15/07/2014
@version 		P11
@param			lVld 		- Indica se ocorreu algum problema na validacao
@param			cMsg		- Mensagem de erro para retorno
@param			cFilTit 	- Filial
@param			cParcela 	- Parcela
@param			cCliente	- Cliente
@param			cNumCtr   - Numero do Contrato do RM
@param			nValor		- Valor do Titulo
@param			nVlCruz	- Valor da parcela
@param			dDtVenc	- Data Vencimento
@obs  			Projeto FS007168 - Req. 03
@return		Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
Static Function FVldGrv(lVld,cMsg,cEmpTit,cFilTit,cParcela,cCliente,cNumCtr,nValor,nVlCruz,dDtVenc)

Do  Case

	//Validacoes de campos
	Case ( Empty(AllTrim(cEmpTit)) .Or. Empty(AllTrim(cFilTit)) .Or. ;	
			Empty(AllTrim(cParcela)) .Or. Empty(AllTrim(cCliente)) .Or. ;
	 		Empty(AllTrim(cNumCtr)) .Or. nValor <= 0 .Or. nVlCruz <= 0 .Or. Empty(dDtVenc))
			
		//Existem campos que nao foram preenchidos
		lVld := .F.
		cMsg := "Informe os campos obrigatórios: Empresa, Filial, Parcela, Cliente, Contrato, Valor, Valor da parcela e Vencimento"
	
	OtherWise
	
		//Não foram encontrados erros
		lVld := .T.
	
EndCase

Return Nil


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGerTit
Funcao para gerar o titulo no financeiro - SE1
        
@author 		Leandro de Faria
@since 		15/07/2014
@version 		P11
@param			cMsg		- Mensagem de erro para retorno
@param			cFilTit 	- Filial do Titulo
@param			cParcela 	- Parcela
@param			cCliente	- Cliente
@param			dDtVenc	- Data Vencimento
@param			nValor		- Valor do Titulo
@param			nVlCruz	- Valor da Parcela
@param			cCcc		- Centro de Custo Credito
@param			cItmC		- Item Credito
@param			cClVrl		- Classe de Valor
@param			cCredit	- Contra Credito	
@param			cDebito	- Conta Debito
@param			cCcd		- Centro de Custo Debito
@param			cItEmd		- Item Contabil a Debito
@param			cClVldb	- Classe de Valor a Debito
@param			cNccZ4		- Número do Cartão de Crédito 
@param			cTitZ4		- Nome do Titular do Cartão 
@param			cNumCtr   - Numero do Contrato do RM
@obs  			Projeto FS007168 - Req. 03
@return		lVldAut   - .T. = Titulo gerado
				 			  .F. = Titulo nao gerado	
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
Static Function FGerTit(cMsg,cEmpTit,cFilTit,cParcela,cCliente,dDtVenc,nValor,nVlCruz,cCcc,cItmC,cClVrl,cCredit,cDebito,cCcd,cItEmd,;
							  cClVldb,cNccZ4,cTitZ4,cNumCtr)

Local lVldAut 	:= .F.
Local aTitSe1	:= {}	
Local cPrefixo	:= SuperGetMv("FS_PRXCR",.F.,"RM")
Local cTipo		:= SuperGetMv("FS_TIPCR",.F.,"BOL")
Local cNaturez	:= SuperGetMv("FS_NATCR",.F.,"999999999")
Local nOpc		:= 3
Local cAuxFil	:= cFilAnt
Local aAreas 	:= {GetArea()}

Private lMsErroAuto := .F.  


//Adiciona os titulos
aAdd(aTitSe1,{"E1_FILIAL"	,xFilial("SE1")					,Nil})
aAdd(aTitSe1,{"E1_PREFIXO"	,cPrefixo							,Nil})
aAdd(aTitSe1,{"E1_NUM"		,GETSXENUM("SE1","E1_NUM")		,Nil})
aAdd(aTitSe1,{"E1_TIPO"		,cTipo								,Nil}) 
aAdd(aTitSe1,{"E1_PARCELA"	,cParcela							,Nil}) 
aAdd(aTitSe1,{"E1_NATUREZ"	,cNaturez							,Nil}) 
aAdd(aTitSe1,{"E1_CLIENTE"	,cCliente							,Nil}) 
aAdd(aTitSe1,{"E1_LOJA"		,"01"								,Nil}) 
aAdd(aTitSe1,{"E1_EMISSAO"	,dDataBase							,Nil}) 
aAdd(aTitSe1,{"E1_VENCTO"	,dDtVenc							,Nil}) 
aAdd(aTitSe1,{"E1_VENCREA" 	,dDtVenc							,Nil}) 
aAdd(aTitSe1,{"E1_VALOR"		,nValor							,Nil}) 
aAdd(aTitSe1,{"E1_VLCRUZ"	,nVlCruz							,Nil}) 
aAdd(aTitSe1,{"E1_CCC"		,cCcc								,Nil}) 
aAdd(aTitSe1,{"E1_ITEMC"		,cItmC								,Nil}) 
aAdd(aTitSe1,{"E1_CLVLCR"	,cClVrl							,Nil}) 
aAdd(aTitSe1,{"E1_CREDIT"	,cCredit							,Nil}) 
aAdd(aTitSe1,{"E1_DEBITO"	,cDebito							,Nil}) 
aAdd(aTitSe1,{"E1_CCD"		,cCcd								,Nil}) 
aAdd(aTitSe1,{"E1_ITEMD"		,cItEmd							,Nil}) 
aAdd(aTitSe1,{"E1_CLVLDB"	,cClVldb							,Nil}) 
aAdd(aTitSe1,{"E1_NCCZ4"		,cNccZ4							,Nil}) 
aAdd(aTitSe1,{"E1_TITZ4"		,cTitZ4							,Nil}) 
aAdd(aTitSe1,{"E1_ZNUMCT"	,cNumCtr							,Nil}) 

//Ordena os array's conforme o dicionario
U_FSOrdArr(@aTitSe1,"SE1",.F.) 

//Executa a rotina automatica
MsExecAuto( { |x,y| FINA040(x,y)} , aTitSe1, nOpc) 
 
If (lMsErroAuto)
	
	//Libera sequencial
	ROLLBACKSXE()
		
	//Mensagem de erro
	cMsg := MemoRead(NomeAutoLog())
    
    //Apaga historio do execauto
	FERASE(NomeAutoLog())
	
	//Titulo nao gerado
	lVldAut 	:= .F.
    
Else
	
	//Confirma a numeracao do titulo
	ConfirmSx8()
	
	//Titulo gerado
    lVldAut := .T.

Endif


//Restaura a area
AEval(aAreas, {|x| RestArea(x)})

Return (lVldAut)
					 		