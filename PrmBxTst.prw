#INCLUDE 'TOTVS.CH'

User Function PrmBxTst()
	
	Local aPergs := {}
	Local aRet   := {}
	
	// Get
	
	aAdd( aPergs, { 001                         ,; // [1] : 1 - MsGet
	'Produto: '                                 ,; // [2] : Descri��o
	Space(GetSX3Cache('B1_COD','X3_TAMANHO'))   ,; // [3] : String contendo o inicializador do campo
	GetSX3Cache('B1_COD','X3_PICTURE')          ,; // [4] : String contendo a Picture do campo
	'Vazio() .Or. ExistCpo( "SB1",MV_PAR01)'    ,; // [5] : String contendo a valida��o
	'SB1'                                       ,; // [6] : Consulta F3
	'AllWaysTrue()'                             ,; // [7] : String contendo a valida��o When
	100                                         ,; // [8] : Tamanho do MsGet
	AllWaysFalse() } )                             // [9] : Flag .T./.F. Par�metro Obrigat�rio ?
	
	// Combo
	
	aAdd( aPergs, { 002                         ,; // [2] : 2 - Combo
	'Confirma ?'                                ,; // [2] : Descri��o
	2                                           ,; // [3] : Num�rico contendo a op��o inicial do combo
	{'1=Sim','2=N�o','3=Talvez'}                ,; // [4] : Array contendo as op��es do Combo
	100                                         ,; // [5] : Tamanho do Combo
	'AllWaysTrue()'                             ,; // [6] : Valida��o
	AllWaysFalse() } )                             // [7] : Flag .T./.F. Par�metro Obrigat�rio ?
	
	// Radio
	
	aAdd( aPergs, { 003                         ,; // [1] : 3 - Radio
	'Confirma ?'                                ,; // [2] : Descri��o
	2                                           ,; // [3] : Num�rico contendo a op��o inicial do Radio
	{'Sim','N�o','Talvez'}                      ,; // [4] : Array contendo as op��es do Radio
	100                                         ,; // [5] : Tamanho do Radio
	'AllWaysTrue()'                             ,; // [6] : Valida��o
	AllWaysFalse()                              ,; // [7] : Flag .T./.F. Par�metro Obrigat�rio ?
	AllWaysTrue() } )                              // [8] : String contendo a valida��o When	
	
	ParamBox(aPergs ,"Substitui recurso",aRet)
	
Return .T.
