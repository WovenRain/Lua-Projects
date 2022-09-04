Buttons = {}


function newButton( text, fn )
	return {
		text = text,
		fn = fn,
		now = false,
		last = false
	}
end

function handButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = true
	}
end

function shopButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = false
	}
end

function outcomeButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = true
	}
end

function bagButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		size = 0,
		active = true
	}
end

function keepRerollButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false,
		active = true
	}
end

function popupButton(text, fn)
	return {
		text = text,
		fn = fn,
		now = false,
		last = false
	}
end