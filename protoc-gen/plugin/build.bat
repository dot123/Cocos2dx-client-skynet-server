@echo off
for %%i in (proto/*.proto) do (   

protoc.exe --lua_out=./ --plugin=protoc-gen-lua="%~dp0protoc-gen-lua.bat" proto/%%i
protoc.exe --cpp_out=. proto/%%i
protoc.exe -o proto/%%ipb proto/%%i
)
if exist "./out" rmdir /s/q "./out" 
cd proto
ren *.protopb *.pb
mkdir "./out/pb"
mkdir "./out/cpp"
mkdir "./out/lua"
move *.pb.h "./out/cpp"
move *.pb.cc "./out/cpp"
move *.pb "./out/pb"
move *.lua "./out/lua"
move /y out ../
echo ok
ping -n 3 127.0.0.1>nul
exit
pause