#INCLUDE "PROTHEUS.CH"  

User Function ChartBar()

	Local oChart
	Local oDlg      

	DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 600,600

	oChart := FWChartBar():New()
	oChart:init( oDlg, .t., .t. ) 
	oChart:addSerie( "Votos LOJA 001", 05 )
	oChart:addSerie( "Votos LOJA 002", 15 )
	oChart:addSerie( "Votos LOJA 003", 01 )
	oChart:addSerie( "Votos LOJA 004", 19 )
	oChart:addSerie( "Votos LOJA 005", 20 )
	oChart:addSerie( "Votos LOJA 006", 05 )
	oChart:addSerie( "Votos LOJA 007", 05 )
	oChart:addSerie( "Votos LOJA 008", 10 )
	oChart:addSerie( "Votos LOJA 009", 10 )
	oChart:addSerie( "Votos LOJA 010", 10 )
	oChart:setLegend( CONTROL_ALIGN_LEFT ) 
	oChart:Build()

	ACTIVATE MSDIALOG oDlg

Return