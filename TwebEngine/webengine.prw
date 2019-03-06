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
	nPort       := oWebChannel::connect() // Efetua conex�o e retorna a porta do WebSocket
	lConnected  := oWebChannel:lConnected // Conectado ? [.T. ou .F.]

	// Verifica conex�o
	if !lConnected
		msgStop("Erro na conex�o com o WebSocket")
		return // Aborta aplica��o
	endif

	// ------------------------------------------
	// Define o CallBack JavaScript
	// IMPORTANTE: Este � o canal de comunica��o
	//             "vindo do Javascript para o ADVPL"
	// ------------------------------------------
	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| jsToAdvpl(self,codeType,codeContent) }

	// Monta link para navega��o local inserindo "file:///"
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
	// Bot�o fara o disparo do m�todo runJavaScript
	// que permite a execu��o via ADVPL de uma fun��o JavaScript
	// ------------------------------------------
	@ 000, 204 BUTTON oButton1 PROMPT "runJavaScript" SIZE 045, 041 OF ConOut;
	ACTION {|| oWebEngine:runJavaScript("alert('Alert Javascript\ndisparado via ADVPL')") } PIXEL
	oButton1:Align := CONTROL_ALIGN_RIGHT

	oDlg:Activate("MAXIMIZED")
Return

// ------------------------------------------
// Esta fun��o recebera todas as chamadas vindas do Javascript
// atrav�s do m�todo dialog.jsToAdvpl(), exemplo:
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
		// Recebe mensagem de termino da carga da p�gina/componente
		// ------------------------------------------
		if codeType == "page_started"

			// ------------------------------------------
			// Ao terminar a caraga da p�gina inserimos um bot�o na p�gina HTML
			// que far� a execu��o de uma fun��o ADVPL via JavaScript
			//
			// Importante: O comando BeginContent permite a cria��o de pequenos trechos de c�digo
			// facilitando a constru��o de chamadas, como neste exemplo onde montamos um trecho Javascript
			// ------------------------------------------
			BeginContent var cFunJS
			<a onclick='totvstec.runAdvpl("DtoS(CtoD(\"" +getDate()+ "\"))", runAdvplSuccess);'>
			<div>
			<font size="5">runAdvpl</font><br><br>
			</div>
			</a>
			EndContent

			// ------------------------------------------
			// O m�todo AdvplToJS envia uma mensagem do ADVPL para o JavaScript, para verificar a chegada
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
			// A informa��o trafegada pela chamada do metodo Javascript runADVPL � uma vari�vel do tipo JSON
			// assim � necess�rio seu tratamento, para tanto utilise as fun��es getJsonHash e getHField, documentadas neste exemplo
			// ------------------------------------------
			if getJsonHash(codeContent, @oTmpHashProg)

				cCommand := getHField(oTmpHashProg, "codeBlock")
				if !empty(cCommand)

					// Transforma o texo em um bloco de c�digo e
					// em caso de sucesso executa o mesmo
					xVal := &("{|| " + cCommand + "}")
					if valType(xVal) == "B"
						xRet := eval(xVal)
						xRet := cValToChar(xRet) // Converte pra String

						// ------------------------------------------
						// Importante:
						// Este trecho executa do callBack (mensagem de retorno) para o Javascript
						// permitindo o retorno de informa��es ao HTML ap�s o processamento via ADVPL
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

getJsonHash: recebe o conteudo no formato Texto que ser� parseado
oHash: � uma varivel que receber� "por referencia" o conteudo HASH
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

oHash: vari�vel no formato HASH criada pela fun��o  getJsonHash
jsonField: nome do campono no formato Texto que se deseja recuperar

retorno: valor do campo encontrado ou "vazio" caso contr�rio
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
// Exibe conout no MultiGet para auxiliar na visualiza��o em tela
// ---------------------------------------------------------------
static function _conout(cText)
	conOut(cText)
	oMultGet:Load(cText)
Return