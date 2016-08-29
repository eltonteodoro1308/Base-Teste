#Include 'Protheus.ch'
#Include "fileio.ch"

#Define NQTDARQ 23

//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSLIBP01
Fonte referente a Lib do projeto
        
@author 		Leandro de Faria
@since 		27/06/2014
@version 		P11
@param
@obs  			Lib
@return	   	Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
User Function FSLIBP01()

Return Nil


//---------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSOrdArr
Funcao para ordenar um array de execauto
        
@author 		Leandro de Faria
@since 	   	27/06/2014
@version 		P11
@param 		aArrOri		- Array no padrão exigido pelo SIGAAUTO
@param 		cAliasSx3	- Alias da Tabela a ser tratada no SIGAAUTO.
@param 		lItem		- Indica se o array é de itens. 
@obs  			Lib
@return	   	lLayout - Indica se ouve sucesso no carregamento do arquivo
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//---------------------------------------------------------------------------------------------------------------------------------------
User Function FSOrdArr(aArrOri,cAliasSx3,lItem)

Local aAreOld 	:= {GetArea(),SX3->(GetArea())}
Local aArrRet	:= {}
Local nPos		:= 0
Local nXi			:= 0  

Default lItem := .F.

If lItem
	For nXi := 1 To Len(aArrOri)
		U_FSOrdArr(@aArrOri[nXi],cAliasSX3,.F.)
	Next
Else
	
	SX3->(dbSetOrder(1))
	SX3->(dbSeek(cAliasSx3,.T.))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAliasSX3
	
		If (nPos:= aScan(aArrOri,{|x| Alltrim(x[1]) == Alltrim(SX3->X3_CAMPO) })) <> 0
			aadd(aArrRet,aClone(aArrOri[nPos]))
		EndIf
	
		SX3->(dbSkip())
	EndDo 
	
	aArrOri := aClone(aArrRet)
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return Nil


//------------------------------------------------------------------- 
/*/{Protheus.doc} FSSemaf
Semaforo para rotinas scheduladas
        
@author 		Leandro de Faria
@since 		02/06/2014
@version 		P11
@param			cChave		- rotina processada
@obs  			Lib dos projetos da Unocann
@return	   	Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------
User Function FSSemaf(cChave)

If( MSFCreate(cChave,0) > 0)
	Return .T.
EndIf         

Return .F.