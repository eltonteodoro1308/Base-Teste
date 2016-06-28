



#Include "TOTVS.ch"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "jpeg.ch"                                 
#INCLUDE "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpPLCT2  บAutor  ณDgomes/Spsantos     บ Data ณ  02/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para importacao da planilha da Provisใo PL.       บฑฑ
ฑฑบ          ณ implementa a tabela CT2 para  imputar os dados na tabela   บฑฑ                                     
ฑฑบ          ณ CT2010                                                     บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa PL - CT2010 - MODULO CONTABIL GERENCIAL            บฑฑ
ฑฑบ          ณ U_ImpPLCT2()                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ    
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

User function IMP_CT2() // Para chamada via formulas
          
	U_ImpPLCT2() 

Return Nil                       

User Function ImpPLCT2()                                         

DEFINE FONT _oFnt1 NAME "Times New Roman" Size 08,18 BOLD                          
DEFINE FONT _oFnt2 NAME "Times New Roman" Size 08,18 
DEFINE FONT _oFnt3 NAME "Arial" Size 07,16 BOLD
 
Private o1 := LoadBitmap(GetResources(),'br_verde')
Private o2 := LoadBitmap(GetResources(),'br_vermelho')
Private o3 := LoadBitmap(GetResources(),'br_branco')
Private o4 := LoadBitmap(GetResources(),'br_preto')
private oListA           
private aListA 		:= {}
private aListAuxA 	:= {}
private aObj 		:= {}
Private  nTLinhas 	:= 0  
Private lExtErro	:= .f.
Private lCorrErro	:= .T.
Private nExtErro	:= 0
Private cPL			:= chr(13)+chr(10)	

Private aRegistro	:= {}  
Private aCabec		:= {}
Private nTotal		:= 0
Private aButtons := {}                                          
Private oImgEx  ,oButton           
Private oLeE		:= TDialog():New(200,001,480,380,'Importa็ใo Excel para CT2 ',,,,,CLR_WHITE,CLR_WHITE,,,.T.)          
Private oMeter,oBtn1,oBtn2,oBtn3,nMeter:=0
Private cArquivo 	:= Space(130)     
Private nTam		:= 200
Private cTela       := Space(130) 
//Private cType       := " Todos os arquivos | *.csv"            
Private nTela       := 1
Private nRecIni     := 0
Private nExErro		:= 0  
   
lAborta := .F.
oMeter:= tMeter():New(83,10,{|u|if(Pcount()> 0,nMeter:=u,nMeter)},nTam,oLeE,170,08,,.T.) // Cria a regua

@ 002,010 	TO 068,095
@ 002,010  	TO 068,180

Img1(nTela)		//Carrega a primeira imangem.

@ 010,018 	Say " Leitura de Arquivo " COLOR CLR_BLUE OBJECT _oSay;			_oSay:SetFont(_oFnt1)
@ 025,018 	Say " Importa็ใo Excel " COLOR CLR_BLUE OBJECT _oSay;		_oSay:SetFont(_oFnt1)
@ 040,018 	Say " para o Contแbil  " COLOR CLR_BLUE OBJECT _oSay;		_oSay:SetFont(_oFnt1)
@ 100,010 	Say " Informe abaixo, onde se encontra o arquivo a importar " COLOR CLR_RED OBJECT _oSay; _oSay:SetFont(_oFnt3)
@ 112,010 	Say " Caminho: " COLOR CLR_BLUE OBJECT _oSay;					_oSay:SetFont(_oFnt2)
@ 110,050 	Get cArquivo Size 130,15  
@ 125,091 	BMPBUTTON TYPE 14 ACTION ArqEx()
@ 125,121 	BMPBUTTON TYPE 01 ACTION (oLeE:end(),Process(oMeter))
@ 125,151	BMPBUTTON TYPE 02 ACTION CLOSE(oLeE)

	oLeE:Refresh()
  	oLeE:Activate(,,,.T.,,,)

Return Nil  

Static Function Img1(nTela)

oImgEx:= TBITMAP():Create(oLeE)			          	// Cria Imagem da MSdialog
oImgEx:cName 		:= "oImgEx"
oImgEx:cCaption 	:= "oImgEx"
	If nTela == 1                                   // Imagem do Excel
		oImgEx:nLeft 		:= 210                	// Coluna
		oImgEx:nTop 		:= 010                	// Linha
		oImgEx:nWidth 		:= 125   			  	// Largura
		oImgEx:nHeight 		:= 115                	// Altura
		oImgEx:lShowHint 	:= .F.
		oImgEx:lReadOnly 	:= .F.
		oImgEx:Align 		:= 0
		oImgEx:lVisibleControl := .T.
		oImgEx:cBmpFile 	:= "Excel.bmp"	
	Else	                                        // Imagem do Microsiga
		oImgEx:nLeft 		:= 190              	// Coluna
		oImgEx:nTop 		:= 005              	// Linha
		oImgEx:nWidth 		:= 170    				// Largura
		oImgEx:nHeight 		:= 130              	// Altura
		oImgEx:lShowHint 	:= .F.
		oImgEx:lReadOnly 	:= .F.
		oImgEx:Align 		:= 0
		oImgEx:lVisibleControl := .T.
		oImgEx:cBmpFile 	:= "Msiga.bmp"		
	Endif
oImgEx:lStretch 	:= .T.
oImgEx:lAutoSize 	:= .F.

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArqEx     บAutor  ณDgomes/spsantos     บ Data ณ  15/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao auxiliar que Coleta o arquivo em EXCEL              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณImporta PL - CT2010 - MODULO CONTABIL GERENCIAL             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ArqEx()

Private cType    := " Todos os arquivos | *.csv"
Private cPath    := '' 
		cArquivo := cGetFile(cType, "Selecione o arquivo a Importar ",0,cPath, .F.,)                 
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma    Process  บAutor  ณDgomes / spsantos   บ Data ณ  02/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao auxiliar que processa o arquivo  EXCEL              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณImporta PL  - CT2010 - MODULO CONTABILIDADE GERENCIAL       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function Process(oMeter)

Private nTamFile, nTamLin, cBuffer, nBtLidos  
Private cArqTxt 	:= Alltrim(cArquivo) 
Private nHdl    	:= fOpen(cArqTxt,68)
Private cEOL    	:= "CHR(13)+CHR(10)"
Private cTab    	:= ""
Private cObs        := ""
Private cRec		:= ''
Private cCodigo     := ""
Private cInSert		:= ''
Private cQZAK		:= ""
Private cString		:= "CT2"
Private nRecno		:= 0
Private nPosicao 	:= 1  
Private nPosicaoC   := 1
Private nTcampo		:= 0
Private nCont	    := 1
Private nPos		:= 1    
Private nQtdProc    := 0 
Private nQtdProcI   := 1
Private cLinha	         
Private cLote       := ""                                 
Private cDtIni		:= ""
Private cDtFim		:= ""
Private cDtI		:= ""
Private cDtF		:= ""
Private nLoc   		:= 0                                                    
Private cUsuario    := cUserName
Private cCabec      := ""   
Private cProcess    := ""   
Private lAchouEntrada := .F.
 nLastKey        := 0   
 
	cNomeArq 	:= SubStr(cArqTxt,4,At(".",SubStr(cArqTxt,4,Len(cArqTxt)))-1) // Usado para evitar o reprocessamento do arquivo.		
	
	If Vazio(cArquivo)
	   MsgAlert("Nenhum arquivo foi selecionado! ","Aten็ใo")
	   Return 
	Endif
	
	If Empty(cEOL)
    	cEOL := CHR(13)+CHR(10)
	Else
    	cEOL := Trim(cEOL); cEOL := &cEOL
	Endif

nTamFile 	:= fSeek(nHdl,0,0)
fSeek(nHdl,0,0)
nTamLin  	:= 550000                         	// Tamanho maximo previsto para a planilha
cBuffer 	:= Space(nTamLin) 					// Variavel para criacao da linha do registro para leitura
nBtLidos 	:= fRead(nHdl,@cBuffer,nTamLin) 	// Leitura da proxima linha do arquivo texto
    
		cArquivo  	:= SubStr(cBuffer,nposicao,Len(cBuffer))
		cArquivo	:= Replace(cArquivo, Space(02), Space(0))
    	cProcess 	:=  Alltrim(SubStr(cArquivo,len(cArquivo)-10,11))
 	
 	If  SubStr(cBuffer,1,10) == "PROCESSADO" 	// Verifica se o arquivo foi precessado anteriormente
    	MsgInfo("O arquivo que estแ sendo importado jแ foi processado anteriormente","Aten็ใo")   
    	 oLeE:End() 	 
		Return Nil
	Endif  
	        
 		oMeter:Set(0) 
        	Sleep(100) 							// 100 para 1 segundo de atraso na regua de processamento  
	  		ProcessMessages() 					// Atualiza a janela
			cTela := "  Lendo arquivo...   Aguarde" 
			@ 110,050 	Get cTela Size 130,08 PIXEL  OF oLeE  
			oLeE:Refresh()
			nCurrent:= Eval(oMeter:bSetGet) 	// Pega valor atual da regua   
        	nCurrent+=170						// Vai implemantar a regua de processamento  
		oMeter:Set(nCurrent) 

        	cBkpArq    	:= SubStr(cBuffer,nposicao,Len(cBuffer))// Variavel criada para salvar uma copia do arquivo texto
			cArquivo	:= SubStr(cBuffer,nposicao,Len(cBuffer))	
 	  //	cArquivo    := cBuffer
  	 		cArquivo	:= StrTran(cArquivo,'cTab' , "")  
	   	// 	cArquivo	:= StrTran(cArquivo,'	', ";")//Transforma a Tabulacao em uma marca para posicionamento 
   		//	cLinha 		:= 'PROCESSADO'
   			cLinha 		:= ''
 
		fWrite(nHdl,cLinha,10)  
 		fClose(nHdl)
        
  For _nA := 1 to 44    						// Separa o cabecalho do restante do texto  
	    Aadd( aCabec, { SubStr(cArquivo,nPosicao,AT(";",Substr(cArquivo,nPosicao,len(cArquivo)))-1), "C",100,0} )           
  		nPosicao := nPosicao + Len(SubStr(cArquivo,nPosicao, AT(";",Substr(cArquivo,nPosicao,len(cArquivo)))-1))+1
  Next _nA   
  
  	For _nQ := 1 to len(aCabec)
      If cCabec == ""  
         cCabec := aCabec[_nQ,1]
      Else    
     	 cCabec := cCabec + ','+aCabec[_nQ,1] 
      Endif
    Next _nQ
      
  	cProcess := Alltrim( SubStr(cArquivo,len(cArquivo)-10,11))
       
		    For _nY := 1 to len(cArquivo)  																			
		       
		            // nTcampo = Tamanho do Campo na Tabela
		        	If 	   nCont ==  1; nTcampo := 002	// CT2_FILIAL
		        	ElseIf nCont ==  2; nTcampo := 008  // CT2_DATA
		        	ElseIf nCont ==  3; nTcampo := 006  // CT2_LOTE   
		        	ElseIf nCont ==  4; nTcampo := 003  // CT2_SBLOTE        
					ElseIf nCont ==  5; nTcampo := 006  // CT2_DOC
					ElseIf nCont ==  6; nTcampo := 003  // CT2_LINHA
			        ElseIf nCont ==  7; nTcampo := 002  // CT2_MOEDLC
			    	ElseIf nCont ==  8; nTcampo := 001  // CT2_DC
			    	ElseIf nCont ==  9; nTcampo := 020  // CT2_DEBITO
			    	ElseIf nCont == 10; nTcampo := 020  // CT2_CREDIT 
			    	ElseIf nCont == 11; nTcampo := 001  // CT2_DCD  
			     	ElseIf nCont == 12; nTcampo := 001  // CT2_DCC
			    	ElseIf nCont == 13; nTcampo := 008  // CT2_VALOR   
			    	ElseIf nCont == 14; nTcampo := 005  // CT2_MOEDAS
			    	ElseIf nCont == 15; nTcampo := 003  // CT2_HP      
			    	ElseIf nCont == 16; nTcampo := 040  // CT2_HIST 
			    	ElseIf nCont == 17; nTcampo := 009  // CT2_CCD   
		    		ElseIf nCont == 18; nTcampo := 009  // CT2_CCC
	    			ElseIf nCont == 19; nTcampo := 009  // CT2_ITEMD
    				ElseIf nCont == 20; nTcampo := 009  // CT2_ITEMC
   					ElseIf nCont == 21; nTcampo := 009  // CT2_CLVLDB  
					ElseIf nCont == 22; nTcampo := 009  // CT2_CLVLCR
		    		ElseIf nCont == 23; nTcampo := 040  // CT2_ATIVDE
		    		ElseIf nCont == 24; nTcampo := 040  // CT2_ATIVCR
			    	ElseIf nCont == 25; nTcampo := 002  // CT2_EMPORI
		        	ElseIf nCont == 26; nTcampo := 002  // CT2_FILORI
		  	    	ElseIf nCont == 27; nTcampo := 001  // CT2_INTERC
		     		ElseIf nCont == 28; nTcampo := 050  // CT2_IDENTC
			        ElseIf nCont == 29; nTcampo := 001  // CT2_TPSALD
			    	ElseIf nCont == 30; nTcampo := 010  // CT2_SEQUEN
			    	ElseIf nCont == 31; nTcampo := 001  // CT2_MANUAL 
			    	ElseIf nCont == 32; nTcampo := 100  // CT2_ORIGEM   
			    	ElseIf nCont == 33; nTcampo := 010  // CT2_ROTINA
			    	ElseIf nCont == 34; nTcampo := 001  // CT2_AGLUT  
			    	ElseIf nCont == 35; nTcampo := 003  // CT2_LP
			    	ElseIf nCont == 36; nTcampo := 003  // CT2_SEQHIS
			    	ElseIf nCont == 37; nTcampo := 003  // CT2_SEQLAN  
			    	ElseIf nCont == 38; nTcampo := 008  // CT2_TAXA
			    	ElseIf nCont == 39; nTcampo := 008  // CT2_VLR01    
			    	ElseIf nCont == 40; nTcampo := 008  // CT2_VLR02     
			    	ElseIf nCont == 41; nTcampo := 008  // CT2_VLR03 
			    	ElseIf nCont == 42; nTcampo := 008  // CT2_VLR04
			    	ElseIf nCont == 43; nTcampo := 008  // CT2_VLR05
			    	ElseIf nCont == 44; nTcampo := 001  // CT2_CRCONV
			       	Else 
			       		nTcampo := 020 
			       	Endif  
			    	
		 	   		Aadd( aRegistro, { SubStr(cCabec,nPosicaoC, AT(";",Substr(cCabec,nPosicaoC,len(cCabec)))-1),SubStr(cArquivo,nPosicao,AT(";",Substr(cArquivo,nPosicao,len(cArquivo)))-1), "C", nTcampo ,0} )           
		  			nPosicao := nPosicao + Len(SubStr(cArquivo,nPosicao, AT(";",Substr(cArquivo,nPosicao,len(cArquivo)))-1))+1
		            nPosicaoC := nPosicaoC + Len(SubStr(cCabec,nPosicaoC, AT(";",Substr(cCabec,nPosicaoC,len(cCabec)))-1))+1 
		            
				          If nCont == 2	//If nCont == 1	
		    			    If Vazio(aRegistro[_nY][2])// .and. nPosicao == len(cArquivo)-10
		    				Exit
		    		     	Endif
		    	          Endif
					   
					   	nCont++ 
		        	If nCont == 45  
		        	    nPosicaoC := 1
		    			nCont  := 1
		    		 	nTotal++        				// Definira o total de registros lidos no arquivo texto
		      		Endif
		   	Next _nY                
           	    
    Cria_tela()	  // Interface de validacao dos dados         
    
Return Nil 
      	    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_tela บAutor  ณdgomes              บ Data ณ  19/05/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Interface de validacao dos dados      			          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cria_tela()
       
DEFINE DIALOG oDlgVerif TITLE " Painel de validacao - dados provisใo da folha - Scopus "  COLOR CLR_BLUE FROM  000, 000 TO  562, 1295 PIXEL  
  
oBtn2 := TBtnBmp2():New( 02,02,26,26,'CANCEL'	,,,,{|| Close(oDlgVerif)},oDlgVerif,,,.T. )
@ 05,015 SAY "Fechar"  COLOR CLR_RED FONT _oFnt1 SIZE 1026,015 PIXEL OF oDlgVerif  
oBtn1 := TBtnBmp2():New( 02,080,26,26,'OK'		,,,,{|| GravaTudo()},oDlgVerif,,,.T. )
@ 05,055 SAY "Importar"  COLOR CLR_GREEN FONT _oFnt1 SIZE 1026,015 PIXEL OF oDlgVerif                                                                                     
                             
	Estrutura()	// Cria a estrutura da tela
	
ACTIVATE DIALOG oDlgVerif Centered       

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEstrutura บAutor  ณdgomes              บ Data ณ  19/05/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Interface de validacao dos dados      			          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Static Function Estrutura()
 
Local _nV	 	:= 0 
Local nPonto 	:= 0
Local cVal		:= ""
Local nDiverg	:= 0 
Local _DtInclu, _DtIniCR, _DtFimCR, _TipoConta	
Local cQex		:= ""   
Local ldg		:= .t.

Private nValDebi  	:= 0  	// total de linhas de Debito
Private nValCred 	:= 0	// total de linhas de Credito

oPanelMed := tPanel():New(245,005,, oDlgVerif,,,,, CLR_WHITE, 630, 010, .T.) 			// Informacoes no Rodape  
_nColun := 002

	For _nT := 1 to 12 
		Aadd( aObj	,{ SetPrvt('oSay' + Alltrim(Str(_nT)))  }) 						// Objeto que receberam os valores na tela (Rodape)
	    aObj[ _nT ,1] := tSay():New( 002, _nColun, {|| "." }, oPanelMed,,_oFnt2,,,,.T.,CLR_BLUE,CLR_BLACK,200, 15)		     
			If _nT == 1      
				_nColun := (_nColun + 20 )
			Else 
				_nColun := (_nColun + 65 )		
			Endif	  
	Next _nT 

aListAuxA := {	Space(1)  , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),; // 10
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(1) } 
		
aadd(aListA, aListAuxA)   
oListA := TCBrowse():New( 018 , 005, 640, 210 ,,;
						{'','CT2_FILIAL','CT2_DATA'	 ,'CT2_LOTE'  ,'CT2_SBLOTE','CT2_DOC'    ,'CT2_LINHA' ,'CT2_MOEDLC','CT2_DC',;
							'CT2_DEBITO','CT2_CREDIT','CT2_DCD'   ,'CT2_DCC'   ,'CT2_VALOR'  ,'CT2_MOEDAS','CT2_HP'    ,'CT2_HIST',;
							'CT2_CCD'	,'CT2_CCC'   ,'CT2_ITEMD' ,'CT2_ITEMC' ,'CT2_CLVLDB' ,'CT2_CLVLCR','CT2_ATIVDE','CT2_ATIVCR',;
							'CT2_EMPORI','CT2_FILORI','CT2_INTERC','CT2_IDENTC','CT2_TPSALD' ,'CT2_SEQUEN','CT2_MANUAL',;
							'CT2_ORIGEM','CT2_ROTINA','CT2_AGLUT' ,'CT2_LP'    ,'CT2_SEQHIS' ,'CT2_SEQLAN','CT2_TAXA'  ,'CT2_VLR01',;
							'CT2_VLR02' ,'CT2_VLR03' ,'CT2_VLR04' ,'CT2_VLR05' ,'CT2_CRCONV' ,'Erro' },;
							{30,30,30,30}, oDlgVerif,,,,{|| aObj[10,1]:SetText("Linha atual: " + Alltrim(Str(oListA:nAT)) ) }  ,;
							{||},,_oFnt2,,,,,.F.,,.T.,,.F.,,, )
oListA:SetArray(aListA)  
oListA:bLine := {|| { 	 aListA[oListA:nAT,01], aListA[oListA:nAT,02], aListA[oListA:nAT,03], aListA[oListA:nAT,04],;
						 aListA[oListA:nAT,05], aListA[oListA:nAT,06], aListA[oListA:nAT,07], aListA[oListA:nAT,08],;
						 aListA[oListA:nAT,09], aListA[oListA:nAT,10], aListA[oListA:nAT,11], aListA[oListA:nAT,12],;
						 aListA[oListA:nAT,13], aListA[oListA:nAT,14], aListA[oListA:nAT,15], aListA[oListA:nAT,16],;
						 aListA[oListA:nAT,17], aListA[oListA:nAT,18], aListA[oListA:nAT,19], aListA[oListA:nAT,20],;
						 aListA[oListA:nAT,21], aListA[oListA:nAT,22], aListA[oListA:nAT,23], aListA[oListA:nAT,24],;
						 aListA[oListA:nAT,25], aListA[oListA:nAT,26], aListA[oListA:nAT,27], aListA[oListA:nAT,28],;
						 aListA[oListA:nAT,29], aListA[oListA:nAT,30], aListA[oListA:nAT,31], aListA[oListA:nAT,32],;
						 aListA[oListA:nAT,33], aListA[oListA:nAT,34], aListA[oListA:nAT,35], aListA[oListA:nAT,36],;                                                                                                
						 aListA[oListA:nAT,37], aListA[oListA:nAT,38], aListA[oListA:nAT,39], aListA[oListA:nAT,40],;                                                                                                						
						 aListA[oListA:nAT,41], aListA[oListA:nAT,42], aListA[oListA:nAT,43], aListA[oListA:nAT,44],;
						 aListA[oListA:nAT,45], aListA[oListA:nAT,46]}}  
						 
 oListA:bLDblClick :=  { ||  AjustaCampo() }  // Foi solicitado pela analista Camila que nenhum campo fosse alterado via tela. 
 
aListA := {}
_nY := 0
      
   	If Val(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_EMPORI"}),2]) != Val(cEmpAnt) // valida empresa do arquivo
		Alert("Empresa divergente do arquivo, a import็ใo serแ cancelada! Verifique a coluna CT2_EMPORI")	
		aListAuxA := {	Space(1)  , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),; // 10
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(1) } 
				aadd(aListA, aListAuxA) 
				oListA:SetArray(aListA)  
				oListA:bLine := {|| { 	  aListA[oListA:nAT,01], aListA[oListA:nAT,02], aListA[oListA:nAT,03], aListA[oListA:nAT,04],;
						  aListA[oListA:nAT,05], aListA[oListA:nAT,06], aListA[oListA:nAT,07], aListA[oListA:nAT,08],;
						  aListA[oListA:nAT,09], aListA[oListA:nAT,10], aListA[oListA:nAT,11], aListA[oListA:nAT,12],;
						  aListA[oListA:nAT,13], aListA[oListA:nAT,14], aListA[oListA:nAT,15], aListA[oListA:nAT,16],;
						  aListA[oListA:nAT,17], aListA[oListA:nAT,18], aListA[oListA:nAT,19], aListA[oListA:nAT,20],;
						  aListA[oListA:nAT,21], aListA[oListA:nAT,22], aListA[oListA:nAT,23], aListA[oListA:nAT,24],;
						  aListA[oListA:nAT,25], aListA[oListA:nAT,26], aListA[oListA:nAT,27], aListA[oListA:nAT,28],;
						  aListA[oListA:nAT,29], aListA[oListA:nAT,30], aListA[oListA:nAT,31], aListA[oListA:nAT,32],;
						  aListA[oListA:nAT,33], aListA[oListA:nAT,34], aListA[oListA:nAT,35], aListA[oListA:nAT,36],;                                                                                                
						  aListA[oListA:nAT,37], aListA[oListA:nAT,38], aListA[oListA:nAT,39], aListA[oListA:nAT,40],;                                                                                                						
						  aListA[oListA:nAT,41], aListA[oListA:nAT,42], aListA[oListA:nAT,43], aListA[oListA:nAT,44],;
						  aListA[oListA:nAT,45], aListA[oListA:nAT,46]	}} 
			Return Nil
	Else
		cQex := "Select count(*) [ACH] FROM " + RetSQlName("CT2")+ " (NOLOCK) "
		cQex += " 	WHERE CT2_FILIAL = '"+ xFilial("CT2")+"' "
		cQex += " 	And CT2_DATA 	= '"+ PadL(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DATA"}),2]),  TamSx3("CT2_DATA")  [1],"0") +"'"
		cQex += " 	And CT2_LOTE 	= '"+ PadL(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_LOTE"}),2]),  TamSx3("CT2_LOTE")  [1],"0") +"'"  			
		cQex += " 	And CT2_SBLOTE 	= '"+ PadL(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_SBLOTE"}),2]),TamSx3("CT2_SBLOTE")[1],"0") +"'"
		cQex += " 	And D_E_L_E_T_ = '' "
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQex),"Ext",.t.,.t.)	
		Ext->(DbGotop())
			If Ext->ACH > 0 .and. ldg 
				Alert("Esse Lote e SubLote jแ existe na base para essa data, a importa็ใo nใo serแ executada!")		
				Ext->(DbCloseArea())
					
				aListAuxA := {	Space(1)  , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),; // 10
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(15) , Space(15), Space(15), Space(15), Space(15),;
				Space(15) , Space(15), Space(15), Space(15), Space(15), Space(1) } 
				aadd(aListA, aListAuxA) 
				oListA:SetArray(aListA)  
				oListA:bLine := {|| { 	  aListA[oListA:nAT,01], aListA[oListA:nAT,02], aListA[oListA:nAT,03], aListA[oListA:nAT,04],;
						  aListA[oListA:nAT,05], aListA[oListA:nAT,06], aListA[oListA:nAT,07], aListA[oListA:nAT,08],;
						  aListA[oListA:nAT,09], aListA[oListA:nAT,10], aListA[oListA:nAT,11], aListA[oListA:nAT,12],;
						  aListA[oListA:nAT,13], aListA[oListA:nAT,14], aListA[oListA:nAT,15], aListA[oListA:nAT,16],;
						  aListA[oListA:nAT,17], aListA[oListA:nAT,18], aListA[oListA:nAT,19], aListA[oListA:nAT,20],;
						  aListA[oListA:nAT,21], aListA[oListA:nAT,22], aListA[oListA:nAT,23], aListA[oListA:nAT,24],;
						  aListA[oListA:nAT,25], aListA[oListA:nAT,26], aListA[oListA:nAT,27], aListA[oListA:nAT,28],;
						  aListA[oListA:nAT,29], aListA[oListA:nAT,30], aListA[oListA:nAT,31], aListA[oListA:nAT,32],;
						  aListA[oListA:nAT,33], aListA[oListA:nAT,34], aListA[oListA:nAT,35], aListA[oListA:nAT,36],;                                                                                                
						  aListA[oListA:nAT,37], aListA[oListA:nAT,38], aListA[oListA:nAT,39], aListA[oListA:nAT,40],;                                                                                                						
						  aListA[oListA:nAT,41], aListA[oListA:nAT,42], aListA[oListA:nAT,43], aListA[oListA:nAT,44],;
						  aListA[oListA:nAT,45], aListA[oListA:nAT,46]	}} 
				Return Nil
			Endif	
		Ext->(DbCloseArea())
		
	Endif      
          
	For _nS := 1 to nTotal  
        
       	aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_LINHA"}),2] := Padl(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_LINHA"}),2],3,'0')
              
       	If 	Len(Alltrim(aRegistro[_nY +aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DATA"}) ,2])) != 8
			lExtErro := .t.
			nExtErro++
			aRegistro[_nY +  1 ,2] := "Data invแlida!"
        Else
        	_DtInclu := Alltrim(aRegistro[_nY +aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DATA"}) ,2])
        Endif                                       
        
        If !Vazio(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2])) 
				If !aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] $ '1|2|3'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Campo CT2_DC deve ser 1,2 ou 3 "
				Else
					Do Case                        
						// ============= Credito ======================================================================================================
						Case aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '1' 
								If!	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01))  ))
									lExtErro := .t.		
									nDiverg++ 
									aRegistro[_nY +  1 ,2] := "Conta invแlida!"
								Else
									If Posicione('CT1',1,xFilial('CT1')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01)),'CT1_BLOQ') == '1'
										lExtErro := .t.		
										nDiverg++ 
										aRegistro[_nY +  1 ,2] := "Conta bloqueada!"				   
									Else
										If !Vazio(PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01))) 
											lExtErro := .t.		
											nDiverg++ 
											aRegistro[_nY +  1 ,2] := "Lan็amento de Debito conta credito deve ser vazia"				   										
										Endif										
									Endif	
				   				Endif 
				   								   				
						// =============== Debito ======================================================================================================	
						Case aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '2'
							If!	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01))  ))
								lExtErro := .t.		
								nDiverg++
								aRegistro[_nY +  1 ,2] := "Conta invแlida!" 
							Else
								If Posicione('CT1',1,xFilial('CT1')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01)),'CT1_BLOQ') == '1'
									lExtErro := .t.		
									nDiverg++ 
									aRegistro[_nY +  1 ,2] := "Conta bloqueada!"				   
						   		Else
									If !Vazio(PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01))) 
										lExtErro := .t.		
										nDiverg++ 
										aRegistro[_nY +  1 ,2] := "Lan็amento de Credito conta debito deve ser vazia"				   										
									Endif
							   	Endif	
							Endif	
						// ================ Partida dobrada =============================================================================================
						Case aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '3'
								
								If!	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01))  ))
									lExtErro := .t.		
									nDiverg++ 
									aRegistro[_nY +  1 ,2] := "Conta invแlida!"
								Else
									If Posicione('CT1',1,xFilial('CT1')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01)),'CT1_BLOQ') == '1'
										lExtErro := .t.		
										nDiverg++ 
										aRegistro[_nY +  1 ,2] := "Conta bloqueada!"				   
									Endif	
				   				Endif
							
								If!	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01))  ))
									lExtErro := .t.		
									nDiverg++
									aRegistro[_nY +  1 ,2] := "Conta invแlida!" 
								Else
									If Posicione('CT1',1,xFilial('CT1')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]), TamSx3("CT1_CONTA")[1] ,Space(01)),'CT1_BLOQ') == '1'
										lExtErro := .t.		
										nDiverg++ 
										aRegistro[_nY +  1 ,2] := "Conta bloqueada!"				   
							   		Endif	
								Endif	            
						// ================ Qualquer outro dado ============================================================================================
						OtherWise
							lExtErro := .t.		
							nDiverg++ 
							aRegistro[_nY +  1 ,2] := "Campo CT2_DC invแlido!"
					End Do 
				Endif
		Endif
        
			// Custo Debito ================================================================================================
			If !Vazio(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCD"}),2]))
				If!	CTT->(dbSeek(xFilial("CTT")+ PadR(Alltrim(aRegistro[_nY +aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCD"}),2]), TamSx3("CTT_CUSTO")[1] ,Space(01) )  ))
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Custo invแlido!"
				Else
					_DtIniCR := Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCD"}),2]),TamSx3("CTT_CUSTO")[1],Space(01)) ,'CTT_DTEXIS') 	// data inicio do CR
					_DtFimCR := Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCD"}),2]),TamSx3("CTT_CUSTO")[1],Space(01)) ,'CTT_DTEXSF')	// data final do CR
				    
				  	If( !Vazio(_DtFimCR) .and. !Vazio(_DtIniCR) )  // se existir data para o CR 
				  		If StoD(_DtInclu) < _DtIniCR .or. StoD(_DtInclu) > _DtFimCR
				  			lExtErro := .t.		
							nDiverg++ 
							aRegistro[_nY +  1 ,2] := "Data Custo invแlida!"	
						Endif
					Endif
					/* Para as contas que iniciam com 5 ou 6 obrigatoriamente precisam do centro de custo diferente de 1 ou 9999999 - Camila */
					If Left(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]),1) $ "5|6" .and.;
					  	Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCD"}),2]) $  ALLTRIM(GETMV("SC_VALCC"))
						lExtErro := .t.		
						nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Custo+conta invแlido!"					
				    Else
				      	If Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCD"}) ,2]), TamSx3("CTT_CUSTO")[1] ,Space(01) ),'CTT_BLOQ') == '1'
				      		lExtErro := .t.		
							nDiverg++ 
							aRegistro[_nY +  1 ,2] := "Custo bloqueado!"
				      	Endif
				    Endif
				
					_TipoConta := Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCD"}),2]),TamSx3("CTT_CUSTO")[1],Space(01)) ,'CTT_NORMAL') 
					
					If (Left(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]),1) == '5' .and. _TipoConta == '1').or.;
					   (Left(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DEBITO"}),2]),1) == '6' .and. _TipoConta == '2')   
						lExtErro := .t.		
						nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Custo nใo compatํvel!"				    
					Endif   
				Endif
			
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '2'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Custo Debito deve ser vazio!"
				Endif
			
			Else
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}) ,2] $ '1|3'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Custo vazio!"
				Endif
			Endif    
			
			
			// Custo Credito ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCC"}) ,2]))
				If!	CTT->(dbSeek(xFilial("CTT")+ PadR(Alltrim(aRegistro[_nY +aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCC"}),2]), TamSx3("CTT_CUSTO")[1] ,Space(01) )  ))
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Custo invแlido!"
				Else
					_DtIniCR := Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCC"}),2]),TamSx3("CTT_CUSTO")[1],Space(01)) ,'CTT_DTEXIS') 	// data inicio do CR
					_DtFimCR := Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCC"}),2]),TamSx3("CTT_CUSTO")[1],Space(01)) ,'CTT_DTEXSF')	// data final do CR
				    
				  	If( !Vazio(_DtFimCR) .and. !Vazio(_DtIniCR) )  // se existir data para o CR 
				  		If StoD(_DtInclu) < _DtIniCR .or. StoD(_DtInclu) > _DtFimCR
				  			lExtErro := .t.		
							nDiverg++ 
							aRegistro[_nY +  1 ,2] := "Data Custo invแlida!"	
						Endif
					Endif
					/* Para as contas que iniciam com 5 ou 6 obrigatoriamente precisam do centro de custo diferente de 1 ou 9999999 - Camila */
					If Left(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]),1) $ "5|6" .and.;
					  	Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCC"}),2]) $  ALLTRIM(GETMV("SC_VALCC"))
								lExtErro := .t.		
							nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Custo+conta invแlido!"					
				    Else
				      	If Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCC"}) ,2]), TamSx3("CTT_CUSTO")[1] ,Space(01) ),'CTT_BLOQ') == '1'
				      		lExtErro := .t.		
							nDiverg++ 
							aRegistro[_nY +  1 ,2] := "Custo bloqueado!"
				      	Endif
				    Endif
				
					_TipoConta := Posicione('CTT',1,xFilial('CTT')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CCC"}),2]),TamSx3("CTT_CUSTO")[1],Space(01)) ,'CTT_NORMAL') 
					
					If (Left(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]),1) == '5' .and. _TipoConta == '1').or.;
						(Left(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CREDIT"}),2]),1) == '6' .and. _TipoConta == '2')    
						lExtErro := .t.		
						nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Custo nใo compatํvel!"				    
					Endif
				Endif  
				
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '1' 
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Custo Debito deve ser vazio!"
				Endif
			Else
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}) ,2] $ '2|3'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Custo vazio!"
				Endif
			Endif

			// iTEM DEBITO ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ITEMD"}) ,2]))
				If!	CTD->(dbSeek(xFilial("CTD")+ PadR(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ITEMD"}) ,2]), TamSx3("CTD_ITEM")[1] ,Space(01) )  ))	
					lExtErro := .t.		
					nDiverg++
					aRegistro[_nY +  1 ,2] := "Item invแlido!"
				Else
					If Posicione('CTD',1,xFilial('CTD')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ITEMD"}),2]), TamSx3("CTD_ITEM")[1] ,Space(01)) ,'CTD_BLOQ') == '1'
				      	lExtErro := .t.		
						nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Item bloqueado!"
				   Endif				
				Endif
				                   
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '2' 
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Item Credito deve ser vazio!"
				Endif
			Else
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] $ '1|3'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Item vazio!"
				Endif
			Endif
			
			// ITEM Credito ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ITEMC"}),2]))
				If!	CTD->(dbSeek(xFilial("CTD")+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ITEMC"}) ,2]), TamSx3("CTD_ITEM")[1] ,Space(01) )  ))	
					lExtErro := .t.		
					nDiverg++ 
				Else
					If Posicione('CTD',1,xFilial('CTD')+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ITEMC"}),2]), TamSx3("CTD_ITEM")[1] ,Space(01)) ,'CTD_BLOQ') == '1'
				      	lExtErro := .t.		
						nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Item bloqueado!"
				   	Endif	
				Endif	
				
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '1'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Item Credito deve ser vazio!"
				Endif
			Else
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] $ '2|3'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Item vazio!"
				Endif
			Endif
			
			// CLASSE DEBITO ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CLVLDB"}),2]))
				If!	CTH->(dbSeek(xFilial("CTH")+ PadR(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CLVLDB"}),2]), TamSx3("CTH_CLVL")[1] ,Space(01) )  ))	
					lExtErro := .t.		
					nDiverg++
					aRegistro[_nY +  1 ,2] := "Classe invแlido!" 
				Else
					If Posicione('CTH',1,xFilial('CTH')+ PadR(Alltrim(aRegistro[_nY +aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CLVLDB"})  ,2]), TamSx3("CTH_CLVL")[1] ,Space(01)),'CTH_BLOQ') == '1'
				      	lExtErro := .t.		
						nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Classe bloqueada!"
				   	Endif		
				Endif
	
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '2'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Classe debito deve ser vazio!"
				Endif
			Else
				If aRegistro[_nY +  aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}) ,2] $ '1|3'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Classe vazia!"
				Endif  
			Endif   
			
			// CLASSE CREDITO ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CLVLCR"}) ,2]))
				If!	CTH->(dbSeek(xFilial("CTH")+ PadR(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CLVLCR"}),2]), TamSx3("CTH_CLVL")[1] ,Space(01) )  ))	
					lExtErro := .t.		
					nDiverg++
					aRegistro[_nY +  1 ,2] := "Classe invแlida!"
				Else
					If Posicione('CTH',1,xFilial('CTH')+ PadR(Alltrim(aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_CLVLCR"}) ,2]), TamSx3("CTH_CLVL")[1] ,Space(01)),'CTH_BLOQ') == '1'
				      	lExtErro := .t.		
						nDiverg++ 
						aRegistro[_nY +  1 ,2] := "Classe bloqueado!"
				   	Endif
				Endif
				
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '1'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Classe credito deve ser vazio!"
				Endif	
			Else
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] $ '2|3'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Classe vazia!"
				Endif
			Endif
			
			// Digito DEBITO ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DCD"}),2]))
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '2'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Digito de controle credito deve ser vazio!"
				Endif
			Endif              
          
			// Digito CREDITO ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DCC"}),2]))
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '1'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Digito de controle debito deve ser vazio!"
				Endif
			Endif  
			
			// Atividade DEBITO ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ATIVDE"}),2]))
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '2'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Atividade debito deve ser vazio!"
				Endif
			Endif              
          
			// Atividade CREDITO ======================================================================================			
			If !Vazio(Alltrim(aRegistro[_nY+aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_ATIVCR"}),2]))
				If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '1'
					lExtErro := .t.		
					nDiverg++ 
					aRegistro[_nY +  1 ,2] := "Atividade credito deve ser vazio!"
				Endif
			Endif  
			  
			
			// ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			// Tratamento para o campo de valor CT2_VALOR para evitar que um usuario preencha a planilha com dois pontos ou duas virgulas Ex: 12.125.10
			_nV := aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_VALOR"})
			
			If Val(aRegistro[_nY +  _nV ,2]) <= 0 // testa valores 
				lExtErro := .t.		
				nDiverg++ 
				aRegistro[_nY +  1 ,2] := "Valor invแlido!"
			Else
				For _nC := 1 to Len(Alltrim(aRegistro[_nY + _nV ,2] ))
	            	
	            	If "." $ Right(Alltrim(aRegistro[_nY + _nV ,2]), _nC ) .or. "," $ Right(Alltrim(aRegistro[_nY + _nV ,2]), _nC )
	            	
	            		cVal := Replace(Left(Alltrim(aRegistro[_nY + _nV ,2]),;
	            					Len(Alltrim(aRegistro[_nY + _nV ,2]))- Len(Right(Alltrim(aRegistro[_nY + _nV ,2]), _nC )) ),".","") 	
	            		cVal := Replace(cVal,",","")
	            		cVal := Replace(cVal,";","") 	
	            		aRegistro[_nY + _nV ,2] :=  Replace(Alltrim(cVal) + Right(Alltrim(aRegistro[_nY + _nV ,2]), _nC),",",".")
	            		
	            		If aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '1' 
							nValDebi :=  nValDebi + Val(aRegistro[_nY + _nV ,2])  	// total de linhas de Debito
	    				Elseif aRegistro[_nY + aScan(aCabec,{|a|Upper(AllTrim(a[1]))== "CT2_DC"}),2] == '2' 	
							nValCred := nValCred + Val(aRegistro[_nY + _nV ,2])  	// total de linhas de Credito
	            		Endif   
	            		Exit
	            	Endif	
				Next _nC
			Endif
			// ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			
		aListAuxA := {	If(lExtErro,o2, o1) ,;  
						aRegistro[_nY +  1 ,2], aRegistro[_nY +  2 ,2], aRegistro[_nY +  3 ,2], aRegistro[_nY +  4 ,2],;
						aRegistro[_nY +  5 ,2], aRegistro[_nY +  6 ,2], aRegistro[_nY +  7 ,2], aRegistro[_nY +  8 ,2],;
						aRegistro[_nY +  9 ,2], aRegistro[_nY + 10 ,2], aRegistro[_nY + 11 ,2], aRegistro[_nY + 12 ,2],;                            
						aRegistro[_nY + 13 ,2], aRegistro[_nY + 14 ,2], aRegistro[_nY + 15 ,2], aRegistro[_nY + 16 ,2],;
						aRegistro[_nY + 17 ,2], aRegistro[_nY + 18 ,2], aRegistro[_nY + 19 ,2], aRegistro[_nY + 20 ,2],;
						aRegistro[_nY + 21 ,2], aRegistro[_nY + 22 ,2], aRegistro[_nY + 23 ,2], aRegistro[_nY + 24 ,2],;								
						aRegistro[_nY + 25 ,2], aRegistro[_nY + 26 ,2], aRegistro[_nY + 27 ,2], aRegistro[_nY + 28 ,2],;
						aRegistro[_nY + 29 ,2], aRegistro[_nY + 30 ,2], aRegistro[_nY + 31 ,2], aRegistro[_nY + 32 ,2],;
						aRegistro[_nY + 33 ,2], aRegistro[_nY + 34 ,2], aRegistro[_nY + 35 ,2], aRegistro[_nY + 36 ,2],;
						aRegistro[_nY + 37 ,2], aRegistro[_nY + 38 ,2], aRegistro[_nY + 39 ,2], aRegistro[_nY + 40 ,2],;
						aRegistro[_nY + 41 ,2], aRegistro[_nY + 42 ,2], aRegistro[_nY + 43 ,2], aRegistro[_nY + 44 ,2],;
						If(lExtErro, 1, 0)} 
						
		_nY := _nY + len(aCabec)
		nTLinhas++ 
		If nDiverg > 0
			nExtErro++
			nDiverg := 0		
		Endif 
		aadd(aListA, aListAuxA)   // Alimenta a estrutura  
		lExtErro := .F.
    Next _nS

oListA:SetArray(aListA)  
oListA:bLine := {|| { 	  aListA[oListA:nAT,01], aListA[oListA:nAT,02], aListA[oListA:nAT,03], aListA[oListA:nAT,04],;
						  aListA[oListA:nAT,05], aListA[oListA:nAT,06], aListA[oListA:nAT,07], aListA[oListA:nAT,08],;
						  aListA[oListA:nAT,09], aListA[oListA:nAT,10], aListA[oListA:nAT,11], aListA[oListA:nAT,12],;
						  aListA[oListA:nAT,13], aListA[oListA:nAT,14], aListA[oListA:nAT,15], aListA[oListA:nAT,16],;
						  aListA[oListA:nAT,17], aListA[oListA:nAT,18], aListA[oListA:nAT,19], aListA[oListA:nAT,20],;
						  aListA[oListA:nAT,21], aListA[oListA:nAT,22], aListA[oListA:nAT,23], aListA[oListA:nAT,24],;
						  aListA[oListA:nAT,25], aListA[oListA:nAT,26], aListA[oListA:nAT,27], aListA[oListA:nAT,28],;
						  aListA[oListA:nAT,29], aListA[oListA:nAT,30], aListA[oListA:nAT,31], aListA[oListA:nAT,32],;
						  aListA[oListA:nAT,33], aListA[oListA:nAT,34], aListA[oListA:nAT,35], aListA[oListA:nAT,36],;                                                                                                
						  aListA[oListA:nAT,37], aListA[oListA:nAT,38], aListA[oListA:nAT,39], aListA[oListA:nAT,40],;                                                                                                						
						  aListA[oListA:nAT,41], aListA[oListA:nAT,42], aListA[oListA:nAT,43], aListA[oListA:nAT,44],;
						  aListA[oListA:nAT,45], aListA[oListA:nAT,46]	}} 

	For _nR := 1 to 12		// Preenche o rodape
        Do Case
       		Case _nR == 1    
				aObj[ _nR, 1 ]:SetText("Total de linhas: " + Alltrim(Str(nTLinhas)) )  
				
			Case _nR == 5    
				aObj[ _nR, 1 ]:SetText("Divergencias: " + Alltrim(Str(nExtErro)) )  

			Case _nR == 10    
				aObj[ _nR, 1 ]:SetText("Linha atual: " + Alltrim(Str(1)) )  	
				
			OtherWise
				aObj[ _nR, 1 ]:SetText("")
		End Case		
	Next _nR
          
    // Validacao caso nao seja partida dobrada          
	If nValDebi > 0 .or. nValCred > 0
		If nValDebi != nValCred 	
			For _nT := 1 to Len(aListA)
				aListA[_nT][01] 	:= o4 	// legenda - preto erro
				aListA[_nT][46]		:= 3  	// id Erro / 2 - Importada  
			Next _nT                         
			MsgStop("Total entre Debito e Credito divergente, verifique todas as linhas!" +cPL +cPL+;
					"Debito: R$ " + Alltrim(Str(nValDebi)) + cPL + "Credito: R$ " +  Alltrim(Str(nValCred)) )
		Endif       
	Endif 

oListA:GoPosition(01)
oListA:DrawSelect()
oDlgVerif:refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaCampo       ณdgomes              บ Data ณ  19/05/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Interface de validacao dos dados      			          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                
Static Function  AjustaCampo()      

Local cAntigo 	:= aListA[oListA:nAt][oListA:nColPos]
Local nTamCp	:= IIf(oListA:nColPos != 14, Len(aListA[oListA:nAt][oListA:nColPos]), 15 )
Local lgrv		:= .f.
 
/*	
		// Alteraveis
	If 	oListA:nColPos > 0 //oListA:nColPos == 3	.or. oListA:nColPos == 4 .or.	oListA:nColPos == 7 .or.;
		//	oListA:nColPos == 9	.or. oListA:nColPos == 10 .or. oListA:nColPos == 11  .or.;
		//	 	oListA:nColPos == 14 .or. oListA:nColPos == 16 .or.;
		//	 		oListA:nColPos == 17 .or. oListA:nColPos == 18 .or. oListA:nColPos == 19 .or.;
		//	 			oListA:nColPos == 20 .or. oListA:nColPos == 21 .or. oListA:nColPos == 22 .or. oListA:nColPos == 23 
		
		// aListA[oListA:nAt][oListA:nColPos] := Alltrim(aListA[oListA:nAt][oListA:nColPos]) + Space(15)
		                                                 
		//lEditCell(@aListA, oListA,'@', oListA:nColPos)  
	    
	 	Do Case
	    	Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DATA"})+1 // Data 03 - CT2_DATA =====================================
	    		If Len(Alltrim(aListA[oListA:nAt][oListA:nColPos])) != 8
	    			Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Deve ser preencchido com a data no formato AAAAMMDD " )
						aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	            Else
	            	If Vazio(StoD(aListA[oListA:nAt][oListA:nColPos]))
						Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite uma data vแlida! " )	            		
							aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	                Else
	                	If VerifTudo() 
	                		aListA[oListA:nAt][01] 	:= o1  	// legenda 
	                		aListA[oListA:nAT,46]	:= 0  	// id Erro 
	                		nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
	                	Endif	
	                Endif
	            Endif 
	       	Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_LOTE"})+1   // Data 04- CT2_LOTE =====================================
	       		aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_LOTE")[1] ,'0')  	                                            
	        
	        Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_LINHA"})+1 // Data 07 - CT2_LINHA ====================================
	       		If Val(aListA[oListA:nAt][oListA:nColPos]) !=  Val(aListA[(oListA:nAt)-1][oListA:nColPos])+1
	       			lgrv := MsgYesNO("N๚mero inserido diferente da sequencia existente!" + cPL + "Confirma a grava็ใo?")
	       		  	
	       		  	If lgrv                                                                                             
	       				aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_LINHA")[1] ,'0')
	       				lgrv := .f.  	                                                
	                Else          
	        			aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	        			lgrv := .f.
	                Endif                                                   
	        	Endif	
			Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DC"})+1 // Data 9 - CT2_DC ==========================================
             
				If Left(Alltrim(aListA[oListA:nAt][oListA:nColPos]),1) $ '1|2|3' 
					aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_DC")[1] , Space(01))
					
					If VerifTudo()
						aListA[oListA:nAt][01] := 	o1  // legenda 
						aListA[oListA:nAT,46]	:= 0  	// id Erro
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
					Endif	
					
					Do Case 
						Case aListA[oListA:nAt][oListA:nColPos] == '1' // CREDITO
						
							If Vazio(Alltrim(aListA[oListA:nAt][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})+1]))
			    				Alert("Campo " + aCabec[(aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1), 1] +;
			    						   cPL + " deve ser preencchido com uma conta vแlida" )
								aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
							Else 
							 	aListA[oListA:nAt][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1] := Space(TamSx3("CT2_DEBITO")[1])
							Endif
							 
						Case aListA[oListA:nAt][oListA:nColPos] == '2' // DEBITO
						 	
						 	If Vazio(Alltrim(aListA[oListA:nAt][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1]))
			    				Alert("Campo " + aCabec[(aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})-1), 1] +;
			    						   cPL + " deve ser preencchido com uma conta vแlida" )
								aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
							Else 
							 	aListA[oListA:nAt][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})+1] := Space(TamSx3("CT2_CREDIT")[1])	
							Endif    
						
						Case aListA[oListA:nAt][oListA:nColPos] == '3' // PARTIDA DOBRADA
						 
							If 	Vazio(Alltrim(aListA[oListA:nAt][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})+1])).or.;
								Vazio(Alltrim(aListA[oListA:nAt][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1]))
			    					Alert("Os campos CT2_CREDIT e CT2_DEBITO deve ser preencchidos com uma conta vแlida" )
									aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
							Endif							
						
					End Case
					
					
					
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite uma op็ใo vแlida! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(cAntigo), TamSx3("CT2_DC")[1] , Space(01))
	             Endif	                        
			 
			Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1 // Data 10 - CT2_DEBITO =================================
				lgrv :=	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_DEBITO")[1] ,Space(01) )  ))
				If lgrv 
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_DEBITO")[1] , Space(01))
	       			//aListA[oListA:nAt][(oListA:nColPos)+1] := Space(TamSx3("CT2_DEBITO")[1])
	       			If VerifTudo()
	       				aListA[oListA:nAt][01] := 	o1  // legenda 
	       				aListA[oListA:nAT,46]	:= 0  	// id Erro	
	       				nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
	       				
	       				If Vazio(aListA[oListA:nAt][	aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})+1])
	       					aListA[oListA:nAt][	aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DC"})+1] := '2'
	       				Else 
	       					aListA[oListA:nAt][	aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DC"})+1] := '3'	
	       				Endif	
	       			Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite uma conta debito vแlida! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif    
			
			Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})+1  // Data - 11 CT2_CREDIT =================================
				lgrv :=	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_CREDIT")[1] ,Space(01) )  ))
				If lgrv                                                                                             
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_CREDIT")[1] , Space(01))  	                                                
					//aListA[oListA:nAt][(oListA:nColPos)-1] := Space(TamSx3("CT2_CREDIT")[1])	
					If VerifTudo()
						aListA[oListA:nAt][01] := 	o1  // legenda        			
						aListA[oListA:nAT,46]	:= 0  	// id Erro
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
						
						If Vazio(aListA[oListA:nAt][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1])
	       					aListA[oListA:nAt][	aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DC"})+1] := '1'
						Else 
	       					aListA[oListA:nAt][	aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DC"})+1] := '3'	
	       				Endif
					Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite uma conta de cr้dito vแlida! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif 
			
			Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_VALOR"})+1   // Data 14 - CT2_VALOR ===================================
				aListA[oListA:nAt][oListA:nColPos] := 	Replace(aListA[oListA:nAt][oListA:nColPos],",",".")
					If VerifTudo()
						aListA[oListA:nAt][01] 	:= o1  // legenda        			
						aListA[oListA:nAT,46]	:= 0  	// id Erro
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
					Else
						aListA[oListA:nAt][01] 	:= o2  // legenda        			
						aListA[oListA:nAT,46]	:= 1  	// id Erro
						nExtErro := (nExtErro+1)					
					Endif    
			
			Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_HP"})+1 // Data - CT2_HP ==============================================
				aListA[oListA:nAt][oListA:nColPos] := PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CT2_HP")[1] , Space(01)) 			
			
			
			Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CCD"})+1  // Data 18 - CT2_CCD ======================================
				lgrv :=	CTT->(dbSeek(xFilial("CTT")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTT_CUSTO")[1] ,Space(01) )  ))
				If lgrv                                                                                            
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTT_CUSTO")[1] , Space(01))  	                                                
	       			aListA[oListA:nAt][(oListA:nColPos)+1] := Space(TamSx3("CTT_CUSTO")[1])
	       			If VerifTudo()
		       			aListA[oListA:nAt][01] := 	o1  // legenda 
		       			aListA[oListA:nAT,46]	:= 0  	// id Erro 
	    	   			nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
	    	   		Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite um centro de custo vแlido! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif    	     	        
	        
	        Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CCC"})+1   // Data 19 - CT2_CCC =======================================
				lgrv :=	CTT->(dbSeek(xFilial("CTT")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTT_CUSTO")[1] ,Space(01) )  ))
				If lgrv 
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTT_CUSTO")[1] , Space(01))  	                                                
					aListA[oListA:nAt][(oListA:nColPos)-1] := Space(TamSx3("CTT_CUSTO")[1])	       			
					If VerifTudo()                                                                                            
						aListA[oListA:nAt][01] := 	o1  // legenda 
						aListA[oListA:nAT,46]	:= 0  	// id Erro 
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
					Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite um centro de custo vแlido! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif
	             
	 		Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_ITEMD"})+1 // Data 20 - CT2_ITEMD =====================================
				lgrv :=	CTD->(dbSeek(xFilial("CTD")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTD_ITEM")[1] ,Space(01) )  ))
				If lgrv 
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTD_ITEM")[1] , Space(01))  	                                                
					aListA[oListA:nAt][(oListA:nColPos)+1] := Space(TamSx3("CTD_ITEM")[1])	       			
					If VerifTudo()                                                                                            
						aListA[oListA:nAt][01] := 	o1  // legenda 
						aListA[oListA:nAT,46]	:= 0  	// id Erro 
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
					Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite um c๓digo vแlido! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif
	             
	        Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1 // Data 21 - CT2_ITEMC ===================================
				lgrv :=	CTD->(dbSeek(xFilial("CTD")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTD_ITEM")[1] ,Space(01) )  ))
				If lgrv 
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTD_ITEM")[1] , Space(01))  	                                                
					aListA[oListA:nAt][(oListA:nColPos)-1] := Space(TamSx3("CTD_ITEM")[1])	       			
					If VerifTudo()                                                                                            
						aListA[oListA:nAt][01] 	:= o1  	// legenda 
						aListA[oListA:nAT,46]	:= 0  	// id Erro 
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
					Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite um c๓digo vแlido! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif

	        Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CLVLDB"})+1 // Data 22- CT2_CLVLDB ====================================
				lgrv :=	CTH->(dbSeek(xFilial("CTH")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTH_CLVL")[1] ,Space(01) )  ))
				If lgrv 
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTH_CLVL")[1] , Space(01))  	                                                
					aListA[oListA:nAt][(oListA:nColPos)+1] := Space(TamSx3("CTD_ITEM")[1])	       			
					If VerifTudo()
						aListA[oListA:nAt][01] 	:= o1 	// legenda 
						aListA[oListA:nAT,46]	:= 0  	// id Erro 
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
					Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite um c๓digo vแlido! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif

	         Case oListA:nColPos == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CLVL"})+1 // Data 23 - CT2_CLVLCR ====================================
				lgrv :=	CTH->(dbSeek(xFilial("CTH")+ PadR(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTH_CLVL")[1] ,Space(01) )  ))
				If lgrv 
	       			aListA[oListA:nAt][oListA:nColPos] := 	PadL(Alltrim(aListA[oListA:nAt][oListA:nColPos]), TamSx3("CTH_CLVL")[1] , Space(01))  	                                                
					aListA[oListA:nAt][(oListA:nColPos)-1] := Space(TamSx3("CTD_ITEM")[1])	       			
					If VerifTudo()
						aListA[oListA:nAt][01] 	:=	o1  // legenda 
						aListA[oListA:nAT,46]	:= 	0  	// id Erro 
						nExtErro := IIf(nExtErro> 0, (nExtErro-1), nExtErro)
					Endif	
                Else 
	            	Alert("Campo " + aCabec[(oListA:nColPos)-1 , 1] + cPL + " Digite um c๓digo vแlido! " )	            		         
	        		aListA[oListA:nAt][oListA:nColPos] := 	cAntigo
	             Endif
	                                     
	        OtherWise
				aListA[oListA:nAt][oListA:nColPos] := Padl(aListA[oListA:nAt][oListA:nColPos], nTamCp ,Space(01))   	        
				
		End Case 

	    lCorrErro	:= .T.
	    aObj[ 05, 1 ]:SetText("Divergencias: " + Alltrim(Str(nExtErro)) )
	    aObj[ 10, 1 ]:SetText("Linha atual: " + Alltrim(Str(oListA:nAt)) )    
			    
		/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFoi preciso inserir uma segunda validacao para testar  ณ
		//ณtoda a linha, uma vez que pode existir 02 ou mais dadosณ
		//ณerrados em uma unica linha, assim a correcao do        ณ
		//ณprimeiro dado com erro tornaria a linha OK, o que nao  ณ
		//ณseria verdade.                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		/ // VerifTudo()  // verifica todas as colunas =============

	Else     
		Alert("Coluna " + aCabec[(oListA:nColPos)-1 , 1] + " nใo pode ser alterada.")    
    Endif
         
oListA:DrawSelect()
oDlgVerif:refresh()
*/
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerifTudo         ณdgomes              บ Data ณ  29/05/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Interface de validacao dos dados      			          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/     
Static Function VerifTudo()

For _nV := 2 to Len(aCabec)

	Do Case
	    	Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DATA"})+1 // Data 03 - CT2_DATA =====================================
	    		If Len(Alltrim(aListA[oListA:nAt][_nV])) != 8
	    			lCorrErro := .f. 	
	            Endif 
	       	
			Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DC"})+1  // Data 9 - CT2_DC ==========================================
             	If! Left(Alltrim(aListA[oListA:nAt][_nV]),1) $ '1|2|3'
					lCorrErro := .f. 	
	       		Endif	                        
			 
			Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1 .and.;// Data - 11 CT2_DEBITO =================================
							!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CT2_DEBITO")[1] ,Space(01) ))
				lgrv :=	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CT2_DEBITO")[1] ,Space(01) )  ))
					If! lgrv                                                                                             
	       				lCorrErro := .f. 	
	    			Endif    
			
			Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})+1 .and.;// Data - 11 CT2_CREDIT =================================
			    		!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CT2_CREDIT")[1] ,Space(01)))
				lgrv :=	CT1->(dbSeek(xFilial("CT1")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CT2_CREDIT")[1] ,Space(01) )  ))
					If! lgrv                                                                                             
	       				lCorrErro := .f. 	
	   		        Endif 
			
			Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_VALOR"})+1 .and.;  // Data 14 - CT2_VALOR ===================================
					!Vazio(aListA[oListA:nAt][_nV])
				if Val(aListA[oListA:nAt][_nV]) == 0
           			lCorrErro := .f. 	
				Endif  
							
			Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CCD"})+1 .and.;  // Data 18 - CT2_CCD ======================================
					!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTT_CUSTO")[1] ,Space(01) ))
				lgrv :=	CTT->(dbSeek(xFilial("CTT")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTT_CUSTO")[1] ,Space(01) )  ))
				If! lgrv                                                                                             
	       			lCorrErro := .f. 	
	            Endif    	     	        
	        
	        Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CCC"})+1 .and.;  // Data 19 - CT2_CCC =======================================
	   				!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTT_CUSTO")[1] ,Space(01) ))     										
				lgrv :=	CTT->(dbSeek(xFilial("CTT")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTT_CUSTO")[1] ,Space(01) )  ))
				If! lgrv                                                                                             
	       			lCorrErro := .f. 	
	            Endif
	             
	 		Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_ITEMD"})+1 .and.;// Data 20 - CT2_ITEMD =====================================
					!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTD_ITEM")[1] ,Space(01) ))	 		
				lgrv :=	CTD->(dbSeek(xFilial("CTD")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTD_ITEM")[1] ,Space(01) )  ))
				If! lgrv                                                                                             
					lCorrErro := .f. 	
	    		Endif
	             
	        Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1 .and.;// Data 21 - CT2_ITEMC ===================================
	        		!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTD_ITEM")[1] ,Space(01) ))
				lgrv :=	CTD->(dbSeek(xFilial("CTD")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTD_ITEM")[1] ,Space(01) )  ))
				If! lgrv                                                                                             
	       			lCorrErro := .f. 	
	  		    Endif

	        Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CLVLDB"})+1 .and.; // Data 22- CT2_CLVLDB ====================================
	        		!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTH_CLVL")[1] ,Space(01) ))
				lgrv :=	CTH->(dbSeek(xFilial("CTH")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTH_CLVL")[1] ,Space(01) )  ))
				If! lgrv                                                                                             
					lCorrErro := .f. 	
	         	Endif

	         Case _nV == aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CLVL"})+1 .and.;// Data 23 - CT2_CLVLCR ====================================
	         		!Vazio(PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTH_CLVL")[1] ,Space(01) ))
				lgrv :=	CTH->(dbSeek(xFilial("CTH")+ PadR(Alltrim(aListA[oListA:nAt][_nV]), TamSx3("CTH_CLVL")[1] ,Space(01) )  ))
				If! lgrv                                                                                             
		       		lCorrErro := .f. 	
	            Endif
	    End Case 

Next _nV          

Return 	lCorrErro
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaTudo         ณdgomes              บ Data ณ  29/05/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Gravacao dos dados validados na tabela CT2                บฑฑ
ฑฑบ          ณ  Caso exista uma linha invalida impede de prosseguir       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function GravaTudo()
            
Local lPendErro := .f.          
Local nMsg		:= 0
private oRegua
private lEnd := .T.
Private nColn		:= 0           
	For _nK := 1 to Len(oListA:AHEADERS) 
		If Upper(oListA:AHEADERS[_nK]) == "ERRO"
	    	nColn := _nK		
	    	For _nL := 1 to Len(aListA)
	    		If aListA[_nL][nColn] != 0 
	    			lPendErro := .t. 
	    				If 	aListA[_nL][nColn] == 1
	    					nMsg := 1	
	    				Elseif aListA[_nL][nColn] == 2
	    					nMsg := 2
	    				Elseif aListA[_nL][nColn] == 3
	    					nMsg := 3	
	    				Endif
	    			Exit 
	    		Endif	
	    	Next _nL	
	    Endif		
	Next _nK
                           
	If lPendErro  
		If nMsg == 1
			MsgStop("Aten็ใo: linha " + Alltrim(Str(_nL)) + cPL + " cont้m uma diverg๊ncia, sem a corre็ใo nใo serแ possํvel prosseguir com a importa็ใo!" )
		ElseIf nMsg == 2
			MsgAlert("Lote jแ importado")
		ElseIf nMsg == 3
			MsgAlert("Valor entre debito e credito divergente, favor corrigir a planilha!")		
		Else
			Alert("Erro desconhecido, acione o dep. de sistemas")		
		Endif
		oListA:GoPosition(_nL)
		aObj[ 05, 1 ]:SetText("Divergencias: " + Alltrim(Str(nExtErro)) )
	    aObj[ 10, 1 ]:SetText("Linha atual: " + Alltrim(Str(_nL)) ) 
		oListA:DrawSelect()
		oDlgVerif:refresh()
		Return Nil
	Endif

// --------------------------------------------------------------------------
// Na utiliza็ใo de execAuto considerar os seguintes crit้rios:
// 1 - Passar o campo CT2_CONVER como 15555, demais moedas devem ser feitos
//     pela inclusใo de um novo aItens
// 2 - na altera็ใo de registro passe novamente o ACab
// --------------------------------------------------------------------------
If MsgYesNo("Deseja realizar a carga dos dados ?")
    oRegua := MsNewProcess():New({|lEnd| GravaCTB(@oRegua,@lEnd) },"Processando","",.T.)
    oRegua:Activate()
    If nExErro == 0
    	MsgAlert("Carga Finalizada")
    Endif	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaCTB บAutor  ณDGOMES              บ Data ณ  21/08/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Contabil integracao                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaCTB(oObj,lEnd)

Local nX
Local aArea         := GetArea()
Local nDoc          := 2
Local lRet          := .T.
Local aCab          := {}
Local aItens        := {}
Local aLinha        := {}
Local dDataLanc     := ddatabase
Local nLinha        := '001' 
//Local nExErro		:= 0  

Private lMsErroAuto     := .F.
Private lMsHelpAuto     := .T.
Private CTF_LOCK        := 0
Private lSubLote        := .T.

oObj:SetRegua1(5)
oObj:IncRegua1("Gerando Documentos")
oObj:SetRegua1(nDoc) 

	aAdd(aCab,  {'DDATALANC'     ,StoD(aListA[1][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DATA"})+1])          							,NIL} )
    aAdd(aCab,  {'CLOTE'         ,Padl(aListA[1][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_LOTE"})+1], TamSx3("CT2_LOTE")[1], "0")  	 	,NIL} )
    aAdd(aCab,  {'CSUBLOTE'      ,Padl(aListA[1][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_SBLOTE"})+1], TamSx3("CT2_SBLOTE")[1], "0")   	,NIL} )
    aAdd(aCab,  {'CDOC'          ,Padl(aListA[1][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DOC"})+1], TamSx3("CT2_DOC")[1], "0")         	,NIL} )
    aAdd(aCab,  {'CPADRAO'       ,''             	,NIL} )
    aAdd(aCab,  {'NTOTINF'       ,0                	,NIL} )
    aAdd(aCab,  {'NTOTINFLOT'    ,0                	,NIL} )

For nX:= 1 To nTLinhas
    If lEnd
        Exit
    EndIf
    
    oObj:IncRegua2("Linha " + Alltrim(Str(nX)) + " de "+ Alltrim(Str(nTLinhas)))
    
    aAdd(aItens,{  	{'CT2_FILIAL'     ,Pad('',TamSX3( "CT2_FILIAL")[1])           																		, NIL},;
    				{'CT2_LINHA'      ,Pad(aListA[nX][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_LINHA"})+1], TamSx3("CT2_LINHA")[1])  			, NIL},;
                   	{'CT2_MOEDLC'     ,PadL(aListA[nX][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_MOEDLC"})+1], TamSx3("CT2_MOEDLC")[1],"0")	, NIL},;
                   	{'CT2_DC'         ,Pad(aListA[nX][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DC"})+1], TamSx3("CT2_DC")[1])					, NIL},;
                   	{'CT2_DEBITO'     ,Pad(aListA[nX][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_DEBITO"})+1],TamSX3( "CT2_DEBITO")[1])       	, NIL},;
                   	{'CT2_CREDIT'     ,Pad(aListA[nX][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_CREDIT"})+1],TamSX3( "CT2_CREDIT")[1])        	, NIL},;
                   	{'CT2_VALOR'      ,Val(aListA[nX][aScan(aCabec, {|a| Upper(AllTrim(a[1])) == "CT2_VALOR"})+1])									, NIL},;
                   	{'CT2_ORIGEM'     ,Pad('SCOPUS_AUTO',TamSX3( "CT2_ORIGEM")[1])           															, NIL},;
                   	{'CT2_HP'         ,Pad('',TamSX3( "CT2_HP")[1])           																			, NIL},;
                   	{'CT2_CONVER'     ,Pad('15555',TamSX3( "CT2_CONVER")[1])           																, NIL},;
                   	{'CT2_HIST'       ,Pad(Alltrim(aListA[nX][aScan(aCabec,{|a| Upper(AllTrim(a[1]))== "CT2_HIST"})+1]),TamSX3("CT2_HIST")[1])    	, NIL},;
                   	{'CT2_CCD'		  ,Pad(Alltrim(aListA[nX][aScan(aCabec,{|a| Upper(AllTrim(a[1]))== "CT2_CCD"})+1]),TamSX3("CT2_CCD")[1])			, NIL},;
                   	{'CT2_CCC'		  ,Pad(Alltrim(aListA[nX][aScan(aCabec,{|a| Upper(AllTrim(a[1]))== "CT2_CCC"})+1]),TamSX3("CT2_CCC")[1])       	, NIL},;
                   	{'CT2_ITEMD'	  ,Pad(Alltrim(aListA[nX][aScan(aCabec,{|a| Upper(AllTrim(a[1]))== "CT2_ITEMD"})+1]),TamSX3("CT2_ITEMD")[1])		, NIL},;
                   	{'CT2_ITEMC'	  ,Pad(Alltrim(aListA[nX][aScan(aCabec,{|a| Upper(AllTrim(a[1]))== "CT2_ITEMC"})+1]),TamSX3("CT2_ITEMC")[1])		, NIL},;
                   	{'CT2_CLVLDB'	  ,Pad(Alltrim(aListA[nX][aScan(aCabec,{|a| Upper(AllTrim(a[1]))== "CT2_CLVLDB"})+1]),TamSX3("CT2_CLVLDB")[1]) 	, NIL},;
                   	{'CT2_CLVLCR'	  ,Pad(Alltrim(aListA[nX][aScan(aCabec,{|a| Upper(AllTrim(a[1]))== "CT2_CLVLCR"})+1]),TamSX3("CT2_CLVLCR")[1])	, NIL},;
                   	{'CT2_ROTINA'	  ,"CTBA102"		, NIL} })  //{'CT2_EMPORI'	  ,cEmpAnt         	, NIL},;      	{'CT2_FILORI'	  ,cFilAnt      , NIL},;
                   	
Next nX 
	lMsErroAuto := .F.
	oObj:IncRegua1("Gravando, aguarde ...")
	Begin transaction 	
		MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)
	End transaction 	   
  
    If lMsErroAuto
    	nExErro++
   		MostraErro()

   		For _nT := 1 to Len(aListA)
			aListA[_nT][01]    		:= o4 	// legenda - preto erro
			aListA[_nT][nColn]		:= 3  	// id Erro / 2 - Importada
		Next _nT 
		
	Else
		For _nT := 1 to Len(aListA)
			aListA[_nT][01] 	:= o3 	// legenda - branco
			aListA[_nT][46]		:= 2  	// id Erro / 2 - Importada
		Next _nT 
		
		oListA:DrawSelect()
		oDlgVerif:refresh()  
	Endif
       
RestArea(aArea)

Return