//挂QQ服务端，如需WEB版挂QQ的，自己来改造，本人现在没有精力改造了
//不需要的东西都已经取消了
//提供该程序只是用来学习目的，千万不要用于非法用途，后果自负
//用到RX控件，和JCL库，请大家自行下载
//如果不能挂QQ的话，那就请看LumqQQ中的相关协议，改成新协议即可
//如有更新希望发一份给我 QQ:709582502 Email:Touchboy@126.com 
unit Class_QQTEA;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;


Type
   PMyByte=^TMYByte;
   TMYByte=Array [0..500] of byte;
   TQQTEA=Class
   private
     FCurrLen:Integer;

     m_lOnBits:Array [0..30] of integer;
     m_l2Power:Array [0..30] of integer;
     //Plain,PrePlain,OutKey:Array of Byte;
     Plain    :TMYByte;     //指向当前的明文块
     prePlain :TMYByte;    //指向前面一个明文块
     OutKey   :TMYByte;    //输出的密文或者明文
     Crypt,preCrypt :Integer;    //当前加密的密文位置和上一次加密的密文块位置，他们相差8
     Pos      :Integer;   //当前处理的加密解密块的位置
     padding:integer;            //填充数

     Key    :Array  of Byte;   //密钥
     Header :Boolean;            //用于加密时，表示当前是否是第一个8字节块，因为加密算法
                                 //是反馈的，但是最开始的8个字节没有反馈可用，所有需要标
                                 //明这种情况
     contextStart:integer;
     procedure Class_Initialize;      //这个表示当前解密开始的位置，之所以要这么一个变量是为了
                                //避免当解密到最后时后面已经没有数据，这时候就会出错，这
                                //个变量就是用来判断这种情况免得出错


     procedure ClearArray(var Arr:Array of Byte);
     function GetFCurrLen: integer;

   public
     constructor Create;

     Function Rand:Integer;
     procedure Encrypt8Bytes;

     Function Decipher(arrayIn, arrayKey:array of Byte;offset:Integer=0):TMYByte;

     //Function Decipher(arrayIn,arrayKey :array of byte;offset:Integer):TMYByte;

     Function Decrypt8Bytes(arrayIn:array of byte;offset:Integer):Boolean;

     Function Encrypt(arrayIn,arrayKey :array of byte;Var nSendLen:integer;offset:Integer=0):TMYByte;
     Function Decrypt(arrayIn,arrayKey :array of byte;offset:Integer=0):TMYByte;
     Function Encipher(arrayIn,arrayKey:array of Byte;offset:Integer=0):TMYByte;
     //Function Encipher(arrayIn,arrayKey :array of byte;offset:Integer):TMYByte;
     Function LShift(lValue:Longint; iShiftBits:Integer):Integer;
     Function RShift(lValue:Longint; iShiftBits:Integer):Integer;
     Function UnsignedAdd(Data1:integer; Data2:integer):integer;
     Function UnsignedDel(Data1, Data2:integer):integer;

     property CurrLen :integer Read GetFCurrLen; 
   end;

var
  QQTEA:TQQTEA;
  GlobalCurrLen:Integer;

  procedure InitArray(var My:TMyByte);


implementation

Function TQQTEA.Encrypt(arrayIn,arrayKey :array of byte;Var nSendLen:integer;offset:Integer):TMYByte;
var
  i:integer;
  nLen :integer;
  nMyLen:integer;
begin
   Pos :=1;
   Crypt :=0;
   preCrypt := 0;
   nLen :=High(arrayin)+1;

   SetLength(Key,High(arrayKey)+1);
   ClearArray(Key);

   CopyMemory(@Key[0], @arrayKey[0],High(arrayKey)+1);

    Header := True ;
    Pos := (nLen+ 10) Mod 8;
    If Pos <> 0 Then Pos := 8-Pos;
    nSendLen :=nLen + Pos + 10;

    For i:=0 to 499 do
    begin
      OutKey[i]:=0;
      prePlain[i]:=0;
      Plain[i]:=0;
    end;
    Plain[0] := (Rand And $F8) Or Pos;
    For I := 1 To Pos do
        Plain[I] := Rand And $FF;

    For I := 0 To 7 do
        prePlain[i] :=$0;

    Pos := Pos + 1;
    padding := 1;
    While padding < 3 do
    begin
      If Pos < 8 Then
      begin
          Plain[Pos] := Rand And $FF;
          padding    := padding + 1 ;
          Pos        := Pos + 1   ;
      end else if Pos = 8 Then
          Encrypt8Bytes;
    end;
    I := offset;   // 头部填充完了，这里开始填真正的明文了，也是满了8字节就加密，一直到明文读完
    While nLen > 0 do
    begin
      If Pos < 8 Then
      begin
          Plain[Pos] := arrayIn[I];
          I := I + 1;
          Pos := Pos + 1;
          nLen := nLen - 1;
      end else if Pos = 8 Then
          Encrypt8Bytes
    end;

    padding := 1;         // 最后填上0，以保证是8字节的倍数
    While padding < 9 do
    begin
      If Pos < 8 Then
      begin
          Plain[Pos] := $0;
          Pos := Pos + 1;
          padding := padding + 1
      end else If Pos = 8 Then
          Encrypt8Bytes
    end;
    //SetLength(Result,High(OutKey)+1);
    //CopyMemory(@Result[0],@OutKey[0],High(OutKey)+1);
    CopyMemory(@Result[0],@OutKey[0], nSendLen);



    //Result := OutKey;
end;


Function TQQTEA.Decrypt(arrayIn,arrayKey :array of byte;offset:Integer):TMYByte;
var
   m:array of byte;
   I :Integer;
   Count :Integer;
   nLen :integer;
begin
    If (High(arrayIn) < 15) Or (((High(arrayIn)+1) Mod 8) <> 0) Then Exit ;
    //If High(arrayKey) <> 15 Then Exit ;
    SetLength(m,offset + 8);
    SetLength(Key,16);
    CopyMemory(@Key[0], @arrayKey[0],16);
    Crypt    := 0;
    preCrypt := 0;
    prePlain := Decipher(arrayIn, arrayKey, offset);
    Pos := prePlain[0] And $7;
    Count:= High(arrayIn)- Pos - 8;
    nLen := High(arrayIn)- Pos - 8;
    If Count < 0 Then Exit ;
    //SetLength(OutKey,Count ); //**
    preCrypt := 0 ;
    Crypt    := 8 ;
    contextStart := 8;
    Pos := Pos + 1;
    padding := 1 ;
    While padding < 3 do
    begin
        If Pos < 8 Then
        begin
            Pos := Pos + 1;
            padding := padding + 1;
        end Else If Pos = 8 Then
        begin
              SetLength(m,high(arrayIn)+1);
              CopyMemory(@m[0], @arrayIn[0], High(m)+ 1);
              If not Decrypt8Bytes(arrayIn, offset) Then Exit;
        end;
    end;
    I := 0;
    While Count <> 0 do
    begin
        If Pos < 8 Then
        begin
            OutKey[I] := m[offset + preCrypt + Pos] Xor prePlain[Pos];
            I := I + 1 ;
            Count := Count - 1;
            Pos   := Pos + 1;
        end  Else If Pos = 8 Then
          begin
            //m := arrayIn; //**
            SetLength(m,High(arrayin)+1);//**

            CopyMemory(@m[0],@arrayin[0],High(arrayin)+1);
            preCrypt := Crypt - 8;
            If not Decrypt8Bytes(arrayIn, offset) Then Exit ;
          end
    end;
    For i:=1 To 7 do
    begin
        If Pos < 8 Then
        begin
            If (m[offset + preCrypt + Pos] Xor prePlain[Pos]) <> 0 Then Exit;
            Pos := Pos + 1;
        end else If Pos = 8 Then
          begin
            CopyMemory(@m[0], @arrayIn[0], High(m) + 1);
            preCrypt := Crypt;
            If not Decrypt8Bytes(arrayIn, offset) Then Exit;
          end;
    end;

 
    //SetLength(Result,High(OutKey)+1);
    //Result :=OutKey;

    CopyMemory(@Result[0],@OutKey[0],nLen);
    FCurrLen :=nLen;

    //Result := OutKey;
end;

procedure TQQTEA.Encrypt8Bytes;
var
  Crypted:TMYByte;
  I :Integer;
begin
    For i :=0 To 7 do
    begin
        If Header Then
            Plain[i] := Plain[i] Xor prePlain[i]
        Else
            Plain[i] := Plain[i] Xor OutKey[preCrypt + i];
    end;
    
    //**
    Crypted := Encipher(Plain,Key);

    For I := 0 To 7 do
        OutKey[Crypt + I] := Crypted[I];

    For i :=0 To 7 do
        OutKey[Crypt + i] := OutKey[Crypt + i] Xor prePlain[i];

    //prePlain := Plain;
    CopyMemory(@PrePlain[0],@Plain[0],8);
    preCrypt := Crypt;
    Crypt    := Crypt + 8;
    Pos := 0;
    Header := False
end;



Function TQQTEA.Decrypt8Bytes(arrayIn:array of byte;offset:Integer):Boolean;
var
  i:integer;
begin
    For i:=0  To 7 do
    begin
        If (contextStart + i) > (High(arrayIn)) Then
        begin
            Result:=True;
            Exit;
        end;
        prePlain[i] := prePlain[i] Xor arrayIn[offset + Crypt + i];
    end;
    try
    //**
      prePlain := Decipher(prePlain, Key);
    except
     Result := False;
     Exit;
    end;
    contextStart := contextStart + 8;
    Crypt := Crypt + 8;
    Pos   := 0;
    Result:= True;
end;


//Function Encipher(arrayIn:TMYByte;arrayKey:Array [0..30] of integer ;offset:Integer):TMYByte;
//Function Encipher:TMYByte;
Function TQQTEA.Encipher(arrayIn,arraykey:Array of Byte;offset:Integer):TMYByte;
var
    I,y,z,a,b,c,d:Longword;
    sum,delta :Longword;
    tmpArray :Array [0..23] of Byte;
    //tmpOut :Array [0..7] of Byte;
    tmpOut :TMYByte;

begin
   { If High(arrayIn) < 7 Then Exit ;
    If High(arrayKey) < 15 Then Exit ;
    sum := 0;
    delta := $9E3779B9;
    delta := delta And $FFFFFFFF;
    CopyMemory(@y,@arrayIn[0],4);
    CopyMemory(@z,@arrayIn[4],4);
    CopyMemory(@a,@arrayKey[0],4);
    CopyMemory(@b,@arrayKey[4],4);
    CopyMemory(@c,@arrayKey[8],4);
    CopyMemory(@d,@arrayKey[12],4);

    For I := 1 To 16 do
    begin
        sum := sum+delta;
        sum := sum And $FFFFFFFF;
        y :=Y+((z shl 4) + a) xor (z + sum) xor ((z shr 5) + b);
        y :=Y and $FFFFFFFF;
        z :=Z+((y shl 4) + c) xor (y + sum) xor ((y shr 5) + d);
        z :=z and $FFFFFFFF;
    end;
   
    SetLength(Result,8);
    Y:=Integer(Y);
    Z:=Integer(Z);
    CopyMemory(@Result[0],@y,4);
    CopyMemory(@Result[4],@z,4);  }

    If High(arrayIn) < 7 Then Exit ;
    If High(arrayKey) < 15 Then Exit ;
    sum := 0;
    delta := $9E3779B9;
    delta := delta And $FFFFFFFF;
    //SetLength(Result,8);

    tmpArray[3] := arrayIn[offset] ;
    tmpArray[2] := arrayIn[offset + 1];
    tmpArray[1] := arrayIn[offset + 2];
    tmpArray[0] := arrayIn[offset + 3];
    tmpArray[7] := arrayIn[offset + 4];
    tmpArray[6] := arrayIn[offset + 5];
    tmpArray[5] := arrayIn[offset + 6];
    tmpArray[4] := arrayIn[offset + 7];
    tmpArray[11] := arrayKey[0];
    tmpArray[10] := arrayKey[1];
    tmpArray[9] := arrayKey[2];
    tmpArray[8] := arrayKey[3];
    tmpArray[15] := arrayKey[4];
    tmpArray[14] := arrayKey[5];
    tmpArray[13] := arrayKey[6];
    tmpArray[12] := arrayKey[7];
    tmpArray[19] := arrayKey[8];
    tmpArray[18] := arrayKey[9];
    tmpArray[17] := arrayKey[10];
    tmpArray[16] := arrayKey[11];
    tmpArray[23] := arrayKey[12];
    tmpArray[22] := arrayKey[13];
    tmpArray[21] := arrayKey[14];
    tmpArray[20] := arrayKey[15];
    CopyMemory(@Y, @tmpArray[0], 4 ) ;
    CopyMemory(@z, @tmpArray[4], 4 );
    CopyMemory(@a, @tmpArray[8], 4 ) ;
    CopyMemory(@b, @tmpArray[12], 4);
    CopyMemory(@c, @tmpArray[16], 4);
    CopyMemory(@d, @tmpArray[20], 4);
    For I := 1 To 16 do
    begin

        sum := UnsignedAdd(sum, delta);
        sum := sum And $FFFFFFFF;
        Y := UnsignedAdd(Y, UnsignedAdd(LShift( z, 4), a) Xor UnsignedAdd(z, sum) Xor UnsignedAdd(RShift(z, 5), b));
        Y := Y And $FFFFFFFF;
        z := UnsignedAdd(z, UnsignedAdd(LShift(Y, 4), c) Xor UnsignedAdd(Y, sum) Xor UnsignedAdd(RShift(Y, 5), d));
        z := z And $FFFFFFFF;

      {  sum := sum+delta;
        sum := sum And $FFFFFFFF;
        y :=Y+((z shl 4) + a) xor (z + sum) xor ((z shr 5) + b);
        y :=Y and $FFFFFFFF;
        z :=Z+((y shl 4) + c) xor (y + sum) xor ((y shr 5) + d);
        z :=z and $FFFFFFFF;
       }
    end;
    CopyMemory(@tmpArray[0], @Y, 4);
    CopyMemory(@tmpArray[4], @z, 4);
    Result[0] := tmpArray[3];
    Result[1] := tmpArray[2];
    Result[2] := tmpArray[1];
    Result[3] := tmpArray[0];
    Result[4] := tmpArray[7];
    Result[5] := tmpArray[6];
    Result[6] := tmpArray[5];
    Result[7] := tmpArray[4];

    FCurrLen := 8;

    //Result := tmpOut;
end;

Function TQQTEA.Decipher(arrayIn,arrayKey:array of Byte;offset:Integer=0):TMYByte;
var
    I,y,z,a,b,c,d:Longint;
    sum,delta :Longint;
    tmpArray :Array [0..23] of Byte;
    tmpOut :Array [0..7] of Byte;
    //tmpOut:TMYByte;
begin
    If High(arrayIn) < 7 Then Exit ;
    If High(arrayKey) < 15 Then Exit;
    sum := $E3779B90;
    sum := sum And $FFFFFFFF;
    delta := $9E3779B9;
    delta := delta And $FFFFFFFF;

    tmpArray[3] := arrayIn[offset];
    tmpArray[2] := arrayIn[offset + 1];
    tmpArray[1] := arrayIn[offset + 2];
    tmpArray[0] := arrayIn[offset + 3];
    tmpArray[7] := arrayIn[offset + 4];
    tmpArray[6] := arrayIn[offset + 5];
    tmpArray[5] := arrayIn[offset + 6];
    tmpArray[4] := arrayIn[offset + 7];
    tmpArray[11] := arrayKey[0];
    tmpArray[10] := arrayKey[1];
    tmpArray[9] := arrayKey[2];
    tmpArray[8] := arrayKey[3];
    tmpArray[15] := arrayKey[4];
    tmpArray[14] := arrayKey[5];
    tmpArray[13] := arrayKey[6];
    tmpArray[12] := arrayKey[7];
    tmpArray[19] := arrayKey[8];
    tmpArray[18] := arrayKey[9];
    tmpArray[17] := arrayKey[10];
    tmpArray[16] := arrayKey[11];
    tmpArray[23] := arrayKey[12];
    tmpArray[22] := arrayKey[13];
    tmpArray[21] := arrayKey[14];
    tmpArray[20] := arrayKey[15];
    CopyMemory(@Y, @tmpArray[0], 4 );
    CopyMemory(@z, @tmpArray[4], 4);
    CopyMemory(@a, @tmpArray[8], 4);
    CopyMemory(@b, @tmpArray[12], 4);
    CopyMemory(@c, @tmpArray[16], 4);
    CopyMemory(@d, @tmpArray[20], 4);
    For I := 1 To 16 do
    begin

       { z :=Z-((y shl 4) + c) xor (y + sum) xor ((y shr 5) + d);
        z :=z and $FFFFFFFF;

        y :=Y-((z shl 4) + a) xor (z + sum) xor ((z shr 5) + b);
        y :=Y and $FFFFFFFF;
        sum := sum-delta;
        sum := sum And $FFFFFFFF;
        }
        z := UnsignedDel(z,(UnsignedAdd(LShift(Y, 4), c) Xor UnsignedAdd(Y, sum) Xor UnsignedAdd(RShift(Y, 5), d)));
        z := z And $FFFFFFFF;
        Y := UnsignedDel(Y, (UnsignedAdd(LShift(z, 4), a) Xor UnsignedAdd(z, sum) Xor UnsignedAdd(RShift(z, 5), b)));
        Y := Y And $FFFFFFFF ;
        sum := UnsignedDel(sum, delta);
        sum := sum And $FFFFFFFF;
    end;
    CopyMemory(@tmpArray[0],@Y, 4);
    CopyMemory(@tmpArray[4],@z, 4);
    tmpOut[0] := tmpArray[3];
    tmpOut[1] := tmpArray[2];
    tmpOut[2] := tmpArray[1];
    tmpOut[3] := tmpArray[0];
    tmpOut[4] := tmpArray[7];
    tmpOut[5] := tmpArray[6];
    tmpOut[6] := tmpArray[5];
    tmpOut[7] := tmpArray[4];

    //SetLength(Result,High(tmpOut)+1);
    CopyMemory(@Result[0],@tmpOut[0], 8);
    FCurrLen := 8;

    //Result := tmpOut;

end;

Function TQQTEA.LShift(lValue:Longint; iShiftBits:Integer):Integer;
begin
    Result :=0;
    If iShiftBits = 0 Then
    begin
        Result := lValue;
        Exit;
    end else If iShiftBits = 31 Then
    begin
      If (lValue And 1)<>0 Then
        Result := $80000000
      Else
        result := 0;                                             //guofan
      Exit;
    end Else If (iShiftBits < 0) Or (iShiftBits > 31) Then Raise Exception.Create('数据转换错误');

    If (lValue And m_l2Power[31 - iShiftBits])<>0 Then
        Result := ((lValue And m_lOnBits[31 - (iShiftBits + 1)]) * m_l2Power[iShiftBits]) Or $80000000
    Else
        Result := ((lValue And m_lOnBits[31 - iShiftBits]) * m_l2Power[iShiftBits]);
end;

Function TQQTEA.RShift(lValue:Longint; iShiftBits:Integer):Integer;
begin
    If iShiftBits = 0 Then
    begin
       RShift :=lValue;
       Exit;
    end
    Else If iShiftBits = 31 Then
    begin
        If (lValue And $80000000)<>0 Then
            RShift := 1
        else
            RShift := 0;
        Exit;
    end
    Else If (iShiftBits < 0) Or (iShiftBits > 31) Then
        Raise Exception.Create('数据转换错误');

    Result := (lValue And $7FFFFFFE) div m_l2Power[iShiftBits];

    If (lValue And $80000000)<>0 Then
        Result := (Result Or ($40000000 div m_l2Power[iShiftBits - 1]))
end;

Function TQQTEA.UnsignedAdd(Data1:integer; Data2:integer):integer;
var
  x1:array [0..3] of byte;
  x2:array [0..3] of byte;
  xx:array [0..3] of byte;
  Rest ,value , a :integer;

begin
    CopyMemory(@x1[0], @Data1, 4);
    CopyMemory(@x2[0], @Data2, 4);
    Rest := 0;
    For a := 0 To 3 do
    begin
        value :=Round(x1[a]) + Round(x2[a])+ Rest;
        xx[a] := value And 255;
        Rest  := value div 256;
    end;
    CopyMemory(@Result, @xx[0], 4);
end;

Function TQQTEA.UnsignedDel(Data1, Data2:integer):integer;
var
  x1:array [0..3] of byte;
  x2:array [0..3] of byte;
  xx:array [0..3] of byte;
  Rest ,value , a :integer;
begin
    CopyMemory(@x1[0], @Data1, 4);
    CopyMemory(@x2[0], @Data2, 4);
    CopyMemory(@xx[0], @Result, 4);
    Rest :=0;
    For a := 0 To 3 do
    begin
      value := Round(x1[a]) - Round(x2[a]) - Rest;
      If (value < 0) Then
      begin
          value := value + 256;
          Rest  := 1;
      end
      Else
          Rest := 0;
      xx[a] := value;
    end;
    CopyMemory(@Result, @xx[0], 4);
end;

procedure TQQTEA.Class_Initialize();
begin
    m_lOnBits[0] := 1 ;//           ' 00000000000000000000000000000001
    m_lOnBits[1] := 3 ;//              ' 00000000000000000000000000000011
    m_lOnBits[2] := 7  ;//             ' 00000000000000000000000000000111
    m_lOnBits[3] := 15 ;//             ' 00000000000000000000000000001111
    m_lOnBits[4] := 31 ;//             ' 00000000000000000000000000011111
    m_lOnBits[5] := 63 ;//             ' 00000000000000000000000000111111
    m_lOnBits[6] := 127 ;//            ' 00000000000000000000000001111111
    m_lOnBits[7] := 255  ;//           ' 00000000000000000000000011111111
    m_lOnBits[8] := 511  ;//           ' 00000000000000000000000111111111
    m_lOnBits[9] := 1023 ;//           ' 00000000000000000000001111111111
    m_lOnBits[10]:= 2047 ;//          ' 00000000000000000000011111111111
    m_lOnBits[11]:= 4095 ;//          ' 00000000000000000000111111111111
    m_lOnBits[12] := 8191 ;//          ' 00000000000000000001111111111111
    m_lOnBits[13] := 16383;//          ' 00000000000000000011111111111111
    m_lOnBits[14] := 32767 ;//         ' 00000000000000000111111111111111
    m_lOnBits[15] := 65535 ;//         ' 00000000000000001111111111111111
    m_lOnBits[16] := 131071;//         ' 00000000000000011111111111111111
    m_lOnBits[17] := 262143 ;//        ' 00000000000000111111111111111111
    m_lOnBits[18] := 524287 ;//        ' 00000000000001111111111111111111
    m_lOnBits[19] := 1048575;//        ' 00000000000011111111111111111111
    m_lOnBits[20] := 2097151;//        ' 00000000000111111111111111111111
    m_lOnBits[21] := 4194303 ;//       ' 00000000001111111111111111111111
    m_lOnBits[22] := 8388607 ;//       ' 00000000011111111111111111111111
    m_lOnBits[23] := 16777215;//       ' 00000000111111111111111111111111
    m_lOnBits[24] := 33554431;//       ' 00000001111111111111111111111111
    m_lOnBits[25] := 67108863;//       ' 00000011111111111111111111111111
    m_lOnBits[26] := 134217727;//      ' 00000111111111111111111111111111
    m_lOnBits[27] := 268435455;//      ' 00001111111111111111111111111111
    m_lOnBits[28] := 536870911;//      ' 00011111111111111111111111111111
    m_lOnBits[29] := 1073741823;//     ' 00111111111111111111111111111111
    m_lOnBits[30] := 2147483647;//     ' 01111111111111111111111111111111
    // Could have done this with a loop calculating each value, but simply
    // assigning the values is quicker - POWERS OF 2
    m_l2Power[0] := 1  ;//          ' 00000000000000000000000000000001
    m_l2Power[1] := 2  ;//          ' 00000000000000000000000000000010
    m_l2Power[2] := 4  ;//          ' 00000000000000000000000000000100
    m_l2Power[3] := 8  ;//          ' 00000000000000000000000000001000
    m_l2Power[4] := 16  ;//         ' 00000000000000000000000000010000
    m_l2Power[5] := 32  ;//         ' 00000000000000000000000000100000
    m_l2Power[6] := 64  ;//         ' 00000000000000000000000001000000
    m_l2Power[7] := 128 ;//         ' 00000000000000000000000010000000
    m_l2Power[8] := 256 ;//         ' 00000000000000000000000100000000
    m_l2Power[9] := 512  ;//        ' 00000000000000000000001000000000
    m_l2Power[10] := 1024 ;//       ' 00000000000000000000010000000000
    m_l2Power[11] := 2048 ;//       ' 00000000000000000000100000000000
    m_l2Power[12] := 4096 ;//       ' 00000000000000000001000000000000
    m_l2Power[13] := 8192  ;//      ' 00000000000000000010000000000000
    m_l2Power[14] := 16384 ;//      ' 00000000000000000100000000000000
    m_l2Power[15] := 32768 ;//      ' 00000000000000001000000000000000
    m_l2Power[16] := 65536  ;//     ' 00000000000000010000000000000000
    m_l2Power[17] := 131072;//      ' 00000000000000100000000000000000
    m_l2Power[18] := 262144 ;//     ' 00000000000001000000000000000000
    m_l2Power[19] := 524288 ;//     ' 00000000000010000000000000000000
    m_l2Power[20] := 1048576;//     ' 00000000000100000000000000000000
    m_l2Power[21] := 2097152 ;//    ' 00000000001000000000000000000000
    m_l2Power[22] := 4194304 ;//    ' 00000000010000000000000000000000
    m_l2Power[23] := 8388608 ;//    ' 00000000100000000000000000000000
    m_l2Power[24] := 16777216;//    ' 00000001000000000000000000000000
    m_l2Power[25] := 33554432;//    ' 00000010000000000000000000000000
    m_l2Power[26] := 67108864 ;//   ' 00000100000000000000000000000000
    m_l2Power[27] := 134217728;//   ' 00001000000000000000000000000000
    m_l2Power[28] := 268435456;//   ' 00010000000000000000000000000000
    m_l2Power[29] := 536870912 ;//  ' 00100000000000000000000000000000
    m_l2Power[30] := 1073741824;//  ' 01000000000000000000000000000000
end;

Function TQQTEA.Rand:Integer;
begin
  //Randomize;
  //Result := UnsignedAdd(Trunc(Random * 2147483647), Trunc(Random * 2147483647))
  Result :=100;
end;

constructor TQQTEA.Create;
begin
  Class_Initialize;
end;

procedure TQQTEA.ClearArray(var Arr: array of Byte);
var
  i:integer;
begin
  For I:=0 to High(Arr) do
    Arr[i]:=0;
end;

function TQQTEA.GetFCurrLen: integer;
begin
 Result := FCurrLen;
end;

procedure InitArray(var My: TMyByte);
var
  i:integer;
begin
  For i:=0 to 500  do
     My[i]:=0;
end;


{
initialization
  QQTEA:=TQQTEA.Create;
finalization
  FreeAndNil(QQTEA);
 }
end.
