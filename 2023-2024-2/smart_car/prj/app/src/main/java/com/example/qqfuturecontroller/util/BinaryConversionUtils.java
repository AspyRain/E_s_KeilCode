package com.example.qqfuturecontroller.util;

public class BinaryConversionUtils {

    /**
     * 将整数字符串转换为6位二进制字符串。
     * 如果输入的整数超过63（即2^6-1），则只取低6位。
     *
     * @param integerStr 输入的整数字符串
     * @return 6位二进制字符串
     */
    public static String convertIntStringToSixBitBinary(String integerStr) {
        int value = Math.abs(Integer.parseInt(integerStr)) % 64; // 取绝对值并模64，确保结果在0-63范围内
        return String.format("%6s", Integer.toBinaryString(value)).replace(' ', '0'); // 补齐至6位
    }

    /**
     * 将二进制字符串转换为二进制数（byte[]），总长度为16位，高位补零。
     *
     * @param binaryStr 输入的二进制字符串
     * @return 16位的二进制数组，高位在前
     */
    public static byte[] convertBinaryStringToByteArr(String binaryStr) {
        if (binaryStr.length() > 16) {
            throw new IllegalArgumentException("Binary string exceeds 16 bits.");
        }

        // 补齐至16位
        String paddedBinaryStr = String.format("%16s", binaryStr).replace(' ', '0');

        // 将二进制字符串转换为字节
        int intValue = Integer.parseInt(paddedBinaryStr, 2); // 转换为整数
        byte[] bytes = new byte[2]; // 由于Java中byte为有符号，-128~127，因此2个字节足够表示16位
        bytes[0] = (byte) (intValue >> 8); // 高位字节
        bytes[1] = (byte) intValue; // 低位字节

        return bytes;
    }

}