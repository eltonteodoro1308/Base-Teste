#Include 'Rwmake.ch'
/*
Programa.: 	MT150LEG 
Autor....:	Pedro Augusto
Data.....: 	26/08/2014 
Descricao: 	Ponto de Entrada para adicionar uma cor no browse da rotina "Atualiza cotacao"
Uso......: 	MIRASSOL
*/
User Function MT150LEG
	Local _aRet := {}     
	Local _nOpc := ParamIXB[1]
	If _nOpc == 1 // Cores
		Aadd( _aRet,{'C8_XWF="1" .and. Alltrim(C8_NUMPED) =""','BR_LARANJA'})
		Aadd( _aRet,{'C8_XWF="2" .and. Alltrim(C8_NUMPED) =""','BR_AZUL'   })
		Aadd( _aRet,{'C8_XWF="3" .and. Alltrim(C8_NUMPED) =""','BR_PINK'   })
	ElseIf _nOpc == 2  // Legenda
		Aadd( _aRet,{'BR_LARANJA','Enviado e-mail p/ fornec.'     } )
		Aadd( _aRet,{'BR_AZUL'   ,'Cotação respondida pelo fornec.'} )
		Aadd( _aRet,{'BR_PINK'   ,'Cotação recusada pelo fornec.'} )
	Endif
	Return _aRet
