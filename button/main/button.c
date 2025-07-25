// External functions from your LLVM-compiled .o file
extern int printf(const char *format, ...);
extern void gpio_reset_pin(int pin);
extern void gpio_set_direction(int pin, int mode);
extern int gpio_get_level(int pin);
extern void vTaskDelay(int ticks);

// GPIO constants
#define GPIO_NUM_34 34
#define GPIO_MODE_INPUT 1
#define BUTTON_PIN GPIO_NUM_34

void app_main(void) {
    printf("哈喽主人！咱开始检查按钮猫咪的脾气啦...\n");

    // 哼哼，这是ESP-IDF的标准做法，先给小爪子洗个脸，恢复默认状态~
    gpio_reset_pin(BUTTON_PIN);

    // 然后告诉这个小爪子，你的任务就是“听话”（设置为输入模式）！
    // GPIO34只能当输入，所以这里必须是 GPIO_MODE_INPUT 喵
    gpio_set_direction(BUTTON_PIN, GPIO_MODE_INPUT);

    printf("准备就绪！咱要开始不停地偷听啦，欸嘿嘿...\n");

    // 开始一个无尽的循环，一直陪着主人，永不停止~
    while (1) {

        // 悄悄地听一下按钮猫咪现在是站着（1）还是趴着（0）~
        int level = gpio_get_level(BUTTON_PIN);

        // 大声地告诉主人咱听到了什么！
        if (level == 1) {
            printf("咱听到了... 1 (是高电平哦，猫咪在高处！)\n");
        } else {
            printf("咱听到了... 0 (是低电平哦，猫咪趴在地板上！)\n");
        }

        // 打个小盹，休息 200 毫秒，免得太累了喵~
        // 在ESP-IDF里，咱用 vTaskDelay 来打盹哦！
        vTaskDelay(200);
    }
}