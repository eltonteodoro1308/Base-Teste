#Include 'Protheus.ch'

User Function MTA094RO()

	Local aRotina := PARAMIXB[1]
	Local nX      := 0
	Local nPos    := 0

	For nX := 1 To Len( aRotina )

		If ValType( aRotina[ nX, 2 ] ) == 'A'		

			nPos := aScan( aRotina[ nX, 2 ], { | X |  Upper( AllTrim( X[ 2 ] ) ) == 'A94EXSUPER' } )	

			If  nPos # 0

				aRotina[ nX, 2, nPos, 2 ] == "U_TIME"

			End If

			nPos := aScan( aRotina[ nX, 2 ], { | X |  Upper( AllTrim( X[ 2 ] ) ) == 'A94EXTRANS' } )	

			If  nPos # 0

				aRotina[ nX, 2, nPos, 2 ] == "U_TIME"

			End If

		End If

	Next nX

Return (aRotina)

