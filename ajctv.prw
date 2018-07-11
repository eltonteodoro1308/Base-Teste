#include 'totvs.ch'

user function ajctv()

Local cAlias   := GetNextAlias()
Local aArea    := GetArea()
Local cSeekCTV := ''
Local cSeekSQL := ''
Local nCount    := 0

BeginSql Alias cAlias
	
	COLUMN CTV_DATA AS DATE
	
	SELECT CTV_FILIAL, CTV_MOEDA, CTV_TPSALD, CTV_ITEM, CTV_CUSTO, CTV_DATA, COUNT(*) COUNT
	FROM %TABLE:CTV%
	WHERE %NOTDEL%
	GROUP BY CTV_FILIAL,CTV_CUSTO,CTV_ITEM,CTV_MOEDA,CTV_DATA,CTV_TPSALD
	HAVING COUNT(*) > 1
	AND SUBSTRING(CTV_DATA,1,4) = '2017'
	
EndSql

(cAlias)->(DbGoTop())

DbSelectArea( 'CTV' )
DbSetOrder(1) //CTV_FILIAL+CTV_MOEDA+CTV_TPSALD+CTV_ITEM+CTV_CUSTO+DTOS(CTV_DATA)

Do While ! ( cAlias )->( Eof() )
	
	cSeekSQL := ( cAlias )->( CTV_FILIAL + CTV_MOEDA + CTV_TPSALD + CTV_ITEM + CTV_CUSTO + DTOS( CTV_DATA ) ) 
	nCount   := ( cAlias )->COUNT
	
	If DbSeek( cSeekSQL )
		
		cSeekCTV := CTV->( CTV_FILIAL + CTV_MOEDA + CTV_TPSALD + CTV_ITEM + CTV_CUSTO + DTOS( CTV_DATA ) )
		
		Do While ! CTV->( Eof() ) .And. cSeekSQL == cSeekCTV .And. nCount > 1
			
			RecLock( 'CTV', .F. )
			
			DbDelete()
			
			MsUnlock()
			
			CTV->( DbSkip() )
			
			nCount--
			
		End Do
		
	End If
	
	( cAlias )->( DbSkip() )
	
End Do

RestArea(aArea)

return
