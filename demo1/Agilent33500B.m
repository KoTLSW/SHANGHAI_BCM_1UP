//
//  Agilent33500B.m
//  33500B_Test
//
//  Created by mac on 21/09/2017.
//  Copyright © 2017 mac. All rights reserved.
//

#import "Agilent33500B.h"

@implementation Agilent33500B



@synthesize isOpen_33500B = _isOpen_33500B;

-(id)init
{
    
    if (self = [super init]) {
        _isOpen_33500B = false;
    }
    return self;
    
}

-(BOOL) Find:(NSString *)serial andCommunicateType:(enum Agilent33500BCommunicateType)communicateType{
    
    sleep(0.5);
    
    status = viOpenDefaultRM(&defaultRM);
    
    if (status < VI_SUCCESS) {
        exit(EXIT_FAILURE);
    }
    
    /*
     * Find all the VISA resources in our system and store the number of resources
     * in the system in numInstrs.  Notice the different query descriptions a
     * that are available.
     
     Interface         Expression
     --------------------------------------
     GPIB              "GPIB[0-9]*::?*INSTR"
     VXI               "VXI?*INSTR"
     GPIB-VXI          "GPIB-VXI?*INSTR"
     Any VXI           "?*VXI[0-9]*::?*INSTR"
     Serial            "ASRL[0-9]*::?*INSTR"
     PXI               "PXI?*INSTR"
     All instruments   "?*INSTR"
     All resources     "?*"
     */

    if (serial == nil) {
        switch (communicateType) {
            case Agilent33500B_LAN_Type:
                status = viFindRsrc(defaultRM, "TCPIP0::192.168.1.10::?*",&findList, &numInstrs, instrDescriptor);
                break;
            case Agilent33500B_USB_Type:
                status = viFindRsrc (defaultRM, "USB0::0x0957::?*", &findList, &numInstrs, instrDescriptor);
                break;
                
                
            default:
                NSLog(@"其它的通信方式");
                break;
        }
        
        if (status < VI_SUCCESS) {
            return false;
        }
    }else{
        
        const char *s = [serial UTF8String];
        status = viFindRsrc(defaultRM, (char*)s, &findList, &numInstrs, instrDescriptor);
        
        if (status == VI_SUCCESS) {
            self.agilentSerial_33500B = serial;
        }
    }
    
    if (status < VI_SUCCESS) {
        printf ("An error occurred while finding resources.\n");
        fflush(stdin);
        viClose (defaultRM);
        return NO;
    }
    
    NSLog(@"%s",instrDescriptor);
    
    return YES;
}

-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum Agilent33500BCommunicateType)communicateType{
    
    if (_isOpen_33500B) {
        return YES;
    }
    
    switch (communicateType) {
        case Agilent33500B_LAN_Type:
            status = viOpen(defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
            break;
            
        case Agilent33500B_USB_Type:
            status = viOpen(defaultRM, instrDescriptor, VI_NULL, VI_NULL, &instr);
            break;

            
        default:
            NSLog(@"其它的通信方式");
            
            break;
    }
    
    if (status < VI_SUCCESS)
    {
        
        return NO;
    }
    _isOpen = YES;
    
    return YES;


}


/**
 *  用于设置波形发生器的参数
 *
 *  @param mode            模式，
 *  @param communicateType 通信方式
 *  @param FREQuency       频率
 *  @param VOLTage         电压
 *  @param OFFSet          偏移
 *  @param leading         上升沿，主要用于pulse和ramp
 *  @param traing          下降沿，主要用于pulse和ramp
 */

-(void)SetMessureMode:(enum Agilent33500BMeasureMode)mode andCommunicateType:(enum Agilent33500BCommunicateType)communicateType andFREQuency:(NSString*)FREQuency andVOLTage:(NSString*)VOLTage andOFFSet:(NSString*)OFFSet{
    
    switch (mode) {
        case MODE_Sine:
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"FUNCtion SIN" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"OUTPut:LOAD 50" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:[NSString stringWithFormat:@"FREQuency %@",FREQuency]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage %@",VOLTage] andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage:OFFSet %@",OFFSet]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"OUTPut ON" andCommunicateType:communicateType]; usleep(10*1000);
            break;
            
        case MODE_DC:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"*CLS" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"FUNCtion DC" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"OUTPut:LOAD 50" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage %@",VOLTage] andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage:OFFSet %@",OFFSet]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"OUTPut:SYNC OFF" andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"OUTPut ON" andCommunicateType:communicateType]; usleep(1000*1000);
        }
            break;
 
        case MODE_Square:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"FUNCtion SQUare" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"OUTPut:LOAD 50" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:[NSString stringWithFormat:@"FREQuency %@",FREQuency]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage %@",VOLTage] andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage:OFFSet %@",OFFSet]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"OUTPut ON" andCommunicateType:communicateType]; usleep(10*1000);
        }
            break;
        case MODE_Ramp:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"FUNCtion RAMP" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"OUTPut:LOAD 50" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:[NSString stringWithFormat:@"FREQuency %@",FREQuency]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage %@",VOLTage] andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage:OFFSet %@",OFFSet]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"OUTPut ON" andCommunicateType:communicateType]; usleep(10*1000);
        }
            break;
        case MODE_Pulse:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"FUNCtion PULSe" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"OUTPut:LOAD 50" andCommunicateType:communicateType]; usleep(50);
        
            [self WriteLine:[NSString stringWithFormat:@"FUNC:PULS:TRAN:LEAD %@",@"4E-8"]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"FUNC:PULS:TRAN:TRA %@", @"1E-6"]  andCommunicateType:communicateType]; usleep(10*1000);
            
            [self WriteLine:[NSString stringWithFormat:@"FREQuency %@",FREQuency]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage %@",VOLTage] andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage:OFFSet %@",OFFSet]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"OUTPut ON" andCommunicateType:communicateType]; usleep(10*1000);
        }
            break;
        case MODE_Noise:
        {
            [self WriteLine:@"*RST" andCommunicateType:communicateType];usleep(10*1000);
            [self WriteLine:@"FUNCtion NOISe" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:@"OUTPut:LOAD 50" andCommunicateType:communicateType]; usleep(50);
            [self WriteLine:[NSString stringWithFormat:@"FREQuency %@",FREQuency]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage %@",VOLTage] andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:[NSString stringWithFormat:@"VOLTage:OFFSet %@",OFFSet]  andCommunicateType:communicateType]; usleep(10*1000);
            [self WriteLine:@"OUTPut ON" andCommunicateType:communicateType]; usleep(10*1000);
        }
            break;
            
        default:
            break;
    }
}


-(void)CloseDevice
{
    if (!_isOpen) return;
    /* Now close the session we just opened.                            */
    /* In actuality, we would probably use an attribute to determine    */
    /* if this is the instrument we are looking for.                    */
    viClose (instr);
    status = viClose(findList);
    status = viClose (defaultRM);
    
    //2015.1.19
    _isOpen = FALSE;
}


/**
 *  write data to Waveform
 *
 *  @param data            data
 *  @param communicateType communicateType
 *
 *  @return success or not
 */
-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum Agilent33500BCommunicateType)communicateType
{
    /*
     * At this point we now have a session open to the instrument at
     * Primary Address 2.  We can use this session handle to write
     * an ASCII command to the instrument.  We will use the viWrite function
     * to send the string "*IDN?", asking for the device's identification.
     */
    
    
    switch (communicateType) {
        case Agilent33500B_LAN_Type:
            status = viSetAttribute (instr, VI_ATTR_TCPIP_NODELAY, 8000);
            break;
        case Agilent33500B_USB_Type:
            status = viSetAttribute (instr, VI_ATTR_TMO_VALUE, 8000);
            break;
            
        default:
            NSLog(@"其它的通信方式");
            break;
    }
    
    NSString* dataLine = [[NSString alloc] initWithFormat:@"%@\n", data];
    NSInteger dataLen = [dataLine length];
    char inputBuffer[dataLen];
    strcpy(inputBuffer, [dataLine UTF8String]);
    
    status = viWrite (instr, (ViBuf)inputBuffer, (ViUInt32)strlen(inputBuffer), &writeCount);
    if (status < VI_SUCCESS)
    {
        return NO;
    }
    
    return YES;
}

//*******************注意*************************//
//网口通信一次最多只能够读取16个字节，既readDataCount<=16;
-(NSString*) ReadData:(int)readDataCount  andCommunicateType:(enum Agilent33500BCommunicateType)communicateType
{
    
    unsigned char buffer[20* readDataCount];   //建立缓存空间
    memset(buffer, 0, 20* readDataCount);      //对内存空间进行清零处理
    switch (communicateType) {
        case Agilent33500B_LAN_Type:
            status = viRead (instr, buffer, readDataCount, &retCount);
            break;
        case Agilent33500B_USB_Type:
            status = viRead (instr, buffer, 20* readDataCount, &retCount);
            break;
            
        default:
            NSLog(@"其它的通信方式");
            break;
    }
    
    if (status < VI_SUCCESS)
    {
        return @"";
    }
    
    NSString *result = [[NSString alloc] initWithUTF8String:(const char*)buffer];
    return result ;
}


@end
