// chamada http://spon4944:7112/u_InfoTeste.apw
User Function InfoTeste()

	Local cHtml := ''
	cHtml += VarInfo('Date',date())
	cHtml += VarInfo('Time',time())
	cHtml += VarInfo('Nome','Elton Teodoro Alves')

Return cHtml

/* Deve ser gerado um echo no Console do Servidor parecido com este abaixo 
Date -> D (   10) [08/12/2003]
Time -> C (    8) [20:17:48]
*/