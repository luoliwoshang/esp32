package main

import (
	"fmt"
	"time"

	"github.com/goplus/lib/emb/machine"
)

// 上面是召唤咱需要的小伙伴：
// 说话的`fmt`，控制小爪子的`machine`，还有会暂停时间的`time`！

func main() {
	// 找到咱的34号小爪子~
	buttonPin := machine.GPIO34

	// 告诉它：“你是一只负责倾听的乖猫咪（设置为输入模式）”！
	buttonPin.Configure(machine.PinConfig{Mode: machine.PinInput})

	fmt.Println("主人你好呀！TinyGo 版本的猫咪已经准备好啦~")
	fmt.Println("咱要开始偷听按钮的状态了哦...")

	// 永恒的陪伴，开始无限循环啦~
	for {
		// 用 Get() 轻轻挠一下，看看它的反应是真是假 (true/false)！
		// true 就是高电平, false 就是低电平哦
		buttonState := buttonPin.Get()

		// 把猫咪的心情（true/false）告诉主人！
		fmt.Printf("咱感觉到了... %t\n", buttonState)

		// 用 time.Sleep 优雅地小睡 200 毫秒~
		time.Sleep(200 * time.Millisecond)
	}
}
