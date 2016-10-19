#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


//-------------------------------------------------------------------
User Function COMP011M() 
// COMP011M É o ID do modelo de dados de Autores/Interpretes
Return Verifica()

//-------------------------------------------------------------------
User Function COMP021M()
// COMP021M É o ID do modelo de dados de Musicas
Return Verifica()

//-------------------------------------------------------------------
User Function COMP023M()
// COMP023M É o ID do modelo de dados de Albuns
Return Verifica()

/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da alteração de qualquer campo do modelo. (requer retorno lógico)
MODELPOS 			Na validação total do modelo (requer retorno lógico)

FORMPRE 			Antes da alteração de qualquer campo do formulário. (requer retorno lógico)
FORMPOS 			Na validação total do formulário (requer retorno lógico)

FORMLINEPRE 		Antes da alteração da linha do formulário GRID. (requer retorno lógico)
FORMLINEPOS 		Na validação total da linha do formulário GRID. (requer retorno lógico)

MODELCOMMITTTS 		Apos a gravação total do modelo e dentro da transação
MODELCOMMITNTTS 	Apos a gravação total do modelo e fora da transação

FORMCOMMITTTSPRE 	Antes da gravação da tabela do formulário
FORMCOMMITTTSPOS 	Apos a gravação da tabela do formulário

FORMCANCEL 			No cancelamento do botão.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formulário ou model, conforme o caso.
PARAMIXB[2] - Id do local de execução do ponto de entrada
PARAMIXB[3] - Id do formulário

Se for uma FORMGRID
PARAMIXB[4] - Linha da Grid
PARAMIXB[5] - Acao da Grid

*/




//-------------------------------------------------------------------
Static Function Verifica()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := aParam[1]
Local cIdPonto   := aParam[2]
Local cIdModel   := IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
Local cClasse    := IIf( oObj<> NIL, oObj:ClassName(), '' )

Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''

If cClasse == 'FWFORMGRID'
	nQtdLinhas := oObj:Length()
	nLinha     := oObj:nLine
EndIf

If     cIdPonto ==  'MODELPOS'
	cMsg := 'Chamada na validação total do modelo (MODELPOS).' + CRLF
	cMsg += 'ID '  + cIdModel + CRLF
	
	If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
		Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
	EndIf
	
	
	//ElseIf cIdPonto ==  'MODELPRE'
	
	//ElseIf cIdPonto ==  'FORMPRE'
	
ElseIf cIdPonto ==  'FORMPOS'
	cMsg := 'Chamada na validação total do formulário (FORMPOS).' + CRLF
	cMsg += 'ID '  + cIdModel + CRLF
	
	If      cClasse == 'FWFORMGRID'
		cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
		cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
	ElseIf cClasse == 'FWFORMFIELD'
		cMsg += 'É um FORMFIELD' + CRLF
	EndIf
	
	If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
		Help( ,, 'Help',, 'O FORMPOS retornou .F.', 1, 0 )
	EndIf
	
ElseIf cIdPonto ==  'FORMLINEPRE'
	If aParam[5] == 'DELETE'
		cMsg := 'Chamada na pre validação da linha do formulário (FORMLINEPRE).' + CRLF
		cMsg += 'Onde esta se tentando deletar uma linha' + CRLF
		cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
		cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
		cMsg += 'ID '  + cIdModel + CRLF
		
		If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
			Help( ,, 'Help',, 'O FORMLINEPRE retornou .F.', 1, 0 )
		EndIf
	EndIf
	
ElseIf cIdPonto ==  'FORMLINEPOS'
	cMsg := 'Chamada na validação da linha do formulário (FORMLINEPOS).' + CRLF
	cMsg += 'ID '  + cIdModel + CRLF
	cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
	cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
	
	If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
		Help( ,, 'Help',, 'O FORMLINEPOS retornou .F.', 1, 0 )
	EndIf
	
ElseIf cIdPonto ==  'MODELCOMMITTTS'
	ApMsgInfo('Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).' + CRLF + 'ID '  + cIdModel )
	
ElseIf cIdPonto ==  'MODELCOMMITNTTS'
	ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).'  + CRLF + 'ID '  + cIdModel)
	
	//ElseIf cIdPonto ==  'FORMCOMMITTTSPRE'
	
ElseIf cIdPonto ==  'FORMCOMMITTTSPOS'
	ApMsgInfo('Chamada apos a gravação da tabela do formulário (FORMCOMMITTTSPOS).'  + CRLF + 'ID '  + cIdModel)
	
ElseIf cIdPonto ==  'MODELCANCEL'
	cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'
	
	If !( xRet := ApMsgYesNo( cMsg ) )
		Help( ,, 'Help',, 'O MODELCANCEL retornou .F.', 1, 0 )
	EndIf
	
ElseIf cIdPonto ==  'BUTTONBAR'
	ApMsgInfo('Adicionando Botao na Barra de Botoes (BUTTONBAR).' + CRLF + 'ID '  + cIdModel )
	xRet := { {'Salvar', 'SALVAR', { || Alert( 'Salvou' ) }, 'Este botao Salva' } }
	
	
ElseIf cIdPonto ==  'MODELVLDACTIVE'
	cMsg := 'Chamada na validação da ativação do Model.' + CRLF + 'Continua ?'
	
	If !( xRet := ApMsgYesNo( cMsg ) )
		Help( ,, 'Help',, 'O MODELVLDACTIVE retornou .F.', 1, 0 )
	EndIf
	           
	
ElseIf cIdPonto ==  'MENUDEF'
	// Este ponto nao é nativo do MVC é preciso cria-lo no MENUDEF da aplicacao
	// Consulte o TDN
	
    ApMsgInfo('Adicionando Botao na MenuDef (MENUDEF).' + CRLF + 'ID '  + cIdModel )
	xRet := { { 'Teste'    , 'MSGINFO("TESTE menu")', 0, 9, 0, NIL }  }
	
	
EndIf

Return xRet