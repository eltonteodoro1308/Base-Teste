#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE STR001 'INCLUSÃO DE PEDIDO DE VENDA E GERAÇÃO DO DOCUMENTO DE SAÍDA'

/*/{Protheus.doc} RFAT001
Classe REST para inclusão de Pedido de Venda e geração do seu Documento de Saída Correspondente.
@type Classe Rest
@author Elton Teodoro Alves
@since 27/11/2017
@version 12.1.17
/*/
WSRESTFUL RFAT001 DESCRIPTION STR001 FORMAT APPLICATION_JSON

WSMETHOD POST DESCRIPTION STR001 WSSYNTAX '/RFAT001'

END WSRESTFUL

/*/{Protheus.doc} POST
Método POST do Web Service Rest
@type Method POST
@author Elton Teodoro Alves
@since 27/11/2017
@version 12.1.17
/*/
WSMETHOD POST WSSERVICE RFAT001

	Local lRet    := .T.
	Local oPedido := Nil
	Local aCabec  := {}
	Local aItem   := {}
	Local aItens  := {}
	Local aErro   := {}
	Local nX      := 0
	Local cMsg    := '{ "LINHA":"Documento de Saída Gerado com Sucesso."}'
	Local cNumPed := ''
	Local cNumNf  := ''
	Local cGerada := 'true'

	Private	lMsErroAuto		:=	.F.
	Private	lMsHelpAuto		:=	.T.
	Private	lAutoErrNoFile	:=	.T.

	::SetContentType("application/json")

	If FWJsonDeserialize( ::GetContent(), @oPedido )

		cNumPed := GetSXENum( 'SC5', 'C5_NUM' )

		RollBAckSx8()

		aAdd( aCabec, { 'C5_NUM'     , cNumPed         , Nil } )
		aAdd( aCabec, { 'C5_TIPO'    , 'N'             , Nil } )
		aAdd( aCabec, { 'C5_CLIENTE' , oPedido:CLIENTE , Nil } )
		aAdd( aCabec, { 'C5_LOJACLI' , oPedido:LOJA    , Nil } )
		aAdd( aCabec, { 'C5_CONDPAG' , oPedido:CONDPGTO, Nil } )

		For nX := 1 To Len( oPedido:ITENS )

			aAdd( aItem, { 'C6_PRODUTO', oPedido:ITENS[nX]:ITEM:PRODUTO   , Nil } )
			aAdd( aItem, { 'C6_QTDVEN' , oPedido:ITENS[nX]:ITEM:QUANTIDADE, Nil } )
			aAdd( aItem, { 'C6_QTDLIB' , oPedido:ITENS[nX]:ITEM:QUANTIDADE, Nil } )
			aAdd( aItem, { 'C6_PRCVEN' , oPedido:ITENS[nX]:ITEM:PRECO     , Nil } )
			aAdd( aItem, { 'C6_TES'    , oPedido:ITENS[nX]:ITEM:TES       , Nil } )

			aAdd( aItens, aClone( aItem ) )

			aSize( aItem, 0 )

		Next nX

		BeginTran()

		MSExecAuto( { | X, Y, Z | MATA410( X, Y, Z ) }, aCabec, aItens, 3 )

		If lMsErroAuto

			aErro := aClone( GetAutoGRLog() )

			cMsg := ''

			For nX := 1 To Len( aErro )

				cMsg += '{ "LINHA":"' + aErro[ nX ] + '"}'

				If nX < Len( aErro )

					cMsg += ','

				End If

			Next nX

			DisarmTransaction()

			cGerada := 'false'

		Else

			cNumNf := GeraNota( cNumPed, oPedido:SERIE )

		End If

		EndTran()

	Else

		cMsg := '{ "LINHA":"Erro no Parse do Arquivo JSON enviado."}'

		cGerada := 'false'

	End If

	::SetResponse(EncodeUtf8('{"GERADA":' + cGerada + ', "PEDIDO": "' + cNumPed + '", "NF": "' + cNumNf + '", "MENSAGEM": [' + cMsg + ']}'))

Return lRet


/*/{Protheus.doc} GeraNota
Gera o Documento de Saída e retorna o seu número correspondente
@type function
@author Elton Teodoro Alves
@since 27/11/2017
@version 12.1.17
@param cNumPed, Caracter, Número do Pedido de Venda
@param cSerie, Caracter, Série do Documento de Saída
@return Caracter, Número do Documento de Saída Gerado
/*/
User Function GeraNota( cNumPed, cSerie )

	Local aPvs     := {}
	Local cNota    := ""

	DbSelectArea("SC9")
	SC9->(DbGoTop())
	SC9->(DbSetOrder(1))

	If SC9->(DbSeek(xFilial("SC9") + cNumPed))
		Do While SC9->(!EOF() .And. SC9->(C9_FILIAL + C9_PEDIDO) == xFilial("SC9") + cNumPed)
			Reclock("SC9",.F.)
			Replace C9_BLEST With ""
			Replace C9_BLCRED With ""
			MsUnlock()
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5") + SC9->C9_PEDIDO))
				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC9") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO))
					DbSelectArea("SE4")
					SE4->(DbSetOrder(1))
					If SE4->(DbSeek(xFilial("SE4") + SC5->C5_CONDPAG))
						DbSelectArea("SB1")
						SB1->(DbSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1") + SC9->C9_PRODUTO))
							DbSelectArea("SB2")
							SB2->(DbSetOrder(1))
							If	SB2->(DbSeek(xFilial("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL))
								DbSelectArea("SF4")
								SF4->(DbSetOrder(1))
								If	SF4->(DbSeek(xFilial("SF4") + SC6->C6_TES))
									Aadd(aPvs,{;
									SC9->C9_PEDIDO,;
									SC9->C9_ITEM,;
									SC9->C9_SEQUEN,;
									SC9->C9_QTDLIB,;
									SC9->C9_PRCVEN,;
									SC9->C9_PRODUTO,;
									.F.,;
									SC9->(RecNo()),;
									SC5->(RecNo()),;
									SC6->(RecNo()),;
									SE4->(RecNo()),;
									SB1->(RecNo()),;
									SB2->(RecNo()),;
									SF4->(RecNo())})
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			SC9->(Dbskip())
		EndDo
	EndIf

	//cNota := MaPvlNfs(aPvs,PADR(cSerie,TamSX3("F2_SERIE")[1] ), .F., .F., .F., .F., .F., 0, 0, .F., .F.)
	cNota := MaPvlNfs(aPvs,cSerie, .F., .F., .F., .F., .F., 0, 0, .F., .F.)

Return(cNota)
