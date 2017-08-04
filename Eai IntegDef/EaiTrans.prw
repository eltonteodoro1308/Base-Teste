#INCLUDE 'TOTVS.CH'

User Function EaiTrans( cXml, cError, cWarning, cParams, oFwEai )

	DbSelectArea( 'ZZZ' )

	RecLock( 'ZZZ', .T. )

	ZZZ->ZZZ_DESCR := Time()

	MsUnlock()

	DisarmTransaction()

Return oFwEai:cReturnMsg