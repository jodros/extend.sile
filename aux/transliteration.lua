local latin = {
	['a'] = 'а',
	['A'] = 'А',
	['ã'] = 'ань',
	['Ã'] = 'АН',

	['e'] = 'е',
	['E'] = 'Е',
	['é'] = 'э',
	['É'] = 'Э',
	['ê'] = 'е',
	['Ê'] = 'е',

	['i'] = 'и',
	['I'] = 'И',
	['í'] = 'иь',
	['Í'] = 'Иь',

	['y'] = 'ы',
	['Y'] = 'Ы',

	['o'] = 'о',
	['ó'] = 'о',
	['õ'] = 'онъ',
	['O'] = 'О',
	['Ó'] = 'О',

	['u'] = 'у',
	['U'] = 'У',
	['ú'] = 'уь',
	['Ú'] = 'УЬ',

	['b'] = 'б',
	['B'] = 'Б',
	['d'] = 'д',
	['D'] = 'Д',
	['f'] = 'ф',
	['F'] = 'Ф',
	['h'] = 'г',
	['H'] = 'Г',
	['j'] = 'ж',
	['J'] = 'Ж',
	['k'] = 'к',
	['K'] = 'К',
	['l'] = 'л',
	['L'] = 'Л',
	['m'] = 'м',
	['M'] = 'М',
	['n'] = 'н',
	['N'] = 'Н',
	['p'] = 'п',
	['P'] = 'П',
	['t'] = 'т',
	['T'] = 'Т',
	['v'] = 'в',
	['V'] = 'В',
	['z'] = 'з',
	['Z'] = 'З',
	['r'] = 'р',
	['R'] = 'Р',
	['s'] = 'с',
	['S'] = 'С',
	['c'] = 'к',
	['C'] = 'К',
	['g'] = 'г',
	['G'] = 'Г',
	['w'] = 'в',
	['W'] = 'В',
	['x'] = 'кс',
	['X'] = 'КС',
	['ç'] = 'ц',
	['Ç'] = 'Ц',

	['q'] = 'к',
	['Q'] = 'К',
}

local cyrrilic = {
	['а'] = 'a',
	['А'] = 'A',

	['е'] = 'e',
	['Е'] = 'E',
	['э'] = 'é',
	['Э'] = 'É',


	['и'] = 'i',
	['И'] = 'I',
	['й'] = 'i',
	['Й'] = 'I',

	['ы'] = 'y',
	['Ы'] = 'Y',

	['о'] = 'o',

	['у'] = 'u',
	['У'] = 'U',
	['б'] = 'b',
	['Б'] = 'B',
	['д'] = 'd',
	['Д'] = 'D',
	['ф'] = 'f',
	['Ф'] = 'F',

	['г'] = 'h', -- ou G???
	['Г'] = 'H',

	['ж'] = 'j',
	['Ж'] = 'J',
	['к'] = 'k',
	['К'] = 'K',
	['л'] = 'l',
	['Л'] = 'L',
	['м'] = 'm',
	['М'] = 'M',
	['н'] = 'n',
	['Н'] = 'N',
	['п'] = 'p',
	['П'] = 'P',
	['т'] = 't',
	['Т'] = 'T',
	['в'] = 'v',
	['В'] = 'V',
	['з'] = 'z',
	['З'] = 'Z',
	['р'] = 'r',
	['Р'] = 'R',
	['с'] = 's',
	['С'] = 'S',
	['к'] = 'c',
	['К'] = 'C',
	['г'] = 'g',
	['Г'] = 'G',
	['в'] = 'w',
	['В'] = 'W',
	['ц'] = 'ç',
	['Ц'] = 'Ç',

	special = {
		['аь'] = 'á',
		['Аь'] = 'Á',
		['аъ'] = 'à',
		['Аъ'] = 'À',
		['ань'] = 'ã',
		['АНь'] = 'Ã',

		['еъ'] = 'ê',
		['Еъ'] = 'Ê',

		['иь'] = 'í',
		['Иь'] = 'Í',

		['уь'] = 'ú',
		['Уь'] = 'Ú',

		['оь'] = 'ó',
		['Оь'] = 'Ó',
		['оъ'] = 'ô',
		['Оъ'] = 'Ô',
		['онъ'] = 'õ',


		['ку'] = 'qu',
		['КУ'] = 'Qu',

		['кс'] = 'x',
		['КС'] = 'X',

		['със'] = 'sc',
		['СЪС'] = 'sc',

	}
	-- [' '] = ' ',
	-- ['.'] = '.',
	-- [','] = ',',
	-- ['\n'] = '\n'
}

--[[
	Some conventions:
	- The nasalisation mark...
	- Circumflex ... is being marked with a hard mark ô -> оъ
	- And the soft ones are used to mark ´, like ó -> оь, except the é since it has its own equivalent character in cyrrilic é -> э

]]

local insp = require "inspect"

local function transliterate(script, text) -- by now only from latin to cyrrilic...
	local translit = ''
	local converted = utf8.codes(text)

	if script == cyrrilic then
		for cyr, lat in pairs(script.special) do
			text = string.gsub(text, cyr, lat)
		end
	end -- the special cases must be handled before the main process! why?? idk

	for pos, char in utf8.codes(text) do
		local c = utf8.char(char)

		if script[c] then
			translit = translit .. script[c]
		elseif not script[c] then
			translit = translit .. c
		end
	end

	return translit
end

local latin_sample = [[Quando errar, quando assar faça sintaxe.]]
local cyrrilic_sample = [[оь е ай, э тамбэм уьлтимо дос кс онъ]]

print(transliterate(cyrrilic, cyrrilic_sample))
-- print(transliterate(latin, latin_sample))


return transliterate
