#### debug tinygo

第一步：克隆并构建 TinyGo 及其依赖项

```bash
git clone https://github.com/tinygo-org/tinygo.git
make llvm-source
make llvm-build
make gen-device
make tinygo
```

第二步：配置 VS Code 调试环境
现在，我们将配置 VS Code，使其能够启动并调试我们刚刚构建的 TinyGo 编译器。

2.1 获取 CGO 环境变量
为了让调试器能够正确链接到我们刚刚在 llvm-build 目录中编译的 LLVM 库，我们需要获取由 make 命令生成的特定 CGO 环境变量。

在 tinygo 项目根目录下运行以下“空运行”(Dry Run)命令：

```bash
make -n tinygo
```

这个命令会打印出即将执行的完整 go build 命令，但并不会真的运行它。从输出中找到 CGO_CPPFLAGS="..." 和 CGO_LDFLAGS="..." 的部分，并将它们的值（包含双引号内的所有内容）复制下来，我们马上会用到。

2.2 创建 launch.json 配置文件
在 VS Code 中，打开 tinygo 项目文件夹。

切换到“运行和调试”侧边栏 (Run and Debug)。

点击“创建 launch.json 文件”(create a launch.json file)，并选择 “Go” 环境。

将生成的文件内容替换为以下模板：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug TinyGo Compiler",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "program": "${workspaceFolder}", // 指向 TinyGo 的主程序
            "cwd": "${workspaceFolder}",
            "args": [
                // 在这里设置你想调试的 TinyGo 命令参数
                // 例如: 编译一个 "blinky" 示例
                "build",
                "-target=pico",
                "./examples/blinky1"
            ],
            "env": {
                "TINYGOROOT": "${workspaceFolder}",
                "GO111MODULE": "on",
                
                // --- 关键部分：粘贴从 "make -n" 获取的环境变量 ---
                "CGO_CXXFLAGS": "-std=c++17",
                "CGO_CPPFLAGS": "<在此处粘贴 CGO_CPPFLAGS 的值>",
                "CGO_LDFLAGS": "<在此处粘贴 CGO_LDFLAGS 的值>"
            },
            "showLog": true,
            "trace": "verbose",
            "dlvFlags": [
                "--check-go-version=false"
            ]
        }
    ]
}
```
请务必将上面模板中的 <在此处粘贴...> 替换为您在上一步中复制的真实值。


