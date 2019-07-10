#INCLUDE 'TOTVS.CH'

User Function MT010INC()

	Local oHTML

	//Crio o objeto oProcess, que recebe a inicialização da classe TWFProcess. Repare que o primeiro Parâmetro é o código do processo que cadastramos acima e o segundo uma descrição qualquer.

	Local oProcess := TWFProcess():New( "000002", "Atualizacao de Precos" )

	//Crio uma task. Um Processo pode ter várias Tasks(tarefas). Para cada Task informo um nome para ela e o HTML envolvido. Repare que o path do HTML é sempre abaixo do RootPath do Microsiga Protheus®.

	oProcess:NewTask( "PRECOS01", "\WORKFLOW\CURSO.HTM" )

	//Informo o título do e-mail.

	oProcess:cSubject := "Atualizacao de Precos"

	//Informo qual função o Workflow executará ao ler a resposta do usuário.

	oProcess:bReturn := "U_CURSO01R()"

	//Informo o tempo de espera máximo para a resposta do usuário e a função a ser executada caso este tempo seja ultrapassado.

	oProcess:bTimeOut := {{"U_CURSO01T()",0, 0, 5 }}

	//Simplesmente passo o valor da propriedade oProcess:oHTML  para uma variável local para facilitar

	oHTML := oProcess:oHTML

	//Começo a preencher os valores do HTML. Inicialmente preencho o objeto DATA(no Html %DATA%) com a data base do sistema.

	oHTML:ValByName('DATA',dDataBase)

	//Preencho os itens da tabela : Código, Descrição do Produto e preço.

	dbSelectArea("SB1")

	aadd((oHtml:valByName('TB.CODIGO')),B1_COD)

	aadd((oHtml:valByName('TB.DESCRICAO')),B1_DESC)

	aadd((oHtml:valByName('TB.PRECO')),TRANSFORM( B1_PRV1,'@E 99,999.99' ))

	//Informo para qual endereço(s) vai o e-mail

	oProcess:cTo := 'elton.alves@totvs.com.br'

	//Informo o código do usuário no Microsiga Protheus® que receberá o e-mail. Isto é útil para usar a consulta de Processos por usuário.

	oProcess:UserSiga := "000000"

	//Coloco aqui um ponto de Rastreabilidade. Os dois primeiros parâmetros são sempre os abaixo passados e o terceiro indica o código do Status acima cadastrado.

	RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'10001')

	//Aqui faço a gravação do ID do Processo (que é gerado pelo Workflow e único para cada processo) em um campo criado pelo usuário nesta tabela. Isto servirá para rastrear qual processo está ligado a determinado produto. É este código que deverá ser informado na caixa de ID da tela de rastreabilidade.

	RecLock('SB1')

	SB1->B1_WFID := oProcess:fProcessID

	MsUnlock()

	//Inicio o Processo, enviando o e-mail.

	oProcess:Start('\web\')

Return .T.

//Sempre é passado como último parâmetro a variável oProcess, que contém todas as propriedades do e-mail respondido.

User Function CURSO01R(oProcess)

	dbSelectArea("SB1")

	dbSetOrder(1)

	//Pego o código do produto, através do método RetByName, para achar o produto correto no cadastro.

	dbSeek(xFilial()+oProcess:oHtml:RetByName('TB.CODIGO')[1])

	RecLock("SB1")

	//Gravo o valor do preço de venda informado pela pessoa que respondeu o e-mail

	SB1->B1_PRV1 := Val(oProcess:oHtml:RetByName('TB.PRECO')[1])

	MsUnlock()

	//Coloco mais um ponto de rastreabilidade, usando o Status 10002.

	RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'10002')

Return .T.

User Function CURSO01T(oProcess)

	ConOut('TimeOut executado')

Return .T.