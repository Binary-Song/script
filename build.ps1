# !!!! run in x64 dev command prompt !!!!
# install rust, npm and swig first!


$workspace = Get-Location

git clone https://gitee.com/openharmony/third_party_llvm-project.git llvm

Push-Location llvm
git checkout 25b15389c9569dfd12501a56bf1ad3d0aa9a51d3
git am "$workspace\0001-llvm-ok.patch"
Pop-Location

Push-Location codelldb
git clone https://github.com/vadimcn/codelldb.git codelldb
git checkout c06be2ebc5a5fae802edf872b2a73db903e55de3
git am "$workspace\0001-codelldb-ok.patch"
Pop-Location

cmake -S llvm/llvm -B llvm_build -G "Visual Studio 17 2022" -DLLVM_TARGETS_TO_BUILD="X86;ARM;AArch64" -DLLVM_ENABLE_PROJECTS="clang;lldb" -DCMAKE_INSTALL_PREFIX="llvm_install" -DLLDB_ENABLE_PYTHON=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build llvm_build --config Release
cmake --install llvm_build --config Release

cmake -S codelldb -B codelldb_build -DCMAKE_TOOLCHAIN_FILE="$workspace\codelldb\cmake\toolchain-x86_64-windows-msvc.cmake" -DLLDB_PACKAGE="$workspace\llvm_install"

Push-Location codelldb_build
npm install
Pop-Location

cmake --build codelldb_build --config Release --target vsix_full
