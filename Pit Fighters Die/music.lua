music = {}

songs = {}
songs["theme"] = "/music/They Are Already Here.ogg"
songs["Plays_1"] = "/music/Point of Clash.ogg"
songs["The Fool"] = "/music/La Verdad.ogg"
songs["Emperor"] = "/music/Ouija A.ogg"

function music:start()
    self.playing = love.audio.newSource(songs["theme"], "stream")
    self.playing:play()
end

function music:update()
    if not self.playing:isPlaying( ) then
		love.audio.play( self.playing )
	end
end

function music:playNew(song)
    self.playing:stop()
    self.playing = love.audio.newSource(songs[song], "stream")
    self.playing:play()
end