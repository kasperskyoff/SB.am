-- Админская база.
if SERVER then  
    AddCSLuaFile("sb.am/shared/sh_func.lua")
    include("sb.am/shared/sh_func.lua")
end

if CLIENT then
    include("sb.am/shared/sh_func.lua")
end