#include 'totvs.ch'

User Function tstbxgct()

	BaixaGCT( {{321},{322},{323},{324}}, {327}, 500 )

Return

Static Function BaixaGCT(aBx, aComp, nValComp)

	Local _nSaldo     := 0
	Local _cContra    := ''
	Local aCompTmp    := {}
	Local nValTmp     := 0
	Local nValSobra   := 0
	Local nX          := 0	

	PERGUNTE("AFI340",.T.)
	lAglutina         := MV_PAR08 == 1
	lDigita           := MV_PAR09 == 1
	lContabiliza      := MV_PAR11 == 1

	For nX := 1 To Len( aBx )

		If MaIntBxCP(2,aBx[nX],,aComp,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,nValComp,dDataBase)

			Alert('Baixa Executada !!!')

		Else

			Alert('Baixa Não Executada !!!')

		End If

	Next nX

	//	SE2->(DbGoTo(aComp[1]))
	//	_nSaldo     := SE2->E2_SALDO
	//	_cContra    := SE2->E2_MDCONTR
	//
	//	//Atualiza os campos no titulo NF
	//	SE2->(DbGoTo(aBx[Len(aBx)]))
	//	RecLock('SE2', .F.)
	//	SE2->E2_SALGCT    := _nSaldo
	//	SE2->E2_CONTGCT   := _cContra
	//	SE2->(MsUnlock())

Return