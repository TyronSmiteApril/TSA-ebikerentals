-- Branding!
local label =
[[ 
	                    _______________________________
                        |                             |
                        |   ████████╗░██████╗░█████╗░ |
                        |   ╚══██╔══╝██╔════╝██╔══██╗ |
                        |   ░░░██║░░░╚█████╗░███████║ |
                        |   ░░░██║░░░░╚═══██╗██╔══██║ |
                        |   ░░░██║░░░██████╔╝██║░░██║ |
                        |   ░░░╚═╝░░░╚═════╝░╚═╝░░╚═╝ |
                        |_____________________________|
                        |  Created by TyronSmiteApril |
                        |_____________________________|
						]]

-- Returns the current version set in fxmanifest.lua
function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

-- Grabs the latest version number from the web GitHub
PerformHttpRequest( "https://github.com/TyronSmiteApril/TSA-Ebikerentals", function( err, text, headers )
	-- Wait to reduce spam
	Citizen.Wait( 2000 )

	-- Print the branding!
	print( label )

	-- Get the current resource version
	local curVer = GetCurrentVersion()

	print( "                            Current version: " .. curVer .. "\n"  )
end )