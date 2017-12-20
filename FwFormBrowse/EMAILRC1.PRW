//#INCLUDE "FIVEWIN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PROTHEUS.CH"

Static lTipMark	:= .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEMAILRC1    บAutor  ณJuliana Gomes     บ Data ณ  24/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este Programa tem objetivo enviar os emails de aprova็ao   บฑฑ
ฑฑบ          ณ dos titulos do Gestใo de Pessoal                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณCarlos.Ramos|01/05/17|------|  Substitui็ใo MsSelect p/ FwFormBrowse   ณฑฑ
ฑฑณCarlos.Ramos|01/05/17|------|  Adequa็ใo da FCRIATRB p/ FwFormBrowse   ณฑฑ
ฑฑณCarlos.Ramos|01/05/17|------|  Adequa็ใo da GeraMail p/ FwFormBrowse   ณฑฑ
ฑฑณCarlos.Ramos|01/05/17|------|  Substitui็ใo da FInverte p/ MarkOne     ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function EMAILRC1()

PRIVATE cSolicit := UsrRetName(RetCodUsr() )  // retorna o nome do usuario corrente
PRIVATE cQuery   := ""
PRIVATE cHTML    := ""  // variavel utilizada para a cria็ใo do e-mail
PRIVATE cEmail   := ALLTRIM(GetMv("MV_RHAPROV")) //
PRIVATE cEmail2  := ALLTRIM(GetMv("MV_RHLOGT"))//
Private lResult  := .T.

APROGPE()

RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraMail   บAutor  ณJULIANA GOMES      บ Data ณ  24/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsavel por enviar o email para solicitar a     บฑฑ
ฑฑบ          ณ aprova็ใo e por gravar o flag que controla se o e-mail foi บฑฑ
ฑฑบ          ณ enviado.                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ REENRC1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static function GeraMail(cAliasRC1)

Local nposRC1    := 0
Local cTitRC1    := ""

(cAliasRC1)->(DbGoTop())
While (cAliasRC1)->(!Eof())

	If !EMPTY((cAliasRC1)->RC1_OK)

		nposRC1:= (cAliasRC1)->RC1_RECNO
		cTitRC1:= (cAliasRC1)->RC1_NUMTIT

		cHtml  := '<html>'
		cHtml  += '<body>'
		cHtml  += '<form action="mailto:%WFMailTo%" method="POST"'
		cHtml  += 'name="FrontPage_Form1">'
		cHtml  += '    <IMG SRC="http://www.viafacil.com.br/images/saopaulo/logoSemPararViafacil.gif">   '
		cHTML  += '<font size="4" face="verdana">'+ UPPER(SM0->M0_NOME) + '-' +UPPER(SM0->M0_FILIAL) +'</font>'
		cHtml  += '    <table border="0" width="933">'
		cHtml  += '        <tr>'
		cHtml  += '            <td width="62">&nbsp;</td>'
		cHtml  += '            <td width="657"><table border="0" width="938"'
		cHtml  += '            height="84">'
		cHtml  += '                <tr>'
		cHtml  += '                    <td colspan="2" width="930" bgcolor="#DFEFFF"'
		cHtml  += '                    height="24"><p align="left"><font size="4"'
		cHtml  += '                    face="verdana"><b>Autorizacao de Pagamento</b>: '+(cAliasRC1)->RC1_NUMTIT+' </font></p>'
		cHtml  += '                    </td>'
		cHtml  += '                </tr>'
		cHtml  += '                <tr>'
		cHtml  += '                    <td valign="top" width="315" height="24"><font size="2" face="verdana"><b>Solicitante</b> : '+cSolicit+' </font></td>'
		cHtml  += '                </tr>'
		cHtml  += '                <tr>'
		cHtml  += '                    <td valign="top" width="315" height="24"><font size="2" face="verdana"><b>Emissao</b> : '  +DtoC(StoD((cAliasRC1)->RC1_EMISSA))+ ' </font></td>'
		cHtml  += '                </tr>'
		cHtml  += '                <tr>'
		cHtml  += '                    <td valign="top" width="500" height="24"><font size="2" face="verdana"><b>Data de Vencimento: </b> : '+DtoC(StoD((cAliasRC1)->RC1_VENREA))+'</font></td>'
		cHtml  += '                </tr>'
		cHtml  += '     </table>'
		cHtml  += '            <p><font color="#0000FF" face="verdana"><b>Titulo</b></font></p>'
		cHtml  += '     <table border="1" width="930" height="85">'
		cHtml  += '                <tr>'
		cHtml  += '                    <td align="left" width="200" bgcolor="#DFEFFF" ><font size="1" face="verdana">Descr.Titulo</font></td>'
		cHtml  += '                    <td align="left" width="60"  bgcolor="#DFEFFF" ><font size="1" face="verdana">Vlr.Titulo</font></td>'
		cHtml  += '                    <td align="left" width="40"  bgcolor="#DFEFFF" ><font size="1" face="verdana">Tipo Titulo</font></td>'
		cHtml  += '                    <td align="left" width="73"  bgcolor="#DFEFFF" ><font size="1" face="verdana">Cod.Natureza</font></td>'
		cHtml  += '                    <td align="left" width="73"  bgcolor="#DFEFFF" ><font size="1" face="verdana">Cod.Fornecedor</font></td>'
		cHtml  += '                </tr>'
		cHtml  += '               <tr>'
		cHtml  += '                    <td align="left"><font size="1" face="verdana">'+(cAliasRC1)->RC1_DESCRI+' </font></td>'
		cHtml  += '                    <td align="left"><font size="1" face="verdana">'+TRANSFORM((cAliasRC1)->RC1_VALOR,"@E 99999999.99") +'  </font></td>'
		cHtml  += '                    <td align="left"><font size="1" face="verdana">'+(cAliasRC1)->RC1_CODTIT+' </font></td>'
		cHtml  += '                    <td align="left"><font size="1" face="verdana">'+(cAliasRC1)->RC1_NATURE+' </font></td>'
		cHtml  += '                    <td align="left"><font size="1" face="verdana">'+(cAliasRC1)->RC1_FORNEC+' </font></td>'
		cHtml  += '                </tr>'
		cHtml  += '   </table>'

		IF (cAliasRC1)->RC1_CODTIT $ "001,002,008,009,015"

			cHtml  += '     <table border="1" width="930" height="85">'
			cHtml  += '                <tr>'
			cHtml  += '                    <td align="left" width="80"  bgcolor="#DFEFFF" ><font size="1" face="verdana">Matricula</font></td>'
			cHtml  += '                    <td align="left" width="300"  bgcolor="#DFEFFF" ><font size="1" face="verdana">Nome</font></td>'
			cHtml  += '                    <td align="left" width="150"  bgcolor="#DFEFFF" ><font size="1" face="verdana">Valor</font></td>'
			cHtml  += '                </tr>'

			DO CASE

				CASE (cAliasRC1)->RC1_CODTIT == "001"
					cQuery := "SELECT SRC.RC_MAT MATRICULA, SRA.RA_NOME NOME, SUM(SRC.RC_VALOR) VALOR"
					cQuery += " FROM "+retsqlname("SRC")+" SRC,"+retsqlname("SRA")+" SRA"
					cQuery += " Where SRA.RA_MAT = SRC.RC_MAT"
					cQuery += " AND SRC.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRA.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRC.RC_PD = '348' "
					cQuery += " GROUP BY SRC.RC_MAT,SRA.RA_NOME "
					cQuery += " ORDER BY SRA.RA_NOME "

				CASE (cAliasRC1)->RC1_CODTIT == "002"
					cQuery := "SELECT SRC.RC_MAT MATRICULA, SRA.RA_NOME NOME, SUM(SRC.RC_VALOR) VALOR"
					cQuery += " FROM "+retsqlname("SRC")+" SRC,"+retsqlname("SRA")+" SRA"
					cQuery += " Where SRA.RA_MAT = SRC.RC_MAT"
					cQuery += " AND SRC.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRA.D_E_L_E_T_<> '*'  "
					cQuery += " AND (SRC.RC_PD = '123' OR SRC.RC_PD = '402') "
					cQuery += " GROUP BY SRC.RC_MAT,SRA.RA_NOME "
					cQuery += " ORDER BY SRA.RA_NOME "

				CASE (cAliasRC1)->RC1_CODTIT == "015"
					cQuery := "SELECT SRC.RC_MAT MATRICULA, SRA.RA_NOME NOME, SUM(SRC.RC_VALOR) VALOR"
					cQuery += " FROM "+retsqlname("SRC")+" SRC,"+retsqlname("SRA")+" SRA"
					cQuery += " Where SRA.RA_MAT = SRC.RC_MAT"
					cQuery += " AND SRC.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRA.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRC.RC_PD = '016' "
					cQuery += " GROUP BY SRC.RC_MAT,SRA.RA_NOME "
					cQuery += " ORDER BY SRA.RA_NOME "

				CASE (cAliasRC1)->RC1_CODTIT == "008"
					cQuery := "SELECT SRC.RC_MAT MATRICULA, SRA.RA_NOME NOME, SUM(SRC.RC_VALOR) VALOR"
					cQuery += " FROM "+retsqlname("SRC")+" SRC,"+retsqlname("SRA")+" SRA"
					cQuery += " Where SRA.RA_MAT = SRC.RC_MAT"
					cQuery += " AND SRC.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRA.D_E_L_E_T_<> '*'  "
					cQuery += " AND (SRC.RC_PD = '405' OR SRC.RC_PD = '794')"
					cQuery += " GROUP BY SRC.RC_MAT,SRA.RA_NOME "
					cQuery += " ORDER BY SRA.RA_NOME "

				CASE (cAliasRC1)->RC1_CODTIT == "009"
					cQuery := "SELECT SRI.RI_MAT MATRICULA, SRA.RA_NOME NOME, SUM(SRI.RI_VALOR) VALOR"
					cQuery += " FROM "+retsqlname("SRI")+" SRI,"+retsqlname("SRA")+" SRA"
					cQuery += " Where SRA.RA_MAT = SRI.RI_MAT"
					cQuery += " AND SRI.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRA.D_E_L_E_T_<> '*'  "
					cQuery += " AND SRI.RI_PD = '711'  "
					cQuery += " GROUP BY SRI.RI_MAT,SRA.RA_NOME "
					cQuery += " ORDER BY SRA.RA_NOME "

			ENDCASE

			If Select("TMP") > 0
				DbSelectArea("TMP")
				DbCloseArea()
			Endif

			TCQUERY cQuery NEW ALIAS "TMP"

			DbSelectArea("TMP")
			DbGoTop()
			DO WHILE TMP->(!Eof())
				cHtml  += '                <tr>'
				cHtml  += '                    <td align="left"><font size="1" face="verdana">'+TMP->MATRICULA+' </font></td>'
				cHtml  += '                    <td align="left"><font size="1" face="verdana">'+TMP->NOME+' </font></td>'
				cHtml  += '                    <td align="left"><font size="1" face="verdana">'+TRANSFORM(TMP->VALOR,"@E 99999999.99")+'</font></td>'
				cHtml  += '                </tr>'
				DBSKIP()
			ENDDO

		ENDIF

		cHtml  += '</form>'
		cHtml  += '</body>'
		cHtml  += '</html>'



		//envia email para o aprovador
		SyEnvMail(cHtml,cEmail,cAliasRC1)

		IF lResult
			DbSelectArea("RC1")
			dbGoto(nposRC1)
			RECLOCK("RC1",.F.)
			RC1->RC1_SOLAP := "SIM"
			MSUNLOCK()
			dbSelectArea(cAliasRC1)
		ENDIF

	Endif
	(cAliasRC1)->(DbSkip())
End

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณSyEnvMail ณ Autor ณ  Rodrigo T. da Silva  ณ Data ณ 31/10/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Envia por e-mail o relatorio                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ EMAILRC1                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function SyEnvMail(cHtml,cEmail,cAliasRC1)

Local cError     := ""
Local cTo        := ""
Local cSubject   := "Autorizacao de Pagto.D.Pessoal: " +Alltrim((cAliasRC1)->RC1_NUMTIT)
Local lAuth      := GetMv("MV_RELAUTH",,.T.)
Local cMailConta := GetMv("MV_RELACNT",,"")
Local cMailServer:= GetMv("MV_RELSERV",,"")
Local cMailSenha := GetMv("MV_RELPSW",,"")
Local cMailAut   := Left(cMailConta, At("@", cMailConta)-1)

cTo:= RTrim(cEmail) + ";protheuslog@semparar.net"
//cTo:=  "juliana.rmo@semparar.net"

If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)
	// Envia e-mail com os dados necessarios
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult

	// Autenticacao da conta de e-mail
	If lResult
		If lAuth
			lResult := MailAuth(cMailConta,cMailSenha)
		EndIf

		If !lResult
			lResult := MailAuth(cMailAut,cMailSenha)
		EndIf

		If lResult
			SEND MAIL  				;
			FROM       cMailConta	;
			TO		   cTo			;
			SUBJECT	   cSubject		;
			BODY	   cHtml		;
			RESULT	   lResult

			If !lResult
				//Erro no Envio do E-Mail.
				GET MAIL ERROR cError
				ConOut(cError)
			EndIf
		Else
			//Erro na autenticacao da conta
			GET MAIL ERROR cError
			ConOut(cError)
		Endif
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		ConOut(cError)
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAPROGPE   บAutor  ณJULIANA GOMES       บ Data ณ  24/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsavel por listar os titulos que podem ser     บฑฑ
ฑฑบ          ณ reenviado o email, sendo  que ele jแ NรO tenha sido        บฑฑ
ฑฑบ          ณ transmitido anteriormente e que nใo tenha sido integrado.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EMAILRC1                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION APROGPE()

Local oDlg
Local oBrowse
Local aCampos 	:= {}
Local aRetQry		:= {}
Local cAliasRC1 	:= "RC1TRB"
Local aSize 		:= FwGetDialogSize(oMainWnd)
Local cTitulo 	:= "Selecione os titulos para aprova็ใo"

aRetQry := FCRIATRB()

oDlg := MsDialog():New(aSize[1]/2, aSize[2]/2, aSize[3]/2, aSize[4]/2, cTitulo,,,,,,,, oMainWnd, .T.)
oBrowse := FwFormBrowse():New()
oBrowse:SetOwner(oDlg)
oBrowse:SetDescription("Solicita็ใo de Aprova็ใo")
oBrowse:AddMarkColumns( {|| If((cAliasRC1)->RC1_OK == 1,"LBOk", "LBNO") },{ |oBrowse| MarkOne(@oBrowse) },{ |oBrowse| MarkAll(@oBrowse) } )
oBrowse:SetDataQuery(.T.)
oBrowse:SetQuery(aRetQry[1])
oBrowse:SetAlias(cAliasRC1)
oBrowse:SetColumns(aRetQry[2])
oBrowse:DisableConfig()
oBrowse:DisableReport()
oBrowse:DisableDetails()
oBrowse:AddButton("Confirmar",{|| GeraMail(cAliasRC1), oDlg:End()},,,,.F.,2)
oBrowse:AddButton("Cancelar",{|| oDlg:End()},,,,.F.,2)
oBrowse:aColumns[1]:bHeaderClick := {|oBrowse| MarkAll(@oBrowse)}
oBrowse:SetDoubleClick({|oBrowse| MarkOne(@oBrowse)})
oBrowse:Activate()


oDlg:Activate( ,,,.T.,,, )

/*
Local nOpca   := 0
Local aCampos := {}
Local oDlg

AADD(aCampos,{"RC1_OK","","  ",""})
AADD(aCampos,{"RC1_NUMTIT","","Titulo","@!"})
AADD(aCampos,{"RC1_DESCRI","","Descricao","@!"})
AADD(aCampos,{"RC1_CODTIT","","Codigo","@!"})
AADD(aCampos,{"RC1_VALOR","","Valor","@E 999,999,999.99"})
AADD(aCampos,{"RC1_EMISSA","","Emissใo",""})
AADD(aCampos,{"RC1_VENCTO","","Vencimento",""})
AADD(aCampos,{"RC1_VENREA","","Vencimento Real",""})
AADD(aCampos,{"RC1_NATURE","","Natureza","@!"})
AADD(aCampos,{"RC1_FORNEC","","Fornecedor","@!"})
AADD(aCampos,{"R_E_C_N_O","","Registro","@E 9999999"})


FCRIATRB()

DEFINE MSDIALOG oDlg TITLE "Selecione os titulos para aprova็ใo"  FROM 9,0 To 28,80 OF oMainWnd
RC1TRB->(Dbgotop())
oMark:=MsSelect():New("RC1TRB","RC1_OK",,aCampos,,cMarca,{02,1,123,316})
oMark:oBrowse:lhasMark := .t.
oMark:oBrowse:lCanAllmark := .t.
oMark:oBrowse:bAllMark := {|| FInverte(cMarca,@oMark)}

DEFINE SBUTTON FROM 126,246.3 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 126,274.4 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	dbSelectArea("RC1TRB")
	dbGoTop()
	While !Eof()
		IF !EMPTY(RC1TRB->RC1_OK)
			GeraMail()
		ENDIF
		dbSelectArea("RC1TRB")
		dbSkip()
	Enddo

Endif

If Select("RC1TRB")>0
	dbSelectArea("RC1TRB")
	dbCloseArea()
Endif
*/

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarkAll   ณCarlos.Ramos                บ Data ณ  29/04/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte e grava a marcacao na mark do browse.               บฑฑ
ฑฑบ          ณOBS. Esta desabilitado no bHeaderClick.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ APROVRC1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarkAll(oObjMark)

Local cMarkRC1 := ''
Local nTipMark := If( lTipMark, 1,0 )

Default oObjMark := Nil

If oObjMark <> Nil
	cMarkRC1 := oObjMark:cAlias

	dbSelectArea(cMarkRC1)
	aAreaRC1 := (cMarkRC1)->( GetArea() )
   (cMarkRC1)->(DbGoTop())
	While (cMarkRC1)->(!EOF())
		RecLock( (cMarkRC1), .F. )
			REPLACE (cMarkRC1)->RC1_OK  WITH IIf( (cMarkRC1)->RC1_OK == 1, 0, 1 )
		MsUnlock()
		(cMarkRC1)->(DbSkip())
	End
	(cMarkRC1)->( DbGotop() )
	RestArea( aAreaRC1 )
	oObjMark:GoBottom()
	oObjMark:GoTop()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarkOne   ณCarlos.Ramos                บ Data ณ  29/04/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao executada ao Marcar/Desmarcar de um registro.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ APROVRC1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarkOne(oObjMark)

Local cMarkRC1 := ''

Default oObjMark := Nil

If oObjMark <> Nil
	cMarkRC1 := oObjMark:cAlias

	If (cMarkRC1)->RC1_OK == 1
		 (cMarkRC1)->RC1_OK := 0
	Else
		 (cMarkRC1)->RC1_OK := 1
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFInverte          ณJuliana Gomes   i   บ Data ณ  24/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte e grava a marcacao na markBrowse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EMAILRC1                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function FInverte(cMarca,oMark)

Local nReg := RC1TRB->(Recno())
dbSelectArea("RC1TRB")
dbGoTop()
While !Eof()
	RecLock("RC1TRB")
	IF RC1_OK == cMarca
		RC1TRB->RC1_OK := "  "
	Else
		RC1TRB->RC1_OK := cMarca
	Endif
	dbSkip()
Enddo
RC1TRB->(dbGoto(nReg))
oMark:oBrowse:Refresh(.t.)

Return Nil

Return
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCRIATRBบAutor  ณJuliana Gomes       บ Data ณ  24/03/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a tabela temporaria e carrega com os registros        บฑฑ
ฑฑบ          ณ da tabela RC1                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EMAILRC1                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FCRIATRB(lSelected)

Local aArea		:= GetArea()
Local aAreaX3		:= ""
Local cQuery 		:= ""
Local nI			:= 0
Local nJ			:= 0
Local aRet			:= {}
Local aCampos		:= {}
Local aColumns	:= {}
Local aNoFields	:= {}

Default lSelected := .F.
//Array com campos para Grid
AADD(aCampos,'RC1_FORNEC')
AADD(aCampos,'RC1_NUMTIT')
AADD(aCampos,'RC1_DESCRI')
AADD(aCampos,'RC1_CODTIT')
AADD(aCampos,'RC1_VALOR')
AADD(aCampos,'RC1_EMISSA')
AADD(aCampos,'RC1_VENCTO')
AADD(aCampos,'RC1_VENREA')
AADD(aCampos,'RC1_NATURE')
//Campo nใo visualizado na Grid
AADD(aNoFields,'RC1_OK')
AADD(aNoFields,'RC1_RECNO')

cQuery := "SELECT "
//Carrega os campos da consulta
For nI := 1 To Len(aCampos)
	If( nI > 1 )
		cQuery += ", "
	Endif
	cQuery += aCampos[nI]
Next nI

If lSelected
	cQuery += ", 1 AS RC1_OK"
Else
	cQuery += ", 0 AS RC1_OK"
Endif
cQuery += ", R_E_C_N_O_ AS RC1_RECNO"
cQuery += " FROM "+RetSqlName("RC1")+" RC1"
cQuery += " WHERE RC1.D_E_L_E_T_ = ' ' "
cQuery += " AND RC1_INTEGR = '0' "
cQuery += " AND RC1_SOLAP <> 'SIM'"

//Cria estrutura da Grid
AADD(aCampos,'RC1_OK')
nJ := 1
For nI := 1 To Len(aCampos)
	If( Ascan(aNoFields, aCampos[nI]) == 0)

		Aadd( aColumns, FWBrwColumn():New() )
		If( aCampos[nI] $( 'RC1_EMISSA|RC1_VENCTO|RC1_VENREA' ) )
			aColumns[nJ]:SetData( &("{||StoD(" +aCampos[nI]+ ")}") )
		Else
			aColumns[nJ]:SetData( &("{||" +aCampos[nI]+ "}") )
		Endif

		dbSelectArea('SX3')
		aAreaX3 := GetArea('SX3')
		SX3->( dbSetOrder(2) )
		SX3->( dbSeek( aCampos[nI] ) )
		aColumns[nJ]:SetTitle(Alltrim(X3titulo(aCampos[nI])))
		aColumns[nJ]:SetSize(TamSx3(aCampos[nI])[1])
		aColumns[nJ]:SetDecimal(TamSx3(aCampos[nI])[2])
		aColumns[nJ]:SetPicture(Alltrim(X3Picture(aCampos[nI])))

		nJ++
	Endif
	RestArea(aAreaX3)
Next nI

Aadd( aRet, cQuery )
Aadd( aRet, aColumns )

RestArea( aArea )


/*
Local aCampos := {}
AADD(aCampos,{"RC1_OK","C",2,0})
AADD(aCampos,{"RC1_NUMTIT","C",9,0})
AADD(aCampos,{"RC1_DESCRI","C",30,0})
AADD(aCampos,{"RC1_CODTIT","C",3,0})
AADD(aCampos,{"RC1_VALOR","N",17,2})
AADD(aCampos,{"RC1_EMISSA","D",8,0})
AADD(aCampos,{"RC1_VENCTO","D",8,0})
AADD(aCampos,{"RC1_VENREA","D",8,0})
AADD(aCampos,{"RC1_NATURE","C",10,0})
AADD(aCampos,{"RC1_FORNEC","C",9,0})
AADD(aCampos,{"R_E_C_N_O","N",7,0})


If Select("RC1TRB")>0
	dbSelectArea("RC1TRB")
	dbCloseArea()
Endif

Dbselectarea("RC1")
cAlias := "RC1TRB"
cIndex := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cIndex,cAlias,.F.)
DbselectArea("RC1")
dbGoTop()
Do While !RC1->(Eof())
	IF RC1->RC1_INTEGR == "0" .AND. RC1->RC1_SOLAP # "SIM"
		RecLock("RC1TRB",.T.)
		RC1TRB->RC1_NUMTIT    := RC1->RC1_NUMTIT
		RC1TRB->RC1_DESCRI    := RC1->RC1_DESCRI
		RC1TRB->RC1_CODTIT    := RC1->RC1_CODTIT
		RC1TRB->RC1_VALOR     := RC1->RC1_VALOR
		RC1TRB->RC1_EMISSA    := RC1->RC1_EMISSA
		RC1TRB->RC1_VENCTO    := RC1->RC1_VENCTO
		RC1TRB->RC1_VENREA    := RC1->RC1_VENREA
		RC1TRB->RC1_NATURE    := RC1->RC1_NATURE
		RC1TRB->RC1_FORNEC    := RC1->RC1_FORNEC
		RC1TRB->R_E_C_N_O     := RC1->(Recno())

	ENDIF

	MsUnLock()
	RC1->(dbskip())
Enddo
#IFNDEF TOP
	dbSelectArea("RC1")
	dbClearFil()
	RetIndex( "RC1" )
	If !Empty(cIndex)
		FErase (cIndex+OrdBagExt())
	Endif
	dbSetOrder(1)
#ELSE
	if TcSrvType() != "AS/400"
		dbSelectArea("RC1")
		dbCloseArea()
		ChKFile("RC1")
		dbSelectArea("RC1")
		dbSetOrder(1)
	else
		dbSelectArea("RC1")
		dbClearFil()
		RetIndex( "RC1" )
		If !Empty(cIndex)
			FErase (cIndex+OrdBagExt())
		Endif
		dbSetOrder(1)
	endif
#ENDIF
*/

Return aRet