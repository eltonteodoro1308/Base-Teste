User Function TFSWSP01()

Local oFSWSP01 := WSFSWSP01():New()

Local CEMPTIT  := '01'
Local CFILTIT  := '01'
Local CPARCELA := '1'
Local CCLIENTE := '001'
Local DDTVENC  := StoD('20160728')
Local NVALOR   := 200
Local NVLCRUZ  := 200
Local CCCC     := '10101'
Local CITMC    := '010010001'
Local CCLVRL   := '010101010101'
Local CCREDIT  := '41010101001'
Local CDEBITO  := '110301030020010031'
Local CNCCZ4   := '123456789'
Local CTITZ4   := 'TOTVS SA'
Local CNUMCTR  := '123456789'


oFSWSP01:FSWSP01_GRVTIT(cEmpTit,cFilTit,cParcela,cCliente,dDtVenc,nValor,nVlCruz,cCcc, cItmC, cClVrl, cCredit,;
cDebito,cNccZ4,cTitZ4,cNumCtr)

Return
