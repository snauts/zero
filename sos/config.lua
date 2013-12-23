-- Program configuration.

local eapi = eapi or { }

Cfg = {
        name = "Zero",
	version = "devel",

	-- Display.
	fullscreen	= false,
	windowWidth	= 800,
	windowHeight	= 480,
	screenBPP	= 0,
	
	-- Sound.
	channels	= 16,
	frequency	= 22050,
	chunksize	= 512,
	stereo		= true,

	-- Debug things.
	debug		= false,
	useDesktop	= true,
	screenWidth	= 800,
	screenHeight	= 480,
	printExtensions = false,
	FPSUpdateInterval = 1000,
	gameSpeed = 0,
        defaultShapeColor = {r=0,g=1,b=0},

	-- Default control scheme: actions mapped to keys.
	controls = {
		Left  = { "Left",  "Joy0 A0-" },
		Right = { "Right", "Joy0 A0+" },
		Up    = { "Up",    "Joy0 A1-" },
		Down  = { "Down",  "Joy0 A1+" },

		Shoot = { "X",     "Joy0 B1" },
		Bomb  = { "Z",     "Joy0 B2" },

		Quit  = { "Escape", "Joy0 B7" },
	},

        -- Engine config.
        poolsize = {
                world      = 12,
                body       = 5000,
                tile       = 5000,
                shape      = 5000,
                group      = 100,
                camera     = 10,
                texture    = 100,
                spritelist = 200,
                sound      = 100,
                music      = 10,
                timer      = 4000,
                gridcell   = 50000,
                property   = 50000,
                collision  = 1000
        },
        collision_dist = 1,
        cam_vicinity_factor = 0.5
}

return Cfg
