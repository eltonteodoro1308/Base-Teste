#INCLUDE "CTBA105.CH"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"

STATIC __aMedias[99]
STATIC __aDtMedias 	:= {}

STATIC __lConOutR
STATIC __lCusto 	:= CtbMovSaldo("CTT")
STATIC __lItem		:= CtbMovSaldo("CTD")
STATIC __lCLVL		:= CtbMovSaldo("CTH")
STATIC __lEnt05		:= CtbQtdEntd() >= 5
STATIC __lEnt06		:= CtbQtdEntd() >= 6
STATIC __lEnt07		:= CtbQtdEntd() >= 7
STATIC __lEnt08		:= CtbQtdEntd() >= 8
STATIC __lEnt09		:= CtbQtdEntd() >= 9

STATIC __aCampos	:= Nil
STATIC __aAltera	:= Nil
STATIC __ClearCx 	:= Nil

STATIC aMVS[6]
STATIC MAX_LINHA
STATIC lEXELOTECTB 	:= ExistBlock("LOTECTB")
STATIC lCt105LOK	:= ExistBlock("CT105LOK")
STATIC lCT105VLENT 	:= ExistBlock("CT105VLENT") //P.E. para validacao das ent. contabeis na gravacao
STATIC lCt105TOK	:= ExistBlock("CT105TOK")
STATIC lCt105CHK	:= ExistBlock("CT105CHK")
STATIC lAntCtbGrv	:= ExistBlock("ANTCTBGRV")
STATIC lDepCtbGrv	:= ExistBlock("DEPCTBGRV")
STATIC lAltDataL	:= ExistBlock("ALTDATAL")
STATIC lCt105Qry	:= ExistBlock("CT105QRY")
STATIC lCT102DLG	:= ExistBlock("CT102DLG")
STATIC lCt105OutM	:= ExistBlock("CTB105OUTM")
STATIC lCt105Pos	:= ExistBlock("CT105POS")
STATIC lCampoESP	:= ExistBlock("C105CESP")
STATIC lCt105But	:= ExistBlock("CT105But")
STATIC lAglByHist	:= Nil

STATIC lCTKHAGLUT  	:= .T.

STATIC __cCurdir    := CurDir()
STATIC __issrvunix  := IsSrvUnix()
STATIC __IsCtbJob	   := NIL

STATIC cDbsExt		:= GetDBExtension()
STATIC cIndExt		:= OrdBagExt()

STATIC cPictVal  	:= MyPesqPict("CT2","CT2_VALOR")
STATIC aMoedaOk		:=	{}
STATIC aCTOCTPOK	:=	{}

STATIC nQtdEntid
Static aPerCache    :=  {} // Grava os períodos e moedas válidas na data do lançamento
STATIC lVldTps 		:= GETMV("MV_CTBCTG",.T.,.F.) // Habilita validação por amarração entre calendário x moeda x tipo de saldo

Static cEnt05Db		:= Nil
Static cEnt05Cr		:= Nil
Static cEnt06Db		:= Nil
Static cEnt06Cr		:= Nil
Static cEnt07Db		:= Nil
Static cEnt07Cr		:= Nil
Static cEnt08Db		:= Nil
Static cEnt08Cr		:= Nil
Static cEnt09Db		:= Nil
Static cEnt09Cr		:= Nil
Static cAtiviDb		:= Nil
Static cAtiviCr		:= Nil
Static __lDCDUso    := NIL
Static __alDtTaxa   := NIL
Static __cCodSeq		:= ""
Static __lMoedFat		:= Nil
Static __lArqTmpB	:= .F.
Static __cArq1		:= ""
Static __cArq2		:= ""
Static __lBlind		:= IsBlind()
Static __cProcAmar 	:= NIL
Static __cProcRegra := NIL	
Static __cProcPai 	:= NIL		
Static __cProcGrv   := NIL
Static __cProcZero  := NIL
Static __cProcSoma1 := NIL
Static __cProcDoc   := NIL
Static __cProcFil   := NIL
Static __lTmp_Zap   := .F.
Static	_lCtbGrv 	:= ExistBlock("CTBGRV")

Static _lProcPsqCT2 := NIl
Static _PrCT2Psq := NIL  
Static _oCTBA105    //Objeto para receber metodos da classe FwTemporaryTable - REVERSAO POR CONTA ERROR LOG ZAP
Static __aCritPln    := {}

#DEFINE MV_ALTLCTO		1
#DEFINE MV_SUBLOTE		2
#DEFINE MV_PRELAN		3
#DEFINE MV_CONTSB		4
#DEFINE MV_CONTBAT		5
#DEFINE MV_SOMA    		6

#DEFINE D_PRELAN		"9"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf Medrano ³08/04/16³TVPIJ3    ³Merge v118 vs v1217                      ³±±
±±³            ³        ³          ³Se modif Func CT105TOk se agrega CT102LOK³±±
±±³            ³        ³          ³Valida existencia de NIT en comprobantes ³±±
±±³            ³        ³          ³contables COLOMBIA                       ³±±
±±³            ³        ³          ³Se agrega comentarios en func CT102LOK   ³±±
±±³Dora Vega   ³04/09/17³DMINA-169 ³Rep. 12.1.7 Se incluye validacion de     ³±±
±±³            ³v12.1.07³DMINA-67  ³items encontrados en browse, tras carga  ³±±
±±³            ³        ³          ³de Asientos Contables desde la rutina    ³±±
±±³            ³        ³          ³Contabilidad TXT. Pais: TODOS            ³±±
±±³Raul Ortiz  ³13/12/17³DMICNS-649³Se realizan modificaciones para uso de   ³±±
±±³            ³        ³          ³tablas temporales - arg                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB_Incl  ³ Autor ³ Pilar S Albaladejo    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de inclus„o de Lan‡amentos Cont beis.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:=CTB105Incl(ExpC1,ExpN1,ExpN2,ExpC2,ExpL1,ExpL2)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do arquivo                                    ³±±
±±³          ³ ExpN1 = Numero do Header                                   ³±±
±±³          ³ ExpN2 = Numero da Opcao escolhida                          ³±±
±±³          ³ ExpC2 = Numero do Lote                                     ³±±
±±³          ³ ExpL1 = Se Mostra ou nao                                   ³±±
±±³          ³ ExpL2 = Se Aglutina ou nao                                 ³±±
±±³          ³ ExpC3 = Determina se sera On Line ou pelo cProva           ³±±
±±³          ³ dData = Data para geracao dos lancamentos contabeis        ³±±
±±³          ³ dReproc = Parametro que indica que lancamentos nao atualiza³±±
±±³          ³           saldos e apos gravacao executa reprocessamento   ³±±
±±³          ³ aFlagCTB    = Array com dados para utilizacao do CTB       ³±±
±±³          ³ aDadosProva = Array com dados para utilizacao multi-thread ³±±
±±³          ³ aTpSaldo = Array para armazenar os tipos de saldos gerados ³±±
±±³          ³            no lancamento contabil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB_Incl(	cArquivo, nHdlPrv, nOpcx, cLoteContabil, lDigita, lAglut, cOnLine,;
					dData, dReproc, aFlagCTB, aDadosProva, aTpSaldo, aSeqDiario, lSimula,;
					cTabCTK, cTabCT2)

Local aDiario   := aClone(aSeqDiario)
Local aSaveArea	:= GetArea()
Local aCampos		:= {}

Local nOpca			:= 0
Local nArqAbre		:= 1

Local cArqAbre		:= "CT0"
Local CTF_LOCK		:= 0
Local cCadastro 	:= OemToAnsi(STR0001)				// Lancamentos Contabeis
Local cArq1
Local cArq2
Local cEmpOri		:= cEmpAnt
Local cFilOri		:= cFilAnt
Local oSize

Local oDlg
Local oFilial
Local oLote
Local oSubLote, lSubLote
Local oDoc
Local oHistCapLt
Local oFnt

Local lFirst		:= .T.
Local lRpc			:= Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela
Local lRpcOk		:= .T.
Local nLin  		:= 0
Local nRecCTK 		:= 0
Local cAliasCTK		:= "CTK"
      
// Variaveis para guardar eventuais funcoes ja atruibuidas às teclas F4 F5 F6 e F7 em outros modulos, para serem
// restauradas no final.
Local bVK_4
Local bVK_5
Local bVK_6
Local bVK_7

Local cPreLcto		:= ""
Local cRotina		:= FunName()
Local cProgName		:= ""
Local aButton 		:= {}
Local aButtonNew	:= {}
Local cLoteEXEC		:= ""
Local cExpFil		:= ""
Local cTxtfil		:= ""

Local aCTKxCT2		:= {}
Local dCt2Data
Local lReturn       := .T.
Local lGravaLanc    := .T.
Local aStruCTK 	:= {}
Local aStruQry		:= {}
Local cTypDB		:= UPPER(TcGetDB())
Local lOrdEnt		:= If(GetNewPar("MV_ORDLCTB","L")=="E",.T.,.F.)			/// MV_ORDLCTB : L= LP (sequen+lp)/ E = Entrada (Recno)
Local nMoedas		:= 0
Local nPosQry		:= 0
Local nY

Local lOrdTpSld		:= If(GetNewPar("MV_ORDLCTB","L")=="T",.T.,.F.)			/// MV_ORDLCTB : T= Tipo de Saldo
Local cSrvType		:= TcSrvType()
Local lTemIDX   	:= .F.
Local nOrdTpSld 	:= 1

Local nPar := 1
Local nTipoSaldo

Local lSeqCorr   	:= UsaSeqCor("CT2/CTK/CT5")
Local cSeqCorr 		:= Space(10)
Local nX
Local cChaveCT2		:= ""
Local cChaveCTK		:= ""
Local lDigitaOri    := lDigita   // salva o status original
Local cHistCapLt	:= "" //Historico Capa do Lote
Local nValDif       := 0
Local cLancCont     := ""
Local nCtr1stRow
Local nLbl1st1
Local nCmp1st1
Local nLbl1st2
Local nCmp1st2

Local nCtr3rdRow
Local nLbl3rd1
Local nCmp3rd1
Local nLbl3rd2
Local nCmp3rd2
Local nLbl3rd3
Local nCmp3rd3

Local cFilLanc		:= FWXFilial("CT2")
Local lCriaTmp := .T.
Private aTELA		:= {}
Private aGETS		:= {}
Private aCols		:= Nil
Private aRotina		:= MenuDef()
Private dDataLanc	:= Iif(dData == Nil,dDataBase,dData)
Private nTotInf		:= 0
Private aTotRdpe 	:= {{0,0,0,0},{0,0,0,0}}
Private nUsado		:= 0
Private nSaida		:= 0

Private oDig
Private oDeb
Private oCred
Private oInf
Private oDescEnt

Private cLote		:= cLoteContabil, cSubLote
Private cDoc		:= Space(6)

Private cSeqCrAnt   := Space(10)

Private aColsP		:= {}
Private oGetDb

Private OPCAO
Private aCtbEntid

Private __aCT2LC	:= {}

If ! CtbVerTmpBD() .And. ! __lTmp_Zap    // ! Type("aAltera") == "U"
	Private aAltera		:= {}
EndIf

If ! CtbVerTmpBD() .And. ! __lTmp_Zap     // Type("aHeader") == "U"
	Private aHeader		:= {}
EndIf

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

/* no FINA370 , já existe um alias chamado TMP, na Contabilização de Rateio financeiro. 
   O nome do alias é alterado para "TMP_CTB", mas neste ponto volto para TMP*/
If CtbVerTmpBD()
	If select("TMP_CTB") > 0
		dbChangeAlias("TMP_CTB", "TMP")
	EndIf
Endif

If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

If lAglByHist == Nil
	lAglByHist	:= GetNewPar("MV_AGLHIST",.F.) .or. UPPER(ALLTRIM(FUNNAME()))$(UPPER(GetNewPar("MV_AGLPROC","")))
Endif

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If aCtbEntid == NIL
	aCtbEntid := Array(2,nQtdEntid)  //posicao 1=debito  2=credito
EndIf

//DEBITO
aCtbEntid[1,1] := {|| TMP->CT2_DEBITO 	}
aCtbEntid[1,2] := {|| TMP->CT2_CCD		}
aCtbEntid[1,3] := {|| TMP->CT2_ITEMD 	}
aCtbEntid[1,4] := {|| TMP->CT2_CLVLDB 	}
//CREDITO
aCtbEntid[2,1] := {|| TMP->CT2_CREDIT }
aCtbEntid[2,2] := {|| TMP->CT2_CCC		}
aCtbEntid[2,3] := {|| TMP->CT2_ITEMC 	}
aCtbEntid[2,4] := {|| TMP->CT2_CLVLCR 	}

For nX := 5 TO nQtdEntid
	aCtbEntid[1, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"DB } ")  //debito
	aCtbEntid[2, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"CR } ")  //credito
Next

// controle de limpeza do cache
If __ClearCx == Nil
	__ClearCx := GetNewPar( "MV_CTBCLSC" , .T. )
Endif

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf

If __lConOutR
	ConOutR("*LOGINI*|INICIO CTBA105")
EndIf

If Type("__aCT2LC") <> "A"
	__aCT2LC := {}
Endif

DEFAULT aFlagCTB	:= {}
DEFAULT nOpcX		:= 3

// define o valor da variavel opcao utilizada na gravação
OPCAO := nOpcx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Assume as informacoes do array aDadosProva, caso as mesmas   |
//| tenham sido passadas via parametro.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(aDadosProva) == "A"
	__HeadProva := ACLONE(aDadosProva)
EndIf

// Carrego os MVS
If aMVS[MV_ALTLCTO] = Nil
	aMVS[MV_ALTLCTO] := Iif( SuperGetMv( "MV_ALTLCTO" , .F., "S") == "S", .T., .F. )		
Endif

If aMVS[MV_SUBLOTE] = Nil
	aMVS[MV_SUBLOTE] := GetMv("MV_SUBLOTE")
Endif

If aMvs[MV_PRELAN] = Nil
	aMvs[MV_PRELAN] := GetMv("MV_PRELAN")
Endif

If MAX_LINHA = Nil
	MAX_LINHA := { CtbLinMax(GetMv("MV_NUMLIN")), GetMv("MV_NUMMAN") }
Endif

//Alterar o conteudo da variavel dDataLanc, caso exista o ponto de entrada
If lAltDataL .and. !lOrdTpSld .And. !lSimula
	dDataLanc	:= 	ExecBlock("ALTDATAL",.F.,.F.,{dData,cRotina})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a numeracao do lote foi alterada pelo PE LOTECTB³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEXELOTECTB .And. !lSimula		//PONTO DE ENTRADA PARA ALTERAÇÃO NO NUMERO DO LOTE CTB.
	cLoteEXEC := EXECBLOCK("LOTECTB",.F.,.F.,{cLote})
	If ValType(cLoteEXEC) == "C" .and. !Empty(cLoteEXEC)
		cLoteContabil := cLoteEXEC
	EndIf
EndIf

cSubLote	:= aMVS[MV_SUBLOTE]
lSubLote 	:= Empty(cSubLote)
nOpc		:= 4
cLote 		:= Iif(Len(Alltrim(cLoteContabil)) < 6 , PADL(ALLTRIM(cLotecontabil),6,"0") , cLoteContabil)

If __lConOutR
	ConOutR("*PROCES*|Inicializando o calculo das medias para conversão das moedas.")
EndIf

// Calcula medias para conversao de moedas
CtbMedias( dDataLanc )

If __lConOutR
	ConOutR("*PROCES*|Finalizando o calculo das medias para conversão das moedas e iniciando a leitura do headprova.")
EndIf

If nHdlPrv == 65536	.and. GetHProva() == 1024
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso houve abertura por HeadProva() ( nHdlPrv == 65536 )     ³
	//³ e houve lan‡amento cont bil (Handle Interno == 1024)         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeqChave:= GetHFile()  // Retorna a chave dos dados gravados no CTK
Else
	RestArea(aSaveArea)
	Return .F.
Endif

If __lConOutR
	ConOutR("*PROCES*|Finalizando a leitura do headprova e iniciando A ABERTURA DOS ARQUIVOS DO CTB.")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AQUI! Abre os Arquivos do CTB em outros m¢dulos              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nArqAbre :=1 to 20 // Arquivos CT1 a CTK
	cArqAbre := soma1(cArqAbre)
	If Select(cArqAbre) <= 0
		ChkFile(cArqAbre)
	Endif
Next

If __lConOutR
	ConOutR("*PROCES*|Finalizando a abertura dos arquivos do CTB e iniciando a montagem do aheader.")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CT2")
If lSimula .and. !(Type("cFunname") <> "U" .and. cFunname == "FINA840")
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CT21"))
		cChaveCT2 := AllTrim(SIX->CHAVE)
		IndRegua("CT2", cTabCT2, cChaveCT2, , , )
	EndIf
	dbSelectArea("CT2")
Else
	dbSetOrder(1)
EndIf

If ! CtbVerTmpBD() 

	If __lTmp_Zap
		lCriaTmp := .T.
		If Select( 'TMP') > 0
			DbSelectArea( "TMP" )
			If FieldPos("CT2_DEBITO") == 0 //verifica se nao existe campo debito no temporario  
				DbCloseArea()
			Else 
				lCriaTmp := .F.  //Setar FALSE para somente dar ZAP no arquivo e nao recriar a cada documento contabilizado
				cArq1 := __cArq1  //atribui a variavel local cArq1/cArq2 o conteudo da static
				cArq2 := __cArq2
			Endif
		EndIf
	EndIf

	If ! lCriaTmp
	
		dbSelectArea("TMP")
		Zap
		dbGoTop()
		
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aHeader para Lan‡amentos Cont beis                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		__aCampos := Ctb105Head(@aAltera,lSimula)
	
		Ctb105Cria(__aCampos,@cArq1,@cArq2)
		
	EndIf

Else

	cArq1 := __cArq1  //atribui a variavel local cArq1/cArq2 o conteudo da static
	cArq2 := __cArq2

EndIf	

If __lConOutR
	ConOutR("*PROCES*|Finalizando a montagem do aheader.")
EndIf

If __lConOutR
	ConOutR("*PROCES*|Inicio da leitura do CTK.")
EndIf

DbSelectArea("CTK")
If lSimula
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CTK1"))
		cChaveCTK := AllTrim(SIX->CHAVE)
		IndRegua("CTK", cTabCTK, cChaveCTK, , , )
	EndIf
	dbSelectArea("CTK")
Else
	DbSetOrder(1)
EndIf

CTK->(DbCommit())		// Garanto que os registros estejam no BANCO

aStruCTK	:= CTK->(dbStruct())
cAliasCTK	:= "QUERYCTK"

cQuery := ""

If lAglut
	cQuery += "CTK_FILIAL,CTK_SEQUEN,CTK_DC"
	cQuery += ",CTK_DEBITO,CTK_CREDIT,CTK_CCD,CTK_CCC,CTK_ITEMD,CTK_ITEMC,CTK_CLVLDB,CTK_CLVLCR"
	For nX := 5 TO nQtdEntid
		cQuery += ",CTK_EC"+StrZero(nX,2)+"DB,CTK_EC"+StrZero(nX,2)+"CR"
	Next
	cQuery += ",CTK_TPSALD,CTK_DATA,CTK_LP"
	
	If lAglByHist
		If lCTKHAGLUT
			cQuery += ",CTK_HAGLUT CTK_HIST" /// Campo CTK_HAGLUT recebe CTK_HIST como apelido
		Else
			cQuery += ",CTK_HIST"
		EndIf
	Endif
	
	cQuery += ",CTK_CODPAR"
	cQuery += ",CTK_DIACTB"
	
	//Tratativa para aglutinação da Moeda do fato - Variacao Cambial
	cQuery += ",CTK_MOEFDB,CTK_MOEFCR"
	
	For nMoedas	:= 1 to __nQuantas
		cQuery += ",SUM( CTK_VLR" + StrZero(nMoedas,2) + " ) CTK_VLR" + StrZero(nMoedas,2)
	Next
	
	If !cTypDB$"MSSQL/MSSQL7/MYSQL/POSTGRES"				//// SE NÃO FOR SQL OU MSSQL7
		cQuery +=",MAX(CTK_LP||CTK_LPSEQ) CTKLPLPSEQ"
	Else									//// SE FOR SQL
		If cTypDB=="MYSQL"
			cQuery +=",MAX(CONCAT(CTK_LP,CTK_LPSEQ)) CTKLPLPSEQ"
		ElseIf cTypDB=="POSTGRES"
			cQuery +=",MAX(CAST(CTK_LP||CTK_LPSEQ AS CHAR("+ ALLTRIM(STR(TamSX3('CTK_LP')[1]+TamSX3('CTK_LPSEQ')[1]))+"))) CTKLPLPSEQ"				
		Else
			cQuery +=",MAX(CTK_LP+CTK_LPSEQ) CTKLPLPSEQ"
		EndIf
	Endif
	cQuery +=",MIN(CTK_ORIGEM) CTK_ORIGEM"
	cQuery +=",MIN(R_E_C_N_O_) CTKMINRECNO"
	cQuery +=",MAX(R_E_C_N_O_) R_E_C_N_O_"
	cQuery +=",MIN(CTK_ROTINA) CTK_ROTINA"
	cQuery +=",MIN(CTK_KEY) CTK_KEY"
	cQuery +=",MIN(CTK_ATIVDE) CTK_ATIVDE"
	cQuery +=",MIN(CTK_ATIVCR) CTK_ATIVCR"
	cQuery +=",COUNT(*) CONTAAGLUT"
	cQuery += ",MIN(CTK_DTVENC) CTK_DTVENC"
	cQuery += ",CTK_AT01DB,CTK_AT02DB,CTK_AT03DB,CTK_AT04DB,CTK_AT01CR,CTK_AT02CR,CTK_AT03CR,CTK_AT04CR"
	If cPaisLoc == "MEX"
		If CTK->( FieldPos("CTK_UUID")) > 0 .and. CT2->(FieldPos("CT2_UUID")) > 0
			cQuery += ",CTK_UUID"
		Endif
		If CTK->( FieldPos("CTK_RFC")) > 0 .and. CT2->(FieldPos("CT2_RFC")) > 0
			cQuery += ",CTK_RFC"
		Endif
	EndIf
Else
	For nY := 1 To Len(aStruCTK)
		cQuery += aStruCTK[nY][1] + ","
	Next nY
	cQuery +="R_E_C_N_O_"
EndIf

cQuery := " SELECT " + cQuery
If lSimula
	cQuery += " FROM " +(cTabCTK)+ " CTK "
Else
	cQuery += " FROM " + RetSqlName( "CTK" ) + " CTK "
EndIf
cQuery += " WHERE CTK.CTK_FILIAL = '" + xFilial( "CTK" ) + "' AND "
cQuery += "   CTK.CTK_SEQUEN = '" + cSeqChave + "' AND "

If lAglut
	cQuery += "	  CTK_DC <>'4' AND "		
Endif

cQuery += "   CTK.D_E_L_E_T_ = ' ' "

If lAglut
	cQuery += "GROUP BY CTK_FILIAL,CTK_SEQUEN,CTK_DC,CTK_DEBITO,CTK_CREDIT,CTK_CCD,CTK_CCC,CTK_ITEMD,CTK_ITEMC,CTK_CLVLDB"
	cQuery += ",CTK_AT01DB,CTK_AT02DB,CTK_AT03DB,CTK_AT04DB,CTK_AT01CR,CTK_AT02CR,CTK_AT03CR,CTK_AT04CR"
	For nX := 5 TO nQtdEntid
		cQuery += ",CTK_EC"+StrZero(nX,2)+"DB,CTK_EC"+StrZero(nX,2)+"CR"
	Next
	cQuery += ",CTK_CLVLCR,CTK_TPSALD,CTK_DATA,CTK_LP"
	If lAglByHist
		If lCTKHAGLUT
			cQuery += ",CTK_HAGLUT"
		Else
			cQuery += ",CTK_HIST"
		EndIf
	Endif
	
	cQuery += ",CTK_CODPAR"
	cQuery += ",CTK_DIACTB"
	
	//Tratativa para a aglutinação da moeda do fato - Variacao Cambial
	cQuery += ",CTK_MOEFDB,CTK_MOEFCR"
	
	If cPaisLoc == "MEX"
		If CTK->( FieldPos("CTK_UUID")) > 0 .and. CT2->(FieldPos("CT2_UUID")) > 0
			cQuery += ",CTK_UUID"
		Endif
		If CTK->( FieldPos("CTK_RFC")) > 0 .and. CT2->(FieldPos("CT2_RFC")) > 0
			cQuery += ",CTK_RFC"
		Endif
	EndIf
	cQuery += " ORDER BY  "
	If 	lOrdTpSld	/// MV_ORDLCTB : T= Tipo de Saldo
		cQuery += "CTK_TPSALD,"
	EndIf
	cQuery += "CTKMINRECNO " /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
Else
	If lOrdEnt
		cQuery += "ORDER BY R_E_C_N_O_"  //"+SqlOrder(CTK->(IndexKey())) /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
	Else
		cQuery += "ORDER BY "
		If 	lOrdTpSld	/// MV_ORDLCTB : T= Tipo de Saldo
			cQuery += "CTK_TPSALD,"
		EndIf
		
		cQuery += SqlOrder(CTK->(IndexKey())) /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
		cQuery += ", CTK_TABORI, CTK_RECORI, R_E_C_N_O_" /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512						
	Endif
EndIf

If lCt105Qry .And. !lSimula
	cQuery 	:= 	ExecBlock("CT105QRY",.F.,.F.,{cQuery,lAglut})
EndIf
        
        If ! lAglut .And. Alltrim( UPPER(TcGetDB()) ) == "DB2"
        	cQuery += " FOR READ ONLY "               //para performance nao passar pela changequery qdo DB2
        ElseIf Alltrim( UPPER(TcGetDB()) ) == "POSTGRES" .And. lAglut  //se banco for PostGres e aglutina 
        	//retirado ChangeQuery pois ela tentava alterar a clausula/funcao CAST( e ocorria error log  e colocado mais um espaco somente para ficar mais legivel o codigo
			cQuery += " "         //cQuery := ChangeQuery(cQuery)
        Else
			cQuery := ChangeQuery(cQuery)
        EndIf

If ( Select ( cAliasCTK ) <> 0 )
	dbSelectArea ( cAliasCTK )
	dbCloseArea ()
Endif

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTK , .T. , .T. )
aStruQry	:= &(cAliasCTK)->(dbStruct())

For nY := 1 To Len(aStruCTK)
	If aStruCTK[nY][2] <> "C"
		//Verificar se o campo existe na query antes do TcSetField
		nPosQry	:= aScan(aStruQry,{|x|(x[1])==Trim(aStruCTK[nY][1])})
		If nPosQry > 0
			TcSetField(cAliasCTK,aStruCTK[nY][1],aStruCTK[nY][2],aStruCTK[nY][3],aStruCTK[nY][4])
		EndIf
	EndIf
Next nY

If __lConOutR
	ConOutR("*PROCES*|FIM QUERY CTK e Inicio da CARGA TMP.")
EndIf

cProgName := (cAliasCTK)->CTK_ROTINA
If Empty(cProgName)
	cProgName := FunName()
Endif

bVK_4 := SetKey(VK_F4)
bVK_5 := SetKey(VK_F5)
bVK_6 := SetKey(VK_F6)
bVK_7 := SetKey(VK_F7)

lEndCTK := .F.

While (cAliasCTK)->( Ctb105Grv(	cSeqChave,lAglut,__aCampos,dDataLanc,@cSubLote,@nLin,@nRecCTK,cAliasCTK,@aFlagCTB,@aCTKxCT2,@lEndCTK,lSeqCorr,@cSeqCorr,aSeqDiario,Nil,lSimula,cTabCTK,cTabCT2,@cHistCapLt))
	
	__cCodSeq := SubStr(cSeqCorr,1,2) 
	
	If __lConOutR
		ConOutR("*PROCES*|FIM CARGA TMP -> CTB105GRV")
	EndIf

	If TMP->(RecCount()) == 0
		RestArea(aSaveArea)
		TMP->( dbCloseArea() )
		Return
	EndIf

	If (lFirst .Or. (nLin > MAX_LINHA[1])) .And. !lSimula
		If CTF_LOCK > 0		//LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC (DEPOIS DE GRAVAR O PRIMEIRO DOC)
			dbSelectArea("CTF")
			dbGoTo(CTF_LOCK)
			CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)			
		Endif

		If lAltDataL .and. lOrdTpSld .And. !lSimula
			dDataLanc	:= 	ExecBlock("ALTDATAL",.F.,.F.,{dData,cRotina})
		EndIf

		Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o N§ do Doc estourou, incrementa o lote         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLote := Soma1(cLote)
			DbSelectArea("SX5")
			MsSeek(xFilial("SX5")+"09"+If(cModulo=="CTB","CON",cModulo))
			RecLock("SX5")
			SX5->X5_DESCRI := Substr(cLote,3,4)
			MsUnlock()
		Enddo
		lFirst := .F.
	Endif

	aButton := {}
	Aadd( aButton, {"RECALC"   , { || MsAguarde({|| CtRecRdPe()},STR0055) },STR0056 } )//"Recalculando totais..."#"Rec.Totais"
	Aadd( aButton, {"SIMULACAO",{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc)} , STR0015+" - <F5>",STR0016 } ) //"Totais do lote e documento (outras moedas)" "Totais"
	Aadd( aButton, {"PREV"     ,{ || CTB105Flt (oGetDb,.F.              ) },STR0019,STR0026 } ) //"Inconsistencia Anterior" //"Anterior"
	Aadd( aButton, {"NEXT"     ,{ || CTB105Flt (oGetDb,.T.              ) },STR0020,STR0050 } ) //"Proxima Inconsistencia" //"Próxima"
	If aMvs[MV_ALTLCTO]
		Aadd( aButton, {"CTBREPLA"   ,{ || Ctb102Repla()}, STR0051 ,STR0052		} ) //"Replicar o conteudo do campo posicionado"###"Replicar"
	EndIf
	aButton := AddToExcel(aButton,{	{"ARRAY",STR0053,{STR0002,STR0003,STR0013,STR0004},{{dDataLanc,cLote,cSubLote,cDoc}}},{"GETDB",STR0054,aHeader,"TMP"} } ) //"Documento"###"Lançamentos"
	Aadd( aButton, {"PESQUISA"   ,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil) },STR0021 } ) //"Localizar"
	Aadd( aButton, {"IMPRIMIR"   ,{ || CTB_IMPLANC() }, OemToAnsi(STR0086) } ) //'Imprimir'
	
	//----------------------------------------------------------------
	// Ponto de entrada para inclusão de novos itens no menu aButton
	//----------------------------------------------------------------
	If ExistBlock("CT105But")
		aButtonNew := ExecBlock("CT105But",.F.,.F.,aButton)
		If (ValType(aButtonNew) == "A")
			aButton := aClone(aButtonNew)
		EndIf
	EndIf
	
	If __lConOutR
		ConOutR("*PROCES*|PEGOU No DOCUMENTO CTB")
	EndIf
	
	__PreLan 	:= .F.		// Indica se tenta gravar como pre-lancamento
	
	If !lDigita										// Se altera lancamento -> visualiza!!
		If lRpc
			//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.		
			If lAntCtbGrv .And. !lSimula
				ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
			Endif	                                                     
			                                               
			If __lConOutR
				ConOutR("*PROCES*|INICIO VALIDACOES1")
			EndIf

			//Validacao
			If lSimula
				lRpcOk := .T.
			Else
				lRpcOk	:= CTB105Rpc(lDigita) .And. Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf)
			EndIf
			
			If !lRpcOk .Or. __Prelan == .T.
				cPreLcto	:= "S"
			Else
				cPreLcto	:= "N"
			EndIf
					
			If __lConOutR
				ConOutR("*PROCES*|FIM VALIDACOES1")
			EndIf
					
			CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,__lCusto,__lItem,__lCLVL,,cProgName,;
					cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
					cHistCapLt)
                       
			If __lConOutR
				ConOutR("*PROCES*|TERMINOU CTBGRAVA1")
			EndIf
			//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lDepCtbGrv .And. !lSimula
				ExecBlock("DEPCTBGRV",.F.,.F., {nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
			Endif

			//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
			//dbSelectArea("TMP")
			//Zap
			If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo
				If ! CtbVerTmpBD()
				
					If __lTmp_Zap

						lCriaTmp := .T.
						If Select( 'TMP') > 0
							DbSelectArea( "TMP" )
							If FieldPos("CT2_DEBITO") == 0 //verifica se nao existe campo debito no temporario  
								DbCloseArea()
							Else 
								lCriaTmp := .F.  //Setar FALSE para somente dar ZAP no arquivo e nao recriar a cada documento contabilizado
							Endif
						EndIf
					
					EndIf
				
					If lCriaTmp 
						TMP->(DbCloseArea())
						FErase( cArq1+cDBSExt )
						Ferase( cArq1+cIndExt )
						Ferase( cArq2+cIndExt )
						cArq1 := ""
						cArq2 := ""
						Ctb105Cria(__aCampos,@cArq1,@cArq2)
					Else
						dbSelectArea("TMP")
					EndIf
				Else
					dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
					TcSqlExec(" Truncate Table "+ cArq1 )  //Zap
					DbCommitAll()
					TcRefresh(cArq1)
					dbgobottom()
					dbgotop()
				EndIf
			EndIf
		Else
			If __lConOutR
				ConOutR("*PROCES*|INICIO VALIDACOES2 | GRAVAÇÃO DO CT2")
			EndIf

			//Validacao
			If lSimula
				lRpcOk := .T.
			Else
				lRpcOk	:= Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf)
			EndIf

			IF ! lRpcOk
				lDigita := aMvs[MV_ALTLCTO]
			Else
				If !CtbValiDt(nOpc,dDataLanc)//Se nao tem uma data valida
					lDigita	:= .T. //Mostra lancamento contabil
		    	Endif
			Endif

			If !lDigita

				//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis. 
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lAntCtbGrv .And. !lSimula
					ExecBlock("ANTCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
				Endif

				If lSimula
					lRpcOk := .T.
				Else
					lRpcOk := lRpcOk .And. CTB105Rpc(lDigita)
				EndIf

				If !lRpcOk  .Or. __Prelan == .T.
					cPreLcto	:= "S"
				Else
					cPreLcto	:= "N"
				EndIf

				CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,;
						__lCusto,__lItem,__lCLVL,,cProgName,cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
						cHistCapLt)

				//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lDepCtbGrv .And. !lSimula
					ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
				Endif

				//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
				//dbSelectArea("TMP")
				//Zap
				If !lEndCTK		///Se não terminou a leitura de CTK carrega TMP novo
					If ! CtbVerTmpBD()
						If __lTmp_Zap
							dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
							Zap
							dbGoTop()				
						Else
							TMP->(DbCloseArea())
							FErase( cArq1+cDBSExt )
							Ferase( cArq1+cIndExt )
							Ferase( cArq2+cIndExt )
							cArq1 := ""
							cArq2 := ""
							Ctb105Cria(__aCampos,@cArq1,@cArq2)
						EndIf
					Else
						dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
						TcSqlExec(" Truncate Table "+ cArq1 )    //Zap
						DbCommitAll()
						TcRefresh(cArq1)
						dbgobottom()
						dbgotop()
					EndIf
				EndIf
				
			EndIf

			If __lConOutR
				ConOutR("*PROCES*|FIM VALIDACOES2 | GRAVAÇÃO DO CT2")
			EndIf
		EndIf
	Endif
	
	If lDigita
		If __lConOutR
			ConOutR("*PROCES*|INICIO INTERFACE")		
		EndIf
		nOpcA 		:= 0
		__PreLan 	:= .F.		// Indica se tenta gravar como pre-lancamento
		     
		/* Nao pemite alteracao nos lancamentos complementares */
		If CTBLCUso()
			If AllTrim(TMP->CT2_ROTINA) == "__CTBLC__"
				nOpcA := 1
			Endif
		Endif

		While nOpcA == 0

			If Type("oMainWnd") = "U"
			
				//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis. 
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente. 		
				If lAntCtbGrv
					ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
				Endif		                                                     
				
				If __lConOutR
					ConOutR("*PROCES*|INICIO CTBGRAVA3")
				EndIf
				
				CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,	__lCusto,__lItem,__lCLVL, nTotInf,cProgName,;
						If(__PreLan, aMvs[MV_PRELAN],),	dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,;
						,,,cHistCapLt)
              
				If __lConOutR
					ConOutR("*PROCES*|FIM CTBGRAVA3")		
				EndIf

				//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis. 
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente. 
				If lDepCtbGrv
					ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
				Endif		                                                     									
				
				//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
				//dbSelectArea("TMP")
				//Zap
				If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo
					If ! CtbVerTmpBD()
						If __lTmp_Zap						
							dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
							Zap
							dbGoTop()				
						Else
							TMP->(DbCloseArea())
							FErase( cArq1+cDBSExt )
							Ferase( cArq1+cIndExt )
							Ferase( cArq2+cIndExt )  
							cArq1 := ""
							cArq2 := ""
							Ctb105Cria(__aCampos,@cArq1,@cArq2)
						EndIf				
					Else
						dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
						TcSqlExec(" Truncate Table "+ cArq1 )    //Zap
						DbCommitAll()
						TcRefresh(cArq1)
						dbgobottom()
						dbgotop()
					EndIf
				EndIf
				Exit
			Endif

			SetKey(VK_F4, { || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc) })		
			SetKey(VK_F5, { || CTB105Flt (oGetDb,.F.                   ) })
			SetKey(VK_F6, { || CTB105Flt (oGetDb,.T.                   ) })
			SetKey(VK_F7, { || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     ) })

			//Faz o calculo automatico de dimensoes de objetos
			oSize := FwDefSize():New(.T.)
	
			oSize:lLateral	:= .F.
			oSize:lProp		:= .T. // Proporcional
	
			oSize:AddObject( "1STROW" ,  100, 08, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "2NDROW" ,  100, 78, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "3RDROW" ,  100, 14, .T., .T. ) // Totalmente dimensionavel
			
			oSize:aMargins	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	
			oSize:Process() // Dispara os calculos		
	
			a1stRow := {	oSize:GetDimension("1STROW","LININI"),;
							oSize:GetDimension("1STROW","COLINI"),;
							oSize:GetDimension("1STROW","LINEND"),;
							oSize:GetDimension("1STROW","COLEND")}
	
			a2ndRow := {	oSize:GetDimension("2NDROW","LININI"),;
							oSize:GetDimension("2NDROW","COLINI"),;
							oSize:GetDimension("2NDROW","LINEND"),;
							oSize:GetDimension("2NDROW","COLEND")}
	
			a3rdRow := {	oSize:GetDimension("3RDROW","LININI"),;
							oSize:GetDimension("3RDROW","COLINI"),;
							oSize:GetDimension("3RDROW","LINEND"),;
							oSize:GetDimension("3RDROW","COLEND")}
	
			//calculo o centro objeto
			nCtr1stRow := a1stRow[1] + ((a1stRow[3] - a1stRow[1]) / 2)		
			nCtr3rdRow := a3rdRow[1] + ((a3rdRow[3] - a3rdRow[1]) / 2)
			
			//defino as coordenadas das labels e dos campos.
			nLbl3rd1	:= nCtr3rdRow - 18
			nCmp3rd1	:= nCtr3rdRow - 20
			nLbl3rd2	:= nCtr3rdRow - 4
			nCmp3rd2	:= nCtr3rdRow - 6
			nLbl3rd3	:= nCtr3rdRow + 10
			nCmp3rd3	:= nCtr3rdRow + 8
			
			If lSeqCorr .OR. cPaisLoc == "ARG"
				nLbl1st1 := a1stRow[1] + 6
				nCmp1st1 := a1stRow[1] + 3
				nLbl1st2 := nCtr1stRow + 6
				nCmp1st2 := nCtr1stRow + 3
			Else
				nLbl1st1 := nCtr1stRow - 3
				nCmp1st1 := nCtr1stRow - 6
			EndIf			
			
			DEFINE MSDIALOG oDlg TITLE cCadastro From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
			oDlg:lMaximized := .T.

			@ nLbl1st1, a1stRow[2] + 000 Say OemToAnsi(STR0091) SIZE 25,9 PIXEl OF oDlg FONT oFnt //"Filial"
			@ nCmp1st1 ,a1stRow[2] + 024 MSGET oFilial VAR cFilLanc PIXEl SIZE 42, 10 OF oDlg PIXEL WHEN .F.

			@ nLbl1st1, a1stRow[2] + 071 Say OemToAnsi(STR0002) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Data"
			@ nCmp1st1, a1stRow[2] + 088 MSGET dDataLanc  Picture "99/99/9999" SIZE 45, 10 OF oDlg PIXEL HASBUTTON When aMvs[MV_ALTLCTO] Valid (NaoVazio(dDataLanc) .and. ;
				C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,3,2)).And.CtbValiDt(nOpc,dDataLanc) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)
							
			@ nLbl1st1, a1stRow[2] + 137 Say OemToAnsi(STR0003) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Lote"
			@ nCmp1st1, a1stRow[2] + 150 MSGET oLote VAR cLote Picture "@!" PIXEl SIZE 25, 10 OF oDlg When aMvs[MV_ALTLCTO];
				Valid NaoVazio(cLote) .and.;
				C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
				Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,;
				oDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)
								
			@ nLbl1st1, a1stRow[2] + 180 Say OemToAnsi(STR0013) SIZE 30,9 PIXEl	OF oDlg FONT oFnt	//"Sub-Lote"
			@ nCmp1st1, a1stRow[2] + 204 MSGET cSubLote Picture "!!!" PIXEl SIZE 24, 10 OF oDlg WHEN If( !lSeqCorr, aMvs[MV_ALTLCTO] .And. lSubLote, .F.) F3 "SB";
				VALID NaoVazio(cSubLote) .and.;
				C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
				Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,;
				oDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)
								
		  	@ nLbl1st1, a1stRow[2] + 237 Say OemToAnsi(STR0004) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Docto"
		  	@ nCmp1st1, a1stRow[2] + 253 MSGET cDoc Picture "999999" PIXEl SIZE 25, 10 OF oDlg When aMvs[MV_ALTLCTO];
				Valid NaoVazio(cDoc) .and.;
				Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,@CTF_LOCK,3) .And.;
				Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

			If lSeqCorr
		  		@ nLbl1st2 ,284 Say OemToAnsi(STR0014) PIXEl	OF oDlg SIZE 55,9 FONT oFnt	//"Correlativo"
		 		@ nCmp1st2 ,318 MSGET oDoc VAR cSeqCorr Picture PesqPict("CT2","CT2_NODIA") PIXEl	SIZE 80, 10 OF oDlg READONLY
			EndIf
			
			If cPaisLoc == "ARG" //Tratamento para o historico na capa do lote
		  		@ nLbl1st2 ,If(lSeqCorr,414,284) Say OemToAnsi(STR0068) PIXEl	OF oDlg SIZE 55,9 FONT oFnt	//"Historico"
		 		@ nCmp1st2 ,If(lSeqCorr,443,318) MSGET oHistCapLt VAR cHistCapLt Picture "@!" PIXEL SIZE 160, 10 OF oDlg
			EndIf
		
			TMP->(dbSetOrder(0))

			Ctb102TamHist()
			
			
			If aMvs[MV_ALTLCTO]
				oGetDB := MSGetDB():New( a2ndRow[1], a2ndRow[2], a2ndRow[3], a2ndRow[4], 4,"CT105LINOK", "CT105TOk", "+CT2_LINHA",.T.,aAltera,,.T., MAX_LINHA[2],"TMP",,,,oDlg,,,"CT102DEL(nOpc)")
				oGetDB:cSuperDel := "IIf(CT105SDEL(nOpc),(Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe),oGetDb:oBrowse:Refresh()),)"
			Else
				oGetDB := MSGetDB():New( a2ndRow[1], a2ndRow[2], a2ndRow[3], a2ndRow[4], 2,"AlwaysTrue", "AlwaysTrue", "+CT2_LINHA",	.F.,,,.T.,,"TMP",,,,oDlg,,,"CT102DEL(nOpc)")
			EndIf                                                        

			Ctb102TamHist(.T.)	    
	
			aTotMov	:= CtbTotMov()
			aTotais	:= Ctb050Tot(dDataLanc,cLote,cSubLote,cDoc)

			//Contem os saldos do CT6 + Conteudo da Tela
			aTotRdPe[1][2] := aTotMov[1][2]
			aTotRdPe[1][3] := aTotMov[1][3]
			aTotRdPe[1][1] := aTotMov[1][1]
			
			//Contem somente o que esta na GETDB.
			aTotRdPe[2][2] := aTotMov[1][2]
			aTotRdPe[2][3] := aTotMov[1][3]
			aTotRdPe[2][1] := aTotMov[1][1]
			
			nTotInf	:= aTotais[1][4]

			@ nLbl3rd1, a3rdRow[2] + 008  	SAY OemToAnsi(STR0012) Of oDlg PIXEL FONT oFnt //"Descri‡„o da Entidade"
			@ nCmp3rd1, a3rdRow[2] + 073 	SAY oDescEnt PROMPT space(50) FONT oDlg:oFont PIXEL COLOR CLR_HBLUE	Of oDlg
			
			@ nLbl3rd2, a3rdRow[2] + 008  	SAY OemToAnsi(STR0006) Of oDlg PIXEL FONT oFnt //"Total Informado :"
			@ nLbl3rd3, a3rdRow[2] + 008  	SAY OemToAnsi(STR0007) Of oDlg PIXEL FONT oFnt //"Total Digitado  :"
			@ nCmp3rd2, a3rdRow[2] + 065 	MSGET oInf VAR nTotInf Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			@ nCmp3rd3, a3rdRow[2] + 065 	MSGET oDig VAR aTotRdpe[1][1] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			
			@ nLbl3rd2, a3rdRow[2] + 190 	SAY OemToAnsi(STR0008) Of oDlg PIXEL FONT oFnt //"Total Debito  :"
			@ nLbl3rd3, a3rdRow[2] + 190	SAY OemToAnsi(STR0009) Of oDlg PIXEL FONT oFnt //"Total Credito :"
			@ nCmp3rd2, a3rdRow[2] + 240	MSGET oDeb VAR aTotRdPe[1][2] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			@ nCmp3rd3, a3rdRow[2] + 240	MSGET oCred VAR aTotRdPe[1][3] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			
			
			//ponto de entrada para usuario
			If lCT102DLG
				Execblock("CT102DLG",.f.,.f.)
			Endif

			If __lConOutR
				ConOutR("*PROCES*|FIM INTERFACE")
			EndIf
			
			ACTIVATE MSDIALOG oDlg ON INIT (	oGetDB:oBrowse:Refresh(),;
													EnchoiceBar(oDlg,{||nOpcA:=1,IIf(Ct105TOK(lCT105TOK,lCT105CHK,oGetDB:lModified,,aTotRdpe,nTotInf,,,@nValDif,@cLancCont) .And.;
											       Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK,nOpc) .And.;
 											       Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK),oDlg:End(),nOpcA := 0)}, {||If(AllTrim(ProcName(1)) <> "CTBA102",MsgAlert(STR0057,STR0011),oDlg:End())},,aButton))//"Atencao"##"Para encerrar essa opcao e necessario confirmar ou excluir a(s) linha(s) de lancamento(s) contabil!"				
				
		EndDo
			
		IF nOpcA == 1
		
			//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis. 
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente. 		
			If lAntCtbGrv
				ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
			Endif		                                                     

			//Validacao 
			lRpcOk	:= CTB105Rpc(lDigita)			          
			
			If !lRpcOk .Or. __PreLan == .T.
				cPreLcto	:= "S"
			Else
				cPreLcto	:= "N"
			EndIf					

			If __lConOutR
				ConOutR("*PROCES*|INICIO CTBGRAVA4")		
			EndIf
			
			If !Empty(nValDif)
				lGravaLanc := GravaDifCent(nValDif, cLancCont, @aCTKxCT2, cTabCTK)
			EndIf

			CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,__lCusto,__lItem,__lCLVL,nTotInf,cProgName,;
					cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,,,,;
					cHistCapLt)
           
			If __lConOutR
				ConOutR("*PROCES*|FIM CTBGRAVA4")		
			EndIf
			// Qdo o usuario solicita que nao mostre a tela de lancto, a tela sera exibida somente qdo houver alguma nao conformidade no doc.
			// Se os documentos seguintes estiverem corretos a tela não será exibida.
			lDigita := IIf( lDigitaOri, .T.,.F.)
			//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis. 
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente. 
			If lDepCtbGrv
				ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
			Endif		                                                     									
			
			//Dar ZAP no arquivo temporario para nao trazer residuos do documento anterior
			//dbSelectArea("TMP")
			//Zap
			If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo
				If ! CtbVerTmpBD()
					If __lTmp_Zap
					 
						//quando chamado rotina com instrucao CtbIniLan mas nao criado temporario no banco, pois nao vai utilizar procedure
						//nao apagar arquivo temporario pois a rotina CtbFinLan sera responsavel pela exclusao na SYSTEM
						//CtbInilan devera ser chamada nas rotinas batch de contabilizacao para melhorar performance
						dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
						Zap
						dbGoTop()
												
					Else
					
						TMP->(DbCloseArea())
						FErase( cArq1+cDBSExt )
						Ferase( cArq1+cIndExt )
						Ferase( cArq2+cIndExt )  
						cArq1 := ""
						cArq2 := ""
						Ctb105Cria(__aCampos,@cArq1,@cArq2)
					
					EndIf	
				Else
				
					dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
					TcSqlExec(" Truncate Table "+ cArq1 )   //Zap
					DbCommitAll()
					TcRefresh(cArq1)
					dbgobottom()
					dbgotop()
				EndIf
			EndIf
		Endif
	EndIf
EndDo

If CTF_LOCK > 0					/// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
	dbSelectArea("CTF")
	dbGoTo(CTF_LOCK)
	CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)			
Endif
        
If Select(cAliasCTK) > 0 //.And. ! ( "INFORMIX" $ Alltrim(Upper(TCGetDB())) ) 
	(cAliasCTK)->(DbCloseArea())
Endif
	
DbSelectArea( "CT2" )
//somente fecha e apaga os arquivos TMP se nao utiliza a nova procedure de gravacao do CT2
If ! CtbVerTmpBD()

	If __lTmp_Zap 
		//quando chamado rotina com instrucao CtbIniLan mas nao criado temporario no banco, pois nao vai utilizar procedure
		//nao apagar arquivo temporario pois a rotina CtbFinLan sera responsavel pela exclusao na SYSTEM
		//CtbInilan devera ser chamada nas rotinas batch de contabilizacao para melhorar performance
	Else
		//procedimento padrao a cada chamada da ca100Incl apaga os arquivos temporarios na SYSTEM
		TMP->(DbCloseArea())
		FErase( cArq1+cDbsExt )
		Ferase( cArq1+cIndExt )
		Ferase( cArq2+cIndExt )
	EndIf

Else

	dbSelectArea("TMP")  //qdo for criado no banco da zap em vez de recriar o arquivo
	TcSqlExec(" Truncate Table "+ cArq1 )   //Zap
	DbCommitAll()
	TcRefresh(cArq1)
	dbgobottom()
	dbgotop()
EndIf
//
// Restaurando ou Desabilitando as teclas de função utilizadas nesta função, que foram F4, F5, F6 e F7
//                 
If bVK_4 == NIL
	Set Key VK_F4 to
Else	
	SetKey(VK_F4,bVK_4)		
EndIf	
If bVK_5 == NIL
	Set Key VK_F5 to
Else	
	SetKey(VK_F5,bVK_5)		
EndIf	
If bVK_6 == NIL
	Set Key VK_F6 to
Else	
	SetKey(VK_F6,bVK_6)		
EndIf	
If bVK_7 == NIL
	Set Key VK_F7 to
Else	
	SetKey(VK_F7,bVK_7)		
EndIf	

If dReproc <> Nil .AND. GetMv( "MV_ATUSAL" )== "S"
	If aTpSaldo == Nil .Or. Len( aTpSaldo ) == 0
		aTpSaldo := {"1"}	//	Reprocessar ao menos o tipo de saldo 1-Real
	EndIf
	
	If lSimula
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		dbGoTop()
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)							
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
		dbSelectArea("CT2")
	Else
		CT2->(DbSetOrder(1))
	EndIf

	CT2->(DbSeek(Soma1(xFilial()), .T.))	// Procuro a proxima filial
	CT2->(DbSkip(-1))						// Volto para o registro anterior
	dCt2Data := CT2->CT2_DATA

	If !lSimula
		For nTipoSaldo := 1 to Len( aTpSaldo )
			If CT2->CT2_FILIAL = xFilial("CT2") .And. dCt2Data > dReproc
				CTBA190(.T.,dReproc,dCt2Data,cFilAnt,cFilAnt,aTpSaldo[nTipoSaldo],.F.,"  ")
			Else                    	
				CTBA190(.T.,dReproc,dReproc,cFilAnt,cFilAnt,aTpSaldo[nTipoSaldo],.F.,"  ")
			Endif
		Next
	EndIf
Endif
	
RestArea(aSaveArea)

PutHFile("")

If __lConOutR
	ConOutR("*LOGFIM*|FIM CTBA105",.T.)
EndIf

// efetua a limpeza dos caches da rotina
If __ClearCx
	ClearCx105()
Endif

			
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lancamento de complementar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If CTBLCUso()
	If (Type("__aCT2LC") == "A") .And. !Empty(__aCT2LC)
		CTBLCGerLC()
	Endif
Endif

Return .T.
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Head³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader para MsGetDB                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb105Head(aAltera)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 = Matriz com campos da MSGETDB                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expa1 = Array de alteracao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb105Head(aAltera,lSimula)

Local aSaveArea:= GetArea()
Local aFora		:= {"CT2_CALEND","CT2_DATA","CT2_LOTE", "CT2_SBLOTE", "CT2_DOC", "CT2_MOEDLC"}
Local aCampos	:= {}

If lAglByHist == Nil
	lAglByHist	:= GetNewPar("MV_AGLHIST",.F.) .or. UPPER(ALLTRIM(FUNNAME()))$(UPPER(GetNewPar("MV_AGLPROC","")))
Endif

PRIVATE nUsado := 0

Default lSimula	:= .F.

AADD(aFora,"CT2_DTLP")

// Na rotina de Lançamento Contábil Parametrizado (CTBA103) o tipo de saldo é 
If IsInCallStack("CTBA103")
	AADD(aFora,"CT2_TPSALD")	
EndIf

// Montagem da matriz aHeader
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("CT2")
While !EOF() .And. (x3_arquivo == "CT2")
	If ( Alltrim(x3_campo) == "CT2_LINHA" .Or. X3USO( X3_USADO )) .and. cNivel >= x3_nivel
		If Ascan(aFora,Trim(X3_CAMPO)) <= 0
			nUsado++
			AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, "TMP", x3_context } )
			If Alltrim(x3_campo) <> "CT2_LINHA"
				If cPaisLoc == "RUS" .And. SuperGetMv("MV_REDSTORN",.F.,.F.)
					If Alltrim(x3_campo) <> "CT2_EC05DB" .And. Alltrim(x3_campo) <> "CT2_EC05CR"
						Aadd(aAltera,Trim(X3_CAMPO))
					Endif
				Else
					Aadd(aAltera,Trim(X3_CAMPO))
				Endif
			EndIf
		EndIF
	EndIF
	aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
	dbSkip()
EndDO

If ( UPPER(TcGetDb()) == "AS/400" .OR. "INFORMIX" $ Alltrim(Upper(TCGetDB())) ) .and. lAglByHist 
	dbSetOrder(2)
	If MsSeek("CT2_HIST")
		aAdd(aCampos,{"CT2_TMPHIS", SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
	Else
		aAdd(aCampos,{"CT2_TMPHIS", "C", 40,0 } )
	Endif
	dbSetOrder(1)
Endif

//bloco para validacao do temporario quando criado diretamente no banco de dados
If CtbVerTmpBD()
	aadd(aCampos,{"CT2_VLD01","C",2,0})
	aadd(aCampos,{"CT2_VLD02","C",2,0})
	aadd(aCampos,{"CT2_VLD03","C",2,0})
	aadd(aCampos,{"CT2_VLD04","C",2,0})
	aadd(aCampos,{"CT2_VLD05","C",2,0})
	aadd(aCampos,{"CT2_VLD06","C",2,0})
	aadd(aCampos,{"CT2_VLD07","C",2,0})
	aadd(aCampos,{"CT2_VLD08","C",2,0})
	aadd(aCampos,{"CT2_VLD09","C",2,0})
	aadd(aCampos,{"CT2_VLD10","C",2,0})
	aadd(aCampos,{"CT2_VLD11","C",2,0})
	aadd(aCampos,{"CT2_VLD12","C",2,0})
	aadd(aCampos,{"CT2_VLD13","C",2,0})
	aadd(aCampos,{"CT2_VLD14","C",2,0})
	aadd(aCampos,{"CT2_VLD15","C",2,0})
	aadd(aCampos,{"CT2_VLD16","C",2,0})
	aadd(aCampos,{"CT2_VLD17","C",2,0})
	aadd(aCampos,{"CT2_VLD18","C",2,0})
	aadd(aCampos,{"CT2_VLD19","C",2,0})
	aadd(aCampos,{"CT2_VLD20","C",2,0})
	aadd(aCampos,{"CT2_VLD21","C",2,0})
	aadd(aCampos,{"CT2_VLD22","C",2,0})
	aadd(aCampos,{"CT2_VLD23","C",2,0})
	aadd(aCampos,{"CT2_VLD24","C",2,0})
	aadd(aCampos,{"CT2_VLD25","C",2,0})
	aAdd(aCampos,{"CT2_RECCTK", "N" , 10 ,0 } )
EndIf
	//Bloco necessario para consulta Walk-Thru
	Ctb102HeaderWT("CT2", aHeader)
	aadd(aCampos,{"CT2_REC_WT","N",10,0})
	aadd(aCampos,{"CT2_ALI_WT","C",3,0})
	
Aadd(aCampos,{"CT2_RECNO","N",9,0})
Aadd(aCampos,{"MODIFIED","N",1,0})
Aadd(aCampos,{"ATUSALDO","N",1,0})
Aadd(aCampos,{"CT2_FLAG","L",1,0}) 

If lCampoESP .And. !lSimula
	ExecBlock("C105CESP",.F.,.F.,{})			
Endif

RestArea(aSaveArea)

Return aCampos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Cria³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria arquivo temporario e indices para MSGETDB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintxe    ³ Ctb105Cria(aCampos,cArq1,cArq2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Matriz com campos da MSGETDB                       ³±±
±±³          ³ ExpC1 = Arquivo 1                                          ³±±
±±³          ³ ExpC2 = Arquivo 2                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb105Cria(aCampos,cArq1,cArq2)

Local aSaveArea		:= GetArea()
Local aChave
Local nAtt          := 0
//Local cDriver               := Upper(AllTrim(RealRDD()))

If lAglByHist == Nil
	lAglByHist	:= GetNewPar("MV_AGLHIST",.F.) .or. UPPER(ALLTRIM(FUNNAME()))$(UPPER(GetNewPar("MV_AGLPROC","")))
Endif

If Select( 'TMP') > 0
   DbSelectArea( "TMP" )
   DbCloseArea()
Endif

aChave := {"CT2_DC","CT2_DEBITO","CT2_CREDIT","CT2_CCD","CT2_CCC","CT2_ITEMD","CT2_ITEMC","CT2_CLVLDB","CT2_CLVLCR","CT2_TPSALD"}

If ( Upper(TcGetDb()) == "AS/400"  .OR. "INFORMIX" $ Alltrim(Upper(TCGetDB())) )  .and. lAglByHist
	Aadd( aChave, "CT2_TMPHIS" )
Endif

//Deleta tabela temporaria no banco, caso ja exita
If _oCTBA105 <> Nil
	_oCTBA105:Delete()
	_oCTBA105 := Nil
Endif
//---------------------------------------------------------------------------
//Cria tabela temporaria no banco de dados atraves da classe FwTemporaryTable
//---------------------------------------------------------------------------
_oCTBA105 := FWTemporaryTable():New( "TMP" )  
_oCTBA105:SetFields(aCampos)
_oCTBA105:AddIndex("1", aChave ) 
_oCTBA105:AddIndex("2", {"CT2_LINHA"}) 
_oCTBA105:Create()

dbSetOrder(1)

cArq1 := _oCTBA105:GETREALNAME()
cArq2 := _oCTBA105:GETREALNAME()

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105GRV ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arq. temporario com dados para MSGETDB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB105GRV( cSeqChave, lAglut, aCampos, dDataLanc, cSubLote )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Contador / Flag do lancamento                      ³±±
±±³          ³ ExpL1 = Aglutina lancamento?                               ³±±
±±³          ³ ExpA1 = Matriz com campos do arquivo temporario            ³±±
±±³          ³ ExpD1 = Data do lancamento                                 ³±±
±±³          ³ ExpC2 = SubLote                                            ³±±
±±³          ³ ExpN1 = Linha atual sendo processada                       ³±±
±±³          ³ ExpN2 = Recno atual                                        ³±±
±±³          ³ ExpC3 = Alias sendo processado [VIA TOP UTILIZA QUERY]     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105GRV( cSeqChave, lAglut, aCampos, dDataLanc, cSubLote,nLin, nRecCtk, cAliasCTK, aFlagCTB,	aCTKxCT2 ,;
					lEndCTK, lSeqCorr, cSeqCorr, aSeqDiario, lDCDUso, lSimula, cTabCTK, cTabCT2, cHistCapLt)
                                                                  
Local aSaveArea		:= GetArea()
Local cMoeda		:= ""
Local lSomaLinha	:= .t.
Local lZero			:= .T.
Local nLinha		:= 0
Local nVal	 		:= 0
Local nCont			:= 0
Local nCont1		:= 0
Local cSeqLan 		:= StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001"
Local nSeqHis 		:= 0
Local lRet			:= .F.
Local cLinha		:= Replicate( "9", Len(CT2->CT2_LINHA) )  // "999"
Local aPeriodos		:= {}
Local nOrdCTK 		:= 1
Local cCampoCtk	:= ""                           
Local nZ
Local cTpSald		:= ""
Local cCt2Conv		:= ""
Local cSrvType		:= TcSrvType()
Local nPosAFlag		:= 0
Local aCTKs			:= {}
Local cTmpValr    	:= ""
Local cCtkValr		:= ""                                      
Local nPosPer		:=	0
Local nValCTKTMP	:= 0

// ****************************
// Controle do Correlativo   *
// ****************************

Local cCodSeq		:= ""
Local lDiaCtb		:= .F.

Local lCache        := CtbCache(9)    

// ****************************
// Controle do Hash Map       *
// ****************************
Local lFound
Local cBusca 
Local nConta, xValue
Local aHash
Local oHash

Static lOrdEnt		:= If(GetNewPar("MV_ORDLCTB","L")=="E",.T.,.F.)			/// MV_ORDLCTB : L= LP (sequen+lp)/ E = Entrada (Recno)
Static lOrdTpSld	:= If(GetNewPar("MV_ORDLCTB","L")=="T",.T.,.F.)			/// MV_ORDLCTB : T= Tipo de Saldo


DEFAULT aCTKxCT2	:= {}
DEFAULT lEndCTK		:= .F.
DEFAULT lSeqCorr 	:= UsaSeqCor("CT2/CTK/CT5")
DEFAULT cSeqCorr 	:= CriaVar("CT2_NODIA")
DEFAULT aSeqDiario 	:= {} 

Default lDCDUso 	:= __lDCDUso    //  Digito de Controle

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

If lAglByHist == Nil
	lAglByHist	:= GetNewPar("MV_AGLHIST",.F.) .or. UPPER(ALLTRIM(FUNNAME()))$(UPPER(GetNewPar("MV_AGLPROC","")))
Endif

//array que contera se o campo "CT2_DTTX" estara em uso para a Moeda
If __alDtTaxa == NIL .Or. Len(__alDtTaxa) != __nQuantas
	__alDtTaxa 	:= Array(__nQuantas)
	__alDtTaxa[1] := .T.
	For  nCont := 2	To __nQuantas
		cMoeda := StrZero(nCont,2)
		__alDtTaxa[nCont] := CtbUso("CT2_DTTX"+cMoeda)
	Next
EndIf
DbSelectArea( cAliasCTK )

If nRecCTK > 0
	If "INFORMIX" $ Alltrim(Upper(TCGetDB()))
		dbGoto(nRecCTK) 
		nRecCTK := 0
	Endif
Endif 

nOrdCTK := IndexOrd()
   
If ( "INFORMIX" $ Alltrim(Upper(TCGetDB())) ) .and. lOrdEnt
	dbSetOrder(0)
Endif

cTpSldAtu 	:= (cAliasCTK)->CTK_TPSALD
lDiaCtb		:= UsaSeqCor("CT2/CTK/CT5")              
                    
If __lConOutR
	ConOutR("*PROCES*|INICIO CARGA CTK->TMP->CT2")
EndIf

While !Eof() .and. (cAliasCTK)->CTK_SEQUEN == cSeqChave .And. nLinha < MAX_LINHA[1]
	
	If lOrdTpSld			/// QUANDO ORDEM POR TIPO DE SALDO - QUEBRA DOCUMENTO POR TIPO DE SALDO
		If (cAliasCTK)->CTK_TPSALD <> cTpSldAtu
			nLin := MAX_LINHA[1]+1		/// SETA LINHA PARA QUEBRAR DOCUMENTO POR TIPO DE SALDO
			Exit
		EndIf
	EndIf
	
	If lDiaCtb
		If ( !Empty( (cAliasCTK)->CTK_DIACTB ) ) // A precedencia é o que está no LP
			cCodSeq := (cAliasCTK)->CTK_DIACTB
		ElseIf Len(aSeqDiario) >= 1 .And. ( !Empty(aSeqDiario[1][3])  .And. aSeqDiario[1][3] != "99" )
			cCodSeq := aSeqDiario[1][3]
		ElseIf Len(aSeqDiario) >= 1 
			cCodSeq := CtbrDia( (cAliasCTK)->CTK_LP ) 
		EndIf
	Endif
	
	// Verifica se existe algum valor <> de 0
	If (cAliasCTK)->CTK_DC != "4"
		lZero := .F.
		For nCont1 := 1 To __nQuantas
			If &(cAliasCTK + "->CTK_VLR"+StrZero(nCont1,2)) != 0
				lZero := .F.
				Exit
			Else
				lZero := .T.
			EndIf
		Next nCont1
	EndIf
	
	If !lZero
		DbSelectArea( "TMP" )
		DbSetOrder(1)
		If lAglut                             			
			If ! ( "INFORMIX" $ Alltrim(Upper(TCGetDB())) )  
				lSomaLinha	:= .T.
				CtdbAppend()			 
				nVal := 0						
			Else
				If AMVS[3] == "S"
					cTpSald	:= "9"
				Else
					cTpSald	:= (cAliasCTK)->CTK_TPSALD					
				EndIf				
			                    			
				cSeekTMP := (cAliasCTK)->(CTK_DC+CTK_DEBITO+CTK_CREDIT+CTK_CCD+CTK_CCC+CTK_ITEMD+CTK_ITEMC+;
				 		  CTK_CLVLDB+CTK_CLVLCR+cTpSald)
				 		  
				If lAglByHist
					If lCTKHAGLUT
						cSeekTMP += (cAliasCTK)->CTK_HIST /// Campo CTK_HAGLUT recebe CTK_HIST como apelido
					EndIf
				Endif
				If MsSeek(cSeekTMP)
						If TMP->CT2_DC = "4"
							nVal := 0
							CtdbAppend()
							lSomaLinha := .T.
						Else
							lSomaLinha := .F.
						EndIf
				Else
					nVal := 0
					CtdbAppend()
					lSomaLinha := .T.
				EndIf
			Endif
		Else
			CtdbAppend()
			lSomaLinha := .T.
		EndIf
		
		If CtbVerTmpBD()
			TMP->CT2_RECCTK := (cAliasCTK)->R_E_C_N_O_
		EndIf
		
		If lAglut
			cKeyCT5 := xFilial("CT5") + (cAliasCTK)->CTKLPLPSEQ					//// USA A QUERY (MAIOR LP E SEQUENCIA)
		Else																		//// SE NAO FOR AGLUTINADO
			cKeyCT5 := xFilial("CT5") + (cAliasCTK)->(CTK_LP+CTK_LPSEQ)		/// USA O LP E SEQUENCIA POSICIONADOS
		Endif

		CT5->(MsSeek(cKeyCT5))

		//Obtém o Historico do documento contábil da primeira sequencia	
		If cPaisLoc $ "ARG/EQU" .And. Empty(cHistCapLt)
			cHistCapLt := CT5->CT5_DOCHIS
		EndIf
		
		If Empty(TMP->CT2_MOEDAS)								
			TMP->CT2_MOEDAS := CT5->CT5_MOEDAS
			If CTBLCUso()
				If AllTrim((cAliasCTK)->CTK_ROTINA) == '__CTBLC__'
					cMoedCtk := ""
					For nCont1 := 1 To __nQuantas
						If &(cAliasCTK + "->CTK_VLR"+StrZero(nCont1,2)) <> 0
							cMoedCTK += "1"
						Else
							cMoedCTK += "2"
						EndIf
					Next nCont1
					TMP->CT2_MOEDAS := cMoedCTK
				Endif		
			Endif
		Endif			
		
		For nCont := 1 To Len(aCampos)
			cCampoCTK := "CTK_" + Substr(aCampos[nCont][1],5,Len(aCampos[nCont][1]))
			nPos := FieldPos(aCampos[nCont][1])
		
			If AllTrim(aCampos[nCont][1]) == "CT2_VALOR" // contabilização na moeda 01

				If !aMVS[MV_ALTLCTO]		// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ SE INCONSISTENTE)
					If lAglut
						TMP->CT2_VALOR += (cAliasCTK)->CTK_VLR01				
					Else
						TMP->CT2_VALOR := (cAliasCTK)->CTK_VLR01									
					EndIf                                                                                					
				ElseIf Left(TMP->CT2_MOEDAS,1) == "1"
					If lAglut
						TMP->CT2_VALOR += (cAliasCTK)->CTK_VLR01				
					Else
						TMP->CT2_VALOR := (cAliasCTK)->CTK_VLR01									
					EndIf                                                                                
				EndIf

			ElseIf Subs(aCampos[nCont][1],1,8) == "CT2_VALR" // contabilização das outras moedas

				//Verifica se existe calendario para a moeda na data do lancamento
				If lCache
					If (nPosPer := Ascan(aPerCache,{|x| x[1] == Subs(aCampos[nCont][1],9,2)})) == 0
						aPeriodos	:= CtbPeriodos(Subs(aCampos[nCont][1],9,2),dDataLanc,dDataLanc,.F.,.F.) 														
						aadd(aPerCache,{Subs(aCampos[nCont][1],9,2),aClone(aPeriodos)})
					Else
						aPeriodos	:=	aClone(aPerCache[nPosPer,2])
					Endif
				Else
					aPeriodos	:= CtbPeriodos(Subs(aCampos[nCont][1],9,2),dDataLanc,dDataLanc,.F.,.F.) 														
				EndIf

				// BOPS 131255 - RFC
				// tratamento dos campos do valor
				cTmpValr := "CT2_VALR" + Subs( aCampos[ nCont ][1] ,9 ,2 )
				cCtkValr := "CTK_VLR"  + Subs( aCampos[ nCont ][1] ,9 ,2 )

				// verifica se o campo existe antes de continuar a operacao
				// em agluns casos o campo existe no temporario mais não existe na query
				If ( TMP->( FieldPos( cTmpValr ) ) <= 0 .Or. ( cAliasCTK )->( FieldPos( cCtkValr ) ) <= 0 )
					Loop
				Endif

				// passo o valor da contabilização para uma variavel
				// afim de evitar sugeiras ou valores estranhos na contabilização
				nValCTKTMP := &( cAliasCTK + "->" + cCtkValr )

				If ! aMVS[MV_ALTLCTO]		// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ SE INCONSISTENTE)   
					If lAglut
						TMP->&cTmpValr += nValCTKTMP 
					Else
						TMP->&cTmpValr := nValCTKTMP 
					EndIf

				ElseIf ! Empty(aPeriodos[1][1]) .and. SubStr(TMP->CT2_MOEDAS,Val(Subs(aCampos[nCont][1],9,2)),1) == "1"

					If aPeriodos[1][4] $ "1"	//Se o calendario estiver aberto
						If lAglut
							TMP->&cTmpValr += nValCTKTMP 
						Else
							TMP->&cTmpValr := nValCTKTMP 
						EndIf
					Else
						Loop
					EndIf
				EndIf

				nValCTKTMP := 0

			ElseIf Subs( aCampos[ nCont ][1], 1, 9 ) == "CT2_DTCV3" // atualização da data do CV3
				TMP->CT2_DTCV3 := (cAliasCTK)->CTK_DATA

			ElseIf Tmp->(FieldPos(aCampos[nCont][1])) > 0 .And. (cAliasCTK)->(FieldPos(cCampoCTK)) > 0
				FieldPut(nPos,(cAliasCTK)->(FieldGet(FieldPos(cCampoCTK))))
			EndIf

		Next nCont
		If lSomaLinha
			If nLinha >  Val( Replicate( "9", Len(CT2->CT2_LINHA) ) ) - 1 // 998
				cLinha := Soma1(cLinha)
				nLinha++
				TMP->CT2_LINHA 	:= cLinha
			Else
				nLinha++
				TMP->CT2_LINHA 	:= StrZero(nLinha,Len(CT2->CT2_LINHA))  //3
			Endif
		EndIf
		
		If lAglut .AND. (cAliasCTK)->CONTAAGLUT > 1
			aAreaFlag := GetArea()
			If lSimula
				cQryFlag := " SELECT R_E_C_N_O_ FROM "+(cTabCTK)+" "
			Else
				cQryFlag := " SELECT R_E_C_N_O_ FROM "+RetSqlName("CTK")+" "
			EndIf
			cQryFlag += " WHERE CTK_FILIAL = '"+(cAliasCTK)->CTK_FILIAL+"' "
			cQryFlag += " AND CTK_SEQUEN = '"+(cAliasCTK)->CTK_SEQUEN+"' "
			cQryFlag += " AND CTK_DC = '"+(cAliasCTK)->CTK_DC+"' " 
			cQryFlag += " AND CTK_DEBITO = '"+(cAliasCTK)->CTK_DEBITO+"' "
			cQryFlag += " AND CTK_CREDIT = '"+(cAliasCTK)->CTK_CREDIT+"' "
			cQryFlag += " AND CTK_CCD = '"+(cAliasCTK)->CTK_CCD+"' "
			cQryFlag += " AND CTK_CCC = '"+(cAliasCTK)->CTK_CCC+"' "
			cQryFlag += " AND CTK_ITEMD = '"+(cAliasCTK)->CTK_ITEMD+"' "
			cQryFlag += " AND CTK_ITEMC = '"+(cAliasCTK)->CTK_ITEMC+"' "
			cQryFlag += " AND CTK_CLVLDB = '"+(cAliasCTK)->CTK_CLVLDB+"' "
			cQryFlag += " AND CTK_CLVLCR = '"+(cAliasCTK)->CTK_CLVLCR+"' "
			cQryFlag += " AND CTK_TPSALD = '"+(cAliasCTK)->CTK_TPSALD+"' "
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ BOPS 00000121784 - Remoção do campo CTK_ORIGEM da query de flags      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//cQryFlag += " AND CTK_ORIGEM = '"+(cAliasCTK)->CTK_ORIGEM+"' " 
			
			If lAglByHist
				If lCTKHAGLUT
					cQryFlag += " AND CTK_HAGLUT = '" +(cAliasCTK)->CTK_HIST + "' "		///TOPCONN CTK_HAGLUT ALIAS = CTK_HIST
				Else
					cQryFlag += " AND CTK_HIST = '" + (cAliasCTK)->CTK_HIST + "' " 
				EndIf
			EndIf

			cQryFlag += " AND D_E_L_E_T_ <> '*' "
				
			cQryFlag := ChangeQuery(cQryFlag)
			
			If Select("cQryFlag") > 0
				dbSelectArea("cQryFlag")
				dbCloseArea()
			EndIf
				
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryFlag),"cQryFlag",.T.,.T.)
			
			TcSetField("cQryFlag","R_E_C_N_O_","N",17,0)
			
			dbSelectArea("cQryFlag")							

			nLenAFlag := Len(aFlagCTB)
			
			If nLenAFlag > 0					//// CASO SEJA FEITA CONTABILIZACAO COM CONTROLE DE TRANSACAO
	
				// Criacao de HashMap para otimizar a busca da posicao no aFlagCTB
							
				aHash 		:= {}
				
				For nConta := 1 To Len(aFlagCTB)
					Aadd(aHash,{aFlagCTB[nConta,6],nConta})
				Next nConta
				
				oHash := aToHM(aHash)
				
				While cQryFlag->(!Eof())     
				
					cBusca := cQryFlag->R_E_C_N_O_
					lFound := HMGet( oHash , cBusca , @xValue )
														
					If lFound
						nPosAFlag := xValue[1,2]
					Else
						nPosAFlag := 0
					Endif

					If nPosAFlag > 0				/// SE TEM NO ARRAY DE FLAG DE CONTABILIZACAO REGISTRO CORRESPONDENTE
						nAFlag := nPosAFlag
						While nAFlag <= nLenAFlag .and. aFlagCTB[nAFlag][6] == cQryFlag->R_E_C_N_O_
							aFlagCTB[nAFlag][7] := TMP->(Recno())
							nAFlag++
						EndDo
					EndIf
					dbSkip()
				EndDo				
				cQryFlag->(dbGoTop())
			
				HMClean(oHash)	// Limpa o HashMap
			
			EndIf
												
			///////////////////////////////////////////////////////////////////////////////////
			/// CONTROLE DE RASTREAMENTO DOS LANCAMENTOS (SEM CTL) -> UTILIZADO NA CTBGRAVA()
			dbSelectArea("cQryFlag")
			aCTKs := {}
			While cQryFlag->(!Eof())
				aAdd( aCTKs, cQryFlag->R_E_C_N_O_ )
				cQryFlag->(dbSkip())
			EndDo				
			aAdd(aCTKxCT2,{TMP->(Recno()),aCTKs})
			///////////////////////////////////////////////////////////////////////////////////
			
			cQryFlag->(dbCloseArea())
			
			RestArea(aAreaFlag)
		Else		/// CASO NAO SEJA CONTABILIZACAO AGLUTINADA - TOPCONN		   			
			///////////////////////////////////////////////////////////////////////////////////
			/// CONTROLE DE RASTREAMENTO DOS LANCAMENTOS (SEM CTL) -> UTILIZADO NA CTBGRAVA()
			aAdd(aCTKxCT2,{TMP->(Recno()), { (cAliasCTK)->R_E_C_N_O_ } })
			///////////////////////////////////////////////////////////////////////////////////
			
			If Len(aFlagCTB) > 0					//// CASO SEJA FEITA CONTABILIZACAO COM CONTROLE DE TRANSACAO
				nPosAFlag := Ascan(aFlagCTB,{|x| x[6] == (cAliasCTK)->R_E_C_N_O_ })						
				If nPosAFlag > 0				/// SE TEM NO ARRAY DE FLAG DE CONTABILIZACAO REGISTRO CORRESPONDENTE
					nLenAFlag := Len(aFlagCTB)
					nAFlag := nPosAFlag	/// POSICAO INICIAL DO ARRAY CORRESPONDENTE AO LANCAMENTO
					While nAFlag <= nLenAFlag .and. aFlagCTB[nAFlag][6] == (cAliasCTK)->R_E_C_N_O_
						aFlagCTB[nAFlag][7] := TMP->(Recno())
						nAFlag++
					EndDo
				EndIf
			EndIf
		EndIf
		
		// Criterio de conversao
		If TMP->CT2_DC == "1" .Or. TMP->CT2_DC == "3"
			CarrCriter((cAliasCTK)->CTK_DEBITO,"1","TMP->CT2_CONVER",dDataLanc)
		EndIf
		If TMP->CT2_DC == "2" .Or. TMP->CT2_DC == "3"
			CarrCriter((cAliasCTK)->CTK_CREDIT,"2","TMP->CT2_CONVER",dDataLanc)
		EndIf
		
		If !lAglut			//Grava TMP->CT2_KEY
			TMP->CT2_KEY	:= (cAliasCTK)->CTK_KEY  
		Endif
		                                 
		// Valor nas outras moedas
		For  nCont := 2	To __nQuantas
			cMoeda := StrZero(nCont,2)

			// Verifica se moeda esta em uso ou se está bloqueada ou se data esta bloqueada para a moeda
			If (! CTBMInUse(cMoeda) ) 
				Loop
			EndIf
			
			If Substr(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. Substr(TMP->CT2_MOEDAS,nCont,1) == "3"
				cMoeda := StrZero(nCont,2)
				If lCache
					If (nPosPer := Ascan(aPerCache,{|x| x[1] == cMoeda})) == 0
						aPeriodos	:= CtbPeriodos(cMoeda,dDataLanc,dDataLanc,.F.,.F.) 														
						aadd(aPerCache,{cMoeda,aClone(aPeriodos)})
					Else
						aPeriodos	:=	aClone(aPerCache[nPosPer,2])
					Endif
				Else
					aPeriodos	:= CtbPeriodos(cMoeda,dDataLanc,dDataLanc,.F.,.F.)
				EndIf
				If !Empty(aPeriodos[1][1])                       										
					If !aMVS[MV_ALTLCTO]					/// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ)
						// Converte valores
					 	If &((cAliasCTK) + '->CTK_VLR'+StrZero(nCont,2)) == 0 .and. Empty(&("CT5->CT5_VLR"+StrZero(nCont,2)))
							&('TMP->CT2_VALR'+StrZero(nCont,2)) :=	CtbConv(Substr(TMP->CT2_CONVER,nCont,1),dDataLanc,cMoeda,TMP->CT2_VALOR)                                								
						EndIf	
					Else
						If aPeriodos[1][4] $ "1"	//Se o calendario estiver aberto									
							// Converte valores
							If &((cAliasCTK) + '->CTK_VLR'+StrZero(nCont,2)) == 0 .and. Empty(&("CT5->CT5_VLR"+StrZero(nCont,2)))
								&('TMP->CT2_VALR'+StrZero(nCont,2)) := CtbConv(Substr(TMP->CT2_CONVER,nCont,1),dDataLanc,cMoeda,TMP->CT2_VALOR)                                								
							EndIf                                								
						EndIf
					EndIf
				EndIf
			EndIf
			
			If __alDtTaxa[nCont] //CtbUso("CT2_DTTX"+cMoeda)
				&("TMP->CT2_DTTX"+cMoeda)	:= dDataLanc
			EndIf                           
			
		Next nCont

		//Atualizar o criterio de conversao apos prencher os valores em outras moedas. 
		//Se o valor na moeda 01 estiver zerado, alterar o criterio de conversao para "5". 
		//Nas outras moedas, o criterio de conversao devera ser alterado para "4". 
        cCt2Conv := TMP->CT2_CONVER
		
		For nCont := 1 to __nQuantas
			If nCont == 1      
				If TMP->CT2_VALOR == 0 
					cCt2Conv := "5" + SubStr(cCt2Conv,2,__nQuantas)
			    Else 
			    	cCt2Conv := "1" + SubStr(cCt2Conv,2,__nQuantas) 
			    EndIf
			Else
				// tratativa para o carregamento dos valores
				If ! Empty(&("CT5->CT5_VLR"+StrZero(nCont,2)))

					// criterio de conversão para as moedas
				    IF ALLTRIM(SubStr(cCt2Conv,2,__nQuantas)) == "A" .AND. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3" 
	 					&("TMP->CT2_VALR"+StrZero(nCont,2)):= &( &("CT5->CT5_VLR"+StrZero(nCont,2)))
						cCt2Conv	:= Stuff(cCt2Conv,nCont,1,"A")

					// se o criterio de conversão for 5, zero o valor da moeda
					ELSEIF ALLTRIM(SubStr(cCt2Conv,nCont,1)) == "5"
						&("TMP->CT2_VALR"+StrZero(nCont,2)):= 0

					ELSE
						// Senão somente modifico o criterio de conversão
						cCt2Conv	:= Stuff(cCt2Conv,nCont,1,"4")
					ENDIF
				
				// se o valor estiver zerado, modifico o criterio de conversão para 5	
				ElseIf &( "TMP->CT2_VALR" + Strzero( nCont,2 ) ) == 0
					If Subs(cCt2Conv,nCont,1) != "4"  //se for informado nao alterar para 5
						cCt2Conv := Stuff(cCt2Conv,nCont,1,"5")
					EndIf
				
				ElseIf Empty(Substr(cCt2Conv,nCont,1)) .and. !Empty(Substr(TMP->CT2_CONVER,nCont,1))
					cCt2Conv := Left(cCt2Conv,nCont-1)+Substr(TMP->CT2_CONVER,nCont,1)+SubStr(cCt2Conv,nCont+1,Len(cCt2Conv))
				EndIf
			EndIf
		Next	 
		
		If !Empty(cCt2Conv)		                
			// Pode ocorrer que neste momento a conta ainda esteja em branco (ver BOPS 89576). Se isso ocorrer, 
			// nao gravar no TMP o criterio de conversao. No momento que o usuario informar a conta, o sistema 
			// trara o criterio automaticamente do Plano de Contas.
			If !Empty(TMP->CT2_DEBITO) .Or. !Empty(TMP->CT2_CREDIT) 
				TMP->CT2_CONVER	:= cCt2Conv			
				cCt2Conv	:= ""
			EndIf
		EndIf											

		TMP->CT2_FLAG := .F.
		If TMP->CT2_LINHA == StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
			cSeqLan	:= StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001"
			nSeqHis	:= 1
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		ElseIf TMP->CT2_DC == '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
			nSeqHis ++
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		ElseIf TMP->CT2_DC != '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
			nSeqHis	:= 1
			cSeqLan := Soma1(cSeqLan)
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		Endif
		If aMvs[MV_PRELAN] = "S"		// Grava como pre lancamento se for S = Sempre
			TMP->CT2_TPSALD := D_PRELAN
		Endif

		If lSeqCorr
		    cSeqCrAnt := Iif( Type("cSeqOficNFE")="C", cSeqOficNFE, ;
		    				  Iif( valType(cSeqCorr)="C", cSeqCorr, Space(10) ) )

			If lSeqCorr .AND. lAglut
				cSeqCorr := CTBSQCor( Left((cAliasCTK)->CTKLPLPSEQ,3), cCodSeq, dDataLanc )
			ElseIf lSeqCorr
				cSeqCorr := CTBSQCor( (cAliasCTK)->CTK_LP, cCodSeq, dDataLanc )
			Endif

        	If cSeqCrAnt > cSeqCorr
        	   cSeqCorr := cSeqCrAnt  // trata o caso do correlativo manual (digitado)
        	EndIf
        EndIf	

		//Grava Digito verificador das contas, caso o campo esteja em uso
		If lDCDUso						//  Digito de Controle
			If Empty(TMP->CT2_DCD)
				dbSelectArea("CT1")                
				dbSetOrder(1)
				If MsSeek(xFilial()+TMP->CT2_DEBITO)
					TMP->CT2_DCD	:= CT1->CT1_DC
				EndIf
				dbSelectArea("TMP")
			EndIf
			If Empty(TMP->CT2_DCC)
				dbSelectArea("CT1")
				dbSetOrder(1)
				If MsSeek(xFilial()+TMP->CT2_CREDIT)
					TMP->CT2_DCC	:= CT1->CT1_DC
				EndIf
				dbSelectArea("TMP")		
			EndIf		
		EndIf

		If lAglut 													//// SE FOR AGLUTINADO
			If ( UPPER(TcGetDb()) == "AS/400" ) .and. lAglByHist
				If lCTKHAGLUT 
					TMP->CT2_TMPHIS := (cAliasCTK)->CTK_HAGLUT		/// GRAVA ANTES DO HISTORICO POIS PODE TER VARIAS LINHAS						
				Else
					TMP->CT2_TMPHIS := (cAliasCTK)->CTK_HIST		/// GRAVA ANTES DO HISTORICO POIS PODE TER VARIAS LINHAS
				EndIf
			Endif

			lGravaHist	 := .F.
			lGravaHAglut := .F.				
			If CT5->(MsSeek(cKeyCT5)) 		/// SE ACHAR O LANCAMENTO PADRAO DE ORIGEM
				If !Empty(CT5->CT5_HAGLUT)  /// E O HISTORICO AGLUTINADO ESTIVER PREENCHIDO
					If Empty(TMP->CT2_HIST)	/// SE O HISTORICO DO TMP ESTIVER VAZIO
						lGravaHAglut := .T.	/// MONTA HISTORICO AGLUTINADO
						lGravaHist	 := .T.
					Else					/// SE O HISTORICO DO TMP ESTIVER PREENCHIDO
						lGravaHAglut := .F.	/// GRAVA CONTINUAÇÕES DE HISTORICO DO CTK_HAGLUT/CTK_HIST (TOP)
						lGravaHist	 := .T.
					EndIf
				ElseIf lSomaLinha					/// SE NAO 1º REGISTRO AGLUTINACAO CODEBASE (TOP SEMPRE .T.)
					lGravaHist 		:= .T.
					lGravaHAglut	:= .F.
				EndIf
			Else
				lGravaHist		:= .F.
				lGravaHAglut	:= .F.
			EndIf
			
			If lGravaHist
				If lGravaHAglut
    				cTpSald 	:= TMP->CT2_TPSALD
					cHistorico 	:= AllTrim(TransLcta(CT5->CT5_HAGLUT,240))
					nLen := Iif( GetNewPar( "MV_CT5HIST" , .T. ), Len(CT2->CT2_HIST), Len(CTK->CTK_HIST) )					
					For nZ := 1 To Len(cHistorico) Step nLen
						If nZ > 1
							nSeqHis ++
						Endif
						cHist := SubStr(cHistorico,nZ,nLen)
						If nZ > 1
							dbSelectArea("TMP")
							DbSetOrder(2)
							DbSkip()
							If TMP->CT2_HIST = cHist
								Loop
							Endif
						
							CtdbAppend()
							TMP->CT2_DC	:= "4"

   			   				If nLinha > Val( Replicate( "9", Len(CT2->CT2_LINHA) ) ) - 1 // 998
								cLinha := Soma1(cLinha)
								nLinha++
								TMP->CT2_LINHA 	:= cLinha
							Else
								nLinha++
								TMP->CT2_LINHA 	:= StrZero(nLinha,Len(CT2->CT2_LINHA))    //3
							Endif
						Endif
						
						TMP->CT2_HIST	:= cHist
						TMP->CT2_TPSALD := cTpSald
						TMP->CT2_SEQLAN := cSeqLan
						TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
						TMP->CT2_LP		:= CT5->CT5_LANPAD
						TMP->CT2_MOEDLC := CT5->CT5_MOEDLC
						TMP->CT2_MOEDAS := CT5->CT5_MOEDAS
						TMP->CT2_ORIGEM	:= (cAliasCTK)->CTK_ORIGEM
					Next nZ
				Else								
			        nRecCTKPos := CTK->(Recno())
					dbSelectArea("CTK")
					dbSetOrder(1)
					dbGoTo((cAliasCTK)->(CTKMINRECNO))
						
		        	If lCTKHAGLUT .And. ! Empty(CT5->CT5_HAGLUT)
			        	cHistorico := CTK->CTK_HAGLUT
		        	Else
						cHistorico 	:= CTK->CTK_HIST						        	
		        	EndIf
					
					CTK->(dbSkip())
					While CTK->(!Eof()) .and. CTK->CTK_FILIAL == xFilial("CTK") .and. CTK->CTK_SEQUEN == cSeqChave .and. CTK->CTK_DC == "4"

			        	If lCTKHAGLUT .And. ! Empty(CT5->CT5_HAGLUT)
				        	cHistorico += CTK->CTK_HAGLUT
			        	Else
				        	cHistorico += CTK->CTK_HIST
				        EndIf
						CTK->(dbSkip())
					EndDo
					cHistorico := Rtrim(cHistorico)
					
					CTK->(MsGoTo(nRecCTKPos))						
					dbSelectArea("TMP")        
			
					cTpSald	:= TMP->CT2_TPSALD

					nLen 	:= Iif( GetNewPar( "MV_CT5HIST" , .T. ), Len(CT2->CT2_HIST), Len(CTK->CTK_HIST) )
					
					For nZ := 1 To Len(cHistorico) Step nLen
						If nZ > 1
							nSeqHis ++
						Endif
						cHist := SubStr(cHistorico,nZ,nLen)
						If nZ > 1
							dbSelectArea("TMP")
							DbSetOrder(2)
							DbSkip()
							If TMP->CT2_HIST = cHist
								Loop
							Endif
					
							CtdbAppend()
							TMP->CT2_DC	:= "4"
           	                     
	   			   			If nLinha > Val( Replicate( "9", Len(CT2->CT2_LINHA) ) ) - 1 // 998                          
								cLinha := Soma1(cLinha)
								nLinha++
								TMP->CT2_LINHA 	:= cLinha
							Else
								nLinha++
								TMP->CT2_LINHA 	:= StrZero(nLinha, Len(CT2->CT2_LINHA))
							Endif
						Endif
					    
						TMP->CT2_HIST	:= cHist
						TMP->CT2_TPSALD := cTpSald
						TMP->CT2_SEQLAN := cSeqLan
						TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
						TMP->CT2_LP		:= CT5->CT5_LANPAD
						TMP->CT2_MOEDLC := CT5->CT5_MOEDLC
						TMP->CT2_MOEDAS := CT5->CT5_MOEDAS
						TMP->CT2_ORIGEM	:= (cAliasCTK)->CTK_ORIGEM
					Next nZ
				EndIf

				If Empty(cSubLote)
					cSubLote	:= CT5->CT5_SBLOTE
				Endif
			Endif
		Else															//// SE NÃO FOR AGLUTINADO
			If Empty(cSubLote) .and. CT5->(MsSeek(cKeyCT5))				//// SE O NUMERO DE SUB-LOTE ESTIVER EM BRANCO
				cSubLote	:= CT5->CT5_SBLOTE
			Endif
		Endif
	EndIf
	
	If __lConOutR
		ConOutR("*PROCES*|ITEM ADICIONADO CARGA CTK->TMP->CT2")
	EndIf

	DbSelectArea( cAliasCTK )
	DbSkip()
	nLin ++
	lRet := .T.       
	
EndDo

If __lConOutR
	ConOutR("*PROCES*|TERMINO CARGA CTK->TMP->CT2")
EndIf
   
If CTK->(Eof()) .or. (cAliasCTK)->CTK_SEQUEN <> cSeqChave
   	lEndCTK := .T.	///Indica que terminou a leitura de registros do CTK para a contabilizacao.
EndIf
                                 
dbSelectArea(cAliasCTK)
dbSetOrder(nOrdCTK)
nRecCTK := Recno()
dbSelectArea("TMP")
dbSetOrder(2)
dbGoTop()
If lAglut				// Em caso de aglutinar a sequencia de lancamento
	cSeqLan := StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001" -  pode ser gerado errada, portanto eh refeita
	nSeqHis := 0
	While ! Eof()
		If TMP->CT2_LINHA == StrZero( 1, Len(CT2->CT2_LINHA) )  //'001'
			cSeqLan	:= StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001"
			nSeqHis	:= 1
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		ElseIf TMP->CT2_DC == '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )  //'001'
			nSeqHis ++
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		ElseIf TMP->CT2_DC != '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )  //'001'
			nSeqHis	:= 1
			cSeqLan := Soma1(cSeqLan)
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		Endif
		DbSkip()
	EndDo
Endif
TMP->(dbGotop())
RestArea(aSaveArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtExibeCta³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Criterio de Conversao - Validacao MSGETDB          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtExibeCta(cConta,cTipo)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta Contabil                                     ³±±
±±³          ³ ExpC2 = Tipo do Lancamento contabil                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtExibeCta(cConta,cTipo,dDataLanc)

// Carrega criterio de conversao
CarrCriter(cConta,cTipo,"TMP->CT2_CONVER",dDataLanc)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CarrCriter³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Criterio de Conversao para campo arq temporario    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CarrCriter(cConta,cTipo,cCampo)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta Contabil                                     ³±±
±±³          ³ ExpC2 = Tipo do Lancamento contabil                        ³±±
±±³          ³ ExpC3 = Campo                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CarrCriter(cConta,cTipo,cCampo,dDataLanc)

Local cCriter	
Local nCont
Local aSaveArea := GetArea()
Local aPeriodos	:= {}
Local lCT1Eof
Local lMVCRITPLN  := SuperGetMv( "MV_CRITPLN" , .F., .T.)
Local cPreenchido := ""

Local lCache := CtbCache(9)
Local nPosCrit := 0

DEFAULT dDataLanc := CTOD("  /  /  ")

// Criterio de conversao
If cTipo == "1" .Or. cTipo == "3"

	cCriter := "1"	//Ref a moeda 01
	If ( nPosCrit := Ascan(__aCritPln,{|x| x[1] == xFilial("CT1") + cConta}) ) > 0
		dbSelectArea( "CT1" )
		lCT1Eof := __aCritPln[nPosCrit][2]
		If !lCT1Eof
			dbGoto( __aCritPln[nPosCrit][3] )
		Else
			dbGoBottom()  //ultimo registro
			dbSkip() //posicionar em fim de arquivo
		EndIf
	Else
		dbSelectArea( "CT1" )
		dbSetOrder(1)
		dbSeek( xFilial("CT1") + cConta, .T. )
		lCT1Eof := CT1->( EOF() )
		
		aAdd( __aCritPln, {xFilial("CT1") + cConta,lCT1Eof, CT1->(Recno())})
		
	EndIf
	If lMVCRITPLN
		For nCont := 2	To __nQuantas
			If ! Empty( dDataLanc )

				If !aMVS[MV_ALTLCTO]					/// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ)

					If (FunName() $ 'CTBA102#CTBA103#CTBA104' .Or. ( FunName() <> 'CTBA102' .And. (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3" ) .Or. Empty(TMP->CT2_MOEDAS)))
						cCriter += &('CT1->CT1_CVD'+StrZero(nCont,2))
					Else
						cCriter += "5"
					EndIf
				Else
					//Verifica se exist e calendario para a moeda na data do lancamento
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == StrZero(nCont,2)})) == 0
							aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.) 														
							aadd(aPerCache,{StrZero(nCont,2),aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.)					
					EndIf

					If !Empty(aPeriodos[1][1])                       						
						If aPeriodos[1][4] $ "1".And. (FunName() $ 'CTBA102#CTBA103' 	.Or. ( FunName() <> 'CTBA102' .And. (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3" ) .Or. Empty(TMP->CT2_MOEDAS)))
							cCriter += &('CT1->CT1_CVD'+StrZero(nCont,2))
						Else
							cCriter += "5"
						EndIf						
					Else
						cCriter += "5"
					EndIf
				EndIf
			Else
				cCriter += &('CT1->CT1_CVD'+StrZero(nCont,2))
			EndIf
		Next nCont
	Else
		cCriter := &(cCampo)

		If Empty( cCriter )
			cCriter := CriaVar(StrTran(cCampo, "TMP", "CT2"))
		Endif
	Endif            
EndIf

If cTipo == "2" .Or. cTipo == "3"
	cCriter := "1"	//Ref. a moeda 01

	If ( nPosCrit := Ascan(__aCritPln,{|x| x[1] == xFilial("CT1") + cConta}) ) > 0
		dbSelectArea( "CT1" )
		lCT1Eof := __aCritPln[nPosCrit][2]
		If !lCT1Eof
			dbGoto( __aCritPln[nPosCrit][3] )
		Else
			dbGoBottom()  //ultimo registro
			dbSkip() //posicionar em fim de arquivo
		EndIf
	Else
		dbSelectArea( "CT1" )
		dbSetOrder(1)
		dbSeek( xFilial("CT1") + cConta, .T. )
		lCT1Eof := CT1->( EOF() )
		aAdd( __aCritPln, {xFilial("CT1") + cConta,lCT1Eof, CT1->(Recno())})
		
	EndIf
		
	If lMVCRITPLN
		For nCont := 2	To __nQuantas
			If !Empty(dDataLanc)
				If !aMVS[MV_ALTLCTO]					/// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ)
					If (FunName() $ 'CTBA102#CTBA103#CTBA104' .Or.;
						 ( FunName() <> 'CTBA102' .And. ;
						 (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3" ) .Or. Empty(TMP->CT2_MOEDAS)))							 			
						cCriter += &('CT1->CT1_CVC'+StrZero(nCont,2))
					Else
						cCriter += "5"
					EndIf											
				Else
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == StrZero(nCont,2)})) == 0
							aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.) 														
							aadd(aPerCache,{StrZero(nCont,2),aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.) 														
					EndIf
					
					If !Empty(aPeriodos[1][1])                                     
						If aPeriodos[1][4] $ "1" .And. (FunName() $ 'CTBA102#CTBA103#CTBA104' .Or.;
							 ( FunName() <> 'CTBA102' .And. ;
							 (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3") .Or. Empty(TMP->CT2_MOEDAS)))							 			
							cCriter += &('CT1->CT1_CVC'+StrZero(nCont,2))
						Else
							cCriter += "5"
						EndIf						
					Else
						cCriter += "5"
					EndIf
				EndIf
			Else			
				cCriter += &('CT1->CT1_CVC'+StrZero(nCont,2))
			EndIf
		Next nCont
	Else
		cCriter := &(cCampo)
		If Empty(cCriter)
			cCriter := CriaVar(StrTran(cCampo, "TMP", "CT2"))
		Endif
	Endif
EndIf

If !Empty(cCriter) .And. !Empty(cCampo)
	If Upper(cCampo) == "TMP->CT2_CONVER"
		If lMVCRITPLN .And. !lCt1Eof  
			cPreenchido := cCriter
		ElseIf Empty(&(cCampo)) .and. !lCt1Eof  //  Se o campo estiver vazio e encontrou a conta no CT1
			cPreenchido := cCriter
		EndIf
	Else
		cPreenchido := cCriter
	EndIf

	// colocado esse controle pois a rotina CTBA100 foi alterada de
	// MSGetDB da 11 para um AddGrid da 12
	// FIX: buscar uma solucao para nao ter que ficar colocando funname
	If FunName() == "CTBA100"
		FwFldPut(cCampo, cPreenchido)
	Else
		&(cCampo) := cPreenchido
	EndIf
EndIf

RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105Conv³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Valores de  Conversao - Validacao MSGETDB          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb105Conv(nValor,cCriter,cMoedas)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor do Lancamento Contabil                       ³±±
±±³          ³ ExpC1 = Criterio de Conversao                              ³±±
±±³          ³ ExpC2 = Moedas do Lancamento Contabil                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb105Conv(nValor,cCriter)

Local cMoeda
Local nValorConv
Local nCont
Local cCritAlt	:= ""
Local aSize
Local nVlMax

cCriter := Iif(Empty(cCriter),TMP->CT2_CONVER,cCriter)
nValor	:= Iif(nValor==Nil,TMP->CT2_VALOR,nValor)

// Zera valor na moeda 1 -> quando CT2_CONVER,1,1 = "2"
If Substr(cCriter,1,1) == "5" //Nao utiliza criterio de conversao
	TMP->CT2_VALOR := 0
EndIf  

//Se alterar o valor, atualiza o criterio de conversao.			
If nValor == 0
	cCritAlt	:= "5"+Subs(cCriter,2,Len(cCriter))
	TMP->CT2_CONVER	:= cCritAlt		
EndIf

	
For nCont := 1 To Len(cCriter)
	cMoeda := StrZero(nCont,2)
	
	// Atualiza a data de conversao conforme a data do lancamento
	If FunName() $ 'CTBA102#CTBA103#CTBA104' .AND. CtbUso( "CT2_DTTX" + cMoeda )
		&( "TMP->CT2_DTTX" + cMoeda ) := dDataLanc
	EndIf
	
	If cMoeda ='01'
		Loop
	EndIf
	
	// Verifica se moeda esta bloqueada ou se data esta bloqueada para a moeda
	lOkCTOCTP	:= (Ascan(aCTOCTPOk,cMoeda) > 0)
	If !lOkCTOCTP .And.(!CTBMInUse(cMoeda) .Or. !CtbDtInUse(cMoeda,dDataLanc))
		Loop
	Else	
		If !lOkCTOCTP
			AAdd(aCTOCTPOk,cMoeda)
		Endif
	EndIf						

	//Se alterar a taxa de conversao, atualiza os valores		
	If Substr(cCriter,nCont,1) <> "5"	//Se utiliza taxa de conversao
		If Substr(cCriter,nCont,1) <> "4" .And. Substr(cCriter,nCont,1) <> "A"	//Se for taxa informada, nao altero o valor na outra moeda
			aSize := TamSX3('CT2_VALR'+cMoeda)
			nVlMax := val(repl('9',aSize[1]-IIf(aSize[2]>0,aSize[2]+1,0)))
			If CtbUso("CT2_DTTX"+cMoeda) .And. Substr(cCriter,nCont,1) == "9"
				nValorConv 	:= CtbConv("9",&("TMP->CT2_DTTX"+cMoeda),cMoeda,nValor)									
			Else			
				nValorConv 	:= CtbConv(Substr(cCriter,nCont,1),dDataLanc,cMoeda,nValor)
			EndIf
			If int(nValorConv)>nVlMax
				Help(" ",1,"WIDTHERR",, STR0067 ,3,0 ) // "A conversão da moeda implicará em valor fora da faixa de representação numérica."
				Return .F.
			EndIf
			&('TMP->CT2_VALR'+cMoeda) := Round(nValorConv,aSize[2])
		EndIf
	Else
		&('TMP->CT2_VALR'+cMoeda) := 0
	EndIf
Next nCont
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105Cta ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida conta da GetDB                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb105Cta(cConta,cTipo)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 = Conta                                              ³±±
±±³          ³ Expc2 = Tipo da conta                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105CTA(cConta,cTipo)

Local aSaveArea := GetArea()
Local lRet		:= .T., lCtaNil
Local lRateio	:= .F.
Local nValRat	:= 0                        
Local nTotalDeb	:= 0
Local nTotalCrd	:= 0              
Local nRecTmp	:= 0
Local cProg		:= FunName()                                               	
Local cRateio	:= ""                                                      
Local cCampo	:= ReadVar()

If (lCtaNil := cConta = Nil)
	cConta := &(ReadVar())
Endif

If ! CtbInUse()			  		// Compatilizacao para usar tambem com SigaCon
	Return Ca050cta(cConta, 1)	// Nao utilizo ValidaConta por ser recursiva
Endif

If cTipo == Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc := dDataBase
Endif   

ConvConta(@cConta)	

//Verificar se a conta possui o campo de Rateio preenchido. Valido somente para a digitacao de lancamentos contabeis
//atraves da rotina CTBA102. Verifica se esta posicionado na Getdb, pois quando digitava a conta na tela de rateio
//estava mostrando a tela do valor a ratear novamente. 	
If cProg $ 'CTBA102#CTBA103#CTBA104' .And. (TMP->(Recno()) == TMP->(RecCount())) .And. ;
	(Subs(cCampo,4,10) == "CT2_DEBITO" .Or. Subs(cCampo,4,10) == "CT2_CREDIT")
	dbSelectArea("CT1")
	dbSetOrder(1)
	If (MsSeek(xFilial()+cConta,.F.)) .And. !Empty(CT1->CT1_RATEIO)
		//Mostra tela para digitacao do valor a ser rateado. Retorna o valor digitado.
		nValRat	:= Ctb102VlRt()	
		
		If nValRat > 0 
		    cRateio	:= CT1->CT1_RATEIO
			cTipo 		:= CtbRateio(cRateio,nValRat,@nTotalDeb,@nTotalCrd,"","","")			     
							
			aTotRdpe := {{0,0,0,0},{0,0,0,0}}

			nRecTmp := TMP->(Recno())
			TMP->(DbGoTop())
			While ! TMP->(Eof())		
				If Subs(cCampo,4,10) == "CT2_DEBITO" 
					lRateio	:= .T.
					If TMP->CT2_DC $ "1/3" .Or. ;
						(!Empty(TMP->CT2_CCD) .Or. !Empty(TMP->CT2_ITEMD) .Or. !Empty(TMP->CT2_CLVLDB))
						TMP->CT2_DEBITO := cConta							
					Else                                                    
						TMP->CT2_DEBITO := ""
					EndIf							
				ElseIf Subs(cCampo,4,10) == "CT2_CREDIT" 
					lRateio	:= .T.
					If TMP->CT2_DC $ "2/3" .Or. ;
						(!Empty(TMP->CT2_CCC) .Or. !Empty(TMP->CT2_ITEMC) .Or. !Empty(TMP->CT2_CLVLCR))															
						TMP->CT2_CREDIT	:= cConta												
					Else
						TMP->CT2_CREDIT	:= ""
					EndIf
				EndIf					
				If ! TMP->CT2_FLAG
					CTB102Exibe(TMP->CT2_VALOR,0,TMP->CT2_DC,"",GetMv("MV_SOMA"))
				Endif
				TMP->(DbSkip())		
			EndDo
			TMP->(DbGoTo(nRecTmp))			
		EndIf
	EndIf
EndIf    
  
//Se nao eh rateio de conta
If !lRateio 
	If cTipo == '1'
		TMP->CT2_DEBITO := cConta
	ElseIf cTipo <> Nil
		TMP->CT2_CREDIT := cConta
	Endif	
EndIf	

lRET := ValidaConta(cConta,cTipo,,,.T.)
If lRet
	If cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
		If ( TMP->CT2_DC $ '1/3' .And. cTipo == "1" ) .Or. ( TMP->CT2_DC $ '2/3' .And. cTipo == "2" )		
			CTExibeCta(cConta,cTipo,dDataLanc)
			C102ExbCta(cConta)
			Ctb105Conv()                          
			// Se a conta tiver um Hist. Padrao cadastrado e o Histórico na MSGETDB estiver em branco, 
			// jogar este Hist. Padrao na MSGETDB atraves de Ctb101Hist 
			If ! Empty(CT1->CT1_HP) .And. Empty(TMP->CT2_HP) .and. Empty(TMP->CT2_HIST)
				Ctb101Hist(CT1->CT1_HP,,,,,,,,.T.)
			EndIf
		EndIf
		If lRet 
			If !Empty(cConta) .And. TMP->CT2_DC == '4'
				Help(" ",1,"NOCTAHIS")
				lRet := .F.				
			EndIf
		EndIf				
	Endif       
	If lRet
		lRet :=	ValidaBloq(cConta,dDataLanc,"CT1")
	EndIf		
EndIf

If lRet .And. ((cTipo == Nil .And. lCtaNil) .or. ( (FunName() $ "CTBA102|CTBA103"  ) .And. IIf(cTipo != Nil, cTipo $ "1|2", .F.)  ))	// Chamada externa lancamentos contabeis nao passar tipo
	&(ReadVar()) := cConta
Endif	


RestArea(aSaveArea)

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105CC  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Centro de Custo da GetDB                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB105CC(cCusto,cTipo)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Centro de Custo                                    ³±±
±±³          ³ ExpC2 = Tipo do centro do custo                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105CC(cCusto,cTipo)

Local aSaveArea := GetArea()
Local lRet	:= .T., lCusNil

If (lCusNil := cCusto = Nil)
	cCusto := &(ReadVar())
Endif

If ! CtbInUse()				// Compatilizacao para usar tambem com SigaCon
	Return ExistCpo("SI3",cCusto)	// Nao utilizo ValidaCusto por ser recursiva
Endif

If cTipo = Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc := dDataBase
Endif

ConvCusto(@cCusto)

If cTipo == '1'
	TMP->CT2_CCD := cCusto
ElseIf cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
	TMP->CT2_CCC := cCusto	
Endif

lRET := ValidaCusto(cCusto,cTipo,,,.T.)
If lRet
	lRet := ValidaBloq(cCusto,dDataLanc,"CTT")
	If cTipo <> Nil // Chamada externa lancamentos contabeis nao passar tipo
		C102ExbCC(cCusto)
	Endif
EndIf

If lRet .And. cTipo = Nil .And. lCusNil		// Chamada externa lancamentos contabeis nao passar tipo
	&(ReadVar()) := cCusto
Endif

RestArea(aSaveArea)

Return lRet
	
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105ITEM³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Item Contabil da GetDB                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb105item(cItem,ctipo)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Item Contabil                                      ³±±
±±³          ³ ExpC2 = Tipo do Item contabil                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105Item(cItem,cTipo)

Local aSaveArea := GetArea()
Local lRet	:= .T., lItNil

If (lItNil := cItem = Nil)
	cItem := &(ReadVar())
Endif
	
If ! CtbInUse()				// Compatilizacao para usar tambem com SigaCon
	Return ExistCpo("SID",cItem)	// Nao utilizo ValidaCusto por ser recursiva
Endif

If cTipo = Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc := dDataBase
Endif

ConvItem(@cItem)

If cTipo == '1'
	TMP->CT2_ITEMD := cItem
ElseIf cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
	TMP->CT2_ITEMC := cItem
Endif

lRet := ValidItem(cItem,cTipo,,,.T.)
If lRet
	lRet := ValidaBloq(cItem,dDataLanc,"CTD")
	If cTipo <> Nil			// Chamada externa lancamentos contabeis nao passar tipo
		C102ExbIt(cItem)
	Endif
EndIf

If lRet .And. cTipo = Nil .And. lItNil	// Chamada externa lancamentos contabeis nao passar tipo
	&(ReadVar()) := cItem
Endif

RestArea(aSaveArea)

Return lRET


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105CLVL³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Classe de Valor da GetDB                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb105Clvl(cClVl,cTipo)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = classe de valor                                    ³±±
±±³          ³ ExpC2 = Tipo da classe de valor                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105CLVL(cClvl,cTipo)

Local aSaveArea := GetArea()
Local lRet	:= .T., lClNil

If (lClNil := cClVl = Nil)
	cClVl := &(ReadVar())
Endif

If cTipo = Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc := dDataBase
Endif

ConvCLVL(@cClvl)

If cTipo == '1'
	TMP->CT2_CLVLDB := cClvl
ElseIf cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
	TMP->CT2_CLVLCR := cClvl
Endif

lRET := ValidaCLVL(cCLVL,cTipo,,,.T.)

If lRet
	lRet :=	ValidaBloq(cCLVL,dDataLanc,"CTH")
	If cTipo <> Nil			// Chamada externa lancamentos contabeis nao passar tipo
		C102ExbCV(cClvl)
	Endif
EndIf

If lRet .And. cTipo = Nil .And. lClNil	// Chamada externa lancamentos contabeis nao passar tipo
	&(ReadVar()) := cClVl
Endif

RestArea(aSaveArea)

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CT105LINOK³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida linha do lancamento na MSGETDB                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct105LinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo  :                                                  ³±±
±±³          ³ lEfetiva: Se .T., indica que esta executando a rotina de   ³±±
±±³          ³           Efetivacao de Lanctos.				              ³±±
±±³          ³ aErro   : Array que recebera codigos para identificar as   ³±±
±±³          ³           inconsistencias. Sera utilizada na Efetivacao.   ³±±
±±³          ³ lTodas  : Se .T., indica que deve verificar todas as incon-³±±
±±³          ³           sistencias. Se .F., retornara na primeira incon- ³±±
±±³          ³           encontrada.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ANALISTA          * ALTERAÇÕES                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Wagner Montenegro * ADICIONADO TRATAMENTO PARA ATIVIDADES COMPLEMENTARES³±±
±±       28/04/2010 * FUNÇÃO CTBValidAt("??",?)??="DB" OU "CR"            ³±±
±±                  * ?=1 P/CTBA101 OU 2 P/CTBA105                        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT105LINOK(cCampo,lEfetiva,aErro,lTodas,nOpc,lDCDUso)

Local aSaveArea	:= GetArea()
Local cDCD			:= " "
Local cDCC			:= " "
Local cContCCD
Local cContCCC
Local cItemD
Local cItemC
Local cCLVLD
Local cCLVLC
Local cHist		:= TMP->CT2_HIST
Local cDebito  	:= TMP->CT2_DEBITO
Local cCredito 	:= TMP->CT2_CREDIT
Local cDC      	:= TMP->CT2_DC
Local cCriter
Local cLinha	:= TMP->CT2_LINHA
Local cTpSald	:= TMP->CT2_TPSALD

Local lRet			:= .t.
Local lDigito		:= .F.
Local lOutMoed		:= .T.
Local lVlrConv		:= .F.
Local lConverte		:= .F.
Local nOutVlr 		:= 0
Local cConver		:= ""

Local nCont
Local nValor   	:= TMP->CT2_VALOR
Local lRpc		:= Type("oMainWnd") <> "U"

Local nQtdMoeda

Local lCallEfet		:= FunName() == "CTBA350"

Local lVAt 			:= FindFunction("CTBValidAt")
Local cTpSaldoAnt 	:= ""
Local lCtrCtb       := SuperGetMV("MV_CTRCTB",.F.,"2") == "1"
Local lC105Vlin     := ExistBlock( "C105VLIN" )

// ARRAY PASSADO PARA FUNÇÃO CTBVALIDAT
Private aAtivCT1:={}
Private aAtivCTD:={}
Private aAtivCTH:={}
Private aAtivCTT:={}
Default cCampo		:= ""
Default lEfetiva	:= .F.		// Chamada a partir da Efetivacao de Lancamentos. Se .T., irá até o fim da rotina para encontrar todos os erros; por isso lRet recebera lEfetiva.
Default aErro		:= {}		// Retorna os codigos de erro para a Efetivacao, que gravará como inconsistencia
Default lTodas		:= .F.		// Se .F., indica que pode retornar na primeira inconsistencia encontrada; se .T.,
								//	devera verificar TODAS as inconsistencias 
If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

Default lDCDUso 	:= __lDCDUso          //  Digito de Controle

If Empty(nOpc)
	If TYPE("OPCAO") <> "U" .and. ValType(OPCAO) == "N"
		Default nOpc		:= OPCAO
	Else
		Default nOpc		:= 3
	EndIf
EndIf

If lEfetiva
	lRpc		:= .F.
	cCriter		:= Replicate( TMP->CT2_CRCONV,__nQuantas )
	nQtdMoeda	:= 1
Else
	If TMP->CT2_FLAG .and. GetNewPar( "MV_CT105LD" , 1 ) == 1							//  Linha Deletada
 		If lC105Vlin
			Return ExecBlock("C105VLIN", .F., .F.,{TMP->CT2_FLAG})
		Else
			Return .T.
		EndIf
	EndIf

	//	Se estiver no remote, não for CTBA101 e CTBA102, e nao permite alteração do lançamento
    If lRpc .And. !( FunName() $ "CTBA101#CTBA102#CTBA103#CTBA104" ) .And. !aMVS[MV_ALTLCTO]
    	lRpc := GetNewPar("MV_CT105MS","S") == "S"			//	S-Mostra msg; N-Não mostra msg
	EndIf
	cCriter		:= TMP->CT2_CONVER
	nQtdMoeda	:= __nQuantas
EndIf

If __lCusto									// Centro de custo
	cContCCD	:=	TMP->CT2_CCD
	cContCCC	:=	TMP->CT2_CCC
EndIf

If __lITem									// Item
	cItemD 	:= TMP->CT2_ITEMD
	cItemC 	:= TMP->CT2_ITEMC
EndIf

If __lCLVL									// Classe de Valor
	cClVLD	:= TMP->CT2_CLVLDB
	cCLVLC  := TMP->CT2_CLVLCR
EndIf

If lDCDUso						//  Digito de Controle
	cDCD  	:= TMP->CT2_DCD
	cDCC  	:= TMP->CT2_DCC
	lDigito	:= .T.
EndIf

// Novas entidades
If __lEnt05 
	cEnt05Db 	:= TMP->CT2_EC05DB
	cEnt05Cr 	:= TMP->CT2_EC05CR
Endif  

If __lEnt06 
	cEnt06Db 	:= TMP->CT2_EC06DB
	cEnt06Cr 	:= TMP->CT2_EC06CR
Endif  

If __lEnt07 
	cEnt07Db 	:= TMP->CT2_EC07DB
	cEnt07Cr 	:= TMP->CT2_EC07CR
Endif  

If __lEnt08 
	cEnt08Db 	:= TMP->CT2_EC08DB
	cEnt08Cr 	:= TMP->CT2_EC08CR
Endif  

If __lEnt09 
	cEnt09Db 	:= TMP->CT2_EC09DB
	cEnt09Cr 	:= TMP->CT2_EC09CR
Endif  

// ******************************************
// * Entidade Contabil 05 - Peru e Colombia *
// ******************************************
cEnt05Db := If(TMP->(FieldPos("CT2_EC05DB"))>0,TMP->CT2_EC05DB,'')
cEnt05Cr := If(TMP->(FieldPos("CT2_EC05CR"))>0,TMP->CT2_EC05CR,'')
cEnt06Db := If(TMP->(FieldPos("CT2_EC06DB"))>0,TMP->CT2_EC06DB,'')
cEnt06Cr := If(TMP->(FieldPos("CT2_EC06CR"))>0,TMP->CT2_EC06CR,'')
cEnt07Db := If(TMP->(FieldPos("CT2_EC07DB"))>0,TMP->CT2_EC07DB,'')
cEnt07Cr := If(TMP->(FieldPos("CT2_EC07CR"))>0,TMP->CT2_EC07CR,'')
cEnt08Db := If(TMP->(FieldPos("CT2_EC08DB"))>0,TMP->CT2_EC08DB,'')
cEnt08Cr := If(TMP->(FieldPos("CT2_EC08CR"))>0,TMP->CT2_EC08CR,'')
cEnt09Db := If(TMP->(FieldPos("CT2_EC09DB"))>0,TMP->CT2_EC09DB,'')
cEnt09Cr := If(TMP->(FieldPos("CT2_EC09CR"))>0,TMP->CT2_EC09CR,'')

cAtiviDb := If(TMP->(FieldPos("CT2_ATIVDE"))>0,TMP->CT2_ATIVDE,'')
cAtiviCr := If(TMP->(FieldPos("CT2_ATIVCR"))>0,TMP->CT2_ATIVCR,'')

If nOpc <> 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Tipo nao foi preenchido                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cDC )
		If lRpc
			Help( " ", 1, "FALTATPLAN" )
		EndIf	
		cCampo := "CT2_DC"
		lRet   := lTodas
		Aadd(aErro,1)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Valor nao preenchido                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .and. cDC <> "4"
		For nCont := 2 To nQtdMoeda
			cCoin4	:= StrZero(nCont,2)
			nOutVlr := &("TMP->CT2_VALR"+cCoin4)
			cConver	:= Subs(TMP->CT2_CONVER,nCont,1)
			                                                   
			//Teste para verificar se há algum valor de conversão.
			If nOutVlr <>  0  
				If cConver == "5"
					cCampo := "CT2_VLR"+cCoin4
					lRet   := lTodas
					Aadd(aErro,2)
					If lRpc
						Help( " ", 1, cCampo )
					EndIf	
					Exit
				EndIf
				lVlrConv		:= .T.				
			EndiF             		
		Next
			
		If lRet .and. (nValor = 0 .And. !lVlrConv)
			cCampo := "CT2_VALOR"
			lRet   := lTodas
			Aadd(aErro,2)
			If lRpc
				Help( " ", 1, "FALTAVALOR" )
			EndIf
		EndIf
	EndIf	
EndIf

If lRet .And. cDC <> "4"
	If cPaisLoc <> "BRA"
		//Se o parâmetro da blindagem contábil estiver habilitado = "1", será validado a configuração da blindagem contábil. 
		If lCtrCtb
			//Habilita a utilização da validação dos controles contábeis nos lançamentos contábeis manuais e de integração
			If !Empty(__cCodSeq)
				lRet := CTBVldCtrl(cDebito, cCredito,cLote ,cSubLote,__cCodSeq,cLinha)
			Else
				lRet := CTBVldCtrl(cDebito, cCredito,cLote ,cSubLote,,cLinha)
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ///MSL - 16/10/06
//³VALIDACAO DE BLOQUEIOS E AMARRAÇÕES (CTG, CTO, CTP).³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ///MSL - 16/10/06	
If lRet .and. cDC <> "4"	 
	If nOpc == 3 .or. nOpc == 6 .or. nOpc == 7	/// Se for inclusão (estorno ou copia inclusive)
		For nCont := 1 to nQtdMoeda	/// Roda todas as moedas
			If lEfetiva
				cCoin4		:= TMP->CT2_MOEDLC
				nVlrLan		:= TMP->CT2_VALOR
			Else
				cCoin4 		:= alltrim(strzero(int(nCont),2))
				iF nCont == 1 	
					nVlrLan := TMP->CT2_VALOR
				Else
					nVlrLan := 	&("TMP->CT2_VALR"+cCoin4)
				EndIf								
			EndIf

			If nVlrLan <> 0 // Se houver valor 
				// Verifica CTO e 			no CTP ausência ou bloqueios.
				lOkCTOCTP	:= (Ascan(aCTOCTPOk,cCoin4) > 0)
				If !lOkCTOCTP .And. (!CTBMInUse(cCoin4) .Or. !CtbDtInUse(cCoin4,dDataLanc))
					Aadd(aErro,19)
					lRet   := lTodas
					If lRpc
						Help( " ", 1, "CT2_VLR"+cCoin4 )
					EndIf
					If !lTodas
						Exit
					EndIf
				Else	
					If !lOkCTOCTP
						AAdd(aCTOCTPOk,cCoin4)
					Endif 					
 					If AScan(aMoedaOk, {|x| x[1] + IIF(lVldTps,x[2],"") == cCoin4 + IIF(lVldTps,cTpSald,"")} ) == 0					
						// Verifica CTG ausencia ou bloqueio de calendário.
						If CtbDtComp(3,dDataLanc,cCoin4,,cTpSald) 
							AAdd(aMoedaOk,{cCoin4,cTpSald})
						Else
							Aadd(aErro,19)
							lRet   := lTodas
							If !lTodas
								Exit							
							EnDif
						EnDif
					Endif
				EndIf						
			EndIf
			
			If lEfetiva
				Exit
			EndIf				
		Next			
	ElseIf nOpc == 4	/// Se for alteração

		cKeyLin 	:= ""
		For nCont := 1 to nQtdMoeda	/// Roda todas as moedas
			cCoin4 		:= alltrim(strzero(int(nCont),2))
			lValidCoin	:= .F.
			/// SE TIVER VALOR NA MOEDA VALIDA
			If nCont == 1 
				If TMP->CT2_VALOR <> 0
					lValidCoin	:= .T.
				EndIf
			Else
				If &("TMP->CT2_VALR"+cCoin4) <> 0
					lValidCoin  := .T.
				EndIf
			EndIf
			
			If lCallEfet				/// Se for chamada, pela tela de lancto na efetivação.
				lValidCoin	:= .T.
			Else
				lValidCoin	:= .F.
			
				If nCont == 1	// Na moeda 01			
					If TMP->CT2_RECNO > 0	
						CT2->(MsGoTo(TMP->CT2_RECNO))
						cTpSaldoAnt := CT2->CT2_TPSALD
						If TMP->CT2_RECNO == CT2->(Recno())
							/// Se o lançamento da moeda 01 já existe
							cKeyLin := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI)
							If TMP->CT2_VALOR <> CT2->CT2_VALOR // e mudou o valor do lançamento
								lValidCoin := .T.
							EndIf
							
							If !lValidCoin
								If Len(CtbMudouL(,,CT2->(Recno()) )) > 0
									lValidCoin := .T.
								EndIf
							EndIf
							
						Else
							// Se o lançamento da moeda 01 não existe
							If TMP->CT2_VALOR <> 0
								lValidCoin := .T.
							EndIf
						EndIf
					Else	// Se o lançamento da moeda 01 não existe
						If TMP->CT2_VALOR <> 0
							lValidCoin := .T.
						EndIf
					EndIf
				Else		// Nas moedas de conversão 0X
					nVlrLan := &("TMP->CT2_VALR"+cCoin4)
					dbSelectArea("CT2")
					dbSetOrder(1)
					If Empty(cKeyLin)
					   cKeyLin := xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+TMP->(CT2_TPSALD+CT2_EMPORI+CT2_FILORI)
					EndIf
					If dbSeek(cKeyLin+cCoin4,.F.)
					   cTpSaldoAnt := CT2->CT2_TPSALD					   
					   If nVlrLan <> CT2->CT2_VALOR	
							lValidCoin := .T.
					   EndIf
					   
						If !lValidCoin
							If Len(CtbMudouL(,,CT2->(Recno()) )) > 0
								lValidCoin := .T.
							EndIf
						EndIf
					   
					Else
						If nVlrLan <> 0
							lValidCoin	:= .T.
						EnDif
					EndIf					
				EndIf 
			EndIf

			If lValidCoin
				// Verifica CTO e 			no CTP ausência ou bloqueios.
				lOkCTOCTP	:= (Ascan(aCTOCTPOk,cCoin4) > 0)
				If !lOkCTOCTP .And. (!CTBMInUse(cCoin4) .Or. !CtbDtInUse(cCoin4,dDataLanc))
					Aadd(aErro,19)
					lRet   := lTodas
					If lRpc
						Help( " ", 1, "CT2_VLR"+cCoin4 )
					EndIf
					If !lTodas
						Exit
					EndIf
				Else	
					If !lOkCTOCTP
						AAdd(aCTOCTPOk,cCoin4)
					Endif
					
					If !Empty(cTpSaldoAnt)  
						If !CtbDtComp(3,dDataLanc,cCoin4,,cTpSaldoAnt) 
					    	lRet := .F.
					    	Exit
						EndIf
					EndIf
					
					// Verifica CTG ausencia ou bloqueio de calendário.
					If AScan(aMoedaOk, {|x| x[1] + IIF(lVldTps,x[2],"") == cCoin4 + IIF(lVldTps,cTpSald,"")} ) == 0						
						If CtbDtComp(3,dDataLanc,cCoin4,,cTpSald) 
							AAdd(aMoedaOk,{cCoin4,cTpSald})
						Else
							Aadd(aErro,19)
							lRet   := lTodas
		 					If !lTodas
								Exit							
							EnDif
						EnDif
					Endif
				EndIf						
			EndIf
		Next			

	ElseIf nOpc == 5	/// Se for Exclusão
		For nCont := 1 to nQtdMoeda	/// Roda todas as moedas
			cCoin4 		:= alltrim(strzero(int(nCont),2))
			iF nCont == 1 	
				nVlrLan := TMP->CT2_VALOR
			Else
				nVlrLan := 	&("TMP->CT2_VALR"+cCoin4)
			EndIf				

			If nVlrLan <> 0 // Se houver valor 
				// Verifica CTO e no CTP ausência ou bloqueios.
				lOkCTOCTP	:= (Ascan(aCTOCTPOk,cCoin4) > 0)
				If !lOkCTOCTP .And. (!CTBMInUse(cCoin4) .Or. !CtbDtInUse(cCoin4,dDataLanc))
					Aadd(aErro,19)
					lRet   := lTodas
					If lRpc
						Help( " ", 1, "CT2_VLR"+cCoin4 )
					EndIf
					If !lTodas
						Exit
					EndIf
				Else	
					If !lOkCTOCTP
						AAdd(aCTOCTPOk,cCoin4)
					Endif
					// Verifica CTG ausencia ou bloqueio de calendário.
					If AScan(aMoedaOk, {|x| x[1] + IIF(lVldTps,x[2],"") == cCoin4 + IIF(lVldTps,cTpSald,"")} ) == 0					
						If CtbDtComp(3,dDataLanc,cCoin4,,cTpSald) 
							AAdd(aMoedaOk,{cCoin4,cTpSald})
						Else
							Aadd(aErro,19)
							lRet   := lTodas
							If !lTodas
								Exit							
							EnDif
						Endif
					EnDif
				EndIf						
			EndIf
		Next			
	EndIf
EndIf	

If nOpc <> 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Historico nao preenchido                         								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If Empty( cHist )
			If lRpc
				Help( " ", 1, "CTB105HIST" )
			EndIf
			cCampo := "CT2_HIST"
			lRet   := lTodas
			Aadd(aErro,3)
		EndIf
	EndIf                            
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se eh lancamento de historico complementar, nao pode ter valor.						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If cDC == "4" .And. TMP->CT2_VALOR <> 0 
			If lRpc
				Help ( " " ,1, "CONTHIST")
			EndIf
			cCampo := "CT2_VLR01"
			lRet   := lTodas
			Aadd(aErro,4)
		EndIf
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se eh lancamento de historico complementar, nao pode ter conta prenchida.			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 If lRet
		If cDC == "4" .And. (!Empty(TMP->CT2_DEBITO) .Or. !Empty(TMP->CT2_CREDIT) .Or. !Empty(TMP->CT2_CCD) .Or.!Empty(TMP->CT2_CCC) .Or. ;
								!Empty(TMP->CT2_ITEMD) .Or. !Empty(TMP->CT2_ITEMC) .Or. !Empty(TMP->CT2_CLVLDB) .OR. !Empty(TMP->CT2_CLVLCR)  )
			If lRpc
				Help( " ",1,"HISTNOENT")								
	  	 	EndIf
			If !Empty(TMP->CT2_DEBITO)
				cCampo := "CT2_DEBITO"
			ElseIf !Empty(TMP->CT2_CREDIT)
				cCampo := "CT2_CREDIT"
			ElseIf !Empty(TMP->CT2_CCD) 
				cCampo := "CT2_CCD"
			ElseIf !Empty(TMP->CT2_CCC) 
				cCampo := "CT2_CCC"
			ElseIf !Empty(TMP->CT2_ITEMD)
				cCampo := "CT2_ITEMD"
			ElseIf !Empty(TMP->CT2_ITEMC)
				cCampo := "CT2_ITEMC"
			ElseIf !Empty(TMP->CT2_CLVLDB)
				cCampo := "CT2_CLVLDB"
			ElseIf !Empty(TMP->CT2_CLVLCR)	
				cCampo := "CT2_CLVLCR"
			Endif
			lRet	:= lTodas
			Aadd(aErro,5)
	    EndIf
	 EndIf
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloco de Valida‡oes Lancamentos a Debito                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 5
	If lRet
		If cDC $ "13"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CONTA CONTABIL A DEBITO                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta foi preenchida                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( cDebito )
				If lRpc
					Help(" ", 1, "FALTA DEB" )
				EndIf
				cCampo := "CT2_DEBITO" 
				lRet   := lTodas
				Aadd(aErro,6)
			Endif

			//-------------------------------------------------------------------------------
			//	Valida se no lancamento do tipo debito existem campos de credito preenchidos
			//  Validacao retirada por não estar de acordo com o documentacao do sistema
			//-------------------------------------------------------------------------------

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta existe e nao e sintetica                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet:= ValidaConta(cDebito,"1",,,.T.,lRpc)
				If lRet
					If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
						lRet := ValidaBloq(cDebito,dDataLanc,"CT1",lRpc)
						If !lRet
							Aadd(aErro,7)
							lRet := lTodas
						EndIf
					EndIf
				Else
					If lEfetiva
						Aadd(aErro,20)
						lRet := lTodas
						If lRet .And. ValidaBloq(cDebito,dDataLanc,"CT1",lRpc)
							Aadd(aErro,7)
						EndIf
					EndIf
				EndIf
				If !lRet
					cCampo := "CT2_DEBITO"
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ DIGITO DE CONTROLE - CONTA DEBITO                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If lDigito  
				
			  		dbSelectArea("CT1")                
			   		dbSetOrder(1)
			   		MsSeek(xFilial()+TMP->CT2_DEBITO)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se lan‡amento e devedor e digito da conta nao preenchido                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty( cDCD )
						If lRpc
							Help( " ", 1, "DIG-DEBITO" )
						EndIf
						lRet := lTodas
						Aadd(aErro,8)
					ElseIf cDCD != CT1->CT1_DC
						If lRpc
							Help( " ", 1, "DIGITO" )
						EndIf
						lRet := lTodas
						Aadd(aErro,9)
					Endif
					If !lRet
						cCampo := "CT2_DCD"
					Endif
				EndIf
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CENTRO DE CUSTO - DEBITO                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCusto
					If lRet
						lRet:= ValidaCusto(cContCCD,"1",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cContCCD,dDataLanc,"CTT",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else 
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cContCCD,dDataLanc,"CTT",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					Endif
					If !lRet
						cCampo := "CT2_CCD"
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ITEM - DEBITO 		                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lItem
					If lRet 
						lRet:= ValidItem(cItemD,"1",,,.T.,lRpc)
						If lRet               
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cItemD,dDataLanc,"CTD",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else 
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cItemD,dDataLanc,"CTD",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CLASSE VALOR - DEBITO 		                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCLVL
					If lRet
						lRet:= ValidaCLVL(cCLVLD,"1",,,.T.,lRpc)
						If lRet  
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cCLVLD,dDataLanc,"CTH",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else 
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cCLVLD,dDataLanc,"CTH",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se as amarracoes estao corretas                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet  := _CtbAmarr(.T., cDebito,cContCCD,cItemD,cCLVLD,.T.,lRpc,.T.)
				If !lRet .And. lEfetiva
					Aadd(aErro,10)
					lRet := lTodas
				EndIf
			EndIf
			
			//Valida informações complementares
			If ( lVAt ) .And. ( lRet )
				lRet := CTBValidAt( "DB", 2, cDebito, cContCCD, cItemD, cCLVLD )	//Função do CTBXFUNC.PRW
			Endif
   			
   			// Valida Entidades Obrigatorias -> Ligacao entre Conta e demais entidades
			If lRet			       
				lRet  := CtbObrig(  cDebito,;
									cContCCD,;
									cItemD,;
									cCLVLD,;
									.T.,;
									"1",;
									lRpc,;
									cEnt05Db,;
									"",;
									cEnt05Db,;
									cEnt06Db,;
									cEnt07Db,;
									cEnt08Db,;
									cEnt09Db,,,;
									aAtivCT1, aAtivCTD, aAtivCTH, aAtivCTT )

				If !lRet .And. lEfetiva
					Aadd(aErro,11)
					lRet := lTodas
				EndIf
			EndIf

			//-------------------------------------------------------------------
			// Valida se a conta contábil permite lançamento de variação cambial
			//-------------------------------------------------------------------
			If lRet
				If !Empty(TMP->CT2_MOEFDB) .And. GetAdvFVal("CT1","CT1_PVARC",XFilial("CT1")+cDebito,1,"",.T.) == "2" 
					lRet := .F.
					Help( " ", 1, "CT105LINOK",,STR0089 + RetTitle("CT2_MOEFDB"), 1, 0 ) //"A conta contábil débito está configurada para não permitir a geração de variação cambial. Verifique o cadastro da conta contábil ou o valor informado no campo " 
				Endif
			EndIf

		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bloco de Valida‡oes Lancamentos a Credito                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If cDC $ "23"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CONTA CONTABIL A CREDITO                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta foi preenchida                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( cCredito )
				If lRpc
					Help( " ", 1, "FALTA CRD" )
				EndIf
				cCampo := "CT2_CREDIT"
				lRet   := lTodas
				Aadd(aErro,12)
			Endif

			//-------------------------------------------------------------------------------
			//	Valida se no lancamento do tipo credito existem campos de debito preenchidos
			//  Validacao retirada por não estar de acordo com o documentacao do sistema
			//-------------------------------------------------------------------------------

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta existe e nao e sintetica                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet     
				lRet := ValidaConta(cCredito,"2",,,.T.,lRpc)
				If lRet          
					If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
						lRet := ValidaBloq(cCredito,dDataLanc,"CT1",lRpc)
						If !lRet
							Aadd(aErro,7)
							lRet := lTodas
						EndIf
					EndIf
				Else 
					If lEfetiva
						Aadd(aErro,20)
						lRet := lTodas
						If lRet .And. ValidaBloq(cCredito,dDataLanc,"CT1",lRpc)
							Aadd(aErro,7)
						EndIf
					EndIf
				EndIf
				If !lRet
					cCampo := "CT2_CREDIT"
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ DIGITO DE CONTROLE - CONTA CREDITO                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If lDigito
					dbSelectArea("CT1")                
			   		dbSetOrder(1)
			   		MsSeek(xFilial()+TMP->CT2_CREDIT)

				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se lan‡amento ‚ credor e digito da conta nao preenchido                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty( cDCC )
						If lRpc
							Help( " ", 1, "DIG-CREDIT" )
						EndIf
						lRet  := lTodas
						Aadd(aErro,13)
					ElseIf cDCC != CT1->CT1_DC
						If lRpc
							Help( " ", 1, "DIGITO" )
						EndIf
						lRet  := lTodas
						Aadd(aErro,9)
					Endif
					If !lRet
						cCampo := "CT2_DCC"
					Endif
				Endif
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CENTRO DE CUSTO - CREDITO                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCusto
					If lRet
						lRet:= ValidaCusto(cContCCC,"2",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cContCCC,dDataLanc,"CTT",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cContCCC,dDataLanc,"CTT",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf 
						EndIf
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ITEM - CREDITO		                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lItem
					If lRet
						lRet:= ValidItem(cItemC,"2",,,.T.,lRpc)
						If lRet               
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cItemC,dDataLanc,"CTD",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else 
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cItemC,dDataLanc,"CTD",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CLASSE VALOR - CREDITO		                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCLVL
					If lRet  
						lRet := ValidaCLVL(cCLVLC,"2",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva										
								lRet := ValidaBloq(cCLVLC,dDataLanc,"CTH",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
					Else
						If lEfetiva
							Aadd(aErro,20)
							lRet := lTodas
							If lRet .And. ValidaBloq(cCLVLC,dDataLanc,"CTH",lRpc)
						  		Aadd(aErro,7)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se as amarracoes estao corretas                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet  := _CtbAmarr(.F., cCredito,cContCCC,cItemC,cCLVLC,.T.,lRpc,.t.)
				If !lRet .And. lEfetiva
					Aadd(aErro,10)
					lRet := lTodas
				EndIf
			EndIf
			
			//Valida informações complementares
			If ( lVAt ) .And. ( lRet )
				lRet := CTBValidAt( "CR", 2, cCredito, cContCCC, cItemC, cCLVLC )	//Função do CTBXFUNC.PRW
			Endif
			
			// Valida Entidades Obrigatorias -> Ligacao entre Conta e demais entidades
			If lRet			      
			 
				lRet := CtbObrig(   cCredito,;
									cContCCC,;
									cItemC,;
									cCLVLC,;
									.T.,;
									"2",;
									lRpc,;
									cEnt05Cr,;
							   		"",;
									cEnt05Cr,;
									cEnt06Cr,;
									cEnt07Cr,;
									cEnt08Cr,;
									cEnt09Cr,,,;
									aAtivCT1, aAtivCTD, aAtivCTH, aAtivCTT )

				If !lRet .And. lEfetiva
					Aadd(aErro,11)
					lRet := lTodas
				EndIf
			EndIf	

			//-------------------------------------------------------------------
			// Valida se a conta contábil permite lançamento de variação cambial
			//-------------------------------------------------------------------
			If lRet
				If !Empty(TMP->CT2_MOEFCR) .And. GetAdvFVal("CT1","CT1_PVARC",XFilial("CT1")+cCredito,1,"",.T.) == "2" 
					lRet := .F.
					Help( " ", 1, "CT105LINOK",,STR0090 + RetTitle("CT2_MOEFCR"), 1, 0 ) //"A conta contábil crédito está configurada para não permitir a geração de variação cambial. Verifique o cadastro da conta contábil ou o valor informado no campo " 
				Endif
			EndIf

		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as moedas foram informados corretamente ( 1=S ou 2=N )                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (cDebito == cCredito) .And. cDC == "3"
		lEqual := .T.

		If lEqual .And. __lCusto
			lEqual := Alltrim( cContCCD ) == Alltrim( cContCCC )
		Endif
	
		If lEqual .And. __lItem
			lEqual := Alltrim( cItemD ) == Alltrim( cItemC )
		Endif
		
		If lEqual .And. __lCLVL
			lEqual := Alltrim( cCLVLD ) == Alltrim( cCLVLC )
		Endif  
		
		If lEqual .And. __lEnt05
			lEqual := Alltrim( cEnt05Db ) == Alltrim( cEnt05Cr)
		Endif  
	
		If lEqual .And. __lEnt06
			lEqual := Alltrim( cEnt06Db ) == Alltrim( cEnt06Cr)
		Endif  

		If lEqual .And. __lEnt07
			lEqual := Alltrim( cEnt07Db ) == Alltrim( cEnt07Cr)
		Endif  

		If lEqual .And. __lEnt08
			lEqual := Alltrim( cEnt08Db ) == Alltrim( cEnt08Cr)
		Endif  

		If lEqual .And. __lEnt09
			lEqual := Alltrim( cEnt09Db ) == Alltrim( cEnt09Cr)
		Endif  

		If lEqual
			If lRpc
				Help(" ",1,"CTAEQUA123")
			Endif
			lRet := .F.
		Endif
		If !lRet .And. lEfetiva
			Aadd(aErro,15)
			lRet := lTodas
		EndIf
	Endif
	// P.E. para validacao das entidades contabeis
	If 	lRet .And. lCT105VLENT
		lRet := ExecBlock("CT105VLENT",.F.,.F.,{cDC,cDebito,cCredito, cContCCD,cContCCC, cItemD,cItemC, cCLVLD,cCLVLC,;
		cEnt05Db,cEnt05Cr,cEnt07Db,cEnt07Cr,cEnt08Db,cEnt08Cr,cEnt09Db,cEnt09Cr})
		
		If !lRet
			Help(" ",1,"CTAEQUA123")
		Endif
	EndIf	
	
	If lRet
		// Valida Debito
		If cDC == "1"
			If !Empty(cDebito) .And. (Empty(cContCCD) .And. !Empty(cContCCC))
				If lRpc
					Help(" ",1,"NOCTADEB")
				EndIf
				lRet  := .F.
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cItemD) .And. !Empty(cItemC))
					If lRpc
						Help(" ",1,"NOCTADEB")
					EndIf
					lRet := .F.					
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cClVlD) .And. !Empty(cClVlC))
					If lRpc
						Help(" ",1,"NOCTADEB")
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt05Db) .And. !Empty(cEnt05Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"05")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "05"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt06Db) .And. !Empty(cEnt06Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"06")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "06"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt07Db) .And. !Empty(cEnt07Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"07")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "07"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt08Db) .And. !Empty(cEnt08Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"08")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "08"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt09Db) .And. !Empty(cEnt09Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"09")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "09"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				cCampo := "CT2_DEBITO"
				If lEfetiva
					Aadd(aErro,16)
					lRet := lTodas
				EndIf
			Endif
		EndIf
		
		// Valida credito
		If cDC == "2" .And. lRet
			If !Empty(cCredito) .And. (Empty(cContCCC) .And. !Empty(cContCCD))
				If lRpc
					Help(" ",1,"NOCTACRD")
				EndIf
				lRet := .F.
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cItemC) .And. !Empty(cItemD))
					If lRpc
						Help(" ",1,"NOCTACRD")
					Endif
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cClVlC) .And. !Empty(cClVlD))
					If lRpc
						Help(" ",1,"NOCTACRD")
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt05Cr) .And. !Empty(cEnt05Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"05")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "05"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt06Cr) .And. !Empty(cEnt06Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"06")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "06"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt07Cr) .And. !Empty(cEnt07Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"07")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "07"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt08Cr) .And. !Empty(cEnt08Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"08")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "08"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt09Cr) .And. !Empty(cEnt09Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If dbSeek(xFilial("CT0")+"09")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "09"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				cCampo := "CT2_CREDIT"
				If lEfetiva
					Aadd(aErro,17)
					lRet := lTodas
				EndIf
			Endif
		EndIf
	EndIf
	
	// validação do tipo de saldo, na rotina CTBA103 o tipo de saldo é fixo pelo parametro
	If lRet .And. !IsInCallStack("CTBA103")	
		If ! VldTpSald( cTpSald )
			Help(" ",1,"NOSALD" , , "Tipo de Saldo inválido" ,3,0 )
			lRet := .F.
		ENDIF
	Endif

	If lRet	
		If lCt105LOK
			lRet  := ExecBlock("CT105LOK",.F.,.F., {OPCAO , dDataLanc} )
         If !lRet .And. lEfetiva
				Aadd(aErro,18)
			EndIf
		Endif		                                                     
	EndIf

	If lEfetiva .And. Len( aErro ) > 0
		lRet := .F.
	EndIf
EndIf
	                       
RestArea(aSaveArea)

Return lRet
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105TOK ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida toda MSGETDB                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT105TOk(lCT105TOK,lCT105CHK,lModified,lDigitacao)   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1    =                                                  ³±±
±±³          ³ExpL2    =                                                  ³±±
±±³          ³ExpL3    = Se alterou                                       ³±±
±±³          ³ExpL4    = Se apresenta mensagem de confirmacao             ³±±
±±³          ³aTotRdpe = Array com os totais de rodape                    ³±±
±±³          ³nTotInf  = Valor informado no total do documento            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT105TOk(lCT105TOK,lCT105CHK,lModified,lConfirma,aTotRdpe,nTotInf,nOpc,cTpSaldo,nValDif,cLancCont)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis.                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSaveArea		:= GetArea()
Local lRet			:= .T.
Local uTot 			:= {}
Local nValDeb		:= 0
Local nValCrd		:= 0
Local nValLimit     := 0
Local aLimitDif     := {}
Local aDebCrd		:= {}
Local nPosTPSLD		:= 1
Local cCtbVldM		:= GetNewPar( "MV_CTBVLDM" , '12222' ) // retorna em quais moedas o sistema efetuará a validação, DEFAULT somente moeda 01.
Local cCtbLimc      := GetNewPar( "MV_CTBLIMC" , '0' )
Local cCtbCenc   	:= GetNewPar( "MV_CTBCENC", '' )
Local nI			:= 0
Local lContBat		:= .T. 
Local lContSb       := .T.
Local lExecMsg      := .T.
Local cQuery  		:=	""
Local cNextAlias	:= GetNextAlias()
Local nOpc192 		:=	1
Local lAtlLcto		:= IIF(GETMV("MV_ALTLCTO") == "S",.T.,.F.)
Local lSeqCorr		:= UsaSeqCor("CT2/CTK/CT5")
Local cSegOfi 		:= GetMv( "MV_SEGOFI" , .F. , "0" )
Local nCont			:= 0
Local aCntCQA		:= {}
Local aDadTmp := {}
Local lAvanca := .F.
Local cTabCTK	:= "CTK"
Local cTabCT2	:= "CT2"
Local lSimula 	:= .F. 
Local nRegAtivo	:= 0
Local lDCDUso
Local aResult	:= {}
Local nX
Local lProcOK := .T.	
Local lCt105Rev	:= ExistBlock("CT105REV")
Local nRecno	:= 0

If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

lDCDUso     	:= __lDCDUso    //  Digito de Controle

DEFAULT lConfirma 	:= .T.
DEFAULT cTpSaldo	:= ""

// carrego os valores para as outras moedas
uTot := CtbTotMov( .T. , cCtbVldM )

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf

If __lConOutR
	ConOutR("*105TOK*|INICIO VALIDACAO")		
EndIf

If Empty(nOpc)
	If Type("OPCAO") <> "U" .and. ValType(OPCAO) == "N"
		DEFAULT nOpc		:= OPCAO
	Else
		DEFAULT nOpc		:= 3		
	EnDiF
EndIf

If nOpc <> 5				///Se exclusão não entra
	If ValType(uTot) = "L"
		lRet := uTot
	Else
		nValDeb := uTot[1][2]
		nValCrd := uTot[1][3]
	Endif
	
	If lRet
		If Empty(cSubLote)
			Help(" ",1,"CT5LOTE1",,STR0018,1,0)//"O Sublote nao pode ficar em branco. Favor preenche-lo."
			lRet	:= .F.
		EndIf
	Endif
	//Validacion para Colombia
	If lRet .and. cPaisLoc=='COL' 
		TMP->(DBGoTop())
		While !TMP->(Eof())
			If !TMP->CT2_FLAG
				lRet := CT102LOK()
				nRecno := TMP->R_E_C_N_O
				If !lRet
					Exit
				EndIf
			EndIf
			TMP->(DBSkip())
		EndDo
		TMP->(DBGoTo(nRecno))
	EndIf
EndIf

If !CtbValiDt(nOpc,dDataLanc,,cTpSaldo)
	lRet	:= .F.
EndIf

If nOpc == 5			///Se for exclusão
	If lRet .And. lSeqCorr .And. cSegOfi == '5'
		Help(" ",1,"CORRNOEXC")
		lRet := .F.
	EndIf  
	If lRet .And. !CtbVldLP(dDataLanc,cLote,cSubLote,cDoc,nOpc,Nil,lSimula,cTabCTK,cTabCT2) .or. !CtbTmpBloq(dDataLanc,cLote,cSubLote,cDoc,nOpc,Nil,lSimula,cTabCTK,cTabCT2) .or. !Ctb102Alert()
		lRet := .F.
	EndIf
EnDif

If lCt105Rev	
	lRet := ExecBlock("CT105REV",.f.,.f.,{dDataLanc,cLote,cSubLote,cDoc })
EndIf

If lRet .And. (nOpc == 4 .OR. nOpc == 5) .And. IsCtbJob()
	cQuery := " SELECT Count(*) CONTA " 
	cQuery += "  FROM " + RetSqlName( "CQA" ) + " CQA "
	cQuery += " WHERE CQA.CQA_FILIAL = '" + xFilial( "CQA" )  + "' "
	cQuery += "   AND CQA.CQA_FILCT2 = '" + xFilial( "CT2" )  + "' "
	cQuery += "   AND CQA.CQA_DATA   = '" + DtoS( dDataLanc ) + "' "
	cQuery += "   AND CQA.CQA_LOTE   = '" + cLote             + "' "
	cQuery += "   AND CQA.CQA_SBLOTE = '" + cSubLote          + "' "
	cQuery += "   AND CQA.CQA_DOC    = '" + cDoc              + "' "
	cQuery += "   AND CQA.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.F.)
	lRet	:=	 (CONTA == 0)
	dbCloseArea()                 
	If !lRet					
		If lConfirma
			Help(" ",1,"DOCNAOATU",,"Documento aguardando" + CRLF + "processamento de sal-" + CRLF + "dos (Fila de saldos)." + CRLF + "Aguarde!",1,0)	
			Return .F.			
		Endif	
	Endif
Endif

If lRet	                                                                       
	If CtbVerTmpBD()
		//com procedure de validacao quando tmp eh criado no banco de dados
		//executa a procedure para validacao de todo arquivo TMP
		aResult	:= {}
		If lRet
			aResult := TCSPExec( xProcedures(__cProcPai), DTOS(dDataLanc), cFilAnt )
			If Empty(aResult) .Or. aResult[1] = "0"
				MsgAlert("Erro na Execucao da Procedure [Validacao Linha OK] : "+__cProcPai+tcsqlerror(),"Erro")
				lProcOK := .F.	
			EndIf
		EndIf
		
		If lProcOk .And. lRet		
			dbSelectArea( "TMP" )
			nRecTMP := TMP->(Recno())
			
			aDadTmp := {}
			lAvanca := .F.
		    //adiciona em aerro para validar
			dbGoTop()
			While TMP->(!Eof())
				
				For nX := 1 TO 25
					If !Empty(&("TMP->CT2_VLD"+StrZero(nX,2)))
						aAdd(aErro, Val( &("TMP->CT2_VLD"+StrZero(nX,2)) ) )
					EndIf
				Next
				If !TMP->CT2_FLAG 
					nRegAtivo++
				EndIf
				TMP->(dbSkip())
			EndDo
			
		    If Len( aErro ) > 0
		    	lRet	:= .F.
		    EndIf
			
		EndIf
	
	EndIf
	//modo normal sem procedure( lRet .And. ! CtbVerTmpBD() )  ou
	If ( lRet .And. ! CtbVerTmpBD() ) .OR. ( CtbVerTmpBD() .And. !lProcOK)  //se eh validacao por procedure e nao consegui executar
		dbSelectArea( "TMP" )
		nRecTMP := TMP->(Recno())
		
		aDadTmp := {}
		lAvanca := .F.
		
		//Verifica na cópia entre filiais se o historico existe
		If FwIsInCallStack("Ctba102Cop") .And. !ValidaHist(TMP->CT2_HP)
			lRet := .F.
		EndIf
		
		dbGoTop()
		While TMP->(!Eof())
			If !CT105LINOK(,,,,nOpc)	// Valida a Linha do Lan‡amento 
				lRet	:= .F.
				Exit
			Endif
			If !TMP->CT2_FLAG 
				nRegAtivo++
			EndIf		
			TMP->(dbSkip())
		EndDo
	EndIf
	
	If lSeqCorr .And. nRegAtivo > 0 
		If !CTBVlSeqCr(dDataLanc,.F.)
			lRet	:= .F.
		EndIf
	EndIf
	
	dbSelectArea("TMP")
	dbGoto(nRecTMP)
EndIf

If nOpc <> 5				///Se exclusão não entra
	If lRet
		// efetuo a validação para as moedas
		FOR nI := 1 To Len( uTot ) 
			nValDeb := uTot[nI][2]
			nValCrd := uTot[nI][3]
			
			// não efetua a validação para valores zerados
			If nValDeb == 0 .And. nValCrd == 0
				LOOP
			Endif

			IF NoRound(Round(nValDeb,3)) != NoRound(Round(nValCrd,3))

				If lCT105TOK

					lRet := ExecBlock("CT105TOK",.f.,.f.,{nValDeb,nValCrd,;
															aTotRdpe[1][1],;
																nTotInf })
				Else
				
					If aMvs[MV_CONTSB] = Nil
						lContSb 	:= IIF(GetMv("MV_CONTSB") == "N",.T.,.F.)
						lContBat 	:= IIF(GetMv("MV_CONTBAT") == "S",.T.,.F.)
					Endif

					If lContSb .And. lRet
						If lContBat		// So grava quando DOC batido
							aLimitDif := QuebraParam(cCtbLimc,";")
		
							If Len( aLimitDif ) >= nI
								nValLimit := Val(aLimitDif[nI])
							Else
								nValLimit := 0
							EndIf
		
							//Se o paramentro MV_CTBLIMC (nValLimit) for maior que zero não efetua a validação do parâmetro MV_CONTBAT
					 		If nValLimit > 0
				
				 				If !Empty(cCtbCenc)
									aCtbCenc := QuebraParam(cCtbCenc)
									lRet := CtbBenc(aCtbCenc)
								Else
									Help( " ", 1, "MV_CTBENC" )//"Favor informar o parâmetro MV_CTBCENC com as entidades contábeis!"
									lRet := .F.
								EndIf
								
								If lRet
									//Se a diferença for maior que o nValLimit não permitir o lançamento
									If ABS(NoRound(Round(nValCrd,3))- NoRound(Round(nValDeb,3))) > nValLimit
										Help(" ",1,"DIFLIMITE")//Diferença de Crédito e Débito é maior que o valor permitido no pârametro MV_CTBLIMC.
								 		lRet := .F.
								 	Else
								 		lExecMsg := .F.
								 		If nValDeb > nValCrd
											cLancCont  := "C"
								 		Else
											cLancCont  := "D"
								 		EndIf
										nValDif := ABS(NoRound(Round(nValDeb,3)) - NoRound(Round(nValCrd,3)))
								 	EndIf
								 EndIf
							 Else
 								If lConfirma
									Help(" ",1,"DOCNOBAT")
								Endif
								lRet := .F.
							EndIf

						Else
							If lConfirma
								lRet := MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011))   //"D‚bito e Cr‚dito n„o conferem !, Aceita Lan‡amento "###"Aten‡„o"
							Else
								//Se for execAuto da mensagem única, retorna .T.  
								If IsIncallStack("CTBI102")
									lRet := .T.
								Else
									lRet := .F.
								Endif	
							Endif
						Endif
					EndIf
				
				EndIf
			
				If lRet .And. aMvs[MV_PRELAN] = "D"
					__PreLan := .T.		// Caso MV_PRELAN estiver indicado para
				EndIf					// Documentos inconsistentes

				If ! lRet
					Exit
				EndIf
			    
			EndIf
		NEXT
	EndIf
	
	If lRet .and. GetNewPar("MV_CONTSLD","S") == "S"
		dbSelectArea("TMP")
		nRecTMP := TMP->(Recno())
		dbGoTop()
		While TMP->(!Eof())
			If !TMP->CT2_FLAG .and. TMP->CT2_DC <> "4"	/// SE NÃO ESTIVER DELETADO E NAO FOR HIST.
				If TMP->CT2_DC$"13"
					nVLRDEB	:= TMP->CT2_VALOR
				Else
					nVLRDEB	:= 0				
				Endif
				If TMP->CT2_DC$"23"
					nVLRCRD	:= TMP->CT2_VALOR
				Else
					nVLRCRD	:= 0
				Endif

				nPosTPSLD := Ascan(aDebCrd,{|x| x[1] == TMP->CT2_TPSALD})

				If nPosTpSLD > 0
					aDebCrd[nPosTpSLD][2] := aDebCrd[nPosTpSLD][2] + nVLRDEB
					aDebCrd[nPosTpSLD][3] := aDebCrd[nPosTpSLD][3] + nVLRCRD
				Else
					aAdd(aDebCrd,{TMP->CT2_TPSALD,nVLRDEB,nVLRCRD})
				Endif
			Endif
			TMP->(dbSkip())
		EndDo
		TMP->(MsGoTo(nRecTMP))
		For nPosTPSLD := 1 to Len(aDebCrd)
			If NoRound(Round(aDebCrd[nPosTPSLD,2],3)) != NoRound(Round(aDebCrd[nPosTPSLD,3],3))  .And. lExecMsg		
				lRet := .F.
			Endif						
		Next
		If !lRet
			If aMvs[MV_CONTSB] = Nil
				lContSb 	:= IIF(GetMv("MV_CONTSB") == "N",.T.,.F.)
				lContBat 	:= IIF(GetMv("MV_CONTBAT") == "S",.T.,.F.)
			Endif
			If lContSb
				If lContBat		// So grava quando DOC batido
					If lConfirma
						Help(" ",1,"DOCNOBAT")
					Endif
					lRet := .F.
				Else   
					If !lCT105TOK
						If lConfirma
							lRet := MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011))   //"D‚bito e Cr‚dito n„o conferem !, Aceita Lan‡amento "###"Aten‡„o"
						Else
							//Se for execAuto da mensagem única, retorna .T.  
							If IsIncallStack("CTBI102")
								lRet := .T.
							Else
								lRet := .F.
							Endif	
						Endif
					Endif
					If lRet .And. aMvs[MV_PRELAN] = "D"
						__PreLan := .T.	// Caso MV_PRELAN estiver indicado para
					Endif					// Documentos inconsistentes
				EndIf
			Else
				lRet := .T.
			EndIf
		EndIf
	Endif

	If lRet
		If lCT105CHK
			lRet := ExecBlock("CT105CHK",.F.,.F.,{lModified})
		EndIf
	EndIf
	
	If lRet
		If lCt105OutM		
			lRet := ExecBlock("CTB105OUTM",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc})		
		EndIf
	EndIf
	
	//ultima validacao customizada por usuario
	IF lCt105Pos
		lRet := ExecBlock("CT105POS",.f.,.f.,{lRet})
	Endif

	If FunName() $ "CTBA102#CTBA103#CTBA104" // No caso de lancamento manual, DEVE sempre manipular a getdados
		lAtlLcto := .T.
	EndIf	            
	
	If ! lRet .And. ! lAtlLcto		// Caso lancamento invalido mas nao poder
		__PreLan := .T.				// alterar, retorno verdadeiro para gravar
		Return .T.					// como pre-lancamento
	Endif									
EndIf

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBTotMov ³ Autor ³ Simone Mie Sato       ³ Data ³ 06.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma o valor do temporario de digitacao (Baseado no CTK)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbTotMov()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aTotMov                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBTotMov(lTudoOk,cMoedas)

Local aSaveArea	:= GetArea()
Local aTotMov 	:= {}
Local lPartDob 	:= .T.
Local nRecTmp	:= 0
Local aMoedas	:= {}
Local cMoedAux	:= ''
Local nValCt2 	:= 0
Local nI		:= 0

DEFAULT lTudoOk := .F.
DEFAULT cMoedas := nil

If aMvs[MV_SOMA] = Nil	 //Determina se o lancam. tipo 3 ira ser somado 1 ou 2 vezes
	aMvs[MV_SOMA] := GetMv("MV_SOMA")
Endif

If cMoedas == Nil
	aMoedas := {{'01' , .T.}}

	// adiciono uma linha o aTotMov
	Aadd( aTotMov , {0,0,0} )
Else
	cMoedAux := Alltrim( cMoedas )

	FOR nI := 1 TO Len( cMoedAux )
		aAdd( aMoedas , { StrZero(nI,2) , iif( Substr( cMoedAux ,1,1 ) == '1' , .T. , .F. ) } )

		cMoedAux := Substr( cMoedAux ,2 )

		// adiciono uma linha o aTotMov
		Aadd( aTotMov , {0,0,0} )
	NEXT

Endif

dbSelectArea("TMP")
nRecTmp	:= Recno()	
DbGoTop()
While ! Eof()
	If CT2_FLAG		// Nao le lancamentos deletados
		DbSkip()
		Loop
	Endif

	FOR nI := 1 To Len( aMoedas )
		
		IF aMoedas[nI][2] == .T. // moedas que irão entrar na validação
			If aMoedas[nI][1] == '01'
				nValCt2 := CT2_VALOR
			Else
				nValCt2 := &("CT2_VALR" + aMoedas[nI][1] )
			Endif
		Else
			nValCt2 := 0
		Endif

		IF nValCt2 <> 0
			// verificação de debito e credito
			If CT2_DC == '3' .OR. CT2_DC == '1'
				aTotMov[nI][2] += nValCt2		 		// Valor a Debito
			Endif
			If CT2_DC == '3' .OR. CT2_DC == '2'
				aTotMov[nI][3] += nValCt2				// Valor a Credito
			Endif
	
			//Se o tipo do lancamento e 3, verifica o parametro MV_SOMA:caso seja 1, soma 1 vez
			//Se for igual a 2, soma 2 vezes no valor digitado.
			If CT2_DC == '3'
				lPartDob := .T.
			Endif

			If lPartDob
				If aMvs[MV_SOMA] == 1
					aTotMov[nI][1]+= nValCt2
				Elseif aMvs[MV_SOMA] == 2
					aTotMov[nI][1]+= (nValCt2 * 2)
				EndIf
			Else
				aTotMov[nI][1]+= nValCt2
			Endif
		Endif	                                              	
	Next

	dbSkip()
EndDo

dbSelectArea("TMP")
dbGoto(nRecTmp)	
RestArea(aSaveArea)

Return aTotMov

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CT105ATRDP³ Autor ³ Simone Mie Sato       ³ Data ³ 28.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao do Rodape, quando altera lote, data ou doc.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,aTotais,aTotRdPe)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = data do lancamento                                 ³±±
±±³          ³ ExpC1 = Lote                                               ³±±
±±³          ³ ExpC2 = SubLote                                            ³±±
±±³          ³ ExpC3 = Documento                                          ³±±
±±³          ³ ExpA1 = Array com os totais                                ³±±
±±³          ³ ExpA2 = Array com os totais do rodape                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,aTotais,aTotRdPe)

Local aSaveArea := GetArea()
Local lRet 		:= .T.

aTotais         := Ctb050Tot(dDataLanc,cLote,cSubLote,cDoc)
aTotRdPe[2]		:= CTBTotMov()[1]

aTotRdPe[1][2] := aTotRdPe[2][2]
aTotRdPe[1][3] := aTotRdPe[2][3]
aTotRdPe[1][1] := aTotRdPe[2][1]

//Atualiza o rodape (refresh)
ctb050ImpT()

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Rpc ³ Autor ³ Simone Mie Sato       ³ Data ³ 22.08.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida toda MSGETDB                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB105RPC(lCT105TOK,lCT105CHK,lModified,lDigitacao)   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1    =                                                  ³±±
±±³          ³ExpL2    =                                                  ³±±
±±³          ³ExpL3    = Se alterou                                       ³±±
±±³          ³ExpL4    = Se apresenta mensagem de confirmacao             ³±±
±±³          ³aTotRdpe = Array com os totais de rodape                    ³±±
±±³          ³nTotInf  = Valor informado no total do documento            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105Rpc(lDigita)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis.                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSaveArea		:= GetArea()
Local lRet			:= .T.
Local lCusto		:= CtbMovSaldo("CTT")
Local lItem 		:= CtbMovSaldo("CTD")
Local lClVl 		:= CtbMovSaldo("CTH")
Local lHelp			:= lDigita	
	
//Verificar se as contas existem
dbSelectArea("TMP")
dbGotop()	

While TMP->(!Eof())
	If TMP->CT2_FLAG		// Nao le lancamentos deletados
		TMP->(DbSkip())
		Loop
	Endif
		
	If TMP->CT2_DC $ "13"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CONTA CONTABIL A DEBITO                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta foi preenchida                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( TMP->CT2_DEBITO )
			lRet := .F.
		Endif           
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta existe e nao e sintetica                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			lRet:= ValidaConta(TMP->CT2_DEBITO,"1",,,.T.,.F.,lHelp)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CENTRO DE CUSTO - DEBITO                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			If lCusto
				lRet:= ValidaCusto(TMP->CT2_CCD,"1",,,.T.,.F.,lHelp)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ITEM - DEBITO 		                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			If lItem
				lRet:= ValidItem(TMP->CT2_ITEMD,"1",,,.T.,.F.,lHelp)
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CLASSE VALOR - DEBITO 		                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			If lCLVL
				lRet:= ValidaCLVL(TMP->CT2_CLVLDB,"1",,,.T.,.F.,lHelp)
			EndIf
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bloco de Valida‡oes Lancamentos a Credito                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If TMP->CT2_DC $ "23"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CONTA CONTABIL A CREDITO                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta foi preenchida                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( TMP->CT2_CREDIT )
				lRet := .F.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta existe e nao e sintetica                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet := ValidaConta(TMP->CT2_CREDIT,"2",,,.T.,.F.,lHelp)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CENTRO DE CUSTO - CREDITO                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If lCusto
					lRet:= ValidaCusto(TMP->CT2_CCC,"2",,,.T.,.F.,lHelp)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ITEM - CREDITO		                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If lItem
					lRet:= ValidItem(TMP->CT2_ITEMC,"2",,,.T.,.F.,lHelp)
				EndIf
			EndIf                    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CLASSE VALOR - CREDITO		                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If lCLVL
					lRet:= ValidaCLVL(TMP->CT2_CLVLCR,"2",,,.T.,.F.,lHelp)
				EndIf
			EndIf
	
		EndIf	
	EndIf
	If !lRet 
		__PreLan := .T.						
		Return .F.							
	Endif												
	TMP->(dbSkip())
EndDo
	
	
RestArea(aSaveArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT105SDEL ºAutor  ³Marcos S. Lobo      º Data ³  04/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a deleção de todas as linhas da tela de lancamentos º±±
±±º          ³contabeis (lancamento automatico).                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT105SDEL(nOpc)
Local lRet := .F.

If ValType(nOpc) <> "N" .or. nOpc == 2
	Return(lRet)
Endif

If MsgYesNo(STR0017)///"Deseja realmente deletar todas as linhas ?"
	dbSelectArea("TMP")
	dbGoTop()
	While !Eof()
		CT102DEL(nOpc, .F.)
		TMP->CT2_FLAG := .T.
		TMP->(dbSkip())
	EndDo
	dbSelectArea("TMP")
	dbGoTop()
	lRet := .T.
Endif
	
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Flt ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca inconsistencias na GetDB e posiciona cursor          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105Flt(oGetDb,lAvan)

Local nColPos 	:= oGetDb:oBrowse:nColPos
Local nRowPos	:= oGetDb:oBrowse:nAt
Local nMaxPos	:= oGetDb:oBrowse:nLen   
Local cCampo 	:=	""                                       
Local nLimite	:= 0
Local nSkip		:= 0
Local cMsg		:= ""
Local nLinBrowse := 1

Default lAvan	:= .T.

nSkip	:= If(lAvan,1      ,-1)
nLimite := If(lAvan,nMaxPos, 1)

While ( lOk := CT105LINOK(@cCampo) )
	nLinBrowse:= oGetDb:oBrowse:nAt
	If ( oGetDb:oBrowse:nAt == nLimite )
		Exit
	Endif
	oGetDb:oBrowse:SKIP( nSkip )
	If oGetDb:oBrowse:nAt == nLinBrowse
		oGetDb:oBrowse:nAt := nLinBrowse+nSkip
	EndIf 
	//oGetDb:oBrowse:Refresh()
Enddo
oGetDb:oBrowse:Refresh()
If lOk
	oGetDb:GoTo(nRowPos)	
	cMsg := STR0022 + If( lAvan, STR0023, STR0024 ) //"Nenhuma inconsistencia "###"abaixo"###"acima"
	MsgInfo( cMsg )
Else
	nColPos	:=	Ascan(aHeader,{|x| alltrim(x[2])==cCampo})
	If nColPos > 0
		oGetDb:oBrowse:nColPos := nColPos
	Endif
Endif
oGetDb:oBrowse:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105FtBs³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro generico para posicionar o cursor no registro exato ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105FtBs(oGetDb,cFiltro,cTexto)

Local nColPos 	 := oGetDb:oBrowse:nColPos
Local nColPosOri := nColPos
Local nRowPos	 := oGetDb:oBrowse:nAt
Local nMaxPos	 := oGetDb:oBrowse:nLen   
Local cMsg		 := ""
Local cCampo 	 :=	""                                       
Local lFind		 := .F.
Local nOpc		 :=	1
Local aOpcoes	 :=	{STR0025,STR0026,STR0027,STR0028} //"Nova"###"Anterior"###"Proxima"###"Cancela"
Local nSkip		 := 0
Local nLimite	 := 0
					 
dbSelectArea("TMP")
If !Empty(cFiltro)
	nOpc	:=	Aviso('Pesquisa',cTexto,aOpcoes)
Endif
If nOpc <> 4
	If Empty(cFiltro).Or. nOpc == 1
		aFiltro := CTB105FlTl("TMP",@cFiltro,@cTexto)
		cFiltro	:=	aFiltro[1]
		cTexto	:=	aFiltro[2]
		nOpc	:=	aFiltro[3]
	Endif
	If nOpc == 2
		nSkip	:=	-1
		nLimite	:=	1
	ElseIf nOpc == 3
		nSkip	:=	1
		nLimite	:=	nMaxPos
	Else
		Return
	Endif		
	
	If !Empty( cFiltro )
		oGetDb:oBrowse:SKIP(nSkip)
		While  !(lFind := &cFiltro)
			If oGetDb:oBrowse:nAt==nLimite
				Exit
			Endif	
			oGetDb:oBrowse:SKIP(nSkip)               
			oGetDb:oBrowse:Refresh()
		Enddo
	
		If !lFind    
			cMsg := STR0029 //"Nenhum lancamento encontrado "
			If nOpc == 2
				cMsg += STR0024 //"acima" 
			ElseIf nOpc == 3
				cMsg += STR0023 //"abaixo"
			Endif
			MsgInfo( cMsg ) 
			oGetDb:GoTo(nRowPos)
			oGetDb:oBrowse:nColPos := nColPosOri
		Else
			nColPos	:=	Ascan(aHeader,{|x| alltrim(x[2])==Alltrim(Left(cFiltro,10))})
			If nColPos > 0
				oGetDb:oBrowse:nColPos := nColPos
			Endif
		Endif
		oGetDb:oBrowse:Refresh()
	Endif
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105FlTl³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro parecido com BuildExpr()							  ³±±
±±³          ³ Criado pela necessidade de se trabalhar com o Arq. TMP     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105 e CTBA102                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB105FlTl(cAl,cExpFil,cTxtFil)

Local oDlgPesq
Local oBtna , oBtn  , oBtnOp, oBtne, oBtnOu
Local oMatch, oCampo, oOper , oExpr, oTxtFil
Local aCpos		:= {}
Local aCampo	:= {}
Local aStrOp	:= {}
Local aStru		:= {}
Local cTitulo	:= ""
Local cCampo	:= ""
Local cExpr		:= ""
Local cOper		:= ""
Local nMatch 	:= 0
Local nA		:= 0
Local nOpc		:= 4

Private cAlias2	:= ""
Private cAlias	:= ""

Default cTxtFil := ""
Default cExpFil := ""
Default cAl		:= "TMP"
		cAlias	:= cAl
		cAlias2 := cAlias + "->"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos do Localizador ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nA := 1 to Len(aHeader)
	AADD( aCpos , aHeader[nA][1] )
	AADD( aCampo,{aHeader[nA][2],aHeader[nA][1],.T.,"01",aHeader[nA][4],If(Empty(aHeader[nA][3]),Space(45),aHeader[nA][3]),aHeader[nA][8],aHeader[nA][5]})
Next nA

cTitulo := STR0021 //"Localizar"

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(cTitulo) FROM 000,000 TO 250,405 PIXEL

	aStrOp := { OemToAnsi(STR0030),OemToAnsi(STR0031),OemToAnsi(STR0032),OemToAnsi(STR0033),OemToAnsi(STR0034),OemToAnsi(STR0035),OemToAnsi(STR0036),OemToANsi(STR0037),OemToANsi(STR0038),OemToAnsi(STR0039)}	 
	//"Igual a"###"Diferente de"###"Menor que"###"Menor ou igual a"###"Maior que"###"Maior ou igual a"###"Cont‚m a express„o"###"N„o cont‚m"###"Est  contido em"###"N„o est  contido em"

	@ 05,005 SAY OemToAnsi(STR0040) SIZE 20,8 PIXEL OF oDlgPesq //"Campo:"
	@ 05,060 SAY OemToAnsi(STR0041) SIZE 30,8 PIXEL OF oDlgPesq //"Operador:"
	@ 05,115 SAY OemToAnsi(STR0042) SIZE 30,8 PIXEL OF oDlgPesq //"Express„o:"
	@ 50,005 SAY OemToAnsi(STR0043) SIZE 20,8 PIXEL OF oDlgPesq //"Filtro:"
	
	@ 35,005 BUTTON oBtna PROMPT OemToAnsi(STR0044) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Adiciona"
		ACTION (cTxtFil := BuildTxt(cTxtFil,Trim(cCampo),cOper,cExpr,.t.,@cExpFil,aCampo,oCampo:nAt,oOper:nAt),cExpr := CalcField(oCampo:nAt,aCampo),BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq),oTxtFil:Refresh(),oBtne:Enable(),oBtnOp:Disable(),oBtnOu:Enable(),oBtna:Disable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh()) ;
		FONT oDlgPesq:oFont
	
	@ 35,45 BUTTON oBtn PROMPT OemToAnsi(STR0045) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Limpa Filtro"
		ACTION (cTxtFil := "",cExpFil := "",nMatch := 0,oTxtFil:Refresh(),oBtnA:Enable(),oBtnE:Disable(),oBtnOu:Disable(),oMatch:Disable(),oBtnOp:Enable()) ;
		FONT oDlgPesq:oFont
	
	@ 30,175 BUTTON oBtnOp PROMPT OemToAnsi("(") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont ;
		ACTION (If(nMatch==0,oMatch:Enable(),nil),nMatch++,cTxtFil+= " ( ",cExpFil+="(",oTxtFil:Refresh()) ;
	
	@ 30,190 BUTTON oMatch PROMPT OemToAnsi(")") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont;
		ACTION (nMatch--,cTxtFil+= " ) ",cExpFil+=")",If(nMatch==0,oMatch:Disable(),nil),oTxtFil:Refresh()) ;
	
	@ 45,175 BUTTON oBtne PROMPT OemToAnsi(STR0046) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" E "
		ACTION (cTxtFil+=STR0046,cExpFil += ".and.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) ; //" e "
	
	@ 45,190 BUTTON oBtnOu PROMPT OemToAnsi(STR0047) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" OU "
		ACTION (cTxtFil+=STR0047,cExpFil += ".or.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) //" ou "
	oMatch:Disable()
	
	cCampo := aCpos[1]
	@ 15,05 COMBOBOX oCampo VAR cCampo ITEMS aCpos SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	cExpr := CalcField(oCampo:nAt,aCampo)
	cOper := aStrOp[1]
	
	@ 15,60 COMBOBOX oOper VAR cOper ITEMS aStrOp SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	
`	@ 15,115 MSGET oExpr VAR cExpr SIZE 85,10 PIXEL OF oDlgPesq PICTURE AllTrim(aCampo[oCampo:nAt,6]) FONT oDlgPesq:oFont
	
	@ 60,05 GET oTxtFil VAR cTxtFil MEMO SIZE 195,40 PIXEL OF oDlgPesq READONLY
	oTxtFil:bRClicked := {||AlwaysTrue()}
	
	If Empty(cExpFil) .And. Empty(cTxtFil)
		oBtne:Disable()
		oBtnou:Disable() 
	Else
		oBtna:Disable()
		oBtnOp:Disable()
		oMatch:Disable()
	Endif
	
	DEFINE SBUTTON o1 FROM 113,115  TYPE 20  ACTION (nOpc:=2,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o2 FROM 113,145  TYPE 19  ACTION (nOpc:=3,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o3 FROM 113,175  TYPE 02  ACTION (nOpc:=4                              ,oDlgPesq:End()) OF oDlgPesq When .T.
	
	o1:cToolTip := STR0048 //"Localizar Anterior"
	o2:cToolTip := STR0049 //"Localizar Proximo"

ACTIVATE MSDIALOG oDlgPesq CENTERED

Return {cExpFil,cTxtFil,nOpc }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³BuildTxt  ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BuildTxt(cTxtFil,cCampo,cOper,xExpr,lAnd,cExpFil,aCampo,nCpo,nOper)
Local cChar := OemToAnsi(CHR(39))
Local cType := ValType(xExpr)
Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}

cTxtFil += cCampo+" "+cOper+" "+If(cType=="C",cChar,"")+cValToChar(xExpr)+If(cType=="C",cChar,"")

If cType == "C"
	If  aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ '+aCampo[nCpo,1]+')'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!('+aCampo[nCpo,1]+" $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ "+aCampo[nCpo,1] +" "   // Inverte Posicoes
	Else
		If (aOper[nOper]=="==")
			cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
			cExpFil += '"'+cValToChar(xExpr)+'"'
		Else
			cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
			cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
		EndIf
	EndIf
ElseIf cType == "D"
	// Nao Mexer, deixar dToS pois e'a FLAG Para Limpeza do Filtro
	// 						 
	cExpFil += "dToS("+aCampo[nCpo,1]+") "+aOper[nOper]+' "'
	cExpFil += Dtos(CTOD(cValToChar(xExpr)))+'"'
Else
	cExpFil += aCampo[nCpo,1]+" "+aOper[nOper]+" "
	cExpFil += cValToChar(xExpr)
EndIf

Return cTxtFil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CalcField ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcField(nAt,aCampo)

Local cRet

If aCampo[nAt,7] == "C"
	cRet := Space(aCampo[nAt,5])
ElseIf aCampo[nAt,7] == "N"
	cRet := 0
ElseIf aCampo[nAt,7] == "D"
	cRet := CTOD("  /  /  ")
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidText ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta experessao de busca para que nao gere error.log     ³±±
±±³          ³ de Invalid Macro por inconsistencia.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidText(cExp,cTxt)

Local lValid := .F.	

Default cExp := ""
Default cTxt := ""

If !Empty(cExp) .And. !Empty(cTxt)
	While !lValid
		Do Case
			Case Right(cTxt,2) == "( "  
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,2) == "E "
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,3) == "OU "
				cTxt := Left( cTxt, Len(cTxt)-4 )
			Case Right(cExp,1) == "("
				cExp := Left( cExp, Len(cExp)-1 )
			Case Right(cExp,5) == ".and."	
				cExp := Left( cExp, Len(cExp)-5 )
			Case Right(cExp,4) == ".or."	
				cExp := Left( cExp, Len(cExp)-4 )
			Otherwise
				lValid := .T.
		End Case
	EndDo
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMudouL ºAutor  ³Marcos S. Lobo      º Data ³  10/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se houve alteracao nas caracteristicas do lancto.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Validacoes CTBA101, CTBA102, CTBA105 e CTBA350       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbMudouL(aNewCont,aOldCont,nRecOld)

/// SE HOUVEREM VARIAS MOEDAS CHAMAR UMA VEZ PARA CADA MOEDA (nRecOld muda)

Local aAreaOri		:= GetArea()
Local aAreaCT2		:= CT2->(GetArea())

Local aMudou		:= {}		///Retorno: Array com os campos alterados (se houver)

Local nField		:= 1
Local nCoin			:= 2

DEFAULT aNewCont	:= {}		///Conteudos Novos/Alterados
DEFAULT aOldCont	:= {}		///Conteudos Antigos/Originais
DEFAULT nRecOld		:= 0		///Numero do Registro Original no CT2 (presume-se TMP posicionado)

aCampos := {"CT2_DC",;
			"CT2_DEBITO","CT2_CREDIT",;
			"CT2_CCD","CT2_CCC",;
			"CT2_ITEMD","CT2_ITEMC",;
			"CT2_CLVLDB","CT2_CLVLCR",;
			"CT2_TPSALD"}		

/// TENTA OBTER CONTEUDOS NOVOS PELO TMP POSICIONADO.
If Len(aNewCont) <= 0
	If Select("TMP") > 0	
		For nField := 1 to Len(aCampos)
			aAdd( aNewCont, &("TMP->"+aCampos[nField]) )			
		Next	
	EndIf
EndIf

/// TENTA OBTER CONTEUDOS ANTIGOS PELO CT2 POSICIONADO.
If Len(aOldCont) <= 0			/// SE NAO VIEREM POR PARAMETRO DA FUNCAO
	If nRecOld > 0				/// VERIFICA SE PASSOU O RECNO() DO CT2 DE ORIGEM/ANTIGO
		CT2->(MsGoTo(nRecOld))
		If CT2->(Recno()) == nRecOld
			For nField := 1 to Len(aCampos)
				aAdd( aOldCont, &("CT2->"+aCampos[nField]) )
			Next
		EndIf
	ElseIf CT2->(!Eof())		/// SE NAO PASSOU ASSUME CT2 POSICIONADO.
		For nField := 1 to Len(aCampos)
			aAdd( aOldCont, &("CT2->"+aCampos[nField]) )
		Next	
	EndIf
EndIf
    
/// VERIFICA SE EXISTEM DIFERENÇAS ENTRE OS CONTEUDOS NOVOS E OS ANTIGOS
For nField := 1 to Len(aCampos)
	If Len(aNewCont) < nField .or. Len(aOldCont) < nField
		Exit
	EndIf

	///VERIFICA SE HOUVE MUDANCA
	If ValType(aNewCont[nField]) <> ValType(aOldCont[nField])
		aAdd(aMudou,aCampos[nField])
	Else
		If aNewCont[nField] <> aOldCont[nField]
			aAdd(aMudou,aCampos[nField])
		EndIf
	EndIf
Next

RestArea(aAreaCT2)
RestArea(aAreaOri)

Return aMudou

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina :=	{	{ "aRotina Falso", "AxPesq",		0, 1 },;
						{ "aRotina Falso", "AxVisual",	0, 2 },;
						{ "aRotina Falso", "AxInclui",	0, 3 },;
						{ "aRotina Falso", "AxAltera",	0, 4 }}

Return(aRotina)
                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClearCx105ºAutor  ³Renato F. Campos    º Data ³  09/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa os caches utilizados pela rotina                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ClearCx105()

__aDtMedias := {}
__lConOutR	:= Nil

If ! CtbVerTmpBD() .And. ! __lTmp_Zap
	__aCampos	:= Nil
EndIf

__aAltera	:= Nil

//Zera array estatico com as moedas ja validadas
aMoedaOk	:=	{}
aCTOCTPOk	:=	{}
aPerCache	:=  {}
__aCritPln := {}	

// limpa a ctba101
ClearCx101()
               
// limpa a ctbxvld
ClearCxVld()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA105   ºAutor  ³Microsiga           º Data ³  08/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbLinMax(nMv_NumLin)
Local nRet := 0

If Len(CT2->CT2_LINHA) == 3
	If nMv_NumLin >= 35658  //limite estabelecido em razao do tamanho campo CT2_LINHA  = 3 e utilizar a funcao Soma1() para incremento
		nRet := 35658
	Else
		nRet := nMv_NumLin
	EndIf
Else
	nRet := nMv_NumLin
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_CtbAmarr ºAutor  ³Microsiga           º Data ³  xx/xx/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function _CtbAmarr(lDebito,cConta,cCusto,cItem ,cCLVL,lPosiciona,lHelp,lValidLinOk,aEntidade)
Local xRetorno := .T.

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If nQtdEntid > 4 .And. Type( 'aCtbEntid' ) == 'A' .And. Len( aCtbEntid ) > 0
	xRetorno := CtbAmarr1( lDebito, lHelp ) // novo metodo de verificação da amarração
Else
	If nQtdEntid > 4
		Help(" ",1,"CT5ENT",,STR0061 + " " + STR0062 + " " + STR0063,1,0)//'A rotina utilizada está incompativel com a rotina atual de amarração.'##'O metodo antigo de verificação da amarração foi acionado.'##'Favor verificar a possibilidade de atualizar o ambiente SIGACTB!'
	Endif

	xRetorno := CtbAmarra(cConta,cCusto,cItem ,cCLVL,lPosiciona,lHelp,lValidLinOk) // metodo antigo de verificação da amarração
Endif

Return xRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbAmarr1 ºAutor  ³Microsiga           º Data ³  xx/xx/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbAmarr1(lDebito,lMessage)
Local aEntidades := {}
Local nX
Local abEntid
Local xRetorno	:= .F.

Default lMessage := .T.

IF Type( 'aCtbEntid' ) == 'A' .And. Len( aCtbEntid ) > 0
	//a variavel aCtbEntid eh private declarada nos fontes ctba101 / ctba102 / ctba105
	abEntid := aCtbEntid[ If(lDebito,1,2) ]
	
	For nX := 1 TO Len(abEntid)
		If lDebito   //debito
			aAdd(aEntidades, Eval(abEntid[nX]) )
		Else        //credito
			aAdd(aEntidades, Eval(abEntid[nX]) )
		EndIf
	Next
	
	xRetorno := CtbAmarra(aEntidades[1]/*cConta*/,aEntidades[2]/*cCusto*/,aEntidades[3]/*cItem*/,aEntidades[4]/*cCLVL*/,,lMessage,,aEntidades)
Else
	Help(" ",1,"NOAMARR1",, STR0064 + CRLF + STR0065 + CRLF + STR0066 + CRLF + 'SIGACTB!', 3,0 )  //'A rotina utilizada está'##'incompativel com a rotina atual.'##'Favor atualizar o ambiente'
Endif

Return xRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} CTB_IMPLANC
Função para impressão dos lançamentos contabeis online

@author Pedro Alencar	
@since 02/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function CTB_IMPLANC()
	Local oReport
	Local aMoedas := {}
	Local nOpcAvi := 0
	
	nOpcAvi := Aviso(OemToAnsi(STR0078), OemToAnsi(STR0079), {OemToAnsi(STR0080), OemToAnsi(STR0081)}) //'Selecionar Moedas', 'Deseja selecionar as moedas em que serão apresentados os valores? Caso clique em Não, será exibida apenas a moeda padrão.', 'Sim', 'Não'
	
	If nOpcAvi = 1 
		aMoedas := GetMoedaCT()
	Endif 
	
	oReport := ReportDef(aMoedas)
	oReport:PrintDialog()
Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define a estrutura do relatório de contabilização online

@author Pedro Alencar	
@since 02/01/2014
@version 12
@param aMoedas, Vetor com as moedas contábeis nas quais serão exibidos os valores
@return oReport, Objeto com a estrutura do relatório TReport
/*/
//-------------------------------------------------------------------------------
Static Function ReportDef(aMoedas)
	Local oReport
	Local oSection1
	Local oSection2
	Local nCount := 0		
	Local cField := ""
	Local oBreak 
	Local lValor := .F.
	//Vetores com os campos que serão carregados no relatório, por padrão
	Local aCab := {"CT2_DATA", "CT2_LOTE", "CT2_SBLOTE", "CT2_DOC"}
	Local aLcto := {"CT2_LINHA", "CT2_DC", "CT2_DEBITO", "CT2_CREDIT", "CT2_HIST", "CT2_CCD", "CT2_CCC", "CT2_CLVLDB", "CT2_CLVLCR", "CT2_TPSALD", "CT2_NODIA", "CT2_DIACTB"}
	
	oReport := TReport():New("CTB_IMPLANC", OemToAnsi(STR0082),,{|oReport| PrintReport(oReport,aMoedas)}, OemToAnsi(STR0083), .T.) //'lançamento Contábil', 'Impressão de Contabilização Online'
	
	//Cria as duas sessões do relatório
	oSection1 := TRSection():New(oReport,OemToAnsi(STR0084),"TMP",,.T.,.T.) //'Cabeçalho'
	oSection2 := TRSection():New(oReport,OemToAnsi(STR0085),"TMP",,.T.,.T.) //'Lançamentos'
	
	//Verifica se é pra adicionar o valor de outras moedas na secão 2
	If Len(aMoedas) > 0 
		For nCount := 1 to Len(aMoedas)	
			If aMoedas[nCount] == "01"					
				//Valor na Moeda 1
				aAdd(aLcto, "CT2_VALOR")
			Else				
				aAdd(aLcto, "CT2_VALR" + aMoedas[nCount])
			Endif			
		Next nCount  
	Else
		//Valor na Moeda 1
		aAdd(aLcto, "CT2_VALOR")
	Endif 
	
	//Pega os campos da tabela temporária e cria uma cell para cada um deles
	For nCount := 1 To TMP->(FCOUNT()) 
		//Pega o nome do campo da tabela TMP
		cField := ALLTRIM(TMP->(FIELD(nCount)))				
		
		//Verifica se é campo de valor, para fazer tratamentos em seguida
		If SubStr(cField, 5, 5) == "VALOR" .OR. SubStr(cField, 5, 4) == "VALR"
			lValor := .T.
		Else
			lValor := .F.
		Endif
		
		//Se for campo de valor, divide em dois campos, débito e crédito, para totalizar corretamente 
		If lValor		
			//Adiciona os campos de valor, dividindo em débito e crédito, em ambas as seções
			TRCell():New(oSection1,cField + OemToAnsi(STR0087),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0087),,,.F.,,,.T.) //'(DEB)'
			TRCell():New(oSection1,cField + OemToAnsi(STR0088),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0088),,,.F.,,,.T.) //'(CRED)'
			TRCell():New(oSection2,cField + OemToAnsi(STR0087),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0087),,,.F.,,,.T.) //'(DEB)'
			TRCell():New(oSection2,cField + OemToAnsi(STR0088),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0088),,,.F.,,,.T.) //'(CRED)'
			//Adiciona um totalizador para os campos de valores
			TRFunction():New(oSection2:Cell(cField + OemToAnsi(STR0087)),"Total","SUM",,,,,.F.,.T.,.F.) //'(DEB)'
			TRFunction():New(oSection2:Cell(cField + OemToAnsi(STR0088)),"Total","SUM",,,,,.F.,.T.,.F.) //'(CRED)'
			
			//Verifica se o campo deve aparecer, por padrão, na seção 1. Se não, deixa o campo selecionavel na personalização 
			If aScan(aCab, Upper(cField)) > 0 				
				oSection1:Cell(cField + OemToAnsi(STR0087)):lEnabled := .T. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .T. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lEnabled := .T. //'(CRED)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .T. //'(CRED)'
			Else
				oSection1:Cell(cField + OemToAnsi(STR0087)):lEnabled := .F. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .F. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lEnabled := .F. //'(CRED)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .F. //'(CRED)'
			EndIf
			
			//Verifica se o campo deve aparecer, por padrão, na seção 2. Se não, deixa o campo selecionavel na personalização 
			If aScan(aLcto, Upper(cField)) > 0 
				oSection2:Cell(cField + OemToAnsi(STR0087)):lEnabled := .T. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .T. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lEnabled := .T. //'(CRED)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .T. //'(CRED)'
			Else
				oSection2:Cell(cField + OemToAnsi(STR0087)):lEnabled := .F. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .F. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lEnabled := .F. //'(CRED)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .F. //'(CRED)'
			EndIf	
		Else //Outros campos que não são os valores do lançamento
			//Adiciona o campo em ambas as seções
			TRCell():New(oSection1,cField,"TMP",,,,.F.,,,.T.)
			TRCell():New(oSection2,cField,"TMP",,,,.F.,,,.T.)
			
			//Verifica se o campo deve aparecer, por padrão, na seção 1. Se não, deixa o campo selecionavel na personalização 
			If aScan(aCab, Upper(cField)) > 0 
				oSection1:Cell(cField):lEnabled := .T.
				oSection1:Cell(cField):lUserEnabled := .T.
			Else
				oSection1:Cell(cField):lEnabled := .F.
				oSection1:Cell(cField):lUserEnabled := .F.
			EndIf
			
			//Verifica se o campo deve aparecer, por padrão, na seção 2. Se não, deixa o campo selecionavel na personalização 
			If aScan(aLcto, Upper(cField)) > 0 
				oSection2:Cell(cField):lEnabled := .T.
				oSection2:Cell(cField):lUserEnabled := .T.
			Else
				oSection2:Cell(cField):lEnabled := .F.
				oSection2:Cell(cField):lUserEnabled := .F.
			EndIf	
		Endif

	Next nCount
	
	//Impressão dos totalizadores por coluna
	oReport:SetTotalInLine(.F.)
	
	//Define o ajuste de tamanho automatico nas seções e a quebra de linha caso os campos ultrapassem o limite de tamanho da tela
	oSection1:SetAutoSize(.T.)
	oSection2:SetAutoSize(.T.)
	oSection1:SetLineBreak(.T.)
	oSection2:SetLineBreak(.T.)
Return oReport  

//----------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Define a visualização dos registros do relatório de contabilização online

@author Pedro Alencar	
@since 02/01/2014
@version 12
@param oReport, Objeto com a estrutura do relatório TReport
@param aMoedas, Vetor com as moedas contábeis selecionadas
/*/
//----------------------------------------------------------------------
Static Function PrintReport(oReport, aMoedas)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local aAreaAnt := TMP->(GetArea())
	Local cHistorico := "" 
	Local lImprime := .F. 
	Local lPrimeiro := .T.
	Local nAux := 0
	Local nCount := 0
	
	DbSelectArea("TMP")
	TMP->(DbGoTop())
	
	oSection1:Init()
	//Os campos do cabeçalho da tela de lançamentos são preenchidos com variáveis com os valores já tratados
	//Verifica se essas variáveis existem para pegar os seus valores e colocar no relatório, senão pega da tabela TMP 
	Iif(Type("dDataLanc") == "U", oSection1:Cell("CT2_DATA"):SetValue(TMP->CT2_DATA), oSection1:Cell("CT2_DATA"):SetValue(dDataLanc))
	Iif(Type("cLote") == "U", oSection1:Cell("CT2_LOTE"):SetValue(TMP->CT2_LOTE), oSection1:Cell("CT2_LOTE"):SetValue(cLote))
	Iif(Type("cSubLote") == "U", oSection1:Cell("CT2_SBLOTE"):SetValue(TMP->CT2_SBLOTE), oSection1:Cell("CT2_SBLOTE"):SetValue(cSubLote))
	Iif(Type("cDoc") == "U", oSection1:Cell("CT2_DOC"):SetValue(TMP->CT2_DOC), oSection1:Cell("CT2_DOC"):SetValue(cDoc))
	oSection1:PrintLine()
	oSection1:Finish()
		
	oSection2:Init()
	//Imprime a seção 2 para cada registro contido na tabela TMP, com tratamento do histórico
	While TMP->(!EOF())
		nAux += 1
		
		//Se o registro não estiver apagado
		If TMP->CT2_FLAG = .F.
			//Se for complemento de histórico, não imprime a linha e concatena para imprimir quando acabar o histórico 
			If TMP->CT2_DC == "4"
				lImprime := .F.
				cHistorico += ' ' + AllTrim(TMP->CT2_HIST)			 
			Else
				//Se não for continuação de histórico, verifica se é o primeiro lançamento a ser analisado
				If lPrimeiro = .T.
					cHistorico += ' ' + AllTrim(TMP->CT2_HIST)
					lImprime := .F.
					lPrimeiro = .F.
				Else //Se não é complemento de histórico nem é a primeira linha de lançamento, então já é outro lançamento (o lançamento anterior deve ser impresso agora)
					lPrimeiro := .T.
					lImprime := .T.		
				Endif 
			Endif
			
			//Se for pra imprimir, volta alguns registros na tabela temporária de acordo com a variavél auxiliar de controle de registros (nAux)
			//Volto os registros para que seja possível imprimir a linha correta com todo o histórico aglutinado 
			If lImprime = .T.
				lImprime := .F.
				TMP->(DbSkip(-nAux+1))
				oSection2:Cell("CT2_HIST"):SetValue(cHistorico)
				
				//Se for débito, imprime o valor apenas no campo de débito criado para os campos de valores
				If TMP->CT2_DC == "1"
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(0) //'(CRED)'
					
					If Len(aMoedas) > 0 
						For nCount := 1 to Len(aMoedas)	
							If aMoedas[nCount] != "01"								
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(DEB)'
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(0)	//'(CRED)'		
							Endif			
						Next nCount   
					Endif					
				ElseIf TMP->CT2_DC == "2" //Se for crédito, imprime o valor apenas no campo de crédito criado para os campos de valores
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'
					
					//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
					If Len(aMoedas) > 0 
						For nCount := 1 to Len(aMoedas)	
							If aMoedas[nCount] != "01"								
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(CRED)'	 									
							Endif			
						Next nCount   
					Endif	
				Else //Se for partida dobrada, imprime o valor tanto no campo de débito quanto no de crédito, criados para os campos de valores
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'
					
					//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
					If Len(aMoedas) > 0 
						For nCount := 1 to Len(aMoedas)	
							If aMoedas[nCount] != "01"								
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(DEB)'
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(CRED)'											
							Endif			
						Next nCount   
					Endif	
				Endif
				
				oSection2:PrintLine()
				cHistorico := ""
				TMP->(DbSkip(nAux-2))
				nAux := 0		
			Endif
		Endif
		
		TMP->(DbSkip())
		
		//Se houve uma linha de lançamento (não complemento de histórico) e a tabela já está no final, então imprime a última linha
		If TMP->(EOF()) .AND. lPrimeiro = .F. .AND. TMP->CT2_FLAG = .F.
			TMP->(DbSkip(-nAux))
			oSection2:Cell("CT2_HIST"):SetValue(cHistorico)
			
			//Se for débito, imprime o valor apenas no campo de débito criado para os campos de valores
			If TMP->CT2_DC == "1"
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(0) //'(CRED)'
				
				If Len(aMoedas) > 0 
					For nCount := 1 to Len(aMoedas)	
						If aMoedas[nCount] != "01"								
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(DEB)'
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(0)	//'(CRED)'		 
						Endif			
					Next nCount   
				Endif	
			ElseIf TMP->CT2_DC == "2" //Se for crédito, imprime o valor apenas no campo de crédito criado para os campos de valores
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'
				
				//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
				If Len(aMoedas) > 0 
					For nCount := 1 to Len(aMoedas)	
						If aMoedas[nCount] != "01"								
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(CRED)'											
						Endif			
					Next nCount   
				Endif	
			Else //Se for partida dobrada, imprime o valor tanto no campo de débito quanto no de crédito, criados para os campos de valores
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'
				
				//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
				If Len(aMoedas) > 0 
					For nCount := 1 to Len(aMoedas)	
						If aMoedas[nCount] != "01"								
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(DEB)'
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(&("TMP->CT2_VALR" + aMoedas[nCount])) //'(CRED)'											
						Endif			
					Next nCount   
				Endif	
			Endif
			
			oSection2:PrintLine()
			TMP->(DbSkip(nAux))
		Endif
	EndDo
	
	TMP->(RestArea(aAreaAnt))
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDif
Grava a diferença da contabilização incluindo uma linha nova.

@author David Moraes
          
@Return Nill
@since 11/02/2014                           	
@version 1.0
/*/
//-------------------------------------------------------------------
Function GravaDifCent(nValDif, cLancCont, aCTKxCT2, cTabCTK)
Local aArea		:= GetArea() 
Local nLin		:= 0
Local lRet		:= .T.
Local cCtbCenc	:= GetNewPar( "MV_CTBCENC", '' )
Local cTpSald	:= ""
Local cHp		:= ""
Local cHpDesc	:= ""
Local cKey		:= ""
Local cSequen	:= ""
Local cTabOri	:= ""
Local cLote		:= ""
Local cRotina	:= ""
Local nRecOri	:= 0
Local dDtLanc	:= Ctod("//")
Local aRet		:= {}
Local lCTKxCT2	:= .F.

Default cTabCTK		:= ""
Default aCTKxCT2	:= {}

If !Empty(cCtbCenc)
	aRet := QuebraParam(cCtbCenc)
	lRet := CtbBenc(aRet)
Else
	Help( " ", 1, "MV_CTBENC" )//"Favor informar o parâmetro MV_CTBCENC com as entidades contábeis!"
	lRet := .F.
EndIf

If lRet
	lCTKxCT2 := !Empty(aCTKxCT2) 
	If lCTKxCT2
		(cTabCTK)->(DbGoTo(aCTKxCT2[1,2,1]))
		cTabOri := (cTabCTK)->CTK_TABORI
		nRecOri := (cTabCTK)->CTK_RECORI
	Endif	

	DbSelectArea( "TMP" )
	//Úlima linha
	TMP->(DbGoTop())
	While TMP->(!Eof())
		If !TMP->CT2_FLAG
			cTpSald := TMP->CT2_TPSALD
			cHp     := TMP->CT2_HP
			cHpDesc := TMP->CT2_HIST
			cKey 	:= TMP->CT2_KEY
			cSequen	:= TMP->CT2_SEQUEN
			dDtLanc	:= TMP->CT2_DATA
			cLote	:= TMP->CT2_LOTE
			cRotina	:= TMP->CT2_ROTINA
			nLin++
		EndIf
		TMP->(dbSkip())
	EndDo
	
	//Inclui uma linha nova
	DbGoTop()
	RecLock("TMP",.T.)
	
	cLinha := Soma1(Strzero(nLin,3))
	TMP->CT2_LINHA 	:= cLinha
	TMP->CT2_KEY	:= ckey
	TMP->CT2_SEQUEN	:= cSequen
	
	If cLancCont == "D"//Debito
		TMP->CT2_DC     := "1"
		TMP->CT2_DEBITO := aRet[1]
		TMP->CT2_CCD    := aRet[2]
		TMP->CT2_ITEMD  := aRet[3]
		TMP->CT2_CLVLDB := aRet[4]
		TMP->CT2_TPSALD := cTpSald
		TMP->CT2_HP     := cHp
		TMP->CT2_HIST   := cHpDesc
		
		If __lEnt05
			If !Empty(aRet[5])
				TMP->CT2_EC05DB := aRet[5]
			EndIf
		EndIf

		If __lEnt06
			If !Empty(aRet[6])
				TMP->CT2_EC06DB := aRet[6]
			EndIf
		EndIf
		
		If __lEnt07
			If !Empty(aRet[7])
				TMP->CT2_EC07DB := aRet[7]
			EndIf
		EndIf
		
		If __lEnt08
			If !Empty(aRet[8])
				TMP->CT2_EC08DB := aRet[8]
			EndIf
		EndIf
		
		If __lEnt09
			If !Empty(aRet[9])
				TMP->CT2_EC09DB := aRet[9]
			EndIf
		EndIf

	Else//Credito
		TMP->CT2_DC     := "2"
		TMP->CT2_CREDIT := aRet[1]  
		TMP->CT2_CCC    := aRet[2]
		TMP->CT2_ITEMC  := aRet[3]
		TMP->CT2_CLVLCR := aRet[4]
		TMP->CT2_TPSALD := cTpSald
		TMP->CT2_HP     := cHp
		TMP->CT2_HIST   := cHpDesc

		If __lEnt05
			If !Empty(aRet[5])
				TMP->CT2_EC05CR := aRet[5]
			EndIf
		EndIf
		
		If __lEnt06
			If !Empty(aRet[6])
				TMP->CT2_EC06CR := aRet[6]
			EndIf
		EndIf
		
		If __lEnt07
			If !Empty(aRet[7])
				TMP->CT2_EC07CR := aRet[7]
			EndIf
		EndIf
		
		If __lEnt08
			If !Empty(aRet[8])
				TMP->CT2_EC08CR := aRet[8]
			EndIf
		EndIf
		
		If __lEnt09
			If !Empty(aRet[9])
				TMP->CT2_EC09CR := aRet[9]
			EndIf
		EndIf

	EndIf
	
	TMP->CT2_VALOR  := nValDif
	
	MsUnlock()
	
	If lCTKxCT2
		RecLock(cTabCTK,.T.)
		(cTabCTK)->CTK_FILIAL 	:= xFilial("CTK")
		(cTabCTK)->CTK_DATA		:= dDtLanc
		(cTabCTK)->CTK_SEQUEN	:= TMP->CT2_SEQUEN      
		(cTabCTK)->CTK_DC		:= TMP->CT2_DC
		(cTabCTK)->CTK_LP		:= TMP->CT2_LP
		(cTabCTK)->CTK_LPSEQ	:= TMP->CT2_SEQLAN
		(cTabCTK)->CTK_KEY		:= TMP->CT2_KEY	
		(cTabCTK)->CTK_DEBITO	:= TMP->CT2_DEBITO
		(cTabCTK)->CTK_CREDIT	:= TMP->CT2_CREDIT
		(cTabCTK)->CTK_VLR01	:= nValDif
		(cTabCTK)->CTK_HIST		:= TMP->CT2_HIST
		(cTabCTK)->CTK_HAGLUT	:= TMP->CT2_HIST
		(cTabCTK)->CTK_CCC		:= TMP->CT2_CCC
		(cTabCTK)->CTK_CCD		:= TMP->CT2_CCD
		(cTabCTK)->CTK_ITEMC	:= TMP->CT2_ITEMC
		(cTabCTK)->CTK_ITEMD	:= TMP->CT2_ITEMD
		(cTabCTK)->CTK_CLVLDB	:= TMP->CT2_CLVLDB
		(cTabCTK)->CTK_CLVLCR	:= TMP->CT2_CLVLCR
		(cTabCTK)->CTK_MOEDLC	:= TMP->CT2_MOEDLC
		(cTabCTK)->CTK_TPSALD	:= TMP->CT2_TPSALD
		(cTabCTK)->CTK_ROTINA	:= cRotina
		(cTabCTK)->CTK_LOTE		:= cLote
		(cTabCTK)->CTK_CONTAB	:= "2"
		(cTabCTK)->CTK_TABORI	:= cTabOri 
		(cTabCTK)->CTK_RECORI	:= nRecOri
		MsUnLock()
		Aadd(aCTKxCT2,{TMP->(Recno()),{(cTabCTK)->(Recno())}})
	Endif
EndIf
	
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QuebraParam
Efetua a quebra do valor em array de acordo com o delimitador informado no parametro.

@author David Moraes
          
@Return aRet retorna em forma de Array os valores informados no parametro.
@since 11/02/2014                           	
@version 1.0
/*/
//-------------------------------------------------------------------
Function QuebraParam(cText, cChar)
Local nX       := 0     
Local nPosIni  := 1
Local nPosFim  := 1
Local aRet     := {}
                        
Default cChar      := ";" 
Default cText      := ""

For nX :=  1 To Len(cText)

	nPosFim := AT(cChar, cText)
	If nPosFim > 0
		AADD(aRet,SubStr(cText,nPosIni,nPosFim-1))
		cText := SubStr(cText,nPosFim+1,Len(cText))
	Else
		If !Empty(cText)
			AADD(aRet,Alltrim(cText))
		EndIf

		Exit	

	EndIf
Next nX 

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbSetTmpBºAutor  ³Microsiga           º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Flag de variavel static para indicar se vai criar o tmp    º±±
±±º          ³ (tela de contabilizacao) direto no banco de dados          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbSetTmpB(lTmpBD)

__lArqTmpB	:= lTmpBD

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbCrTmpBDºAutor  ³Microsiga           º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criacao do  tmp (tela de contabilizacao) direto no banco   º±±
±±º          ³ de dados                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbCrTmpBD()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader para Lan‡amentos Cont beis                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__aCampos := Ctb105Head(@aAltera,.F./*lSimula*/)

Ctb105Cria(__aCampos,@__cArq1,@__cArq2)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbVerTmpBDºAutor  ³Microsiga          º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se arquivo tmp foi criado no banco                 º±±
±±º          ³ de dados                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbVerTmpBD()
Local lRet := .T.

lRet := __lArqTmpB

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbDelTmpBDºAutor  ³Microsiga          º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao do  tmp (tela de contabilizacao) direto no banco  º±±
±±º          ³ de dados                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbDelTmpBD()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga as tabelas criadas no banco (tela de contabilizacao)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet := .F.
If Select("TMP") > 0
	TMP->( dbCloseArea() )
EndIf
If Select("TMP_CTB") > 0
	TMP_CTB->( dbCloseArea() )
EndIf

If TcDelFile(__cArq1)
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbDel_TmpºAutor  ³Microsiga          º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao do  tmp (tela de contabilizacao) do SYSTEM       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbDel_Tmp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga as tabelas criadas no banco (tela de contabilizacao)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet := .F.
If Select("TMP") > 0
	TMP->( dbCloseArea() )
	FErase( __cArq1+cDbsExt )
	Ferase( __cArq1+cIndExt )
	Ferase( __cArq2+cIndExt )
	lRet := .T.
	dbSelectArea("CT2")
EndIf

If TCSPExist( _PrCT2Psq+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ _PrCT2Psq+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de Pesquisa CT2." + _PrCT2Psq+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		lRet := .T.
	EndIf
Endif


Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbDelProc ºAutor  ³Microsiga          º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao das procedures criadas no banco de dados          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbDelProc()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga as tabelas criadas no banco (tela de contabilizacao)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lRet := .F.

If TCSPExist( __cProcRegra+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcRegra+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de Regra/Contra-Regra." + __cProcRegra+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE DE REGRA/CONTRA-REGRA" + __cProcRegra+"_"+cEmpAnt  )
		lRet := .T.
	EndIf
Endif

If TCSPExist( __cProcAmar+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcAmar+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de Amarracao." + __cProcAmar+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE DE AMARRACAO" + __cProcAmar+"_"+cEmpAnt )
		lRet := .T.
	EndIf
Endif

If TCSPExist( __cProcPai+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcPai+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de validacao contabilização." + __cProcPai+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE DE VALIDACAO CONTABILIZACAO" + __cProcPai+"_"+cEmpAnt )
		lRet := .T.
	EndIf
Endif

If TCSPExist( __cProcZero+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcZero+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de StrZero usada na contabilizacao." + __cProcZero+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE STRZERO USADA NA CONTABILIZACAO" + __cProcZero+"_"+cEmpAnt )
		lRet := .T.
	EndIf
Endif

If TCSPExist( __cProcSoma1+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcSoma1+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de StrZero usada na contabilizacao." + __cProcSoma1+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE STRZERO USADA NA CONTABILIZACAO" + __cProcSoma1+"_"+cEmpAnt )
		lRet := .T.
	EndIf
Endif

If TCSPExist( __cProcDoc+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcDoc+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure Prox.Doc. usada na contabilizacao." + __cProcDoc+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE STRZERO USADA NA CONTABILIZACAO" + __cProcDoc+"_"+cEmpAnt )
		lRet := .T.
	EndIf
Endif

If TCSPExist( __cProcGrv+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcGrv+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de gravacao contabilização." + __cProcGrv+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE DE GRAVACAO DE CONTABILIZACAO" + __cProcGrv+"_"+cEmpAnt )
		lRet := .T.
	EndIf
Endif
If TCSPExist( __cProcFil+"_"+cEmpAnt )
	If TcSqlExec("DROP PROCEDURE "+ __cProcFil+"_"+cEmpAnt) <> 0
 		UserException("Erro na deleção da Procedure de gravacao contabilização." + __cProcFil+"_"+cEmpAnt + CRLF + TCSqlError() )
   	Else
		Conout( "#SUCESSO# EXCLUSAO DA PROCEDURE DE GRAVACAO DE CONTABILIZACAO" + __cProcFil+"_"+cEmpAnt )
		lRet := .T.
	EndIf
Endif
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct105LOKPr ºAutor  ³Microsiga          º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criação da procedure de validacao da linkaok(tela de       º±±
±±º          ³ contabilizacao) qdo tmp criado direto no banco de dados    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
Function Ct105LOKPr(cProcName, cProcAmar, cProcFil)
Local lRet 			:= .T.
Local cQuery 		:= ""
Local cDeclare  	:= ""
Local cCpoCursor 	:= ""
Local cVarProc   	:= ""
Local nQtdMoeda	:= __nQuantas
Local nX
Local cAmarracao	:= If(FindFunction("CtbUseAmar"),CtbUseAmar(),"1")
Local cVarIni     := ""

DEFAULT cProcName 	:= CriaTrab(,.F.)

If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

//variaveis para declarar na procedure e utilizacao no cursor 
CtbPrepPrc( @cDeclare, @cCpoCursor, @cVarProc,,,, @cVarIni )

cQuery := " CREATE PROCEDURE "+cProcName+"_"+cEmpAnt+"( "+CRLF
cQuery +="  @IN_DATALANC 	Char(8),"+CRLF
cQuery +="  @IN_FILIAL    	Char("+Alltrim(Str(Len(CT2->CT2_FILIAL)))+"),"+CRLF
cQuery += " @OUT_RET 		char(1) output" +CRLF
cQuery += " ) as "+ CRLF
cQuery += " "+ CRLF
//declara as variaveis
cQuery += cDeclare + CRLF
cQuery += " Declare @nMoedaInUse integer "+CRLF
cQuery += " Declare @nMoedDtUse integer "+CRLF
cQuery += " Declare @nContador integer "+CRLF
cQuery += " Declare @nContador1 integer "+CRLF
cQuery += " Declare @cDigConta VarChar("+Alltrim(Str(Len(CT1->CT1_DC)))+") "+CRLF
cQuery += " Declare @cCT1_CCOBRG VarChar("+Alltrim(Str(Len(CT1->CT1_CCOBRG)))+") "+CRLF
cQuery += " Declare @cCT1_ITOBRG VarChar("+Alltrim(Str(Len(CT1->CT1_ITOBRG)))+") "+CRLF
cQuery += " Declare @cCT1_CLOBRG VarChar("+Alltrim(Str(Len(CT1->CT1_CLOBRG)))+") "+CRLF
If CT1->( FieldPos( "CT1_05OBRG" ) ) > 0
	cQuery += "  Declare @cCT1_05OBRG VarChar("+Alltrim(Str(Len(CT1->CT1_05OBRG)))+") "+CRLF
	cQuery += "  Declare @cCT1_ACET05 VarChar("+Alltrim(Str(Len(CT1->CT1_ACET05)))+") "+CRLF
EndIf
If CT1->( FieldPos( "CT1_06OBRG" ) ) > 0
	cQuery += "  Declare @cCT1_06OBRG VarChar("+Alltrim(Str(Len(CT1->CT1_06OBRG)))+") "+CRLF
	cQuery += "  Declare @cCT1_ACET06 VarChar("+Alltrim(Str(Len(CT1->CT1_ACET06)))+") "+CRLF
EndIf
If CT1->( FieldPos( "CT1_07OBRG" ) ) > 0
	cQuery += "  Declare @cCT1_07OBRG VarChar("+Alltrim(Str(Len(CT1->CT1_07OBRG)))+") "+CRLF
	cQuery += "  Declare @cCT1_ACET07 VarChar("+Alltrim(Str(Len(CT1->CT1_ACET07)))+") "+CRLF
EndIf
If CT1->( FieldPos( "CT1_08OBRG" ) ) > 0
	cQuery += "  Declare @cCT1_08OBRG VarChar("+Alltrim(Str(Len(CT1->CT1_08OBRG)))+") "+CRLF
	cQuery += "  Declare @cCT1_ACET08 VarChar("+Alltrim(Str(Len(CT1->CT1_ACET08)))+") "+CRLF
EndIf
If CT1->( FieldPos( "CT1_09OBRG" ) ) > 0
	cQuery += "  Declare @cCT1_09OBRG VarChar("+Alltrim(Str(Len(CT1->CT1_09OBRG)))+") "+CRLF
	cQuery += "  Declare @cCT1_ACET09 VarChar("+Alltrim(Str(Len(CT1->CT1_ACET09)))+") "+CRLF
EndIf
cQuery += "    Declare @cCTT_ITOBRG VarChar("+Alltrim(Str(Len(CTT->CTT_ITOBRG)))+") "+CRLF
cQuery += "    Declare @cCTT_CLOBRG VarChar("+Alltrim(Str(Len(CTT->CTT_CLOBRG)))+") "+CRLF
cQuery += "    Declare @cCTD_CLOBRG VarChar("+Alltrim(Str(Len(CTD->CTD_CLOBRG)))+") "+CRLF
cQuery += "    Declare @cCT1_ACCUST VarChar("+Alltrim(Str(Len(CT1->CT1_ACCUST)))+") "+CRLF
cQuery += "    Declare @cCT1_ACITEM VarChar("+Alltrim(Str(Len(CT1->CT1_ACITEM)))+") "+CRLF
cQuery += "    Declare @cCT1_ACCLVL VarChar("+Alltrim(Str(Len(CT1->CT1_ACCLVL)))+") "+CRLF
cQuery += "    Declare @cRetRegra VarChar(1) "+CRLF
cQuery += "    Declare @cFilCT1      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cFilCTT      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cFilCTD      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cFilCTH      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cFilCTO      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cFilCTP      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cFilCTE      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cFilCTG      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery += "    Declare @cAux       	Char( 03 )"+CRLF
//inicio do processamento
cQuery += "Begin " + CRLF
cQuery += " " + CRLF
cQuery += "select @OUT_RET = '0' " + CRLF
cQuery += "select @cAux  = 'CT1' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCT1 output " + CRLF
cQuery += "select @cAux  = 'CTT' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTT output " + CRLF
cQuery += "select @cAux  = 'CTD' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTD output " + CRLF
cQuery += "select @cAux  = 'CTH' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTH output " + CRLF
cQuery += "select @cAux  = 'CTO' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTO output " + CRLF
cQuery += "select @cAux  = 'CTP' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTP output " + CRLF
cQuery += "select @cAux  = 'CTE' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTE output " + CRLF
cQuery += "select @cAux  = 'CTG' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTG output " + CRLF

cQuery += cVarIni + CRLF

//declaracao do cursor
	
cQuery += "Declare cCursor insensitive cursor for" + CRLF
cQuery += " "+ CRLF
cQuery += "SELECT "+cCpoCursor+" FROM "+__cArq1+ CRLF
cQuery += " "+ CRLF
cQuery += "FOR READ ONLY" + CRLF
cQuery += "Open cCursor "+ CRLF
cQuery += "    Fetch cCursor into "+ cVarProc+ CRLF
//laco do cursor
cQuery += "While (@@FETCH_STATUS = 0)  "+ CRLF
cQuery += "begin "+ CRLF
cQuery += "   IF @cCT2_DC = ' ' "+ CRLF
cQuery += "      select @cCT2_VLD01 = '1' "+ CRLF
cQuery += " "+ CRLF
//VALIDACAO 01  - Indicador deb/cred/part.dobrada/contin. historico esta preenchido
cQuery += "   IF @cCT2_DC = ' ' "+ CRLF  
cQuery += "      select @cCT2_VLD01 = '1' "+ CRLF
cQuery += " "+ CRLF

cQuery += "   IF @cCT2_DC != '4' "+ CRLF
cQuery += "   Begin "+ CRLF //<------------------
//VALIDACAO 02  -- verificar criterio de conversao=5 e valor diferente de zero a partir da moeda 2
For nX := 2 TO nQtdMOeda
	cQuery += "      IF @nCT2_VALR"+StrZero(nX,2)+" <> 0 AND SUBSTRING(@cCT2_CONVER,"+StrZero(nX,2)+",1) = '5' "+ CRLF
	cQuery += "         select @cCT2_VLD02 = '2' "+ CRLF
	cQuery += " "+ CRLF
Next
cQuery += "      IF @cCT2_VLD02 = ' ' AND @nCT2_VALOR = 0 "+ CRLF
cQuery += "         select @cCT2_VLD02 = '2' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 03 		-- primeiro verificar se todas as moedas estao em uso - CTBMInUse(cCoin4) 
//VALIDACAO 03.1 	-- depois moeda na data esta liberada - CtbDtInUse(cCoin4,dDataLanc)
//VALIDACAO 03.2 -- Verifica CTG ausencia ou bloqueio de calendário. -- CtbDtComp(3,dDataLanc,cCoin4,,cTpSald) 
For nX := 1 TO nQtdMOeda  //todas as moedas

	If nX == 1    //moeda 1 pega CT2_VALOR
		cQuery += "      IF @cCT2_VLD03 = ' ' AND @nCT2_VALOR != 0 "+ CRLF
		cQuery += "      Begin"+ CRLF
	Else          //moeda 2 em diante CT2_VALR+moeda
		cQuery += "      IF @cCT2_VLD03 = ' ' AND @nCT2_VALR"+StrZero(nX,2)+" != 0 "+ CRLF
		cQuery += "      Begin"+ CRLF
	EndIf
    //inicio da validacao
		//VALIDACAO 03 		-- primeiro verificar se todas as moedas estao em uso - CTBMInUse(cCoin4) 
		cQuery +="      Select @nMoedaInUse = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTO")+;
													" Where CTO_FILIAL = @cFilCTO AND CTO_MOEDA = '"+StrZero(nX,2)+"' "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "      IF @cCT2_VLD03 = ' ' AND @nMoedaInUse = 0 "+ CRLF
		cQuery += "         select @cCT2_VLD03 = '19' "+ CRLF
		cQuery +="      Select @nMoedaInUse = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTO")+;
													" Where CTO_FILIAL = @cFilCTO AND CTO_MOEDA = '"+StrZero(nX,2)+"'"+;
													" AND CTO_BLOQ = '1' AND D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "      IF @cCT2_VLD03 = ' ' AND @nMoedaInUse > 0 "+ CRLF
		cQuery += "         select @cCT2_VLD03 = '19' "+ CRLF
		cQuery += " "+ CRLF
		//VALIDACAO 03.1 	-- depois moeda na data esta liberada - CtbDtInUse(cCoin4,dDataLanc)
		cQuery +="      Select @nMoedDtUse = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTP")+;
													" Where CTP_FILIAL = @cFilCTP AND CTP_MOEDA = '"+StrZero(nX,2)+"' "+;
													" AND CTP_DATA = @IN_DATALANC AND D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "      IF @cCT2_VLD03 = ' ' AND @nMoedDtUse > 0 "+ CRLF
		cQuery +="           Select @nMoedDtUse = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTP")+;
													" Where CTP_FILIAL = @cFilCTP "+;
													" AND CTP_MOEDA = '"+StrZero(nX,2)+"' AND CTP_DATA = @IN_DATALANC "+;
													" AND CTP_BLOQ = '1' AND D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "      IF @cCT2_VLD03 = ' ' AND @nMoedDtUse > 0 "+ CRLF
		cQuery += "         select @cCT2_VLD03 = '19' "+ CRLF
		cQuery += " "+ CRLF
		//VALIDACAO 03.2 -- Verifica CTG ausencia ou bloqueio de calendário/moeda. -- CtbDtComp(3,dDataLanc,cCoin4,,cTpSald) 
		cQuery +="      Select @nMoedDtUse = ISNULL( Count(CTE.R_E_C_N_O_), 0 ) From "+RetSqlName("CTE")+" CTE,"+RetSqlName("CTG")+" CTG "+;
													" Where CTE_FILIAL = CTG_FILIAL AND CTE_CALEND = CTG_CALEND "+;
													" AND CTE_FILIAL = @cFilCTE "+;
													" AND CTE_MOEDA = '"+StrZero(nX,2)+"' "+;
													" AND CTG_FILIAL = @cFilCTG "+;
													" AND @IN_DATALANC BETWEEN CTG_DTINI AND CTG_DTFIM "+;
													" AND CTG_STATUS = '1' "+;
													" AND CTE.D_E_L_E_T_ = ' ' AND CTG.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "      IF @cCT2_VLD03 = ' ' AND @nMoedDtUse = 0 "+ CRLF
		cQuery += "         select @cCT2_VLD03 = '19' "+ CRLF
		cQuery += " "+ CRLF
	//fim da validacao - fecha o begin referente a valor diferente de zero
	cQuery += "      End"+ CRLF

Next 

cQuery += "   End "+ CRLF  //<-------------------

//VALIDACAO 04 - Historico nao preenchido
cQuery += "   IF @cCT2_VLD04 = ' ' AND @cCT2_HIST = ' ' "+ CRLF
cQuery += "      select @cCT2_VLD04 = '3' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 05 - Se eh lancamento de historico complementar, nao pode ter valor
cQuery += "   IF @cCT2_VLD05 = ' ' AND @cCT2_DC = '4' AND @nCT2_VALOR != 0 "+ CRLF
cQuery += "      select @cCT2_VLD05 = '4' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 06 - Se eh lancamento de historico complementar, nao pode ter conta prenchida.
cQuery += "   IF @cCT2_VLD06 = ' ' AND @cCT2_DC = '4' AND  ( @cCT2_DEBITO != ' ' OR @cCT2_CREDIT = ' ' OR"
cQuery += "                                                  @cCT2_CCD = ' ' OR @cCT2_CCC = ' ' OR "
cQuery += "                                                  @cCT2_ITEMD = ' ' OR @cCT2_ITEMC = ' ' OR "
cQuery += "                                                  @cCT2_CLVLDB = ' ' OR @cCT2_CLVLCR = ' ' )"+CRLF
cQuery += "      select @cCT2_VLD06 = '5' "+ CRLF
cQuery += " "+ CRLF
//-----------------------------------D E B I T O-----------------------------------------------------------//
//VALIDACAO 07 - DEBITO - Verifica se a conta foi preenchida
cQuery += "   IF @cCT2_VLD07 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DEBITO = ' ' "+CRLF
cQuery += "      select @cCT2_VLD07 = '6' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 08 - DEBITO - // Verifica se a conta existe e nao e sintetica
cQuery +="      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CT1")+;
													" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_DEBITO "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou a conta atribue 7
cQuery += "   IF @cCT2_VLD08 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DEBITO != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD08 = '20' "+ CRLF
cQuery += " "+ CRLF
//se encontrou a conta e classe for diferente de 2 atribue 7
cQuery +="      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CT1")+;
													" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_DEBITO "+;
													" AND CT1_CLASSE != '2' AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "   IF @cCT2_VLD08 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DEBITO != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD08 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 08.1 - DEBITO -- verifica se conta nao esta bloqueada 
cQuery +="      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CT1")+;
													" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_DEBITO "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CT1_BLOQ = '1' "+;
                                                    "        OR ( CT1_DTBLIN <> ' ' AND CT1_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CT1_DTBLIN AND CT1_DTBLFI ) "+;
                                                    "        OR (     ( CT1_DTEXIS <> ' ' AND @IN_DATALANC < CT1_DTEXIS )"+;
                                                    "              OR ( CT1_DTEXSF <> ' ' AND @IN_DATALANC  > CT1_DTEXSF ) ) )"+CRLF
cQuery += "   IF @cCT2_VLD08 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DEBITO != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD08 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 09 - verifica digito de controle
If __lDCDUso
	//Se lan‡amento e devedor e digito da conta nao preenchido
	cQuery += "   IF @cCT2_VLD09 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DCD = ' '"+CRLF
	cQuery += "      select @cCT2_VLD09 = '8' "+ CRLF
	cQuery += " "+ CRLF
	cQuery +="      Select @cDigConta = CT1_DC From "+RetSqlName("CT1")+;
												" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_DEBITO "+;
												" AND D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "   IF @cCT2_VLD09 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DEBITO != ' '  AND @cDigConta != @cCT2_DCD "+CRLF
	cQuery += "      select @cCT2_VLD09 = '9' "+ CRLF
	cQuery += " "+ CRLF
EndIf

//VALIDACAO 10 - DEBITO -- Valida CENTRO DE CUSTO e bloqueio
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD10 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' ' "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTT")+;
													" Where CTT_FILIAL = @cFilCTT AND CTT_CUSTO = @cCT2_CCD "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou a conta atribue 7
cQuery += "   IF @cCT2_VLD10 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD10 = '20' "+ CRLF
cQuery += " "+ CRLF
//VALIDACAO 10.1 -- bloqueio de centro de custo
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD10 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' ' "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTT")+;
													" Where CTT_FILIAL = @cFilCTT AND CTT_CUSTO = @cCT2_CCD "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CTT_BLOQ = '1' "+;
                                                    "        OR ( CTT_DTBLIN <> ' ' AND CTT_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CTT_DTBLIN AND CTT_DTBLFI ) "+;
                                                    "        OR (     ( CTT_DTEXIS <> ' ' AND @IN_DATALANC < CTT_DTEXIS )"+;
                                                    "              OR ( CTT_DTEXSF <> ' ' AND @IN_DATALANC  > CTT_DTEXSF ) ) ) "+CRLF

//se nao encontrou a conta atribue 7
cQuery += "   IF @cCT2_VLD10 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD10 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 11 - DEBITO - Valida ITEM CONTABIL e bloqueio
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD11 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMD != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTD")+;
													" Where CTD_FILIAL = @cFilCTD AND CTD_ITEM = @cCT2_ITEMD "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou atribue 7
cQuery += "   IF @cCT2_VLD11 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMD != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD11 = '20' "+ CRLF
cQuery += " "+ CRLF
//VALIDACAO 11.1 -- bloqueio de centro de custo
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD11 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMD != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTD")+;
													" Where CTD_FILIAL = @cFilCTD AND CTD_ITEM = @cCT2_ITEMD "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CTD_BLOQ = '1' "+;
                                                    "        OR ( CTD_DTBLIN <> ' ' AND CTD_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CTD_DTBLIN AND CTD_DTBLFI ) "+;
                                                    "        OR (     ( CTD_DTEXIS <> ' ' AND @IN_DATALANC < CTD_DTEXIS )"+;
                                                    "              OR ( CTD_DTEXSF <> ' ' AND @IN_DATALANC  > CTD_DTEXSF ) ) ) "+CRLF

//se nao encontrou  atribue 7
cQuery += "   IF @cCT2_VLD11 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMD != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD11 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 12 - DEBITO - Valida CLASSE DE VALOR e bloqueio
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD12 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLDB != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTH")+;
													" Where CTH_FILIAL = @cFilCTH AND CTH_CLVL = @cCT2_CLVLDB "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou atribue 7
cQuery += "   IF @cCT2_VLD12 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLDB != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD12 = '20' "+ CRLF
cQuery += " "+ CRLF
//VALIDACAO 12.1 -- bloqueio de classe de valor
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD12 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLDB != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTH")+;
													" Where CTH_FILIAL = @cFilCTH AND CTH_CLVL = @cCT2_CLVLDB "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CTH_BLOQ = '1' "+;
                                                    "        OR ( CTH_DTBLIN <> ' ' AND CTH_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CTH_DTBLIN AND CTH_DTBLFI ) "+;
                                                    "        OR (     ( CTH_DTEXIS <> ' ' AND @IN_DATALANC < CTH_DTEXIS )"+;
                                                    "              OR ( CTH_DTEXSF <> ' ' AND @IN_DATALANC  > CTH_DTEXSF ) ) ) "+CRLF

//se nao encontrou  atribue 7
cQuery += "   IF @cCT2_VLD12 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLDB != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD12 = '7' "+ CRLF
cQuery += " "+ CRLF

//13A. VALIDACAO - DEBITO - AMARRACAO
//³ Verifica se as amarracoes estao corretas                                         ³
//_CtbAmarr(.T., cDebito,cContCCD,cItemD,cCLVLD,.T.,lRpc,.T.)
If cAmarracao != "0"

	If 		cAmarracao == "1"
		cQuery += "   Select @cRetRegra = 0 "+CRLF
		cQuery += "   EXEC "+cProcAmar+"_"+cEmpAnt+ " @IN_FILIAL, @cCT2_DEBITO, @cCT2_CCD, @cCT2_ITEMD, @cCT2_CLVLDB, @cRetRegra OutPut"+CRLF
		cQuery += "   IF @cCT2_VLD13 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND @cRetRegra = 0  "+CRLF
		cQuery += "      select @cCT2_VLD13 = '10' "+ CRLF
	
	ElseIf 	cAmarracao == "2"
		cQuery += "      select @nContador = 0 "+ CRLF
		cQuery += "      select @nContador1 = 0 "+ CRLF
		cQuery += CtQryAmar2("D")
		cQuery += "   IF @cCT2_VLD13 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND @nContador1 != 0 AND @nContador = 0  "+CRLF
		cQuery += "      select @cCT2_VLD13 = '10' "+ CRLF
	
	ElseIf 	cAmarracao == "3"
		cQuery += "      select @nContador = 0 "+ CRLF
		cQuery += CtQryAmar3("D")
		cQuery += "   IF @cCT2_VLD13 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND @nContador > 0  "+CRLF
		cQuery += "      select @cCT2_VLD13 = '10' "+ CRLF
	EndIf
EndIf	

//14a. VALIDACAO
//Valida informações complementares
//If ( lVAt ) .And. ( lRet )
//	lRet := CTBValidAt( "DB", 2, cDebito, cContCCD, cItemD, cCLVLD )	//Função do CTBXFUNC.PRW
//Endif

//15A. VALIDACAO - DEBITO - OBRIGATORIEDADE DOS CAMPOS E ACEITE
cQuery += "   IF @cCT2_VLD15 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) Begin "+CRLF
cQuery += "      Select @cCT1_CCOBRG = ' ' "+CRLF
cQuery += "      Select @cCT1_ITOBRG = ' ' "+CRLF
cQuery += "      Select @cCT1_CLOBRG = ' ' "+CRLF
cQuery += "      Select @cCT1_ACCUST = ' ' "+CRLF
cQuery += "      Select @cCT1_ACITEM = ' ' "+CRLF
cQuery += "      Select @cCT1_ACCLVL = ' ' "+CRLF

If CT1->( FieldPos( "CT1_05OBRG" ) ) > 0
	cQuery += "   Select @cCT1_05OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET05 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_06OBRG" ) ) > 0
	cQuery += "   Select @cCT1_06OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET06 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_07OBRG" ) ) > 0
	cQuery += "   Select @cCT1_07OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET07 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_08OBRG" ) ) > 0
	cQuery += "    Select @cCT1_08OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET08 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_09OBRG" ) ) > 0
	cQuery += "    Select @cCT1_09OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET09 = ' ' "+CRLF
EndIf

cQuery += "      Select @cCT1_CCOBRG = CT1_CCOBRG, @cCT1_ITOBRG = CT1_ITOBRG, "
cQuery += "      @cCT1_CLOBRG = CT1_CLOBRG, "
cQuery += "      @cCT1_ACCUST = CT1_ACCUST, "
cQuery += "      @cCT1_ACITEM = CT1_ACITEM, "
cQuery += "      @cCT1_ACCLVL = CT1_ACCLVL  "
 
If CT1->( FieldPos( "CT1_05OBRG" ) ) > 0
	cQuery += "      , @cCT1_05OBRG = CT1_05OBRG "
	cQuery += "      , @cCT1_ACET05 = CT1_ACET05 "
EndIf
If CT1->( FieldPos( "CT1_06OBRG" ) ) > 0
	cQuery += "      , @cCT1_06OBRG = CT1_06OBRG "
	cQuery += "      , @cCT1_ACET06 = CT1_ACET06 "
EndIf
If CT1->( FieldPos( "CT1_07OBRG" ) ) > 0
	cQuery += "      , @cCT1_07OBRG = CT1_07OBRG "
	cQuery += "      , @cCT1_ACET07 = CT1_ACET07 "
EndIf
If CT1->( FieldPos( "CT1_08OBRG" ) ) > 0
	cQuery += "      , @cCT1_08OBRG = CT1_08OBRG "
	cQuery += "      , @cCT1_ACET08 = CT1_ACET08 "
EndIf
If CT1->( FieldPos( "CT1_09OBRG" ) ) > 0
	cQuery += "      , @cCT1_09OBRG = CT1_09OBRG "
	cQuery += "      , @cCT1_ACET09 = CT1_ACET09 "
EndIf
cQuery += "      FROM "+RetSqlName("CT1")
cQuery += "      WHERE CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_DEBITO AND D_E_L_E_T_ = ' ' "+CRLF
//valida OBRIGATORIEDADE por plano de conta
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_CCOBRG = '1' AND @cCT2_CCD = ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ITOBRG = '1' AND @cCT2_ITEMD = ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_CLOBRG = '1' AND @cCT2_CLVLDB = ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
If lRet .AND. CT1->( FieldPos( "CT1_05OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC05DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_05OBRG = '1' AND @cCT2_EC05DB = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_06OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC06DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_06OBRG = '1' AND @cCT2_EC06DB = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_07OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC07DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_07OBRG = '1' AND @cCT2_EC07DB = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_08OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC08DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_08OBRG = '1' AND @cCT2_EC08DB = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_09OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC09DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_09OBRG = '1' AND @cCT2_EC09DB = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
//valida OBRIGATORIEDADE por centro de custo
cQuery += "      Select @cCTT_ITOBRG = ' ' "
cQuery += "      Select @cCTT_CLOBRG = ' ' "
cQuery += "      Select @cCTT_ITOBRG = CTT_ITOBRG, @cCTT_CLOBRG = CTT_CLOBRG "
cQuery += "      FROM "+RetSqlName("CTT")
cQuery += "      WHERE CTT_FILIAL = @cFilCTT AND CTT_CUSTO = @cCT2_CCD AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCTT_ITOBRG = '1' And @cCT2_ITEMD = ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCTT_CLOBRG = '1' AND @cCT2_CLVLDB = ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
//valida OBRIGATORIEDADE por item
cQuery += "      Select @cCTD_CLOBRG = ' ' "
cQuery += "      Select @cCTD_CLOBRG = CTD_CLOBRG"
cQuery += "      FROM "+RetSqlName("CTD")
cQuery += "      WHERE CTD_FILIAL = @cFilCTD AND CTD_ITEM = @cCT2_ITEMD AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCTD_CLOBRG = '1' AND @cCT2_CLVLDB = ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
//Valida ACEITE por plano de contas    ******AQUI*****
//cQuery += "      @cCT1_ACCUST = CT1_ACCUST, "
//cQuery += "      @cCT1_ACITEM = CT1_ACITEM, "
//cQuery += "      @cCT1_ACCLVL = CT1_ACCLVL, "

cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACCUST = '2' AND @cCT2_CCD != ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACITEM = '2' AND @cCT2_ITEMD != ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACCLVL = '2' AND @cCT2_CLVLDB != ' ' "+CRLF
cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
If lRet .AND. CT1->( FieldPos( "CT1_05OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC05DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACET05 = '2' AND @cCT2_EC05DB != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_06OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC06DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACET06 = '2' AND @cCT2_EC06DB != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_07OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC07DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACET07 = '2' AND @cCT2_EC07DB != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_08OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC08DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACET08 = '2' AND @cCT2_EC08DB != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_09OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC09DB") ) > 0
	cQuery += "      IF @cCT2_VLD15 = ' ' AND @cCT1_ACET09 = '2' AND @cCT2_EC09DB != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD15 = '11' "+ CRLF
EndIf
cQuery += "   End "+ CRLF  //final do if obrigatoriedade/aceite

//-----------------------------------C R E D I T O-----------------------------------------------------------//
//VALIDACAO 16 - CREDITO - Verifica se a conta foi preenchida
cQuery += "   IF @cCT2_VLD16 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CREDIT = ' ' "+CRLF
cQuery += "      select @cCT2_VLD16 = '12' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 17 - CREDITO - // Verifica se a conta existe e nao e sintetica
cQuery +="      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CT1")+;
													" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_CREDIT "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou a conta atribue 7
cQuery += "   IF @cCT2_VLD17 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CREDIT != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD17 = '20' "+ CRLF
cQuery += " "+ CRLF
//se encontrou a conta e classe for diferente de 2 atribue 7
cQuery +="      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CT1")+;
													" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_CREDIT "+;
													" AND CT1_CLASSE != '2' AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "   IF @cCT2_VLD17 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CREDIT != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD17 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 17.1 - CREDITO -- verifica se conta nao esta bloqueada 
cQuery +="      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CT1")+;
													" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_CREDIT "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CT1_BLOQ = '1' "+;
                                                    "        OR ( CT1_DTBLIN <> ' ' AND CT1_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CT1_DTBLIN AND CT1_DTBLFI ) "+;
                                                    "        OR (     ( CT1_DTEXIS <> ' ' AND @IN_DATALANC < CT1_DTEXIS )"+;
                                                    "              OR ( CT1_DTEXSF <> ' ' AND @IN_DATALANC  > CT1_DTEXSF ) ) ) "+CRLF
cQuery += "   IF @cCT2_VLD17 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CREDIT != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD17 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 18 - verifica digito de controle
If __lDCDUso
	//Se lan‡amento e devedor e digito da conta nao preenchido
	cQuery += "   IF @cCT2_VLD18 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_DCC = ' '"+CRLF
	cQuery += "      select @cCT2_VLD18 = '13' "+ CRLF
	cQuery += " "+ CRLF
	cQuery +="      Select @cDigConta = CT1_DC From "+RetSqlName("CT1")+;
												" Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_CREDIT "+;
												" AND D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "   IF @cCT2_VLD18 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CREDIT != ' '  AND @cDigConta != @cCT2_DCD "+CRLF
	cQuery += "      select @cCT2_VLD18 = '9' "+ CRLF
	cQuery += " "+ CRLF
EndIf

//VALIDACAO 19 - CREDITO -- Valida CENTRO DE CUSTO e bloqueio
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD19 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTT")+;
													" Where CTT_FILIAL = @cFilCTT AND CTT_CUSTO = @cCT2_CCD "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou a conta atribue 7
cQuery += "   IF @cCT2_VLD19 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD19 = '20' "+ CRLF
cQuery += " "+ CRLF
//VALIDACAO 19.1 -- bloqueio de centro de custo
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD19 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' '  
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTT")+;
													" Where CTT_FILIAL = @cFilCTT AND CTT_CUSTO = @cCT2_CCD "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CTT_BLOQ = '1' "+;
                                                    "        OR ( CTT_DTBLIN <> ' ' AND CTT_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CTT_DTBLIN AND CTT_DTBLFI ) "+;
                                                    "        OR (     ( CTT_DTEXIS <> ' ' AND @IN_DATALANC < CTT_DTEXIS )"+;
                                                    "              OR ( CTT_DTEXSF <> ' ' AND @IN_DATALANC  > CTT_DTEXSF ) ) ) "+CRLF

//se nao encontrou a conta atribue 7
cQuery += "   IF @cCT2_VLD19 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CCD != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD19 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 20 - CREDITO - Valida ITEM CONTABIL e bloqueio
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD20 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMC != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTD")+;
													" Where CTD_FILIAL = @cFilCTD AND CTD_ITEM = @cCT2_ITEMC "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou atribue 7
cQuery += "   IF @cCT2_VLD20 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMC != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD20 = '20' "+ CRLF
cQuery += " "+ CRLF
//VALIDACAO 20.1 -- bloqueio de centro de custo
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD20 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMC != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTD")+;
													" Where CTD_FILIAL = @cFilCTD AND CTD_ITEM = @cCT2_ITEMC "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CTD_BLOQ = '1' "+;
                                                    "        OR ( CTD_DTBLIN <> ' ' AND CTD_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CTD_DTBLIN AND CTD_DTBLFI ) "+;
                                                    "        OR (     ( CTD_DTEXIS <> ' ' AND @IN_DATALANC < CTD_DTEXIS )"+;
                                                    "              OR ( CTD_DTEXSF <> ' ' AND @IN_DATALANC  > CTD_DTEXSF ) ) ) "+CRLF

//se nao encontrou  atribue 7
cQuery += "   IF @cCT2_VLD20 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_ITEMC != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD20 = '7' "+ CRLF
cQuery += " "+ CRLF

//VALIDACAO 21 - CREDITO - Valida CLASSE DE VALOR e bloqueio
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD21 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLCR != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTH")+;
													" Where CTH_FILIAL = @cFilCTH AND CTH_CLVL = @cCT2_CLVLCR "+;
													" AND D_E_L_E_T_ = ' ' "+CRLF
//se nao encontrou atribue 7
cQuery += "   IF @cCT2_VLD21 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLCR != ' '  AND @nContador = 0 "+CRLF
cQuery += "      select @cCT2_VLD21 = '20' "+ CRLF
cQuery += " "+ CRLF
//VALIDACAO 12.1 -- bloqueio de classe de valor
cQuery += "   Select @nContador = 0 "+CRLF
cQuery += "   IF @cCT2_VLD21 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLCR != ' '  "+CRLF
cQuery += "      Select @nContador = ISNULL( Count(R_E_C_N_O_), 0 ) From "+RetSqlName("CTH")+;
													" Where CTH_FILIAL = @cFilCTH AND CTH_CLVL = @cCT2_CLVLCR "+;
													" AND D_E_L_E_T_ = ' ' "+;
                                                    " AND ( CTH_BLOQ = '1' "+;
                                                    "        OR ( CTH_DTBLIN <> ' ' AND CTH_DTBLFI <> ' ' "+;
                                                    "                 AND @IN_DATALANC BETWEEN CTH_DTBLIN AND CTH_DTBLFI ) "+;
                                                    "        OR (     ( CTH_DTEXIS <> ' ' AND @IN_DATALANC < CTH_DTEXIS )"+;
                                                    "              OR ( CTH_DTEXSF <> ' ' AND @IN_DATALANC  > CTH_DTEXSF ) ) ) "+CRLF

//se nao encontrou  atribue 7
cQuery += "   IF @cCT2_VLD21 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CLVLCR != ' '  AND @nContador > 0 "+CRLF
cQuery += "      select @cCT2_VLD21 = '7' "+ CRLF
cQuery += " "+ CRLF

//22A. VALIDACAO - CREDITO - AMARRACAO
//³ Verifica se as amarracoes estao corretas                                         ³
//_CtbAmarr(.T., cCREDITO,cContCCD,cITEMC,cCLVLC,.T.,lRpc,.T.)
If cAmarracao != "0"
	If 		cAmarracao == "1"
		cQuery += "   Select @cRetRegra = 0 "+CRLF
		cQuery += "   EXEC "+cProcAmar+"_"+cEmpAnt+ " @IN_FILIAL, @cCT2_CREDIT, @cCT2_CCC, @cCT2_ITEMC, @cCT2_CLVLCR, @cRetRegra OutPut"+CRLF
		cQuery += "   IF @cCT2_VLD13 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND @cRetRegra = 0  "+CRLF
		cQuery += "      select @cCT2_VLD13 = '10' "+ CRLF
	
	ElseIf 	cAmarracao == "2"
		cQuery += "      select @nContador = 0 "+ CRLF
		cQuery += "      select @nContador1 = 0 "+ CRLF
		cQuery += CtQryAmar2("C")
		cQuery += "   IF @cCT2_VLD22 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' )  AND @nContador1 != 0 AND @nContador = 0  "+CRLF
		cQuery += "      select @cCT2_VLD22 = '10' "+ CRLF
	
	ElseIf 	cAmarracao == "3"
		cQuery += "      select @nContador = 0 "+ CRLF
		cQuery += CtQryAmar3("C")
		cQuery += "   IF @cCT2_VLD22 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND @nContador > 0  "+CRLF
		cQuery += "      select @cCT2_VLD22 = '10' "+ CRLF
	EndIf
EndIf	

//23a. VALIDACAO
//Valida informações complementares
//If ( lVAt ) .And. ( lRet )
//	lRet := CTBValidAt( "CR", 2, cCREDITO, cContCCD, cITEMC, cCLVLC )	//Função do CTBXFUNC.PRW
//Endif

//24A. VALIDACAO - CREDITO - OBRIGATORIEDADE DOS CAMPOS E ACEITE
cQuery += "   IF @cCT2_VLD24 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) Begin "+CRLF
cQuery += "      Select @cCT1_CCOBRG = ' ' "+CRLF
cQuery += "      Select @cCT1_ITOBRG = ' ' "+CRLF
cQuery += "      Select @cCT1_CLOBRG = ' ' "+CRLF
cQuery += "      Select @cCT1_ACCUST = ' ' "+CRLF
cQuery += "      Select @cCT1_ACITEM = ' ' "+CRLF
cQuery += "      Select @cCT1_ACCLVL = ' ' "+CRLF

If CT1->( FieldPos( "CT1_05OBRG" ) ) > 0
	cQuery += "   Select @cCT1_05OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET05 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_06OBRG" ) ) > 0
	cQuery += "   Select @cCT1_06OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET06 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_07OBRG" ) ) > 0
	cQuery += "   Select @cCT1_07OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET07 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_08OBRG" ) ) > 0
	cQuery += "    Select @cCT1_08OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET08 = ' ' "+CRLF
EndIf
If CT1->( FieldPos( "CT1_09OBRG" ) ) > 0
	cQuery += "    Select @cCT1_09OBRG = ' ' "+CRLF
	cQuery += "   Select @cCT1_ACET09 = ' ' "+CRLF
EndIf

cQuery += "      Select @cCT1_CCOBRG = CT1_CCOBRG, @cCT1_ITOBRG = CT1_ITOBRG, "
cQuery += "      @cCT1_CLOBRG = CT1_CLOBRG, "
cQuery += "      @cCT1_ACCUST = CT1_ACCUST, "
cQuery += "      @cCT1_ACITEM = CT1_ACITEM, "
cQuery += "      @cCT1_ACCLVL = CT1_ACCLVL  "
 
If CT1->( FieldPos( "CT1_05OBRG" ) ) > 0
	cQuery += "      , @cCT1_05OBRG = CT1_05OBRG "
	cQuery += "      , @cCT1_ACET05 = CT1_ACET05 "
EndIf
If CT1->( FieldPos( "CT1_06OBRG" ) ) > 0
	cQuery += "      , @cCT1_06OBRG = CT1_06OBRG "
	cQuery += "      , @cCT1_ACET06 = CT1_ACET06 "
EndIf
If CT1->( FieldPos( "CT1_07OBRG" ) ) > 0
	cQuery += "      , @cCT1_07OBRG = CT1_07OBRG "
	cQuery += "      , @cCT1_ACET07 = CT1_ACET07 "
EndIf
If CT1->( FieldPos( "CT1_08OBRG" ) ) > 0
	cQuery += "      , @cCT1_08OBRG = CT1_08OBRG "
	cQuery += "      , @cCT1_ACET08 = CT1_ACET08 "
EndIf
If CT1->( FieldPos( "CT1_09OBRG" ) ) > 0
	cQuery += "      , @cCT1_09OBRG = CT1_09OBRG "
	cQuery += "      , @cCT1_ACET09 = CT1_ACET09 "
EndIf
cQuery += "      FROM "+RetSqlName("CT1")
cQuery += "      WHERE CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_CREDIT AND D_E_L_E_T_ = ' ' "+CRLF
//valida OBRIGATORIEDADE por plano de conta
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_CCOBRG = '1' AND @cCT2_CCC = ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ITOBRG = '1' AND @cCT2_ITEMC = ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_CLOBRG = '1' AND @cCT2_CLVLCR = ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
If lRet .AND. CT1->( FieldPos( "CT1_05OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC05CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_05OBRG = '1' AND @cCT2_EC05CR = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_06OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC06CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_06OBRG = '1' AND @cCT2_EC06CR = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_07OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC07CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_07OBRG = '1' AND @cCT2_EC07CR = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_08OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC08CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_08OBRG = '1' AND @cCT2_EC08CR = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_09OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC09CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_09OBRG = '1' AND @cCT2_EC09CR = ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
//valida OBRIGATORIEDADE por centro de custo
cQuery += "      Select @cCTT_ITOBRG = ' ' "+CRLF
cQuery += "      Select @cCTT_CLOBRG = ' ' "+CRLF
cQuery += "      Select @cCTT_ITOBRG = CTT_ITOBRG, @cCTT_CLOBRG = CTT_CLOBRG "
cQuery += "      FROM "+RetSqlName("CTT")
cQuery += "      WHERE CTT_FILIAL = @cFilCTT AND CTT_CUSTO = @cCT2_CCC AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCTT_ITOBRG = '1' AND @cCT2_ITEMC = ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCTT_CLOBRG = '1' AND @cCT2_CLVLCR = ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
//valida OBRIGATORIEDADE por item
cQuery += "      Select @cCTD_CLOBRG = ' ' "+CRLF
cQuery += "      Select @cCTD_CLOBRG = CTD_CLOBRG"
cQuery += "      FROM "+RetSqlName("CTD")
cQuery += "      WHERE CTD_FILIAL = @cFilCTD AND CTD_ITEM = @cCT2_ITEMC AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCTD_CLOBRG = '1' AND @cCT2_CLVLCR = ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
//Valida ACEITE por plano de contas
//cQuery += "      @cCT1_ACCUST = CT1_ACCUST, "
//cQuery += "      @cCT1_ACITEM = CT1_ACITEM, "
//cQuery += "      @cCT1_ACCLVL = CT1_ACCLVL, "

cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACCUST = '2' AND @cCT2_CCC != ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACITEM = '2' AND @cCT2_ITEMC != ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACCLVL = '2' AND @cCT2_CLVLCR != ' ' "+CRLF
cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
If lRet .AND. CT1->( FieldPos( "CT1_05OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC05CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACET05 = '2' AND @cCT2_EC05CR != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_06OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC06CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACET06 = '2' AND @cCT2_EC06CR != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_07OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC07CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACET07 = '2' AND @cCT2_EC07CR != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_08OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC08CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACET08 = '2' AND @cCT2_EC08CR != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
If lRet .AND. CT1->( FieldPos( "CT1_09OBRG" ) ) > 0 .And. CT2->( FieldPos("CT2_EC09CR") ) > 0
	cQuery += "      IF @cCT2_VLD24 = ' ' AND @cCT1_ACET09 = '2' AND @cCT2_EC09CR != ' ' "+CRLF
	cQuery += "        select @cCT2_VLD24 = '11' "+ CRLF
EndIf
cQuery += "   End "+ CRLF  //final do if obrigatoriedade/aceite

//UPDADE DOS CAMPOS CT2_VLDnn COM CONTEUDO DAS VARIAVEIS
If Alltrim(Upper(TcGetDb())) $ 'MSSQL7/ORACLE/DB2'
	cQuery += "   begin tran "+CRLF
EndIf
cQuery += "   UPDATE "+__cArq1+" SET "
For nX := 1 TO 25
	cQuery += "   	CT2_VLD"+StrZero(nX,2)+" = @cCT2_VLD"+StrZero(nX,2)+If(nX<25," , ", "  ")
Next
cQuery += "   WHERE "
cQuery += "   R_E_C_N_O_ = @iRecno "+CRLF
If Alltrim(Upper(TcGetDb())) $ 'MSSQL7/ORACLE/DB2'
	cQuery += "   commit tran"+CRLF
EndIf

//fetch
cQuery += "       Fetch cCursor into "+ cVarProc+ CRLF
//final do while
cQuery += " "+ CRLF
cQuery += "   End "+ CRLF   //final do while -- cursor

cQuery +="   Close cCursor "+CRLF
cQuery +="   deallocate cCursor "+CRLF

cQuery += "   select @OUT_RET = '1' " + CRLF

cQuery += " "+ CRLF
cQuery += "   End "+ CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert("Procedure Validacao linOK nao passou pelo Parse. "+cProcName+CRLF+MsParseError(),"Erro")  //"A query da filial nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProcName )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure [Validacao linOK] : "+cProcName,"Erro")  //"Erro na criacao da proc filial: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbPrepPrcºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara as variaveis para cursor e insert na CT2 a ser uti- º±±
±±º          ³lizado na procedure de validacao e gravacao CT2/CV3 e TRW   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbPrepPrc(cDeclare, cCpoCursor, cVarProc, cCposCT2, cVarCT2, lProc1,cVarIni)
Local nX
Local nLenCpos := Len(__aCampos)

DEFAULT cDeclare := ""
DEFAULT cCpoCursor := ""
DEFAULT cVarProc := ""
DEFAULT cCposCT2 := ""
DEFAULT cVarIni := ""
DEFAULT cVarCT2 := ""
DEFAULT lProc1 := .T.	

For nX := 1 To nLenCpos  //todos os campos contidos no array static __aCampos

	cDeclare+= "Declare "  //declaracao das variaveis a ser utilizada no curosr
	cVarIni += "Select "  
	If 	__aCampos[nX][2] == "C"
		cVarProc 	+= " @c"
		cDeclare 	+= " @c"+__aCampos[nX][1]+" char(" + Alltrim(STR(__aCampos[nX][3])) + ")" + CRLF
		cVarIni   += " @c"+__aCampos[nX][1]+ " = ' '" + CRLF
	Elseif 	__aCampos[nX][2] == "N"
		cVarProc 	+= " @n"
		cDeclare	+= " @n"+__aCampos[nX][1]+" float" + CRLF
		cVarIni 	+= " @n"+__aCampos[nX][1]+ " = 0" + CRLF
	Elseif 	__aCampos[nX][2] == "D"
		cVarProc 	+= " @c"
		cDeclare 	+= " @c"+__aCampos[nX][1]+" char(8)" + CRLF
		cVarIni 	+= " @c"+__aCampos[nX][1]+ " = ' '" + CRLF
	Else // logico "L"
		cVarProc 	+= " @l"
		cDeclare 	+= " @l"+__aCampos[nX][1]+" char(1)" + CRLF
		cVarIni 	+= " @l"+__aCampos[nX][1]+ " = '0'" + CRLF
	Endif
	
	cVarTipo := Right(cVarProc, 2)
	
	cCpoCursor	+= __aCampos[nX][1]+", "  //campos do cursor
	cVarProc 	+= __aCampos[nX][1]+", "  //variaveis do cursor mesmo nome do campo com @tipvar

	If CT2->(FieldPos(__aCampos[nX][1])) > 0
		cCposCT2 	+= __aCampos[nX][1]+", "
		cVarCT2	+= cVarTipo+__aCampos[nX][1]+","
	Endif		

Next nX

If lProc1
	cDeclare += " Declare @iRecno integer "
	cVarIni  += " Select @iRecno = 0 " + CRLF
Else
	cDeclare += " Declare @iRecCT2 integer "
EndIf

cCpoCursor += " R_E_C_N_O_ "
If lProc1
	cVarProc 	+= " @iRecno "
Else
	cVarProc 	+= " @iRecCT2 "
EndIf

cVarCT2	+= " @iRecno "
cCposCT2 	+= " R_E_C_N_O_ "

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbPrcAmarºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao da procedure para verificar se a contraregra esta   º±±
±±º          ³contido na regra quando parametro MV_CTBAMAR = 1 (PADRAO)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbPrcAmar( cProc, cProcRegra, cProcFil )
Local lRet := .T.
Local cRet := ""
Local cQuery := ""

DEFAULT cProc 		:= CriaTrab(,.F.)
DEFAULT cProcRegra 	:= CriaTrab(,.F.)

cQuery :="Create procedure "+cProc+"_"+cEmpAnt+CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_FILIAL        		Char("+Alltrim(Str(Len(CT1->CT1_FILIAL)))+"),"+CRLF
cQuery +="  @IN_CONTA        		Char("+Alltrim(Str(Len(CT1->CT1_CONTA)))+"),"+CRLF
cQuery +="  @IN_CUSTO        		Char("+Alltrim(Str(Len(CTT->CTT_CUSTO)))+"),"+CRLF
cQuery +="  @IN_ITEM        		Char("+Alltrim(Str(Len(CTD->CTD_ITEM)))+"),"+CRLF
cQuery +="  @IN_CLVL        		Char("+Alltrim(Str(Len(CTH->CTH_CLVL)))+"),"+CRLF
cQuery +="  @OUT_RET                Char(01) OutPut"+CRLF
cQuery +=" )"+CRLF
cQuery +=" as"+CRLF
cQuery +=" Declare @nContador 		Integer"+CRLF
cQuery +=" Declare @cAlias    		Char( 03 )"+CRLF
cQuery +=" Declare @nNivel    		Integer"+CRLF
cQuery +=" Declare @cRegra   		Char( "+Alltrim(Str(Len(CT1->CT1_RGNV1)))+" )"+CRLF
cQuery +=" Declare @cContraRegra  	Char( "+Alltrim(Str(Len(CTT->CTT_CRGNV1)))+" )"+CRLF
cQuery +=" Declare @OUT_AMAR    	Char( 1 )"+CRLF
cQuery +=" Declare @cFilCT1      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery +=" Declare @cFilCTT      	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery +=" Declare @cFilCTD     	Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery +=" Declare @cFilCTH    	   Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" )"+CRLF
cQuery +=" Declare @cAux    	   Char( 03 )"+CRLF

//inicio do processamento
cQuery += "Begin " + CRLF
cQuery += " " + CRLF
cQuery += "select @OUT_RET = '1' " + CRLF
cQuery += "select @OUT_AMAR = '1' " + CRLF
cQuery += "select @cAux  = 'CT1' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCT1 output " + CRLF
cQuery += "select @cAux  = 'CTT' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTT output " + CRLF
cQuery += "select @cAux  = 'CTD' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTD output " + CRLF
cQuery += "select @cAux  = 'CTH' " + CRLF
cQuery += "Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCTH output " + CRLF

//declaracao do cursor
cQuery += "Declare cCursor1  insensitive cursor for" + CRLF
cQuery += " "+ CRLF
cQuery +=" SELECT 'CT1' ALIAS,1 NIVEL, CT1_RGNV1 REGRA, CTT_CRGNV1 CONTRAREGRA FROM "+RetSqlName("CT1")+" CT101, "+RetSqlName("CTT")+" CTT  "+CRLF
cQuery +=" WHERE  "+CRLF
cQuery +="          CT1_FILIAL = @cFilCT1 "+CRLF
cQuery +=" AND      CT1_CONTA = @IN_CONTA "+CRLF
cQuery +=" AND      CT101.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" AND      CTT_FILIAL = @cFilCTT "+CRLF
cQuery +=" AND      CTT_CUSTO = @IN_CUSTO "+CRLF
cQuery +=" AND      CTT.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" UNION ALL "+CRLF
cQuery +=" SELECT 'CT1' ALIAS,2 NIVEL, CT1_RGNV2 REGRA, CTD_CRGNV1 CONTRAREGRA FROM "+RetSqlName("CT1")+" CT102, "+RetSqlName("CTD")+" CTD  "+CRLF
cQuery +=" WHERE  "+CRLF
cQuery +="          CT1_FILIAL = @cFilCT1 "+CRLF
cQuery +=" AND      CT1_CONTA = @IN_CONTA "+CRLF
cQuery +=" AND      CT102.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" AND      CTD_FILIAL = @cFilCTD "+CRLF
cQuery +=" AND      CTD_ITEM  = @IN_ITEM "+CRLF
cQuery +=" AND      CTD.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" UNION ALL "+CRLF
cQuery +=" SELECT 'CT1' ALIAS,3 NIVEL, CT1_RGNV3 REGRA, CTH_CRGNV1 CONTRAREGRA FROM "+RetSqlName("CT1")+" CT103, "+RetSqlName("CTH")+" CTH  "+CRLF
cQuery +=" WHERE  "+CRLF
cQuery +="          CT1_FILIAL = @cFilCT1 "+CRLF
cQuery +=" AND      CT1_CONTA = @IN_CONTA "+CRLF
cQuery +=" AND      CT103.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" AND      CTH_FILIAL = @cFilCTH "+CRLF
cQuery +=" AND      CTH_CLVL  = @IN_CLVL "+CRLF
cQuery +=" AND      CTH.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" UNION ALL "+CRLF
cQuery +=" SELECT 'CTT' ALIAS,2 NIVEL, CTT_RGNV2 REGRA, CTD_CRGNV2 CONTRAREGRA  FROM "+RetSqlName("CTT")+" CTT01,"+RetSqlName("CTD")+" CTD "+CRLF
cQuery +=" WHERE  "+CRLF
cQuery +="          CTT_FILIAL = @cFilCTT "+CRLF
cQuery +=" AND      CTT_CUSTO = @IN_CUSTO "+CRLF
cQuery +=" AND      CTT01.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" AND      CTD_FILIAL = @cFilCTD "+CRLF
cQuery +=" AND      CTD_ITEM  = @IN_ITEM "+CRLF
cQuery +=" AND      CTD.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" UNION ALL "+CRLF
cQuery +=" SELECT 'CTT' ALIAS,3 NIVEL, CTT_RGNV3 REGRA, CTH_CRGNV2 CONTRAREGRA  FROM "+RetSqlName("CTT")+" CTT02, "+RetSqlName("CTH")+" CTH "+CRLF
cQuery +=" WHERE  "+CRLF
cQuery +="          CTT_FILIAL = @cFilCTT "+CRLF
cQuery +=" AND      CTT_CUSTO = @IN_CUSTO "+CRLF
cQuery +=" AND      CTT02.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" AND      CTH_FILIAL = @cFilCTH "+CRLF
cQuery +=" AND      CTH_CLVL  = @IN_CLVL "+CRLF
cQuery +=" AND      CTH.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" UNION ALL "+CRLF
cQuery +=" SELECT 'CTD' ALIAS,3 NIVEL, CTD_RGNV3 REGRA, CTH_CRGNV3 CONTRAREGRA FROM "+RetSqlName("CTD")+" CTD, "+RetSqlName("CTH")+" CTH "+CRLF
cQuery +=" WHERE  "+CRLF
cQuery +="          CTD_FILIAL = @cFilCTD "+CRLF
cQuery +=" AND      CTD_ITEM = @IN_ITEM "+CRLF
cQuery +=" AND      CTD.D_E_L_E_T_ = ' ' "+CRLF
cQuery +=" AND      CTH_FILIAL = @cFilCTH "+CRLF
cQuery +=" AND      CTH_CLVL  = @IN_CLVL "+CRLF
cQuery +=" AND      CTH.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "FOR READ ONLY" + CRLF
cQuery += "Open cCursor1 "+ CRLF
cQuery += "Fetch cCursor1 into @cAlias, @nNivel, @cRegra, @cContraRegra" + CRLF

//laco do cursor
cQuery += "While (@@FETCH_STATUS = 0)  begin"+ CRLF
cQuery += "   IF @cRegra != ' ' AND @cContraRegra != ' ' begin "+ CRLF
cQuery += "      IF @cAlias = 'CT1' AND @nNivel = 1 AND @IN_CONTA != ' ' "+ CRLF
cQuery += "         EXEC "+cProcRegra+"_"+cEmpAnt+" @IN_CUSTO, @cRegra, @cContraRegra, @OUT_AMAR OutPut  "+ CRLF
cQuery += "      IF @cAlias = 'CT1' AND @nNivel = 2 AND @IN_CONTA != ' ' "+ CRLF
cQuery += "         EXEC "+cProcRegra+"_"+cEmpAnt+" @IN_ITEM, @cRegra, @cContraRegra, @OUT_AMAR OutPut  "+ CRLF
cQuery += "      IF @cAlias = 'CT1' AND @nNivel = 3 AND @IN_CONTA != ' ' "+ CRLF
cQuery += "         EXEC "+cProcRegra+"_"+cEmpAnt+" @IN_CLVL, @cRegra, @cContraRegra, @OUT_AMAR OutPut  "+ CRLF
cQuery += "      IF @cAlias = 'CTT' AND @nNivel = 2 AND @IN_CUSTO != ' ' "+ CRLF
cQuery += "         EXEC "+cProcRegra+"_"+cEmpAnt+" @IN_ITEM, @cRegra, @cContraRegra, @OUT_AMAR OutPut  "+ CRLF
cQuery += "      IF @cAlias = 'CTT' AND @nNivel = 3 AND @IN_CUSTO != ' ' "+ CRLF
cQuery += "         EXEC "+cProcRegra+"_"+cEmpAnt+" @IN_CLVL, @cRegra, @cContraRegra, @OUT_AMAR OutPut  "+ CRLF
cQuery += "      IF @cAlias = 'CTD' AND @nNivel = 3 AND @IN_ITEM != ' ' "+ CRLF
cQuery += "         EXEC "+cProcRegra+"_"+cEmpAnt+" @IN_CLVL, @cRegra, @cContraRegra, @OUT_AMAR OutPut  "+ CRLF
cQuery += "      IF @OUT_AMAR = '0' "+ CRLF
cQuery += "         BREAK "+ CRLF
cQuery += "   End "+ CRLF  //finaliza IF
cQuery += "   Fetch cCursor1 into @cAlias, @nNivel, @cRegra, @cContraRegra" + CRLF
cQuery += "End "+ CRLF  //finaliza While

cQuery +="   Close cCursor1 "+CRLF
cQuery +="   deallocate cCursor1 "+CRLF

cQuery += "select @OUT_RET = @OUT_AMAR " + CRLF

//finaliza begin inicial
cQuery += "End "+ CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert("Procedure Regra/ContraRegra nao passou pelo Parse. "+cProc+CRLF+MsParseError(), "Erro")  //"A query da filial nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure [REGRA/CONTRAREGRA]: "+cProc, "Erro")
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbPRegra ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao da procedure para verificar se a contraregra esta   º±±
±±º          ³contido na regra quando parametro MV_CTBAMAR = 1 (PADRAO)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbPRegra(cProc)
Local lRet := .T.
Local cRet := ""
Local cQuery := ""

DEFAULT cProc := CriaTrab(,.F.)

cQuery :="Create procedure "+cProc+"_"+cEmpAnt +CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_CODENTID        	Char("+Alltrim(Str(Len(CT1->CT1_CONTA)))+"),"+CRLF
cQuery +="  @IN_REGRA    			Char("+Alltrim(Str(Len(CT1->CT1_RGNV1)))+"),"+CRLF
cQuery +="  @IN_CONTRAREGRA    		Char("+Alltrim(Str(Len(CTT->CTT_CRGNV1)))+"),"+CRLF
cQuery +="  @OUT_RET                Char(01) OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF
cQuery +="Declare @cTem      Char( 01 )"+CRLF
cQuery +="Declare @cCodigo   VarChar( "+Alltrim(Str(Len(CTA->CTA_REGRA)))+" )"+CRLF
cQuery +="Declare @nContador Integer"+CRLF

cQuery +="begin"+CRLF
cQuery +="  Select @OUT_RET = '1' "+CRLF
cQuery +="  Select @cTem = '0' "+CRLF

cQuery +="  IF @IN_CODENTID != ' ' begin "+CRLF
cQuery +="      IF @IN_REGRA != ' ' AND @IN_CONTRAREGRA != ' ' begin "+CRLF
cQuery +="  	     Select @cTem = '0' "+CRLF
cQuery +="  	     Select @cCodigo	= '' "+CRLF
cQuery +="  	     Select @nContador = 1 "+CRLF
cQuery +="         WHILE @nContador <= LEN( @IN_CONTRAREGRA ) begin"+CRLF
cQuery +="            Select @cCodigo  = @cCodigo+Substring(@IN_CONTRAREGRA, @nContador,1) "+CRLF
cQuery +="            IF Substring(@IN_CONTRAREGRA, @nContador,1)='/' OR Substring(@IN_CONTRAREGRA, @nContador,1)=' ' begin"+CRLF
cQuery +="            		Select @cCodigo  = Substring(@cCodigo, 1,Len(@cCodigo)-1) "+CRLF
//se encontrou apenas espaco quebra laco
cQuery +="   				IF @cCodigo  = ' ' "+CRLF
cQuery +="         				BREAK "+CRLF
//pesquisar e verifica se encontra a  contra-regra contido na regra
cQuery +="   				IF CharIndex(@cCodigo, @IN_REGRA) > 0 "+CRLF //ORACLE OU DB2 INSTR( string, substring ) INSTR('Tech on the net', 'e')	would return 2; the first occurrence of 'e'
cQuery +="  	               Select @cTem = '1' "+CRLF
cQuery +="            End"+CRLF
cQuery +="  	        Select @nContador = @nContador + 1 "+CRLF
cQuery +="         End "+CRLF  //fim do while
cQuery +="   	     IF @cCodigo != ' ' AND CharIndex(@cCodigo, @IN_REGRA) > 0 "+CRLF
cQuery +="  	        Select @cTem = '1' "+CRLF
cQuery +="  	     "+CRLF
cQuery +="   	     IF @cTem = '1' "+CRLF
cQuery +="  	        Select @OUT_RET = '1' "+CRLF
cQuery +="  	     ELSE "+CRLF
cQuery +="  	        Select @OUT_RET = '0' "+CRLF
cQuery +="      End "+CRLF
cQuery +="  End "+CRLF

cQuery +="End "+CRLF

cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert("Procedure Regra/ContraRegra nao passou pelo Parse. "+cProc+CRLF+MsParseError(), "Erro")  //"A query da filial nao passou pelo Parse "
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure [Regra/ContraRegra]: "+cProc, "Erro")  //"Erro na criacao da proc filial: "
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtQryAmar2ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³query a ser incluida na procedure de validacao quando       º±±
±±º          ³parametro MV_CTBAMAR = 2                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtQryAmar2(cDebCred)
Local cQuery := ""
//PRIMEIRA QUERY
cQuery += " SELECT @nContador1 = COUNT(R_E_C_N_O_) "+CRLF
cQuery += " FROM "+RetSqlName("CTA")+CRLF
cQuery += " WHERE"+CRLF
cQuery += " CTA_FILIAL = '"+xFilial("CTA")+"' AND "+CRLF
cQuery += " CTA_ITREGR != ' ' AND "+CRLF
If cDebCred == "D"
	cQuery += " ( CTA_CONTA = ' ' OR CTA_CONTA = @cCT2_DEBITO ) AND "+CRLF
	cQuery += " ( CTA_CUSTO = ' ' OR CTA_CUSTO = @cCT2_CCD ) AND "+CRLF
	cQuery += " ( CTA_ITEM  = ' ' OR CTA_ITEM = @cCT2_ITEMD ) AND "+CRLF
	cQuery += " ( CTA_CLVL = ' ' OR CTA_CLVL = @cCT2_CLVLDB ) AND "+CRLF
	If CT2->( FieldPos("CT2_EC05DB") ) > 0
		cQuery += " ( CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC06DB") ) > 0
		cQuery += " ( CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC07DB") ) > 0
		cQuery += " ( CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC08DB") ) > 0
		cQuery += " ( CTA_ENTI08 = ' '  OR CTA_ENTI08 = @cCT2_EC08DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC09DB") ) > 0
		cQuery += " ( CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09DB )AND  "+CRLF
	EndIf
Else
	cQuery += " ( CTA_CONTA  = ' ' OR CTA_CONTA  = @cCT2_CREDIT ) AND  "+CRLF
	cQuery += " ( CTA_CUSTO  = ' ' OR CTA_CUSTO  = @cCT2_CCC ) AND  "+CRLF
	cQuery += " ( CTA_ITEM   = ' ' OR CTA_ITEM   = @cCT2_ITEMC ) AND  "+CRLF
	cQuery += " ( CTA_CLVL   = ' ' OR CTA_CLVL   = @cCT2_CLVLCR ) AND "+CRLF 
	If CT2->( FieldPos("CT2_EC05CR") ) > 0
		cQuery += " ( CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC06CR") ) > 0
		cQuery += " ( CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC07CR") ) > 0
		cQuery += " ( CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC08CR") ) > 0
		cQuery += " ( CTA_ENTI08 = ' ' OR CTA_ENTI08 = @cCT2_EC08CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC09CR") ) > 0
		cQuery += " ( CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09CR ) AND  "+CRLF
	EndIf
EndIf
cQuery += " D_E_L_E_T_ = ' '  "+CRLF

//SEGUNDA QUERY
cQuery += " SELECT @nContador = COUNT(R_E_C_N_O_) "+CRLF
cQuery += " FROM "+RetSqlName("CTA")+CRLF
cQuery += " WHERE"+CRLF
cQuery += " CTA_FILIAL = '"+xFilial("CTA")+"' AND "+CRLF
cQuery += " CTA_ITREGR != ' ' AND "+CRLF
If cDebCred == "D"
	cQuery += " ( @cCT2_DEBITO = ' ' OR CTA_CONTA = ' ' OR CTA_CONTA = @cCT2_DEBITO ) AND "+CRLF
	cQuery += " ( @cCT2_CCD = ' '  OR CTA_CUSTO = ' ' OR CTA_CUSTO = @cCT2_CCD ) AND "+CRLF
	cQuery += " ( @cCT2_ITEMD  = ' ' OR CTA_ITEM  = ' ' OR CTA_ITEM = @cCT2_ITEMD ) AND "+CRLF
	cQuery += " ( @cCT2_CLVLDB  = ' '  OR CTA_CLVL = ' ' OR CTA_CLVL = @cCT2_CLVLDB ) AND "+CRLF
	If CT2->( FieldPos("CT2_EC05DB") ) > 0
		cQuery += " ( @cCT2_EC05DB = ' ' OR CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC06DB") ) > 0
		cQuery += " ( @cCT2_EC06DB = ' ' OR CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC07DB") ) > 0
		cQuery += " ( @cCT2_EC07DB = ' ' OR CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC08DB") ) > 0
		cQuery += " ( @cCT2_EC08DB = ' ' OR CTA_ENTI08 = ' '  OR CTA_ENTI08 = @cCT2_EC08DB ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC09DB") ) > 0
		cQuery += " ( @cCT2_EC09DB = ' '  OR CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09DB )AND  "+CRLF
	EndIf
Else
	cQuery += " ( @cCT2_CREDIT = ' '  OR CTA_CONTA  = ' ' OR CTA_CONTA  = @cCT2_CREDIT ) AND  "+CRLF
	cQuery += " ( @cCT2_CCC = ' '  OR CTA_CUSTO  = ' ' OR CTA_CUSTO  = @cCT2_CCC ) AND  "+CRLF
	cQuery += " ( @cCT2_ITEMC  = ' ' OR CTA_ITEM   = ' ' OR CTA_ITEM   = @cCT2_ITEMC ) AND  "+CRLF
	cQuery += " ( @cCT2_CLVLCR  = ' ' OR CTA_CLVL   = ' ' OR CTA_CLVL   = @cCT2_CLVLCR ) AND "+CRLF 
	If CT2->( FieldPos("CT2_EC05CR") ) > 0
		cQuery += " ( @cCT2_EC05CR = ' ' OR CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC06CR") ) > 0
		cQuery += " ( @cCT2_EC06CR = ' ' OR CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC07CR") ) > 0
		cQuery += " ( @cCT2_EC07CR = ' ' OR CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC08CR") ) > 0
		cQuery += " ( @cCT2_EC08CR = ' ' OR CTA_ENTI08 = ' ' OR CTA_ENTI08 = @cCT2_EC08CR ) AND  "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC09CR") ) > 0
		cQuery += " ( @cCT2_EC09CR = ' ' OR CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09CR ) AND  "+CRLF
	EndIf
EndIf

cQuery += " D_E_L_E_T_ = ' '  "+CRLF

Return(cQuery)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtQryAmar3ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³query a ser incluida na procedure de validacao quando       º±±
±±º          ³parametro MV_CTBAMAR = 3                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtQryAmar3(cDebCred)

Local cQuery := ""

cQuery += " SELECT @nContador = COUNT( R_E_C_N_O_ )"+CRLF
cQuery += " FROM "+RetSqlName("CTA") +CRLF
cQuery += " WHERE"+CRLF
cQuery += " CTA_FILIAL = '"+xFilial("CTA")+"' AND "+CRLF

If cDebCred == "D"
	cQuery  += " CTA_CONTA = @cCT2_DEBITO AND "+CRLF
	cQuery  += " CTA_CUSTO = @cCT2_CCD AND "+CRLF
	cQuery  += " CTA_ITEM = @cCT2_ITEMD AND "+CRLF
	cQuery  += " CTA_CLVL = @cCT2_CLVLDB AND "+CRLF
	If CT2->( FieldPos("CT2_EC05DB") ) > 0 
		cQuery  += " CTA_ENTI05 = @cCT2_EC05DB AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC06DB") ) > 0
		cQuery  += " CTA_ENTI06 = @cCT2_EC06DB AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC07DB") ) > 0
		cQuery  += " CTA_ENTI07 = @cCT2_EC07DB AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC08DB") ) > 0
		cQuery  += " CTA_ENTI08 = @cCT2_EC08DB AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC09DB") ) > 0
		cQuery  += " CTA_ENTI09 = @cCT2_EC09DB AND "+CRLF
	EndIf
Else
	cQuery  += " CTA_CONTA = @cCT2_CREDIT AND "+CRLF
	cQuery  += " CTA_CUSTO = @cCT2_CCC AND "+CRLF
	cQuery  += " CTA_ITEM  = @cCT2_ITEMC AND "+CRLF
	cQuery  += " CTA_CLVL  = @cCT2_CLVLCR AND "+CRLF
	If CT2->( FieldPos("CT2_EC05CR") ) > 0
		cQuery  += " CTA_ENTI05 = @cCT2_EC05CR AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC06CR") ) > 0
		cQuery  += " CTA_ENTI06 = @cCT2_EC06CR AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC07CR") ) > 0
		cQuery  += " CTA_ENTI07 = @cCT2_EC07CR AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC08CR") ) > 0
		cQuery  += " CTA_ENTI08 = @cCT2_EC08CR AND "+CRLF
	EndIf
	If CT2->( FieldPos("CT2_EC09CR") ) > 0
		cQuery  += " CTA_ENTI09 = @cCT2_EC09CR AND "+CRLF
	EndIf
EndIf

cQuery += " D_E_L_E_T_ = ' ' " + CRLF

Return(cQuery)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtdbAppendºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui registros na tabela TMP - Quando criada no banco     º±±
±±º          ³tem que utilizar RecLock para gravar recno no banco pois    º±±
±±º          ³este sera usada na procedure de gravacao da CT2             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtdbAppend()
If ! CtbVerTmpBD()
	dbAppend()
Else
	RecLock("TMP", .T.)
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbIniLan ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa variaveis para contabilizao com criacao de arq.  º±±
±±º          ³TMP no banco e cria as procedures de validacao e            º±±
±±º          ³gravacao CT2/CV3/TRW.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbIniLan()
Local lRet := .T.
Local cSqlCtbZERO
/* tirado o DB2, pois qdo existe contb de mais de uma filial o DbAccess ;
   não limpa a tabela TMP do banco mesmo com dbgottom, dbgotop, tcrefresh*/
/*   
Local lUseProc    := SuperGetMv( "MV_CTBUPRC" , .T. , .F. ) .and.;       //Criar TMP de contabilização no BD
                    (Alltrim(Upper(TCGetDB()))$ "MSSQL7|ORACLE" ) .and.; //Sqlserver Ou Oracle
                    !(IIF(GETMV("MV_ALTLCTO") == "S",.T.,.F.))           // se altera Lancto, faz pelo padrão 
*/
Local lUseProc    := .F. //MANTER FALSO ATE VALIDAR AS PROCEDURES NA VERSAO 12.1.16
                    
                    
Local cPeCT105CT2 :="CT105CT2"  //Nome do pto de entrada na procedure 
Local cPeCTBGRV   :="CTBGRV"    //Nome do pto de entrada na procedure
If lUseProc 
	//criar variavel private
	//Private aAltera := {} 	//usado na contabilizacao - deve ser declarado antes de criar tmp no banco
	//Private aHeader	:= {} 	//usado na contabilizacao - deve ser declarado antes de criar tmp no banco
	//Private aErro	:= {} 	//usado na contabilizacao - deve ser declarado antes de criar tmp no banco
	_SetNamedPrvt("aAltera",{}, If( Alltrim(FunName()) == "RPC",PROCNAME(1),FunName() ) )
	_SetNamedPrvt("aHeader",{}, If( Alltrim(FunName()) == "RPC",PROCNAME(1),FunName() ) )
	_SetNamedPrvt("aErro",{}, If( Alltrim(FunName()) == "RPC",PROCNAME(1),FunName() ) )
	
	CtbSetTmpB(.T.)          	//Seta a variavel static para criar tabela tmp no banco
	
	CtbCrTmpBD()			//cria a tabeça temporaria (tela de contabilizacao) no banco
	
	//declarar variaveis staticas
	__cProcAmar := NIL
	__cProcRegra := NIL	
	__cProcPai := NIL
	__cProcFil := NIL		
	        //PROCEDURE XFILIAL - No recálculo tem a opção de varias filiais.
	lRet := CtbPFilial(@__cProcFil) 
	If lRet	        
	        //PROCEDURE VERIFICA SE A REGRA ESTA CONTIDA NA CONTRA-REGRA
		lRet := CtbPRegra(@__cProcRegra)
	EndIf
	If lRet
		//PROCEDURE CTBAMARRA REGRA X CONTRAREGRA
		lRet := CtbPrcAmar( @__cProcAmar, __cProcRegra, __cProcFil )
	EndIf
				
	If lRet
		//PROCEDURE LINHA OK PARA VALIDAR TODO TMP CRIADO NO BANCO
		lRet := Ct105LOKPr(@__cProcPai, @__cProcAmar, __cProcFil )
	EndIf
	
	If lRet
		__cProcZero := CriaTrab(,.F.)
		cSqlCtbZERO := ProcSTRZERO(__cProcZero)
		
		If !TCSPExist( __cProcZero )
			cRet := TcSqlExec(cSqlCtbZERO)
			If cRet <> 0
				If !__lBlind
					MsgAlert("Erro na criacao da procedure CtbZero[StrZero] : "+cNomProcZero,"Erro") 
					lRet:= .F.
				EndIf
			Else
				If __cProcSoma1 == NIL
					__cProcSoma1 := CriaTrab(,.F.)
				Endif
				lRet := CTM300SOMA( __cProcSoma1 , __cProcZero+"_"+cEmpAnt )
			EndIf
		EndIf
	
	EndIf
	
	If lRet
	
		//PROCEDURE GRAVACAO DA CT2 BASEADO NO TMP CRIADO NO BANCO
		If ( lRet := Ct105Doc(@__cProcDoc) )
			/* Criar pontos de entrada CT105CT2 e CTBGRV */
			
			lRet := Ct105105CT2(cPeCT105CT2)  // PE CT105CT2
			lRet := Ct105CTBGRV(cPeCTBGRV)    // PE CTBGRV
			lRet := Ct105PrGrv(@__cProcGrv, __cProcZero,cPeCT105CT2, cPeCTBGRV, __cProcFil )
		Endif
	EndIf
	
	If !lRet
		CtbSetTmpB(.F.)          	//Seta a variavel static para criar tabela tmp no banco
	EndIf
	/* no FINA370 , já existe um alias chamado TMP, então mudo de TMP PARA "TMP_CTB"*/
	DbChangeAlias("TMP","TMP_CTB")
Else
	//QUANDO ROTINA DE CONTABILIZACAO OFF-LINE ESTA COM CTBINILAN() CRIA TMP NO SYSTEM 
	_SetNamedPrvt("aAltera",{}, If( Alltrim(FunName()) == "RPC",PROCNAME(1),FunName() ) )
	_SetNamedPrvt("aHeader",{}, If( Alltrim(FunName()) == "RPC",PROCNAME(1),FunName() ) )
	_SetNamedPrvt("aErro",{}, If( Alltrim(FunName()) == "RPC",PROCNAME(1),FunName() ) )
	
	CtbSetTmpB(.F.)          	//FALSE - Seta a variavel static para criar tabela tmp no SYSTEM
	
	CtbCrTmpBD()			//cria a tabeça temporaria (tela de contabilizacao) no SYSTEM
	
	__lTmp_Zap := .T.

	//Incluir na funcao CtbIniLan
	If _lProcPsqCT2 == NIl
	
		_PrCT2Psq := CriaTrab(,.F.)	
		_lProcPsqCT2 := CtPrCT2Psq( @_PrCT2Psq )
		
	EndIf 

EndIf

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbFinLan ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Finalizacao de contabilizao - exlui o arquivo tmp criado    º±±
±±º          ³no banco e as procedures de validacao e gravacao CT2/CV3/TRWº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbFinLan()
/* tirado o DB2, pois qdo existe contb de mais de uma filial o DbAccess ;
   não limpa a tabela TMP do banco mesmo com dbgottom, dbgotop, tcrefresh*/
/*   
Local lUseProc    := SuperGetMv( "MV_CTBUPRC" , .T. , .F. ) .and.;       //Criar TMP de contabilização no BD
                    (Alltrim(Upper(TCGetDB()))$ "MSSQL7|ORACLE" ) .and.; //Sqlserver Ou Oracle
                    !(IIF(GETMV("MV_ALTLCTO") == "S",.T.,.F.))           // se altera Lancto, faz pelo padrão 
*/
Local lUseProc    := .F. //MANTER FALSO ATE VALIDAR AS PROCEDURES NA VERSAO 12.1.16
                    
If lUseProc 

	CtbSetTmpB(.F.)          	//Seta a variavel static para NAO criar tabela tmp no banco
	CtbDelTmpBD()				//exclui tabela temporaria (tela de contabilizacao) no banco
	CtbDelProc()				//exclui tabela temporaria (tela de contabilizacao) no banco
	
Else
	
	If __lTmp_Zap
	
		CtbSetTmpB(.F.)          	//Seta a variavel static para NAO criar tabela tmp no banco
		CtbDel_Tmp()				//exclui tabela temporaria (tela de contabilizacao)
		
		__lTmp_Zap   := .F.         //seta a variavel para criar tabela temporaria a cada chamada do ca100Incl (padrao)
		
	EndIf
	
EndIf

//retorna as variaveis staticas ao seu valor original
__cArq1			:= ""
__cArq2			:= ""
__cProcAmar 	:= NIL
__cProcRegra 	:= NIL	
__cProcPai 		:= NIL		
__cProcGrv   	:= NIL
__cProcZero  	:= NIL
__cProcDoc  	:= NIL

_lProcPsqCT2 := NIl
_PrCT2Psq := NIL  


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct105PrGrvºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao da procedure para gravacao dos movimentos contabeis º±±
±±º          ³CT2/CV3 e TRW para atualizacao dos saldos e chamada da      º±±
±±º          ³multithread para execucao da procedure                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ct105PrGrv( cProcName, cProcCtbZero, cPeCT105CT2, cPeCTBGRV, cProcFil )
Local lRet     := .T.
Local cProcCTB := ""
Local nX
Local nPosHora 		:= CT2->( FieldPos( 'CT2_HORALC' ) )
Local lControlSD	:= CT2->( FieldPos( 'CT2_CTRLSD' ) ) > 0
Local lCTxTABORI	:= CV3->( FieldPos( "CV3_TABORI" )) > 0 .and. CTK->(FieldPos("CTK_TABORI") > 0)
Local lCTxRECORI 	:= CV3->(FieldPos("CV3_RECORI")) > 0 .and. CTK->(FieldPos("CTK_RECORI") > 0)
Local lCTxRECDES 	:= CV3->(FieldPos("CV3_RECDES")) > 0 .and. CTK->(FieldPos("CTK_RECDES") > 0)
Local lMudaTRT 		:= SuperGetMV("MV_MUDATRT",.F.,.T.)
Local cTabTRW 		:= "TRW"+SM0->M0_CODIGO+"0"+Iif(lMudaTRT, "_SP", "")
Local lCubo 		:= IIf(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )
Local cDBType		:= Alltrim(Upper(TCGetDB()))
Local nPTratRec		:= 0
Local cTamDOC 		:= STR(TamSx3("CT2_DOC")[1])
Local cDeclare  	:= ""
Local cCpoCursor 	:= ""
Local cVarProc   	:= ""
Local cCamposProc   := ""
Local cVarGrvCps	:= ""
Local cProcDocAux   := __cProcDoc+"_"+cEmpAnt
Local lExistTRW   := TcCanOpen(cTabTRW)
Local lCommit     := If(Upper(Alltrim(TcGetDb())) == 'INFORMIX', .F., .T.)

DEFAULT cProcName 	:= CriaTrab(,.F.)

//variaveis para declarar na procedure e utilizacao no cursor 
CtbPrepPrc( @cDeclare, @cCpoCursor, @cVarProc, @cCamposProc, @cVarGrvCps, .F. )


cProcCTB	+= "CREATE PROCEDURE "+cProcName+"_"+cEmpAnt+" "+CRLF
cProcCTB	+= " ( "+ CRLF
cProcCTB	+= "   @IN_cDataLanc 			char(8), "+ CRLF
cProcCTB	+= "   @IN_cLote               char("+STR(TamSx3("CT2_LOTE")[1])+"),  "+ CRLF
cProcCTB	+= "   @IN_cSubLote            char("+STR(TamSx3("CT2_SBLOTE")[1])+"), "+ CRLF
cProcCTB	+= "   @IN_cDoc                char("+cTamDOC+"), "+ CRLF
cProcCTB	+= "   @IN_cFilOri             char("+STR(TamSx3("CT2_FILORI")[1])+"),  "+ CRLF
cProcCTB	+= "   @IN_cEmpOri             char("+STR(TamSx3("CT2_EMPORI")[1])+"),  "+ CRLF
cProcCTB	+= "   @IN_cSequenc            char("+STR(TamSx3("CT2_SEQUEN")[1])+"),  "+ CRLF
cProcCTB	+= "   @IN_lAglut              char(1), "+ CRLF
cProcCTB	+= "   @IN_cProg	             char("+STR(TamSx3("CT2_ROTINA")[1])+"),  "+ CRLF
cProcCTB	+= "   @IN_cSeqLan             char("+STR(TamSx3("CT2_SEQLAN")[1])+"),  "+ CRLF
cProcCTB	+= "   @IN_lSeqCorr            char(1),  "+ CRLF
cProcCTB	+= "   @IN_cSeqCorr            char("+STR(TamSx3("CT2_NODIA")[1])+"),  "+ CRLF
cProcCTB	+= "   @IN_lCusto              char(1), "+ CRLF
cProcCTB	+= "   @IN_lItem               char(1), "+ CRLF
cProcCTB	+= "   @IN_lCLVL               char(1), "+ CRLF
cProcCTB	+= "   @IN_nPosHora            integer,  "+ CRLF
cProcCTB	+= "   @IN_nMoedas             integer, "+ CRLF
cProcCTB	+= "   @IN_cFilialCT2       	char("+STR(TamSx3("CT2_FILIAL")[1])+"), "+ CRLF
cProcCTB	+= "   @IN_cHoraLc             char(8), "+ CRLF
cProcCTB	+= "   @IN_cManual             char(1), "+ CRLF
cProcCTB	+= "   @IN_lCTBA101            char(1), "+ CRLF
cProcCTB	+= "   @IN_lCT2_DIACTB         char(1), "+ CRLF
cProcCTB	+= "   @IN_lCT2_MLTSLD         char(1), "+ CRLF
cProcCTB	+= "   @IN_lCT2_CTLSLD         char(1), "+ CRLF
cProcCTB	+= "   @IN_lGrvTRW	            char(1), "+ CRLF
cProcCTB	+= "   @IN_cPreLcto         	varchar(1), "+ CRLF
cProcCTB	+= "   @IN_ThreadID            char("+STR(TAMSX3("CT2_ATIVDE")[1])+")," + CRLF
cProcCTB	+= "   @IN_LSIMULA             Char( 01 )," + CRLF
cProcCTB	+= "   @IN_TOTINF              float," + CRLF
cProcCTB	+= "   @IN_LATUBASE            Char( 01 )," + CRLF
cProcCTB	+= "   @IN_LREPROC             Char( 01 )," + CRLF
cProcCTB	+= "   @IN_NOPC                Integer," + CRLF
cProcCTB	+= "   @IN_FILIAL              char("+STR(TamSx3("CT2_FILORI")[1])+"),  "+ CRLF
cProcCTB	+= "   @OUT_RET                char(1) output" + CRLF
cProcCTB	+= " ) "+CRLF
 cProcCTB	+= " as "+ CRLF
	
cProcCTB	+= "   "+ CRLF
cProcCTB	+= "Declare @nContador       integer "+ CRLF
cProcCTB	+= "Declare @cMoeda	         char(2) "+ CRLF
cProcCTB	+= "Declare @nValor	         float "+ CRLF
cProcCTB	+= "Declare @iNroRegs        integer "+ CRLF
cProcCTB	+= "Declare @cKey            varchar("+STR(TamSx3("CT2_KEY")[1])+") "+ CRLF
cProcCTB	+= "Declare @cAglut          char(1) "+ CRLF
cProcCTB	+= "Declare @iRecno	         integer "+ CRLF
cProcCTB	+= "Declare @iRecCV3         integer "+ CRLF
cProcCTB	+= "Declare @iRecTRW         integer "+ CRLF
cProcCTB	+= "Declare @nSeqHis         integer "+ CRLF
cProcCTB	+= "Declare @cNewSeq         char(3) "+ CRLF
cProcCTB	+= "Declare @lContinua       char(1) "+ CRLF

If ( nPosHora == 0 )
	cProcCTB	+= "Declare @cCT2_HORALC char(5)"+ CRLF
Endif
If ! ( "@nCT2_VALR06" $ cDeclare )
	cProcCTB	+= "Declare @nCT2_VALR06 float"+ CRLF
EndIf
If ! ( "@nCT2_VALR07" $ cDeclare )
	cProcCTB	+= "Declare @nCT2_VALR07 float"+ CRLF
EndIf
If ! ( "@nCT2_VALR08" $ cDeclare )
	cProcCTB	+= "Declare @nCT2_VALR08 float"+ CRLF
EndIf
If ! ( "@nCT2_VALR09" $ cDeclare )
	cProcCTB	+= "Declare @nCT2_VALR09 float"+ CRLF
EndIf
If ! ( "@nCT2_VALR10" $ cDeclare )
	cProcCTB	+= "Declare @nCT2_VALR10 float"+ CRLF
EndIf
If ! ( "@nCT2_VALR11" $ cDeclare )
	cProcCTB	+= "Declare @nCT2_VALR11 float"+ CRLF
EndIf
If ! ( "@nCT2_VALR12" $ cDeclare )
	cProcCTB	+= "Declare @nCT2_VALR12 float"+ CRLF
EndIf

cProcCTB	+= "Declare @lOutrMoeda      char(1)" + CRLF
cProcCTB	+= "Declare @CTK_DATA        char(8)" + CRLF
cProcCTB	+= "Declare @lNoMltSld		 char(1)" + CRLF
cProcCTB	+= "Declare @cTipoOri		 char(1)" + CRLF
cProcCTB	+= "Declare @cPoint			 char(1)" + CRLF
cProcCTB	+= "Declare @cChar       	 varchar( 01 )" +CRLF
cProcCTB	+= "Declare @cMltSldAux    	 varchar( 20 )" +CRLF
cProcCTB	+= "Declare @CTK_SEQUEN      char("+STR(TamSx3("CTK_SEQUEN")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_DC          varchar("+STR(TamSx3("CTK_DC")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_LP          varchar("+STR(TamSx3("CTK_LP")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_LPSEQ       varchar("+STR(TamSx3("CTK_LPSEQ")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_KEY         varchar("+STR(TamSx3("CTK_KEY")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_DEBITO      varchar("+STR(TamSx3("CTK_DEBITO")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_CREDIT      varchar("+STR(TamSx3("CTK_CREDIT")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_VLR01       float" + CRLF
cProcCTB	+= "Declare @CTK_VLR02       float" + CRLF
cProcCTB	+= "Declare @CTK_VLR03       float" + CRLF
cProcCTB	+= "Declare @CTK_VLR04       float" + CRLF
cProcCTB	+= "Declare @CTK_VLR05       float" + CRLF
cProcCTB	+= "Declare @iX		 		 integer" + CRLF
cProcCTB	+= "Declare @nPosition 		 Integer" + CRLF
cProcCTB	+= "Declare @CTK_HIST        varchar("+STR(TamSx3("CTK_HIST")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_CCC         varchar("+STR(TamSx3("CTK_CCC")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_CCD         varchar("+STR(TamSx3("CTK_CCD")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_ITEMC       varchar("+STR(TamSx3("CTK_ITEMC")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_ITEMD       varchar("+STR(TamSx3("CTK_ITEMD")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_CLVLDB      varchar("+STR(TamSx3("CTK_CLVLDB")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_CLVLCR      varchar("+STR(TamSx3("CTK_CLVLCR")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_MOEDLC      varchar("+STR(TamSx3("CTK_MOEDLC")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_TABORI      varchar("+STR(TamSx3("CTK_TABORI")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_RECORI      varchar("+STR(TamSx3("CTK_RECORI")[1])+")" + CRLF
cProcCTB	+= "Declare @CTK_RECDES      varchar("+STR(TamSx3("CTK_RECDES")[1])+")" + CRLF
cProcCTB	+= "Declare @cCT2LinAux      char( "+Str(LEN(CT2->CT2_LINHA))+"  )" + CRLF
cProcCTB	+= "Declare @cSeqLan         char("+STR(TamSx3("CT2_SEQLAN")[1])+")"+ CRLF
cProcCTB	+= "Declare @iAux            integer"+ CRLF
cProcCTB	+= "Declare @cAux            CHAR( 03 )"+ CRLF
cProcCTB	+= "Declare @cFilCV3         char("+STR(TamSx3("CT2_FILIAL")[1])+") "+ CRLF

cProcCTB	+= cDeclare + CRLF
cProcCTB	+= "Begin " + CRLF
cProcCTB	+= "   " + CRLF
cProcCTB	+= "   Select @cAux = 'CV3'" + CRLF
cProcCTB   += "   Exec "+cProcFil+"_"+cEmpAnt+" @cAux , @IN_FILIAL, @cFilCV3 output " + CRLF

cProcCTB	+= "   Select @cSeqLan = @IN_cSeqLan"+ CRLF
cProcCTB	+= "   Select @iAux = "+STR(TamSx3("CT2_SEQUEN")[1])+" "+ CRLF

cProcCTB	+= "   If @IN_cPreLcto = 'S' begin " + CRLF
cProcCTB	+= "   	  UPDATE "+__cArq1+" SET CT2_TPSALD = '9' " + CRLF
cProcCTB	+= "   End " + CRLF
cProcCTB	+= "   select @OUT_RET = '0' " + CRLF
cProcCTB	+= "   select @nContador = 1 " + CRLF
cProcCTB	+= "   select @cTipoOri  = ' ' " + CRLF
cProcCTB	+= "   select @iNroRegs = 0 " + CRLF
cProcCTB	+= "   " + CRLF
cProcCTB	+= "   If @IN_lAglut='1' select @cAglut = '1' " + CRLF
cProcCTB	+= "   Else select @cAglut = '2' " + CRLF
cProcCTB	+= "   " + CRLF

cProcCTB	+= "   Declare cCursorCTB  insensitive cursor for" + CRLF
cProcCTB	+= "   "+ CRLF
cProcCTB	+= "   SELECT "+cCpoCursor+" FROM "+__cArq1+ CRLF
cProcCTB	+= "   "+ CRLF
cProcCTB	+= "   FOR READ ONLY" + CRLF
cProcCTB	+= "   Open cCursorCTB "+ CRLF
cProcCTB	+= "   Fetch cCursorCTB into "+ cVarProc+ CRLF
cProcCTB	+= "   While (@@FETCH_STATUS = 0) begin "+ CRLF
cProcCTB	+= "   "+ CRLF

// COMEÇA AQUI A VALIDAÇÃO DO CAMPO CT2_MLTSLD
// NA TEORIA A VARIAVEL @cCT2_MLTSLD JÁ DEVE ESTAR DELCARADA
// NA VARIAVEL STATIC cDECLARE

// DEVEMOS TRATAR AINDA ALGUM OUTRO CAMPO NA CT5 QUE IDENTIFIQUE A DUPLICAÇÃO DO LP - CT5_CTRLSD (updctb).
// NOVOS CAMPOS PARA ESTE CONTROLE:
// CT2_CTRLSD, CT5_CTRLSD e CTK_CTRLSD (CONTROLA SALDO?) 1 = SIM / 0 = NÃO

If lControlSD

	cProcCTB	+= "      select @cMltSldAux  = @cCT2_TPSALD " + CRLF
	cProcCTB	+= "      select @cTipoOri = @cCT2_TPSALD "+CRLF
	cProcCTB	+= "      select @iX = 1"+CRLF
	cProcCTB	+= "      "+ CRLF	
	cProcCTB	+= "      If @cCT2_TPSALD != '9' "+ CRLF	
	cProcCTB	+= "         ##FIELDP01( 'CT2.CT2_CTRLSD' )"+ CRLF	
	cProcCTB	+= "           AND @cCT2_CTRLSD = '1' "+ CRLF	
	cProcCTB	+= "         ##ENDFIELDP01"+ CRLF	
	cProcCTB	+= "         begin" +CRLF
	cProcCTB	+= "     	   " +CRLF
	cProcCTB 	+= "     	   While @iX <= Len( @cCT2_MLTSLD ) begin"+CRLF
	cProcCTB 	+= "            select @cChar = ''"+CRLF
	cProcCTB 	+= "            select @cChar = SubString( @cCT2_MLTSLD, @iX, 1 )"+CRLF
	cProcCTB 	+= "            If @cChar in ( ';',',', '/','|', ' ','9','0') or @cChar = @cCT2_TPSALD  begin"+CRLF
	cProcCTB 	+= "                 Select @cChar = ''"+CRLF
	cProcCTB 	+= "            End"+CRLF
	cProcCTB 	+= "            select @cMltSldAux = (@cMltSldAux || @cChar)"+CRLF
	cProcCTB 	+= "            select @iX = @iX + 1"+CRLF
	cProcCTB 	+= "         End"+CRLF
	cProcCTB	+= "         select @cPoint = SUBSTRING( @cCT2_MLTSLD , 2 , 1 )"+CRLF
	cProcCTB	+= "         If (@cPoint = ';') AND (@cCT2_CTRLSD = '1') begin"+CRLF
	cProcCTB	+= "            select @lNoMltSld = '1' "+CRLF
	cProcCTB	+= "         end"+CRLF
	cProcCTB 	+= "      end"+CRLF
	cProcCTB	+= "      select @iX = 1"+CRLF
	cProcCTB	+= "      select @nPosition = 1 " + CRLF
	cProcCTB 	+= "      "+CRLF
	cProcCTB	+= "  	  While @iX <= Len( @cMltSldAux ) begin"+CRLF   // OR (@lNoMltSld = '0')
	cProcCTB	+= "         select @cCT2_TPSALD = SUBSTRING(@cMltSldAux, @nPosition , 1)"+CRLF
	cProcCTB	+= "         select @nPosition = @nPosition + 1 "+CRLF
	cProcCTB 	+= "         select @iX = @iX + 1"+CRLF
	cProcCTB	+= "         If @cCT2_TPSALD = ' ' break" + CRLF
Endif

cProcCTB	+= "         select @lOutrMoeda = '0' "+ CRLF

For nx:=2 to __nQuantas
	cProcCTB	+= "         If @nCT2_VALR"+STRZERO(nx,2)+" > 0	select @lOutrMoeda = '1' "+ CRLF
Next nX

cProcCTB	+= "         select @nContador = 1 "+ CRLF
cProcCTB	+= "         select @cMoeda = '  ' "+ CRLF
cProcCTB	+= "         "+ CRLF
cProcCTB	+= "         While @IN_nMoedas >= @nContador begin "+ CRLF
cProcCTB	+= "            "+ CRLF
cProcCTB	+= "		      select @lContinua = 1 " + CRLF
cProcCTB	+= "		      exec "+ cProcCtbZero+"_"+cEmpAnt+" @nContador , 2 , @cMoeda output "+ CRLF
cProcCTB	+= "		      If @cMoeda = '01' select @nValor = @nCT2_VALOR "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '02' select @nValor = @nCT2_VALR02 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '03' select @nValor = @nCT2_VALR03 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '04' select @nValor = @nCT2_VALR04 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '05' select @nValor = @nCT2_VALR05 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '06' select @nValor = @nCT2_VALR06 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '07' select @nValor = @nCT2_VALR07 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '08' select @nValor = @nCT2_VALR08 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '09' select @nValor = @nCT2_VALR09 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '10' select @nValor = @nCT2_VALR10 "+ CRLF
cProcCTB	+= "		      Else If @cMoeda = '11' select @nValor = @nCT2_VALR11 "+ CRLF
cProcCTB	+= "		      Else select @nValor = @nCT2_VALR12 "+ CRLF
cProcCTB	+= "		      "+ CRLF
cProcCTB	+= "		      If (@lCT2_FLAG = 'T') OR ( @cMoeda <> '01' And @cCT2_DC = '4') OR (@cCT2_DC != '4' And @nValor <= 0 And ( @cMoeda <> '01' Or (@cMoeda = '01' And @lOutrMoeda = '0' ))) begin "+ CRLF
cProcCTB	+= "		         select @lContinua = 0 "+ CRLF
cProcCTB	+= "		      End"+ CRLF
cProcCTB	+= "		      "+ CRLF
cProcCTB	+= "		      If @lContinua = 1 begin " + CRLF
cProcCTB	+= "		         If @IN_cManual = '2' select @cKey = @cCT2_KEY "+ CRLF
cProcCTB	+= "		         Else select @cKey = ' ' "+ CRLF
cProcCTB	+= "		         "+ CRLF
cProcCTB	+= "		         If @cMoeda = '01' begin "+ CRLF
//PEGAR A ULTIMA LINHA DO DOCUMENTO JA GRAVADA----------------------------------------------------------------------------------------------------
cProcCTB	+= "		            select @cCT2LinAux = IsNull(Max( CT2_LINHA ), '"+StrZero(0,LEN(CT2->CT2_LINHA))+"'  ) " + CRLF
cProcCTB	+= "		              from "+RetSqlName("CT2") +  CRLF
cProcCTB	+= "		             where CT2_FILIAL =  @IN_cFilialCT2"+ CRLF
cProcCTB	+= "		               AND CT2_DATA   = @IN_cDataLanc"+ CRLF
cProcCTB	+= "                       AND CT2_LOTE   = @IN_cLote "+ CRLF
cProcCTB	+= "                       AND CT2_SBLOTE = @IN_cSubLote"+ CRLF
cProcCTB	+= "                       AND CT2_DOC    = @IN_cDoc"+ CRLF
cProcCTB	+= "                       AND CT2_FILORI = @IN_cFilOri"+ CRLF
cProcCTB	+= "                       AND CT2_EMPORI = @IN_cEmpOri"+ CRLF
cProcCTB	+= "                       AND D_E_L_E_T_ = ' ' "+ CRLF
//EFETUAR SOMA1 DA LINHA
cProcCTB	+= "		         exec "+ __cProcSoma1+"_"+cEmpAnt+" @cCT2LinAux , '1', @cCT2_LINHA output "+ CRLF
//------------------------------------------------------------------------------------------------------------------------------------------------
cProcCTB	+= "		         If @IN_lCTBA101 = '1' begin "+ CRLF
cProcCTB	+= "		            "+ CRLF
cProcCTB	+= "		            If @cCT2_DC != '4' begin "+ CRLF
cProcCTB	+= "		               "+ CRLF
//cProcCTB	+= "						select @IN_cSeqLan = @IN_cSeqLan + 1 "+ CRLF
cProcCTB	+= "		               Exec "+ __cProcSoma1+"_"+cEmpAnt+" @cSeqLan, '0', @cSeqLan OutPut"+ CRLF
cProcCTB	+= "		               select @cCT2_SEQHIS = '001' "+ CRLF
cProcCTB	+= "		               select @cCT2_SEQLAN	= @cSeqLan "+ CRLF
cProcCTB	+= "		               select @nSeqHis = 1 "+ CRLF
cProcCTB	+= "		            End else begin "+ CRLF
			   	                       /* -----------------------------------------
   	   	                                 @cCT2_DC = '4' ou outro
	   		                             ----------------------------------------- */
cProcCTB	+= "		               If @cCT2_DC = '4' begin "+ CRLF
cProcCTB	+= "		                  select @nSeqHis = @nSeqHis + 1 "+ CRLF
cProcCTB	+= "		                  select @cCT2_SEQLAN	= @cSeqLan "+ CRLF
cProcCTB	+= "		                  exec "+ cProcCtbZero+"_"+cEmpAnt+" @nSeqHis , 3 , @cNewSeq output "+ CRLF
cProcCTB	+= "		                  select @cCT2_SEQHIS	= @cNewSeq "+ CRLF
cProcCTB	+= "		               end else begin "+ CRLF
cProcCTB	+= "		                  If @cCT2_LINHA = '"+StrZero(1,Len(CT2->CT2_LINHA))+"'  begin "+ CRLF
cProcCTB	+= "		                     select @cSeqLan = '"+StrZero( 1, Len(CT2->CT2_SEQLAN) )+"' "+ CRLF//"001"
cProcCTB	+= "		                     select @nSeqHis = 1 "+ CRLF
cProcCTB	+= "		                     select @cCT2_SEQLAN = @cSeqLan "+ CRLF
cProcCTB	+= "		                     exec "+ cProcCtbZero+"_"+cEmpAnt+" @nSeqHis , 3 , @cNewSeq output "+ CRLF
cProcCTB	+= "		                     select @cCT2_SEQHIS = @cNewSeq "+ CRLF
cProcCTB	+= "		                  end else begin "+ CRLF
cProcCTB	+= "		                     If @cCT2_DC != '4' And @cCT2_LINHA != '"+StrZero(1,Len(CT2->CT2_LINHA))+"'  begin "+ CRLF
cProcCTB	+= "		                        select @cCT2_SEQHIS	= '001' "+ CRLF
cProcCTB	+= "		                        select @nSeqHis = 1 "+ CRLF
cProcCTB	+= "		                        If @cCT2_SEQLAN != ' ' begin "+ CRLF
cProcCTB	+= "		                           select @cSeqLan 	= @cCT2_SEQLAN "+ CRLF
cProcCTB	+= "		                        end else begin "+ CRLF
cProcCTB	+= "		                           select @cSeqLan = @cSeqLan + 1 "+ CRLF
cProcCTB	+= "		                           select @cCT2_SEQLAN = @cSeqLan "+ CRLF
cProcCTB	+= "		                        End"+ CRLF
cProcCTB	+= "						     End Else begin"+ CRLF
cProcCTB	+= "						        If @cCT2_DC = '4' And @cCT2_LINHA != '"+StrZero(1,Len(CT2->CT2_LINHA))+"' begin "+ CRLF
cProcCTB	+= "		                           If @cCT2_SEQLAN = ' ' select @cCT2_SEQLAN	= @cSeqLan "+ CRLF
cProcCTB	+= "						           Else	select @cSeqLan = @cCT2_SEQLAN "+ CRLF
cProcCTB	+= "						           "+ CRLF
cProcCTB	+= "						           If @cCT2_SEQHIS = ' ' begin "+ CRLF
cProcCTB	+= "						              select @nSeqHis = @nSeqHis + 1 "+ CRLF
cProcCTB	+= "                                      "+ CRLF
cProcCTB	+= "                                      exec "+ cProcCtbZero+"_"+cEmpAnt+" @nSeqHis , 3 , @cNewSeq output "+ CRLF
cProcCTB	+= "                                      select @cCT2_SEQHIS = @cNewSeq "+ CRLF
cProcCTB	+= "								   end else select @nSeqHis = Convert(int, @cCT2_SEQHIS ) "+ CRLF
cProcCTB	+= "								   "+ CRLF
cProcCTB	+= "                                End "+ CRLF
cProcCTB	+= "                             End "+ CRLF
cProcCTB	+= "                          End "+ CRLF
cProcCTB	+= "                       End "+ CRLF
cProcCTB	+= "                    End "+ CRLF //
cProcCTB	+= "                 End "+ CRLF
cProcCTB	+= "				 select @cCT2_CRCONV = SUBSTRING(@cCT2_CONVER,1,1) "+ CRLF
cProcCTB	+= "               End Else begin "+ CRLF
						         /* -----------------------------------------
						            @cMoeda != '01'
						            ----------------------------------------- */
cProcCTB	+= "                  select @cCT2_CRCONV = SUBSTRING(@cCT2_CONVER,@nContador,1) "+ CRLF
cProcCTB	+= "                  select @nCT2_VALOR	= @nValor "+ CRLF
cProcCTB	+= "               End "+ CRLF
cProcCTB	+= "               "+ CRLF
cProcCTB	+= "			   If @IN_lSeqCorr = '1' begin "+ CRLF
cProcCTB	+= "                  select @cCT2_SEGOFI	= @IN_cSeqCorr "+ CRLF
cProcCTB	+= "                  select @cCT2_NODIA 	= @IN_cSeqCorr "+ CRLF
cProcCTB	+= "                  "+ CRLF
cProcCTB	+= "                  If @IN_lCT2_DIACTB = '1' And @IN_lSeqCorr != ' ' begin "+ CRLF
cProcCTB	+= "                     select @cCT2_DIACTB = SUBSTRING( @IN_cSeqCorr , 1 , 2) "+ CRLF
cProcCTB	+= "                  End"+ CRLF
cProcCTB	+= "               End "+ CRLF
cProcCTB	+= "               "+ CRLF
cProcCTB	+= "               If @IN_lCT2_MLTSLD = '1' AND @IN_lCT2_CTLSLD = '1' begin "+ CRLF
cProcCTB	+= "                  select @cCT2_CTLSLD	= '0' "+ CRLF
cProcCTB	+= "               End "+ CRLF
cProcCTB	+= "               "+ CRLF
cProcCTB	+= "               select @cCT2_FILIAL = @IN_cFilialCT2 "+ CRLF
cProcCTB	+= "               select @cCT2_DATA	= @IN_cDataLanc "+ CRLF
cProcCTB	+= "               select @cCT2_LOTE	= @IN_cLote "+ CRLF
cProcCTB	+= "               select @cCT2_SBLOTE	= @IN_cSubLote "+ CRLF
cProcCTB	+= "               select @cCT2_DOC	= @IN_cDoc "+ CRLF
cProcCTB	+= "               select @cCT2_FILORI = @IN_cFilOri "+ CRLF
cProcCTB	+= "               select @cCT2_EMPORI = @IN_cEmpOri "+ CRLF
cProcCTB	+= "               select @cCT2_SEQUEN = @IN_cSequenc "+ CRLF
cProcCTB	+= "               select @cCT2_ROTINA = @IN_cProg "+ CRLF
cProcCTB	+= "               select @cCT2_AGLUT	= @cAglut "+ CRLF
cProcCTB	+= "               select @cCT2_MOEDLC = @cMoeda "+ CRLF
cProcCTB	+= "               select @cCT2_MANUAL = '2' " + CRLF
cProcCTB	+= "               If @IN_nPosHora > 0 begin "+ CRLF
cProcCTB	+= "                  select @cCT2_HORALC = @IN_cHoraLc "+ CRLF
cProcCTB	+= "               end "+ CRLF
cProcCTB	+= "               "+ CRLF
cProcCTB	+= "               select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName("CT2") + CRLF
cProcCTB	+= "               select @iRecno = @iRecno + 1 "+ CRLF
cProcCTB	+= "               ##TRATARECNO @iRecno\ "+ CRLF
//cProcCTB	+= "               begin tran"+ CRLF
cProcCTB	+= "               INSERT INTO "+RetSqlName("CT2")+" ("+cCamposProc+")"+ CRLF
 cProcCTB	+= "               VALUES ("+cVarGrvCps+")" + CRLF
		         /* -----------------------------------------
		            PE CT105CT2 na gravação do Ct2
		            ----------------------------------------- */
cProcCTB	+= "               If ( @IN_cProg != 'CTBA101' and  @IN_cProg != 'CTBA102' and @IN_cProg != 'CTBA103' ) And @IN_LSIMULA = '0' begin"+ CRLF               
cProcCTB	+= "			      Exec "+cPeCT105CT2+"_"+cEmpAnt+ " @IN_nMoedas, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @IN_lCusto, @IN_lItem, @IN_lCLVL, @IN_TOTINF, @IN_LATUBASE, @IN_LREPROC"+ CRLF
cProcCTB	+= "               end"+ CRLF
		         /* -----------------------------------------
		            PE CTBGRV 
		            ----------------------------------------- */
cProcCTB	+= "               If @IN_LSIMULA = '0' begin"+ CRLF
cProcCTB	+= "               	  Exec "+cPeCTBGRV+"_"+cEmpAnt+" @IN_NOPC, @IN_cProg"+ CRLF
cProcCTB	+= "               End"+ CRLF
//cProcCTB	+= "               Commit tran"+ CRLF
cProcCTB	+= "               ##FIMTRATARECNO  "+ CRLF
cProcCTB	+= "               "+ CRLF
cProcCTB	+= "               SELECT @CTK_DATA = CTK_DATA, @CTK_SEQUEN = CTK_SEQUEN, @CTK_DC = CTK_DC, @CTK_LP = CTK_LP, @CTK_LPSEQ = CTK_LPSEQ, @CTK_KEY = CTK_KEY, @CTK_DEBITO = CTK_DEBITO, @CTK_CREDIT = CTK_CREDIT, "+ CRLF
cProcCTB	+= "               @CTK_VLR01 = CTK_VLR01, @CTK_VLR02 = CTK_VLR02, @CTK_VLR03 = CTK_VLR03, @CTK_VLR04 = CTK_VLR04, @CTK_VLR05 = CTK_VLR05, @CTK_HIST = CTK_HIST, @CTK_CCC = CTK_CCC, @CTK_CCD = CTK_CCD, "+ CRLF
cProcCTB	+= "               @CTK_ITEMC = CTK_ITEMC, @CTK_ITEMD = CTK_ITEMD, @CTK_CLVLDB = CTK_CLVLDB, @CTK_CLVLCR = CTK_CLVLCR, @CTK_MOEDLC = CTK_MOEDLC "+ CRLF
If lCTxTABORI
	cProcCTB	+= "               , @CTK_TABORI = CTK_TABORI " + CRLF
EndIf
If lCTxRECORI		
	cProcCTB	+= "               , @CTK_RECORI = CTK_RECORI " + CRLF		
Endif
If lCTxRECDES		
	cProcCTB	+= "               , @CTK_RECDES = CTK_RECDES " + CRLF		
Endif
cProcCTB	+= "               FROM " + RetSqlName("CTK") + CRLF
cProcCTB	+= "               WHERE R_E_C_N_O_ = @nCT2_RECCTK " + CRLF 
cProcCTB	+= "                 AND D_E_L_E_T_ = ' '" + CRLF
cProcCTB	+= "               "+ CRLF
cProcCTB	+= "               select @iRecCV3 = IsNull(Max( R_E_C_N_O_ ), 0 ) from " + RetSqlName("CV3") + CRLF
cProcCTB	+= "               select @iRecCV3 = @iRecCV3 + 1 "+ CRLF
cProcCTB	+= "               ##TRATARECNO @iRecCV3\ "+ CRLF
cProcCTB	+= "               "+ CRLF
//cProcCTB	+= "               begin tran"+ CRLF
cProcCTB	+= "               INSERT INTO "+RetSqlName("CV3")+" (" + CRLF
cProcCTB	+= "               CV3_FILIAL,CV3_DTSEQ,CV3_SEQUEN,CV3_DC,CV3_LP,CV3_LPSEQ,CV3_KEY," + CRLF
cProcCTB	+= "               CV3_DEBITO,CV3_CREDIT,CV3_VLR01,CV3_VLR02,CV3_VLR03,CV3_VLR04,CV3_VLR05," + CRLF
cProcCTB	+= "               CV3_HIST,CV3_CCC,CV3_CCD,CV3_ITEMC,CV3_ITEMD,CV3_CLVLDB,CV3_CLVLCR,CV3_MOEDLC" + CRLF
If lCTxTABORI
	cProcCTB	+= "               , CV3_TABORI " + CRLF
EndIf
If lCTxRECORI 
	cProcCTB	+= "               , CV3_RECORI " + CRLF
EndIf				
If lCTxRECDES
	cProcCTB	+= "               , CV3_RECDES " + CRLF
EndIf
cProcCTB	+= "               , R_E_C_N_O_ ) Values" + CRLF
cProcCTB	+= "               (" + CRLF
cProcCTB	+= "               @cFilCV3, @CTK_DATA,@CTK_SEQUEN ,@CTK_DC,@CTK_LP,@CTK_LPSEQ,@CTK_KEY,@CTK_DEBITO,"+ CRLF
cProcCTB	+= "               @CTK_CREDIT,@CTK_VLR01,@CTK_VLR02,@CTK_VLR03,@CTK_VLR04,@CTK_VLR05," + CRLF
cProcCTB	+= "               @CTK_HIST,@CTK_CCC,@CTK_CCD,@CTK_ITEMC,@CTK_ITEMD,@CTK_CLVLDB,@CTK_CLVLCR,@CTK_MOEDLC" + CRLF
If lCTxTABORI
	cProcCTB	+= "               , @CTK_TABORI" + CRLF
EndIf
If lCTxRECORI 
	cProcCTB	+= "               , @CTK_RECORI" + CRLF
EndIf				
If lCTxRECDES
	cProcCTB	+= "               , @iRecno" + CRLF
EndIf
cProcCTB	+= "               ,@iRecCV3)" + CRLF
//cProcCTB	+= "               commit tran"+ CRLF
cProcCTB	+= "               "+ CRLF
cProcCTB	+= "               ##FIMTRATARECNO  "+ CRLF
cProcCTB	+= "               "+ CRLF

cProcCTB	+= "               select @iNroRegs = @iNroRegs + 1 "+ CRLF
cProcCTB	+= "               "+ CRLF
/*cProcCTB	+= "					If @iNroRegs >= 2000 begin "+ CRLF
cProcCTB	+= "						commit tran "+ CRLF
cProcCTB	+= "						select @iNroRegs = 0 "+ CRLF
cProcCTB	+= "					End "+ CRLF*/
cProcCTB	+= "               "+ CRLF
//cProcCTB 	+= "               begin tran "+CRLF
cProcCTB	+= "               UPDATE " + RetSQLName("CTK") + " SET CTK_RECDES = @iRecno, CTK_RECCV3 = @iRecCV3 WHERE R_E_C_N_O_ = @nCT2_RECCTK " + CRLF
//cProcCTB 	+= "               commit tran"+CRLF
If lExistTRW
	cProcCTB	+= "               If @IN_lGrvTRW = '1'  begin"+ CRLF
	cProcCTB	+= "                  select @iRecTRW = IsNull(Max( R_E_C_N_O_ ), 0 ) from " + cTabTRW + CRLF
	cProcCTB	+= "                  select @iRecTRW = @iRecTRW + 1 "+ CRLF
	cProcCTB	+= "                  ##TRATARECNO @iRecTRW\ "+ CRLF
//	cProcCTB	+= "                  Begin tran"+ CRLF
	cProcCTB	+= "                  Insert Into "+cTabTRW+" "+ CRLF
	cProcCTB	+= "                  ( CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC, "+ CRLF
	cProcCTB	+= "                  CT2_MOEDLC, CT2_TPSALD, CT2_SEQUEN , CT2_DC,     CT2_DEBITO, CT2_CREDIT, "+ CRLF
	cProcCTB	+= "                  CT2_VALOR,  CT2_CCD,    CT2_CCC, CT2_ITEMD,  CT2_ITEMC, "+ CRLF
	cProcCTB	+= "                  CT2_CLVLDB, CT2_CLVLCR, CT2_EMPORI, CT2_FILORI, CT2_LINHA, "+ CRLF
	cProcCTB	+= "                  CT2_ATIVDE, R_E_C_N_O_  "+ CRLF
	If lCubo
		If FieldPos("CT2_EC05DB") > 0 .and. FieldPos("CT2_EC05CR") > 0
			cProcCTB	+= "                  ,CT2_EC05DB, CT2_EC05CR  "+ CRLF
		EndIf
		If FieldPos("CT2_EC06DB") > 0 .and. FieldPos("CT2_EC06CR") > 0
			cProcCTB	+= "                  ,CT2_EC06DB, CT2_EC06CR  "+ CRLF
		EndIf
		If FieldPos("CT2_EC07DB") > 0 .and. FieldPos("CT2_EC07CR") > 0
			cProcCTB	+= "                  ,CT2_EC07DB, CT2_EC07CR  "+ CRLF
		EndIf
		If FieldPos("CT2_EC08DB") > 0 .and. FieldPos("CT2_EC08CR") > 0
			cProcCTB	+= "                  ,CT2_EC08DB, CT2_EC08CR  "+ CRLF
		EndIf                             	
		If FieldPos("CT2_EC09DB") > 0 .and. FieldPos("CT2_EC09CR") > 0
			cProcCTB	+= "                  ,CT2_EC09DB, CT2_EC09CR  "+ CRLF
		EndIf
	EndIf
	cProcCTB	+= "                  )"+ CRLF
	cProcCTB	+= "                  Values ( "+ CRLF
	cProcCTB	+= "                  @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE,@cCT2_DOC, "+ CRLF
	cProcCTB	+= "                  @cCT2_MOEDLC, @cCT2_TPSALD , @cCT2_SEQUEN , @cCT2_DC , @cCT2_DEBITO, @cCT2_CREDIT, "+ CRLF
	cProcCTB	+= "                  @nCT2_VALOR, @cCT2_CCD, @cCT2_CCC, @cCT2_ITEMD, @cCT2_ITEMC, "+ CRLF
	cProcCTB	+= "                  @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_EMPORI, @cCT2_FILORI, @cCT2_LINHA , "+ CRLF
	cProcCTB	+= "                  @IN_ThreadID , @iRecTRW "+ CRLF
			
	If lCubo
		If FieldPos("CT2_EC05DB") > 0 .and. FieldPos("CT2_EC05CR") > 0
			cProcCTB	+= "                  ,@cCT2_EC05DB , @cCT2_EC05CR "+ CRLF
		EndIf
		If FieldPos("CT2_EC06DB") > 0 .and. FieldPos("CT2_EC06CR") > 0
			cProcCTB	+= "                  ,@cCT2_EC06DB , @cCT2_EC06CR "+ CRLF
		EndIf
		If FieldPos("CT2_EC07DB") > 0 .and. FieldPos("CT2_EC07CR") > 0
			cProcCTB	+= "                  , @cCT2_EC07DB , @cCT2_EC07CR "+ CRLF
		EndIf
		If FieldPos("CT2_EC08DB") > 0 .and. FieldPos("CT2_EC08CR") > 0
			cProcCTB	+= "                  ,@cCT2_EC08DB , @cCT2_EC08CR "+ CRLF
		EndIf
		If FieldPos("CT2_EC09DB") > 0 .and. FieldPos("CT2_EC09CR") > 0
			cProcCTB	+= "                  ,@cCT2_EC09DB, @cCT2_EC09CR "+ CRLF
		EndIf
	EndIf
	cProcCTB	+= "                  )"+ CRLF
	cProcCTB	+= "                  "+ CRLF
//	cProcCTB	+= "                  commit tran "+ CRLF
	cProcCTB	+= "                  ##FIMTRATARECNO  "+ CRLF
	cProcCTB	+= "                  "+ CRLF
	cProcCTB	+= "                  select @lNoMltSld = '1' "+CRLF
	cProcCTB	+= "               end"+ CRLF
EndIf

cProcCTB	+= "            end"+ CRLF
cProcCTB	+= "            select @nContador = @nContador + 1 "+ CRLF
cProcCTB	+= "         End"+CRLF
If lControlSD
cProcCTB	+= "      End "+ CRLF
Endif
cProcCTB	+= "      Fetch cCursorCTB into "+ cVarProc+ CRLF
cProcCTB	+= "   End "+ CRLF
cProcCTB	+= "   Close cCursorCTB "+ CRLF
cProcCTB	+= "   Deallocate cCursorCTB "+ CRLF
cProcCTB	+= "   select @OUT_RET='1' "+ CRLF

cProcCTB	+= "End "+ CRLF

cProcCTB := CtbAjustaP(.T., cProcCTB, @nPTratRec)
cProcCTB := MsParse(cProcCTB,If(Upper(TcSrvType())= "ISERIES", "DB2", cDBType ) )
cProcCTB := CtbAjustaP(.F., cProcCTB, nPTratRec)

If Empty( cProcCTB )
	MsgAlert("Erro na montagem da procedure de contabilização! Por favor, entrar em contato com atendimento." + CRLF + msParseError(),"Erro") 
	lRet := .F.
Else
	If !TCSPExist( cProcName+"_"+cEmpAnt )
		cRet := TcSqlExec( cProcCTB )
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure de gravacao [contabilizacao] : "+cProcName,"Erro")
	 			MsgAlert(TCSqlError())  //'Erro criando a Stored Procedure:'
	 			final()
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBby_ProcºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao da procedure para gravacao dos movimentos contabeis º±±
±±º          ³CT2/CV3 e TRW para atualizacao dos saldos e chamada da      º±±
±±º          ³multithread para execucao da procedure                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTBby_Proc(nOpc, lInclui, dDataLanc, cLote, cSubLote, cDoc, cFilOri, cEmpOri, cSequenc, ;
									lAglut, nContMoeda, cMoeda, aHeader, lAltTpSld, cProg, cSeqLan, cSeqLan01, ;
									nSeqHis, cSeqHis01, lFirstSq, lSeqCorr, cSeqCorr, lCusto,lItem,lCLVL, 	;
									nTotInf, lSimula, cTabCTK, cTabCT2,_lCTB185,__nQuantas,aTpSaldo,lAgruSld,lTrbProc,;
									cModoClr, cPreLcto , dReproc, cHoraLc, aAtuSaldos)
							                                      
							
Local lCTBA103 		:= Alltrim(Upper(cProg)) == "CTBA103"
Local lMudaTRT 		:= SuperGetMV("MV_MUDATRT",.F.,.T.)
Local lCubo 		:= IIf(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )
Local lCT2_MLTSLD 	:= CT2->( FieldPos( "CT2_MLTSLD" ) ) > 0
Local lCT2_CTLSLD	:= CT2->( FieldPos( "CT2_CTLSLD" ) ) > 0
Local lCT2_DIACTB 	:= CT2->( FieldPos( "CT2_DIACTB" ) > 0 )
Local nPosHora 		:= CT2->( FieldPos( 'CT2_HORALC' ) )
Local lGrvTRW 		:= _lctb185 .And. !lSimula
Local cManual		:= Iif(empty(cSequenc),"1","2")
Local lCTBA101 		:= ( cProg == 'CTBA101' )
Local cTabTRW 		:= "TRW"+SM0->M0_CODIGO+"0"+Iif(lMudaTRT, "_SP", "")
Local lOutrMoeda	:= .F.
//Local aAtuSaldos	:= {}
Local lPodeExc		:= .T.
Local lAtuProc		:= .F.
Local lOk 			:= .T.
Local lContinua		:= .T.
Local cMoedaOld
Local _lAtSldBase := .T. 
Local _lReproc    := .F.

Default lSeqCorr	:= ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"

If __IsCtbJob  == NIL
	__IsCtbJob  := If( FindFunction( "IsCtbJob"), IsCtbJob() , .F. )
EndIf

lGrvTRW := lGrvTRW .And. ! __IsCtbJob

cMoedaOld := cMoeda

// VerIficacao para identIficar se grava na moeda 01 com Valor 0.00
lOutrMoeda   := CtbVOt_Moed(__nQuantas)
TMP->(dbGotop())
WHILE TMP->(!EOF()) .and. lContinua

	For nContMoeda := 1 To __nQuantas
		
		cMoeda := StrZero(nContMoeda,2)
		nValor := CtbGet_Valor(cMoeda, @cEmpOri, @cFilOri)
		nValorAnt:= 0 // SÓ CHAMA AQUI QDO FOR INCLUSAO, PORTANTO, VALOR ANTERIOR ZERADO SEMPRE!
   
        //armazena no array aAtuSaldos para posterior a gravacao do CT2 proceder atualizacao de saldos
		lContinua := CtbArmSald(nOpc, nOpc, aAtuSaldos, nContMoeda, cMoeda, lPodeExc, aTpSaldo, lAgruSld, ;
							lTrbProc, @lAtuProc, cModoClr, dReproc, nValor, nValorAnt, lSimula, cTabCTK, cTabCT2)

	Next nContMoeda
	
	TMP->(dbSkip())
	
EndDo

cMoeda := cMoedaOld

If lContinua

	// efetua a gravação do numero gerado, caso já exista o numero, ele  irá gerar um novo.
	lSeqCorr := CTBSQGrv( cSeqCorr ,dDataLanc )
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()	
	lOutrMoeda   := CtbVOt_Moed(__nQuantas)

	CONOUT("CHAMA PROCEDURE DE GRAVACAO: "+TIME())
	aResult := TCSPExec( 	__cProcGrv+"_"+cEmpAnt, ; // nome da procedure
	 			DtoS(dDataLanc),;
	 			cLote, ;
	 			cSubLote, ;
	 			cDoc, ;
	 			cFilOri, ;
	 			cEmpOri, ;
	 			cSequenc, ;
				iif(lAglut, '1', '0'), ;
				cProg, ;
				cSeqLan, ;
				iif(lSeqCorr, '1', '0'), ;
				cSeqCorr, ;
				iif(lCusto, '1', '0'),;
				iif(lItem, '1', '0'),;
				iif(lCLVL, '1', '0'),;
				nPosHora , ;
				__nQuantas, ;
				xFilial("CT2"), ;
				cHoraLc,;
				cManual, ;
				iif(lCTBA101, '1', '0'), ;
				iif(lCT2_DIACTB, '1', '0'), ;
				iif(lCT2_MLTSLD, '1', '0'), ;
				iif(lCT2_CTLSLD, '1', '0'), ;
				Iif(lGrvTRW,'1', '0'),;
				cPreLcto ,;
				StrZero(ThreadID(),Len(CT2->CT2_ATIVDE)),;
				Iif(lSimula, '1', '0'),; 
				Iif(nTotInf == NIL, 0,nTotInf),;
				Iif(_lAtSldBase, '1', '0'),; 
				Iif(_lReproc, '1', '0'),;
				nOpc,;
				cFilAnt )
						
	CONOUT("FIM DA PROCEDURE DE GRAVACAO: "+TIME())
	If lOk .and. ( Empty(aResult) .or. aResult[1] != "1" )
		lOk:= .F.
		UserException( "Erro na procedure de contabilização! Por favor, entrar em contato com atendimento." + CRLF + TCSqlError()  + CRLF )
	Else
		//laco para ponto de entrada CTBGRV
		dbSelectArea("CT2")
		dbSetOrder(1)

		dbSeek( xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+"001" )  //posicionar sempre na primeira linha
                                                                             
		If _lCtbGrv .And. !lSimula
			While CT2->( !Eof() .And. CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC == xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc )
			
				ExecBlock("CTBGRV",.f.,.f.,{nOpc,cProg,.T./*lProcedure*/,CT2->(Recno())/*nRecCT2*/})
	
				CT2->( dbSkip() )
			
			EndDo
		Endif
	Endif
	TcRefresh("CT2")
	TcRefresh("CTK")
Endif

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbVOt_MoedºAutor  ³Microsiga          º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se valor positivo existe em outras moedas          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbVOt_Moed(nMoedas)
// VerIficacao para identIficar se grava na moeda 01 com Valor 0.00
Local lOutrMoeda   := .F.
Local nContMoeda
For nContMoeda 	:= 2 To nMoedas			//comecao o for a partir da segunda moeda
	If ! TMP->CT2_FLAG
		lOutrMoeda := &( "TMP->CT2_VALR" + StrZero( nContMoeda, 2 )) > 0
    	If lOutrMoeda
    		Exit
    	EndIf
	EndIf
Next

Return(loutrMoeda)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGet_ValorºAutor  ³Microsiga         º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recupera o valor na moeda informada                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbGet_Valor(cMoeda, cEmpOri, cFilOri)
Local nValor

If !TMP->CT2_FLAG						////// SE NAO ESTIVER DELETADO NO TMP
	If cMoeda == '01'
		nValor	:= TMP->CT2_VALOR
		//Se estiver na empresa consolidadora, ira considerar os campos CT2_EMPORI e CT2_FILORI
		//da moeda 01. Caso inclua algum registro novo em outra moeda, ira gravar com o mesmo
		//conteudo da moeda 01. 			
		If !Empty(TMP->CT2_EMPORI) .And. !Empty(TMP->CT2_FILORI)							
			cEmpOri	:= TMP->CT2_EMPORI                            	
			cFilOri	:= TMP->CT2_FILORI
		EndIf
	Else
		nValor	:= &("TMP->CT2_VALR"+cMoeda)
	EndIf
Else								// Quando a linha for deletada -> garantir valor 0!!
	nValor 	:= 0
EndIf				

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT105DOC    ºAutor ³ TOTVS            º Data ³  04/12/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera proxima linha, doc e lote                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Nome da procedure                                  º±±
±±º          ³ EXPA1 - Array aProc[6] com o nome da procedure StrZero     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct105Doc(cProcDoc)
Local lRet      := .T.
Local cQuery    := ""
Local cTamDOC	:= STR(TAMSX3("CT2_DOC")[1])
Local nRet		:= 0
Local nPTratRec	:= 0
Local cDocHum	:= STRZERO(1, TAMSX3("CT2_DOC")[1] )
DEFAULT cProcDoc:= CriaTrab(,.F.)

cQuery := "Create procedure "+cProcDoc+"_"+cEmpAnt+" ("+CRLF
cQuery += "   @IN_cData  	char(8),"+CRLF  
cQuery += "   @IN_cLote  	varchar("+STR(TAMSX3("CT2_LOTE")[1])+"),"+CRLF  
cQuery += "   @IN_cSubLote  varchar("+STR(TAMSX3("CT2_SBLOTE")[1])+"),"+CRLF  
cQuery += "   @IN_cDocOri   varchar("+cTamDOC+"),"+CRLF  
cQuery += "   @OUT_Doc   	varchar( "+cTamDOC+" ) OutPut"+CRLF  


cQuery += ")"+CRLF
cQuery += "as"+CRLF

cQuery += "Declare @cMaxDoc  Char( "+cTamDOC+" )" +CRLF
cQuery += "Declare @cDoc     Char( "+cTamDOC+" )" +CRLF
cQuery += "Declare @iRecno   integer " +CRLF

cQuery += "Begin " + CRLF
cQuery += " " + CRLF

cQuery += "SELECT @cMaxDoc = ISNULL(Max(CTF_DOC),'"+cDocHum+"') "
cQuery += "  FROM " + RetSqlName("CTF") + " CTF "
cQuery += " WHERE CTF_FILIAL = '" + xFilial("CTF") + "'"
cQuery += "   AND CTF_DATA = @IN_cData "
cQuery += "   AND CTF_LOTE = @IN_cLote "
cQuery += "   AND CTF_SBLOTE = @IN_cSubLote "
cQuery += "   AND D_E_L_E_T_ = ' ' "

cQuery += "exec "+__cProcSoma1+"_"+cEmpAnt+" @cMaxDoc, '1', @cDoc OutPut " + CRLF

cQuery += "If @IN_cDocOri = @cDoc" + CRLF
cQuery += "	exec "+__cProcSoma1+"_"+cEmpAnt+" @IN_cDocOri, '1', @cDoc OutPut " + CRLF
cQuery += ""+CRLF
cQuery += "select @iRecno = IsNull(Max( R_E_C_N_O_ ), 0 ) from "+RetSqlName("CTF") + CRLF
cQuery += "select @iRecno = @iRecno + 1 "+ CRLF
cQuery += "##TRATARECNO @iRecno\ "+ CRLF
cQuery += "INSERT INTO "+RetSqlName("CTF")+" (CTF_FILIAL,CTF_DOC,CTF_LOTE,CTF_SBLOTE,CTF_DATA,CTF_LINHA, R_E_C_N_O_) VALUES ('"+xFilial("CTF")+"',@cDoc,@IN_cLote,@IN_cSubLote,@IN_cData,'   ',@iRecno)" + CRLF
cQuery += "##FIMTRATARECNO  "+ CRLF
cQuery += ""+CRLF
cQuery += "select @OUT_Doc = @cDoc "+CRLF
cQuery += "End " + CRLF
cQuery := CtbAjustaP(.T., cQuery, @nPTratRec)
cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, nPTratRec)

If Empty( cQuery )
	MsgAlert(MsParseError(),"A query de geracao da Proxima linha, lote, doc nao passou pelo Parse "+cProcDoc)
	lRet := .F.
Else
	If !TCSPExist( cProcDoc )
		nRet := TcSqlExec(cQuery)
		If nRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da procedure Proxima linha, lote, doc "+cProcDoc)
				MsgAlert(MsParseError())
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct105105CT2º Autor ³ TOTVS            º Data ³  13/01/16    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PE CT105CT2 chamada na procedure de Gravação do CT2         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct105105CT2(cPeCT105CT2)
Local lRet      := .T.
Local cQuery    := ""

If !TCSPExist( cPeCT105CT2+"_"+cEmpAnt )
	
	cQuery := "Create Procedure CT105CT2_"+cEmpAnt+" ("+CRLF
	cQuery += "   @IN_NMOEDAS   integer,"+CRLF
	cQuery += "   @IN_DATALANC  Char( 08 ),"+CRLF
	cQuery += "   @IN_LOTE      Char( "+Str(TamSx3("CT2_LOTE")[1])+" ),"+ CRLF
	cQuery += "   @IN_SBLOTE    Char( "+Str(TamSx3("CT2_SBLOTE")[1])+" ),"+ CRLF
	cQuery += "   @IN_DOC       Char( "+Str(TamSx3("CT2_DOC")[1])+" ),"+ CRLF
	cQuery += "   @IN_LCUSTO    Char( 01 ),"+CRLF
	cQuery += "   @IN_LITEM     Char( 01 ),"+CRLF
	cQuery += "   @IN_LCLVL     Char( 01 ),"+CRLF
	cQuery += "   @IN_TOTINF    float,"+CRLF
	cQuery += "   @IN_LATUBASE  Char( 01 ),"+CRLF
	cQuery += "   @IN_LREPROC   Char( 01 )"+CRLF
	cQuery += " )"+CRLF
	cQuery += "as"+CRLF
	cQuery += ""+CRLF
	/* ------------------------------------------------------------------------------------
	      Ponto de entrada padrao : CT105CT2
	      ---------------------------------------------
	      @IN_NMOEDAS   - Nro de Moedas Usadas
	      @IN_DATALANC  - Data do Lancto
	 	   @IN_LOTE      - Nro do Lote Contábil
	 	   @IN_SBLOTE    - Sublote contábil
	 	   @IN_DOC       - Nro do Documento contabil
	 	   @IN_LCUSTO    - Indica se Trabalha com CCusto, '1' trabalha, '0' Nao
	 	   @IN_LITEM     - Indica se Trabalha com Item , '1' trabalha, '0' Nao
	 	   @IN_LCLVL     - Indica se Trabalha com Classe de Valor, '1' trabalha, '0' Nao
	 	   @IN_TOTINF    - Total Informado
	 	   @IN_LATUBASE  - Indica se atualiza tabelas de Saldos. Se '1' atualiza
	 	   @IN_LREPROC   - Indoca se é Reproc Contábil
	   -------------------------------------------------------------------------------------- */
	cQuery += "Declare @iMoedas   Integer"+CRLF
	cQuery += "Declare @cDataLanc Char( 08 )"+ CRLF
	cQuery += "Declare @cLote     Char( "+Str(TamSx3("CT2_LOTE")[1])+" )"+ CRLF
	cQuery += "Declare @cSbLote   Char( "+Str(TamSx3("CT2_SBLOTE")[1])+" )"+ CRLF
	cQuery += "Declare @cDoc      Char( "+Str(TamSx3("CT2_DOC")[1])+" )"+ CRLF
	cQuery += "Declare @lCusto    Char( 01 )"+ CRLF
	cQuery += "Declare @lItem     Char( 01 )"+ CRLF
	cQuery += "Declare @lClvl     Char( 01 )"+ CRLF
	cQuery += "Declare @nTotInf   Float"+ CRLF
	cQuery += "Declare @lAtuBase  Char( 01 )"+ CRLF
	cQuery += "Declare @lReproc   Char( 01 )"+ CRLF
	cQuery += ""+CRLF
	cQuery += "Begin"+CRLF
	cQuery += "   "+CRLF
	cQuery += "   select @iMoedas   = @IN_NMOEDAS"+CRLF
	cQuery += "   select @cDataLanc = @IN_DATALANC"+CRLF
	cQuery += "   select @cLote     = @IN_LOTE"+CRLF
	cQuery += "   select @cSbLote   = @IN_SBLOTE"+CRLF
	cQuery += "   select @cDoc      = @IN_DOC"+CRLF
	cQuery += "   select @lCusto    = @IN_LCUSTO"+CRLF
	cQuery += "   select @lItem     = @IN_LITEM"+CRLF
	cQuery += "   select @lClvl     = @IN_LCLVL"+CRLF
	cQuery += "   select @nTotInf   = @IN_TOTINF"+CRLF
	cQuery += "   select @lAtuBase  = @IN_LATUBASE"+CRLF
	cQuery += "   select @lReproc   = @IN_LREPROC"+CRLF
	cQuery += "   "+CRLF
	cQuery += "End"+CRLF
	
	cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
	
	If Empty( cQuery )
		MsgAlert(MsParseError(),"A query do PE CT105CT2 nao passou pelo Parse "+cPeCT105CT2)
		lRet := .F.
	Else
		If !TCSPExist( cPeCT105CT2+"_"+cEmpAnt )
			nRet := TcSqlExec(cQuery)
			If nRet <> 0
				If !__lBlind
					MsgAlert("Erro na criacao da procedure do PE CT105CT2 "+cPeCT105CT2)
					MsgAlert(MsParseError())
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	EndIf
Endif	
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct105105CT2º Autor ³ TOTVS            º Data ³  13/01/16    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PE CTBGRV chamada na procedure de Gravação do CT2         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct105CTBGRV(cPeCTBGRV)    // PE CTBGRV
Local lRet      := .T.
Local cQuery    := ""

If !TCSPExist( cPeCTBGRV+"_"+cEmpAnt )
	
	cQuery := "Create Procedure CTBGRV_"+cEmpAnt+" ("+CRLF
   	cQuery += "  @IN_NOPC      integer,"+CRLF
   	cQuery += "  @IN_CPROG     Char( "+Str(TamSx3("CT2_ROTINA")[1])+" )"+ CRLF
   	cQuery += " )"+CRLF
   	cQuery += "as"+CRLF
	
	/* ------------------------------------------------------------------------------------
	      Ponto de entrada padrao : CT105CT2
	      ---------------------------------------------
	      @IN_NOPC      - 3 - Inclusao, 4- alteração, 6 - Estorno
	      @IN_CPROG     - Nome do Programa
 	   -------------------------------------------------------------------------------------- */
	cQuery += "Declare @nOpc    Integer"+CRLF
	cQuery += "Declare @cProg   Char( "+Str(TamSx3("CT2_ROTINA")[1])+" )"+ CRLF
   	cQuery += ""+CRLF
   	cQuery += "Begin"+CRLF
   	cQuery += "   "+CRLF
   	cQuery += "   select @nOpc    = @IN_NOPC"+CRLF
   	cQuery += "   select @cProg   = @IN_CPROG"+CRLF
   	cQuery += "   "+CRLF
   	cQuery += "End"+CRLF
	
	cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
	
	If Empty( cQuery )
		MsgAlert(MsParseError(),"A query do PE CTBGRV nao passou pelo Parse "+cPeCTBGRV)
		lRet := .F.
	Else
		If !TCSPExist( cPeCTBGRV+"_"+cEmpAnt )
			nRet := TcSqlExec(cQuery)
			If nRet <> 0
				If !__lBlind
					MsgAlert("Erro na criacao da procedure do PE CT105CT2 "+cPeCTBGRV)
					MsgAlert(MsParseError())
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	EndIf
Endif	
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CT102LOK  ³ Autor ³ Alfredo Medrano       ³ Data ³05/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida existencia de NIT en comprobantes contables Colombia³±±
±±³          ³ Funcion que se utiliza en fuente CTBA102 en func Ctba102Lan³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT102LOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CT105TOk                 	                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT102LOK()

Local aArTrab := GetArea()
Local lRet	:= .T.
Local cDescri	:= ""

dbSelectArea('SX3') 
SX3->(dbSetOrder(2))   
	
If TMP->CT2_DC=='1'
	If !empty(TMP->CT2_EC05DB)	
	   	DbselectArea("CV0")
	   CV0->(DbSetOrder(1))
		If CV0->(	DbSeek(xFilial("CV0")+"01"+TMP->CT2_EC05DB))
			lRet	:= .T.
	   Else  
			lRet	:= .F.  
			MsgInfo(OemToAnsi(STR0110) + TMP->CT2_EC05DB + OemToAnsi(STR0111) +TMP->CT2_LINHA + OemToAnsi(STR0112) )//El NIT /  en debito de la linea / no existe
		EndIf 
	Else
			If(CT2->(dbSeek( 'CT2_EC05DB' )), cDescri := X3DESCRIC(),'')	
			lRet	:= .F.  
			MsgInfo(OemToAnsi(STR0113) + cDescri + OemToAnsi(STR0114) +TMP->CT2_LINHA + OemToAnsi(STR0115))//El Campo NIT de Debito( / ) de la linea /  esta vacío 	  
   EndIf	   
ELseIf TMP->CT2_DC=='2'   
 	If !empty(TMP->CT2_EC05CR)	
	   	DbselectArea("CV0")
	   CV0->(DbSetOrder(1))
		If CV0->(DbSeek(xFilial("CV0")+"01"+TMP->CT2_EC05CR)) 
			lRet	:= .T.
	   Else  
		   lRet	:= .F.  
		   MsgInfo(OemToAnsi(STR0110) + TMP->CT2_EC05CR + OemToAnsi(STR0116) +TMP->CT2_LINHA + OemToAnsi(STR0112))//El NIT /  en credito de la linea  /  no existe
		EndIf
	Else
		If(CT2->(dbSeek( 'CT2_EC05CR' )), cDescri := X3DESCRIC(),'')	
		lRet	:= .F.  
		MsgInfo(OemToAnsi(STR0117) + cDescri + OemToAnsi(STR0114) + TMP->CT2_LINHA + OemToAnsi(STR0115))	//El Campo NIT de Credito( / ) de la linea /  esta vacío 
			  
	EndIf
EndIf     
RestArea(aArTrab)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³MyPesqPict  ³ Autor ³ Eduardo K.          ³ Data ³29/09/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento para evitar o desposicionamento de registros    ³±±
±±³          ³ ao executar a função PesqPict							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

Static Function MyPesqPict(cTab,cCampo)

local cPict
Local aArea	   := GetArea()
Local aAreaSX3 := SX3->(GetArea())

cPict := PesqPict(cTab,cCampo)

RestArea(aAreaSX3)
RestArea(aArea)

Return cPict
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbPRegra ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao da procedure para verificar se a contraregra esta   º±±
±±º          ³contido na regra quando parametro MV_CTBAMAR = 1 (PADRAO)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbPFilial(cProc)
Local lRet := .T.
Local cRet := ""
Local cQuery := ""
Local aSaveArea := GetArea()

DEFAULT cProc := CriaTrab(,.F.)

cQuery :="Create procedure "+cProc+"_"+cEmpAnt +CRLF
cQuery +="( "+CRLF
cQuery +="  @IN_ALIAS        Char(03),"+CRLF
cQuery +="  @IN_FILIALCOR    Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" ),"+CRLF
cQuery +="  @OUT_FILIAL      Char( "+Alltrim(Str(Len(CT1->CT1_FILIAL)))+" ) OutPut"+CRLF
cQuery +=")"+CRLF
cQuery +="as"+CRLF

/* -------------------------------------------------------------------
    Versão      -  <v> Genérica </v>
    Assinatura  -  <a> 010 </a>
    Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

    Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
                        @IN_FILIALCOR    - Filial corrente </ri>

    Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
                   <o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

    Responsavel :  <r> Alice Yaeko </r>
    Data        :  <dt> 14/12/10 </dt>
   
   X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
   -------- ------- --------- ---------- --------- -------- ---------
   CT2      E       E         E          3.0       3.0        2.0       
      X2_CHAVE   - Tabela
      X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
      X2_MODOUN  - Comparti/o da Unidade de Negócio, 'E' exclusivo e 'C' compartilhado
      X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
      X2_TAMFIL  - Tamanho da Filial
      X2_TAMUN   - Tamanho da Unidade de Negocio
      X2_TAMEMP  - tamanho da Empresa
   
   Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
   Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
   Compartilhamentos e tamanhos possíveis
   compartilhaemnto         tamanho ( zero ou nao zero)
   EMP UNI FIL             EMP UNI FIL
   --- --- ---             --- --- ---
    C   C   C               0   0   X   -- 1 - somente filial
    E   C   C               0   X   X   -- 2 - filial e unidade de negocio
    E   E   C               X   0   X   -- 3 - empresa e filial
    E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
------------------------------------------------------------------- */
cQuery +="Declare @cModo    Char( 01 )"+CRLF
cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
cQuery +="Declare @iTamFil  Integer"+CRLF
cQuery +="Declare @iTamUn   Integer"+CRLF
cQuery +="Declare @iTamEmp  Integer"+CRLF

cQuery +="begin"+CRLF
  
cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF
  
cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
cQuery +="    From SX2"+cEmpAnt+"0 "+CRLF
cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
cQuery +="     and D_E_L_E_T_ = ' '"+CRLF
  
  /*   SITUACAO -> 1 somente FILIAL */
cQuery +="  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2 ) begin"+CRLF   //  -- so tem filial tam 2
cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
cQuery +="  end else begin"+CRLF
    /*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
cQuery +="    If @iTamEmp = 0 begin"+CRLF
cQuery +="      If @cModoUn = 'E' begin"+CRLF
cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end else begin"+CRLF
      /* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
cQuery +="      If @iTamUn > 0 begin"+CRLF
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModoUn = 'E' begin"+CRLF
cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
cQuery +="          end else begin"+CRLF
cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="          end"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end else begin"+CRLF
        /*  SITUACAO -> 3 EMPRESA e FILIAL */
cQuery +="        If @cModoEmp = 'E' begin"+CRLF
cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
cQuery +="        end"+CRLF
cQuery +="      end"+CRLF
cQuery +="    end"+CRLF
cQuery +="  end"+CRLF
cQuery +="end"+CRLF
cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query da filial nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		cRet := TcSqlExec(cQuery)
		If cRet <> 0
			If !__lBlind
				MsgAlert("Erro na criacao da proc filial: "+cProc)
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtPrcPesq    ºAutor ³ TOTVS           º Data ³  30/03/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna se Pesquisa  linha, no doc e lote  por procedure   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtPrcPesq()
Local lRet := .F.

If Alltrim(Upper(TcGetDb())) $ "MSSQL7|DB2"
	If _lProcPsqCT2 == NIL
		lRet := .F.
	Else
		lRet := _lProcPsqCT2            //variavel static q esta .T. quando criada a procedure de pesquisa
	EndIf
EndIf
 
Return( lRet )
//-------------------------------------------------------------------------------------------------------//                                      
//exemplo de utilizacao no ctbxatu em vez do MsSeek 
/*
If  CtPrcPesq()
	lRetorno := CtCT2Psq( dDataLanc, cLote, cSubLote, cDoc, cLinha, cTpSld, cEmpOri, cFilOri, cMoeda )
Else
	//lRetorno := MsSeek(cChave)
	lRetorno := dbSeek(cChave) //alterado para dbSeek por conta de performance
EndIf
*/
//-------------------------------------------------------------------------------------------------------//                                      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtCT2Psq    ºAutor ³ TOTVS           º Data ³  30/03/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Executa Procedure Pesquisa  linha, no doc e lote           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³   ExpD1 - Data do Lançamento                               º±±                                                                     ic
±±º          ³   ExpC2 - Lote                                             º±±
±±º          ³   ExpC3 - SubLote                                          º±±
±±º          ³   ExpC4 - Documento                                        º±±
±±º          ³   ExpC5 - Linha                                            º±±
±±º          ³   ExpC6 - Tipo de Saldo                                    º±±
±±º          ³   ExpC7 - Empresa Origem                                   º±±
±±º          ³   ExpC8 - Filial Origem                                    º±±
±±º          ³   ExpC9 - Moeda                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtCT2Psq( dDataLanc, cLote, cSubLote, cDoc, cLinha, cTpSld, cEmpOri, cFilOri, cMoeda )
Local lRet := .F. 

If _lProcPsqCT2
		// Executar procedure
		aResult	:= TCSPEXEC( 	xProcedures( _PrCT2Psq ),;
								xFilial("CT2"),;				//xFilial CT2
								DtoS( dDataLanc ),;				//Data 
	 							cLote,;					        //Lote
	 							cSubLote,;					    //SubLote
	 							cDoc,;						    //Doc
	 							cLinha,;					    //Linha
	 							cTpSld,;						//Tipo de Saldo
	 							cEmpOri,;						//Empresa Origem
	 							cFilOri,;						//Filial Origem
	 							cMoeda )				        //Moeda

		If Empty( aResult )
			If !__lBlind
				MsgAlert( "Erro executando a Stored Procedure Pesquisa Linha CT2" + " " + _PrCT2Psq + ": " + TCSqlError() ) // "Erro executando a Stored Procedure"
			EndIf

		ElseIf aResult[1] != '0'
			lRet := .T.
			If aResult[2] > 0
				CT2->( dbGoto(aResult[2]) )  //caso encontrou registro posiciona na CT2
			EndIf
		
		EndIf
EndIf

Return(lRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtPrCT2Psq   ºAutor ³ TOTVS           º Data ³  30/03/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Criacao da Procedure Pesquisa  linha, no doc e lote        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³   Expc1 - Nome da Procedure                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtPrCT2Psq( cProcCT2P )
Local lRet      := .T.
Local cQuery    := ""
Local nRet		:= 0

Default cProcCT2P := CriaTrab(,.F.)

cQuery := "Create procedure "+cProcCT2P+"_"+cEmpAnt+" ("+CRLF
cQuery += "   @IN_cFILCT2  	char("+Alltrim(Str(Len(CT2->CT2_FILIAL)))+"),"+CRLF  
cQuery += "   @IN_cDATA  	char(8),"+CRLF  
cQuery += "   @IN_cLOTE  	varchar("+Alltrim(Str(Len(CT2->CT2_LOTE)))+"),"+CRLF  
cQuery += "   @IN_cSUBLOTE  varchar("+Alltrim(Str(Len(CT2->CT2_SBLOTE)))+"),"+CRLF  
cQuery += "   @IN_cDOC      varchar("+Alltrim(Str(Len(CT2->CT2_DOC)))+"),"+CRLF  
cQuery += "   @IN_cLINHA     varchar("+Alltrim(Str(Len(CT2->CT2_LINHA)))+"),"+CRLF  
cQuery += "   @IN_cTPSALD   varchar("+Alltrim(Str(Len(CT2->CT2_TPSALD)))+"),"+CRLF  
cQuery += "   @IN_cEMPORI   varchar("+Alltrim(Str(Len(CT2->CT2_EMPORI)))+"),"+CRLF  
cQuery += "   @IN_cFILORI   varchar("+Alltrim(Str(Len(CT2->CT2_FILORI)))+"),"+CRLF  
cQuery += "   @IN_cMOEDLC   varchar("+Alltrim(Str(Len(CT2->CT2_MOEDLC)))+"),"+CRLF  
cQuery += "   @OUT_RESULT   varchar( 1 ) OutPut,"+CRLF  
cQuery += "   @OUT_RESULT2  integer OutPut"+CRLF  

cQuery += ")"+CRLF
cQuery += "as"+CRLF

cQuery += "Declare @nRecCT2  integer " +CRLF
cQuery += "Declare @iRecno   integer " +CRLF

cQuery += "Begin " + CRLF
cQuery += " " + CRLF

cQuery += "SELECT @OUT_RESULT = '0' " +CRLF
cQuery += "SELECT @OUT_RESULT2 = 0 " +CRLF

cQuery += "SELECT @nRecCT2 = 0 " +CRLF

cQuery += "SELECT @nRecCT2 = ISNULL(R_E_C_N_O_,0) " +CRLF
cQuery += "  FROM " + RetSqlName("CT2") + " CT2 " +CRLF
cQuery += " WHERE CT2_FILIAL = @IN_cFILCT2 " +CRLF
cQuery += "   AND CT2_DATA   = @IN_cDATA " +CRLF
cQuery += "   AND CT2_LOTE   = @IN_cLOTE " +CRLF
cQuery += "   AND CT2_SBLOTE = @IN_cSUBLOTE " +CRLF 
cQuery += "   AND CT2_DOC    = @IN_cDOC " +CRLF 
cQuery += "   AND CT2_LINHA  = @IN_cLINHA " +CRLF 
cQuery += "   AND CT2_TPSALD = @IN_cTPSALD " +CRLF 
cQuery += "   AND CT2_EMPORI = @IN_cEMPORI " +CRLF
cQuery += "   AND CT2_FILORI = @IN_cFILORI " +CRLF 
cQuery += "   AND CT2_MOEDLC = @IN_cMOEDLC " +CRLF 
cQuery += "   AND D_E_L_E_T_ = ' ' " +CRLF

cQuery += "If @nRecCT2 > 0 begin " + CRLF
cQuery += "select @OUT_RESULT = '1' "+CRLF
cQuery += "select @OUT_RESULT2 = @nRecCT2 "+CRLF
cQuery += "end else begin "+CRLF 
cQuery += "select @OUT_RESULT = '0' "+CRLF 
cQuery += "end "+CRLF 

cQuery += "End " + CRLF

cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery, 0)

If Empty( cQuery )
	MsgAlert(MsParseError(),"A query de pesquisa da Proxima linha, lote, doc nao passou pelo Parse "+cProcCT2P)
	lRet := .F.
Else
	If !TCSPExist( cProcCT2P )
		nRet := TcSqlExec(cQuery)
		If nRet <> 0
			If !IsBlind()
				MsgAlert("Erro na criacao da procedure Pesquisa linha, lote, doc "+cProcCT2P)
				MsgAlert(MsParseError())
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ C105DelTmp   ºAutor ³ TOTVS           º Data ³  06/02/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Excluir o TMP criado pela função CTB105Cria                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C105DelTmp()
//Deleta tabela temporaria no banco, caso ja exita
	If _oCTBA105 <> Nil
		_oCTBA105:Delete()
		_oCTBA105 := Nil
	Endif
REturn
