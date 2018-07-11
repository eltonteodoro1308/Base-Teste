#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBXVLD.CH"

#DEFINE BLQ_FILIAL		1
#DEFINE BLQ_ALIAS		2
#DEFINE BLQ_CODENTD		3
#DEFINE BLQ_DTBLIN		4
#DEFINE BLQ_DTBLFI		5
#DEFINE BLQ_DTEXIS		6
#DEFINE BLQ_DTEXSF		7
#DEFINE BLQ_ARRAYDT		8
#DEFINE BLQ_PLANO		9

STATIC __lConOutR
STATIC __aDtComp   		:= {}
STATIC __aDtInUse  		:= {}
STATIC __CtbAmarra 		:= {}
STATIC __CtbPosic 		:= {}
STATIC __aCtbUso		:= {}
STATIC __aCtbMInUse 	:= {}
STATIC __aCtbDtInUse	:= {}
STATIC __aCtbValidDt	:= {}
STATIC __aCtbVlDtCal    := {}

//entidades bloqueadas Conta/Centro de Custo/Item contabil/Classe de valor
STATIC _aEntdBloq		:=	{}

STATIC aCtbIni 	 		:= {}
STATIC lBlind			:= IsBlind()
STATIC lFWCodFil 		:= .T.

STATIC lOracle
STATIC lPostgres
STATIC lDB2
STATIC lInformix
STATIC cSrvType
STATIC cTipoDB
STATIC cOp_Concat  		:= Ctb_Oper_Concat()

STATIC cVerSP169		:= "001"

STATIC nQtdEntid 				//Quantidade de entidades

STATIC __CtbSixCTA 	:= CtbSixCTA()

STATIC __cFilCTO		:= ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidaBloq³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 07.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se Entidade Contabil esta bloqueada pela data       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidaBloq(cEntidade,dDAta,cAlias)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Entidade                                           ³±±
±±³          ³ ExpD1 = Data                                               ³±±
±±³          ³ ExpC2 = Alias                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValidaBloq(cEntidade,dData,cAlias,lHelp,cIdEntid,cPlano)

Local aSaveArea:= GetArea()
Local lRet		:= .T.
Local lCtbExDtFim := CtbExDtFim(cAlias)
Local nElem, nPosElem
Local cQuery := ""
Local cCampo := ""
Local lBloqEnt
Local dDtBlqIni
Local dDtBlqFim
Local dDtExist
Local bBloq
Local lCache := CtbCache(8)

DEFAULT lHelp := .T.
DEFAULT cIdEntid := ""
DEFAULT cPlano := ""

iF ! (cAlias $ "CT1/CTT/CTD/CTH/CV0")
	Return(lRet)
EndIf

If !Empty(cEntidade)
	If lCache
		If cAlias == "CV0"
			nElem := aScan(_aEntdBloq,{|x| x[1]+x[2]+x[3]+x[9] == xFilial(cAlias)+cAlias+cEntidade+cPlano})
		Else
			nElem := aScan(_aEntdBloq,{|x| x[1]+x[2]+x[3] == xFilial(cAlias)+cAlias+cEntidade })
		EndIf
		If nElem > 0
			nPosElem := aScan(_aEntdBloq[nElem,BLQ_ARRAYDT], DTOS(dData))
			If nPosElem > 0
				lRet := .F.
			Else
				//valida com base no array ja populado pela query
				lBloqEnt 	:= .T.
				dDtBlqIni 	:= STOD( _aEntdBloq[nElem,BLQ_DTBLIN] )
				dDtBlqFim 	:= STOD( _aEntdBloq[nElem,BLQ_DTBLFI] )
				dDtExist 	:= STOD( _aEntdBloq[nElem,BLQ_DTEXIS] )
				lRet := CtbVlDtBlq(cAlias, cEntidade, lHelp, lBloqEnt, dData, dDtBlqIni, dDtBlqFim)
				lRet := lRet .And. CtbVlDtExi(dData, dDtExist, lHelp)
				lRet := lRet .And. lCtbExDtFim .And. CtbVlDtExF(cAlias, dData,lHelp) //se existe o campo CT1_DTEXSF
				If !lRet
					aAdd( _aEntdBloq[nElem,BLQ_ARRAYDT], DTOS(dData) )
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet
		//query para verificar se existe bloqueio de entidade
		If cAlias == 'CT1'
			cCampo := "CT1_CONTA"
		ElseIf cAlias == 'CTT'
			cCampo := "CTT_CUSTO"
		ElseIf cAlias == 'CTD'
			cCampo := "CTD_ITEM"
		ElseIf cAlias == 'CTH'
			cCampo := "CTH_CLVL"
		ElseIf cAlias == 'CV0'
			cCampo := "CV0_CODIGO"
		EndIf
		
		cQuery := " SELECT "
		cQuery += cAlias+"_FILIAL FILIAL, "
		cQuery += "'"+cAlias+"' ALIASTAB, "
		cQuery += cCampo+" CODENTD, "
		If cAlias == "CV0"
			cQuery += cAlias+"_DTIBLQ DTBLIN, "
			cQuery += cAlias+"_DTFBLQ DTBLFI, "
			cQuery += cAlias+"_DTIEXI DTEXIS  "
			If lCtbExDtFim
				cQuery += ", "+cAlias+"_DTFEXI DTEXSF "
			EndIf
		Else
			cQuery += cAlias+"_DTBLIN DTBLIN, "
			cQuery += cAlias+"_DTBLFI DTBLFI, "
			cQuery += cAlias+"_DTEXIS DTEXIS  "
			If lCtbExDtFim
				cQuery += ", "+cAlias+"_DTEXSF DTEXSF "
			EndIf
		EndIf
		cQuery += "  FROM " + RetSqlName(cAlias)
		cQuery += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cQuery += "   AND " + cCampo + " = '" + cEntidade + "' "

		If cAlias == "CV0"
			cQuery += " AND  "+cAlias+"_PLANO = '"+cPlano+"' "
			cQuery += " AND ( "+cAlias+"_BLOQUE = '1' "
			cQuery += " OR (" +cAlias+"_DTIBLQ <> ' ' AND "+cAlias+"_DTFBLQ <> ' ' AND '"+DTOS(dData)+"' BETWEEN "+cAlias+"_DTIBLQ AND "+cAlias+"_DTFBLQ ) "
			cQuery += " OR ( (" +cAlias+"_DTIEXI <> ' ' AND '"+DTOS(dData)+"' < "+cAlias+"_DTIEXI )"
			If lCtbExDtFim
				cQuery += " OR (" +cAlias+"_DTFEXI <> ' ' AND '"+DTOS(dData)+"'  > "+cAlias+"_DTFEXI ) ) "
			Else
				cQuery += " ) "
			EndIf
		Else
			cQuery += " AND ( "+cAlias+"_BLOQ = '1' "
			cQuery += " OR (" +cAlias+"_DTBLIN <> ' ' AND "+cAlias+"_DTBLFI <> ' ' AND '"+DTOS(dData)+"' BETWEEN "+cAlias+"_DTBLIN AND "+cAlias+"_DTBLFI ) "
			cQuery += " OR ( (" +cAlias+"_DTEXIS <> ' ' AND '"+DTOS(dData)+"' < "+cAlias+"_DTEXIS )"
			If lCtbExDtFim
				cQuery += " OR (" +cAlias+"_DTEXSF <> ' ' AND '"+DTOS(dData)+"'  > "+cAlias+"_DTEXSF ) ) "
			
			Else
				cQuery += " ) "
			EndIf
		EndIf
		cQuery += " ) "
		cQuery += " AND D_E_L_E_T_ = ' ' "			

		//cQuery := ChangeQuery(cQuery)   //retirado para melhoria de performance
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias+"BLOQ",.T.,.F.)
		
		lRet := (cAlias+"BLOQ")->( Eof() )  //se nao encontrou bloqueio da entidade na query
		
		If !lRet  //caso encontre algum registro bloqueado validar data de vigencia 	
			If  ( !Empty((cAlias+"BLOQ")->DTBLIN).And.DTOS(dData)<(cAlias+"BLOQ")->DTBLIN ) .OR. ; //DATA FOR MENOR QUE DATA DE INICIO
				( !Empty((cAlias+"BLOQ")->DTBLFI).And.DTOS(dData)>(cAlias+"BLOQ")->DTBLFI )        //OU DATA FOR MAIOR QUE DATA FIM  				
				lRet = .T.
			Endif
		Endif
		
		If ! lRet .And. lCache
			//se encontrou entidade com bloqueio na query - armazena no array para validacao futura
			aAdd(_aEntdBloq, array(9) )
			nElem := Len(_aEntdBloq)
			_aEntdBloq[nElem,BLQ_FILIAL] := (cAlias+"BLOQ")->FILIAL
			_aEntdBloq[nElem,BLQ_ALIAS] := (cAlias+"BLOQ")->ALIASTAB
			_aEntdBloq[nElem,BLQ_CODENTD] := (cAlias+"BLOQ")->CODENTD
			_aEntdBloq[nElem,BLQ_DTBLIN] := (cAlias+"BLOQ")->DTBLIN
			_aEntdBloq[nElem,BLQ_DTBLFI] := (cAlias+"BLOQ")->DTBLFI
			_aEntdBloq[nElem,BLQ_DTEXIS] := (cAlias+"BLOQ")->DTEXIS
			_aEntdBloq[nElem,BLQ_DTEXSF] := If( lCtbExDtFim, (cAlias+"BLOQ")->DTEXSF, Space(8) )
			_aEntdBloq[nElem,BLQ_ARRAYDT] := {}
			_aEntdBloq[nElem,BLQ_PLANO] := cPlano
			aAdd( _aEntdBloq[nElem,BLQ_ARRAYDT], DTOS(dData) )
		EndIf
		
		dbSelectArea(cAlias+"BLOQ")
		dbCloseArea()
		
	EndIf
	
	If !lRet .And. lHelp
		Help( " " , 1 , "CTA_BLOQ" ,, cAlias + " :" + cEntidade ,3,0)
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet
//----------------------------------------------------------------------------------------------------//
Static Function CtbVlDtBlq(cAlias, cEntidade, lHelp, lBloqEnt, dData, dDtBlqIni, dDtBlqFim)

Local lRet := .F.

If lBloqEnt
	If(((((DTOS(dData))<(DTOS(dDtBlqIni))).And.(!Empty(DTOS(dDtBlqIni)))).Or. (((DTOS(dData))>(DTOS(dDtBlqFim))).And.(!Empty(DTOS(dDtBlqFim))))))
		lRet := .T.
	else
		If lHelp
			Help( " " , 1 , "CTA_DTBLOQ" ,, cAlias + " :" + cEntidade ,3,0)
		EndIf
		lRet := .F.
	EndIf
Else
	lRet := .T.
EndIf

Return(lRet)
//----------------------------------------------------------------------------------------------------//
Static Function CtbVlDtExi(dData, dDtExist, lHelp)
Local lRet := .F.

If DTOS(dData) < DTOS(dDtExist)
	// Data do lancamento menor do que a data de existencia da conta
	If lHelp
		Help("  ", 1, "CTA_DTEXIS")
	EndIf
	lRet := .F.
Else
	lRet := .T.
EndIf

Return(lRet)
//----------------------------------------------------------------------------------------------------//
Static Function CtbVlDtExF(cAlias, dData,lHelp)
Local lRet := .F.

lRet := CtbVlDtFim(cAlias,dData)

If !lRet .And. lHelp
	Help(" ",1,"CtbVlDtExF",,STR0001,1,0)// Data do lancamento maior do que a data final de existencia da entidade
EndIf

Return(lRet)
//----------------------------------------------------------------------------------------------------//


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidaValo³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Valor digitado                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidaValor(nValor)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor do Lancamento                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValidaValor(nValor)

Local nValorAnt	:= 0
Local lRet		:= .T.
Local aSaveArea:= GetArea()
Local nValLcto	:= 0
Local nCont		:= 0
Local cCriter	:= ""
Local lRedStorn	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn

If "CT2_VALOR" $ ReadVar()
	nValLcto    := M->CT2_VALOR
	nValorAnt	:= TMP->CT2_VALOR
ElseIf "CT2_VALR" $ ReadVar()
	nValLcto    := &("M->CT2_VALR" + Right(ReadVar(), 2))
	nValorAnt	:= &("TMP->CT2_VALR" + Right(ReadVar(), 2))
ElseIf IsInCallStack("Ctb102Repla")	
	nValLcto	:= nValor		
	nValorAnt	:= TMP->CT2_VALOR
Endif

If TMP->CT2_DC $ "123"
	If nValLcto <> nValorAnt
		If cPaisLoc == "RUS"
			If nValorAnt = 0 .And. ((nValLcto > 0 .and. !lRedStorn) .or. (nValLcto <> 0 .and. lRedStorn))	//Se o valor anterior era zero e alterei para outro valor
				TMP->CT2_CONVER	:= "1" + SUBS(TMP->CT2_CONVER,2,LEN(TMP->CT2_CONVER))
			ElseIf ((nValorAnt > 0 .and. !lRedStorn) .or. (nValorAnt <> 0 .and. lRedStorn)) .And. nValLcto = 0
				For nCont := 2 to __nQuantas
					If Subs(TMP->CT2_CONVER,nCont,1) = "4"
						cCriter += "4"
					Else
						cCriter	+= "5"
					EndIf
				Next
				TMP->CT2_CONVER	:= "5" + cCriter
			EndIf
		Else
			If nValorAnt = 0 .And. nValLcto > 0	//Se o valor anterior era zero e alterei para outro valor
				TMP->CT2_CONVER	:= "1" + SUBS(TMP->CT2_CONVER,2,LEN(TMP->CT2_CONVER))
			ElseIf nValorAnt > 0 .And. nValLcto = 0
				For nCont := 2 to __nQuantas
					If Subs(TMP->CT2_CONVER,nCont,1) = "4"
						cCriter += "4"
					Else
						cCriter	+= "5"
					EndIf
				Next
				TMP->CT2_CONVER	:= "5" + cCriter
			EndIf
		EndIf
	Endif
EndIf

If lRet
	If cPaisLoc == "RUS"
		If nValor < 0 .AND. !lRedStorn
			Help(" ",1,"POSIT")
			lRet := .F.
			nSaida++
		EndIf
	Else
		If nValor < 0
			Help(" ",1,"POSIT")
			lRet := .F.
			nSaida++
		EndIf
	EndIf
EndIf
If lRet
	IF nValor != 0 .and. TMP->CT2_DC == "4"
		Help(" ",1,"CONTHIST")
		lRet := .F.
		nSaida++
	End
EndIf

// Atualiza rodape -> MSGETDB => SOMENTE SE A LINHA NAO ESTIVER DELETADA!!!
If lRet .And. ! TMP->CT2_FLAG
	CTB102Exibe(nValor,nValorAnt,TMP->CT2_DC,TMP->CT2_DC,GetMv("MV_SOMA"))  //esta funcao encontra ctbxfun.prx
EndIf

RestArea(aSaveArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidaCrit³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Criterio de Conversao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidaCriter(cCriterio)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Criterio de Conversao                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValidaCriter(cCriterio,cProg,cTpSaldo)

Local nCont
Local lRet 		:= .T.
Local cCriterAnt:= ""
Local cCriterAtu:= ""
Local dData	:= CTOD("  /  /  ")
Local lShowHelp := !IsBlind()

Default cTpSaldo := ""

cProg	:= Iif(cProg == Nil,"",cProg)

lRet := !Empty(cCriterio)

If lRet	//Se for Lancam. Contab. por Folder considerar o acols
	If cProg == 'CTBA101'
		If aCols[n][1] ==  '01'			//Na moeda 01 nao podera digitar nada, so sera alterado qdo alterar
			If lShowHelp
				Help(" ",1,"ERRO_CRITE")	//o valor na moeda 01.
			EndIf
			Return .F.
		Else
			If !(cCriterio $ "123456789A")
				If lShowHelp
					Help(" ",1,"ERRO_CRITE")
				EndIf
				Return .F.
			Else
				//Verificar se existe amarracao moeda x calendario na moeda que esta alterando a conversao
				//So sera verificado se o criterio de conversao for diferente de "5" => Nao tem conversao.
				If cCriterio <> "5"
					If !Empty(dDataLanc)
						lRet := CtbDtComp(4,dDataLanc,aCols[n][1],lShowHelp,cTpSaldo)
						If !lRet
							Return .F.
						EndIf
					Endif
				EndIf
			EndIf
		Endif
	Else
		For nCont := 1 To Len(Trim(cCriterio))
			If nCont = 1//Na moeda 01 podera ser digitado somente 1 ou 5=>pois nao utiliza criterio de conversao
				cCriterAnt	:= Subs(TMP->CT2_CONVER,1,1)
				cCriterAtu	:= Subs(M->CT2_CONVER,1,1)
				//Na moeda 01, nao sera possivel alterar o criterio de conversao. O criterio so
				//sera alterado quando alterar o valor. ( na moeda 01)
				//				If !SubStr(cCriterio,nCont,1) $ "15"
				If cCriterAnt	<> cCriterAtu
					If lShowHelp
						Help(" ",1,"ERRO_CRITE")
					EndIf
					Return .F.
				EndIf
			Else
				IF !SubStr(cCriterio,nCont,1) $ "123456789A"
					If lShowHelp
						Help(" ",1,"ERRO_CRITE")
					EndIf
					Return .F.
				Else
					//Verificar se existe amarracao moeda x calendario na moeda que esta alterando a conversao
					//So sera verificado se o criterio de conversao for diferente de "5" => Nao tem conversao.
					If !SubStr(cCriterio,nCont,1) $ "5"
						If !Empty(TMP->CT2_DATA)
							dData	:= TMP->CT2_DATA
						ElseIf !Empty(dDataLanc)
							dData	:= dDataLanc
						EndIf
						If !Empty(dData)
							lRet := CtbDtComp(4,dData,StrZero(nCont,2),lShowHelp,cTpSaldo)
							If !lRet
								Return .F.
							EndIf
						Endif
					EndIf
				EndIf
			EndIf
		Next
	EndIf
Endif
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbValLig ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a amarracao de cadastros                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbValLig(cClasse)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Classe                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbValLig(cClasse)

Local aSaveArea := GetArea()
Local lRET		:= .T.

If cClasse == "1"
	Help(" ",1,"CTBNOLIG")
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbMInUse ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 19.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a moeda esta bloqueada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBMInUse(cMoeda)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Moeda                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBMInUse(cMoeda,lValidCTO)

Local aSaveArea := GetArea()
Local nPos
Local lRet		:= .T.
Local lCache := CtbCache(5)
Local cFuncao := Upper( AllTrim( FunName() ) )

Default lValidCTO := ( Substr(GetNewPar("MV_CTVBLOQ","111"),1,1) == "1" ) .And. ; // Parametro para indicar quais rotinas  passarão por esta validacao (DEFAULT 111-TODAS)
					 ( cFuncao $ Upper(GetNewPar("MV_CTFBLOQ",cFuncao))    ) 	// Parametro para indicar rotinas que passarão por esta validacao (DEFAULT TODAS)

If lValidCTO
	If lCache .And. !Empty(__aCtbMInUse) .And. ( nPos := aScan(__aCtbMInUse, {|x| x[1] == cMoeda } ) ) > 0 .And. __cFilCTO == cFilAnt
		lRet := __aCtbMInUse[nPos, 2]
	Else
		dbSelectArea("CTO")
		dbSetOrder(1)
		lRet := MsSeek(xFilial()+cMoeda)
		lRet := lRet .And. CTO->CTO_BLOQ != "1"		// Moeda Bloqueada
		If __cFilCTO <> cFilAnt
			__aCtbMInUse := {}
		Endif
		__cFilCTO := cFilAnt
		If lCache
			aAdd(__aCtbMInUse, {cMoeda, lRet})
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CtbDtInUse³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 19.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a data esta bloqueada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbDtInUse(cMoeda,dData)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 =Moeda												  ³±±
±±³			 ³ExpD1 =Data                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBDtInUse(cMoeda,dData, lValidCTP)

Local aSaveArea:= GetArea()
Local nPos
Local lRet		:= .T.
Local lCache := CtbCache(6)
Local cFuncao := Upper( AllTrim( FunName() ) )

Default lValidCTP := 	( Substr(GetNewPar("MV_CTVBLOQ","111"),3,1) == "1" ) .And. ;  // Parametro para indicar rotinas que passarão por validacao (DEFAULT 111-TODAS)
						( cFuncao $ Upper(GetNewPar("MV_CTFBLOQ",cFuncao))	 ) // Parametro para indicar rotinas que passarão por esta validacao (DEFAULT TODAS)

If lValidCTP
	If lCache .And. !Empty(__aCtbDtInUse) .And. ( nPos := aScan(__aCtbDtInUse, {|x| x[1]+DtoS(x[2]) == cMoeda+DtoS(dData) } ) ) > 0
		lRet := __aCtbDtInUse[nPos, 3]
	Else
		dbSelectArea("CTP")				/// CADASTRO DE CAMBIO DE MOEDAS
		dbSetOrder(1)
		lRet := MsSeek(xFilial("CTP")+DTOS(dData)+cMoeda)
		lRet := If(lRet, CTP->CTP_BLOQ != "1", .T.)		// "1" = Data Bloqueada para a moeda
		If lCache
			aAdd(__aCtbDtInUse, {cMoeda, dData, lRet})
		EndIf
	EndIf
EnDif

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CtbUso    ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 19.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o campo esta em uso.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbUso(ccampo)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 =Campo												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbUso(cCampo)
Local aSaveArea
Local lRet		:= .F.
Local aAreaSx3
Local nPosUso	:=	0
If (nPosUso	:=	Ascan(__aCTBUSO,{|x| x[1] == cCampo}) )> 0
	lRet	:=	__aCTBUSO[nPosUso,2]
Else
	aSaveArea:= GetArea()
	aAreaSx3 := SX3->(GetArea())
	dbSelectArea( "SX3" )
	dbSetOrder( 2 )
	If MsSeek( cCampo )
		If X3USO( X3_USADO )
			lRet := .t.
		EndIf
	EndIf
	AADD(__aCTBUSO,{cCampo,lRet})
	RestArea(aAreaSX3)
	RestArea(aSaveArea)
Endif
Return lRet

****************************************************************
*			VALIDACOES DA DATA
*			COMUM A CTBA105 E CTBA050
****************************************************************

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbDtComp ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verificacao da Data e Moeda                                 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbDtComp(nOpc,dData,cMoeda)                        		    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da opcao                                   		    ³±±
±±³          ³ ExpD1 = Data                                              		    ³±±
±±³          ³ ExpC1 = Moeda                                             		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbDtComp(nOpc,dData,cMoeda,lMessage,cTpSaldo)

Local lRet 		:= .T.
Local aSaveArea	:= GetArea()
Local nPos  	:= 0
Local lCache   := CtbCache(1)  //avalia se trabalha com cache
Local bPsqData 	:= {|x| 	x[1] == dData .and. ;
x[2] == cMoeda      }

Default lMessage:= !IsBlind()
Default cTpSaldo:= ""

If nOpc <> 2			// Inclusão / Alteração / Exclusão
	//procura no cache
	If lCache .And. ! Empty(__aDtComp) .And. ( nPos := Ascan( __aDtComp, bPsqData) ) > 0
		lRet := __aDtComp[nPos, 3]
	EndIf
	//se nao achou no cache nPos == 0 ou se tem q mostrar mensagem na tela invoca a funcao CtVlDTMoed
	If ( nPos == 0 .Or. lMessage) .And. CtVlDTMoed(dData,dData,2,cMoeda,lMessage,cTpSaldo)		///NOVA VALIDACAO CTO, CTG e CTP (CTBXFUNA)
		/// Se houver algo bloqueado (retorno .T.)
		lRet := .F.
	EndIf
EndIf

If lCache .And. nPos == 0   //so acrescenta se nao existe no cache
	aAdd( __aDtComp, { dData, cMoeda, lRet } )
EndIf

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBXFUNA  ºAutor  ³Marcos S. Lobo      º Data ³  10/25/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua validacoes das moedas e do intervalo de datas consid:º±±
±±º          ³Cad.Moedas, Cad.Calendario e Cad.Cambio de Moedas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtVlDTMoed(dDtIni,dDtFim,nMoedas,cQualMoeda,lShowMsg,cTpSaldo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Todas funcoes que atualizam lançamentos passam pelas     ³
//³seguintes funções:                                       ³
//³                                                         ³
//³CtbDtComp(CTBXFUN)                                       ³
//³  |                                 |Há chamadas diretas ³
//³CtbValiDT(CTBXFUN)                 /-------------------- ³
//³  |                               /                      ³
//³  --------> CtVlDtMoed(CTBXFUNA) /                       ³
//³                |    |-CtbDTInUse(CTBXFUN) //Valida CTP  ³
//³                |    |-CtbMInUnse(CTBXFUN) //Valida CTO  ³
//³                |                                        ³
//³                --------> VlDtCal(CTBA190)  // Valida CTG³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lBlocked 	:= .F.			///Retorno .T. se houver algum bloqueio / .F. se não houver
Local nCont 	:= 1
Local cCoin4	:= "01"
Local dDataAtu  := CTOD("01/01/80")
Local lValidCTO := .T.				/// Indica que ira efetuar validação do Cad. Moedas
Local lValidCTG	:= .T.				/// Indica que ira efetuar validação do Calendário
Local LValidCTP := .T.				/// Indica que ira efetuar validação do Cambio.

Local cCodEmp	:= FWGRPCompany()
Local cNomeEmp := FWFilialName(cEmpAnt,cFilAnt,2)
Local cCodFil	:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
Local cNomeFil	:= FWFilialName(cEmpAnt,cFilAnt,1)
Local cDadosSM0 := SM0->(cCodEmp+"/"+cCodFil+" ("+ALLTRIM(cNomeEmp)+"/"+ALLTRIM(cNomeFil)+")")

Local aDatasBlq := {}
Local lRet 	:= .F.
Local cFuncao := Upper( AllTrim( FunName() ) )
Local cValids := GetNewPar("MV_CTVBLOQ","111")			/// Parametro para indicar quais serão as verificações de bloqueio efetuadas (DEFAULT TODAS CTO, CTG e CTP).
Local cFunc2Chk := GetNewPar("MV_CTFBLOQ",cFuncao)	/// Parametro para indicar rotinas que passarão pelas validacoes (DEFAULT TODAS)

DEFAULT lShowMsg:= !lBlind
DEFAULT nMoedas := If(!Empty(cQualMoeda),2,1)
DEFAULT cTpSaldo:= ""

//aDatasBlq eh para mostrar no list box as datas com moedas bloqueadas
aAdd(aDatasBlq,cDadosSM0)
aAdd(aDatasBlq,Padr(STR0002,10)+STR0003)//"Moeda"#"Data"

If Type("__nQuantas") <> "N" .or. __nQuantas <= 0
	__nQuantas := CtbMoedas()
EndIf

If Empty(cValids) .or. Len(alltrim(cValids)) < 3
	cValids := Padr(alltrim(cValids),3,"1")
EndIf

lValidCTO := ( Substr(cValids,1,1) == "1" ) /// 1ª POSIÇÃO VALIDACAO CTO (CtbMInUse(CTBXFUN))
lValidCTG := ( Substr(cValids,2,1) == "1" ) /// 2ª POSIÇÃO VALIDACAO CTG (VlDtCal(CTBA190))
lValidCTP := ( Substr(cValids,3,1) == "1" ) /// 3ª POSIÇÃO VALIDACAO CTP (CtbDtInUse(CTBXFUN))

If cFuncao $ Upper(AllTrim(cFunc2Chk))
	If lValidCTO
		If __nQuantas <= 0
			If lShowMsg
				Help(" ",1,"NOMOEDCTO")
			EndIf
			lBlocked := .T.
		Else
			For nCont := 1 to __nQuantas	/// Roda todas as moedas
				If nMoedas == 2
					cCoin4	:= cQualMoeda
				Else
					cCoin4 	:= Alltrim(strzero(int(nCont),2))
				EndIf
				
				If !CTBMInUse(cCoin4, lValidCTO) /// Verifica Moeda no CTO ausencia ou bloqueio.
					If lShowMsg
						MsgInfo(STR0003+" "+cCoin4+STR0004+CRLF+CRLF+STR0005,STR0006+" |"+cDadosSM0 )///"Moeda"#" bloqueada."#"Verifique bloqueio(s), ou selecione moeda(s) e intervalo de data não bloqueados."#"Cadastro de Moedas."
					EndIf
					lBlocked := .T.
					Exit
				EndIf
				
				If nMoedas == 2
					Exit
				EndIf
			Next
		EndIf
	EndIf
	
	/// Verifica Status de bloqueio no cadastro do calendário CTG (pela amarração das moedas)
	If !lBlocked .And. lValidCTG
		lBlocked := !VlDtCal(dDtIni,dDtFim,nMoedas,cQualMoeda,"234", lShowMsg,cTpSaldo )
	EndIf
	
	/// Verifica Status de bloqueio no cadastro de cambio CTP (DATA+MOEDA)
	If !lBlocked .And. lValidCTP
		For nCont := 1 to __nQuantas	/// Roda todas as moedas
			If nMoedas == 2
				cCoin4	:= cQualMoeda
			Else
				cCoin4 	:= Alltrim(strzero(int(nCont),2))
			EndIf
			
			cQuery := " SELECT "
			cQuery += " CTP_FILIAL, "
			cQuery += " CTP_MOEDA, "
			cQuery += " CTP_DATA "
			cQuery += " FROM " + RetSqlName("CTP")+" CTP "
			cQuery += " WHERE "
			cQuery += " CTP.D_E_L_E_T_ = ' ' "
			cQuery += " AND CTP_FILIAL = '"+xFilial("CTP")+"' "
			cQuery += " AND CTP_MOEDA = '"+cCoin4+"' "
			cQuery += " AND CTP_DATA >= '"+DTOS(dDtIni)+ "' "
			cQuery += " AND CTP_DATA <= '"+DTOS(dDtFim)+ "' "
			cQuery += " AND CTP_BLOQ = '1' "		// "1" = Data Bloqueada para a moeda
			//RETIRADO PARA PERFORMANCE - ANSI NAO HA NECESSIDADE DE PASSAR PELA CHANGEQUERY	
			If ! ( Alltrim(Upper(TCGetDB())) $ "MSSQL|MSSQL7|ORACLE" )
				cQuery := ChangeQuery(cQuery)
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CTPBLOQ",.T.,.F.)
			
			lRet := CTPBLOQ->(! Eof() )
			
			If lRet
				lBlocked := .T.
				If lShowMsg
					While CTPBLOQ->(! Eof() )
						aAdd(aDatasBlq,Padr(cCoin4,10)+" "+DTOC(STOD(CTPBLOQ->CTP_DATA)))
						CTPBLOQ->( dbSkip() )
					EndDo
				EndIf
			EndIf
			
			dbSelectArea("CTPBLOQ")
			dbCloseArea()
			
			If !lShowMsg .And. lBlocked
				Exit
			EndIf
			
			If nMoedas == 2
				Exit
			EndIf
		Next  //nCont
		
		If lBlocked .and. lShowMsg
			If MsgYesNo(STR0007+CRLF+CRLF+STR0010+CRLF+STR0008,STR0009+"|"+cDadosSM0)//"Existem datas bloqueadas no período para a(s) moeda(s) selecionadas."#"Visualizar ?"#"Cadastro de Cambio de Moedas"
				CtbShowLst(STR0011+STR0012,aDatasBlq)//"Moedas com Datas Bloqueadas - "#"Cadastro de Cambio de Moedas"
			EndIf
		EndIf
		
	EndIf
EndIf

Return lBlocked


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VlDtCal   ºAutor  ³Marcos S. Lobo      º Data ³  05/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validação do intervalo de datas checando se o      º±±
±±º          ³calendario contabil esta bloqueado (conteúdo de MV_CTGBLOQ).º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ dDtIni = Data Inicial do Intervalo                         º±±
±±º          ³ dDtFim = Data Final do Intervalo                           º±±
±±º          ³ nTMoedas = 1 p/ todas as moedas / 2= Moeda Específica      º±±
±±º          ³ cMoeda = Codigo da Moeda específica                        º±±
±±º          ³ lMensagem = Indica se pode exibir mensagem                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VlDtCal(dDtIni,dDtFim,nTMoedas,cMoeda,cStatBlq,lMensagem,cTpSaldo)

Local lDatasOk	:= .T.
Local aCalends	:= {}
Local nCal		:= 1
Local nQ		:= 1
Local lFoundCTG := .F.
Local cQuery 	:= ""
Local nLenStat
Local nX
Local lRet 		:= .F.
Local nPos      := 0
Local lCache := CtbCache(7)

DEFAULT cStatBlq	:= GetNewPar("MV_CTGBLOQ","234")	/// INDICA OS STATUS DE CALENDARIO QUE NÃO PERMITEM REPROCESSAR
DEFAULT dDtIni 		:= dDataBase
DEFAULT dDtFim 		:= dDataBase
DEFAULT nTMoedas	:= 2
DEFAULT cMoeda		:= "01"
DEFAULT lMensagem	:= .T.
DEFAULT cTPSaldo		:= ""

If lCache .And. Len(__aCtbVlDtCal) > 0  .And. ( nPos := aScan(__aCtbVlDtCal,{|x|  	x[1] == dDtIni .And. ;
																		x[2] == dDtFim .And. ;
																		x[3] == nTMOedas .And. ;
																		x[4] == cMoeda .And. ;
																		x[5] == cStatBlq .And. ;
																		x[6] == lMensagem .And. ;
																		x[7] == cTpSaldo } ) ) > 0
	lDatasOk := __aCtbVlDtCal[nPos, 8]
																		
	If !lDatasOk .And. lMensagem
		//"O intervalo de datas informadas não poderá ser processado. "#"Verifique o intervalo de datas ou os calendários no intervalo."
		//"Moeda "#", o periodo "#" do calendario "#" está Bloqueado/Encerrado."
		MsgInfo(STR0013,STR0014)
	EndIf
Else																		

	__nQuantas 	:= CtbMoedas()
	cStatBlq 	:= Alltrim(cStatBlq)
	nLenStat 	:= Len(cStatBlq)

	
	For nQ := 1 to __nQuantas
		If nTMoedas == 2			/// SE FOR MOEDA ESPECÍFICA
			nQ := Val(cMoeda)
		Else						/// SE FOR PARA TODAS AS MOEDAS
			cMoeda := StrZero(nQ,2)
		Endif
	
		If dDtIni <> dDTFim
			
			If nLenStat > 0
				cQuery := " SELECT "
				cQuery += " CTE_FILIAL, "
				cQuery += " CTE_MOEDA, "
				cQuery += " CTG_DTINI, "
				cQuery += " CTG_DTFIM, "
				cQuery += " CTG_CALEND, "
				cQuery += " CTG_PERIOD  "
				cQuery += " FROM " + RetSqlName("CTE")+" CTE, "+ RetSqlName("CTG")+" CTG "
				cQuery += " WHERE CTE_CALEND = CTG_CALEND "
				cQuery += "   AND CTE_FILIAL = '"+xFilial("CTE")+"' "
				cQuery += "   AND CTE_MOEDA = '"+cMoeda+"' "
				cQuery += "   AND CTE.D_E_L_E_T_ = ' ' "
				cQuery += "   AND CTG_FILIAL = '"+xFilial("CTG")+"' "
				cQuery += "   AND CTG_STATUS IN ('"
				For nX := 1 TO nLenStat
					cQuery += Substr(cStatBlq, nX, 1) + If( nX<nLenStat, "','", "" )
				Next
				cQuery += "')"
				cQuery += "   AND CTG.D_E_L_E_T_ = ' ' "
				
		   			//RETIRADO PARA PERFORMANCE - ANSI NAO HA NECESSIDADE DE PASSAR PELA CHANGEQUERY	
					If ! ( Alltrim(Upper(TCGetDB())) $ "MSSQL|MSSQL7|ORACLE" )
						cQuery := ChangeQuery(cQuery)
					EndIf
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CTEBLOQ",.T.,.F.)
				TcSetField("CTEBLOQ","CTG_DTINI","D",8,0)
				TcSetField("CTEBLOQ","CTG_DTFIM","D",8,0)
				
				lRet := CTEBLOQ->(! Eof() )
				
				If lRet
					While CTEBLOQ->(! Eof() )
						aAdd(aCalends,{CTEBLOQ->CTG_DTINI,CTEBLOQ->CTG_DTFIM,CTEBLOQ->CTG_CALEND,CTEBLOQ->CTG_PERIOD,CTG->CTG_EXERC})
						CTEBLOQ->( dbSkip() )
					EndDo
				EndIf
				
				dbSelectArea("CTEBLOQ")
				dbCloseArea()
				
			EndIf
			//se nao conseguiu resolver na query para exibir mensagens coerentes
			If ! lRet
				dbSelectArea("CTE")
				dbSetOrder(1)
				If MsSeek(xFilial("CTE")+cMoeda,.F.)
					While CTE->(!Eof()) .And. CTE->CTE_FILIAL == xFilial("CTE") .and. CTE->CTE_MOEDA == cMoeda
						dbSelectArea("CTG")
						dbSetOrder(2)
						If MsSeek(xFilial("CTG")+CTE->CTE_CALEND,.F.)
							lFoundCTG := .T.
							While !Eof() .and. CTG->CTG_CALEND == CTE->CTE_CALEND
								If CTG->CTG_STATUS$cStatBlq
									aAdd(aCalends,{CTG->CTG_DTINI,CTG->CTG_DTFIM,CTG->CTG_CALEND,CTG->CTG_PERIOD,CTG->CTG_EXERC})
								Else
									If !Empty(cTpSaldo) .AND. dDtIni <= CTG->CTG_DTINI .AND. CTG->CTG_DTINI <= dDtFim .AND. dDtIni <= CTG->CTG_DTFIM .AND. CTG->CTG_DTFIM <= dDtFim
										If !CtbVldArm(CTE->CTE_MOEDA,CTG->CTG_CALEND,CTG->CTG_EXERC,CTG->CTG_PERIOD,cTpSaldo,lMensagem)
											lDatasOk := .F.
											Exit				  									
										EndIf
									EndIf	
								EndIf
								CTG->(dbSkip())
							EndDo
						EndIf
						CTE->(dbSkip())
					EndDo
					If !lFoundCTG	/// SE NÃO ENCONTROU NENHUM CALENDÁRIO AMARRADO
						If lMensagem
							Help("  ",1,"CTGNOCAD")
						EndIf
						lDatasOk := .F.
					EndIf
				Else
					If lMensagem
						// Não há nenhuma calendário montado
						Help("  ",1,"CTGDTOUT")
					EndIf
					lDatasOk := .F.
				EndIf
			EndIf
			If lDatasOk
				For nCal := 1 to Len(aCalends)
					If (dDtIni <= aCalends[nCal][1] .and. dDtFim >= aCalends[nCal][2]) .or.;
						(dDtIni >= aCalends[nCal][1] .and. dDtFim <= aCalends[nCal][2]) .or.;
						(dDtIni <= aCalends[nCal][1] .and. dDtFim >= aCalends[nCal][1] .and. dDtFim <= aCalends[nCal][2]) .or.;
						(dDtIni >= aCalends[nCal][1] .and. dDtIni <= aCalends[nCal][2])
						
						If lMensagem
							//"O intervalo de datas informadas não poderá ser processado. "#"Verifique o intervalo de datas ou os calendários no intervalo."
							//"Moeda "#", o periodo "#" do calendario "#" está Bloqueado/Encerrado."
							MsgInfo(STR0013+STR0014,STR0002+StrZero(nQ,2)+STR0015+aCalends[nCal][4]+STR0016+aCalends[nCal][3]+STR0017)
						EndIf
						lDatasOk := .F.
						Exit
					EndIf
				    
				    If !Empty(cTpSaldo)
						If !CtbVldArm(cMoeda,aCalends[nCal][3],aCalends[nCal][5],aCalends[nCal][4],cTpSaldo,lMensagem)
							lDatasOk := .F.
							Exit				  									
						EndIf
					EndIf	
				Next
			EndIf
			
		Else					/// SE DATA INICIAL E FINAL FOREM IGUAIS (APENAS 1 DATA)
			cQuery := " SELECT "
			cQuery += " CTE_FILIAL, "
			cQuery += " CTE_MOEDA, "
			cQuery += " CTG_DTINI, "
			cQuery += " CTG_DTFIM, "
			cQuery += " CTG_CALEND, "
			cQuery += " CTG_PERIOD,  "
			cQuery += " CTG_EXERC  "
			cQuery += " FROM " + RetSqlName("CTE")+" CTE, "+ RetSqlName("CTG")+" CTG "
			cQuery += " WHERE CTE_CALEND = CTG_CALEND "
			cQuery += "   AND CTE_FILIAL = '"+xFilial("CTE")+"' "
			cQuery += "   AND CTE_MOEDA = '"+cMoeda+"' "
			cQuery += "   AND CTE.D_E_L_E_T_ = ' ' "
			cQuery += "   AND CTG_FILIAL = '"+xFilial("CTG")+"' "
			cQuery += "   AND '"+DTOS(dDtIni)+"' BETWEEN CTG_DTINI AND CTG_DTFIM "
			cQuery += "   AND CTG_STATUS IN ('"
			For nX := 1 TO nLenStat
				cQuery += Substr(cStatBlq, nX, 1) + If( nX<nLenStat, "','", "" )
			Next
			cQuery += "')"
			cQuery += "   AND CTG.D_E_L_E_T_ = ' ' "
			
			//RETIRADO PARA PERFORMANCE - ANSI NAO HA NECESSIDADE DE PASSAR PELA CHANGEQUERY	
			If ! ( Alltrim(Upper(TCGetDB())) $ "MSSQL|MSSQL7|ORACLE" )
				cQuery := ChangeQuery(cQuery)
			EndIf
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CTEBLOQ",.T.,.F.)
			TcSetField("CTEBLOQ","CTG_DTINI","D",8,0)
			TcSetField("CTEBLOQ","CTG_DTFIM","D",8,0)
			
			lRet := CTEBLOQ->(! Eof() )
			
			If lRet
				If lMensagem
					//"O intervalo de datas informadas não poderá ser processado. "#"Verifique o intervalo de datas ou os calendários no intervalo."
					//"Moeda "#", o periodo "#" do calendario "#" está Bloqueado/Encerrado."
					MsgInfo(STR0013+STR0014,STR0002+cMoeda+STR0015+CTEBLOQ->CTG_PERIOD+STR0016+CTEBLOQ->CTG_CALEND+STR0017)
				EndIf
				lDatasOk := .F.			
			EndIf
			
			dbSelectArea("CTEBLOQ")
			dbCloseArea()
			
		
			//se nao conseguiu resolver na query para exibir mensagens coerentes
			If ! lRet
				dbSelectArea("CTE")
				dbSetOrder(1)
				If MsSeek(xFilial("CTE")+cMoeda,.F.)
					While CTE->(!Eof()) .And. CTE->CTE_FILIAL == xFilial("CTE") .and. CTE->CTE_MOEDA == cMoeda
						dbSelectArea("CTG")
						dbSetOrder(2)
						MsSeek(xFilial("CTG")+CTE->CTE_CALEND+DTOS(dDtIni),.T.)
						
						If 	CTG->(Eof()) .or. ;
							CTG->CTG_FILIAL <> xFilial("CTG") .or. ;
							CTG->CTG_CALEND <> CTE->CTE_CALEND .or. ;
							DTOS(dDtIni) < DTOS(CTG->CTG_DTINI)
							CTG->(dbSkip(-1))
						EndIf
						
						If 	CTG->(!Eof()) .And. ;
							CTG->CTG_FILIAL == xFilial("CTG") .And. ;
							CTG->CTG_CALEND == CTE->CTE_CALEND .And. ;
							DTOS(dDtIni) >= DTOS(CTG->CTG_DTINI) .And. ;
							DTOS(dDtIni) <= DTOS(CTG->CTG_DTFIM)
							
							lFoundCTG := .T.
							
							If CTG->CTG_STATUS$cStatBlq
								If lMensagem
									//"O intervalo de datas informadas não poderá ser processado. "#"Verifique o intervalo de datas ou os calendários no intervalo."
									//"Moeda "#", o periodo "#" do calendario "#" está Bloqueado/Encerrado."
									MsgInfo(STR0013+STR0014,STR0002+cMoeda+STR0015+CTG->CTG_PERIOD+STR0016+CTG->CTG_CALEND+STR0017)
								EndIf
								
								lDatasOk := .F.
								Exit
							EndIf
						
							If !Empty(cTpSaldo)
				   				If !CtbVldArm(cMoeda,CTG->CTG_CALEND,CTG->CTG_EXERC,CTG->CTG_PERIOD,cTpSaldo,lMensagem)
									lDatasOk := .F.
									Exit			  									
								EndIf
							EndIf											
						EndIf
						
						CTE->(dbSkip())
					EndDo
					
					If !lFoundCTG
						// Não há nenhuma calendário montado
						If lMensagem
							Help("  ",1,"CTGNOCAD")
						Endif
						lDatasOk := .F.
						Exit
					EndIf
				Else
					If lMensagem
						// Não há nenhuma calendário montado
						Help("  ",1,"CTGDTOUT")
					EndIf
					lDatasOk := .F.
				EndIf
			EndIf
		EndIf
		
		If nTMoedas == 2 .or. !lDatasOk
			Exit
		Endif
	Next
	If lCache
		//armazena em array static para nao fazer pesquisa a cada nova chamada da funcao
		//os primeiros 7 elementos sao os parametros da chamada da funcao
		//resultado do processamento fica armazenado no elemento 8
		//elementos            1      2       3         4     5         6         7        8
		aAdd(__aCtbVlDtCal, {dDtIni,dDtFim,nTMoedas,cMoeda,cStatBlq,lMensagem,cTpSaldo, lDatasOk} )
	EndIf
EndIf

Return(lDatasOk)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbValiDt  ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³validacao da data                                           			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbValidt(nOpc,dData)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da opcao escolhida         	                 		 ³±±
±±³          ³ ExpD1 = Data                              	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbValiDt(nOpc,dData,lHelp,cTpSaldo,lVldTps,aProcesso,cHelp)

Local aSaveArea := GetArea()
Local lDataFree := .T.
Local nMoed 	:= 1
Local nBlocks	:= 0
Local nPos
Local lCache 	:= CtbCache(7)
Local bVldCache
Local cQry			:= ""
Local cProc			:= ""
Local nZ			:= 0
Local cTbl  		:= CriaTrab(,.F.)

DEFAULT cHelp       := STR0065//"Calendário Contábil Bloqueado. Verfique o processo."
DEFAULT aProcesso	:= {"CTB001"}
DEFAULT lHelp		:= !lBlind
DEFAULT cTpSaldo 	:= ""
DEFAULT lVldTps		:= .F. //Habilita o controle de Cache por Tipo de Saldo
DEFAULT nOpc := 3

If lDataFree

	For nZ := 1 To Len(aProcesso)
		If nZ == Len(aProcesso)
			cProc += aProcesso[nZ]
		Else
			cProc += aProcesso[nZ]+"/"	
		Endif 
	Next
	
	cQry:=" SELECT CQD_STATUS, CQD_DTINI, CQD_DTFIM"+CRLF
	cQry+=" FROM " + RetSqlName("CTG")+" CTG"+CRLF
	cQry+=" INNER JOIN " + RetSqlName("CQD")+" CQD ON"+CRLF
	cQry+=" CTG_FILIAL			 = CQD.CQD_FILIAL"+CRLF
	cQry+=" AND CTG_CALEND 		 = CQD.CQD_CALEND"+CRLF	
	cQry+=" AND CTG_EXERC 		 = CQD.CQD_EXERC"+CRLF
	cQry+=" AND CTG_PERIOD 		 = CQD.CQD_PERIOD"+CRLF
	cQry+=" INNER JOIN " + RetSqlName("CTE")+" CTE ON"+CRLF
	cQry+=" CTG_FILIAL			 = CTE.CTE_FILIAL"+CRLF
	cQry+=" AND CTG_CALEND 		 = CTE.CTE_CALEND"+CRLF
	cQry+=" WHERE CTG_DTINI 	<= '"+DTOS(dData)+"'"+CRLF
	cQry+=" AND CTG_DTFIM		>= '"+DTOS(dData)+"'"+CRLF
	cQry+=" AND CQD.CQD_PROC IN "+FormatIn(cProc,"/")+CRLF
	cQry+=" AND CTG_FILIAL	 	 = '"+xFilial("CTG")+"'"+CRLF
	cQry+=" AND CTE.CTE_MOEDA	 = '01'"+CRLF
	cQry+=" AND CTE.D_E_L_E_T_	 =''"+CRLF
	cQry+=" AND CTG.D_E_L_E_T_	 =''"+CRLF
	cQry+=" AND CQD.D_E_L_E_T_	 =''"
	
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTbl,.T.,.T.)
	
	If (cTbl)->(!EOF())
		While (cTbl)->(!EOF())
			If (cTbl)->CQD_STATUS == "4" .OR. (cTbl)->CQD_STATUS == "2" //Bloqueado ou Fechado
				lDataFree := .F.
				Exit
			Elseif (cTbl)->CQD_STATUS == "5"
				If dData >= STOD((cTbl)->CQD_DTINI) .AND. dData <= STOD((cTbl)->CQD_DTFIM)
					lDataFree := .F.
					Exit
				Endif
			Endif
			(cTbl)->(DbSkip())
		EndDo
	Else
		lDataFree := .T.
	EndIf

	If lDataFree == .F. .And. lHelp
		Help(" ",1,"CTBBLOQ",,cHelp,1,0)
	Endif	
EndIf

If lDataFree .And. ( FWIsInCallStack("CTBA102") .Or. FWIsInCallStack("ctb_incl") .Or. FWIsInCallStack("CTBA101") .Or. FWIsInCallStack("CTBA103"))
	If lVldTps
		bVldCache := {||( nPos := aScan(__aCtbValidDt, {|x| StrZero(x[1],3)+DtoS(x[2])+x[3] == StrZero(nOpc,3)+DtoS(dData)+cTpSaldo } ) ) > 0 }
	Else
		bVldCache := {||( nPos := aScan(__aCtbValidDt, {|x| StrZero(x[1],3)+DtoS(x[2]) == StrZero(nOpc,3)+DtoS(dData) } ) ) > 0 }
	EndIf

	If lCache .And. !lHelp .And. !Empty(__aCtbValidDt) .And. Eval(bVldCache)
		lDataFree := __aCtbValidDt[nPos, 4]
	Else
		__nQuantas := CtbMoedas()
			
		For nMoed := 1 to __nQuantas		/// TESTA MOEDAS ESPECÍFICAMENTE SEM ALERTAS
			If CtVlDTMoed(dData,dData,2,strzero(nMoed,2),.F.,cTpSaldo)
				nBlocks++
			EndIF
		Next
	
		If nBlocks == __nQuantas			/// SE NENHUMA MOEDA ESTIVE LIBERADA (HOUVE BLOQUEIO PARA TODAS)
			If lHelp
				Help(" ",1,"CTGDTCOMP")
				For nMoed := 1 to __nQuantas
				/// TESTA TODAS AS MOEDAS NOVAMENTE MAS AGORA APRESENTA OS ALERTAS
					If CtVlDTMoed(dData,dData,1,"",.T.,cTpSaldo)
						Exit
					EndIF
				Next
			Endif
			lDataFree := .F.
		EndIf
		If lCache
			aAdd(__aCtbValidDt, { nOpc,dData,cTpSaldo, lDataFree } )
		EndIf
	EndIf
EndIf

If Select(cTbl) > 0
	DbSelectArea(cTbl)
	DbCloseArea()
EndIf

RestArea(aSaveArea)

Return lDataFree
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtTipoLan  ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³validacao do tipo do lancamento                             			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtTipoLan()                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                    	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtTipoLan()

Local aSaveArea := GetArea()
Local aRateio
Local cTipant	:= TMP->CT2_DC
Local cVar		:= ReadVar()
Local cTipoDC
Local cTipo
Local lRet 		:= .T.
Local lCancel	:= .F.
Local nValRat
Local nValor 	:= TMP->CT2_VALOR
Local nValorAnt
Local nTotalDeb := 0
Local nTotalCrd := 0
Local nRecTmp	:= 0
Local nOrdTMP	:= 1
Local cMensagem	:= ""
Local cSeqLan	:= ""
Local cSeqHis	:= "001"
Local nLinMax   := CtbLinMax(GetMv("MV_NUMLIN"))

cTipoDc	:= &(ReadVar())

If cTipAnt == "4" .And. cTipAnt <> cTipoDc 						//// NÃO DEVE EXECUTAR RATEIO OU LP SEM PASSAR POR ESTA VALIDACAO
	//Se for Complemento de historico, nao deixar alterar. Devera deletar o registro e incluir uma
	//nova linha.
	cMensagem	:= STR0018 + chr(13)
	cMensagem	+= STR0019
	MsgInfo(cMensagem)
	lRet	:= .F.
ElseIF !Empty(cTipAnt) .and. cTipoDC$("56")					//// SE NÃO FOR REGISTRO NOVO (DC JA PREENCHIDO) E INDICADO TIPO RATEIO/LP
	cMensagem	:= STR0020 + chr(13)
	cMensagem	+= STR0019
	MsgInfo(cMensagem)
	lRet	:= .F.
ElseIf cTipoDC == "6"				// Lancamento Padrao
	cPadrao 	:= CtbEscPad(@lCancel)
	If !Empty(cPadrao)
		cTipo 	:= CtbEnche(cPadrao,.F.)
		&cVar		:= cTipo
	Else
		If !lCancel					// Usuario nao cancelou a escolha do rateio, e o rateio nao existe!
			Help("",1,"NOLCTOPAD")
			lRet := .F.
		Else
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		aTotRdpe := {{0,0,0,0},{0,0,0,0}}
		
		nRecTmp := TMP->(Recno())
		TMP->(DbGoTop())
		While ! TMP->(Eof())
			If ! TMP->CT2_FLAG
				CTB102Exibe(TMP->CT2_VALOR,0,TMP->CT2_DC,"",GetMv("MV_SOMA"))
			Endif
			TMP->(DbSkip())
		EndDo
		TMP->(DbGoTo(nRecTmp))
	Endif
	
ElseIf cTipoDC == "5"			// Rateio
	aRateio:=CtbEscRat(@lCancel)
	
	nLinAtu := DecodSoma1(TMP->CT2_LINHA)
	
	If nLinAtu+Len(aRateio) > nLinMax
		aRateio := {}
		lRet := .F.
		lCancel := .T.
		Aviso(STR0037,STR0039,{"Ok"})  //"Atenção!"##"Numero de linhas do rateio excede a quantidade maxima de linhas permitida por documento."
	EndIf
	
	IF Len(aRateio) != 0
		cRateio	:= aRateio[1]
		nValRat	:= aRateio[2]
		cTipo 	:= CtbRateio(	cRateio,nValRat,@nTotalDeb,@nTotalCrd,;
		aRateio[3],aRateio[4],aRateio[5])
		&cVar		:= cTipo
		
		If !lCancel
			// Usuario nao cancelou a escolha do rateio, e o rateio nao existe!
			If cTipo = "5"
				Help("",1,	"NoRateio",,	CHR(13)+;
				STR0021+;  //"Ou todas as contas do rateio estao zeradas"
				CHR(13),4,0)
				lRet := .F.
			Endif
		Else
			lRet := .F.
		EndIf
		
		If lRet
			aTotRdpe := {{0,0,0,0},{0,0,0,0}}
			
			nRecTmp := TMP->(Recno())
			TMP->(DbGoTop())
			While ! TMP->(Eof())
				If ! TMP->CT2_FLAG
					CTB102Exibe(TMP->CT2_VALOR,0,TMP->CT2_DC,"",GetMv("MV_SOMA"))
				Endif
				TMP->(DbSkip())
			EndDo
			TMP->(DbGoTo(nRecTmp))
		Endif
	Else
		If !lCancel					// Usuario nao cancelou a escolha do rateio, e o rateio nao existe!
			Help("",1,"NoRateio")
			lRet := .F.
		Else
			lRet := .F.
		EndIf
	EndIF
Else
	&cVar			:= cTipoDc
	// Atualiza rodape -> MSGETDB
	nValorAnt := TMP->CT2_VALOR
	If cTipoDC != cTipAnt .and. !TMP->CT2_FLAG
		CTB102Exibe(nValor,nValorAnt,cTipoDC,cTipAnt,GetMv("MV_SOMA"))
		If cTipoDC $ "13" .And. !Empty(TMP->CT2_DEBITO)
			CtExibeCta(TMP->CT2_DEBITO,cTipoDC,dDataLanc)
			Ctb105Conv(TMP->CT2_VALOR,,)
		ElseIf cTipoDC $ "23" .And. !Empty(TMP->CT2_CREDIT)
			CtExibeCta(TMP->CT2_CREDIT,cTipoDC,dDataLanc)
			Ctb105Conv(TMP->CT2_VALOR,,)
		EndIf
	EndIf
	TMP->CT2_DC := cTipoDC
	
	//Gravacao do TMP->CT2_SEQLAN
	If cTipoDc <> cTipAnt .Or. Empty(TMP->CT2_SEQLAN)
		dbSelectArea("TMP")
		nOrdTMP	:= IndexOrd()
		nRecTMP	:= Recno()
		dbSetOrder(2)
		dbSkip(-1) 			//Procuro pela sequencia, para poder calcular a proxima.
		If TMP->CT2_FLAG		/// SE A LINHA ANTERIOR ESTIVER DELETADA.
			While !Bof() .and. !Eof() .and. TMP->CT2_FLAG
				dbSkip(-1) 			//Procuro pela sequencia, para poder calcular a proxima.
			EndDo
		EndIf
		If !Bof() .And. !Eof()
			If cTipoDC == "4"
				cSeqHis	:= StrZero((Val(TMP->CT2_SEQHIS)+1),3)
			Else
				cSeqHis	:= "001"
			EndiF
			
			If cTipoDC == "4"
				cSeqLan	:= TMP->CT2_SEQLAN
			Else
				If TMP->CT2_DC == "4"
					While !TMP->(Bof()) .and. TMP->CT2_DC == "4"
						dbSkip(-1)
					End
					cSeqLan := Soma1( TMP->CT2_SEQLAN )
				Else
					cSeqLan := Soma1( TMP->CT2_SEQLAN )
				EndIf
			EndIf
		Else
			cSeqLan	:= '001'
		Endif
		
		dbGoto(nRecTMP)
		dbSetOrder(nOrdTMP)
		
		TMP->CT2_SEQLAN		:= cSeqLan
		TMP->CT2_SEQHIS		:= cSeqHis
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CtbMovSaldo³ Autor ³ Pilar S. Albaladejo  ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a o centro de custo, item ou classe de valor    ³±±
±±³			 ³esta em uso.                              				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³CtbMovSaldo(cAlias)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³.T./.F.         											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo a ser verificado				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbMovSaldo(cAlias, lMessage, cIdEntid, cAliasEnt)

Local lRet		:= .f.
Local nPos
Local aCtbIni 	:= ReadIniCtb()
Local aSavArea  := GetArea()
Local bSx3 		:= { |cCampo| (	SX3->(DbSetOrder(2)), SX3->(DbSeek(cCampo)),;
SX3->(DbSetOrder(1)), SX3->X3_USADO) }

DEFAULT lMessage := .F.
DEFAULT cIdEntid := ""
DEFAULT cAliasEnt:= cAlias

If ! CtbInUse()		// Compatibilizacao com o SigaCon
	If cAlias = "CTT"
		lRet 	:= X3Uso(Eval(bSx3, "I2_CCC")) .And. X3Uso(Eval(bSx3, "I2_CCD"))
	ElseIf cAlias = "CTD"
		lRet 	:= X3Uso(Eval(bSx3, "I2_ITEMC")) .And. X3Uso(Eval(bSx3, "I2_ITEMD"))
	Else
		lRet	:= .F.
	Endif
ElseIf cAlias == "CT0" //Validação para as entidades adicionais
	dbSelectArea(cAliasEnt)
	dbSetOrder(1)
	If dbSeek(xFilial(cAlias)+cIdEntid)
		lRet := Iif((cAliasEnt)->CT0_CONTR == "1",.T.,.F.)
	EndIf
Else
	nPos := Ascan(aCtbIni, {|x| Substr(x,20,03) = Upper(cAlias) })
	If nPos > 0
		lRet := Iif(Substr(aCtbIni[nPos],18,1) == "1",.T.,.F.)
	Endif
Endif

If ! lRet .And. lMessage .And. cAlias = "CTH"
	Help(" ",1,"NCONSALCV")
ElseIf ! lRet .And. lMessage .And. cAlias = "CTD"
	Help(" ",1,"NCONSALITE")
ElseIf ! lRet .And. lMessage .And. cAlias = "CTT"
	Help(" ",1,"NCONSALCC")
ElseIf ! lRet .And. lMessage .And. cAlias = "CT0" .And. cIdEntid == "05" //Entidade 05
	Help(" ",1,"NCONSALEC05")
ElseIf ! lRet .And. lMessage .And. cAlias = "CT0" .And. cIdEntid == "06" //Entidade 06
	Help(" ",1,"NCONSALEC06")
ElseIf ! lRet .And. lMessage .And. cAlias = "CT0" .And. cIdEntid == "07" //Entidade 07
	Help(" ",1,"NCONSALEC07")
ElseIf ! lRet .And. lMessage .And. cAlias = "CT0" .And. cIdEntid == "08" //Entidade 08
	Help(" ",1,"NCONSALEC08")
ElseIf ! lRet .And. lMessage .And. cAlias = "CT0" .And. cIdEntid == "09" //Entidade 09
	Help(" ",1,"NCONSALEC09")
Endif

RestArea(aSavArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValEntSup ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 01.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Conta Superior na inclusao da conta contabil.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ValEntSup(cCodEnt, cEntidade)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Endidade contabil Superior Digitada                ³±±
±±³          ³ ExpC2 = Entidade para validacao (CTT/CTD/CTH)              ³±±
±±³Parametros³ ExpC3 = Entidade contabil que esta sendo cadastrada        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValEntSup(cCodEnt, cEntidade, cCodAtu)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

Default cEntidade := Alias()
Default cCodAtu   := ""

dbSelectArea(cEntidade)
dbSetOrder(1)

If !Empty(cCodEnt)
	DO CASE
		CASE cCodAtu == cCodEnt					//A entidade cadastrada deve ser diferente da superior (_xxSUP)
			Help(" ",1,"ENTPAIGUAL")
			lRet := .F.
		CASE !MsSeek(xFilial()+cCodEnt)          //A Entidade deve existir
			Help("  ", 1, "NOCADENTSU")
			lRet := .F.
		CASE &(cEntidade + "_CLASSE") != "1"	//A entidade superior deve ser sintetica.
			Help(" ",1,"NOENTCLASI")
			lRet := .F.
		CASE !CtbValRecurs(cCodEnt, cEntidade, cCodAtu) //Função CtbValRecurs valida apenas C. Custo
			Help(" ",1,"NORECUSIR",,STR0058 ,1,0) //
			lRet := .F.
	ENDCASE
EndIf

RestArea(aSaveArea)

Return lRet

Function CtbValRecurs(cCodDestino,cEntidade,cCodAtu)
Local lWhile := .T.
Local lRet		 := .F.
Local cSup	:= ''

If cEntidade == 'CTT' //Centro de Custo
	
	While lWhile
		//Posicionar no cCodEnt e ver o código superior dele, se for o mesmo que o cCodAtu aborta para não ficar em recursividade.
		If CTT->(dbSeek(xFilial() + cCodDestino))
			If Empty(CTT->CTT_CCSUP) 
				lRet 		:= .T.
				Exit
			ElseIf CTT->CTT_CCSUP == cCodAtu 
				lRet := .F.
				Exit 
			EndIf
			cCodDestino := CTT->CTT_CCSUP
		EndIf	
	EndDo
			
ElseIf cEntidade == 'CTD' //Item Contábil

	While lWhile
		If CTD->(dbSeek(xFilial() + cCodDestino))
			If Empty(CTD->CTD_ITSUP) 
				lRet 		:= .T.
				Exit
			ElseIf CTD->CTD_ITSUP == cCodAtu 
				lRet := .F.
				Exit 
			EndIf
			cCodDestino := CTD->CTD_ITSUP
		EndIf	
	EndDo

ElseIf cEntidade == 'CTH' //Classe Valor

	While lWhile
		If CTH->(dbSeek(xFilial() + cCodDestino))
			If Empty(CTH->CTH_CLSUP) 
				lRet 		:= .T.
				Exit
			ElseIf CTH->CTH_CLSUP == cCodAtu 
				lRet := .F.
				Exit 
			EndIf
			cCodDestino := CTH->CTH_CLSUP
		EndIf	
	EndDo
EndIf
	
Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CT102DEL  ³ Autor ³ Simone Mie Sato       ³ Data ³ 16.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza totais no rodape, quando deleta linha da MSGETDB.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct102Del(nOpc)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA102                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da Opcao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct102Del(nOpc, lValida)
Local aArea		:= GetArea()
Local nValLcto
Local cCondicao	:= ""
Local cSeqLan	:= "001"
Local cSeqHis	:= "001"
Local cLinha	:= TMP->CT2_LINHA
Local nRecTMP	:= TMP->(Recno())
Local lRet		:= .T.
Local lTmpFlg 	:= TMP->CT2_FLAG

DEFAULT lValida	:= .T.
SaveInter()

If __lConOutR == Nil
	__lConOutR := FindFunction( "CONOUTR" )
EndIf

IF !TMP->CT2_FLAG
	//Verifica se existe alguma entidade bloqueada
	If !Ctb102Bloq("CT1",TMP->CT2_DEBITO) .Or. !Ctb102Bloq("CT1",TMP->CT2_CREDIT) .Or. ;
		( !Empty(TMP->CT2_CCD) .And.  !Ctb102Bloq("CTT",TMP->CT2_CCD)) .Or.(!Empty(TMP->CT2_CCC) .And.  !Ctb102Bloq("CTT",TMP->CT2_CCC)) .Or. ;
		( !Empty(TMP->CT2_ITEMD) .And.  !Ctb102Bloq("CTD",TMP->CT2_ITEMD)) .Or.(!Empty(TMP->CT2_ITEMC) .And.  !Ctb102Bloq("CTD",TMP->CT2_ITEMC)) .Or. ;
		( !Empty(TMP->CT2_CLVLDB) .And.  !Ctb102Bloq("CTH",TMP->CT2_CLVLDB)) .Or.(!Empty(TMP->CT2_CLVLCR) .And.  !Ctb102Bloq("CTH",TMP->CT2_CLVLCR))
		lRet	:= .F.
	EndIf
EndIf

IF lRet .And. lValida
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	//// TRATAMENTO NUMERACAO DO SEQLAN/SEQHIS CASO O CT2_DC NÃO SEJA PREENCHIDO E A LINHA SEJA DELETADA
	If Empty(TMP->CT2_DC)
		TMP->CT2_DC := "4"								//// PREENCHE POR DEFAULT COM TIPO 4 (CONT. HISTORICO)
		
		//Gravacao do TMP->CT2_SEQLAN
		dbSelectArea("TMP")
		nRecTMP	:= Recno()
		dbSkip(-1) 			//Procuro pela sequencia, para poder calcular a proxima.
		
		If !Bof()
			cSeqLan	:= TMP->CT2_SEQLAN
			cSeqHis	:= StrZero((Val(TMP->CT2_SEQHIS)+1),3)
		Else
			cSeqLan	:= '001'
			cSeqHis	:= '001'
		Endif
		
		dbGoto(nRecTMP)
		
		TMP->CT2_SEQLAN		:= cSeqLan
		TMP->CT2_SEQHIS		:= cSeqHis
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VALIDAÇÕES DE LINHAS DELETADAS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// salvo a posição atual da linha
	nRecTmp := TMP->( RECNO() )
	cSeqLan := TMP->CT2_SEQLAN
	cSeqHis	:= TMP->CT2_SEQHIS
	cLinha	:= TMP->CT2_LINHA
	
	If __lConOutR
		ConoutR( "Ct102Del| SeqLan: " + cSeqLan  + "| SeqHis: " + cSeqHis + "| Linha: " + cLinha )
	Endif
	
	IF ( TMP->CT2_DC $ "1|2|3" )
		
		lRet := CtVldLinDCP( cSeqLan )
		
		// rotina de limpeza em cascata: Pai + Filhos
		IF lRet .And. TMP->CT2_SEQHIS == '001'
			
			// forço o flag para passar na validação
			TMP->CT2_FLAG := !lTmpFlg
			
			While TMP->( !Eof() )
				
				// se for diferente da linha pai
				If TMP->CT2_SEQLAN == cSeqLan .And. TMP->CT2_SEQHIS <> "001"
					
					IF ! CtVldLinHis( cSeqLan , .F. )
						TMP->( DbSkip() )
						Loop
					Endif
					
					// deleto ou recupero as linhas filhas (historicos e afins)
					TMP->CT2_FLAG := !lTmpFlg
				EndIf
				
				TMP->( DbSkip() )
			EndDo
			
			TMP->( DbGoto( nRecTmp ) )
			
			// volto o status do flag
			TMP->CT2_FLAG := lTmpFlg
			
		Endif
		
	ElseIF TMP->CT2_DC == "4"
		lRet := CtVldLinHis( cSeqLan, .T. )
	Endif
	
	IF lRet
		//Se chamar do CTBA105, tem alguns programas que nao inicializam a variavel
		//INCLUI ou ALTERA.
		
		If Empty(nOpc) .Or. nOpc == Nil
			cCondicao := INCLUI .Or. ALTERA
		Else
			cCondicao := (nOpc == 4 .Or. nOpc == 3)
		Endif
		
		If cCondicao
			nValLcto := TMP->CT2_VALOR
			
			If TMP->CT2_FLAG
				CTB102Exibe(TMP->CT2_VALOR,0,TMP->CT2_DC,"")
			Else
				CTB102Exibe(0,TMP->CT2_VALOR,"",TMP->CT2_DC)
			EndIf
		Endif
	Endif
Endif

RestInter()
RestArea( aArea )

ct102ImpT()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtVldLinDCPºAutor  ³Renato F. Campos   º Data ³  09/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtVldLinDCP( cSeqLan )
Local aArea		:= GetArea()
Local nRecTmp	:= TMP->( Recno() )
Local lRet		:= .T.

// Se for deleção de linha cabeçalho (debito, credito ou partida dobrada), excluo os filhos (historicos e afins)
If TMP->CT2_SEQHIS == "001" .And. TMP->CT2_FLAG// se for diferente da linha pai
	
	IF TMP->( !Eof() )
		TMP->( DbSkip() )
	ENDIF
	
	While lRet .And. TMP->( !Eof() )
		
		If __lConOutR
			ConoutR( "Ct102Del| SeqLan: " +  TMP->CT2_SEQLAN  + "| SeqHis: " + TMP->CT2_SEQHIS + "| Linha: " +  TMP->CT2_LINHA )
		Endif
		
		IF TMP->CT2_SEQLAN == cSeqLan
			IF !TMP->CT2_FLAG
				Conout( 'Erro' )
			Endif
		Else
			IF TMP->CT2_DC == "4"
				IF ! TMP->CT2_FLAG // se for continuação de historico e não estiver deletado
					If __lConOutR
						ConoutR( "Ct102Del| Continuação de historico de outro pai" )
					Endif
					
					Help(" ",1,"CT2CRIA11",,STR0031+ " " + STR0032 ,1,0)// "Existe uma continuação de historico vinculada a linha de lançamento anterior!"##"Não será possivel recuperar essa linha, exclua primeiro o historico da linha abaixo para continuar."
					lRet := .F.
					EXIT
				Endif
			Else
				// se o proximo registro for de outra sequencia e do tipo 1, 2 ou 3 eu saio
				EXIT
			Endif
		Endif
		TMP->( DbSkip() )
	EndDo
	
	// se entrou na condição, retorno para linha de origem
	TMP->( DbGoto( nRecTmp ) )
Endif

RestArea( aArea )

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtVldLinHisºAutor  ³Renato F. Campos   º Data ³  09/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtVldLinHis( cSeqLan, lExbMsg )
Local aArea		:= GetArea()
Local nRecTmp	:= TMP->( Recno() )
Local lRet		:= .T.

Default lExbMsg := .T.

IF TMP->CT2_DC == "4" .And. TMP->CT2_FLAG
	lPaiDel := .F.
	
	If TMP->( !Bof() )
		TMP->( DbSkip(-1) )
	Endif
	
	IF TMP->CT2_SEQLAN == cSeqLan
		
		While lRet .And. TMP->CT2_SEQLAN == cSeqLan .And. TMP->( !Bof() )
			If __lConOutR
				ConoutR( "Ct102Del Continuação| SeqLan: " +  TMP->CT2_SEQLAN  + "| SeqHis: " + TMP->CT2_SEQHIS + "| Linha: " +  TMP->CT2_LINHA )
			Endif
			
			IF TMP->CT2_DC == "4" .And. TMP->CT2_FLAG
				lRet := .F.
				EXIT
			Endif
			
			If TMP->CT2_SEQHIS == "001" .And. TMP->CT2_FLAG
				IF lExbMsg
					Help(" ",1,"CT2CRIA12",,STR0034,1,0)// "Para restaurar esta continuacao de historico e necessario estar restaurando o registro de Debito ou Credito deletado."
					
					lRet := .F.
					EXIT
				Endif
			Endif
			
			TMP->( DbSkip(-1) )
		EndDo
	Else
		IF ! TMP->CT2_FLAG
			IF lExbMsg
				Help(" ",1,"CT2CRIA13",,STR0033,1,0)//  "Não será possivel restaurar essa continuação de historico. A sequencia de lançamento anterior (linha acima) é diferente da sequencia dessa linha."
			Endif
			lRet := .F.
		Endif
	Endif
Endif

TMP->( DbGoto( nRecTmp ) )

RestArea( aArea )

Return(lRet)




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbAmarra  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 04.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se as amarracoes sao permitidas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbAmarra(Cta,cc,Item,Clvlr,Posiciona?)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta                                              ³±±
±±³          ³ ExpC2 = Centro de Custo                                    ³±±
±±³          ³ ExpC3 = Item                                               ³±±
±±³          ³ ExpC4 = Classe de Valor                                    ³±±
±±³          ³ ExpL1 = Indica se deve posicionar ou nao                   ³±±
±±³          ³ ExpL2 = Validacao linha ok                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbAmarra(cConta,cCusto,cItem ,cCLVL,lPosiciona,lHelp,lValidLinOk,aEntidade)

Local lRet			:= .T.
Local lTem			:= .F.
Local aArea 		:= GetArea()
Local cCodigo		:= ""
Local nPos			:= 0
Local cAmarracao	:= CtbUseAmar()
Local cQry			:= ""
Local cAliasQry		:= ""
Local aCpos			:= {}
Local nX			:= 0
Local lCache   		:= CtbCache(3)  //avalia se trabalha com cache
Local bAddCache		:= ""
Local bPesqCache	:= ""
Local cAddEnt		:= ""
Local cBuscaEnt		:= ""

DEFAULT lPosiciona	:= .T.
DEFAULT lHelp		:= .T.
DEFAULT lValidLinOk	:= .T.
DEFAULT aEntidade	:= {}


If nQtdEntid == NIL
	nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If cAmarracao == '0'		// Nao controla
	RestArea(aArea)
	Return lRet
	
ElseIf cAmarracao == '1' 	// Regra de niveis  --> valido somente para as 4 entidades padroes conta/centro custo/item contabil/classe de valor
	
	If lPosiciona
		CtbPosic(cConta,cCusto,cItem,cClvl)
	EndIf
	
	If lCache .And. !Empty(__CtbAmarra) .And. ( nPos := Ascan(__CtbAmarra, {|x| 	x[1] == cConta .And. ;
		x[2] == cCusto .And. ;
		x[3] == cItem .And. ;
		x[4] == cCLVL } ) ) > 0
		lRet := __CtbAmarra[nPos, 5]
		If ! lRet .And. lHelp
			Help(" ",1,"NOAMARRA01")
		EndIf
		
	Else
		/*********************************************************
		//
		//	Neste sentido eh considerado REGRA
		//	--------------------------------------------->>>>>
		//
		//  	NIVEL 1				NIVEL 2		NIVEL 3
		//  	+---------------+	+-------+	+--------+
		//  	|               |	|		|	|      	 |
		//		CONTA  			C.CUSTO		ITEM	CLASSE VALOR
		//
		//	Neste sentido eh considerado CONTRA-REGRA
		//	<<<<<---------------------------------------------
		//
		//**********************************************************/
		
		// Validacao do Plano de Contas
		If !Empty(cConta)
			// NIVEL 1 => CONTA -> CCUSTO
			If (!Empty(CT1->CT1_RGNV1) .And. (! Empty(cCusto) .And. !Empty(CTT->CTT_CRGNV1)))
				If AT("/",CTT->CTT_CRGNV1) > 0 //Se tiver mais de um codigo de amarracao
	
					lTem := CtbAmaRegr(CTT->CTT_CRGNV1/*cContra*/, CT1->CT1_RGNV1/*cRegra*/)
	
					If !lTem
						If lHelp
							Help(" ",1,"NOAMARRA01")
						EndIf
						lRet	:= .F.
					EndIf
				Else //Se tiver somente um codigo no campo CTT_CRGNV1
					If !(Alltrim(CTT->CTT_CRGNV1) $ Alltrim(CT1->CT1_RGNV1))
						If lHelp
							Help(" ",1,"NOAMARRA01")
						EndIf
						lRet := .F.
					EndIF
				EndIf
			EndIf
			
			// NIVEL 2 => CONTA -> ITEM
			If lRet
				lTem   		:= .F.
				cCodigo		:= ""
				If (!Empty(CT1->CT1_RGNV2) .And. (! Empty(cItem) .And. !Empty(CTD->CTD_CRGNV1)))
					If AT("/",CTD->CTD_CRGNV1) > 0 //Se tiver mais de um codigo de amarracao
					
						lTem := CtbAmaRegr(CTD->CTD_CRGNV1/*cContra*/, CT1->CT1_RGNV2/*cRegra*/)
						
						If !lTem
							If lHelp
								Help(" ",1,"NOAMARRA02")
							EndIf
							lRet	:= .F.
						EndIf
					Else
						If !(Alltrim(CTD->CTD_CRGNV1) $ Alltrim(CT1->CT1_RGNV2))
							If lHelp
								Help(" ",1,"NOAMARRA02")
							EndIf
							lRet := .F.
						EndIF
					EndIf
				EndIf
			EndIf
			
			// NIVEL 3 => CONTA -> CLASSE VALOR
			If lRet
				lTem   		:= .F.
				cCodigo		:= ""
				If (!Empty(CT1->CT1_RGNV3) .And. (! Empty(cClVl) .And. !Empty(CTH->CTH_CRGNV1)))
					If AT("/",CTH->CTH_CRGNV1) > 0 //Se tiver mais de um codigo de amarracao
					
						lTem := CtbAmaRegr(CTH->CTH_CRGNV1/*cContra*/, CT1->CT1_RGNV3/*cRegra*/)
			
						If !lTem
							If lHelp
								Help(" ",1,"NOAMARRA03")
							EndIf
							lRet	:= .F.
						EndIf
					Else
						If !(Alltrim(CTH->CTH_CRGNV1) $ Alltrim(CT1->CT1_RGNV3))
							If lHelp
								Help(" ",1,"NOAMARRA03")
							EndIf
							lRet := .F.
						EndIF
					EndIf
				EndIf
			EndIf
		EndIf
		
		// Validacao do Centro de Custo
		If !Empty(cCusto) .And. lRet
			// NIVEL 2 => CCUSTO -> ITEM
			If lRet
				lTem	:= .F.
				cCodigo	:= ""
				If (!Empty(CTT->CTT_RGNV2) .And. (! Empty(cItem) .And. !Empty(CTD->CTD_CRGNV2)))
					If AT("/",CTD->CTD_CRGNV2) > 0 //Se tiver mais de um codigo de amarracao

						lTem := CtbAmaRegr(CTD->CTD_CRGNV2/*cContra*/, CTT->CTT_RGNV2/*cRegra*/)

						If !lTem
							If lHelp
								Help(" ",1,"NOAMARRA04")
							EndIf
							lRet	:= .F.
						EndIf
					Else
						If !(Alltrim(CTD->CTD_CRGNV2) $ Alltrim(CTT->CTT_RGNV2))
							If lHelp
								Help(" ",1,"NOAMARRA04")
							EndIf
							lRet := .F.
						EndIF
					EndIf
				EndIf
			EndIf
			// NIVEL 3 => CCUSTO -> CLASSE VALOR
			If lRet
				lTem	:= .F.
				cCodigo	:= ""
				If (!Empty(CTT->CTT_RGNV3) .And. (! Empty(cClVl) .And. !Empty(CTH->CTH_CRGNV2)))
					If AT("/",CTH->CTH_CRGNV2) > 0 //Se tiver mais de um codigo de amarracao

						lTem := CtbAmaRegr(CTH->CTH_CRGNV2/*cContra*/, CTT->CTT_RGNV3/*cRegra*/)
						
						If !lTem
							If lHelp
								Help(" ",1,"NOAMARRA05")
							EndIf
							lRet	:= .F.
						EndIf
					Else
						If !(Alltrim(CTH->CTH_CRGNV2) $ Alltrim(CTT->CTT_RGNV3))
							If lHelp
								Help(" ",1,"NOAMARRA05")
							EndIf
							lRet := .F.
						EndIF
					EndIf
				EndIf
			EndIf
		EndIf
		
		// Validacao do Item Contabil
		If !Empty(cItem) .And. lRet
			// NIVEL 3 => ITEM -> CLASSE VALOR
			If lRet
				lTem 		:= .F.
				cCodigo     := ""
				
				If (!Empty(CTD->CTD_RGNV3) .And. (! Empty(cClVl) .And. !Empty(CTH->CTH_CRGNV3)))
					If AT("/",CTH->CTH_CRGNV3) > 0 //Se tiver mais de um codigo de amarracao

						lTem := CtbAmaRegr(CTH->CTH_CRGNV3/*cContra*/, CTD->CTD_RGNV3/*cRegra*/)

						If !lTem
							If lHelp
								Help(" ",1,"NOAMARRA06")
							EndIf
							lRet	:= .F.
						EndIf
					Else
						If !(Alltrim(CTH->CTH_CRGNV3) $ Alltrim(CTD->CTD_RGNV3))
							If lHelp
								Help(" ",1,"NOAMARRA06")
							EndIf
							lRet := .F.
						EndIF
					EndIf
				EndIf
			EndIf
		EndIf
		
		If lCache .And. Empty(__CtbAmarra) .Or. ( nPos := Ascan(__CtbAmarra, {|x| 	x[1] == cConta .And. ;
			x[2] == cCusto .And. ;
			x[3] == cItem .And. ;
			x[4] == cCLVL } ) ) ==  0
			aAdd(__CtbAmarra, { cConta, cCusto, cItem, cCLVL, lRet })
		EndIf
		
	EndIf
	
ElseIf cAmarracao == '2' 
	
	If lRet			
		If Empty(aEntidade)
			
			aCpos	:= {	{'CTA_CONTA',cConta } ,;
			{'CTA_CUSTO',cCusto } ,;
			{'CTA_ITEM'	,cItem  } ,;
			{'CTA_CLVL'	,cCLVL  } }
		Else
			aCpos	:= {	{'CTA_CONTA',aEntidade[1] } ,;
			{'CTA_CUSTO',aEntidade[2] } ,;
			{'CTA_ITEM'	,aEntidade[3] } ,;
			{'CTA_CLVL'	,aEntidade[4] } }
		EndIf
		
		For nX:= 5 To nQtdEntid
			AADD( aCpos,{ 'CTA_ENTI'+StrZero(nX,2),Iif(Empty(aEntidade)," ",aEntidade[nX])} )
			cBuscaEnt +=  " .And. x["+ AllTrim(Str(nX)) +"] == aCpos["+AllTrim(Str(nX))+"][2]"
			cAddEnt	+= ", aCpos["+AllTrim(Str(nX))+"][2] " 
		Next nX
		
		
		bPesqCache := '{|y| Ascan(y, {|x| x[1] == aCpos[1][2] .And. x[2] == aCpos[2][2] .And. x[3] == aCpos[3][2] .And. x[4] == aCpos[4][2]'  
		bPesqCache += cBuscaEnt
		bPesqCache += '} )} '
		bPesqCache := &(bPesqCache)
		
		bAddCache := '{|x| aAdd( x , { aCpos[1][2], aCpos[2][2], aCpos[3][2], aCpos[4][2]'
		bAddCache += cAddEnt
		bAddCache += ', lRet} )} '
		bAddCache := &(bAddCache)
									
		If lCache .And. !Empty(__CtbAmarra) .And. (nPos := Eval(bPesqCache,__CtbAmarra)) > 0
			lRet := __CtbAmarra[nPos, Len(aCpos)+1 ]
			If !lRet .And. lHelp
				Help(" ",1,"NOAMARRA01")
			EndIf	
		Else
			If CtbQryRestr(aCpos)
				
				cAliasQry := Criatrab(,.F.) //GetNextAlias()
						
				cQry := CtbRetSql(aCpos)  //2o. verifica se restricao atende as condicoes
				cQry := ChangeQuery(cQry)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)
				DbSelectArea(cAliasQry)
				DbGoTop()
				
				If (cAliasQry)->CONTREC == 0
					If lHelp
						Help(" ",1,"NOAMARRA01")
					EndIf
					lRet := .F.
				EndIf
	   		    
	   			If Select(cAliasQry) > 0
					DbSelectArea(cAliasQry)
					DbCloseArea()
				EndIf
	   		EndIf 
		
			If lCache .And. (Empty(__CtbAmarra) .Or. nPos  ==  0)
				Eval(bAddCache,__CtbAmarra)
			EndIf
		EndIf
	EndIf
	
ElseIf  cAmarracao == '3' 

	If lRet	
		If lValidLinOk != NIL .And. Valtype(lValidLinOk) == "L" .And. lValidLinOk
			
			If Empty(aEntidade)
				aCpos	:= {	{'CTA_CONTA',cConta } ,;
				{'CTA_CUSTO',cCusto } ,;
				{'CTA_ITEM'	,cItem  } ,;
				{'CTA_CLVL'	,cCLVL  } }
			Else
				aCpos	:= {	{'CTA_CONTA',aEntidade[1] } ,;
				{'CTA_CUSTO',aEntidade[2] } ,;
				{'CTA_ITEM'	,aEntidade[3] } ,;
				{'CTA_CLVL'	,aEntidade[4] } }
			EndIf
		
			For nX:= 5 To nQtdEntid
				AADD( aCpos,{ 'CTA_ENTI'+StrZero(nX,2),Iif(Empty(aEntidade)," ",aEntidade[nX])} )
				cBuscaEnt +=  " .And. x["+ AllTrim(Str(nX)) +"] == aCpos["+AllTrim(Str(nX))+"][2]"
				cAddEnt	+= ", aCpos["+AllTrim(Str(nX))+"][2] " 
			Next nX
		
			bPesqCache := "{|y| Ascan(y, {|x| x[1] == aCpos[1][2] .And. x[2] == aCpos[2][2] .And. x[3] == aCpos[3][2] .And. x[4] == aCpos[4][2]"  
			bPesqCache += cBuscaEnt
			bPesqCache += "} )} "
			bPesqCache := &(bPesqCache)
			
			bAddCache := "{|x| aAdd(x, { aCpos[1][2], aCpos[2][2], aCpos[3][2], aCpos[4][2]"
			bAddCache += cAddEnt
			bAddCache += ", lRet} )} "
			bAddCache := &(bAddCache)
					
			If lCache .And. !Empty(__CtbAmarra) .And. (nPos := Eval(bPesqCache,__CtbAmarra)) > 0
				lRet := __CtbAmarra[nPos,Len(aCpos)+1]
				If !lRet .And. lHelp
					Help( " " , 1 , "MV_CTBAMAR" ,, "Conta localizada no cadastro de amarrações (Tratamento por Exceção)" ,3,0)
				EndIf	
			Else
							
				cQry := CtbRetSql( aCpos, cAmarracao)
				
				If !Empty(cQry)
					cQry := ChangeQuery(cQry)
					
					cAliasQry := CriaTrab(,.F.)
					
					If Select(cAliasQry) > 0
						DbSelectArea(cAliasQry)
						DbCloseArea()
					EndIf
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.T.,.F.)


					DbSelectArea(cAliasQry)
					DbGoTop()
					If (cAliasQry)->CONTREC > 0
						If lHelp
							Help( " " , 1 , "MV_CTBAMAR" ,, "Conta localizada no cadastro de amarrações (Tratamento por Exceção)" ,3,0)
						EndIf
						lRet := .F.
					EndIF
					
					If Select(cAliasQry) > 0
						DbSelectArea(cAliasQry)
						DbCloseArea()
					EndIf
										
				EndIf
				
				If lCache .And. (Empty(__CtbAmarra) .Or. nPos  ==  0)
					Eval(bAddCache,__CtbAmarra)
				EndIf				
			EndIf			
		EndIf
	EndIf	

EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbAmaRegr ºAutor  ³Microsiga           º Data ³  24/08/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se alguma amarracao contida na contra regra       º±±
±±º          ³ existe na regra                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbAmaRegr(cContra, cRegra)
Local aContra := {}
Local aRegra := {}
Local nX 
Local nY
Local lTem := .F.

aContra := StrToArray( cContra, "/" )  //colocar em array a string cContra que eh separado por /
aRegra 	:= StrToArray( cRegra, "/" )   //colocar em array a string cRegra que eh separado por /

//laco na contra-regra
For nX := 1 TO Len(aContra)
	//laco na regra -- para verificar se contra regra esta contida na regra
	For nY := 1 TO Len(aRegra)
		If Alltrim(aContra[nX]) == AllTrim(aRegra[nY])
			lTem := .T.  //se existe na regra sai fora do laco
			Exit
		EndIf
	Next
	If lTem  
		Exit  //caso exista na regra sai fora do laco
	EndIf
Next

//limpar array
For nX := 1 TO Len(aContra)
	aDel(aContra, nX)
Next
ASIZE(aContra,0)
For nX := 1 TO Len(aRegra)
	aDel(aRegra, nX)
Next
ASIZE(aRegra,0)

Return(lTem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBXVLD   ºAutor  ³Microsiga           º Data ³  04/17/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbRetSql( aCampos, cOpCtbAmar )
Local cQrySql	:= ""
Local nQtdCpos	:= Len(aCampos)
Local nX

Default cOpCtbAmar := '2'

cQrySql += " SELECT"
cQrySql += " COUNT(R_E_C_N_O_) CONTREC FROM"
cQrySql += " ("
cQrySql += " SELECT R_E_C_N_O_,"
For nX := 1 TO nQtdCpos
	cQrySql += aCampos[nX, 1]+If(nX < nQtdCpos, ", ", " ")
Next
cQrySql += " FROM "+RetSqlName("CTA")
cQrySql += " WHERE"
cQrySql += " CTA_FILIAL = '"+xFilial("CTA")+"' AND "
cQrySql += " CTA_ITREGR  != ' '  AND "
For nX  := 1 TO nQtdCpos
	If cOpCtbAmar <> '3'
		If !Empty(aCampos[nX,2])
			cQrySql += " "+aCampos[nX,1]+ " IN ( ' ', '"+aCampos[nX,2]+"') AND "

		EndIf
	Else
		cQrySql += " "+aCampos[nX,1]+ " = '"+aCampos[nX,2]+"' AND "
	EndIf
Next
cQrySql += " D_E_L_E_T_ = ' '"  
cQrySql += " ) TMPAUX"
	
Return(cQrySql)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBXVLD   ºAutor  ³Microsiga           º Data ³  04/17/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbQryRestr( aCampos, cOpCtbAmar )
Local lRet 			:= .F.
Local nQtdCpos 		:= Len(aCampos)
Local nX			:= 0
Local cQrySql		:= ""
Local cAliasQry 	:= ""

Default cOpCtbAmar := '2'

If __CtbSixCTA
	For nX  := 1 TO nQtdCpos
	
		If !Empty(aCampos[nX,2])
			CTA->(DBOrderNickName(aCampos[nX,1]))
			lRet := CTA->(MsSeek(xFilial("CTA")+aCampos[nX,2]))
			If lRet 
				Exit
			EndIf
		EndIf	 
	Next

Else
	
	If nQtdCpos > 0 .And. aScan(aCampos, {|x| !Empty(x[2])}) > 0 
	
		cAliasQry := GetNextAlias()
	
		cQrySql += " SELECT"
		cQrySql += " COUNT(R_E_C_N_O_) CONTREC FROM"
		cQrySql += " ("
		cQrySql += " SELECT R_E_C_N_O_,"
		For nX := 1 TO nQtdCpos
			cQrySql += aCampos[nX, 1]+If(nX < nQtdCpos, ", ", " ")
		Next
		cQrySql += " FROM "+RetSqlName("CTA")
		cQrySql += " WHERE"
		cQrySql += " CTA_FILIAL = '"+xFilial("CTA")+"' "
		cQrySql += " AND CTA_ITREGR  != ' ' "
		cQrySql += "AND ("
		For nX  := 1 TO nQtdCpos
			If !Empty(aCampos[nX,2])
				cQrySql += IIf(nX > 1," OR ","")+ aCampos[nX,1]+ " = '"+aCampos[nX,2]+"' "
			ElseIf nX <= 1
				cQrySql += " "+aCampos[nX,1]+ " = ' ' "	 
			EndIf
		Next
		cQrySql += " ) AND D_E_L_E_T_ = ' '"  
		cQrySql += " ) TMPAUX"
		
		cQrySql := ChangeQuery(cQrySql)
		
		If Select(cAliasQry) > 0
			DbSelectArea(cAliasQry)
			DbCloseArea()
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySql),cAliasQry,.T.,.F.)
		DbSelectArea(cAliasQry)
		DbGoTop()
		If (cAliasQry)->(!Eof() .And. CONTREC > 0 )   //se nao encontrou registros nao prossegue validacao retornando true
			lRet:= .T.
		EndIf

		If Select(cAliasQry) > 0
			DbSelectArea(cAliasQry)
			DbCloseArea()
		EndIf
	EndIf

EndIf
	
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbObrig   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 04.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se as amarracoes sao permitidas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbObrig(Cta,cc,Item,Clvlr,Posiciona?)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta                                              ³±±
±±³          ³ ExpC2 = Centro de Custo                                    ³±±
±±³          ³ ExpC3 = Item                                               ³±±
±±³          ³ ExpC4 = Classe de Valor                                    ³±±
±±³          ³ ExpL1 = Indica se deve posicionar ou nao                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ANALISTA          * ALTERAÇÕES                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Wagner Montenegro * ADICIONADO TRATAMENTO PARA ATIVIDADES COMPLEMENTARES³±±
±±       28/04/2010 * RECEBE OS PARAM. aAtivCT1,aAtivCTD,aAtivCTH,aAtivCTT³±±
±±                  *                                                     ³±±
±±                  *                                                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbObrig(cConta,cCusto,cItem,cClvl,lPosiciona,cTipo,lHelp,cEntCTB05,cEco05CR,cEnt5, cEnt6, cEnt7, cEnt8, cEnt9,cAtivde,cAtivcr,aAtivCT1,aAtivCTD,aAtivCTH,aAtivCTT)

Local aSaveAREA := GetArea()
Local cEntidade	:= ""
Local cAlias    := ""
Local aGenerico := {}

//Controle de Loop
Local ni
Local nj
Local nf

Local cSayCusto	:= CtbSayApro("CTT")
Local cSayItem	:= CtbSayApro("CTD")
Local cSayClVL	:= CtbSayApro("CTH") 
Local cSayEnt5  := "" 
Local lRet		:= .T.
Local i
Local aQt       :={}

Default lHelp	:= .T.
Default cEnt5	:= ""
Default cEnt6	:= ""
Default cEnt7	:= ""
Default cEnt8	:= ""
Default cEnt9	:= ""
DEFAULT cEco05CR := ""
DEFAULT cAtivde  := ""
DEFAULT cAtivcr  := ""
DEFAULT aAtivCT1 := {}
DEFAULT aAtivCTD := {}
DEFAULT aAtivCTH := {}
DEFAULT aAtivCTT := {}

If lPosiciona
	CtbPosic(cConta,cCusto,cItem,cClvl)
EndIF

If cTipo != Nil
	If cTipo == "1"
		cDC := STR0022
	Else
		cDc :=STR0023
	EndIf
Else
	cDc := " "
EndIf

// Testar Validacao de CT1_CCOBRG / CT1_ITOBRG / CT1_CLOBRG
If lRet
	cEntidade := ''
	If CT1->CT1_CCOBRG == "1" .And. Empty(cCusto)
		cEntidade += cSayCusto + cDC
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	EndIf
	If lRet
		If CT1->CT1_ITOBRG == "1" .And. Empty(cItem)
			cEntidade += cSayItem + cDC
			If lHelp
				Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If CT1->CT1_CLOBRG == "1" .And. Empty(cClVL)
			cEntidade += cSayCLVL + cDc
			If lHelp
				Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
	If lRet
		lRet := CTBVldNEnt( lHelp, cEnt5, cEnt6, cEnt7, cEnt8, cEnt9, cEntidade,cDc )
	EndIf
EndIf

// Testar Validacao de CTT_ITOBRG / CTT_CLOBRG
If lRet .And. !Empty(cCusto)
	cEntidade := STR0024
	If CTT->CTT_ITOBRG == "1" .And. Empty(cItem)
		cEntidade	+= cSayItem + cDC
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	EndIf
	If lRet
		If CTT->CTT_CLOBRG == "1" .And. Empty(cClVl)
			cEntidade	+= 	cSayClVl + cDC
			If lHelp
				Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf

// Testar Validacao de CTD_CLOBRG
If lRet .And. !Empty(cItem)
	cEntidade := STR0024
	If CTD->CTD_CLOBRG == "1" .And. Empty(cClVl)
		cEntidade	+= 	cSayClVl + cDC
		If lHelp
			Help(" ",1,"ENTIDOBRIG",,cEntidade,3,1)
		EndIf
		lRet := .F.
	EndIf
EndIf


// Testar Validacao de CT1_ACCUSTO / CT1_ACITEM / CT1_ACCLVL
// Se nao aceita entidade e entidade preenchida -> Help!!
If lRet
	cEntidade := STR0024
	If CT1->CT1_ACCUST == "2" .And. !Empty(cCusto)
		cEntidade += cSayCusto + cDC
		If lHelp
			Help(" ",1,"NAOACENTID",,cEntidade,3,1)
		EndIf
		lRet := .F.
	EndIf
	If lRet
		If CT1->CT1_ACITEM == "2" .And. !Empty(cItem)
			cEntidade += cSayItem + cDC
			If lHelp
				Help(" ",1,"NAOACENTID",,cEntidade,3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If CT1->CT1_ACCLVL == "2" .And. !Empty(cClVL)
			cEntidade += cSayCLVL + cDC
			If lHelp
				Help(" ",1,"NAOACENTID",,cEntidade,3,1)
			EndIf
			lRet := .F.
		EndIf
	EndIf  
	
	If lRet   
   		
   		nOrder 	:= CT0->(IndexOrd())
		nRecno 	:= CT0->(Recno())
		
		CT0->(DbSetOrder(1))
		CT0->(DbGoTop())
		CT0->(DbSeek(xFilial("CT0")+"05"))
		
		While CT0->CT0_FILIAL == xFilial("CT0") .And. Val(CT0->CT0_ID) >= 5 .And. !Eof()
		
			cId      := CT0->CT0_ID     
			cId2     := SubStr(CT0->CT0_ID, 2, 1) 
					
			cSayEnt5 := CtbSayApro(CT0->CT0_ALIAS,cId)  
					
			If !Empty(cId2) .And. &("CT1->CT1_ACET"+cId) == "2" .And. !Empty(Eval(MontaBlock(  "{||cEnt"+cId2+"}" )))
				cEntidade := cSayEnt5 + cDC
				If lHelp
					Help(" ",1,"NAOACENTID",,cEntidade,3,1)
				EndIf
				lRet := .F.
				Exit
			EndIf  
			
			CT0->(DbSkip())
			
		End       
		
		CT0->(DbSetOrder(nOrder))
		CT0->(DbGoto(nRecno))
		
	EndIF
	
EndIf

// Testar Validacao de CTT_ACITEM / CTT_ACCLVL
If lRet .And. !Empty(cCusto)
	cEntidade	:= STR0025
	If CTT->CTT_ACITEM == "2" .And. !Empty(cItem)
		cEntidade += cSayItem + cDC
		If lHelp
			Help(" ",1,"NCCACENTID",,cEntidade,3,1)
		EndIf
		lRet := .F.
	EndIf
	
	If lRet
		If CTT->CTT_ACCLVL == "2" .And. !Empty(cClVl)
			cEntidade += cSayClVl + cDC
			If lHelp
				Help(" ",1,"NCCACENTID",,cEntidade,3,1)
			EndIF
			lRet := .F.
		EndIf
	EndIf
EndIf

// Testar Validacao de CTD_ACCLVL
If lRet .And. !Empty(cItem)
	cEntidade	:= STR0026  //"O item nao permite lancamento com a entidade "
	If CTD->CTD_ACCLVL == "2" .And. !Empty(cClVl)
		cEntidade += cSayClVl + cDC
		If lHelp
			Help(" ",1,"NITACENTID",,cEntidade,3,1)
		EndIf
		lRet := .F.
	EndIf
EndIf

//****************************************************
//  Ativar quando for criado o controle de amarração *
//****************************************************
If lRet .AND. cPaisLoc $"PER#COL"
	// Valida se entidade for obrigatoria conforme o plano de contas
	If CT1->CT1_05OBRG == "1"
		If lRet .and. cEntCTB05<>nil .and. Empty(cEntCTB05)
			If lHelp
				Help(" ",1,"ENTIDOBRIG",,"Ent.05",3,1)
			EndIf
			lRet := .F.
		EndIf
		
		/*	Fase 2 retirado pora falta de itegridade
		If lRet .and. Empty(cAtivde)
		If lHelp
		Help(" ",1,"ENTIDOBRIG",,"Ativ.Debito",3,1)
		EndIf
		lRet := .F.
		EndIf
		If lRet .and. Empty(cAtivcr)
		If lHelp
		Help(" ",1,"ENTIDOBRIG",,"Ativ.Credito",3,1)
		EndIf
		lRet := .F.
		EndIf
		*/
	EndIf
EndIf

//Valida preenchimento de informações complementares obrigatórias das Entidades Contábeis
If ( lRet )
	For nj := 1 To 4
		If ( nj == 1 )
			cAlias    := "CT1"
			nf        := Len( aAtivCT1 )
			cEntidade := cConta
			aGenerico := AClone( aAtivCT1 )
		ElseIf ( nj == 2 )
			cAlias    := "CTD"
			nf        := Len( aAtivCTD )
			cEntidade := cItem
			aGenerico := AClone( aAtivCTD )
		ElseIf ( nj == 3 )
			cAlias    := "CTH"
			nf        := Len( aAtivCTH )
			cEntidade := cClVl
			aGenerico := AClone( aAtivCTH )
		ElseIf ( nj == 4 )
			cAlias    := "CTT"
			nf        := Len( aAtivCTT )
			cEntidade := cCusto
			aGenerico := AClone( aAtivCTT )
		Else
			cEntidade := ""
			aGenerico := {}
			nf        := 0
		EndIf
		
		If ( lRet ) .And. ( !Empty( cEntidade ) )
			(cAlias)->(dbSetOrder(1))
			If ( cAlias )->( dbSeek( xFilial(cAlias) + cEntidade ) )
				For ni := 1 To nf
					If ( Val(&(aGenerico[ni][1])) == 1 ) .And. ( Val(&(aGenerico[ni][2])) == 1 )
						If ( Empty( &(aGenerico[ni][3]) ) )
							Help( " ", 1, "P" + aGenerico[ni][3] )
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	Next
EndIf

RestAREA(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidaLP  ³ Autor ³ Simone Mie Sato       ³ Data ³ 23.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Lancamento Padrao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidaLP(cLP)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cod. Lancamento Padrao                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValidaLP(cLP)

Local aSaveArea := GetArea()
Local lRet		:= .T.

IF !Empty(cLP)
	dbSelectArea("CT5")
	dbSetOrder(1)
	If !MsSeek(xFilial()+cLP)
		lRet := .F.
		Help(" ",1,"NOCODLP")
	EndIf
EndIF

RestArea(aSaveArea)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbStatus   ³ Autor ³ Simone Mie Sato      ³ Data ³ 18.06.2002		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe algum calendario encerrado no periodo solicitado	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbStatus(cCpoDescricao)                                   	  		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo para retorno da descricao (Macro-Substituicao)    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CtbStatus(cMoeda,dDataIni,dDataFim,lAll)

Local aSaveArea	:= GetArea()
Local aPeriodos	:= {}
Local lRet		:= .T.
Local nPeriodos	:= 0

DEFAULT lAll	:= .T.
If Month(dDataIni) = Month(dDataFim) .And. Year(dDataIni) = Year(dDataFim)
	aPeriodos	:= CtbPeriodos(cMoeda,dDataIni,dDataFim,.F.,.F.)
Else
	If lAll	//Se eh para verificar o calendario inteiro
		aPeriodos	:= CtbPeriodos(cMoeda,dDataIni,dDataFim,.T.,.F.)
	Else	//Se nao eh para verificar somente a linha do calendario solicitado.
		aPeriodos	:= CtbPeriodos(cMoeda,dDataIni,dDataFim,.F.,.F.)
	EndIf
EndIf

If !Empty(aPeriodos)
	For nPeriodos := 1 to len(aPeriodos)
		If aPeriodos[nPeriodos][4] <> '1'
			Help(" ",1,"CTGDTCOMP")
			lRet	:= .F.
			Exit
		EndIf
	Next
EndIf

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CtVlOutvlr ³ Autora³ Simone Mie Sato     ³ Data ³ 05.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o crit. eh igual 4. So podera alterar se for 4  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtVlOutVlr()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nValorr	 = Valor                                          ³±±
±±³          ³ nMoeda 	 = Numero da Moeda                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtVlOutVlr(nValor,nMoeda)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

If nValor <> 0
	If Subs(TMP->CT2_CONVER,nMoeda,1) <> "4" .AND. Subs(TMP->CT2_CONVER,nMoeda,1) <> "A"
		lRet	:= .F.
		Help(" ",1,"NOCRITER")
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbVldDig ³ Autor ³ Simone Mie Sato       ³ Data ³ 01.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o digito verificador da conta contabil              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbVldDig(cConta,cDigito)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cConta = Conta                                             ³±±
±±³          ³ cDigito = Digito Verificador                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbVldDig(cConta,cDigito)

Local aSaveArea	:= GetArea()
Local lRet		:= .T. 

dbSelectArea("CT1")
dbSetOrder(1)
If MsSeek(xFilial()+cConta)
	If CT1->CT1_DC <> cDigito
		lRet	:= .F.
		Help( " ", 1, "DIGITO" )
	EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbValDel   ³ Autor ³ Simone Mie Sato      ³ Data ³ 15.05.2003		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar se pode excluir o registro.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbValDel()                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cArqDel	   = Arquivo em que o registro sera excluido.			   	³±±
±±³          ³ aArqSeek    = Array contendo as tabelas a serem verificadas.  	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbValDel(cArqDel,aArqSeek)

Local aSaveArea		:= GetArea()
Local lRet			:= .T.
Local cFilBack		:= cFilAnt
Local cModo			:= ""
Local cModoUni		:= ""
Local cModoEmp		:= ""	
Local nArqs			:= 0
Local aSM0			:= AdmAbreSM0()
Local nContFil		:= 0
Local cCodEmpOri 	:= FWCodEmp(cArqDel)
Local cCodUnOri		:= FWUnitBusiness(cArqDel) 

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return .F.
Endif

dbSelectarea("SX2")
dbSetOrder(1)
If MsSeek(cArqDel)
	cModo		:=	SX2->X2_MODO
	cModoUni	:=	SX2->X2_MODOUN
	cModoEmp	:=	SX2->X2_MODOEMP
EndIf

If cModo == "C" .Or. cModoUni == "C" .Or. cModoEmp == "C" 	//Se a tabela do registro a ser excluido for compartilhado, devera ser verificado em todas as filiais
	For nContFil := 1 to Len(aSM0)
		If aSM0[nContFil][SM0_GRPEMP] != cEmpAnt .Or.;
			( (cModoEmp == "E") .And. (aSM0[nContFil][SM0_EMPRESA] != cCodEmpOri) .And. (!Empty(aSM0[nContFil][SM0_EMPRESA] )) ) .Or.;
			( (cModoUni == "E") .And. (aSM0[nContFil][SM0_UNIDNEG] != cCodUnOri ) .And. (!Empty(aSM0[nContFil][SM0_UNIDNEG] )) ) 			
			Loop
		EndIf
		For nArqs	:= 1 to Len(aArqSeek)
			dbSelectArea(aArqSeek[nArqs][1])	//Tabela a ser verificada
			dbSetOrder(aArqSeek[nArqs][2])		//Ordem utilizada
			cFilAnt	:= aSM0[nContFil][SM0_CODFIL]
			If MsSeek(xFilial()+aArqSeek[nArqs][3])		//Chave a ser procurada, sem a filial
				lRet	:= .F.
				cFilAnt	:= cFilBack
				RestArea(aSaveArea)
				Return(lRet)
			EndIf
		Next
	Next nContFil
	cFilAnt := cFilBack
Else
	For nArqs	:= 1 to Len(aArqSeek)
		dbSelectArea(aArqSeek[nArqs][1])	//Tabela a ser verificada
		dbSetOrder(aArqSeek[nArqs][2])		
		If MsSeek(xFilial()+aArqSeek[nArqs][3])
			lRet	:= .F.
			Exit		
		EndIf
	Next
EndIf

RestArea(aSaveArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbExDtFim³ Autor ³ Simone Mie Sato       ³ Data ³ 21.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificar se o campo DTEXSF existe.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbExDtFim()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Entidade                                           ³±±
±±³          ³ ExpD1 = Data                                               ³±±
±±³          ³ ExpC2 = Alias                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbExDtFim( cCadAlias )
Local aSaveArea	:= GetArea()
Local lRet		:= .F.

If cCadAlias == "CV0"
	If (cCadAlias)->(FieldPos((cCadAlias)+"_DTFEXI")) > 0
		lRet	:= .T.
	EndIf
Else
	If (cCadAlias)->(FieldPos((cCadAlias)+"_DTEXSF")) > 0
		lRet	:= .T.
	EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbVlDtFim³ Autor ³ Simone Mie Sato       ³ Data ³ 21.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data de existencia final da entidades.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbVlDtFim(cCadAlias)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Entidade                                           ³±±
±±³          ³ ExpD1 = Data                                               ³±±
±±³          ³ ExpC2 = Alias                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbVlDtFim(cCadAlias,dDataIni)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

If cCadAlias == "CV0"
	If !Empty((cCadAlias)->&(cCadAlias+"_DTFEXI")) .And. (dtos(dDataIni) > DTOS((cCadAlias)->&(cCadAlias+"_DTFEXI")))
		lRet	:= .T.
	EndIf
Else
	If !Empty((cCadAlias)->&(cCadAlias+"_DTEXSF")) .And. (dtos(dDataIni) > DTOS((cCadAlias)->&(cCadAlias+"_DTEXSF")))
		lRet	:= .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CanDelCt2 ºAutor  ³Marcos S. Lobo      º Data ³  01/26/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se pode efetuar a exclusao do CT2 se puder         º±±
±±º          ³efetua a remarcaçao dos flags de contabilizaçao.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - funcao CtbGrava() - CTBXFUN e CTB101GRV() - CTBA101   º±±
±±º          ³      Exclusão de Lançamentos rotina manual ou automatica   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CanDelCt2(nOpc,nRotina,cModoClr)

Local lExcluir := .T.

DEFAULT nRotina := 2

If nRotina == 1	///CHAMADA PELO CTBA101
	/// SE FOR LANCAMENTO DE INTEGRAÇAO, COM VALOR (123) e na MOEDA 01
	If !Empty(CT2->CT2_DTCV3) .and. CT2->CT2_DC <= '3' .and. CT2->CT2_MOEDLC == "01"
		/// SE FOR ALTERACAO EXCLUINDO LINHA ou EXCLUSAO
		If nOpc == 5		///	NAO HÁ COMO EXCLUIR DURANTE ALTERAÇÃO NO CTBA101
			/// VERIFICA FLAGS TABELAS DE ORIGEM PARA REMARCAÇÃO DOS FLAGS DE CONTABILIZAÇÃO
			If CT2ClearLA(cModoClr) >= "3"		/// SE CANCELOU A EXCLUSÃO
				lExcluir := .F.
			EndIf
		Endif
	EndIf
Else			///CHAMADA PELO CTBA102/CTBA105 (TRABALHA COM TMP)
	/// SE FOR LANCAMENTO DE INTEGRAÇAO, COM VALOR (123) e na MOEDA 01
	If !Empty(CT2->CT2_DTCV3) .and. CT2->CT2_DC <= '3' .and. CT2->CT2_MOEDLC == "01"
		/// SE FOR ALTERACAO EXCLUINDO LINHA ou EXCLUSAO
		If ( nOpc == 4 .and. TMP->CT2_FLAG) .or. nOpc == 5
			/// VERIFICA FLAGS TABELAS DE ORIGEM PARA REMARCAÇÃO DOS FLAGS DE CONTABILIZAÇÃO
			If CT2ClearLA(cModoClr) >= "3"		/// SE CANCELOU A EXCLUSÃO
				lExcluir := .F.
			EndIf
		Endif
	EndIf
EndIf

Return lExcluir


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbVlDtIni³ Autor ³ Simone Mie Sato       ³ Data ³ 02.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data de existencia inicial da entidade.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbVlDtIni(cCadAlias)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Entidade                                           ³±±
±±³          ³ ExpD1 = Data                                               ³±±
±±³          ³ ExpC2 = Alias                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbVlDtIni(cCadAlias,dDataFim)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.


If !Empty((cCadAlias)->&(cCadAlias+"_DTEXIS")) .And.  DTOS((cCadAlias)->&(cCadAlias+"_DTEXIS"))>(dtos(dDataFim))
	lRet	:= .F.
EndIf

RestArea(aSaveArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldTpSald   ³ Autor ³ Totvs                   ³ Data ³ 15/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o tipo de saldo informado                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTpSaldo - tipo do saldo a ser validado.                        ³±±
±±³          ³ cCharEsp - se permite o caracter * ou nao.                      ³±±
±±³          ³ lOrcado - se permite efetuar lançamento do tipo 0               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldTpSald( cTpSaldo, lCharEsp, lOrcado, lShowHelp )
Local lRet			:= .F.
Default lCharEsp	:= .F.
Default lOrcado	:= .F.
Default lShowHelp := .T.

If cTpSaldo == "*" .And. lCharEsp
	lRet := .T.
ElseIF cTpSaldo == "0" .And. !lOrcado
	lRet := .F.
	If lShowHelp
		Help('',1,'TPSALDINV',,OemtoAnsi(STR0040),2,0) //"Tipo de saldo inválido pra essa operação!"
	EndIf
Else
	lRet := !Empty( Tabela( "SL", cTpSaldo, lShowHelp ) )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³CTBLanXProc³ Autor ³ Totvs                   ³ Data ³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para verificar lancamento padrao no seu respectivo     ³±±
±±³          ³ modulo e processo.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBLanXProc( cCodigo, cModulo, cProcesso )

Local lReturn 	:= .T.
Local aArea	 	:= GetArea()
Local aAreaCVA	:= {}

aAreaCVA 	:= CVA->( GetArea() )
DbSelectArea( "CVA" )
CVA->( DbSetOrder( 1 ) )
lReturn := CVA->( DbSeek( xFilial( "CVA" ) + cCodigo ) .And. ;
		    CVA->CVA_MODULO == cModulo .AND. ;
	        CVA->CVA_PROCES == cProcesso )
RestArea( aAreaCVA )
	
RestArea( aArea )

Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbRegCTZ ³ Autor ³ Simone Mie Sato       ³ Data ³ 28.11.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe registro no arquivo de conta ponte       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbRegCTZ(cMoeda                              		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbRegCTZ(cMoeda,dDataLP,cTpSald)

Local aSaveArea	:= GetArea()
Local lRet		:= .F.
Local cQuery 	:= ""

cQuery := " SELECT "
cQuery += " CTZ_FILIAL, "
cQuery += " CTZ_MOEDLC, "
cQuery += " CTZ_DATA, "
cQuery += " CTZ_TPSALD "
cQuery += " FROM " + RetSqlName("CTZ")+" CTZ "
cQuery += " WHERE "
cQuery += " CTZ.D_E_L_E_T_ = ' ' "
cQuery += " AND CTZ_FILIAL = '"+xFilial("CTZ")+"' "
cQuery += " AND CTZ_DATA = '"+Dtos(dDataLP)+"' "
If ! Empty(cMoeda)
	cQuery += " AND CTZ_MOEDLC = '"+cMoeda+"' "
	If ! Empty(cTpSald)
		cQuery += " AND CTZ_TPSALD = '"+cTpSald+"' "
	EndIf
EndIf
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CTZ_QRY",.T.,.F.)

lRet := CTZ_QRY->(! Eof() )

dbSelectArea("CTZ_QRY")
dbCloseArea()

RestArea(aSaveArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ConvConta ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte Codigo Reduzido para Codigo Normal                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ConvConta(cConta)		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico  	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta contabil                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ConvConta(cConta)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local lReduz	:= GetMv("MV_REDUZID") == "S"
Local cCtaSeek	:= cConta

If !Empty(cConta)
	// Conta digitada sera sempre pelo codigo reduzido
	If !lReduz .And. Substr(cConta,1,1) == "*"
		cCtaSeek := SubStr(cConta,2)
		lReduz := .T.
	EndIf        
	
	cCtaSeek := Alltrim(cCtaSeek)
	
	If lReduz .And. Len(cCtaSeek) <= Len(CT1->CT1_RES)
 		cCtaSeek := PadR( cCtaSeek, Len(CT1->CT1_RES))
 		dbSelectArea("CT1")
 		CT1->(dbSetOrder(2))
 		If CT1->(dbSeek(xFilial("CT1")+cCtaSeek))
			cConta 	:= CT1->CT1_CONTA
			lRet 	:= ValidaConta(cConta)
		EndIf
	EndIf
		
EndIf

RestArea(aSaveArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb101Moed³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Moeda do Lancamento Contabil 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb101Moeda(cMoeda,nOpc,dData)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Moeda do Lancamento                                ³±±
±±³          ³ ExpN1 = Numero da opcao escolhida                          ³±±
±±³          ³ ExpD1 = Data                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb101Moeda(cMoeda, nOpc, dData, cTpSald)

Local aSaveArea:= GetArea()
Local lRet		:= .T. 

Default cTpSald := ""

dbSelectArea("CTO")
dbSetOrder(1)
If !dbSeek(xFilial()+cMoeda)
	Help(" ",1,"NOMOEDA")
	lRet := .F.
Else
	// Valida a Data
	lRet := CtbDtComp(nOpc, dData, cMoeda,, cTpSald)
EndIf

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbTipo   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna Tipo do Lancamento a partir da matriz/combo Tipos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbTipo(cTipo)                                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.  	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo do Lancamento Contabil                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbTipo(cTipo)
Local lRet := .T.

If Empty(cTipo) .OR. !(cTipo$"123")
	Help(" ",1,"TIPOINVALI")
	lRet := .F.
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb101Bloq  ³ Autor ³ Simone Mie Sato      ³ Data ³ 15.04.2005		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar o bloqueio das entidades.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb101Bloq(cAlias,cCodigo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb => X3_WHEN=> CTBA102/CTBA105                      			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias 	   = Entidade a ser verificada.                			   	³±±
±±³          ³ cCodigo     = Codigo da entidade a ser verificada.            	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb101Bloq(cAlias,cCodigo,cCampo,cCampo1,cCampo2,dDataLanc,cTipoCTB,cDebito,cCredit,;
cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cCLVLDeb,cCLVLCrd,lHelp)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

DEFAULT lHelp	:= .T.

If !Empty(cCampo)
	If cCampo1 == cCampo2
		Return .T.
	EndIf
EndIf

//Se ira verificar somente uma determinada entidade. Campos: Conta, Centro de Custo, Item ou Classe de Valor
If !Empty(cAlias)
	If !ValidaBloq(cCodigo,dDataLanc,cAlias,lHelp)
		lRet	:= .F.
	EndIf
Else	//Campos: Valor, Tipo de Saldo, Criterio de Conversao, Tipo de lancamento, Moedas.
	If ( cTipoCTB $"13" .And. !ValidaBloq(cDebito,dDataLanc,"CT1",lHelp).Or.!ValidaBloq(cCredit,dDataLanc,"CT1",lHelp)  .Or. ;
		( !Empty(cCustoDeb) .And.  !ValidaBloq(cCustoDeb,dDataLanc,"CTT",lHelp)) .Or.  ;
		( !Empty(cItemDeb) .And.  !ValidaBloq(cItemDeb,dDataLanc,"CTD",lHelp)) .Or. ;
		( !Empty(cClVlDeb) .And.  !ValidaBloq(cClVlDeb,dDataLanc,"CTH",lHelp)))  .OR. ;
		( cTipoCTB $ "23" .And. !ValidaBloq(cDebito,dDataLanc,"CT1",lHelp) .Or. !ValidaBloq(cCredit,dDataLanc,"CT1",lHelp) .Or. ;
		( !Empty(cCustoCrd) .And.  !ValidaBloq(cCustoCrd,dDataLanc,"CTT",lHelp)) .Or.  ;
		( !Empty(cItemCrd) .And.  !ValidaBloq(cItemCrd,dDataLanc,"CTD",lHelp)) .Or. ;
		( !Empty(cClVlCrd) .And.  !ValidaBloq(cClVlCrd,dDataLanc,"CTH",lHelp)))
		lRet	:= .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct101ChDoc ³ Autor ³ Simone Mie Sato      ³ Data ³ 28.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificar se debito/credito estao batendo por documento.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct101ChDoc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.					                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico				                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo do Saldo Lancamento Contabil (Orcado/Real)    ³±±
±±³          ³ ExpO1 = Objeto para apresentacao do tipo de saldo digitado ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct101ChDoc(cTipo,dData,cLote,cSubLote,cDoc,cMoeda,cTpSald,nValor)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

dbSelectArea("CTC")
dbSetOrder(1)
If MsSeek(xFilial()+DTOS(dData)+cLote+cSubLote+cDoc+cMoeda+cTpSald)
	Do Case
		Case cTipo == "1"
			If NoRound(Round((CTC->CTC_DEBITO + nValor),3))<> NoRound(Round(CTC->CTC_CREDIT,3))
				lRet	:= .F.
			EndIf
		Case cTipo == "2"
			If NoRound(Round((CTC->CTC_CREDIT + nValor),3))<> NoRound(Round(CTC->CTC_DEBITO,3))
				lRet	:= .F.
			EndIf
		Case cTipo == "3"
			If NoRound(Round((CTC->CTC_CREDIT + nValor),3))<> NoRound(Round((CTC->CTC_DEBITO+nValor),3))
				lRet	:= .F.
			EndIf
	EndCase
Else
	Do Case
		Case cTipo $ "1/2"
			lRet	:= .F.
	EndCase
EndIf
RestArea(aSaveArea)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbValCta ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 06.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a digitacao das contas para rateio gerencial      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbValCta(cDebito, cCredito)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F. = Se sim permite a digitacao das contas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDebito  = Conta digitada a debito do rateio gerencial     ³±±
±±³          ³ cCredito = Conta digitada a crebito do rateio gerencial    ³±±
±±³          ³ cTpEntida = Variavel que identifica validacao por entidade ³±±
±±³          ³ 1 = Identifica que todos os registro verificara CC         ³±±
±±³          ³ 2 = Identifica que todos os registro verificara Item       ³±±
±±³          ³ 3 = Identifica que todos os registro verificara Classe Val.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbValCta(cDebito, cCredito, cTpEntida)
Local aArea := GetArea()
Local lRet := .F.

dbSelectArea("CT1")
dbSetOrder(1)
If ! Empty(cDebito) .And. CT1->(MsSeek(xFilial() + cDebito))
	If cTpEntida = "0" .And. IsInCallStack("CTBESCRAT")
		lRet := .T.
	EndIf
	If cTpEntida = "1" .And. CT1->CT1_ACCUST <> "2"
		lRet := .T.
	Endif
	If cTpEntida = "2" .And. CT1->CT1_ACITEM <> "2"
		lRet := .T.
	Endif
	If cTpEntida = "3" .And. CT1->CT1_ACCLVL <> "2"
		lRet := .T.
	Endif
Endif

If ! lRet .And. ! Empty(cCredito) .And. CT1->(MsSeek(xFilial() + cCredito))
	If cTpEntida = "0" .And. IsInCallStack("CTBESCRAT")
		lRet := .T.
	EndIf
	If cTpEntida = "1" .And. CT1->CT1_ACCUST <> "2"
		lRet := .T.
	Endif
	If cTpEntida = "2" .And. CT1->CT1_ACITEM <> "2"
		lRet := .T.
	Endif
	If cTpEntida = "3" .And. CT1->CT1_ACCLVL <> "2"
		lRet := .T.
	Endif
Endif

If Empty(cDebito) .And. Empty(cCredito)
	lRet := .F.
Endif
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct102VlDoc³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe num. lote e doc e nao deixa incluir.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct102VlDoc(dData,cLote,cSubLote,cDoc,cProg)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento Contabil                        ³±±
±±³          ³ ExpC1 = Lote do Lancamento Contabil                        ³±±
±±³          ³ ExpC2 = Documento do Lancamento Contabil                   ³±±
±±³          ³ ExpO1 = Objeto do documento                                ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct102VlDoc(dData,cLote,cSubLote,cDoc,cProg)

Local lRet 		:= .T., aArea := GetArea()
Local aSaveArea := CT2->(GetArea())

If 	dData <> Nil .And. cLote <> Nil .And. cSubLote <> Nil .And. cDoc <> Nil .And.;
	(cProg == 'CTBA102' .Or. cProg == 'CTBA105' .Or. cProg == 'CTBA103')
	dbSelectArea("CTF")
	dbSetOrder(1)
	If MsSeek(xFilial("CTF")+dtos(dData)+cLote+cSubLote+cDoc) .And. !Empty(CTF->CTF_LINHA)
		lRet := .F.
	Endif
	
	If lRet		// Verifico tambem no arquivo de lancamentos como garantia
		dbSelectArea("CT2")
		dbSetOrder(1)
		If MsSeek(xFilial("CT2")+dtos(dData)+cLote+cSubLote+cDoc)
			lRet := .F.
		Endif
	Endif
	
	If ! lRet
		Help(" ",1,"LOTDOCEX")
	Endif
	CT2->(RestArea(aSaveArea))
	RestArea(aArea)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³C102CapOK ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida dados digitados na capa de lote                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C102CapOk(dData,cLote,cSublote,cDoc)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento Contabil                        ³±±
±±³          ³ ExpC1 = Lote  do Lancamento Contabil                       ³±±
±±³          ³ ExpC2 = SubLote do Lancamento Contabil                     ³±±
±±³          ³ ExpC3 = Documento do lancamento contabil                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function c102CapOk(dData,cLote,cSubLote,cDoc)

Local lRet := .T.

If Empty(dData) .Or. Empty(cLote) .Or. Empty(cSubLote) .Or. Empty(cDoc)
	Help(" ",1,"NOCAPLOTE")
	lRet := .F.
EndIf

Return lret

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldCaplote ³ Autor ³ Simone Mie Sato       ³ Data ³17.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Para chamar o ponto de Entrada VLCPLOTE				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³VldCapLote(dDataLanc,cLote,cSubLote,cDoc,nOpc)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA102                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento                                 ³±±
±±³          ³ ExpC1 = Numero do Lote do Lancamento                       ³±±
±±³          ³ ExpC2 = Numero do Sub-Lote do Lancamento                   ³±±
±±³          ³ ExpC3 = Numero do documento do Lancamento                  ³±±
±±³          ³ ExpN1 = Numero da opcao escolhida                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc)

Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA VLCPLOTE                            ³
//³ Criado para poder verificar se o lancamento vindo de ³
//³ outro modulo podera ser alterado ou nao. Podera ser	 ³
//³ chamado na inclusao ou alteracao.                    ³
//³ ParamIxb:Data,Lote,Sub-Lote,Doc, nOpc.   	         ³
//³ Devera retornar .T. ou .F., pois sera utilizado na   ³
//³ validacao do botao OK.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("VLCPLOTE")
	lRet := ExecBlock("VLCPLOTE",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc,nOpc})
Endif

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbVldLP   ³ Autor ³ Simone Mie Sato       ³ Data ³ 11.12.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verificar se o documento eh de apuracao de lucros/perdas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbVldLP()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CtbVldLP(dDataLanc,cLote,cSubLote,cDoc,nOpc,lHelp,lSimula,cTabCTK,cTabCT2)

Local aSaveArea	:= GetArea()
Local nIndCT2	:= CT2->(IndexOrd())
Local nRecCT2	:= CT2->(Recno())
Local lRet		:= .T.
Local cMensagem	:= ""
Local cChaveCT2	:= ""

DEFAULT lHelp	:= .T.
Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

dbSelectArea("CT2")
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
	dbSetOrder(1)
EndIf
If MsSeek(xFilial()+dtos(dDataLanc)+cLote+cSubLote+cDoc)
	If (nOpc = 4 .Or. nOpc = 5) .And. !Empty(CT2->CT2_DTLP)
		cMensagem	:= STR0027 //"Nao é possivel a alteracao/exclusao de documento gerado pela apuracao de lucros/perdas.."
		cMensagem	+= STR0028 //"Favor rodar a rotina de estorno de apuracao de lucros/perdas.."
		If lHelp
			Help(" ",1,"CT1CRIA115",,cMensagem,1,0)
		EndIf
		lRet	:= .F.
	EndIf
EndIf

dbSelectArea("CT2")
dbSetOrder(nIndCT2)
dbGoTo(nRecCT2)
RestArea(aSaveArea)
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbTmpBloq  ³ Autor ³ Simone Mie Sato      ³ Data ³ 23.02.2005		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar o bloqueio das entidades na exclusao do documento.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbTmpBloq                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb 			                                        			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbTmpBloq(dDataLanc,cLote,cSubLote,cDoc,nOpc,lHelp,lSimula,cTabCTK,cTabCT2)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local nIndCT2	:= CT2->(IndexOrd())
Local nRecCT2	:= CT2->(Recno())
Local cChaveCT2	:= ""

DEFAULT	lHelp	:= .T.
Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If FwIsInCallStack('CTBA102')
	If nOpc == 5
		dbSelectarea("CT2")
		If lSimula
			dbSelectArea("SIX")
			dbSetOrder(1)		//INDICE+ORDEM
			dbGoTop()
			If SIX->(dbSeek("CT21"))
				cChaveCT2 := AllTrim(SIX->CHAVE)
				IndRegua("CT2", cTabCT2, cChaveCT2, , , )
			EndIf
			dbSelectArea(cTabCT2)
		Else
			dbSetOrder(1)
		EndIf
		If MsSeek(xFilial()+dtos(dDataLanc)+cLote+cSubLote+cDoc)
			While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And. DTOS(CT2->CT2_DATA) == DTOS(dDataLanc) .And.;
				CT2->CT2_LOTE == cLote .And. CT2->CT2_SBLOTE == cSubLote .And. CT2->CT2_DOC == cDoc
				If ( CT2->CT2_DC $ "13" .And.  !Ctb102Bloq("CT1",CT2->CT2_DEBITO,dDataLanc,lHelp) .Or.;
					( !Empty(CT2->CT2_CCD) .And.  !Ctb102Bloq("CTT",CT2->CT2_CCD,dDataLanc,lHelp)) .Or.;
					( !Empty(CT2->CT2_ITEMD) .And.  !Ctb102Bloq("CTD",CT2->CT2_ITEMD,dDataLanc,lHelp)) .Or.;
					( !Empty(CT2->CT2_CLVLDB) .And.  !Ctb102Bloq("CTH",CT2->CT2_CLVLDB,dDataLanc,lHelp))) .OR.;
					(  CT2->CT2_DC $ "23" .And.	 !Ctb102Bloq("CT1",CT2->CT2_CREDIT,dDataLanc,lHelp) .Or. ;
					(!Empty(CT2->CT2_CCC) .And.  !Ctb102Bloq("CTT",CT2->CT2_CCC,dDataLanc,lHelp)) .Or. ;
					(!Empty(CT2->CT2_ITEMC) .And.  !Ctb102Bloq("CTD",CT2->CT2_ITEMC,dDataLanc,lHelp)).Or. ;
					(!Empty(CT2->CT2_CLVLCR) .And.  !Ctb102Bloq("CTH",CT2->CT2_CLVLCR,dDataLanc,lHelp)))
					lRet	:= .F.
					Exit
				EndIf
				dbSelectArea("CT2")
				dbSkip()
			End
		EndIf
	EndIf
EndIf

dbSelectArea("CT2")
dbSetOrder(nIndCT2)
dbGoTo(nRecCT2)

RestArea(aSaveArea)
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb102Bloq  ³ Autor ³ Simone Mie Sato      ³ Data ³ 22.02.2005		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar o bloqueio das entidades.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb102Bloq(cAlias,cCodigo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb => X3_WHEN=> CTBA102/CTBA105                      			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias 	   = Entidade a ser verificada.                			   	³±±
±±³          ³ cCodigo     = Codigo da entidade a ser verificada.            	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb102Bloq(cAlias,cCodigo,dDataBloq,lHelp)

Local aSaveArea	:= GetArea()
Local lRet		:= .T.

DEFAULT dDataBloq	:= dDataLanc
DEFAULT lHelp		:= .T.

If FwIsInCallStack('CTBA102')
	//Se ira verificar somente uma determinada entidade. Campos: Conta, Centro de Custo, Item ou Classe de Valor
	If !Empty(cAlias)
		If !ValidaBloq(cCodigo,dDataBloq,cAlias,lHelp)
			lRet	:= .F.
		EndIf
	Else	//Campos: Valor, Tipo de Saldo, Criterio de Conversao, Tipo de lancamento, Moedas.
		If ( TMP->CT2_DC $"13" .And.( !ValidaBloq(TMP->CT2_DEBITO,dDataBloq,"CT1",lHelp)  .Or. ;
			( !Empty(TMP->CT2_CCD) .And.  !ValidaBloq(TMP->CT2_CCD,dDataBloq,"CTT",lHelp)) .Or. ;
			( !Empty(TMP->CT2_ITEMD) .And.  !ValidaBloq(TMP->CT2_ITEMD,dDataBloq,"CTD",lHelp)) .Or.;
			( !Empty(TMP->CT2_CLVLDB) .And.  !ValidaBloq(TMP->CT2_CLVLDB,dDataBloq,"CTH",lHelp)))) .OR.;
			( TMP->CT2_DC $ "23" .And.(!ValidaBloq(TMP->CT2_CREDIT,dDataBloq,"CT1",lHelp)	.Or. ;
			(!Empty(TMP->CT2_CCC) .And.  !ValidaBloq(TMP->CT2_CCC,dDataBloq,"CTT",lHelp)) .Or. ;
			(!Empty(TMP->CT2_ITEMC) .And.  !ValidaBloq(TMP->CT2_ITEMC,dDataBloq,"CTD",lHelp)) .Or. ;
			(!Empty(TMP->CT2_CLVLCR) .And.  !ValidaBloq(TMP->CT2_CLVLCR,dDataBloq,"CTH",lHelp))))
			lRet	:= .F.
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |CapValLP  ºAutor  ³Renato F. Campos    º Data ³  19/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validação do campo LP                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA102                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CapValLP( cPadrao )
Local aSaveArea := GetArea()
Local lRet		:= .T.

IF ! Empty( cPadrao )
	dbSelectArea( "CVA" )
	dbSetOrder( 1 )
	
	If MsSeek( xFilial() + cPadrao )
		lRet := .F.
		Help( " " , 1 , " " ,, STR0029 ,7,0) //##"Não é possivel utilizar uma LP definida como ponto de lançamento"
	EndIf
	
EndIF

RestArea( aSaveArea )

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | VdSetOfBook	  ºAutor³ Renato F. Campos º Data ³ 06/02/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para a validação da configuração do livro           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral/Demostrativos                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VdSetOfBook( cSetOfBook , lPlanGer )
Local aSaveArea := GetArea()
Local lOk := .T.
Local cFilialCtn := ""
Local nTamCod := TamSX3("CTN_CODIGO" )[ 1 ] 

Default cSetOfBook := " "  // código da configuração do livro
Default lPlanGer := .F. // Flag de controle sobre a validação do plano gerencial do livro

If lOk .AND. ( Empty( cSetOfBook ) .Or. ( cSetOfBook == Nil ) .Or. ValType( cSetOfBook ) <> "C" )
	lOk := .F.
EndIf

If lOk
	dbSelectArea("CTN")
	CTN->(dbSetOrder(1))
	
	cFilialCTN	:= xfilial( "CTN" )
	
	if Valtype( cFilialCTN ) <> "C"
		lOk := .F.
	Endif
	
	If lOk .AND. !MsSeek(cFilialCTN+PadR(cSetOfBook,nTamCod))
		lOk := .F.
	EndIf
Endif

If ! lOk
	Help( OemToAnsi(STR0054) ,1 ,"NOSETOF" ) //"O código do livro contábil informado é inválido." 
Else
	If ! Empty( lPlanGer ) .AND. ( Empty( CTN->CTN_PLAGER ) .OR. ( CTN->CTN_PLAGER == nil ) )
		lOk = .F.
		MsgInfo( OemToAnsi(STR0055) )//"O Livro Contábil informado não está configurado com uma Visão Gerencial. Verifique suas configurações."
	EndIf
EndIf

RestArea(aSaveArea)

Return lOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb101Lote³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida nro. do lote e gera proximo numero de documento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb101Lote(dData,cLote,cSubLote,cDoc,oDoc,CTF_LOCK)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento Contabil                        ³±±
±±³          ³ ExpC1 = Lote do Lancamento Contabil                        ³±±
±±³          ³ ExpC2 = Documento do Lancamento Contabil                   ³±±
±±³          ³ ExpO1 = Objeto do documento                                ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb101Lote(dData,cLote,cSubLote,cDoc,oDoc,CTF_LOCK)

Local lRet 		:= .T.
Local aSaveArea := GetArea()

If CTF_LOCK > 0
	dbSelectArea("CTF")
	dbSetOrder(1)
	dbGoto(CTF_LOCK)
	
	If CTF->CTF_LOTE != cLote .And. CTF->CTF_SBLOTE != cSubLote
		IF !ProxDoc(dData,cLote,cSubLote,@cDoc)
			Help(" ",1,"DOCESTOUR")
			lRet := .F.
		Endif
	EndIf
	
	RestArea(aSaveArea)
Endif

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb101Doc ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida nro. do documento e gera proximo se necessario      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb101Doc(dData,cLote,cSubLote,cDoc,oDoc,CTF_LOCK)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento Contabil                        ³±±
±±³          ³ ExpC1 = Lote do Lancamento Contabil                        ³±±
±±³          ³ ExpC2 = Documento do Lancamento Contabil                   ³±±
±±³          ³ ExpO1 = Objeto do documento                                ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb101Doc(dData,cLote,cSubLote,cDoc,oDoc,CTF_LOCK,nOpc)

Local aSaveArea:= GetArea()
Local lRet     := .T.
Local nIndCT2  := CT2->(IndexOrd())
Local nRecCT2  := CT2->(Recno())
Local cNameFun := FunName()
Local lNewCTF  := .F.
Local lMsgUnq		:= IsInCallStack("CTBI102")

If CTF_LOCK > 0
	dbSelectArea("CTF")
	dbSetOrder(1)
	dbGoTo(CTF_LOCK)
	If (CTF->CTF_LOTE <> cLote .Or. CTF->CTF_SBLOTE <> cSubLote .Or. CTF->CTF_DOC <> cDoc)	/// SE A CHAVE EM TELA FOR DIFERENTE DO CTF "LOCADO"
		If Empty(CTF_LINHA)
			CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,@CTF_LOCK)		///	LIBERA O CTF ANTERIOR (MAS CHECA SE OUTRO USUÁRIO NAO GRAVOU CT2 COM O MESMO NUMERO PARA NÃO DELETAR INDEVIDO)
		Endif
	Else
		CT2->(dbSetOrder(nIndCT2))
		CT2->(dbGoTo(nRecCT2))
		RestArea(aSaveArea)
		Return(lRet)		//// SE PASSAR... CAI NO TESTE DO RLOCK CTF E JA ESTÁ "LOCADO"
	EndIf
Endif

If dData <> Nil .And. cLote <> Nil .And. cSubLote <> Nil .And. cDoc <> Nil
	DbSelectArea("CTF")
	dbSetOrder(1)
	If MsSeek(xFilial("CTF")+dtos(dData)+cLote+cSubLote+cDoc)
		If nOpc == 3 .or. nOpc == 6	.Or. nOpc == 7									//// SE FOR INCLUSAO
			If !Empty(CTF->CTF_LINHA) .and. cNameFun != "CTBA101"
				Help("",1,"EXISTCHAV")									/// JA FOI UTILIZADO POR OUTRO USUARIO
				lRet := .F.  											///Se achou e esta bloqueado, mostra Help de acordo com a chave de valida‡„o
			Endif
		Endif
		If !lMsgUnq // Proteção Mensagem Unica
			If lRet
				If CTF->(RLock())										/// SE NÃO ESTIVER "LOCADO" USA O NUMERO (RLOCK PARA RETORNAR .F. SE NÃO CONSEGUIU O HANDLE
					CTF_LOCK := CTF->(Recno())
				Else
					Help("",1,"USEDCODE")							/// ESTÁ "LOCADO" INDICA USO POR OUTRO USUARIO
					lRet := .F.  										///Se achou e esta bloqueado, mostra Help de acordo com a chave de valida‡„o
				Endif
			Endif
		Endif
	Else
		lNewCTF := .T.
	Endif
	
	If lRet
		If nOpc == 3 .or. nOpc == 6 .Or. nOpc == 7												//// SE FOR INCLUSAO
			dbSelectArea("CT2")
			dbSetOrder(1)
			If MsSeek(xFilial("CT2")+dtos(dData)+cLote+cSubLote+cDoc) .AND. cNameFun != "CTBA101" 			/// JA EXISTE NO CTF E TAMBEM NO CT2
				Help("",1,"EXISTCHAV")									/// CHAVE JÁ CADASTRADA, MUDE A CHAVE PRINCIPAL
				lRet := .F.
			Endif
		Endif
	Endif
	
	If lRet .and. lNewCTF
		LockDoc(dData,cLote,cSubLote,cDoc,@CTF_LOCK )
	Endif
	
	If ValType(oDoc) == "O"
		oDoc:Refresh()
	Endif
Else
	Help("",1,"OBRIGCAMPO")			/// CAMPOS OBRIGATORIOS NÃO PREENCHIDOS
	lRet := .F.	//// SE ALGUM DOS CAMPOS DE CABECALHO ESTIVER VAZIO RETORNA .F. (NAO VALIDO)
EndIf

CT2->(dbSetOrder(nIndCT2))
CT2->(dbGoTo(nRecCT2))
RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbProxLin ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera proxima linha do lancamento manual                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbProxLin(dData,cLote,cSubLote,cDoc,cLinha,oLinha)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento Contabil                         ³±±
±±³          ³ ExpC1 = Lote do Lancamento Contabil                         ³±±
±±³          ³ ExpC2 = Sub-Lote do Lancamento Contabil                     ³±±
±±³          ³ ExpC3 = Documento do Lancamento Contabil                    ³±±
±±³          ³ ExpC4 = Numero da Linha                                     ³±±
±±³          ³ ExpO1 = Objeto da Linha                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbProxLin(dData,cLote,cSubLote,cDoc,cLinha,oLinha)

Local aSaveArea:= GetArea()
Local lRet		:= .T.

dbSelectArea("CTF")
dbSetOrder(1)
dbSeek(xFilial()+DTOS(dData)+cLote+cSubLote+cDoc,.T.)

cLinha := Soma1(CTF->CTF_LINHA)

// Garante que a linha não exista!
dbSelectArea("CT2")
dbSetOrder(1)
If dbSeek(xFilial()+Dtos(dData)+cLote+cSubLote+cDoc+cLinha,.T.)
	// Se a linha ja existe gera nova linha a partir do CT2!!
	dbSeek(xFilial()+DTOS(dData)+cLote+cSubLote+cDoc+"ZZZ",.T.)
	dbSkip(-1)
	If CT2->CT2_FILIAL == xFilial() .And. DTOS(CT2->CT2_DATA) == DTOS(dData) .And.;
		CT2->CT2_LOTE   == cLote 	 .And. CT2->CT2_SBLOTE   == cSubLote 	 	 .And.;
		CT2->CT2_DOC == cDoc
		cLinha	:= CT2->CT2_LINHA
	EndIf
	If lRet
		cLinha 	:= Soma1(CT2->CT2_LINHA)
	EndIf
EndIf

If oLinha != Nil
	oLinha:SetText(OemToAnsi(cLinha))
Endif

//Verificar se a linha eh maior que o conteudo do parametro MV_NUMMAN
If FwIsInCallStack("CTBA101")
	If cLinha	> CtbSoma1Li()
		Help(" ", 1, "CTBNUMMAN")
		lRet	:= .F.
	EndIf
EndIf


RestArea(aSaveArea)

Return lRet

//----------------------------------------//
//rotinas para compatibilidade
//----------------------------------------//
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidaMoed³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida quais moedas estao sendo lancadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidaMoedas(cMoedas)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Moedas Lancadas                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValidaMoedas(cMoedas)

Local aSaveArea:= GetArea()
Local lRet 		:= .T.
Local nCont

IF Empty(cMoedas) .and. TMP->CT2_DC $ "123"
	lRet := .F.
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste apenas quando n„o for continua‡„o do historico      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	For nCont:= 1 TO Len(Trim(cMoedas))
		If !SubStr(cMoedas,nCont,1) $ "12" .and. TMP->CT2_DC $ "123"
			Help(" ",1,"ca050Moeda")
			nSaida++
			lRet := .f.
			Exit
		EndIF
	Next i
EndIf

RestArea(aSaveArea)

Return lRet

Static Function Ctb_Oper_Concat()
//carrega as variaveis static
cTipoDB	:= Alltrim(Upper(TCGetDB()))
cSrvType := Alltrim(Upper(TCSrvType()))


lOracle		:= "ORACLE"   $ cTipoDB
lPostgres 	:= "POSTGRES" $ cTipoDB
lDB2		:= "DB2"      $ cTipoDB
lInformix 	:= "INFORMIX"   $ cTipoDB
cOp_Concat := If( lOracle .Or. lPostgres .Or. lDB2 .Or. lInformix, " || ", " + " )

Return( cOp_Concat )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbVigenc ºAutor  ³ Totvs              º Data ³  03/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o periodo de vigencia das moedas contabeis.         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbVigenc()
Local aArea		:= CTO->( GetArea() )
Local cReadVar	:= AllTrim( Upper( ReadVar() ) )
Local dConteudo	:= &( ReadVar() )
Local lRet		:= .T.

If cReadVar == "M->CTO_DTINIC"
	If !Empty(M->CTO_DTFINA) .AND. dConteudo > M->CTO_DTFINA
		Help( " ", 1, "DTVIGENCIA",, STR0036, 3, 1 ) // "A data final do periodo nao pode ser menor que a inicial!"
		lRet := .F.
	EndIf
EndIf

If cReadVar == "M->CTO_DTFINA"
	If !Empty(M->CTO_DTINIC) .AND. dConteudo < M->CTO_DTINIC
		Help( " ", 1, "DTVIGENCIA",, STR0036, 3, 1 ) // "A data final do periodo nao pode ser menor que a inicial!"
		lRet := .F.
	EndIf
EndIf

RestArea( aArea )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105EntC³ Autor ³ Microsiga             ³ Data ³ 24/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida codigo da entidade contabil                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB105EntC(cPlano,cEntContab,lHelp)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 = Plano Contabil                                     ³±±
±±³          ³ Expc2 = Codigo da Entidade Contabil                        ³±±
±±³          ³ Expl1 = Se Exibe Help                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105EntC(cPlano,cEntContab,lHelp,cIdEntid)

Local lRet	    := .T.
Local cAliasEnt := "CV0"
Local _cCampo   := ""
Local _cProgr   := Alltrim(FunName())
Local lRpc		:= Type("oMainWnd") = "U" // Chamada via Rpc nao tem tela
Local aIndexes
Local cDesc
Default cPlano  := "01"
Default lHelp	:= .T.

aIndexes := CTBEntGtIn()

If !Empty(cIdEntid)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+cIdEntid)
		cPlano    := CT0->CT0_ENTIDA
		cAliasEnt := CT0->CT0_ALIAS
	EndIf
EndIf

If !Empty(cEntContab)
	dbSelectArea(cAliasEnt)
	If !Empty(cIdEntid)
		dbSetOrder(aIndexes[Val(cIdEntid)][1])
	Else
		dbSetOrder(1)
	EndIf
	If cAliasEnt <> "CV0"
		dbSeek(xFilial(cAliasEnt)+cEntContab)
	Else
		dbSeek(xFilial(cAliasEnt)+cPlano+cEntContab)
		C102ExEnt(cPlano,cEntContab) 
	EndIf
	
	If Eof()
		If lHelp
			Help("  ", 1, "NOENTIDA")
		EndIf
		lRet := .F.
	EndIf
	
	If lRet .And. FieldPos(cAliasEnt+"_CLASSE") > 0
		_cCampo	:= cAliasEnt+"_CLASSE"
		If &_cCampo != "2"	// Analitica
			If lHelp
				Help(" ",1,"NOCLASSE")
			EndIf
			lRet := .F.
		EndIf
		If lRet
			lRet := ValidaBloq(cEntContab,dDataBase,cAliasEnt,!lRpc,cIdEntid,cPlano)
		EndIf
	EndIf
	
	If lRet
		If _cProgr $ "CTBA101|CTBA102|CTBA105"
			If _cProgr $ "CTBA102|CTBA105"
				//grava variavel de memoria no arquivo temporario em edicao
				_cCampo	:= Alltrim( Substr( ReadVar(), AT(">", ReadVar())+1 ) )
				&("TMP->"+_cCampo) := &(ReadVar())
			EndIf
			                                                       
			If Type("aCtbEntid") == "A"
				If Right(ReadVar(),2) == "DB"
					lRet := CtbAmarr1(.T.)
				ElseIf Right(ReadVar(),2) == "CR"
					lRet := CtbAmarr1(.F.)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbEntExis  ºAutor  ³Microsiga         º Data ³  17/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a existencia da entidade. Utilizada como alterna-  º±±
±±º          |tiva para a funcao ExistCpo.					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbEntExis()

Local aSaveArea		 := GetArea()
Local lRet			 := .T.
Local cIdCT0		 := ""
Local cPlanoCT0		 := ""
Local cAliasEnt		 := ""
Local cCodEntid		 := ReadVar()
Local cCampo, nX
Local aIndexes

If !Empty(&(cCodEntid))
	cCampo := Readvar()
	If At( ">", cCampo ) != 0
		cCampo := AllTrim(SubStr( cCampo, 1+At( ">", cCampo) , 10 ) )
	EndIf
	cCampo := PadR(cCampo,10)
	
	If nQtdEntid == NIL
		nQtdEntid:= CtbQtdEntd()
	EndIf
	
	For nX := 5 TO nQtdEntid
		If StrZero(nX,2) $ cCampo
			cIdCT0 := StrZero(nX, 2)
			Exit
		EndIf
	Next
	
	aIndexes := CTBEntGtIn()
	
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial()+cIdCT0)
		cPlanoCT0 := CT0->CT0_ENTIDA //Plano
		cAliasCT0 := CT0->CT0_ALIAS
		
		dbSelectArea(cAliasCT0)
		dbSetOrder(aIndexes[Val(CT0->CT0_ID)][1])
		If cAliasCT0 <> "CV0"
			dbSeek(xFilial(cAliasCT0)+(&cCodEntid))
		Else
			dbSeek(xFilial(cAliasCT0)+cPlanoCT0+(&cCodEntid))
		EndIf
		
		If Eof()
			Help("  ", 1, "NOENTIDA")
			lRet := .F.
		EndIf
	Else
		lRet := .F.
		Help("  ", 1, "NOENTIDA")
	EndIf
EndIf

RestArea(aSaveArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbVldArm ºAutor  ³J. Domingos Caldana º Data ³  01/18/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de verificação de bloqueio de amarração de          º±±
±±º          ³ Moeda x Caldario x Tipo de Saldo                           º±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico a partir da Versão 11.80                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 = Moeda                                              ³±±
±±³          ³ Expc2 = Calendário										  ³±±
±±³          ³ Expc3 = Exercicio Contábil    	                          ³±±
±±³          ³ Expc4 = Periodo   				                          ³±±
±±³          ³ Expc5 = Tipo de Saldo				                      ³±±
±±³          ³ Expl6 = Se Exibe Help                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbVldArm(cCodMoeda,cCalend,cCodExec,cPeriodo,cTpSaldo,lMsg)

Local aArea		:= GetArea()
Local aAreaCWG  	:= {}
Local lRet 		:= .T.
Local lVldTps 	:= GETMV("MV_CTBCTG",.T.,.F.) // Habilita validação por amarração entre calendário x moeda x tipo de saldo
Local cFilCWG		:= XFILIAL("CWG")
Default lMsg		:= .T.

If lVldTps
	dbSelectArea("CWG") // Cadastro de Amarração Calendário X Moeda X Tipo de Saldo
	aAreaCWG := CWG->(GetArea())
	CWG->(dbSetOrder(1)) // Filial + Código da Moeda Contábil + Código do Calendário Contábil + Exercício Contábil + Período (Ano) 
	If cTpSaldo == '*'
		If CWG->( MsSeek(cFilCWG+cCodMoeda+cCalend+cCodExec+cPeriodo)) 
			While CWG->(!Eof()) .And. CWG->(CWG_FILIAL+CWG_MOEDA+CWG_CALEND+CWG_PERIOD) == cFilCWG+cCodMoeda+cCalend+cCodExec+cPeriodo
				/*
				 * Se a amarração existir, mas o status estiver como bloqueado, o movimento não será permitido
				 */
				If !(CWG->CWG_STATUS $ "1")					
					If lMsg ///Mostra mensagem
						Help(,,"CTBAMRVLD",,STR0042+CWG->CWG_TPSALD+STR0043+cCodMoeda+STR0044,1,1)  //'Tipo de Saldo: "' //'" bloqueado para a Moeda: "' //'" neste periodo. Verifique o status da amarração Moeda X Calendário X Tp. Saldo.'
					EndIf
					lRet := .F.
					Exit
				EndIf
		    	CWG->(DbSkip())
		    EndDo
		EndIf	
	Else
		If CWG->( MsSeek(cFilCWG + cCodMoeda + cCalend + cCodExec+ cPeriodo + cTpSaldo ))
			/*
			 * Se a amarração existir, mas o status estiver como bloqueado, o movimento não será permitido
			 */  
			If !(CWG->CWG_STATUS $ "1")
				If lMsg ///Mostra mensagem
					Help(,,"CTBAMRVLD",,STR0042+cTpSaldo+STR0043+cCodMoeda+STR0044,1,1)  //'Tipo de Saldo: "' //'" bloqueado para a Moeda: "' //'" neste periodo. Verifique o status da amarração Moeda X Calendário X Tp. Saldo.'
				EndIf
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaCWG)
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClearCxVldºAutor  ³Renato F. Campos    º Data ³  14/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa os caches utilizados pela rotina                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ClearCxVld()

__lConOutR		:= Nil
__aDtComp   	:= {}
__aDtInUse  	:= {}
__CtbAmarra 	:= {}
__CtbPosic 		:= {}
__aCtbUso		:= {}
__aCtbMInUse 	:= {}
__aCtbDtInUse	:= {}
__aCtbValidDt	:= {}

Return


//-------------------------------------------------------------------
/*{Protheus.doc} ExiSalCQ
Validação de existencia de saldos contábeis para a entidade.

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function ExiSalCQ(cCad,cFiltro,dDtIni,dDtFin,cConta,cCC,cItem,cClasse)
Local aArea := GetArea()
Local cQuery 
Local lRet := .T.
Local cAliasTRB := ""
Local cTab := ""

Default cFiltro := ""
Default dDtIni := CTOD("")
Default dDtFin := CTOD("")
Default cConta := ""
Default cCC := ""
Default cItem := ""
Default cClasse := ""

If cCad $ "CT1/CTG"
	cTab := "CQ1"
ElseIf cCad == "CTT"
	cTab := "CQ3"
ElseIf cCad == "CTD"
	cTab := "CQ5"
ElseIf cCad == "CTH"
	cTab := "CQ7"
EndIf

DbSelectArea(cTab)

cAliasTRB := "TSQL"+cTab

cQuery := " SELECT COUNT(*) CONT"
cQuery += " FROM "+RetSqlName(cTab)+ " " 
cQuery += " WHERE  "
cQuery += " D_E_L_E_T_ = ' '  "

If xFilial(cTab) == xFilial(cCad)
	cQuery += " AND "+cTab+"_FILIAL = '"+xFilial(cTab)+"'  "
EndIf

If cTab $ "CQ1"
	If !Empty(dDtIni) .And. !Empty(dDtFin) 
		cQuery +=  " AND "+cTab+"_DATA >= '"+DTOS(dDtIni)+"' "
		cQuery +=  " AND "+cTab+"_DATA <= '"+DTOS(dDtFin)+"' "
	EndIf
	If !Empty(cConta)
		cQuery += " AND "+cTab+"_CONTA = '"+cConta+"' "
	EndIf
ElseIf cTab $ "CQ3" 
	cQuery += " AND "+cTab+"_CCUSTO = '"+cCC+"' "
ElseIf cTab $ "CQ5"
	cQuery += " AND "+cTab+"_ITEM = '"+cItem+"' "
ElseIf cTab $ "CQ7"
	cQuery += " AND "+cTab+"_CLVL = '"+cClasse+"' "
EndIf

If !Empty(cFiltro)
	cQuery += " AND " + cFiltro
EndIf

If Select(cAliasTRB) > 0
	dbSelectArea(cAliasTRB)
	DbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTRB,.F.,.T.)

dbSelectArea(cAliasTRB)

If (cAliasTRB)->(!Eof())
	If (cAliasTRB)->CONT > 0
		lRet:= .T.
	Else
		lRet:= .F.
	EndIF
Else
	lRet:= .F.
EndIf

If Select(cAliasTRB) > 0
	dbSelectArea(cAliasTRB)
	DbCloseArea()
EndIf

RestArea(aArea)
Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} CTBValFila
Valida se o documento possui lançamentos que estão na fila de saldos contabeis.

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBValFila(cLote,cSublote,cDoc,dData,lHelp)
Local lRet 		:= .T.
Local aArea 		:= GetArea()
Local aAreaCT2	:= CT2->(GetArea())
Local cQuery		:= ""
Local cTab			:= GetNextAlias()

Default cLote		:= ""
Default cSublote	:= ""
Default cDoc		:= ""
Default dData		:= ""
Default lHelp		:= .T.

cQuery += " SELECT " + CRLF
cQuery += " 	COUNT(*) CONTCQA " + CRLF
cQuery += " FROM  " + CRLF
cQuery += " 	"+RetSQLName("CQA")+" CQA " + CRLF
cQuery += " WHERE " + CRLF
cQuery += " 	CQA.D_E_L_E_T_		= ' ' " + CRLF
cQuery += " 	AND CQA_FILCT2		= '"+xFilial("CT2")+"' " + CRLF
cQuery += " 	AND CQA_DATA			= '"+DTOS(dData)+"' " + CRLF
cQuery += " 	AND CQA_LOTE			= '"+cLote+"' " + CRLF
cQuery += " 	AND CQA_SBLOTE		= '"+cSublote+"' " + CRLF
cQuery += " 	AND CQA_DOC			= '"+cDoc+"' " + CRLF

cQuery := Changequery(cQuery)

If ( Select ( cTab ) > 0 )
	dbSelectArea ( cTab )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)

If (cTab)->(!EOF()) .And. (cTab)->CONTCQA > 0
	lRet := .F.
EndIf

If !lRet .And. lHelp
	Help( " " , 1 , "CTBFILA" ,, STR0056 ,3,0)//"Operação Bloqueada. O lançamento contábil está sendo processado pelo reprocessamento de saldo em fila."
EndIf

dbSelectArea ( cTab )
dbCloseArea ()

RestArea(aAreaCT2)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbSIXCTA ºAutor  ³Totvs               º Data ³  14/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existem os Indices da tabela CTA               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbSIXCTA()

Local aArea 	:= GetArea()
Local nX		:= 0	
Local aCpos		:= {}
Local lRet		:= .T.

If nQtdEntid == NIL
	nQtdEntid := If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

AADD( aCpos,'CTA_CONTA')
AADD( aCpos,'CTA_CUSTO')
AADD( aCpos,'CTA_ITEM')
AADD( aCpos,'CTA_CLVL')
For nX:= 5 To nQtdEntid
	AADD( aCpos,'CTA_ENTI'+StrZero(nX,2))
Next nX

//Verificar somente a existencia dos indices 
//  das entidades principais
//  CONTA/ CENTRO DE CUSTO / ITEM / CLASSE DE VALOR 
For nX := 1 To 4
	If !FindNickName('CTA',aCpos[nX])
		lRet := .F.
		Exit
	EndIf
Next nX		

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CtbBxVld
Valida as informações preenchidas de Lote, Sublote e Diário para efetuar o lançamento contábil.

@author David Moraes

@Param cDebito  -  Código da conta de Débito.
@Param cCredito - Código da conta de Credito.
@Param cLote     -  Lote
@Param SubLote  -  SubLote
@Param cDiario  -  Código do Diário

@Return lRet
@since 24/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CTBVldCtrl(cDebito, cCredito, cLote,cSubLote, cDiario,cLinha)
Local aArea		 := GetArea()
Local lRet       := .T.    
Local lAcesso    := VerSenha(191)
Local cMsgLin		:= ""
Local lIsBlind	:= IsBlind()
Default cDiario := ""
Default cLinha := ""


If !Empty(cLinha)
	cMsgLin := " "+STR0057+": " + cLinha
EndIf

//Permitir movimentação se o usuário  estiver configurado no acesso de usuário para efetuar movimentos independente da validação dos controles contabeis.
If lAcesso .And. lRet
	DbSelectArea('CVP')
	CVP->(DbSetOrder(1))//Filial + Conta Contabil
	If	CVP->(DbSeek(xFilial('CVP')+cDebito)) .And. lRet .And. !lIsBlind
		//Define se o usuário com permissões de lançamento manual, com qualquer combinação de entidades contábeis
		//estiver com as permissões de lançamentos independente do controle contábil,
		//será avisado por uma mensagem de aviso, mas o lançamento será permitido.
		If CVP->CVP_AVISO == "1" .And. lRet
			Aviso( STR0045,STR0046+CRLF+;//"Usuário está configurado para efetuar movimentação independente do Controle Contábil."
			STR0047+cDebito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cDebito,'CT1_DESC01')) + cMsgLin , {"Ok"},2)//Cta Débito
			
		EndIf
	EndIf
	
	If CVP->(DbSeek(xFilial('CVP')+cCredito)) .And. lRet.And. !lIsBlind
		//Define se o usuário com permissões de lançamento manual, com qualquer combinação de entidades contábeis
		//estiver com as permissões de lançamentos independente do controle contábil,
		//será avisado por uma mensagem de aviso, mas o lançamento será permitido.
		If CVP->CVP_AVISO == "1" .And. lRet
			Aviso( STR0045,STR0046+CRLF+;//"Usuário está configurado para efetuar movimentação independente do Controle Contábil."
			STR0048+cCredito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cCredito,'CT1_DESC01')) + cMsgLin  , {"Ok"}, 2)//Cta Crédito
			
		EndIf
		
	EndIf
	
Else
	If !Empty(cDebito) .And. lRet
		
		CVP->(DbSelectArea('CVP'))
		CVP->(DbSetOrder(2))//Filial + Conta Contabil + Lote + SubLote
		If	CVP->(DbSeek(xFilial('CVP')+cDebito+cLote+cSubLote))
			If CVP->CVP_ATIVO <> '1' .And. lRet
				Help('',1,'CtbBxVld',,STR0047+cDebito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cDebito,'CT1_DESC01'))+STR0049 + cMsgLin ,4,1)//Cta Debito: 0000001 não está ativa na rotina de Controles Contábeis
				lRet := .F.
			EndIf
			
			If CVP->CVP_LCTMAN <> '1' .And. lRet
				Help('',1,'CtbBxVld',,STR0050+CRLF+;//"Conta contábil não está configurada para aceitar lançamentos manuais. "
				STR0047+cDebito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cDebito,'CT1_DESC01'))+ cMsgLin,4,1)
				lRet := .F.
			EndIf
		Else
			CVP->(DbSelectArea('CVP'))
			CVP->(DbSetOrder(1))//Filial + Conta Contabil
			If CVP->(DbSeek(xFilial('CVP')+cDebito)) .And. lRet
				Help('',1,'CtbBxVld',,STR0051+CRLF+;//"Lote/Sublote não está vinculado com a conta contábil."
				STR0047+cDebito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cDebito,'CT1_DESC01'))+ cMsgLin,4,1)//"Cta Debito: "
				lRet := .F.
			EndIf
		EndIf
		
		CVP->(DbSelectArea('CVP'))
		CVP->(DbSetOrder(1))//Filial + Conta + Código do diário
		If !Empty(cDiario) .And. lRet
			If CVP->(DbSeek(xFilial('CVP')+cDebito+cDiario))
				
				If CVP->CVP_ATIVO <> '1' .And. lRet
					Help('',1,'CtbBxVld',,STR0047+cDebito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cDebito,'CT1_DESC01'))+STR0049+ cMsgLin,4,1)//" não está ativa na rotina de Controles Contábeis"
					lRet := .F.
				EndIf
				
				If CVP->CVP_LCTMAN <> '1' .And. lRet
					Help('',1,'CtbBxVld',,STR0047+cDebito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cDebito,'CT1_DESC01'))+STR0050+ cMsgLin,4,1)//" não está configurada para aceitar lançamentos manuais"
					lRet := .F.
				EndIf
				
			Else
				Help('',1,'CtbBxVld',,STR0052+CRLF+;//"Diário não está vinculado com a conta contábil. "
				STR0047+cDebito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cDebito,'CT1_DESC01'))+ cMsgLin,4,1)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	If !Empty(cCredito) .And. lRet
		CVP->(DbSelectArea('CVP'))
		CVP->(DbSetOrder(2))//Filial + Conta Contabil + Lote + SubLote
		If	CVP->(DbSeek(xFilial('CVP')+cCredito+cLote+cSubLote))
			If CVP->CVP_ATIVO <> '1' .And. lRet
				Help('',1,'CtbBxVld',,STR0048+cCredito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cCredito,'CT1_DESC01'))+STR0049+ cMsgLin,4,1)//" não está ativa na rotina de Controles Contábeis"
				lRet := .F.
			EndIf
			
			If CVP->CVP_LCTMAN <> '1' .And. lRet
				Help('',1,'CtbBxVld',,STR0048+cCredito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cCredito,'CT1_DESC01'))+STR0050+ cMsgLin,4,1)//" não está configurada para aceitar lançamentos manuais"
				lRet := .F.
			EndIf
			
		Else
			CVP->(DbSelectArea('CVP'))
			CVP->(DbSetOrder(1))//Filial + Conta Contabil
			If	CVP->(DbSeek(xFilial('CVP')+cCredito))
				Help('',1,'CtbBxVld',,STR0051+CRLF+;//"Lote/Sublote não está vinculado com a conta contábil."
				STR0048+cCredito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cCredito,'CT1_DESC01'))+ cMsgLin,4,1)//"Cta Credito: ""Lote/Sublote não está vinculado com a conta contábil. "
				lRet := .F.
			EndIf
		EndIf
		
		CVP->(DbSelectArea('CVP'))
		CVP->(DbSetOrder(1))//Filial + Conta + Código do diário
		If !Empty(cDiario) .And. lRet
			If	CVP->(DbSeek(xFilial('CVP')+cCredito+cDiario))
				If CVP->CVP_ATIVO <> '1' .And. lRet
					Help('',1,'CtbBxVld',,STR0048+cCredito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cCredito,'CT1_DESC01'))+STR0049+ cMsgLin,4,1)//" não está ativa na rotina de Controles Contábeis"
					lRet := .F.
				EndIf
				
				If CVP->CVP_LCTMAN <> '1' .And. lRet
					Help('',1,'CtbBxVld',,STR0048+cCredito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cCredito,'CT1_DESC01'))+STR0050+ cMsgLin,4,1)//" não está configurada para aceitar lançamentos manuais"
					lRet := .F.
				EndIf
				
			Else
				Help('',1,'CtbBxVld',,STR0052+CRLF+;//"Diário não está vinculado com a conta contábil. "
				STR0048+cCredito+" - "+Alltrim(POSICIONE('CT1',1,xFilial('CT1')+cCredito,'CT1_DESC01'))+ cMsgLin,4,1)//"Cta Crédito: "
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
          
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldVlrLanc
Validação do valor das linhas de lançamentos das rotinas CTBA102 e CTBA103, 
para evitar problemas com as novas tabelas de saldos contábeis

@param lTudoOK, indica se é validação de toda a grid ou só da linha  
@return lRet

@author Pedro Alencar
@since 18/08/2014
@version P12
/*/
//-------------------------------------------------------------------
Function VldVlrLanc(lTudoOK)
	Local lRet := .T.
	Local nValor := 0
	Local nRecTMP := 0
	Local aAreaAnt := {}
	Local cLinha := ""
	Default lTudoOK := .F.
	
	If !lTudoOK  //Se for Validação LinhaOK, valida apenas a linha
		//Só valida se a linha não estiver excluída
		If !TMP->CT2_FLAG
			nValor := TMP->CT2_VALOR
			
			If nValor > 9999999999999.99
				cLinha := AllTrim( TMP->CT2_LINHA )
				lRet := .F.			
			Endif
		Endif
	Else //Se for validação TudoOK, valida cada linha da grid
		aAreaAnt := GetArea()
		
		dbSelectArea( "TMP" )
		nRecTMP := TMP->( Recno() )
		TMP->( dbGoTop() )
		While TMP->( !EOF() )
			//Só valida se a linha não estiver excluída
			If !TMP->CT2_FLAG
				nValor := TMP->CT2_VALOR
			
				If nValor > 9999999999999.99
					cLinha := AllTrim( TMP->CT2_LINHA )
					lRet := .F.				
					Exit			
				Endif
			Endif
			
			TMP->( dbSkip() )
		EndDo
		
		TMP->( dbGoto( nRecTMP ) )
		
		RestArea(aAreaAnt)
	Endif

	If !lRet .AND. !IsBlind()
		Help( " ", 1, "LANCVLRMAX", , OemToAnsi(STR0059) + clinha + OemToAnsi(STR0060), 1, 0 ) //"Valor máximo permitido no lançamento: 9.999.999.999.999,99. A linha ", " do lançamento deve ser corrigida." 
	Endif
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDtExis()
Valida data de existência
@author Lucas de Oliveira
@since  11/11/2014
@version 12
/*/
//-------------------------------------------------------------------
Function VldDtExis()
Local lRet			:= .T.
local cAlias		:= SUBSTR(readvar(),AT(">",readvar())+1,3)
local cCpoDtIni	:= cAlias+"_DTEXIS"
local cCpoDtFim	:= cAlias+"_DTEXSF"

IF cAlias == "CV0" //Valida entidades adicionais CV0	
	If (!empty(M->CV0_DTFEXI) .and. !empty(M->CV0_DTIEXI)) .and. (M->CV0_DTFEXI < M->CV0_DTIEXI)
		lRet:=.F.
	Endif	
Else //Valida entidades - CT1, CTT, CTD, CTH	
	If (!empty(M->&(cCpoDtFim)) .and. !empty(M->&(cCpoDtIni))) .and. (M->&(cCpoDtFim) < M->&(cCpoDtIni))
		lRet:=.F.
	Endif
EndIf

If !lRet
Help(" ",1,"HELP","DTEXFI",STR0061,3,1)  //A data de fim de existencia não pode ser menor que a data de inicio de existencia
EndIf

Return lRet    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidaHist³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Historico Digitado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidaHist(cHP)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Historico Padrao                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValidaHist(cHP)
Local aSaveArea	:= GetArea()
Local lRet		:= .T.

If !Empty(cHP)
	dbSelectArea("CT8")
	dbSetOrder(1)
	If MsSeek(xFilial()+cHP)
		If CT8->CT8_IDENT == 'I' //Se for historico inteligente, monta a tela do historico
			If TMP->(Recno()) <> TMP->(RecCount())
				lRet := .F.
				Help(" ",1,"ValidaHist",,STR0063,1,0) //"Utilize o historico inteligente somente na ultima linha ou atraves do Lanc. Manual"
			Endif
			If lRet .And. Empty(TMP->CT2_DC)
				lRet := .F.
				Help("",1,"CT2_DC")
			Endif

			If lRet
				MontHistInt(cHp)
			EndIf

		Else
			TMP->CT2_HIST := CT8->CT8_DESC
		Endif
	Else
		lRet := .F.
		Help(" ",1,"ValidaHist",,STR0066,1,0) //"Não existe este historico cadastrado. Verifique"
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctba70Hist³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica validade do hist¢rico padronizado.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba70Hist()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Valida‡„o do SX3 do Campo CT8_DESC                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ctba70Hist()

LOCAL cHist := &(ReadVar())
LOCAL i,j,k,l
LOCAL nBytes:=0
LOCAL z :=0

IF Empty(cHist)
	Help(" ",1,"HISTVAZIO")
	Return .F.
EndIf
For i:=1 TO Len(cHist)
	IF SubStr( cHist,i,1 ) == "@"
		z++
		j := i
		k := ""
		While SubStr( cHist,j,1 ) != " " .and. j < Len( cHist )
			j++
			k += SubStr(cHist,j,1)
		EndDo
		l := Len(Trim(k))
		k := Val(k)
		nBytes := nBytes + k - l
	EndIf
Next
IF (nBytes + Len(Trim(cHist)))-z > 40
	Help(" ",1,"MUIGRD")
	Return .F.
EndIF
Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} VldPlRef()
Verifica se tem mais de uma conta referencial amarrada a uma mesma conta contábil 	

@author Simone Mie Sato Kakinoana
   
@version P12
@since   28/04/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function VldPlRef(cCodigo,cCodPlRef, cVersao, cCodPlGer)

Local aArea	:= GetArea()

Local lRet	:= .T.

Local cQuery := ""
Local cNewTmp	:= GetNextAlias()

DEFAULT cCodigo		:= ""
DEFAULT cCodPlRef	:= ""
DEFAULT cVersao		:= ""
DEFAULT cCodPlGer	:= ""

If Empty(cCodPlGer)
	DbSelectArea("CTN")
	DbSetOrder(1)
	If DbSeek(xFilial("CTN")+cCodigo)
		cCodPlGer	:= CTN->CTN_PLAGER			
	Endif
EndIf

If !Empty(cCodPlGer) .And. !Empty(cCodPlRef)
	Help("  ",1,"CTBPLREF1",,STR0067,1,0) //"Não é permitido utilizar visão gerencial e plano referencial na mesma config. livro."
	lRet	:= .F.
Endif

If lRet	
	If !Empty(cCodPlRef) .And. Empty(cVersao)
		Help("  ",1,"CTBPLREF2",,STR0068,1,0) //"Versão não preenchida.Obrigatório preenchimento do plano referencial e versão." 
		lRet	:= .F.			
	ElseIf Empty(cCodPlRef) .And. !Empty(cVersao)
		Help("  ",1,"CTBPLREF3",,STR0069,1,0) //"Plano referencial não preenchido.Obrigatório preenchimento do plano referencial e versão."
		lRet	:= .F.
	ElseIf !Empty(cCodPlRef) .And. !Empty(cVersao)
	
		DbSelectArea("CVN")
		DbSetOrder(4)
		If !DbSeek(xFilial()+cCodPlRef+cVersao)	
			Help("  ",1,"CTBPLREF0",,STR0070,1,0) //"Plano referencial /versão não cadastrado."
			lRet	:= .F.
		Else			
			cQuery	:= " SELECT COUNT(*) REGS, CVD_CODPLA, CVD_VERSAO, CVD_CONTA " + CRLF
			cQuery	+= " FROM " +RetSqlName("CVD") + " CVD "+ CRLF
			cQuery	+= " WHERE CVD_FILIAL = '"+xFilial("CVD")+"' "+ CRLF
			cQuery	+= " AND CVD.D_E_L_E_T_ = ' ' "+ CRLF  
			cQuery	+= " AND CVD_CODPLA = '"+cCodPlRef+"' "+CRLF
			cQuery	+= " AND CVD_VERSAO = '"+cVersao+"'"+ CRLF
			cQuery	+= " AND ( SELECT COUNT(*) REGS "+ CRLF
			cQuery	+= " FROM " +RetSqlName("CVD") + " CVDA" + CRLF 
			cQuery	+= " WHERE CVD_FILIAL = '"+xFilial("CVD")+"' "+ CRLF  
			cQuery	+= " AND CVDA.D_E_L_E_T_ = ' '"+ CRLF
			cQuery	+= " AND CVD.CVD_CODPLA = CVDA.CVD_CODPLA"+ CRLF				
			cQuery	+= " AND CVD.CVD_VERSAO = CVDA.CVD_VERSAO"+ CRLF
			cQuery	+= " AND CVD.CVD_CONTA = CVDA.CVD_CONTA "+ CRLF
			cQuery	+= " GROUP BY CVD_CODPLA, CVD_VERSAO, CVD_CONTA ) > 1 "+ CRLF
			cQuery	+= " GROUP BY CVD_CODPLA, CVD_VERSAO, CVD_CONTA "+ CRLF				
			cQuery := ChangeQuery( cQuery )	
				
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNewTmp)	
				
			DbSelectArea(cNewTmp)
			DbGoTop()				
			If (cNewTmp)->(!Eof())
				Help("  ",1,"CTBPLREF4",,STR0071,1,0) //"Não é permitido utilizar plano referencial que possua mais de uma conta referencial associada a uma mesma conta contábil."
				lRet	:= .F.
			Else
				lRet	:= .T.
			EndIf
		EndIf
		
	Endif
Endif

RestArea(aArea)

Return(lRet)
