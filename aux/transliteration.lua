local letters = {
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
	['í'] = 'и',
	['Í'] = 'И',

	['y'] = 'ы',
	['Y'] = 'Ы',

	['o'] = 'о',
	['ó'] = 'о',
	['õ'] = 'онъ',
	['O'] = 'О',
	['Ó'] = 'О',

	['u'] = 'у',
	['U'] = 'У',
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

	-- 

	['rr'] = 'х',
	['RR'] = 'Х',
	['qu'] = 'ку',
	['Qu'] = 'КУ',
	-- [' '] = ' ',
	-- ['.'] = '.',
	-- [','] = ',',
	-- ['\n'] = '\n'
}


local function transliterate(text) -- by now only from latin to cyrrilic...
	local translit = ''

	for _, char in utf8.codes(text) do
		local c = utf8.char(char)

		if letters[c] then
			translit = translit .. letters[c]   -- memoized...
		elseif not letters[c] then
			translit = translit .. c
		end
	end

	return translit
end

return transliterate
