#INCLUDE 'TOTVS.CH'

User Function PrmBxTst()
	
	Local aPergs := {}
	Local aRet   := {}
	
	// Get
	
	aAdd( aPergs, { 001                         ,; // [1] : 1 - MsGet
	'Produto: '                                 ,; // [2] : Descrição
	Space(GetSX3Cache('B1_COD','X3_TAMANHO'))   ,; // [3] : String contendo o inicializador do campo
	GetSX3Cache('B1_COD','X3_PICTURE')          ,; // [4] : String contendo a Picture do campo
	'Vazio() .Or. ExistCpo( "SB1",MV_PAR01)'    ,; // [5] : String contendo a validação
	'SB1'                                       ,; // [6] : Consulta F3
	'AllWaysTrue()'                             ,; // [7] : String contendo a validação When
	100                                         ,; // [8] : Tamanho do MsGet
	AllWaysFalse() } )                             // [9] : Flag .T./.F. Parâmetro Obrigatório ?
	
	// Combo
	
	aAdd( aPergs, { 002                         ,; // [2] : 2 - Combo
	'Confirma ?'                                ,; // [2] : Descrição
	2                                           ,; // [3] : Numérico contendo a opção inicial do combo
	{'1=Sim','2=Não','3=Talvez'}                ,; // [4] : Array contendo as opções do Combo
	100                                         ,; // [5] : Tamanho do Combo
	'AllWaysTrue()'                             ,; // [6] : Validação
	AllWaysFalse() } )                             // [7] : Flag .T./.F. Parâmetro Obrigatório ?
	
	// Radio
	
	aAdd( aPergs, { 003                         ,; // [1] : 3 - Radio
	'Confirma ?'                                ,; // [2] : Descrição
	2                                           ,; // [3] : Numérico contendo a opção inicial do Radio
	{'Sim','Não','Talvez'}                      ,; // [4] : Array contendo as opções do Radio
	100                                         ,; // [5] : Tamanho do Radio
	'AllWaysTrue()'                             ,; // [6] : Validação
	AllWaysFalse()                              ,; // [7] : Flag .T./.F. Parâmetro Obrigatório ?
	AllWaysTrue() } )                              // [8] : String contendo a validação When	
	
	ParamBox(aPergs ,"Substitui recurso",aRet)
	
Return .T.
