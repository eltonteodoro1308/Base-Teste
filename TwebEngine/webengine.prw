#include "TOTVS.CH"

user function webengine()
	local i
	local cMultGet := ""
	local nPort,lConnected, link
	local aFiles := {"totvstec.js", "webengine.index.html"}
	local _tempPath := GetTempPath()
	PRIVATE oWebChannel
	PRIVATE oWebEngine
	PRIVATE oMultGet

	PRIVATE oDlg := TWindow():New(10, 10, 800, 600, "Exemplo", NIL, NIL, NIL, NIL, NIL, NIL, NIL,;
	CLR_BLACK, CLR_WHITE, NIL, NIL, NIL, NIL, NIL, NIL, .T. )

	// Baixa arquivos do exemplo do RPO no diretorio temporario
	for i := 1 to len(aFiles)
		cFile := _tempPath + aFiles[i]
		nHandle := fCreate(cFile)
		fWrite(nHandle, getApoRes(aFiles[i]))
		fClose(nHandle)
	next i

	// ------------------------------------------
	// Prepara o conector WebSocket
	// ------------------------------------------
	oWebChannel := TWebChannel():New()
	nPort       := oWebChannel::connect() // Efetua conexão e retorna a porta do WebSocket
	lConnected  := oWebChannel:lConnected // Conectado ? [.T. ou .F.]

	// Verifica conexão
	if !lConnected
		msgStop("Erro na conexão com o WebSocket")
		return // Aborta aplicação
	endif

	// ------------------------------------------
	// Define o CallBack JavaScript
	// IMPORTANTE: Este é o canal de comunicação
	//             "vindo do Javascript para o ADVPL"
	// ------------------------------------------
	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| jsToAdvpl(self,codeType,codeContent) }

	// Monta link para navegação local inserindo "file:///"
	if subs(_tempPath,1,2) == "C:"
		_tempPath := "file:///" + strTran(_tempPath, "\", "/")
	endif
	link := _tempPath + "webengine.index.html"

	// ------------------------------------------
	// Cria navegador embedado
	// ------------------------------------------
	oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100,, nPort)
	oWebEngine:navigate(link)
	oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

	// Painel inferior
	@ 038, 000 MSPANEL ConOut SIZE 250, 030 OF oDlg COLORS 0, 16777215 RAISED
	ConOut:Align := CONTROL_ALIGN_BOTTOM
	oMultGet := TSimpleEditor():New( 0,0,ConOut, 100,100,"",, {| u | if( pCount() > 0, cMultGet := u, cMultGet )}, , .T.)
	oMultGet:Align := CONTROL_ALIGN_ALLCLIENT

	// ------------------------------------------
	// Botão fara o disparo do método runJavaScript
	// que permite a execução via ADVPL de uma função JavaScript
	// ------------------------------------------
	@ 000, 204 BUTTON oButton1 PROMPT "runJavaScript" SIZE 045, 041 OF ConOut;
	ACTION {|| oWebEngine:runJavaScript("alert('Alert Javascript\ndisparado via ADVPL')") } PIXEL
	oButton1:Align := CONTROL_ALIGN_RIGHT

	oDlg:Activate("MAXIMIZED")
Return

// ------------------------------------------
// Esta função recebera todas as chamadas vindas do Javascript
// através do método dialog.jsToAdvpl(), exemplo:
// dialog.jsToAdvpl("page_started", "Pagina inicializada");
// ------------------------------------------
static function jsToAdvpl(self,codeType,codeContent)
	local i
	local cFunJS
	local oTmpHashProg:= .F.
	local cCommand := ""

	if valType(codeType) == "C"
		_conout("jsToAdvpl->codeType: " + codeType + " = " + codeContent)

		// ------------------------------------------b
		// Recebe mensagem de termino da carga da página/componente
		// ------------------------------------------
		if codeType == "page_started"

			// ------------------------------------------
			// Ao terminar a caraga da página inserimos um botão na página HTML
			// que fará a execução de uma função ADVPL via JavaScript
			//
			// Importante: O comando BeginContent permite a criação de pequenos trechos de código
			// facilitando a construção de chamadas, como neste exemplo onde montamos um trecho Javascript
			// ------------------------------------------
			BeginContent var cFunJS
			<a onclick='totvstec.runAdvpl("DtoS(CtoD(\"" +getDate()+ "\"))", runAdvplSuccess);'>
			<div>
			<font size="5">runAdvpl</font><br><br>
			</div>
			</a>
			EndContent

			// ------------------------------------------
			// O método AdvplToJS envia uma mensagem do ADVPL para o JavaScript, para verificar a chegada
			// desta mensagem procure  o trecho a seguir no arquivo webengine.index.html
			// if (codeType == "html") {...
			// ------------------------------------------
			oWebChannel:advplToJs("html", cFunJS)

		endif

		// ------------------------------------------
		// Este trecho vai executar um comando ADVPL vindo do JavaScript
		// ------------------------------------------
		if codeType == "runAdvpl"

			// ------------------------------------------
			// Importante:
			// A informação trafegada pela chamada do metodo Javascript runADVPL é uma variável do tipo JSON
			// assim é necessário seu tratamento, para tanto utilise as funções getJsonHash e getHField, documentadas neste exemplo
			// ------------------------------------------
			if getJsonHash(codeContent, @oTmpHashProg)

				cCommand := getHField(oTmpHashProg, "codeBlock")
				if !empty(cCommand)

					// Transforma o texo em um bloco de código e
					// em caso de sucesso executa o mesmo
					xVal := &("{|| " + cCommand + "}")
					if valType(xVal) == "B"
						xRet := eval(xVal)
						xRet := cValToChar(xRet) // Converte pra String

						// ------------------------------------------
						// Importante:
						// Este trecho executa do callBack (mensagem de retorno) para o Javascript
						// permitindo o retorno de informações ao HTML após o processamento via ADVPL
						// ------------------------------------------
						fnCallBack = getHField(oTmpHashProg, "callBack")+"('" +xRet+ "')"
						oWebEngine:runJavaScript(fnCallBack)

					endif

				endif
			endif

		endif

	endif

return

/* ---------------------------------------------------------------
Parseia o Json em um Hash

getJsonHash: recebe o conteudo no formato Texto que será parseado
oHash: é uma varivel que receberá "por referencia" o conteudo HASH
contido no Texto inicial, por ser uma variavel utilizada por referencia
ela deve ter seu valor declarado anteriormente, exemplo: oTmpHashProg:= .F.
---------------------------------------------------------------*/
Static Function getJsonHash(jsonData, oHash)
	Local oJson := tJsonParser():New()
	Local jsonfields := {}
	Local nRetParser := 0

	if empty(jsonData)
		return .F.
	endif

	// Converte JSON pra Hash
	return oJson:Json_Hash(jsonData, len(jsonData), @jsonfields, @nRetParser, @oHash)
return

/* ---------------------------------------------------------------
Retorna valor do campo no Hash

oHash: variável no formato HASH criada pela função  getJsonHash
jsonField: nome do campono no formato Texto que se deseja recuperar

retorno: valor do campo encontrado ou "vazio" caso contrário
---------------------------------------------------------------*/
Static Function getHField(oHash, jsonField)
	Local xGet := Nil
	// Recupera valor do campo
	if HMGet(oHash, jsonField, xGet)
		return xGet
	else
		return ""
	endif
return

// ---------------------------------------------------------------
// Exibe conout no MultiGet para auxiliar na visualização em tela
// ---------------------------------------------------------------
static function _conout(cText)
	conOut(cText)
	oMultGet:Load(cText)
Return