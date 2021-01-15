------------------------------------------------------------------
-- ATTENTION: These are the API functions currently implemented in EWT. 
------------------------------------------------------------------
-- LAST UPDATED: 2021-01-11
-- Added Draw3DLine, Draw3DText, AddNavRegion/RemoveNavRegion, RestoreMeshPoint/RestoreMeshPoints, GetActorCount and GetActorWithIndex.
-- Changed CalculatePath 'StraightPath'
-- Added UnzipFile.
-- IsQuestObject returns the quest giver status and the tooltip data
-- Changed CalculatePath 'AllowSwim'
-- SetMeshPointInfo can be used to change the polygon flags
-- Added AddNavConnection and ClearNavConnections
-- ObjectCreator now works with Area Triggers
-- ReadFile/WriteFile now use EWT's directory if no path is provided
-- Added Flag 4 to SendHTTPRequest
-- Added SetObjectToken, CastSpellID
-- InitializeNavigation's Callback returns extra info in case of errors
-- Added UnitCollisionBox
-- Added IsQuestObject

------------------------- General Instructions ------------
-- For WoWs >= 7.3, EWT is loaded AFTER the addons. Because of this, use the code below to detect whether EWT's API is fully loaded:
local ewtLoaded = false
local f = CreateFrame('frame')
f:SetScript("OnUpdate", function()
    if GetObjectCount ~= nil then
        ewtLoaded = true
        -- start my bot
    end
end)

-- ADDON PROTECTION
-- If you have a popular addon in the Interface/Addons folder that uses EWT, make sure to rename/move the addon if you don't use EWT to avoid detections.
-- If you create a 'Persist' folder where EWT is located, all Lua files in it will be executed in alphabetical order every time WoW's Lua context refreshes.
-- Subdirectories can be used. You can use this to run Lua in the Character/Login screens.
-- If you create an 'Addons' folder where EWT is located, it behaves like 'Persist' but the Lua files are only executed if you are in the world.
-- IMPORTANT: This 'Addons' folder does not behave like WoW's Interface/Addons folder.
-- To simulate Saved Variables, use the PLAYER_LEAVING_WORLD event and save the variables to a file with WriteFile

-- ANTI-CRACK PROTECTION
-- Contact admin on Slack for instructions.

------------------------- Active Player -------------------

--- Stop falling.
function StopFalling ()

--- Start falling.
function StartFalling ()

--- Move to a position.
-- X           (number)  - The X coordinate
-- Y           (number)  - The Y coordinate
-- Z           (number)  - The Z coordinate
-- InstantTurn (boolean) - Whether to instantly turn toward the destination
-- Note: If using this function inside a transport (Ship, Zeppelin, Elevator, etc), you must provide coordinates relative to the transport.
function MoveTo (X, Y, Z[, InstantTurn])

-- Attempts to stop movement. You may want to use GetUnitSpeed to double-check if the speed is 0.
function StopMoving()

-- Initializes navigation meshes. The tiles must be located in 'mmaps' folder inside EWT's folder
-- Callback    (function) - Used to get a return when the tiles have been loaded because this function is asynchronous.
-- MapIDList   (string or number)   - A string with all the map IDs that should be loaded. "0 1" loads EasternKingdoms and Kalimdor. If ommited, all maps are loaded.
-- Returns     nil        - It doesn't return anything.
-- InitializeNavigation needs to be called only once per map. Upon a /reload, the meshes won't be loaded again.
-- To download the meshes, check this post https://ewtwow.com/topic/2606
-- For old expansions running 32-bit client, check this post https://ewtwow.com/topic/3031
function InitializeNavigation(Callback[, MapIDList])

-- Destroy currently loaded navigation meshes. Mainly used to "refresh" and load the meshes again.
function DestroyNavigation()

-- Returns whether the mesh for the given Map ID has been loaded
-- MapID       (number)  - The map ID returned from GetMapId()
-- returns     (boolean) - Whether the map is loaded or not.
-- Note: If there are meshes being loaded, i.e., InitializeNavigation hasn't completed yet, then it will return false.
function IsMeshLoaded(MapID)

-- Returns info about a mesh point
-- X, Y, Z     (number, number, number) - The coordinates
-- MapId       (number)                 - The map ID. If ommited, then the current map ID will be used.
-- NewFlags    (number)                 - Used to change the polygon flags. Useful to create different types of terrain or obstacles.
-- Returns: (error, dist, flags, cx, cy, cz, overPolygon, ID)
-- Number   - Error: 1 = map ID not loaded | 2 = Not initialized | 3 = Not on mesh
-- Number   - Distance to start polygon
-- Number   - Polygon/terrain flags (1 = Ground, 2 = Water, 4 = Magma/Slime)
-- Number   - X, Y, Z of the closest point on polygon
-- Boolean  - Whether the point is over the polygon or not
-- ID       - String with the polygon ID which can be used with RestoreMeshPoint
-- If the closest point XY doesnt match the given point, then the given point is not present in the mesh, i.e.
-- If you call this API while a mesh is being loaded (InitializeNavigation), it will freeze WoW until the load is done.
-- If you use NewFlags = 0, 8 or another unused flag, then you can configure navigation to ignore a polygon.
function GetMeshPointInfo(X, Y, Z [, MapId])
function SetMeshPointInfo(X, Y, Z [, MapId, NewFlags])

-- Restores the flags of a polygon that has been edited with SetMeshPointInfo 
function RestoreMeshPoint(ID)

-- Restores the flags of all polygons that have been edited with SetMeshPointInfo
function RestoreMeshPoints()

--- Calculates a path using navigation meshes.
-- MapID        (number) - The MapID returned from GetMapId()
-- FromX        (number) - The start X
-- FromY        (number) - The start Y
-- FromZ        (number) - The start Z
-- ToX          (number) - The end X
-- ToY          (number) - The end Y
-- ToZ          (number) - The end Z
-- PathFlags or StraightPath (number or bool)   - The path flags described below
-- Flags or AllowSwim (number or bool) - The terrain/polygon flags allowed: 1 = Ground, 2 = Water, 4 = Magma/Slime - AllowSwim false is equivalent to Flags = 13
-- wallDistance (number) - The distance from the wall to avoid stucks. Use 0 to disable.
-- The path flags: 1 = StraightPath, 2 = Avoid dynamic obstacles (BETA), 4 = ProjectPath: causes the coordinates to be projected down to the terrain
-- Note1: wallDistance only works if you use StraightPath = true
-- Returns a table with all the waypoints and the total distance of the path: { {X1, Y1, Z1}, {X2, Y2, Z2}, {X3, Y3, Z3}, ...}
function CalculatePath( MapID, FromX, FromY, FromZ, ToX, ToY, ToZ [, PathFlags = 5 or StraightPath = true, Flags = 7 or AllowSwim = true, WallDistance = 0] )

--- Adds an offmesh connection to the navmesh
-- FromX        (number) - The start X
-- FromY        (number) - The start Y
-- FromZ        (number) - The start Z
-- ToX          (number) - The end X
-- ToY          (number) - The end Y
-- ToZ          (number) - The end Z
-- Direction    (number) - 0 = one sided, 1 = bidirectional
-- Radius       (number) - Radius of the agent
-- MapID        (number) - Map ID for the positions
-- Note: This API is useful to tell the navigation to jump down a hill or connect coordinates that aren't normally reachable.
-- These connections do not edit the mesh files in the disk.
function AddNavConnection(fromX, fromY, fromZ, toX, toY, toZ, [Direction = 1, Radius = 2.5, MapId = GetMapId])

-- Clears all offmesh connections in the given navmesh tile.
-- FromX        (number) - The start X
-- FromY        (number) - The start Y
-- FromZ        (number) - The start Z
-- MapID        (number) - Map ID for the positions
-- A tile is a division of the entire map/continent. This doesn't clear all map connections.
function ClearNavConnections([fromX = PlayerX, fromY = PlayerY, fromZ = PlayerZ, MapId = GetMapId])

-- Adds an obstacle or a walkable region in the navmesh at the desired position.
-- X        (number) - The region X
-- Y        (number) - The region Y
-- Z        (number) - The region Z
-- Radius   (number) - The region radius
-- Obstacle (boolean)- Whether it's an obstacle or a walkable area
-- Sides    (number) - The number of sides: 3 = triangle, 4 = square, up to 6
-- MapId    (number) - Map ID for the position
-- Returns  (number) - The region ID that can be used with RemoveNavRegion
function AddNavRegion(X, Y, Z, Radius, [Obstacle = true, Sides = 4, MapId = GetMapId])

-- Removes a region that was added with AddNavRegion.
function RemoveNavRegion(ID)

-- Example using InitializeNavigation and CalculatePath:
local initNavigation = false
local ewtPath = nil
local pathIndex = 1
local stuckCount = 0
local lastX, lastY, lastZ = 0, 0, 0
local f = CreateFrame('frame')
f:SetScript("OnUpdate", function (self, event, addon)
    if ewtPath ~= nil then
        local PlayerX, PlayerY, PlayerZ = ObjectPosition("Player");
        local destX = ewtPath[pathIndex][1]
        local destY = ewtPath[pathIndex][2]
        local destZ = ewtPath[pathIndex][3]
        -- You may want to check the only the 2D (XY) distance to the waypoint instead of 3D (XYZ)
        -- if GetDistanceBetweenPositions(PlayerX, PlayerY, PlayerZ, destX, destY, destZ) < 1 then
        if sqrt(((destX - PlayerX) ^ 2) + ((destY - PlayerY) ^ 2)) < 1 and math.abs(destZ - PlayerZ) < 4 then
            pathIndex = pathIndex + 1
            -- print('Moving to next coordinates')
            if pathIndex > #ewtPath then
                pathIndex = 1
                ewtPath = nil
            end
        else
            if lastX == PlayerX and lastY == PlayerY and lastZ == PlayerZ then
                stuckCount = stuckCount + 1
                if stuckCount > 100 then
                    -- print('Stuck jumping...')
                    JumpOrAscendStart()
                    stuckCount = 0
                end
            end
            MoveTo(destX, destY, destZ)
            lastX = PlayerX
            lastY = PlayerY
            lastZ = PlayerZ
        end
    end
end)

function GoTo(toX, toY, toZ)
    if initNavigation == false then
        print('Loading meshes... please wait.')
        InitializeNavigation(function(result, extra) 
            if result == true then
                print('Initialized meshes') 
                initNavigation = true 
                GoTo(toX, toY, toZ) 
            else
                print('Failed to initialize meshes.')
                print(extra)
            end
        end)
    else
        pathIndex = 1
        ewtPath = nil
        local PlayerX, PlayerY, PlayerZ = ObjectPosition("Player");
        ewtPath, totalDist = CalculatePath(GetMapId(), PlayerX, PlayerY, PlayerZ, toX, toY, toZ, true, false, 1.5)
        print('Created path ' .. #ewtPath)
    end
end

--- Teleport to a position.
-- X           (number)  - The X coordinate
-- Y           (number)  - The Y coordinate
-- Z           (number)  - The Z coordinate
function Teleport (X, Y, Z)

-- Teleports to a given direction for a certain distance
-- Direction    (number) - 0 = Forward, 1 = Backward, 2 = Left, 3 = Right, 4 = Up, 5 = Down
-- Distance     (number) - The distance
-- Note: This API is mainly useful for precision teleporting, numpad-teleporting, macros and bypassing walls without .collision.
-- Keep in mind that going below the terrain may disconnect you.
function TeleportDirection(Direction, Distance)

--- Registers Lua callbacks for Teleport
-- before      (function) - A callback that is called before EWT teleports your character.
-- after       (function) - A callback that is called after EWT teleports your character.
function AddTeleportCallbacks(before, after)
-- Example:
function myTeleportFunc()
    AddTeleportCallbacks(
        function()
            local beforeX, beforeY, beforeZ = ObjectPosition("player")
            print('Teleported from ' .. beforeX .. ' ' .. beforeY .. ' ' .. beforeZ)
        end,
        function()
            local x, y, z = ObjectPosition("player")
            print('to x ' .. x .. ' ' .. y .. ' ' .. z)
        end
    )
end

--- Set the direction that the player is facing.
-- Direction (number) or Object (string) - The direction in radians or the object
-- Update    (boolean) - Whether to immediately notify the server
-- Note1: You can also do FaceDirection(X, Y, Update) - The Z coordinate isnt needed.
-- Note2: Direction must be between [0,2pi] otherwise you will disconnect.
function FaceDirection (Direction[, Update])

--- Set the maximum angle from the XY plane that the player can move at
-- Angle (number) - The maximum angle in degrees
-- Note that the angle must be between 0º and 90º.
function SetMaximumClimbAngle (Angle)

--- Get the current map ID, area/zone ID and the sub-zone ID 
-- return (number, number, number)
-- Examples:
-- Area/Zone = Elwynn Forest    (GetZoneText)
-- SubZone   = Goldshire        (GetSubZoneText)
function GetMapId()

------------------------- Object --------------------------

if EWT.is80 then
    ObjectType = {
        Object = 0,
        Item = 1,
        Container = 2,
        AzeriteEmpoweredItem = 3,
        AzeriteItem = 4,
        Unit = 5,
        Player = 6,
        ActivePlayer = 7,
        GameObject = 8,
        DynamicObject = 9,
        Corpse = 10,
        AreaTrigger = 11,
        SceneObject = 12,
        ConversationData = 13
    };
else
    ObjectType = {
        Object = 0,
        Item = 1,
        Container = 2,
        Unit = 3,
        Player = 4,
        GameObject = 5,
        DynamicObject = 6,
        Corpse = 7,
        AreaTrigger = 8,
        SceneObject = 9,
        ConversationData = 10
    };
end

-- Don't use this for BFA
ObjectTypes = {
    None = 0,
    Object = 1,
    Item = 2,
    Container = 4,
    Unit = 8,
    Player = 16,
    GameObject = 32,
    DynamicObject = 64,
    Corpse = 128,
    AreaTrigger = 256,
    SceneObject = 512,
    All = -1
};

--- Get an object's pointer.
-- Object  (object) - The object
-- returns (string or nil) - The pointer as a hexadecimal string prefixed by 0x or nil if the object does not exist.
-- Note: If the object doesn't exist, for example, ObjectPointer('party1target'), it returns nil.
-- This API is mainly useful to get the object address of unitIDs like 'target', 'mouseover', etc.
-- ObjectPointer('0xDEADBEEF') simply returns '0xDEADBEEF' and does NOT check if the address exists in the object manager. Don't do this.
function ObjectPointer (Object)

--- Get whether an object exists in the object manager with O(n) performance.
-- Object  (object)  - The object
-- returns (string or nil) - The pointer as a hexadecimal string prefixed by 0x or nil if the object does not exist.
-- Note that if the object does not exist in the object manager it is invalid and should not be used.
-- This API has O(n) performance, which means that the more objects in the object manager, the slower it is.
-- This API is only useful to check if '0x' strings are *really* valid. It should never be used
-- if you are properly using GetObjectCount since you will always work with objects that exist.
-- This API is similar to ObjectPointer, but it checks if the object exists in the object manager.
-- If you pass a unitID, like ObjectExists('target'), then its performance is the same as ObjectPointer('target').
function ObjectExists (Object)

--- Get whether an object exists in the object manager with O(1) performance.
-- Object  (object)  - The object
-- returns (string or nil) - The pointer as a hexadecimal string prefixed by 0x or nil if the object does not exist.
-- Note: If you pass an invalid object, this will generate a crash log.
-- This API works like WoW's UnitIsVisible, but instead of returning boolean, it returns string or nil. 
-- UnitIsVisible only applies to Units while ObjectIsVisible applies to all object types.
-- ObjectIsVisible has O(1) performance, which means that, no matter how many units in the object manager, the speed is the same. 
-- ObjectIsVisible/UnitIsVisible may create crash logs if you provide '0x' strings of objects that don't exist.
function ObjectIsVisible (Object)

-- Get whether a game object is collidable
-- GameObject (object)      - The game object
-- SetCollision (boolean)   - Whether the object's collision should be set or not.
-- returns    (boolean)
-- Can be used to check if some door is opened, i.e., no collision.
function ObjectIsCollidable(Object [, SetCollision])

-- Get the bounding box of a game object
-- GameObject (object)      - The game object
-- returns    (number, number, number, number, number, number)   - Minimum XYZ, Maximum XYZ
function ObjectBoundingBox(Object)

-- Get or set the flags of a game object
-- GameObject (object)      - The game object
-- NewFlags   (number)      - The new game object flags
-- returns    (number)      - The flags
-- Note: You may want to use bit.bor or bit.band to detect if some flag exists.
function GameObjectFlags(Object, [NewFlags])
-- Check whether door is open:
bit.band(GameObjectFlags(object), 0x1) > 0 

--- Get an object's position.
-- Object  (object)                 - The object
-- GetRaw  (boolean)                - Whether it should return the raw values as well. Useful for transport debugging.
-- returns (number, number, number) - The X, Y, and Z coordinates
-- Note: If the object doesn't exist, it returns (nil, nil, nil)
-- Note2: When in a transport, the raw position is relative to the transport's matrix.
function ObjectPosition (Object [, GetRaw])

--- Get an object's facing and display facing.
-- Object  (object)         - The object
-- GetRaw  (boolean)        - Whether it should return the raw value as well. Useful for transport debugging.
-- returns (number, number) - The facing (angle in XY) and display facing in radians between 0 and 2PI.
-- Note: If the object doesn't exist, it returns nil.
-- Note2: When in a transport, the raw facing is relative to the transport's facing.
function ObjectFacing (Object [, GetRaw])
GetObjectFacing = ObjectFacing

--- Get an object's GUID.
-- Object  (object) - The object
-- returns (string or nil) - The GUID as a string or nil if the object doesn't exist.
-- Note: This API is mainly for WoW Classic 1.12.1, because UnitGUID doesn't exist in this version
-- and to retrieve the GUID of GameObjects with the "mouseover" token.
function ObjectGUID (Object)

--- Get an object's name.
-- Object  (object) - The object
-- returns (string) - The name
function ObjectName (Object)

--- Get an object's type ID.
-- Object  (object)  - The object
-- returns (integer) - The type ID or nil if the object is invalid
function ObjectID (Object)

--- Get an object's entry ID.
-- Object  (object)  - The object
-- returns (integer) - The entry ID or nil if the object is invalid
-- Note: This API is similar to ObjectID, but faster because it doesnt retrieve the ID from the object's GUID.
function ObjectEntryID (Object)

--- Get or set an object's dynamic flags.
-- Object  (object)  - The object
-- NewFlags (number) - The new flags
-- returns (integer) - The flags or nil.
-- Note: You may want to use bit.bor or bit.band to detect if some flag exists.
-- You can use NewFlags to change the object flags. Each object type (Unit, GameObject, Corpse, etc) has different flags.
-- GameObject: https://github.com/TrinityCore/TrinityCore/blob/master/src/server/game/Miscellaneous/SharedDefines.h#L2511
-- Unit: https://github.com/TrinityCore/TrinityCore/blob/master/src/server/game/Miscellaneous/SharedDefines.h#L4702
function ObjectDynamicFlags (Object [, NewFlags])

--- Get or set an object's scale.
-- Object   (object)    - The object
-- NewScale (number)    - The new scale
-- returns  (number)    - The scale.
-- Note: The scale is the essentially the size of the object. You may want to update UpdateModel() to reflect its changes.
function ObjectScale (Object [, NewScale])

--- Get whether an object is of a type.
-- Object  (object)            - The object
-- Type    (ObjectTypes member) - The type
-- returns (boolean)           - Whether the object is of the type
-- Note: Don't use this for BFA. Use ObjectRawType instead.
function ObjectIsType (Object, Type)

--- Get an object's type flags.
-- Object  (object)  - The object
-- returns (integer) - One or more members of the ObjectTypes table combined with bit.bor
-- Note: Don't use this for BFA. Use ObjectRawType instead.
function ObjectTypeFlags (Object)

--- Get an object's type.
-- Object  (object)  - The object
-- returns (integer) - One member of the ObjectType table.
function ObjectRawType (Object)

function ObjectIsPlayer(object)
    local type = ObjectRawType(object)
    return type == ObjectType.Player or type == ObjectType.ActivePlayer
end

function ObjectIsUnit(object)
    local type = ObjectRawType(object)
    return type == ObjectType.Unit or type == ObjectType.Player or type == ObjectType.ActivePlayer
end

function ObjectIsGameObject(object)
    return ObjectRawType(object) == ObjectType.GameObject
end

function ObjectIsAreaTrigger(object)
    return ObjectRawType(object) == ObjectType.AreaTrigger
end

function GetDistanceBetweenPositions (X1, Y1, Z1, X2, Y2, Z2)
    return math.sqrt(math.pow(X2 - X1, 2) + math.pow(Y2 - Y1, 2) + math.pow(Z2 - Z1, 2));
end

--- Get the distance between two objects.
-- Object1 (object) - The first object
-- Object2 (object) - The second object
-- returns (number) - The distance
function GetDistanceBetweenObjects (Object1, Object2)

--- Get the angles between two objects.
-- Object1 (object)         - The first object
-- Object2 (object)         - The second object
-- returns (number, number) - The facing (angle in XY) and pitch (angle from XY) from the first object to the second
function GetAnglesBetweenObjects (Object1, Object2)

--- Get the position that is between two objects and a specified distance from the first object.
-- Object1  (object)                 - The first object
-- Object2  (object)                 - The second object
-- Distance (number)                 - The distance from the first object
-- returns  (number, number, number) - The X, Y, and Z coordinates
function GetPositionBetweenObjects (Object1, Object2, Distance)

function GetPositionFromPosition (X, Y, Z, Distance, AngleXY, AngleXYZ)
    return math.cos(AngleXY) * Distance + X,
    math.sin(AngleXY) * Distance + Y,
    math.sin(AngleXYZ) * Distance + Z;
end

function GetAnglesBetweenPositions (X1, Y1, Z1, X2, Y2, Z2)
    return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2), 
    math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi;
end

function GetPositionBetweenPositions (X1, Y1, Z1, X2, Y2, Z2, DistanceFromPosition1)
    local AngleXY, AngleXYZ = GetAnglesBetweenPositions(X1, Y1, Z1, X2, Y2, Z2);
    return GetPositionFromPosition(X1, Y1, Z1, DistanceFromPosition1, AngleXY, AngleXYZ);
end

-- Returns the last position sent to the server.
-- Returns (number, number, number) - The XYZ position
function GetServerPosition()

--- Get whether an object is facing another.
-- Object1 (object)  - The first object
-- Object2 (object)  - The second object
-- returns (boolean) - Whether the first object is facing the second
-- Note: For custom angles, check UnitIsFacing API.
function ObjectIsFacing (Object1, Object2)

--- Get whether an object is facing a position.
-- Object1 (object)  - The first object
-- X       (number)  - The X coordinate
-- Y       (number)  - The Y coordinate
-- returns (boolean) - Whether the object is facing the given coordinates
function ObjectIsFacingPosition (Object, X, Y)

--- Get whether an object is behind another.
-- Object1 (object)  - The first object
-- Object2 (object)  - The second object
-- returns (boolean) - Whether the first object is behind the second
function ObjectIsBehind (Object1, Object2)

--- Get one of an object's descriptors.
-- Object  (object)      - The object
-- Offset  (integer)     - The descriptor offset
-- Type    (Type member) - The descriptor type
-- returns (Type)        - The descriptor value
function ObjectDescriptor (Object, Offset, Type)

--- Get one of an object's fields.
-- Object  (object)      - The object
-- Offset  (integer)     - The field offset
-- Type    (Type member) - The field type
-- returns (Type)        - The field value
function ObjectField (Object, Offset, Type)

--- Get the object's animation state.
-- Object  (object)      - The object
-- returns (number)      - The state
-- Mainly useful to check when the Fishing Bobber has a fish. Call this every frame to monitor the animation.
function ObjectAnimation (Object)

--- Interact with Object. Useful for 1.12.1 and 2.4.3 since InteractUnit isn't available in these versions.
-- Object  (object)      - The object
-- returns (boolean)     - True if the object is valid, False if not
function ObjectInteract (Object)

-- Returns whether an object is a quest object and the quest giver status.
-- Returns (boolean, status, tooltip1, tooltip2) - Whether it's a quest object, the quest giver status and the tooltip data
-- Note: The boolean and the tooltip returns only work on Shadowlands.
-- Status: 
-- Classic and BFA: 5 = Incomplete 8 = HasQuest   10 = CompletedQuest
-- Shadowlands:     5 = Incomplete 9 = DailyQuest 10 = HasQuest        12 = CompletedQuest
-- If you completed the requirements of a quest, then it will return false for the quest object/NPC.
function IsQuestObject(Object)

-- Set an Object's GUID to the given Token
-- Tokens supported: mouseover, target, focus, arena0-15
-- Returns (guid, guid)  - NewGUID, OldGUID
function SetObjectToken(Object, Token)

------------------------- Object Manager ------------------

--- Get the number of objects in the object manager and optionally 2 tables with all objects that were updated in the frame.
-- GetUpdates (boolean)  - True to get the tables with the objects that were updated in the frame.
-- Id (string)           - A simple string identifier to avoid conflicts between multiple addons calling GetObjectCount(true) in the same frame.
-- returns (integer, boolean, table, table) - The total number of objects, if the object manager was updated, the added objects and the removed objects.
-- Note: This should be the first API that you should call before using the other object manager functions.
-- Ideally, call it once every frame with an OnUpdate frame event.
-- You can use table.getn or # to get the number of objects in the returned tables.
-- Be careful with caching: the object manager can be updated after your GetObjectCount call within the same frame. 
function GetObjectCount ([GetUpdates, Id])
ObjectCount = GetObjectCount

-- Example:
local initOM = true
local myOM = {}
local myFrame = CreateFrame("Frame")
myFrame:SetScript("OnUpdate", function ()
    -- The first frame call to GetObjectCount(true) should have total == #added and 'added' will contain all objects.
    -- The next GetObjectCount(true) calls should have only the updated objects.
    local total, updated, added, removed = GetObjectCount(true, "customId")
    if initOM then
        initOM = false
        for i = 1,total do
            local thisUnit = GetObjectWithIndex(i)  -- thisUnit contains the '0x' string representing the object address 
            -- Do something with the unit
            myOM[thisUnit] = 1
        end
    end
    for k,v in pairs(added) do
        -- k - Number = Array index = Don't confuse this with the Object Index used by GetObjectWithIndex. It's not the same thing.
        -- v - String = Object address
        print('Added ' .. v)
        myOM[v] = 1
        if ObjectIsUnit(v) then
            local posX, posY, posZ = ObjectPosition(v)
        end
    end
    for k,v in pairs(removed) do
        print('Removed ' .. v)
        myOM[v] = nil
    end
    local manualCount = 0
    for k,v in pairs(myOM) do
        manualCount = manualCount + 1
    end
    if #added ~= 0 or #removed ~= 0 then
        print('Total ' .. total .. ' ' .. #added .. ' ' .. #removed .. ' Manual ' .. manualCount)
    end
end);

--- Get an object in the object manager from its index.
-- Index   (integer) - The one-based index of the object. Starts at 1.
-- returns (object)  - The object
-- Note: If an object is at index 30, this does NOT mean that in the next frame it will be at index 30 again.
-- This API isn't really needed if you are properly using GetObjectCount(true).
function GetObjectWithIndex (Index)
ObjectWithIndex = GetObjectWithIndex

--- Get an object in the object manager from its pointer.
-- Pointer (string) - A pointer to the object as a hexadecimal string prefixed by 0x
-- returns (object) - The object
-- Note: Avoid using this API. Prefer GetObjectWithIndex instead. It's here only because of backwards compatibility.
function GetObjectWithPointer (Pointer)

--- Get an object in the object manager from its GUID.
-- GUID    (string) - The GUID
-- returns (object) - The object or nil if it is not in the object manager
function GetObjectWithGUID (GUID)

--- Gets the active player.
-- returns (object or nil) - The active player object or nil if it does not exist.
function GetActivePlayer ()

--- Gets the active mover.
-- returns (object or nil) - The active mover object or nil if it does not exist.
-- Note: This is usually the Active Player. When you get mind controlled, lose control of your character or control 
-- something else, then the Active Mover is different.
function GetActiveMover ()

------------------------- Unit ----------------------------

--- Get an object's facing direction.
-- @param Object The object. It must be of type Unit.
-- @param Object The object.
-- @param Angle The frontal cone angle in degrees. Default: 180 degrees
-- @return Boolean. Whether it is facing or not.
-- Note: This API is similar to ObjectIsFacing but it supports this extra frontal cone angle that is useful for some spells, like Shockwave.
function UnitIsFacing (Object, Object [, Angle])
function UnitIsFacing (Object, X, Y [, Angle])

MovementFlags = {
    Forward = 0x1,
    Backward = 0x2,
    StrafeLeft = 0x4,
    StrafeRight = 0x8,
    TurnLeft = 0x10,
    TurnRight = 0x20,
    PitchUp = 0x40,
    PitchDown = 0x80,
    Walking = 0x100,
    Immobilized = 0x400,
    Falling = 0x800,
    FallingFar = 0x1000,
    Swimming = 0x100000,
    Ascending = 0x200000,
    Descending = 0x400000,
    CanFly = 0x800000,
    Flying = 0x1000000,
};

-- Returns whether the unit is falling or not.
-- Returns (boolean)
function UnitIsFalling(Unit)

-- Returns whether the unit is standing, sleeping or sit.
-- Returns (number)     - The state: 0 = stand, 1 = sit, 3 = sleep
function UnitIsStanding(Unit)

-- Returns the unit's mount display ID.
-- Returns (number)     - The mount display ID. If 0, the unit isn't mounted.
-- Note: WoW has the IsMounted API but it only works for the active player.
function UnitIsMounted(Unit)

--- Get the unit's movement address.
-- Unit    (unit)    - The unit
-- returns (integer) - The movement struct address
-- Note: If the object is not a unit, then it returns nil.
function GetUnitMovement (Unit)

--- Get the unit's speed.
-- Unit    (unit)    - The unit
-- returns (number)  - currentSpeed, groundSpeed, flightSpeed, swimSpeed
-- Note: If the object is not a unit, then it returns nil.
-- This API is only available on 1.12.1 and 2.4.3.
function GetUnitSpeed (Unit)

-- Get the unit's transport
-- returns (object, guid)  - The object and its GUID or nil if the unit is not on a transport
function GetUnitTransport(Unit)

--- Get a unit's movement flags.
-- Unit    (unit)    - The unit
-- returns (integer) - The movement flags
function UnitMovementFlags (Unit)

--- Set a unit's movement flags.
-- Unit    (unit)    - The unit
-- Flags   (number)  - The new movement flags
-- returns (boolean) - True if it worked or some error if not.
function SetMovementFlags (Unit, Flags)

--- Send the player's movement state to the server.
-- Opcode (number)    - Optionally set a movement opcode - Defaults to CMSG_MOVE_HEARTBEAT
--- returns (boolean) - True if it worked, False if not. It will only fail if there's no player active.
function SendMovementUpdate ([Opcode])

--- Get a unit's bounding radius.
-- Unit    (unit)   - The unit
-- returns (number) - The bounding radius
function UnitBoundingRadius (Unit)

--- Get a unit's combat reach.
-- Unit    (unit)   - The unit
-- returns (number) - The combat reach
function UnitCombatReach (Unit)

-- Get or set a unit's collision box
-- Unit         (unit)                      - The unit
-- Returns      (number, number, number)    - The radius, the height and the step up value
-- Pass 0 or nil to skip a field.
-- If you change the Height, you may disconnect when you start swimming.
-- Changing the StepUp allows you to climb higher angles, but you may disconnect if you climb too fast.
-- Changing the Radius allows you to get closer to walls/edges, but you may disconnect if you move too quickly next to them.
-- (Dis)Mounting restores your original collision box. You may want to create an OnUpdate function to call this API every frame.
function UnitCollisionBox (Unit [, NewRadius = 0, NewHeight = 0, NewStepUp = 0])
-- Example script - You may want to change the parameters in case of disconnections:
local f = CreateFrame('frame')
f:SetScript('OnUpdate', function()
    UnitCollisionBox(GetActiveMover(), 0.1, 0, 20)
end)

--- Get or set a unit's flags
-- Unit         (unit)   - The unit
-- NewFlags1    (number) - The new flags
-- NewFlags2    (number) - The new flags
-- NewFlags3    (number) - The new flags
-- NewNpcFlags  (number) - The new npc flags
-- returns (number, number, number, number) - Flags1, Flags2, Flags3, NpcFlags that belong to a Unit
-- Note: You may want to use bit.bor or bit.band to detect if some flag exists.
-- Note: Flags are described here https://github.com/TrinityCore/TrinityCore/blob/master/src/server/game/Entities/Unit/UnitDefines.h#L165
-- Note2: If you just want to set NewFlags3, pass 'nil' to the other flags
function UnitFlags (Unit [, NewFlags1, NewFlags2, NewFlags3, NpcFlags])
-- Example:
local bla = UnitFlags("player")
local inCombat = bit.band(bla, 0x00080000) > 0

-- Get or set a player's flags
-- Player       (player) - The player
-- NewFlags1    (number) - The new flags
-- NewFlags2    (number) - The new flags
-- Note: You may want to use bit.bor or bit.band to detect if some flag exists.
-- Note: Flags are described here https://github.com/TrinityCore/TrinityCore/blob/master/src/server/game/Entities/Player/Player.h#L400
function PlayerFlags(Player [, NewFlags1, NewFlags2])

--- Get a unit's target.
-- Unit    (unit) - The unit
-- returns (unit) - The target or nil if there is none
-- Note: This function reads a descriptor that is updated by the server. Don't use it to check if you have a target.
function UnitTarget (Unit)

--- Get a unit's creature type ID.
-- Unit    (unit) - The unit
-- returns (number) - The type ID
-- Note: This function is similar to UnitCreatureType, but instead of returning a string, it returns an ID
function UnitCreatureTypeID (Unit)

--- Get an object's creator.
-- Object  (object) - The unit, game object or area trigger
-- returns (unit) - The creator or nil if there is none
function ObjectCreator (Unit)
UnitCreator = ObjectCreator

--- Get an object's display ID.
-- Object  (object) - The unit, game object or corpse
-- returns (unit)   - The ID or nil if the object is invalid
function ObjectDisplayID (Object)

--- Get a game object's sub-type
-- Object  (object)             - The game object
-- returns (number, string)     - The sub-type ID and the type string
-- Example of strings: mailbox, door, fishingNode, gatheringNode, spellFocus, generic, etc
function GetGameObjectType(GameObject)

--- Get whether a unit can be looted.
-- Unit    (unit)    - The unit
-- returns (boolean) - Whether the unit can be looted
function UnitCanBeLooted (Unit)

--- Get whether a unit can be skinned.
-- Unit    (unit)    - The unit
-- returns (boolean) - Whether the unit can be skinned
-- Note: You might want to check UnitFlags3 returned by UnitFlags() to see if the unit has been skinned or not.
-- Classic: Flags3 & 0x8000    BFA: Flags3 & 0x20000 
function UnitCanBeSkinned (Unit)

--- Set a unit's display ID.
-- Unit      (unit)    - The unit
-- DisplayID (integer) - The new display ID
-- returns (boolean)   - Whether the display was changed or not
-- Note that UnitUpdateModel must be called for the change to be displayed.
function UnitSetDisplayID (Unit, DisplayID)
SetDisplayID = UnitSetDisplayID

-- Sets the unit's mount display ID
function SetMountDisplayID(Unit, DisplayID)

-- Set's the unit's item display ID
function SetVisibleItem(Unit, SlotID, ItemID [, ItemAppearanceModID])

-- Set's the unit's item enchant ID
function SetVisibleEnchant(Unit, SlotID, EnchantID)

--- Update a unit's model.
-- Unit (unit) - The unit
function UnitUpdateModel (Unit)
UpdateModel = UnitUpdateModel

--- Get the spell IDs being casted or channelled by the unit
-- Unit    (unit)           - The unit
-- returns (number, number, object, object) - (Spell Cast ID, Spell Channel ID, Cast Object, Channel Object) 
-- Note1: If no spells are being casted, it returns 0, 0, nil, nil. On Classic, you only have the info about your player, not targets.
-- Note2: On certain WoW expansions, the Cast Object and Channel Object arent erased after cast. So you must always check if CastID and ChannelID arent 0.
-- Note3: On Classic, you may also look at the following libraries to provide spell info:
-- https://github.com/rgd87/LibClassicDurations
-- https://github.com/rgd87/LibClassicCasterino
function UnitCastID (Unit)

--- Get or set unit pitch.
-- Unit       (unit)          - The unit
-- newPitch   (number)        - The new pitch
-- update     (boolean)       - Whether to immediately notify the server
-- returns    (number)        - The unit pitch.
-- Note: If setting the pitch, it doesnt return anything. Also, pitch returns 0 for other units which aren't the current active mover.
function UnitPitch (Unit[, newPitch, update])

------------------------- Missile -------------------------

-- Casts the spell ID, optionally on a target.
-- Id       (Number)           - Spell ID
-- Target   (object)           - Optional target
-- Note: You may want to use the addon idTip to get the spell ID: https://www.curseforge.com/wow/addons/idtip
function CastSpellID(Id [, Target])

-- Get the number of missiles in flight
function GetMissileCount()

-- Get the missile info from its index
-- SpellID          (number)                    - The spell ID
-- SpellVisualID    (number)                    - The spell Visual ID
-- X, Y, Z          (number, number, number)    - The current missile position   - This position changes while the missile is in flight
-- Caster           (object)                    - Object that casted the missile
-- SX, SY, SZ       (number, number, number)    - The start XYZ position - This is a fixed position
-- Target           (object)                    - Target object of the missile
-- TX, TY, TZ       (number, number, number)    - The end XYZ position - This position may change if the target is moving.
-- This API is useful to query spells that have been casted and are going to land somewhere.
-- So you can use it to dodge spells casted by bosses, cast Iceblock before a spell hits you, etc: https://streamable.com/cfxo59
-- Examples: Freezing Trap (Hunter) does not have a Target.
function GetMissileWithIndex(Index)
-- Example:
local f = CreateFrame('frame')
f:SetScript('OnUpdate', function()
    local count = GetMissileCount()
    if count > 0 then
        print('Count ' .. count)
        for i = 1, count do
            local spellId, visualId, x, y, z, caster, sx, sy, sz, target, tx, ty, tz = GetMissileWithIndex(i)
            print(i .. ' ID ' .. spellId .. ' ' .. tostring(caster) .. ' ' .. tostring(target))
            print('pos ' .. x .. ' ' .. y .. ' ' .. z)
            print('source ' .. sx .. ' ' ..  sy .. ' ' .. sz)
            print('target ' .. tx .. ' ' .. ty .. ' ' .. tz)
        end
    end
end)

------------------------- Actors --------------------------

-- Actors are client-side objects that are loaded that do not belong to the object manager.
-- They have a different GUID and are collidable.
-- Get the number of loaded actors
function GetActorCount()

-- Get the actor info from its index
-- GUID                 (string)                    - The actor GUID (ClientActor)
-- X, Y, Z              (number, number, number)    - The actor position
-- XYZ                  (number, number, number)    - Minimum bounding box
-- XYZ                  (number, number, number)    - Maximum bounding box
function GetActorWithIndex(Index)

------------------------- World ---------------------------

HitFlags = {
    M2Collision = 0x1,
    M2Render = 0x2,
    WMOCollision = 0x10,
    WMORender = 0x20,
    Terrain = 0x100,
    WaterWalkableLiquid = 0x10000,
    Liquid = 0x20000,
    EntityCollision = 0x100000,
};

--- Perform a raycast between two positions.
-- StartX  (number)                 - The starting X coordinate
-- StartY  (number)                 - The starting Y coordinate
-- StartZ  (number)                 - The starting Z coordinate
-- EndX    (number)                 - The ending X coordinate
-- EndY    (number)                 - The ending Y coordinate
-- EndZ    (number)                 - The ending Z coordinate
-- Flags   (integer)                - One or more members of the HitFlags table combined with bit.bor
-- returns (number, number, number, guid) - The XYZ coordinates of the hit position, the collision GUID, or nil if there was no hit. 
-- Be careful with how often you call this API because your FPS can drop a lot.
-- For generic LoS checks, use 0x100111 for Flags (M2, WMO, Terrain, Entity)
-- CActor's are M2 objects that have a GUID but they are not in the object manager. Their GUID are like "ClientActor-1-1-23"
function TraceLine (StartX, StartY, StartZ, EndX, EndY, EndZ [, Flags])

--- Equivalent to TraceLine(StartX, StartY, 10000, StartX, StartY, -10000, Flags)
-- StartX  (number)                 - The starting X coordinate
-- StartY  (number)                 - The starting Y coordinate
-- Returns (number, number, number) - The X, Y and Z
function GetGroundZ(StartX, StartY [, Flags])
    return TraceLine(StartX, StartY, 10000, StartX, StartY, -10000, Flags)
end

--- Get the camera position.
-- returns (number, number, number) - The XYZ coordinates of the camera
function GetCameraPosition ()

--- Cancel the pending spell if any.
function CancelPendingSpell ()

--- Simulate a click at a position in the game-world.
-- X     (number)  - The X coordinate
-- Y     (number)  - The Y coordinate
-- Z     (number)  - The Z coordinate
-- Right (boolean) - Whether to right click rather than left click
function ClickPosition (X, Y, Z[, Right])
CastAtPosition = ClickPosition

--- Get information about the last click.
-- returns (number, number, number, number, object) - The XYZ coordinates of the click, the click type and the object that was clicked.
-- Click Type: 1 = Normal Terrain/World Click | 2 = Clicked on some Unit/GameObject
-- Object - string or nil - The address of the last clicked object or nil if it doesn't exist.
-- Note: If no World Frame is available, it returns nil.
-- For WoWs < WOTLK, the object does not clear after a terrain click.
function GetLastClickInfo ()

--- Get whether an AoE spell is pending a target.
-- returns (boolean) - Whether an AoE spell is pending a target
function IsAoEPending ()
    return SpellIsTargeting()
end

-- Get the ID of the spell pending a cast.
-- Returns (number or nil if no spell is pending, i.e., IsAoEPending() == false)
function GetTargetingSpell()

--- Get the screen coordinates relative from World coordinates
-- X        (number)  - The X coordinate.
-- Y        (number)  - The Y coordinate.
-- Z        (number)  - The Z coordinate.
-- returns  (number, number, boolean) - The X and Y screen coordinates for the XYZ coordinates and whether they are in front of the camera or not.
-- Note: Top-left (0, WorldFrame:GetTop())     Bottom-Right (WorldFrame:GetRight(), 0)
function WorldToScreen (X, Y, Z)

-- This returns the normalized X and Y screen coordinates. (0,0) = top-left, (1,1) = bottom-right
-- Negative values mean that the coordinates are outside the screen bounds.
function WorldToScreenRaw(X, Y, Z) 

-- Example moving mouse to your target and then sending a click after some delay.
local tx, ty, tz = ObjectPosition("target")
local x, y = WorldToScreenRaw(tx, ty, tz)
local sx, sy = GetWoWWindow()
MoveMouse(x * sx, y * sy)
C_Timer.After(0.1, function() SendClick(true) end)

--- Get the World coordinates from screen coordinates
-- X        (number)  - The X coordinate.
-- Y        (number)  - The Y coordinate.
-- Flags    (number)  - One or more members of the HitFlags table combined with bit.bor
-- returns  (number, number, number) or nil if it failed - The XYZ world coordinates
-- Note: This API uses TraceLine internally so be careful with how often you call it so performance is not affected.
function ScreenToWorld (X, Y [, Flags] )

-- Causes the game to load terrain info at the given coordinates
-- X        (number)
-- Y        (number)
-- Z        (number)
-- returns  (boolean) - True on success, False otherwise
-- Note: This API is useful to call TraceLine on areas far away from the player that arent currently loaded by the game.
-- Without WorldPreload, TraceLine will return wrong values. Also, it only works in the same continent.
function WorldPreload(X, Y, Z)

--- Return whether the given coordinates are in front of WoW's camera
-- X        (number)  - The X coordinate.
-- Y        (number)  - The Y coordinate.
-- Z        (number)  - The Z coordinate.
-- returns  (boolean) - Whether they are in front or not.
-- Note: This API isn't really needed if you are already calling WorldToScreen.
function IsInFront (X, Y, Z)

--- Return the width and height of WoW's client window.
-- Width    (number)
-- Height   (number)
-- Note: On Windowed Mode, WoW's window has a border. This border is not considered.
-- This API should be used with DirectX drawing functions. It is the raw window size and is not affected by UI scale.
function GetWoWWindow()

--- Return the mouse position relative to WoW's window and your screen/monitor
-- return (number, number, number, number) or nil if something failed - X and Y relative to WoW, X and Y relative to your screen/monitor
-- This API can be used with ScreenToWorld to get 3D world coordinates where the mouse is. 
function GetMousePosition()

--- Return the corpse 3D world coordinates and map ID.
-- return (number, number, number, number) - XYZ and the MapId - If the corpse doesnt exist, all 3 coordinates are 0 and the map Id is -1 
function GetCorpsePosition()

-- Get the auction items and their exact remaining time
-- IsBlackMarket    (boolean)           - Whether it should read the Black Market
-- Returns          (table of strings)  - Table with "id seconds" for all items.
-- If querying a regular AH, it returns 3 tables: Browse tab, Auction tab and Bid tab
-- The item order is the same as the one shown in the opened AH.
-- Regular AH isn't working yet for BFA due to Auction House revamp.
-- You may want to use the events AUCTION_HOUSE_SHOW/AUCTION_HOUSE_CLOSED/BLACK_MARKET_OPEN/BLACK_MARKET_CLOSE
function GetAuctionTimers([IsBlackMarket = false])
-- Example:
function printItems(items)
    for k,v in pairs(items) do
        for id, time in pairs(v) do
            print(k .. ' ' .. id .. ' ' .. time)
        end
    end
end

local browse, auctions, bids = GetAuctionTimers()
printItems(browse)
printItems(auctions)
printItems(bids)

------------------------- Hacks ---------------------------

-- Check this page for all possible commands: https://ewtwow.com/topic/167/full-command-list

--- Get whether a hack is enabled.
-- Hack    (string)       - The hack command
-- returns (boolean)      - Whether the hack is enabled
function IsHackEnabled (Hack)

--- Set whether a hack is enabled.
-- Hack   (string)       - The hack command
-- Enable (number or boolean)  - Whether the hack is to be enabled. 
-- returns (boolean)     - True if the hack was found.
-- Note: You can also use RunMacroText('.command 1') to enable a hack instead of calling this API.
function SetHackEnabled (Hack, Enable)
SetOptionEnabled = SetHackEnabled

-- Sets a CVar without the game limitation.
-- Name     (string)                        - The CVar name
-- Value    (number, boolean or string)     - The new CVar value
function SetCVarEx(Name, Value)
-- On Classic, the cameraDistanceMaxZoomFactor CVar maximum value is 4 while on Retail it is 2.6.
-- You can do SetCVarEx("cameraDistanceMaxZoomFactor", 4) on Retail and your camera distance will increase.
-- This distance is limited up to 50 yards.

------------------------- File ----------------------------

--- Get the names of the files in a directory.
-- Path    (string) - The path to the files
-- returns (table)  - The file names
-- Example: "C:\*" would retrieve the names of all of the files in C:\.
-- Example: "C:\*.dll" would retrieve the names of all of the .dll files in C:\.
function GetDirectoryFiles (Path)

--- Get the names of the directories in a directory.
-- Path    (string) - The path to the directories
-- returns (table)  - The directory names
-- Example: "C:\*" would retrieve the names of all of the directories in C:\.
-- Example: "C:\Program Files*" would retrieve the names of the program files directories in C:\.
function GetSubdirectories (Path)

--- Get the contents of a text file.
-- Path    (string) - The file path
-- Flags   (number) - Flags that control the behavior of ReadFile
-- 0x1 AsBinary - Whether the file contents should be returned as a table of bytes
-- 0x2 Execute  - Whether the file should be executed internally (mainly to avoid using RunString)
-- returns (string, table or number) - The file contents as string or table of bytes, or whether the file was executed correctly (1 = yes, 0 = no)
-- If the file doesn't exist, it returns nil.
-- Note: The table contains unsigned numbers, so {0x41, 0x42, 0x43, 0x85, 0xFE, -5, -10} will return {65, 66, 67, 133, 254, 251, 246}
function ReadFile (Path [, Flags])

--- Set the contents of or append a text file.
-- Path   (string)  - The file path
-- Contents (string or table)  - The file contents as a string or table of bytes
-- Append (boolean) - Whether to append rather than overwrite
-- CreatePath (boolean) - Whether to create directories for the given file path.
-- Note: If you provide just a filename in Path, then it will create the file where EWT is located.
function WriteFile (Path, Contents[, Append, CreatePath])

--- Unzips a regular .zip file.
-- Path        (string)  - The file path
-- Destination (string)  - Where the file should be extracted.
function UnzipFile (Path [, Destination = EWT directory])

--- Creates a directory (folder) at the given path.
-- Path    (string) - The file path
-- returns (boolean) - True if the folder was created successfully or it already existed. False if it failed.
-- Note: If you pass a path like "D:\\myaddon\\rotations\\mage", 3 folders will be created.
function CreateDirectory (Path)

-- Whether a directory (folder) exists at the given path. 
-- Returns (boolean)    - Whether it exists
function DirectoryExists(Path)

--- Get the directory that the hack is in.
-- @return The directory that the hack is in.
function GetHackDirectory ()

--- Get the directory that WoW is in.
-- returns (string) - The directory that WoW is in
function GetWoWDirectory ()

------------------------- Scripts -------------------------

--- Load a script from the Scripts folder.
-- FileName (string) - The script file name
-- returns  - True or false if the script executed correctly, or nil if the file was not found.
-- Note: The Scripts folder should be created where EWT is located.
function LoadScript (FileName)

--- Get the file name of the currently executing script.
-- returns (string) - The file name of the currently executing script
-- Note that this can only be called from within a script.
function GetScriptName ()

-- Add a Lua script that will be called every time WoW creates a new Lua context.
-- This API can be used to run scripts at Character Selection or Login screens.
-- String   (string)   - The Lua script
-- Name     (string)   - The name of the Lua script
-- returns true or false if the Script was executed correctly. 
-- Note1: The Lua script will be executed when you enter in game, logout or do a /reload.
-- Note2: EWT does NOT spam your Lua script. Use C_Timer or a frame with OnUpdate for that.
-- Note3: You can also create a folder named 'Persist' and add .lua files to it to achieve the same behavior. The files are executed in alphabetical order.
function AddLuaString (String, Name)

-- Example:
AddLuaString([==[message('Hello')]==], 'MyScript')
AddLuaString([==[f = CreateFrame('Frame') f:SetScript('OnUpdate', function() if AccountLoginUI then  end)]==], 'MyScript')

-- Remove a Lua script that was added with AddLuaScript
-- Name     (string)    - The name of the Lua script
-- returns  (number)    - 1 if it was removed, 0 if not
function RemoveLuaString (Name)

-- Runs a Lua script. This API is similar to RunScript, but with extra protection.
-- String   (string or table of bytes)    - The Lua script. The table of bytes can be taken from ReadFile.
-- returns  (number)    - 1 if it executed correctly, 0 if not
function RunString (String)

-- Creates a Lua function from a memory address.
-- Name     (string)    - The name of the Lua function
-- Address  (number)    - The address of the function. This is the raw C-function address, not the one that you get from print(). 
-- returns  (number)    - 1 if it executed correctly, 0 if not
function RegisterLuaFunction (Name, Address)

------------------------- Callbacks -------------------------

--- Adds a Lua callback for a sent or received game packet (not a socket packet).
-- mode     (string)    - "send" or "recv" to listen to sent/received packets
-- opcode   (number)    - The opcode that you want to listen. -1 listens everything.
-- callback (function)  - Your Lua callback returning data and opcode
-- returns string (ID of packet callback which is used by RemovePacketCallback)
-- Example for 3.3.5 using CMSG_MOVE_JUMP: /script AddPacketCallback("send", 0xBB, function(data, opcode) print(data) end)
-- Note: Packet callbacks don't persist through Lua /reload's
function AddPacketCallback(mode, opcode, callback)

-- Removes a Lua callback added by AddPacketCallback
-- id       (string)    - The string returned by AddPacketCallback
-- returns true on success, false if the callback wasn't found.
function RemovePacketCallback(id)


-- Add a callback to a Lua table that is called every frame, i.e., every "OnUpdate" WoW frame event.
-- Callback (function) - The callback
function AddFrameCallback (Callback)

--- Add a timer callback.
-- Interval (number)   - The number of seconds between calls
-- Callback (function) - The callback
function AddTimerCallback (Interval, Callback)

--- Add a WoW event callback, i.e., a function that is called on "OnEvent" frame event.
-- Event    (string)   - The event name
-- Callback (function) - The callback
-- Note that the callback is called with the event arguments.
function AddEventCallback (Event, Callback)

------------------------- Miscellaneous -------------------

Types = {
    Bool = "bool",
    Char = "char",
    Byte = "byte",
    SByte = "char",
    UByte = "byte",
    Short = "short",
    SShort = "short",
    UShort = "ushort",
    Int = "int",
    SInt = "int",
    UInt = "uint",
    UInt64 = "uint64",
    Long = "long",
    SLong = "long",
    ULong = "ulong",
    Float = "float",
    Double = "double",
    String = "string",
    Pointer = "pointer",
    GUID = "guid",
    PGUID = "pguid",    -- packed GUID
    Vector3 = "vector3"
};

--- Open a URL in the default handler for the scheme.
-- URL (string) - The URL
function OpenURL (URL)

--- Send an HTTP or HTTPS request.
-- URL        (string)   - The URL to send to
-- PostData   (string)   - The POST data if any (nil to use a GET request)
-- OnComplete (body, code, req, res, err) - The function to be called with the response if the request succeeds.
-- Headers    (string)   - Headers that should be added to the request. Split with \r\n.
-- Flags      (number)   - Flags that control the behavior of SendHTTPRequest. They can be combined.
-- 0x1 - Sync       - Whether SendHTTPRequest should be done synchronously or not
-- 0x2 - AsBinary   - Whether SendHTTPRequest should read the response (body) as binary (table of numbers)
-- 0x4 - RunLua     - Whether SendHTTPRequest should execute internally the downloaded Lua
-- Note1: This function doesn't return anything. Use the OnComplete callback for that.
-- Note2: If OnComplete is nil or you pass flag 4, SendHTTPRequest executes internally the Lua code returned from the HTTP request. 
-- Note3: Sync is mainly used if you need to do local requests that are fast. 
-- Note4: AsBinary can be combined with WriteFile to download files.
-- Note5: If you pass flag 4 and a callback, SendHTTPRequest returns (executed, code, nil, nil, err)
function SendHTTPRequest (URL, [ PostData, OnComplete, Headers, Flags] )

-- Example with a synchronous request
local body, code, req, res, err
SendHTTPRequest('https://someurl.com/test', nil, function(_body, _code, _req, _res, _err)
    body, code, req, res, err = _body, _code, _req, _res, _err
end, nil, false)

-- or use the helper below
function SendHTTPRequestSync(URL, PostData, OnComplete, Headers)
    local body, code, req, res, err
    SendHTTPRequest(URL, PostData, function(_body, _code, _req, _res, _err)
        body, code, req, res, err = _body, _code, _req, _res, _err
        if type(OnComplete) == 'function' then
            OnComplete(body, code, req, res, err)
        end
    end, nil, false)
    return body, code, req, res, err
end

-- Example with a GET authentication + Lua execution with RunScript:

SendHTTPRequest('http://someurl.com/auth?username=' .. username .. '&pass=' .. password, nil, 
    function(body, code, req, res, err)
        RunScript(body)   -- contents that were downloaded
        print(code) -- string - HTTP Response Code
        print(req)  -- string - Full HTTP Request
        print(res)  -- string - Full HTTP Response
        print(err)  -- string - Some internal Socket Error
    end,
    "Authentication: bmljZQ==\r\nX-My-Server: HelloServer\r\nX-My-Client: HelloClient\r\n"
)

-- Example that executes internally the Lua code returned from the HTTP request:
SendHTTPRequest('http://someurl.com/auth?username=' .. username .. '&pass=' .. password)

-- Creates a websocket connection
-- URL      (string)         - The websocket URL starting with ws:// or wss://
-- Handler  (function)       - The Handler that will receive the messages
-- Returns  (string)         - Socket ID that should be used with WebsocketClose/WebsocketSend
-- Note: EWT automatically sends a websocket ping every 25s to avoid disconnections.
function WebsocketConnect(URL, Handler)

-- Sends a message over the websocket
-- ID       (string)         - The ID returned by WebsocketConnect
-- Message  (string)         - The message that should be sent
-- Returns  (bool)           - Whether the message was sent or not
function WebsocketSend(ID, Message)

-- Closes a websocket connection
-- ID       (string)         - The ID returned by WebsocketConnect
-- Returns  (bool)           - Whether the message was sent or not
-- Upon doing a /reload, all websocket connections will be closed.
function WebsocketClose(ID)

-- Example using the 3 functions above. Call WebsocketClose whenever you want.
local function SocketHandler(msg, data, sockId, err)
    print(msg .. ' ' .. sockId)
    print(data)
    if msg == 'message' then
        if message == 'bye' then
            -- The Handler for this socket ID won't be called anymore after this 
            WebsocketClose(sockId)
        else
            WebsocketSend(sockId, 'helloo')
        end
    elseif msg == 'close' then
        ewtSockId = nil
    elseif msg == 'connect' then
        if data == 'failed' then
            ewtSockId = nil
            print('Failed connect ' .. err)
        else
            ewtSockId = sockId
        end
    end
end

local function ReconnectSocket()
    if ewtSockId == nil then
        ewtSockId = WebsocketConnect("ws://127.0.0.1:8001", SocketHandler)
    end
end

ReconnectSocket()
C_Timer.NewTicker(10, ReconnectSocket)

--- Get the hardware info that is sent to Blizzard upon login. This is mainly useful for people running multiple accounts.
-- returns (table, string, number) - The JSON with the hardware info, the JSON string and the FNV-1a hash for the string
-- Note: For more details, check this https://www.unknowncheats.me/forum/2608771-post18.html
-- and this https://www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-general/840510-hwid-bann-wow-classic.html
-- This info may be used by Blizzard when you get hardware-ID banned.
function GetHardwareId()

--- Get a session variable. It persists through logout and disconnection.
-- Name    (string) - The variable name
-- returns (string) - The value
function GetSessionVariable (Name)

--- Set a session variable. It will be saved on ewtconfig.json if you use .save or SaveSessionConfig.
-- Name  (string)           - The variable name
-- Value (string or number) - The new value
-- Returns (boolean)        - Whether the variable was set or not.
function SetSessionVariable (Name, Value)

--- Saves the config into ewtconfig.json
-- Returns  (boolean) - Whether the file was saved correctly or not
function SaveSessionConfig ()

--- Get a temporary variable. It persists through logout and disconnection, but it won't be saved on ewtconfig.json.
-- Name    (string) - The variable name
-- returns (string) - The value
function GetTempVariable (Name)

--- Set a temporary variable.
-- Name  (string)           - The variable name
-- Value (string or number) - The new value
-- Returns (boolean)        - Whether the variable was set or not.
function SetTempVariable (Name, Value)

--- Get whether the game client is the foreground window.
-- returns (boolean) - Whether the game client is the foreground window
function IsForeground ()

--- Get the state of a key.
-- Key     (integer)          - The virtual key code
-- returns (boolean, boolean) - Whether the key is down and whether the key is toggled
-- Virtual Key Codes: https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
function GetKeyState (Key)
function GetAsyncKeyState (Key)

--- Set the clipboard data (CTRL+C/CTRL+V)
-- Data     (string)        - The string that will be set
-- Returns nothing
function SetClipboard (Data)

--- Get an offset used by EWT.
-- Name     (string) - The offset name
-- returns  (number) - The offset value if found. If value == -1, the offset is invalid.
-- Example: GetOffset("FrameScript_RegisterFunction") or GetOffset("CGGameObject_C__Animation") for Fishing bobber animation
-- On WoWs <= 4.3.4, you use this to get certain descriptors too, like GetOffset("UNIT_FIELD_FLAGS").
function GetOffset (Name)

--- Get a WoW descriptor.
-- Group    (string) - The group that the descriptor belongs
-- Name     (string) - The descriptor name
-- returns  (number) - The offset value if found
-- Example: GetDescriptor("CGObjectData", "Scale") or GetDescriptor("CGPlayerData", "PlayerTitle")
-- Notes: Descriptor name follows an upper camel case convention, like UpperCamelCase.
-- For a list of WoW descriptors, check Ownedcore's Info Dump Threads in the Memory Editing Section
function GetDescriptor (Group, Name)
  return GetOffset(Group .. '__' .. Name)
end

--- Create a Timer (useful for WoW versions below Warlords which don't have the C_Timer API)
-- Duration (number)    - The interval in milliseconds of the timer
-- Callback (function)  - The function to be called when the interval ends
-- NumRuns  (number)    - Default: 0 (Repeats infinitely). Number of times the callback must be called.
-- returns  (string)    - ID of the timer. Returns nil if error.
-- Example: local timerId = CreateTimer(200, function() print('Test') end)
-- Note: Timers don't persist through Lua reloads. Any running timer will be stopped.
-- Note: If the Timer already executed all NumRuns, you don't need to call StopTimer.
function CreateTimer (Duration, Callback[, NumRuns = 0])

--- Stop a Timer created by CreateTimer
-- TimerID  (string)    - The ID of the Timer
-- returns  (boolean)   - True if it stopped or False if the timer wasn't found
-- Notes: Upon calling this function, the Timer is completely destroyed and you must call CreateTimer again.
function StopTimer (TimerID)

--- Sends a key to WoW's window
-- Key      (number or string)  - The key to be sent
-- Release  (boolean)           - Whether the key should be released. Default: true
-- Example: SendKey('2') or SendKey(0x32) or SendKey(50) - Keep in mind the keys are in ASCII
function SendKey (Key[, Release])

--- Moves the mouse to the given screen position
-- X      (number)    - The X screen coordinate
-- Y      (number)    - The Y screen coordinate
-- Note1: 0,0 is the top-left of the screen. 1920, 1080 (or whatever resolution) is bottom-right.
-- Note2: You may want to use WorldToScreen to convert 3D world coordinates into 2D.
function MoveMouse (X, Y)

--- Sends a mouse click where the mouse is
-- Flags      (Number)    - Click flags. Defaults to 6 (left-click)
-- LEFTDOWN    0x02 /* left button down */
-- LEFTUP      0x04 /* left button up */
-- RIGHTDOWN   0x08 /* right button down */
-- RIGHTUP     0x10 /* right button up */
-- To simulate mouse drag like rotating WoW's camera, use SendClick(8), MoveMouse(X, Y) and then SendClick(0x10)
function SendClick ([Flags = 6])

--- Reads the given memory address.
-- Address  (number)            - The address
-- Type     (string)            - The type of data (Types table)
-- returns the requested type of data (guid, string, bool, number, etc)
function ReadMemory (Address, Type)

--- Gets the base address of a loaded module
-- Name     (string)            - The module name, like Wow.exe, ntdll.dll, kernel32.dll, etc
-- returns  (number)            - The base address of the module
-- Note: This can be used with ReadMemory to read some specific WoW offset. If nil is passed to Name, then it defaults to WoW.
function GetModuleAddress ([Name])

-- Gets WoW's process ID and the Window Handle
-- Returns (number, number)     - The PID and the Window (HWND) Handle
function GetWoWProcess()

--- Send a packet to the servers.
-- Address (number)             - The address
-- ByteString (string)          - The string of bytes like: AB 35 00 DA
-- returns (number)             - Number of bytes sent. If it returns 0, then it failed.
function PatchAddress(Address, ByteString)

-- Returns some clock information about WoW and your computer
-- Returns (number, number, number, number)   - Milisseconds since WoW has been opened, Number of processor ticks, Performance Counter, Performance Frequency
-- Note: Performance Counter/Frequency are used for high resolution (<1us) time stamp: https://docs.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter
function GetClockTime()

--- Safely patch an address with a string of bytes.
-- ByteString (string)          - The string of bytes like: AB 35 00 DA
-- returns (number)             - Number of bytes written. If it returns 0, then it failed.
function SendPacket(ByteString)
-- Example sending a chat message with 'asd'
SendPacket("E7 37 07 00 00 00 01 80 61 73 64")

-- Returns some value as bytes - Useful for packet functions
-- Value    (string, number)    - A GUID, a number, a string, etc
-- Type     (string)            - The type of data (Types table)
-- Returns  (string or table of bytes) - The bytes for the given value
function GetByteValue(Value, Type[, AsBinary = false])
GetByteValue(2, "float")    -- 00 00 00 40
GetByteValue(2, "int")      -- 02 00 00 00

--- Unloads EWT
-- Message  (string)            - Some message to show upon unloading
function UnloadEWT(Message)

--------------- Encryption Functions -------

-- Applies AES-256 CBC encryption to the given string
-- String       (string) - Text to be encrypted
-- Key          (string) - 32-character key
-- Iv           (string) - 16-character initialization vector
-- Encoding     (number) - 1 = Base64 | 2 = Hex | Defaults to Hex
-- Returns      (string) - The encrypted string - If invalid params were passed, returns nil
function AesEncrypt(string, key, iv [, encoding])

AesEncrypt("test", "01234567890123456789012345678901", "0123456789012345")
A68C23C38693A8EBD1D6276FBB90E5E1


-- Applies AES-256 CBC decryption to the given string
-- String       (string) - Text to be encrypted
-- Key          (string) - 32-character key
-- Iv           (string) - 16-character initialization vector
-- Encoding     (number) - 1 = Base64 | 2 = Hex | Defaults to Hex
-- Returns      (string) - The decrypted string - If invalid params were passed, returns nil
function AesDecrypt(string, key, iv [, encoding])
AesDecrypt("A68C23C38693A8EBD1D6276FBB90E5E1", "01234567890123456789012345678901", "0123456789012345")
test

-- Creates and returns a 2048-bit RSA public key. This is unique per EWT session.
-- Returns (string, number) - The key and an error code
-- Error 0 = No errors
function RsaGetPubKey()

-- Encrypts a string with the generated RSA public key
-- Returns      (string) - The encrypted string
-- Note: You can only encrypt up to 245 bytes (or characters).
function RsaEncrypt(string)

-- Hashes a string or table of bytes using some common algorithms
-- String       (string or table of bytes) - Content to be hashed
-- Mode         (number) - 1 = MD5, 2 = SHA1, 3 = SHA256
-- Encoding     (number) - 0 = Base64, 1 = HEX
-- Returns      (string) - The hashed output in Base64 format
function HashString(String, Mode [, Encoding = 0])
-- Examples
HashString("test")
-- CY9rzUYh03PK3k6DJie09g==
HashString("test", 2)
-- qUqP5cyxm6YcTAhz05Hph5gvu9M=
HashString("test", 3, 1)
-- 9F86D081884C7D659A2FEAA0C55AD015A3BF4F1B2B0B822CD15D6C15B0F00A08


--------------- DirectX Drawing Functions -------
-- For these functions to work, you must use DirectX 9 or 11. If you are on Safe Mode, type .enabledx.

--- Draws a DirectX line
-- startX   (number)  - The X coordinate of the line start
-- startY   (number)  - The Y coordinate of the line start
-- endX     (number)  - The X coordinate of the line end
-- endY     (number)  - The Y coordinate of the line end
-- width    (number)  - The width of the line
-- return   (boolean) - true if it worked, false if not
function Draw2DLine(startX, startY, endX, endY[, width = 1.0f])

--- Draws a DirectX line
-- Object   (object) - The origin object (start of line)
-- Target   (object) - The target object (end of line)
-- width    (number) - The width of the line
-- return   (boolean) - true if it worked, false if not
function Draw2DLine(Object, Target[, width = 1.0f])

--- Draws a DirectX line
-- startX   (number)  - The X coordinate of the line start
-- startY   (number)  - The Y coordinate of the line start
-- startZ   (number)  - The Z coordinate of the line start
-- endX     (number)  - The X coordinate of the line end
-- endY     (number)  - The Y coordinate of the line end
-- endZ     (number)  - The Z coordinate of the line end
-- width    (number)  - The width of the line
-- return   (boolean) - true if it worked, false if not
function Draw3DLine(startX, startY, startZ, endX, endY, endZ [, width = 1.0f])

--- Sets the global RGBA color for the next rendering. No need to call this all the time if you
--- don't change the color often.
-- red      (number) - The Red component
-- green    (number) - The Green component
-- blue     (number) - The Blue component
-- alpha    (number) - The Alpha component
function SetDrawColor(red, green, blue[, alpha = 1.0f])

--- Draws a DirectX text
-- textX    (number) - The X coordinate of the text
-- textY    (number) - The Y coordinate of the text
-- text     (number) - The Text
-- fontSize (number) - The font size
function Draw2DText(textX, textY, text [, fontSize])

--- Draws a DirectX text
-- textX    (number) - The X coordinate of the text
-- textY    (number) - The Y coordinate of the text
-- textZ    (number) - The Z coordinate of the text
-- text     (number) - The Text
-- fontSize (number) - The font size
function Draw3DText(textX, textY, textZ, text [, fontSize])

-- Example of how to draw a line to your target
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function (self, event, addon)
  Draw2DLine("player", "target")
end)

-- Example of how to draw Tracker Projections and Text using the APIs above:
local OBJECTTRACKER = {}
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, event, addon)
    local sWidth, sHeight = GetWoWWindow()
    SetDrawColor(1, 1, 1, 1) -- white
    Draw2DText(sWidth * 0.5, sHeight * 0.5, "THIS IS A TEST")
    local totalObjects = GetObjectCount()
    for i = 1, totalObjects do
        local object = GetObjectWithIndex(i)
        OBJECTTRACKER[object] = CanTrackObject(object)
    end
    local playerX, playerY, playerZ = ObjectPosition("player")
    local camX, camY, camZ = GetCameraPosition()
    for i, v in pairs(OBJECTTRACKER) do
        if v then -- Bool: if the object can be tracked or not
            local targetX, targetY, targetZ = ObjectPosition(i)
            if targetX and targetY and targetZ then
                local arg1 = GetDistanceBetweenPositions(playerX, playerY, playerZ, targetX, targetY, targetZ)
                local arg2 = GetDistanceBetweenPositions(camX, camY, camZ, targetX, targetY, targetZ)
                if arg1 <= arg2 then
                    if ObjectIsUnit(i) then
                        local reaction = UnitReaction("player", i)
                        if reaction then
                            if reaction > 4 then
                                if UnitIsPlayer(i) then
                                    SetDrawColor(0, 0, 1, 1) -- blue
                                else
                                    SetDrawColor(0, 1, 0, 1) -- green
                                end
                            elseif reaction == 4 then
                                SetDrawColor(1, 1, 0, 1) -- yellow
                            elseif reaction < 4 then
                                SetDrawColor(1, 0, 0, 1) -- red
                            end
                        else
                            SetDrawColor(1, 1, 1, 1) -- white
                        end
                    else
                        SetDrawColor(1, 1, 1, 1) -- white
                    end
                    local player2DX, player2DY, playerInFront = WorldToScreenRaw(playerX, playerY, playerZ)
                    local target2DX, target2DY, targetInFront = WorldToScreenRaw(targetX, targetY, targetZ)
                    Draw2DLine(player2DX * sWidth, player2DY * sHeight, target2DX * sWidth, target2DY * sHeight)
                end
            end
        end
    end
end)


--------------- LibDraw Drawing Functions -------
-- For more info, check this https://github.com/MrTheSoulz/NerdPack-Protected/blob/master/external/LibDraw.lua

LibDraw.Sync(function()
    if UnitExists("target") then
        local playerX, playerY, playerZ = ObjectPosition("player")
        local targetX, targetY, targetZ = ObjectPosition("target")
        local reaction = UnitReaction("player", "target")
        if reaction >= 5 then
            LibDraw.SetColorRaw(0, 1, 0, 1)
        elseif reaction == 4 then
            LibDraw.SetColorRaw(1, 1, 0, 1)
        elseif reaction <= 3 then
            LibDraw.SetColorRaw(1, 0, 0, 1)
        end
        LibDraw.Line(playerX, playerY, playerZ, targetX, targetY, targetZ)
        -- LibDraw.Circle(targetX, targetY, targetZ, 5)
    end
end)
LibDraw.Enable(0.01)