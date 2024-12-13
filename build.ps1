echo "!! 确保在 x64 dev command prompt 里执行!!"
echo "!! 确保这几个命令可用： rust, npm, swig。 可用choco安装!!"
echo "!! 确保安装python3.10 ( https://www.python.org/downloads/release/python-31011/ )!!"

Set-PSDebug -Trace 1
$workspace = Get-Location

git clone https://gitee.com/openharmony/third_party_llvm-project.git llvm
if ($LastExitCode -ne 0)  { exit $LastExitCode }

Push-Location llvm
git checkout 25b15389c9569dfd12501a56bf1ad3d0aa9a51d3
if ($LastExitCode -ne 0)  { exit $LastExitCode }
git am "$workspace\0001-llvm-ok.patch"
if ($LastExitCode -ne 0)  { exit $LastExitCode }
Pop-Location

git clone https://github.com/vadimcn/codelldb.git codelldb
if ($LastExitCode -ne 0)  { exit $LastExitCode }
Push-Location codelldb
git checkout c06be2ebc5a5fae802edf872b2a73db903e55de3
if ($LastExitCode -ne 0)  { exit $LastExitCode }
git am "$workspace\0001-codelldb-ok.patch"
if ($LastExitCode -ne 0)  { exit $LastExitCode }
Pop-Location


cmake -S llvm/llvm -B llvm_build -G "Visual Studio 16 2019" `
    -DLLVM_TARGETS_TO_BUILD="X86;ARM;AArch64" `
    -DLLVM_ENABLE_PROJECTS="clang;lldb" `
    -DCMAKE_INSTALL_PREFIX="llvm_install" `
    -DLLDB_ENABLE_PYTHON=ON `
    -DLLDB_EMBED_PYTHON_HOME=ON `
    -DPython3_ROOT_DIR="~\AppData\Local\Programs\Python\Python310" `
    -DLLDB_PYTHON_HOME=python `
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON `
    -DLLDB_INCLUDE_TESTS=OFF

if ($LastExitCode -ne 0)  { exit $LastExitCode }
cmake --build llvm_build --config Release
if ($LastExitCode -ne 0)  { exit $LastExitCode }
cmake --install llvm_build --config Release
if ($LastExitCode -ne 0)  { exit $LastExitCode }

cmake -S codelldb -B codelldb_build -DCMAKE_TOOLCHAIN_FILE="$workspace\codelldb\cmake\toolchain-x86_64-windows-msvc.cmake" -DLLDB_PACKAGE="$workspace\llvm_install"
Push-Location codelldb 
npm install
Pop-Location
if ($LastExitCode -ne 0)  { exit $LastExitCode }
cmake --build codelldb_build --config Release --target vsix_full
if ($LastExitCode -ne 0)  { exit $LastExitCode }

mkdir "$workspace\llvm_install\bin\python"
cp -r "~\AppData\Local\Programs\Python\Python310\Dlls" "$workspace\llvm_install\bin\python"
cp -r "~\AppData\Local\Programs\Python\Python310\Lib" "$workspace\llvm_install\bin\python"
cp "~\AppData\Local\Programs\Python\Python310\python3.dll" "$workspace\llvm_install\bin"
cp "~\AppData\Local\Programs\Python\Python310\python310.dll" "$workspace\llvm_install\bin"
cp "$workspace\codelldb_build\codelldb-full.vsix" "$workspace\llvm_install"
