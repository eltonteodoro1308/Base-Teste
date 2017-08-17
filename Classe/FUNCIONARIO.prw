#include 'protheus.ch'

class FUNCIONARIO

	method new() constructor
	method teste()
    var Nome
	data DataNasc
	data Sexo
	data Salario

endclass

method new() class FUNCIONARIO

return Self

method teste() class FUNCIONARIO

return Self

User Function TstCls()

	Local oFunc := FUNCIONARIO():NEW()

	VarInfo( '', ClassDataArr( oFunc ),, .F., .T. )

	VarInfo( '', ClassMethArr( oFunc ),, .F., .T. )

Return