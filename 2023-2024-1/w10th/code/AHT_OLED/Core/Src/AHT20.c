#include "AHT20.h"

AHT20_StructureTypedef  Humiture;

/**
  * @brief  ��AHT20 �豸״̬��
  * @param  void
  * @retval uint8_t �豸״̬��
  */

static uint8_t AHT20_ReadStatusCmd(void)
{
	uint8_t tmp = 0;
    HAL_I2C_Master_Receive(&hi2c2, AHT20_SLAVE_ADDRESS, &tmp, 1, 0xFFFF);
	return tmp;
}

/**
  * @brief  ��AHT20 �豸״̬�� �е�Bit3: У׼ʹ��λ
  * @param  void
  * @retval uint8_t У׼ʹ��λ��1 - ��У׼; 0 - δУ׼
  */
static uint8_t AHT20_ReadCalEnableCmd(void)
{
	uint8_t tmp = 0;
	tmp = AHT20_ReadStatusCmd();
	return (tmp>>3)&0x01;
}

/**
  * @brief  ��AHT20 �豸״̬�� �е�Bit7: æ��־
  * @param  void
  * @retval uint8_t æ��־��1 - �豸æ; 0 - �豸����
  */
static uint8_t AHT20_ReadBusyCmd(void)
{
	uint8_t tmp = 0;
	tmp = AHT20_ReadStatusCmd();
	return (tmp>>7)&0x01;
}

/**
  * @brief  AHT20 оƬ��ʼ������
  * @param  void
  * @retval void
  */
static void AHT20_IcInitCmd(void)
{
	uint8_t tmp = AHT20_INIT_COMD;
	HAL_I2C_Master_Transmit(&hi2c2, AHT20_SLAVE_ADDRESS, &tmp, 1, 0xFFFF);
}

/**
  * @brief  AHT20 ����λ����
  * @param  void
  * @retval void
  */
static void AHT20_SoftResetCmd(void)
{
	uint8_t tmp = AHT20_SoftReset;
	HAL_I2C_Master_Transmit(&hi2c2, AHT20_SLAVE_ADDRESS, &tmp, 1, 0xFFFF);
}

/**
  * @brief  AHT20 ������������
  * @param  void
  * @retval void
  */
static void AHT20_TrigMeasureCmd(void)
{
    static uint8_t tmp[3] = {AHT20_TrigMeasure_COMD, 0x33, 0x00};
	HAL_I2C_Master_Transmit(&hi2c2, AHT20_SLAVE_ADDRESS, tmp, 3, 0xFFFF);
}


/**
  * @brief  AHT20 �豸��ʼ��
  * @param  void
  * @retval uint8_t��0 - ��ʼ��AHT20�豸�ɹ�; 1 - ��ʼ��AHT20ʧ�ܣ������豸�����ڻ���������
  */
uint8_t AHT20_Init(void)
{
	uint8_t rcnt = 2+1;//����λ���� ���Դ�����2��
	uint8_t icnt = 2+1;//��ʼ������ ���Դ�����2��

	while(--rcnt)
	{
		icnt = 2+1;

		HAL_Delay(40);//�ϵ��Ҫ�ȴ�40ms
		// ��ȡ��ʪ��֮ǰ�����ȼ��[У׼ʹ��λ]�Ƿ�Ϊ1
		while((!AHT20_ReadCalEnableCmd()) && (--icnt))// 2�����Ի���
		{
			HAL_Delay(1);
			// �����Ϊ1��Ҫ���ͳ�ʼ������
			AHT20_IcInitCmd();
			HAL_Delay(40);//���ʱ���ֲ�û˵�����ϵ�ʱ����40ms
		}

		if(icnt)//[У׼ʹ��λ]Ϊ1,У׼����
		{
			break;//�˳�rcntѭ��
		}
		else//[У׼ʹ��λ]Ϊ0,У׼����
		{
			AHT20_SoftResetCmd();//����λAHT20����������
			HAL_Delay(20);//���ʱ���ֲ����������20ms.
		}
	}

	if(rcnt)
	{
		return 0;// AHT20�豸��ʼ������
	}
	else
	{
		return 1;// AHT20�豸��ʼ��ʧ��
	}
}

/**
  * @brief  AHT20 �Ĵ�����λ
  * @param  void
  * @retval void
  */
static void AHT20_Register_Reset(uint8_t addr)
{
  uint8_t  iic_tx[3] = {0}, iic_rx[3] = {0};
  
  iic_tx[0] = addr;
  HAL_I2C_Master_Transmit(&hi2c2, AHT20_SLAVE_ADDRESS, iic_tx, 3, 0xFFFF);
  HAL_Delay(5);
  HAL_I2C_Master_Receive(&hi2c2, AHT20_SLAVE_ADDRESS, iic_rx, 3, 0xFFFF);
  HAL_Delay(10);
  iic_tx[0] = 0xB0 | addr;
  iic_tx[1] = iic_rx[1];
  iic_tx[2] = iic_rx[2];
  HAL_I2C_Master_Transmit(&hi2c2, AHT20_SLAVE_ADDRESS, iic_tx, 3, 0xFFFF);
  HAL_Delay(10);
}


/**
  * @brief  AHT20 �豸��ʼ��ʼ��
  * @param  void
  * @retval void
  */
void AHT20_Start_Init(void)
{
  static uint8_t    temp[3] = {0x1B, 0x1C, 0x1E}, i;
  for(i = 0; i < 3; i++)
  {
    AHT20_Register_Reset(temp[i]);
  }
}



/**
  * @brief  AHT20 �豸��ȡ ���ʪ�Ⱥ��¶ȣ�ԭʼ����20Bit��
  * @param  uint32_t *HT���洢20Bitԭʼ���ݵ�uint32����
  * @retval uint8_t��0-��ȡ��������; 1-��ȡ�豸ʧ�ܣ��豸һֱ����æ״̬�����ܻ�ȡ����
  */
uint8_t AHT20_ReadHT(uint32_t *HT)
{
	uint8_t cnt=3+1;//æ��־ ���Դ�����3��
	uint8_t tmp[6];
	uint32_t RetuData = 0;

	// ���ʹ�����������
	AHT20_TrigMeasureCmd();

	do{
		HAL_Delay(75);//�ȴ�75ms��������ɣ�æ��־Bit7Ϊ0
	}while(AHT20_ReadBusyCmd() && (--cnt));//����3��

	if(cnt)//�豸�У����Զ���ʪ������
	{
		HAL_Delay(5);
		// ����ʪ������
        HAL_I2C_Master_Receive(&hi2c2, AHT20_SLAVE_ADDRESS, tmp, 6, 0XFFFF);
		// �������ʪ��RH��ԭʼֵ��δ����Ϊ��׼��λ%��
		RetuData = 0;
		RetuData = (RetuData|tmp[1]) << 8;
		RetuData = (RetuData|tmp[2]) << 8;
		RetuData = (RetuData|tmp[3]);
		RetuData = RetuData >> 4;
		HT[0] = RetuData;

		// �����¶�T��ԭʼֵ��δ����Ϊ��׼��λ��C��
		RetuData = 0;
		RetuData = (RetuData|tmp[3]) << 8;
		RetuData = (RetuData|tmp[4]) << 8;
		RetuData = (RetuData|tmp[5]);
		RetuData = RetuData&0xfffff;
		HT[1] = RetuData;

		return 0;
	}
	else//�豸æ�����ض�ȡʧ��
	{
		return 1;
	}
}

/**
  * @brief  AHT20 ��ʪ���ź�ת������20Bitԭʼ���ݣ�ת��Ϊ��׼��λRH=%��T=��C��
  * @param  struct m_AHT20* aht���洢AHT20��������Ϣ�Ľṹ��
  * @retval uint8_t��0-������������; 1-��������ʧ�ܣ�����ֵ����Ԫ���ֲ���Χ
  */
uint8_t StandardUnitCon(AHT20_StructureTypedef *aht)
{
	aht->RH = (double)aht->HT[0] *100 / 1048576;//2^20=1048576 //ԭʽ��(double)aht->HT[0] / 1048576 *100��Ϊ�˸��㾫�ȸ�Ϊ���ڵ�
	aht->Temp = (double)aht->HT[1] *200 / 1048576 -50;

	//�޷�,RH=0~100%; Temp=-40~85��C
	if((aht->RH >=0)&&(aht->RH <=10000) && (aht->Temp >=-4000)&&(aht->Temp <=8500))
	{
		aht->flag = 0;
		return 0;//������������
	}
	else
	{
		aht->flag = 1;
		return 1;//�������ݳ�����Χ������
	}
}


/**
  * @brief  AHT20 ��ʪ���ź�ת������20Bitԭʼ���ݣ�ת��Ϊ��׼��λRH=%��T=��C��
  * @param  struct m_AHT20* aht���洢AHT20��������Ϣ�Ľṹ��
  * @retval uint8_t��0-������������; 1-��������ʧ�ܣ�����ֵ����Ԫ���ֲ���Χ
  */
uint8_t AHT20_Get_Value(AHT20_StructureTypedef *p)
{
  uint8_t   temp = 0;
  
  temp = AHT20_ReadHT(p->HT);
  
  if(temp == 0)
  {
    temp = StandardUnitCon(p);
  }
  
  return temp;
}
