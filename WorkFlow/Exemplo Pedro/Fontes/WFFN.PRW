#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CONSOLE  บAutor  ณ Pedro Augusto      บ Data ณ  Dez/2008   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava as mensagens nos logs do Server e do Workflow        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS Business Inteligence                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Console(cTexto)

Local cEOL		:= Chr(13)+Chr(10)
Local nHdl2
Local aLogBody  := {}
Local nW		:= 0

Set Date To British

If cTexto == NIL
	cTexto := "["+DtoC(Date()) + ' ' + Time()+"] ** Texto nใo recebido **"
Else
	cTexto := "["+DtoC(Date()) + ' ' + Time()+"] " + cTexto
Endif

ConOut(cTexto)

aLogBody := QuebrLin(cTexto,80)

nHdl2 := FOpen("\workflow\emp"+cEmpAnt+"\wfconsole.log",2)
Iif(nHdl2 > 0,,nHdl2:= MSFCreate("\workflow\emp"+cEmpAnt+"\wfconsole.log",0))
FSeek(nHdl2,0,2)

For nW := 1 to Len(aLogBody)
	If nW = 1
		FWrite(nHdl2,aLogBody[nW]+cEOL,Len(aLogBody[nW]+cEOL))
	Else
		FWrite(nHdl2,Space(20)+aLogBody[nW]+cEOL,Len(Space(20)+aLogBody[nW]+cEOL))
	EndIf
Next nW
FClose(nHdl2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QuebrLin บ Autor ณ Kley Goncalves     บ Data ณ  07/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Quebra um string em uma ou varias linhas de acordo com o   บฑฑ
ฑฑบ          ณ tamanho da linha especificado, e retorna um array com as   บฑฑ
ฑฑบ          ณ linhas.                                                    บฑฑ
ฑฑบ          ณ Parametros recebidos:                                      บฑฑ
ฑฑบ          ณ   cTexto  ==> String contendo o texto ou mensagem          บฑฑ
ฑฑบ          ณ   nTamLin ==> Tamanho maximo de cada linha                 บฑฑ
ฑฑบ          ณ Parametros devolvidos:                                     บฑฑ
ฑฑบ          ณ   aLinha  ==> Array com as linhas contendo o texto.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS Business Inteligence Library                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function QuebrLin(cTexto,nTamLin)

Local aLinha	:= {}
Local nPosIni	:= 1
Local nCaracLin	:= 0
Local aCaracQbra:= {" ",".",",","-",")",":","/"}
Local nCaracQbra:= 0
Local nN		:= 0

cTexto	:= AllTrim(cTexto)

Do While Len(cTexto) - nPosIni >= 0

	If Len(cTexto) - (nPosIni - 1) <= nTamLin	// Processa ultima linha
		nCaracLin	:= nTamLin
	Else
		nCaracLin := 0
		For nN := 1 to Len(aCaracQbra)
			nCaracQbra	:= RAt(aCaracQbra[nN],Substr(cTexto,nPosIni,nTamLin))	// Encontra o ultimo caracter de quebra
			If nCaracLin < nCaracQbra
				nCaracLin := nCaracQbra
			EndIf		
		Next nN
	EndIf
	
	aAdd(aLinha, Substr(cTexto,nPosIni,nCaracLin))			// Adiciona o trecho ao Array
	
	nPosIni += nCaracLin

EndDo

Return(aLinha)
                           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNotifyAdm บAutor  ณMicrosiga           บ Data ณ  08/15/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณUtilizado para enviar qualquer notificacao ao administrador บฑฑ
ฑฑบ          ณdo Siga.     															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION NotifyAdm(cTitle, aMsg, aFiles )
RETURN U_MailNotify( , cTitle, aMsg, aFiles )

USER FUNCTION MailNotify(cTo, cTitle, aMsg, aFiles )
Local cBody := '', nInd

cTitle		:= ALLTRIM(cTitle) + " Emp/Fil : " + cEmpAnt + "/" + cFilAnt

cBody := ''
cBody += '<DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>'
cBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
cBody += 'size=3><STRONG>Workflow - MIRA TRANSPORTES - Servi็o de Envio de Mensagens</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 TO Len(aMsg)
 cBody += '<DIV><FONT face=Verdana color=#000080 size=2><SPAN class=216593018-10022004>' + aMsg[nInd] + '</SPAN></FONT></DIV><p>'
Next

IF EMPTY(cTo)
	cTo	:= Nil                            
ENDIF

RETURN WFNotifyAdmin( cTo , cTitle, cBody, aFiles )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetTimeOut                                                  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
*/
User function GetTimeOut(nTimeOut,dData, cHora)
Local cQuery := ""
                  
IF dData == Nil
	dData	:= MSDATE()
ENDIF
IF cHora == Nil
	cHora	:= TIME()
ENDIF
IF nTimeOut == Nil
	nTimeOut:= 24
ENDIF

cHoraI 	:= GetNewPar("ES_WFHORAI","00:00")
cHoraF  := GetNewPar("ES_WFHORAF","24:00")

nHora	:= Val(Left(cHora,2))  + Val(Substr(cHora,4,2))/60
nHoraI  := Val(Left(cHoraI,2)) + Val(Substr(cHoraI,4,2))/60
nHoraF  := Val(Left(cHoraF,2)) + Val(Substr(cHoraF,4,2))/60

IF nHora<=nHoraI  
	nHora	:= nHoraI 
ENDIF                
  
dDtVld := dData
While .T.
	IF (nHora + nTimeOut) <= nHoraF
		nHora	:= nHora + nTimeOut
		EXIT
	ENDIF
	nTimeOut	:= nTimeOut - (nHoraF - nHora)
	nHora		:= nHoraI

	dDtVld		:= dDtVld + 1     
	dDtVld		:= DataValida(dDtVld,.T.)
END

return {dData,cHora,dDtVld, ALLTRIM(STRZERO(int(nHora),2)) + ":" + ALLTRIM(STRZERO((nHora - Int(nHora)) * 60,2))}

USER FUNCTION SEMAFORO(Params)
Local nHdl 	:= 0                  
Local cFile := ""

    IF Params == Nil .OR. ! ValType(Params) $ "N|C" 
    	U_CONSOLE("SEMAFORO - Parametro invalido")
    	RETURN
    ENDIF            

	IF VALTYPE(Params) == "C"	// Quando for caracter - fecha o semaforo
		cFile := TRIM(Params) + ".LCK"
		       
		IF !FILE(cFile)
			nHdl:=MSFCREATE(cFile,0)
			fClose(nHdl)
		ENDIF
			
		While .T.
			nHdl := FOPEN(cFile , 16)
			IF nHdl > 0
			   	EXIT
			ENDIF			    
		    
			SLEEP(5000)
		END
	ENDIF
	
	IF VALTYPE(Params) == "N"	// Quando for numerico - abre o semaforo
		fClose(Params)
	ENDIF
	
	RETURN IIF(nHdl <> 0, nHdl, Nil)

/* SINTAXE DA MAALCDOC PADRAO: 
MAAlcDoc({SC1->C1_NUM,"SC",_nValor,,,GrpSC(),,,,SC1->C1_EMISSAO},SC1->C1_EMISSAO,3)

MaAlcDoc(ExpA1                                                    ,ExpD1,ExpN1,ExpC1,ExpL1) , ONDE:

ExpA1 = Array com informacoes do documento                  
        [1] Numero do documento                               
        [2] Tipo de Documento                                 
        [3] Valor do Documento                                
        [4] Codigo do Aprovador                               
        [5] Codigo do Usuario                                 
        [6] Grupo do Aprovador                                
        [7] Aprovador Superior                                
        [8] Moeda do Documento                                
        [9] Taxa da Moeda                                     
       [10] Data de Emissao do Documento                      
       [11] Grupo de Compras                                  
       [12] Aprovador Original                                
  ExpD1 = Data de referencia para o saldo                     
  ExpN1 = Operacao a ser executada                            
        1 = Inclusao do documento                             
        2 = Transferencia para Superior                       
        3 = Exclusao do documento                             
        4 = Aprovacao do documento                            
        5 = Estorno da Aprovacao                              
        6 = Bloqueio Manual da Aprovacao                      
  ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR         
  ExpL1 = Eliminacao de Residuos                              
*/
