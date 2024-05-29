@[toc](目录)
# 一、 内容概要
1. 串口传输文件的练习。将两台笔记本电脑，借助 usb转rs232 模块和杜邦线，建立起串口连接。然后用串口助手等工具软件（带文件传输功能）将一台笔记本上的一个大文件（图片、视频和压缩包软件）传输到另外一台电脑，预算文件大小、波特率和传输时间三者之间的关系，并对比实际传输时间。

2. 学习理解汉字的机内码、区位码编码规则和字形数据存储格式。在Ubuntu下用C/C++(或python) 调用opencv库编程显示一张图片，并打开一个名为"logo.txt"的文本文件（其中只有一行文本文件，包括你自己的名字和学号），按照名字和学号去读取汉字24*24点阵字形字库（压缩包中的文件HZKf2424.hz）中对应字符的字形数据，将名字和学号叠加显示在此图片右下位置。

3.  理解OLED屏显和汉字点阵编码原理，使用STM32F103的SPI或IIC接口实现以下功能：

1) 显示自己的学号和姓名； 

2) 显示AHT20的温度和湿度；

3) 上下或左右的滑动显示长字符，比如“Hello，欢迎来到重庆交通大学物联网205实训室！”或者一段歌词或诗词(最好使用硬件刷屏模式)。

# 二、 正文
## 2.1 串口传输文件的练习
### 2.1.1 准备工作
1. 电脑 两台
2. usb转rs232 模块 两个
3. 串口助手
### 2.1.1 连接电脑
1. 通过两个usb转rs232模块连接两台电脑

2. 打开串口助手检测连接性，并调整参数
![在这里插入图片描述](https://img-blog.csdnimg.cn/77561632de834225b31ea8d49001250e.png)
3. 点击发送文件
![在这里插入图片描述](https://img-blog.csdnimg.cn/cabc9f3b86624f3e9e7347e990077290.png)
4. 选择图片
选一张小一点的，不然要传输很久
![在这里插入图片描述](https://img-blog.csdnimg.cn/828fa91195774d2f9e244497a8615946.png)


5. 查看传输结果
![在这里插入图片描述](https://img-blog.csdnimg.cn/1ce0d319bcbf4b4ca7fa894325e83210.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/e3f5228b4e0540dd99071663fd49a421.png)

![在这里插入图片描述](https://img-blog.csdnimg.cn/d7287b7a22c445408277c2217ef7f0fd.png)
计时：
|波特率| 时间 |
|--|--|
| 115200 | 6.3s |
| 38400| 3.3s|
|19200|40s|

## 2.2 学习理解汉字的机内码、区位码编码规则和字形数据存储格式。用python显示带图片的文字
### 2.2.1 准备工作
1. 电脑
2. python
3. logo.txt
4. 图片
5. [中文点阵字库及其显示工具](https://d0.ananas.chaoxing.com/download/d0ef6f743a59048721bfefc8c022172d?at_=1700369842045&ak_=f8f991b22ad7184ac174689fe52c973e&ad_=a477a4eec270508a8d4cc7d4e26c4d0f&fn=%25E4%25B8%25AD%25E6%2596%2587%25E7%2582%25B9%25E9%2598%25B5%25E5%25AD%2597%25E5%25BA%2593%25E5%258F%258A%25E6%2598%25BE%25E7%25A4%25BA%25E5%25B7%25A5%25E5%2585%25B7%25E7%25A8%258B%25E5%25BA%258F)
### 2.2.2 学习理解汉字的机内码、区位码
1. 区位码
在国标 GD2312—80 中规定，所有的国标汉字及符号分配在一个 94 行、94 列的方
阵中，方阵的每一行称为一个“区”，编号为 01 区到 94 区，每一列称为一个“位”，编号为
01 位到 94 位，方阵中的每一个汉字和符号所在的区号和位号组合在一起形成的四个阿拉
伯数字就是它们的“区位码”。**区位码的前两位是它的区号，后两位是它的位号。用区位码就可以唯一地确定一个汉字或符号**，反过来说，任何一个汉字或符号也都对应着一个唯一的区位码。汉字“母”字的区位码是 3624，表明它在方阵的 36 区 24 位，问号“?”的区位码为
0331，则它在 03 区 3l 位。
 
2. 机内码
汉字的机内码是指在计算机中表示一个汉字的编码。机内码与区位码稍有区别。如上所
述，汉字区位码的区码和位码的取值均在 1~94 之间，如直接用区位码作为机内码，就会与基本 ASCII 码混淆。为了避免机内码与基本 ASCII 码的冲突，需要避开基本 ASCII 码
中的控制码(00H~1FH)，还需与基本 ASCII 码中的字符相区别。为了实现这两点，可以
先在区码和位码分别加上 20H，在此基础上再加 80H(此处“H”表示前两位数字为十六进制
数)。经过这些处理，用机内码表示一个汉字需要占两个字节，分别 称为高位字节和低位字
节，这两位字节的机内码按如下规则表示：

**高位字节 = 区码 + 20H + 80H(或区码 + A0H)**

**低位字节 = 位码 + 20H + 80H(或位码 + AOH)** 
由于汉字的区码与位码的取值范围的十六进制数均为01H ~ 5EH（即十进制的 01 ~ 94），所以汉字的高位字节与低位字节的取值范围则为 A1H ~ FEH(即十进制的 161 ~ 254)。
  例如，汉字“啊”的区位码为 1601，区码和位码分别用十六进制表示即为 1001H，它
的机内码的高位字节为 B0H，低位字节为 A1H，机内码就是 B0A1H。
二、 点阵字库结构
1. 点阵字库存储
在汉字的点阵字库中，每个字节的每个位都代表一个汉字的一个点，每个汉字都是由一个矩形的点阵组成，0 代表没有，1 代表有点，将 0 和 1 分别用不同颜色画出，就形成了一个汉字，常用的点阵矩阵有 12*12, 14*14, 16*16 三种字库。
字库根据字节所表示点的不同有分为横向矩阵和纵向矩阵，目前多数的字库都是横向矩阵的存储方式(用得最多的应该是早期 UCDOS 字库)，纵向矩阵一般是因为有某些液晶是采用纵向扫描显示法，为了提高显示速度，于是便把字库
矩阵做成纵向，省得在显示时还要做矩阵转换。我们接下去所描述的都是指横向
矩阵字库。
2. 16*16 点阵字库
对于 16*16 的矩阵来说，它所需要的位数共是 16*16＝256 个位，每个字
节为 8 位，因此，每个汉字都需要用 256/8=32 个字节来表示。
即每两个字节代表一行的 16 个点，共需要 16 行，显示汉字时，只需一次
性读取 32 个字节，并将每两个字节为一行打印出来，即可形成一个汉字。
点阵结构如下图所示：

![在这里插入图片描述](https://img-blog.csdnimg.cn/9940abce43b9401fa1e213e631f98f24.png)

 
3. 14 * 14 与 12 * 12 点阵字库
对于 14 * 14 和 12 * 12 的字库，理论上计算，它们所需要的点阵分别为(14 * 14/8)=25, (12 * 12/8)=18 个字节，但是，如果按这种方式来存储，那么取点阵和显示时，由于它们每一行都不是 8 的整位数，因此，就会涉到点阵的计算处理问题，会增加程序的复杂度，降低程序的效率。为了解决这个问题，有些点阵字库会将 14 * 14 和 12 * 12 的字库按 16 * 14
和 16 * 12 来存储，即，每行还是按两个字节来存储，但是 14 * 14 的字库，每两个字节的最后两位是没有使用，12*12 的字节，每两字节的最后 4 位是没有使用，这个根据不同的字库会有不同的处理方式，所以在使用字库时要注意这个
问题，特别是 14*14 的字库。
三、 汉字点阵获取
1. 利用区位码获取汉字
  汉字点阵字库是根据区位码的顺序进行存储的，因此，我们可以根据区位来
获取一个字库的点阵，它的计算公式如下：
**点阵起始位置 = ((区码- 1) * 94 + (位码 – 1)) * 汉字点阵字节数**
获取点阵起始位置后，我们就可以从这个位置开始，读取出一个汉字的点阵。
2. 利用汉字机内码获取汉字
前面我们己经讲过，汉字的区位码和机内码的关系如下：

**机内码高位字节 = 区码 + 20H + 80H(或区码 + A0H)**
**机内码低位字节 = 位码 + 20H + 80H(或位码 + AOH)**

反过来说，我们也可以根据机内码来获得区位码：

**区码 = 机内码高位字节 - A0H**
**位码 = 机内码低位字节 - AOH**

将这个公式与获取汉字点阵的公式进行合并计就可以得到汉字的点阵位置。
### 2.2.3 用python显示图片和文字
首先将下载好的字库添加到当前Python目录中
![在这里插入图片描述](https://img-blog.csdnimg.cn/d4924be0eaa64ce0b2a2fbca64793769.png)
复制以下代码，可以根据注释学习功能
~~~python
import re
import cv2
import numpy as np

def resize_image(image, target_area):
    """
    调整图像大小，以达到目标面积，并保持长宽比。

    参数:
    - image: 原始图像。
    - target_area: 调整后的目标面积。

    返回:
    - 调整后的图像。
    """
    height, width = image.shape[:2]
    current_area = height * width
    scale = np.sqrt(target_area / current_area)
    new_height = int(height * scale)
    new_width = int(width * scale)
    resized_image = cv2.resize(image, (new_width, new_height))
    return resized_image

def paint_ascii(image, x_offset, y_offset, offset):
    """
    在图像上绘制ASCII字符。

    参数:
    - image: 绘制字符的图像。
    - x_offset: X坐标偏移量。
    - y_offset: Y坐标偏移量。
    - offset: 读取ASCII字符数据的偏移量。

    返回:
    - 无
    """
    p = np.array([x_offset, y_offset])
    buff = bytearray(16)

    with open("Asci0816.zf", "rb") as ASCII:
        ASCII.seek(offset)
        ASCII.readinto(buff)

    for i in range(16):
        p[0] = x_offset
        for j in range(8):
            if buff[i] & (0x80 >> j):
                image[p[1]:p[1]+2, p[0]:p[0]+2] = [0, 0, 255]
            p[0] += 2
        p[1] += 2

def paint_chinese(image, x_offset, y_offset, offset):
    """
    在图像上绘制中文字符。

    参数:
    - image: 绘制字符的图像。
    - x_offset: X坐标偏移量。
    - y_offset: Y坐标偏移量。
    - offset: 读取中文字符数据的偏移量。

    返回:
    - 无
    """
    p = np.array([x_offset, y_offset])
    
    buff = bytearray(72)

    with open("HZKf2424.hz", "rb") as HZK:
        HZK.seek(offset)
        HZK.readinto(buff)

    mat = np.zeros((24, 24), dtype=bool)

    for i in range(24):
        for j in range(3):
            for k in range(8):
                if buff[i * 3 + j] & (0x80 >> k):
                    mat[j * 8 + k][i] = True

    for i in range(24):
        p[0] = x_offset
        for j in range(24):
            if mat[i][j]:
                image[p[1], p[0]] = [0, 255, 0]
            p[0] += 1
        p[1] += 1

def is_chinese(character):
    """
    检查给定字符是否为中文。

    参数:
    - character: 输入字符。

    返回:
    - 如果字符为中文则为True，否则为False。
    """
    return bool(re.match('[\u4e00-\u9fa5]', character))

def process_character(character, image, x, y):
    """
    处理文本中的每个字符并在图像上绘制。

    参数:
    - character: 输入字符。
    - image: 绘制字符的图像。
    - x: X坐标偏移量。
    - y: Y坐标偏移量。

    返回:
    - 无
    """
    if is_chinese(character):
        gbk_code = character.encode('gbk')
        hex_code = gbk_code.hex().upper()

        # 提取区号和位号
        qh = int(hex_code[:2], 16) - 0xaf
        wh = int(hex_code[2:], 16) - 0xa0
        offset = (94 * (qh - 1) + (wh - 1)) * 72
        paint_chinese(image, x, y, offset)
    else:
        offset = ord(character) * 16
        paint_ascii(image, x, y, offset)

def put_text_to_image(x_rate, y_rate, image_path, logo_path):
    """
    将文本放置在图像上并显示结果。

    参数:
    - x_rate: 文本放置的X坐标比率。
    - y_rate: 文本放置的Y坐标比率。
    - image_path: 原始图像路径。
    - logo_path: 文本文件路径。

    返回:
    - 无
    """
    original_image = cv2.imread(image_path)

    # 调整图像大小，使其大致为原始面积的1/4
    resized_image = resize_image(original_image, target_area=original_image.size // 27)

    with open(logo_path, "r", encoding="utf-8") as file_logo:
        text = file_logo.read().strip()  # 读取文件内容并去除首尾空白

    length = len(text)
    height, width, channels = resized_image.shape
    x = int(width * x_rate)
    y = int(height * y_rate)
    for m in range(length):
        character = text[m]
        if character == '#':
            break
        process_character(character, resized_image, x, y)  # 假设ASCII字符的偏移量为0
        if is_chinese(character):
            m += 1
            x += 24
        else:
            m += 1
            x += 16

    cv2.imshow("resized_image", resized_image)
    cv2.waitKey()

if __name__ == "__main__":
    image_path = "aerial.jpg"  # 图像路径
    logo_path = "logo.txt"  # 文本文件路径
    put_text_to_image(0.2, 0.9, image_path, logo_path)

~~~
效果:
![在这里插入图片描述](https://img-blog.csdnimg.cn/b569695806ca4e97bd3b967e9d1df6bc.png)
## 2.3 解OLED屏显和汉字点阵编码原理，使用STM32F103的SPI或IIC接口显示姓名学号和温湿度
### 2.3.1 准备工作
1. OLED显示屏
2. MDK
3. CubeMX
4. stm32F103c8t6
5. usb转rs232模块或stlink等烧录模块
6. OLED相关文件：
>网址:[OLED资料](https://pan.baidu.com/s/13_WpuJZDb_K2oH_yewQhYw)
>提取码：2frr
>可以去购买oled的购物平台主页查看，有可能版本不一样导致无法运行
>网址2：[取模软件](https://blog.csdn.net/qq_51272949/article/details/120198795)
>网址3:  [AHT20文件](https://blog.csdn.net/lxr0106/article/details/134396459?spm=1001.2014.3001.5501)
>新建AHT20.c和AHT20.h然后复制粘贴文章开头部分响应代码，再添加至所需项目即可
### 2.3.2 显示姓名学号
1. 创建项目
① 打开cubemx,新建项目
![在这里插入图片描述](https://img-blog.csdnimg.cn/333437c6a67b4f6a9f19ed13e2f63295.png)
② 选择芯片型号

![在这里插入图片描述](https://img-blog.csdnimg.cn/5b20125ea9eb441784b01e155987e56c.png)

③ 选择I2C
![在这里插入图片描述](https://img-blog.csdnimg.cn/f5399dde6e8d406aa29c67c080cdb49d.png)
④ 如图进行其它配置
![在这里插入图片描述](https://img-blog.csdnimg.cn/796ab9c219304d849ac7d7b21c17efd0.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/19a66a14a2c946098059a8a9ae064e4f.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/b4f3462c87724200b898e75be66c6867.png)
⑤ 点击生成
![在这里插入图片描述](https://img-blog.csdnimg.cn/1bcad161f25a422a9565d2116ba81e99.png)
2. 将下载好的oled.c和oled.h和oledfont.c添加至项目里

![在这里插入图片描述](https://img-blog.csdnimg.cn/375a8e941344469b9ff56f72a3970275.png)

![在这里插入图片描述](https://img-blog.csdnimg.cn/e9af7a0aa8714b678211c531ba871172.png)
双击
![在这里插入图片描述](https://img-blog.csdnimg.cn/46906c24762f44b9af421bf0bf2d6c46.png)
选择oled.c添加
![在这里插入图片描述](https://img-blog.csdnimg.cn/ede53ebe0e86478fbdf4b4809dd05bdb.png)
点击编译一下
![在这里插入图片描述](https://img-blog.csdnimg.cn/643748e99c4648419a42641fff9fb141.png)
可以看到添加成功了

2. 编程
① 打开取模软件，这里我下载的是
![在这里插入图片描述](https://img-blog.csdnimg.cn/2f73f87c423848f68e7c21e2a000c029.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/696fdd3bd36b4cbeaf89801f90899793.png)
② 点击设置，选择C51模式
![在这里插入图片描述](https://img-blog.csdnimg.cn/52b4ae28397b4330bd8f1b2fa6434b47.png)
③ 输入文字，点击生成
![在这里插入图片描述](https://img-blog.csdnimg.cn/2c3ac3ab4dd1496c86e967972546a0ca.png)
④ 将点阵数据输出区的文字复制一下，打开oledfont.h
![在这里插入图片描述](https://img-blog.csdnimg.cn/5e0785bdfb11432f81306af7b395832f.png)
可以看到这里是各种数字，英文，符号的字模数据，我们翻到最底下
添加：
~~~c
char Hzk[][32]=
{

};
~~~
并把复制好的字段粘贴到里面
![在这里插入图片描述](https://img-blog.csdnimg.cn/600c7871b2494f52aae89850cb574d6e.png) 然后删除oled.c开头对Hzk的声明
⑤ 编写代码：
3. 首先打开main函数，添加include "oled.h"

4. 在main函数里添加oled的初始化
~~~c
OLED_Init();
OLED_Clear();
~~~
5. 在后面输入：
~~~c
OLED_ShowCHinese(0,0,0);
		OLED_ShowCHinese(18,0,1);
~~~
⑤ 编译烧录查看结果:
![在这里插入图片描述](https://img-blog.csdnimg.cn/f81d5c9bd1234b008d95ad1e972255a5.jpeg)
可以看到汉字能顺利显示但是方向不对
解决办法：
回到取字模软件，调整方向：
![在这里插入图片描述](https://img-blog.csdnimg.cn/49c2f7545d22401fa1c8b29db22ca095.png)
重新生成字模，并复制到oledfont.h
重新烧录
（这部分可能要调整多次，耐心调试到字显示正常即可）
![在这里插入图片描述](https://img-blog.csdnimg.cn/5a9fd4a2126d4366950428896500dfcc.jpeg)
成功
⑥ 输入自己的姓名，取字模然后编译烧录
![在这里插入图片描述](https://img-blog.csdnimg.cn/522fae39aa7e463eb0757e710ada3da0.png)
把显示文字代码替换为：
~~~c
 OLED_ShowCHinese(0,0,0);
		OLED_ShowCHinese(18,0,1);
		OLED_ShowCHinese(36,0,2);
		OLED_ShowString(54,0,(uint8_t*)"632107060323",18);
~~~
编译烧录
![在这里插入图片描述](https://img-blog.csdnimg.cn/7f775696e26e43c88d23a1a8bd3eebde.png)
完成
### 2.3.3 显示温湿度
1. 重新新建一个项目，启动I2C2
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/2a084f487eb5425bae90857fab14e0f8.png)
2. 编程
① 像上一个项目一样添加OLED相关文件和AHT20相关文件
![在这里插入图片描述](https://img-blog.csdnimg.cn/cf3bfcb9bff94db3baa05d1ca3ecf8a0.png)
**② 更改其中一个模块的I2C通道，因为一个I2C通道只能通信一个模块**
这里选择更改AHT20的通道
点击AHT20.c（2.3.1准备工作有提到文件来源）
把所有&hi2c1更改为&hi2c2
按住ctrl+F，打开搜索界面，再选择replace
![在这里插入图片描述](https://img-blog.csdnimg.cn/8cedf9cfc0a34b148d6d1ef1f4c2d024.png)
置换所有
![在这里插入图片描述](https://img-blog.csdnimg.cn/dacc8ed6e9b04e22a84978bae4156688.png)
**③ 编程**
首先回到取模软件获取需要的汉字的字模
这里我需要的字为：
“温湿度获取失败”
![在这里插入图片描述](https://img-blog.csdnimg.cn/17a1965960134370b2bbeced631b40cd.png)
然后复制到oledfont.h里面：
~~~c
char Hzk[][32]={

{0x10,0x60,0x02,0x8C,0x00,0x00,0xFE,0x92,0x92,0x92,0x92,0x92,0xFE,0x00,0x00,0x00},
{0x04,0x04,0x7E,0x01,0x40,0x7E,0x42,0x42,0x7E,0x42,0x7E,0x42,0x42,0x7E,0x40,0x00},/*"温",0*/
{0x10,0x60,0x02,0x8C,0x00,0xFE,0x92,0x92,0x92,0x92,0x92,0x92,0xFE,0x00,0x00,0x00},
{0x04,0x04,0x7E,0x01,0x44,0x48,0x50,0x7F,0x40,0x40,0x7F,0x50,0x48,0x44,0x40,0x00},/*"湿",1*/
{0x00,0x00,0xFC,0x24,0x24,0x24,0xFC,0x25,0x26,0x24,0xFC,0x24,0x24,0x24,0x04,0x00},
{0x40,0x30,0x8F,0x80,0x84,0x4C,0x55,0x25,0x25,0x25,0x55,0x4C,0x80,0x80,0x80,0x00},/*"度",2*/
{0x04,0x14,0xA4,0x44,0xAF,0x14,0x04,0x04,0x04,0xF4,0x0F,0x24,0x44,0x04,0x04,0x00},
{0x12,0x49,0x84,0x42,0x3F,0x81,0x41,0x31,0x0D,0x03,0x0D,0x31,0x41,0x81,0x81,0x00},/*"获",3*/
{0x02,0x02,0xFE,0x92,0x92,0x92,0xFE,0x02,0x06,0xFC,0x04,0x04,0x04,0xFC,0x00,0x00},
{0x08,0x18,0x0F,0x08,0x08,0x04,0xFF,0x04,0x84,0x40,0x27,0x18,0x27,0x40,0x80,0x00},/*"取",4*/
{0x00,0x40,0x30,0x1E,0x10,0x10,0x10,0xFF,0x10,0x10,0x10,0x10,0x10,0x00,0x00,0x00},
{0x81,0x81,0x41,0x21,0x11,0x0D,0x03,0x01,0x03,0x0D,0x11,0x21,0x41,0x81,0x81,0x00},/*"失",5*/
{0x00,0xFE,0x02,0xFA,0x02,0xFE,0x40,0x20,0xD8,0x17,0x10,0x10,0xF0,0x10,0x10,0x00},
{0x80,0x47,0x30,0x0F,0x10,0x67,0x80,0x40,0x21,0x16,0x08,0x16,0x21,0x40,0x80,0x00},/*"败",6*/

};

~~~
回到main.c中
首先添加include:
在/* USER CODE BEGIN Includes */中添加：
~~~c
#include "oled.h"
#include "AHT20.h"
#include "stdio.h"
~~~
在下面添加两个全局变量：
~~~c
char temp_buffer[100];
char RH_buffer[100];
~~~
用于温度和湿度的信息输送
在main函数里添加AHT20和OLED的定义
~~~c
  OLED_Init();
  OLED_Clear();
  int flag=AHT20_Init();
~~~
在while函数里添加:
~~~c

    
    /* USER CODE END WHILE */
    if (flag==0){
      Humiture.alive=1;
     AHT20_Get_Value(&Humiture);
      OLED_ShowCHinese(0,0,0);//温
      OLED_ShowCHinese(18,0,2);//度
      OLED_ShowCHinese(0,2,0);//湿
      OLED_ShowCHinese(18,2,2);//度
      sprintf(temp_buffer,":%.2f",Humiture.Temp);
      OLED_ShowString(36,0,(uint8_t*)temp_buffer,16);
     sprintf(RH_buffer,":%.2f",Humiture.RH);
OLED_ShowString(36,2,RH_buffer,16);
    }
    else{
      OLED_Clear();
      Humiture.alive=0;
  OLED_ShowCHinese(0,0,0);
  OLED_ShowCHinese(18,0,1);
  OLED_ShowCHinese(36,0,2);
  OLED_ShowCHinese(54,0,3);
  OLED_ShowCHinese(72,0,4);
  OLED_ShowCHinese(90,0,5);
  OLED_ShowCHinese(108,0,6);
    }
    HAL_Delay(2000);
~~~
完整代码：
~~~c
/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2023 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "i2c.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "oled.h"
#include "AHT20.h"
#include "stdio.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
char temp_buffer[100];
char RH_buffer[100];
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_I2C1_Init();
  MX_I2C2_Init();
  OLED_Init();
  OLED_Clear();
int flag=AHT20_Init();
  /* USER CODE BEGIN 2 */

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    
    /* USER CODE END WHILE */
    if (flag==0){
      Humiture.alive=1;
     AHT20_Get_Value(&Humiture);
      OLED_ShowCHinese(0,0,0);//温
      OLED_ShowCHinese(18,0,2);//度
      OLED_ShowCHinese(0,2,0);//湿
      OLED_ShowCHinese(18,2,2);//度
      sprintf(temp_buffer,":%.2f",Humiture.Temp);
      OLED_ShowString(36,0,(uint8_t*)temp_buffer,16);
     sprintf(RH_buffer,":%.2f",Humiture.RH);
OLED_ShowString(36,2,RH_buffer,16);
    }
    else{
      OLED_Clear();
      Humiture.alive=0;
  OLED_ShowCHinese(0,0,0);
  OLED_ShowCHinese(18,0,1);
  OLED_ShowCHinese(36,0,2);
  OLED_ShowCHinese(54,0,3);
  OLED_ShowCHinese(72,0,4);
  OLED_ShowCHinese(90,0,5);
  OLED_ShowCHinese(108,0,6);
    }
    HAL_Delay(2000);

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

~~~
3. 编译运行
![在这里插入图片描述](https://img-blog.csdnimg.cn/3eaa7456beea4aee8396fa3a1c26191c.gif)
### 2.3.4 滑动文字
1. 新建项目
按照2.3.2建立就行
2. 编程
复制以下代码到/* USER CODE BEGIN PV */
~~~c
void showString(){
  int x_p=0;
      for (int i=0;i<7;i++){
        OLED_ShowCHinese(x_p,0,i);
        x_p+=18;
      }
}
// 每个滚动步骤之间的时间间隔，以帧为单位，越大越慢
typedef enum
{ 
	FRAME_2 = 0x07,
	FRAME_3 = 0x04, 
	FRAME_4 = 0x05,
	FRAME_5 = 0x06,
	FRAME_6 = 0x00, 
	FRAME_32 = 0x01,	
	FRAME_64 = 0x02,
	FRAME_128 = 0x03, 	
}Roll_Frame;
 
/**
  * @brief  OLED_Inside_Hor_Sroll，内部设置水平滚动
  * @param  start_page,end_page :起始滚动页与终止滚动页(start_page:0~7, end_page:0~7);
  *			frame : 每个滚动步骤之间的时间间隔，以帧为单位，越大越慢(FRAME_2 ~ FRAME_128)
  *			dir : 1 向右水平滚动，0 向左水平滚动
  * @retval 无
  */
void OLED_Inside_Hor_Sroll(uint8_t start_page,uint8_t end_page,Roll_Frame frame,uint8_t dir)
{
	// 先必须关闭滚动
	OLED_WR_CMD(0x2E);
	
	// 1是向右水平滚动，0是向左水平滚动
	OLED_WR_CMD(dir ? 0x26 : 0x27);
	
	// 发送一个虚拟字节
	OLED_WR_CMD(0x00);        
 
	OLED_WR_CMD(start_page & 0x07);      //起始页 0
	OLED_WR_CMD(frame & 0x07);           //滚动时间间隔
	OLED_WR_CMD(end_page & 0x07);        //终止页 7
	
	// 发送两个虚拟字节
	OLED_WR_CMD(0x00);
	OLED_WR_CMD(0xFF);
	
	//开启滚动
	OLED_WR_CMD(0x2F);
}
~~~
在main函数中添加
~~~c
OLED_Init();
	OLED_Clear();
  /* USER CODE BEGIN 2 */
    showString();
  OLED_Inside_Hor_Sroll(0,7,FRAME_6,0);
~~~
3. 编译烧录
![在这里插入图片描述](https://img-blog.csdnimg.cn/b3b39b5235264f8b93a4dbea35aee2ea.gif)
# 三、总结


**任务1: 串口传输文件的练习**
在这个任务中，我通过搭建串口连接，利用USB转RS232模块和杜邦线将两台笔记本电脑相连接。使用串口助手等工具软件进行文件传输实践，包括图片、视频和压缩包等文件的传输。通过调整波特率、文件大小等参数，我深入了解了这些参数之间的关系，并对比实际传输时间。这任务帮助我更好地理解串口通信的原理和相关参数的影响。

**任务2: 汉字编码和图片显示**
在这个任务中，我学习了理解汉字的机内码、区位码编码规则和字形数据存储格式。通过调用OpenCV库，我成功地在python下编程显示一张图片，并通过读取汉字24x24点阵字形字库中对应字符的字形数据，将名字和学号叠加显示在图片右下角。这使我对汉字编码有了更深入的理解，并锻炼了调用库、文件操作等编程技能。

**任务3: STM32F103的OLED屏显**
这个任务涉及到硬件和嵌入式系统的知识。通过理解OLED屏显和汉字点阵编码原理，我使用了STM32F103的SPI或IIC接口实现了显示学号和姓名，AHT20的温湿度信息，并实现了长字符的滑动显示。在这个任务中，最重要的是理解OLED屏的工作原理以及STM32F103的SPI/IIC接口的使用。通过硬件刷屏模式，我提高了屏幕的刷新效率。这任务对我深化了对嵌入式系统和硬件编程的理解。

通过这三个任务，我不仅学到了串口通信、汉字编码、图片显示、OLED屏显等多个方面的知识，还锻炼了实际问题解决的能力，提高了编程和硬件调试的技能。这些综合的任务对于系统性地提升我的综合能力和知识储备起到了积极的作用。
