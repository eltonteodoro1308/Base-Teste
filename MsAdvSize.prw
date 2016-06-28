#include 'TOTVS.CH'

User Function Teste1()
	
	Local aSize           := {}
	Local aObjects        := {}
	Local aInfo            := {}
	Local oDlg
	Local oGetD
	Local cCadastro := ''
	Local nReg := 1
	Local nOpc := 3
	
	// Obtém a a área de trabalho e tamanho da dialog
	
	aSize := MsAdvSize()
	
	AAdd( aObjects, { 100, 100, .T., .T. } )  // Dados da Enchoice
	
	AAdd( aObjects, { 200, 200, .T., .T. } ) // Dados da getdados
	
	// Dados da área de trabalho e separação
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	
	// Chama MsObjSize e recebe array e tamanhos
	
	aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
	// Usa tamanhos da dialog
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	// Usar sempre PIXEL !!!
	// Usa linha 1 do array para enchoice. A enchoice já recebe um array pronto de dimensões
	
	EnChoice( "AI1", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.F. )
	// Usa linha 2 do array para getdados. A getdados recebe individualmente
	
	oGetD :=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Ft180LOk()","Ft180TOk()","+AI2_ITEM",(nOper==3 .Or.nOper==4),,1,,MAXGETDAD)
	
Return
/*
Casos mais sofisticados
Em algumas situações, uma chamada simples de MsObjSize() não é suficiente para se produzir janelas realmente sofisticadas.
Tipicamente, isso ocorre quando desejamos exibir uma combinação de objetos dispostos vertical e horizontalmente.
Nesse caso, pode ser necessário efetuar o disparo de duas ou mais funções MsObjSize().
Uma vez dominada esta técnica, pode-se produzir praticamente qualquer combinação de objetos.
Um exemplo clássico desta técnica é a rotina FATA320.PRX ( representantes – módulo faturamento ).
Nesse caso, temos dois objetos dispostos do lado esquerdo da tela (agenda do dia e tarefas da semana), um sobre o outro.
Do lado direito, temos outros dois objetos (um calendário e um painel com vários botões), também dispostos de forma vertical.
A forma mais fácil de solucionar esta janela é, primeiramente, considerar que existem dois objetos na tela dispostos lado a lado.
Depois, resolveremos os objetos dispostos em cada metade da tela (direita e esquerda). Isso nos leva a três chamadas de MsObjSize().
Exemplo de código:
*/

User Function Teste2()
	
	Local aSize := {}
	Local aInfo := {}
	Local aObjects := {}
	Local aPosObj1            := {}
	Local aPosObj2            := {}
	Local aPosObj3            := {}
	
	// Divide a tela lateralmente e resolve as dimensões de cada parte
	// Observe que o segundo objeto (calendário) não pode ser dimensionado
	// lateralmente, pois seu tamanho é fixo
	
	aSize := MsAdvSize(.F.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	// todo variável
	AAdd( aObjects, { 140,  66, .F., .T. } ) // tamanho ( X ) fixo
	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	// Primeira chamada, dois objetos laterais
	
	aPosObj1 := MsObjSize( aInfo, aObjects,  , .T. )
	// Resolve as dimensoes dos objetos da parte esquerda da tela
	// Temos 2 objetos que podem ser redimensionados.
	aObjects := {}
	
	AAdd( aObjects, { 100, 100, .T., .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T., .T. } )
	
	// Agora, lançaremos mão de um artifício: usaremos o primeiro objeto retornado
	// pela primeira MsObjSize como área de trabalho da segunda MsObjSize
	
	aSize2 := aClone( aPosObj1[1] )
	
	// Para tanto, devemos inverter os parâmetros de tamanho.
	// A ordem passa a ser 2,1,4,3 e não mais 1,2,3,4
	// Isso ocorre, pois a área de trabalho funciona com coordenadas X,Y e não
	// Linha / coluna (Y, X)
	
	aInfo    := { aSize2[ 2 ], aSize2[ 1 ], aSize2[ 4 ], aSize2[ 3 ], 3, 3, 0, 0 }
	
	// Segunda chamada (lado esquerdo), objetos dispostos verticalmente.
	
	aPosObj2 := MsObjSize( aInfo, aObjects )
	
	// Resolve as dimensões dos objetos da parte direita da tela
	
	aObjects := {}
	AAdd( aObjects, { 140,  66, .T., .F. } )
	
	// agora, a altura do calendário que nao pode mudar (Y)
	
	AAdd( aObjects, { 100, 100, .T., .T., .T. } )
	
	// pode variar X e Y
	// O artifício de novo: usaremos o segundo objeto retornado
	// pela primeira MsobjSize como área de trabalho da terceira MsObjSize
	
	aSize3 := aClone( aPosObj1[2] )
	
	// Para tanto, devemos inverter os parâmetros de tamanho.
	// A ordem passa a ser 2,1,4,3 e não mais 1,2,3,4
	
	aInfo    := { aSize3[ 2 ], aSize3[ 1 ], aSize3[ 4 ], aSize3[ 3 ], 3, 3, 0, 0 }
	aPosObj3 := MsObjSize( aInfo, aObjects )
	
	//Basicamente, o que temos agora são dados de dimensões para 4 objetos, representados por aPosObj2, elementos 1 e 2, e aPosObj3, elementos 1 e 2.
	//Abaixo representamos código resumido da aplicação dos dados de aPosObj2 e 3.
	
	// Browse da agenda
	
	oAgenda :=TSBrowse():New(aPosObj2[1,1],aPosObj2[1,2],aPosObj2[1,3],aPosObj2[1,4],oDlg,,35,,5 )
	
	// Browse das tarefas
	
	oTarefa := TsBrowse():New( aPosObj2[2,1], aPosObj2[2,2], aPosObj2[2,3], aPosObj2[2,4], oDlg,,35,,5 )
	
	// Calendário
	
	oCalend:=MsCalend():New(aPosObj3[1,1],aPosObj3[1,2],oDlg)
	
	// Painel de botões
	
	@ aPosObj3[2,1],aPosObj3[2,2] MSPANEL oPanel3 PROMPT "" SIZE aPosObj3[2,3],aPosObj3[2,4] OF oDlg CENTERED RAISED //"Botoes"
	
Return
