local base = require("packages.base")

local package = pl.class(base)
package._name = "abnt"

package.defaultFrameset = {

}

function package:_init()
	base._init(self)
end

function package:registerCommands()
	self:registerCommand("", function(options, content)
	end)

	-- Elementos pré-textuais
	
	self:registerCommand("cover", function(options, content)
	end, "Capa")

	
	self:registerCommand("", function(options, content)
	end, "Folha de rosto")
	self:registerCommand("", function(options, content)
	end, "Errata")
	self:registerCommand("", function(options, content)
	end, "Folha de aprovação")
	self:registerCommand("", function(options, content)
	end, "Dedicatória")
	
	self:registerCommand("agradecimentos", function(options, content)
	end, "Agradecimentos")

	self:registerCommand("epigrafe", function(options, content)
	end, "Epigrafe")

	self:registerCommand("resumo", function(options, content)
	end, "Resumo na lingua vernácula")

	self:registerCommand("abstract", function(options, content)
	end, "Resumo em lingua estrangeira")

	self:registerCommand("lista:ilustracoes", function(options, content)
	end, "Lista de ilustrações")

	self:registerCommand("lista:tabelas", function(options, content)
	end, "Lista de tabelas")

	self:registerCommand("lista:abreviaturas-siglas", function(options, content)
	end, "Lista de abreviaturas e siglas")

	self:registerCommand("lista:simbolos", function(options, content)
	end, "Lista de simbolos")

	self:registerCommand("sumario", function(options, content)
	end, "Sumário")

	-- Elementos textuais 

	self:registerCommand("intro", function(options, content)
	end, "Introdução")
	
	self:registerCommand("desenvolvimento", function(options, content)
	end, "Desenvolvimento")

	self:registerCommand("conclusao", function(options, content)
	end, "Conclusão")

	self:registerCommand("ref", function(options, content)
	end, "Referências")

	self:registerCommand("glossario", function(options, content)
	end, "Glossário")

	self:registerCommand("apendice", function(options, content)
	end, "Apêndice")

	-- Elementos pós-textuais
	
	self:registerCommand("anexo", function(options, content)
	end, "Anexo")
	
	self:registerCommand("indice", function(options, content)
	end, "indice")
end

package.documentation = [[
\begin{document}

The \autodoc:package{abnt} aims to automatically render your text according to the rules of ABNT...


A estrutura de trabalhos acadêmicos compreende: parte externa e parte interna.

Com a finalidade de orientar os usuários, a disposição de elementos é a seguinte:

\strong{Estrutura do trabalho acadêmico}

\strong{Parte externa}

Capa

Lombada

\strong{Parte interna}

Elementos pré-textuais

Elementos textuais

Folha de rosto

Errata

Folha de aprovação

Dedicatória

Agradecimentos

Epigrafe

Resumo na lingua vernácula

Resumo em lingua estrangeira

Lista de ilustrações

Lista de tabelas

Lista de abreviaturas e siglas

Lista de simbolos

Sumário

Introdução

Desenvolvimento

Conclusão

Referências

Glossário

Apéndice

Elementos pós-textuais

Anexo

indice




\end{document}
]]

return package
