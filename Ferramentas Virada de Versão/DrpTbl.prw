//TODO Rotina que verifica se tabela está vazia e drop a mesma
//TODO Verifica se há campo ausente na tabela, com tipo diferente,
//TODO com tamanho diferente ou com decimais diferentes
//TODO exporta tabela para dbf, dropa, recria e appenda
//TODO dbf exportado.
//TODO
//TODO


#INCLUDE 'TOTVS.CH'
#INCLUDE "TOPCONN.CH"

User Function DrpTbl()
	
	Local aAreaSX2 := SX2->( GetArea() )
	Local aArea    := GetArea()
	
	SX2->( DbSetOrder(1) )
	SX2->( DbGoTop() )
	
	Do While .Not. SX2->( Eof() )
		
		DbSelectArea(SX2->X2_CHAVE)
		
		If (SX2->X2_CHAVE)->(RecCount()) > 0
			
			ConOut(SX2->X2_CHAVE + ' Populada')
			
		Else
			
			ConOut(SX2->X2_CHAVE + ' Vazia')
			
			(SX2->X2_CHAVE)->(DbCloseArea())
			
			If TcDelFile( RetSqlName( SX2->X2_CHAVE) )
				
				ConOut( SX2->X2_CHAVE + ' Excluída' )

			Else

				ConOut( SX2->X2_CHAVE + ' Não Excluída' )

			End If
			
		End If
		
		SX2->( DbSkip() )
		
	End Do
	
	SX2->( RestArea( aAreaSX2 ) )
	RestArea( aArea )
	
Return


