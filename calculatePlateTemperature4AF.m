function [plateTemperature,T_PlateXPos,tempdifference] = calculatePlateTemperature4AF(ID,...
    plateGrade, plateLength, plateWidth, plateThickness,...
    plateSpeed, plateHeadLocation,...
    T_AF_Upp, T_AF_Low,...
    delta_t, targetPlateTemperature, prevPlateTemperature)
%% 该函数作用：实现AF内钢板加热过程温度分布计算

%  (1) Input
%      ID:                     string类型，钢板的ID
%      plateGrade:             string类型，钢板的牌号
%      plateLength:            double类型，钢板的长度（mm）
%      plateWidth:             double类型，钢板的宽度（mm）
%      plateThickness:         double类型，钢板的厚度（mm）
%      plateSpeed:             double类型，钢板在AF中的运动速度（m/min）
%      plateHeadLocation:      double类型，钢板的头部位置（mm）
%      T_AF_Upp：              double array类型(1*11行向量)，上部11支热电偶的温度（℃）
%      T_AF_Low：              double array类型(1*11行向量)，下部11支热电偶的温度（℃）
%      delta_t：               double类型，时间步长；（s）
%      targetPlateTemperature：double类型，钢板的目标温度（℃）
%      prevPlateTemperature：  double array类型(1*N行向量)，前一时刻钢板温度分布向量（℃）

%  (2) Output
%      plateTemperature：      double array类型(1*N行向量)（℃）
%      运算结果存储在表中：      表名是钢坯ID
%                               第1列为时刻，0,1,2，...
%                               第2列为计算机的系统时间
%                               第3列~第N+2列为钢板各层温度（℃）
%                               第N+3列~第N+5列为钢板上下表面及中心温度（℃）
%                               ..........待完善。
%      T_PlateXPos:            double array类型(1*2行向量)(℃)
%      tempdifference:         double类型，钢板的温差(℃)
%% 准备工作
% ***** 下面代码的功能：钢板数据的单位转换 ***********************************
% ***************************************************************************
plateLength = plateLength/1000;                 % 单位转换，由mm转换成m
plateWidth = plateWidth/1000;                   % 单位转换，由mm转换成m
plateThickness = plateThickness/1000;           % 单位转换，由mm转换成m
plateSpeed = plateSpeed/60;                     % 单位转换，由m/min转换成m/s
plateHeadLocation = plateHeadLocation/1000;     % 单位转换，由mm转换成m
% ***** 上面代码的功能：钢板数据的单位转换 **********************************
% ***************************************************************************

% ***** 下面代码的功能：计算层数和空间步长 *********************************************
% **************************************************************************************
layerNumber = length(prevPlateTemperature) - 1; % 由前一时刻钢板温度分布计算钢板划分层数
delta_x = plateThickness/layerNumber;           % 计算空间步长
% ***** 上面代码的功能：计算层数和空间步长 *********************************************
% **************************************************************************************

% ***** 下面代码的功能：给出进料炉门位置（或称坐标）及11个区域尾部位置（或称坐标）******
% *************************************************************************************
CHARGING_DOOR_LOCATION = 29600;
SECTION1_TAIL_LOCATION = 38000;
SECTION2_TAIL_LOCATION = 45200;
SECTION3_TAIL_LOCATION = 52400;
SECTION4_TAIL_LOCATION = 59600;
SECTION5_TAIL_LOCATION = 66800;
SECTION6_TAIL_LOCATION = 74000;
SECTION7_TAIL_LOCATION = 81200;
SECTION8_TAIL_LOCATION = 88400;
SECTION9_TAIL_LOCATION = 95600;
SECTION10_TAIL_LOCATION = 102800;
SECTION11_TAIL_LOCATION = 118000;

KEY_POINT_LOCATION = [CHARGING_DOOR_LOCATION, SECTION1_TAIL_LOCATION,...
    SECTION2_TAIL_LOCATION, SECTION3_TAIL_LOCATION, SECTION4_TAIL_LOCATION,...
    SECTION5_TAIL_LOCATION, SECTION6_TAIL_LOCATION, SECTION7_TAIL_LOCATION,...
    SECTION8_TAIL_LOCATION, SECTION9_TAIL_LOCATION, SECTION10_TAIL_LOCATION,...
    SECTION11_TAIL_LOCATION]/1000;
% ***** 上面代码的功能：给出进料炉门位置（或称坐标）及11个区域尾部位置（或称坐标）******
% *************************************************************************************
 

%% 以下程序功能：通过子函数 calcualatePhicf 和 calPlateTemp4AF 计算当前时刻钢板头部温度
plateHeadTemperature = prevPlateTemperature;

% ***** 下面代码的功能：计算钢板头部 phicf ****************************************
% *********************************************************************************
[phicf_PlateHead_Upp, phicf_PlateHead_Low] = calcualatePhicf(plateLength,...
    plateSpeed, plateHeadLocation, plateHeadTemperature);
% ***** 上面代码的功能：计算钢板头部 phicf ****************************************
% *********************************************************************************

% ***** 下面代码的功能：由前一时刻钢板头部温度计算当前时刻钢板头部温度（是一向量）***
% **********************************************************************************
T_AF = [T_AF_Upp; T_AF_Low];

% ----- 首先，调用子函数 checkPlateCategory，给出钢板的类别号 -----------------
plateCategoryNumber = checkPlateCategory(plateGrade);

% ----- 然后，调用子函数 calPlateTemp4QF，运用有限差分法（隐式）和第三类 ------
% ----- 边界条件，由前一时刻钢板头部温度计算当前时刻钢板头部温度（是一向量）---
[plateHeadTemp,T_PlateXPos_Upp,T_PlateXPos_Low] = calPlateTemp4QF(plateHeadLocation,...
    plateHeadTemperature, plateCategoryNumber, T_AF,...
    phicf_PlateHead_Upp, phicf_PlateHead_Low, delta_x, delta_t, layerNumber);

% -----最后，输出钢板温度 ----------------------------------------------------
plateTemperature = plateHeadTemp(end,:); % plateHeadTemp 共两行，分别是上一
                                         % 时刻和当前时刻的钢板头部温度分布
% ***** 上面代码的功能：由前一时刻钢板头部温度计算当前时刻钢板头部温度（是一向量）***
% ***********************************************************************************


bb=plateTemperature(end);
aa=plateTemperature(round((layerNumber+1)/2));

tempdifference=bb-aa;

T_PlateXPos=[T_PlateXPos_Upp,T_PlateXPos_Low];

end



%% ----------------------- All subfunctions are list below ---------------
%% 计算钢板X处的钢温分布
function [plateXPosTemp,T_PlateXPos_Upp,T_PlateXPos_Low] = calPlateTemp4QF(plateXPosLocation,...
    plateXPosTemperature, plateCategoryNumber, T_AF,...
    phicf_PlateXPos_Upp, phicf_PlateXPos_Low,...
    delta_x, delta_t, layerNumber)

plateXPosTemp = plateXPosTemperature;

rou = 7860;                                  % 密度kg/m3
cp_PlateXPos = zeros(layerNumber+1,1);       % 比热
lambda_PlateXPos = zeros(layerNumber+1,1);   % 导热系数
epsilon = 0.8;                               % 钢板黑度
sigma = 5.67E-8;                             % 玻尔兹曼常数                     

% ***** 下面代码的功能：使用平均温度计算物性参数 *****************************
% ***************************************************************************
k = 1;
averagePlateXPosTemp = sum(plateXPosTemp(k,:))/(layerNumber+1); 
[cp_PlateXPos(1:(layerNumber+1)), lambda_PlateXPos(1:(layerNumber+1))]...
    = calculatePhysicalParameters(plateCategoryNumber, averagePlateXPosTemp);
% ***** 上面代码的功能：使用平均温度计算物性参数 *****************************
% ***************************************************************************

% ***** 下面代码的功能：调用 calculateFurnaceTemperature，利用插值计算炉温 ******
% ******************************************************************************
[T_PlateXPos_Upp, T_PlateXPos_Low] = ... 
    calculateFurnaceTemperature(plateXPosLocation, T_AF);
% ***** 上面代码的功能：调用 calculateFurnaceTemperature，利用插值计算炉温 *****
% ******************************************************************************

% ***** 下面代码的功能：单位转换，由摄氏度℃转换为开氏温度K *********
% ******************************************************************
T_PlateXPos_Upp = T_PlateXPos_Upp + 273.15;
T_PlateXPos_Low = T_PlateXPos_Low + 273.15;
plateXPosTemp = plateXPosTemp + 273.15;
% ***** 上面代码的功能：单位转换，由摄氏度℃转换为开氏温度K *********
% ******************************************************************

% ***** 下面代码的功能：给出傅里叶数，以便计算主对角线和副对角线 *******
% *********************************************************************
Fo = (lambda_PlateXPos./(rou.*cp_PlateXPos))*delta_t/delta_x^2; 
% ***** 上面代码的功能：给出傅里叶数，以便计算主对角线和副对角线 *******
% *********************************************************************

% ***** 下面代码的功能：计算当前时刻上下表面钢板温度 **************************************
% ****************************************************************************************
plateXPosTemp(k+1,1) = 2*Fo(1)*(plateXPosTemp(k,2)-plateXPosTemp(k,1)) + ...
    2*phicf_PlateXPos_Upp*sigma*delta_t*((T_PlateXPos_Upp)^4-(plateXPosTemp(k,1))^4)/...
    (rou*cp_PlateXPos(1)*delta_x) + plateXPosTemp(k,1);

plateXPosTemp(k+1,layerNumber+1) = 2*Fo(layerNumber+1)*(plateXPosTemp(k,layerNumber)-...
    plateXPosTemp(k,layerNumber+1)) + 2*phicf_PlateXPos_Low*sigma*delta_t*...
    ((T_PlateXPos_Low)^4-(plateXPosTemp(k,layerNumber+1))^4)/...
    (rou*cp_PlateXPos(layerNumber+1)*delta_x) + plateXPosTemp(k,layerNumber+1);
% ***** 上面代码的功能：计算当前时刻上下表面钢板温度 *************************************
% ****************************************************************************************

% ***** 下面代码的功能：TDMA求解隐式方程，获得当前时刻除上下表面外各层钢板温度 ******
% **********************************************************************************
B = zeros(layerNumber-1,1);
A = zeros(layerNumber-2,1);
C = zeros(layerNumber-2,1);
D = zeros(layerNumber-1,1);
C1 = zeros(layerNumber-2,1);
D1 = zeros(layerNumber-1,1);

A(1 : layerNumber-2) = -Fo(1 : layerNumber-2);
B(1 : layerNumber-1) = 1+2*Fo(1 : layerNumber-1);
C(1 : layerNumber-2) = -Fo(1 : layerNumber-2);

D(1,1) = plateXPosTemp(k,2) + Fo(1)*plateXPosTemp(k+1,1);
D((2 : layerNumber-2)) = plateXPosTemp(k,(3 : layerNumber-1));
D(layerNumber-1,1) = plateXPosTemp(k,layerNumber) + ...
    Fo(layerNumber+1)*plateXPosTemp(k+1,layerNumber+1);
D1(1) = D(1)/B(1);
T = B(1);
kk = 2;
while kk~=layerNumber
    C1(kk-1) = C(kk-1)/T;
    T = B(kk) - A(kk-1)*C1(kk-1);
    D1(kk) = (D(kk) - A(kk-1)*D1(kk-1))/T;
    kk = kk + 1;
end
plateXPosTemp(k+1,layerNumber) = D1(layerNumber-1);
for kk = layerNumber-1 : -1 : 2
    plateXPosTemp(k+1,kk) = D1(kk-1) - C1(kk-1)*plateXPosTemp(k+1,kk+1);
end
% ***** 上面代码的功能：TDMA求解隐式方程，获得当前时刻除上下表面外各层钢板温度 ******
% **********************************************************************************

% ***** 下面代码的功能：单位转换，由开氏温度K转换为摄氏度℃ ********
% *****************************************************************
plateXPosTemp = plateXPosTemp - 273.15;
T_PlateXPos_Upp = T_PlateXPos_Upp - 273.15;
T_PlateXPos_Low = T_PlateXPos_Low - 273.15;
% ***** 上面代码的功能：单位转换，由开氏温度K转换为摄氏度℃ *******
% *****************************************************************

end

%% 计算总括热吸收率
function [phicf_PlateXPos_Upp, phicf_PlateXPos_Low] = ...
    calcualatePhicf(plateLength, plateSpeed, plateXPosLocation, plateXPosTemperature)

if plateXPosLocation <= 52400
    phicf_PlateXPos_Upp = 0.8001;
    phicf_PlateXPos_Low = 0.8001;
elseif (52400 < plateXPosLocation) && (plateXPosLocation <= 81200)
    phicf_PlateXPos_Upp = 0.80;
    phicf_PlateXPos_Low = 0.80;
else
    phicf_PlateXPos_Upp = 0.80;
    phicf_PlateXPos_Low = 0.80;
end

end

%% 利用钢坯位置进行炉温插值
function [T_PlateXPos_Upp, T_PlateXPos_Low] = ...
    calculateFurnaceTemperature(plateXPosLocation, T_AF)
% plateXPosLocation：   钢坯的头/中/尾部位置；
% T_AF：                2*11的数组，AF内热电偶的温度测量值；
% 需要说明的是：        输入输出温度单位均是℃。

% ***** 下面代码的功能：给出AF内热电偶的位置 *******************************
% *************************************************************************
plateXPosLocation=plateXPosLocation*1000;
TC_LOCATION = ...
    [36250 43350 50550 57750 64500 71700 80100 86100 93300 100500 107050
     36250 43350 50550 57750 64950 72150 80550 87750 93750 100950 109450];
% ***** 上面代码的功能：给出AF内热电偶的位置 ******************************
% *************************************************************************

temp1 = (plateXPosLocation-TC_LOCATION) >= 0;
index1 = sum(temp1(1,:));
index2 = index1 + 1;
index3 = sum(temp1(2,:));
index4 = index3 + 1;

if plateXPosLocation <= 36250
    T_PlateXPos_Upp = T_AF(1,1);
    T_PlateXPos_Low = T_AF(2,1);
elseif  (plateXPosLocation >= 107050) && (plateXPosLocation < 109450)
    T_PlateXPos_Upp = T_AF(1,11);
    T_PlateXPos_Low = T_AF(2,index3) +...
        (T_AF(2,index4) - T_AF(2,index3))*...
        (plateXPosLocation - TC_LOCATION(2,index3) + 1e-10)/...
        (TC_LOCATION(2,index4) - TC_LOCATION(2,index3) + 1e-10);
elseif (plateXPosLocation > 36250) && (plateXPosLocation < 107050) 
    T_PlateXPos_Upp = T_AF(1,index1) +...
        (T_AF(1,index2) - T_AF(1,index1))*...
        (plateXPosLocation - TC_LOCATION(1,index1) + 1e-10)/...
        (TC_LOCATION(1,index2) - TC_LOCATION(1,index1) + 1e-10);
    T_PlateXPos_Low = T_AF(2,index3) +...
        (T_AF(2,index4) - T_AF(2,index3))*...
        (plateXPosLocation - TC_LOCATION(2,index3) + 1e-10)/...
        (TC_LOCATION(2,index4) - TC_LOCATION(2,index3) + 1e-10);
elseif  plateXPosLocation >= 109450
    T_PlateXPos_Upp = T_AF(1,11);
    T_PlateXPos_Low = T_AF(2,11);

end
end



%% 计算物性参数
function [cp_PlateXPos, lambda_PlateXPos] = ...
    calculatePhysicalParameters(plateCategoryNumber, averagePlateXPosTemp)

% ***** 上面代码的功能：计算比热容 cp ****************************************************
% ****************************************************************************************
T_cp = [100*(1:12) 1250];
cp_Set = ...
    [0.465 0.465 0.469 0.473 0.477 0.482 0.494 0.486
     0.477 0.477 0.482 0.482 0.486 0.486 0.502 0.494
     0.494 0.498 0.502 0.507 0.511 0.515 0.519 0.515
     0.515 0.515 0.515 0.523 0.523 0.528 0.536 0.528
     0.532 0.532 0.536 0.536 0.540 0.544 0.553 0.544
     0.565 0.565 0.565 0.573 0.574 0.574 0.582 0.578
     0.599 0.599 0.603 0.603 0.607 0.607 0.615 0.607
     0.666 0.678 0.691 0.691 0.687 0.678 0.687 0.682
     0.708 0.703 0.699 0.691 0.687 0.678 0.670 0.674
     0.708 0.703 0.699 0.691 0.687 0.678 0.653 0.674
     0.708 0.703 0.699 0.691 0.691 0.682 0.662 0.678
     0.708 0.708 0.703 0.695 0.691 0.687 0.662 0.678
     0.708 0.708 0.699 0.695 0.695 0.687 0.662 0.678];

cp_Set = cp_Set(:,[2 3 6])';

if averagePlateXPosTemp >= 1250
    if plateCategoryNumber == 1
        cp_PlateXPos = cp_Set(1,end);
    elseif plateCategoryNumber == 2
        cp_PlateXPos = cp_Set(2,end);
    else
        cp_PlateXPos = cp_Set(3,end);
    end
elseif averagePlateXPosTemp <= 100
    if plateCategoryNumber == 1
        cp_PlateXPos = cp_Set(1,1);
    elseif plateCategoryNumber == 2
        cp_PlateXPos = cp_Set(2,1);
    else
        cp_PlateXPos = cp_Set(3,1);
    end
else
    temp2 = (averagePlateXPosTemp - T_cp) >= 0;
    index4 = sum(temp2);
    index5 = index4 + 1;
    cp_PlateXPos = cp_Set(plateCategoryNumber,index4) +...
        (averagePlateXPosTemp - T_cp(index4))*...
        (cp_Set(plateCategoryNumber,index5) - cp_Set(plateCategoryNumber,index4) + 1e-10)/...
        (T_cp(index5) - T_cp(index4) + 1e-10);
end

% --- 注意：上面表格中 cp 单位是 kJ/(kg*℃)，而计算时需要的是J/(kg*℃)，故下面×1000 ---
cp_PlateXPos = 1000*cp_PlateXPos;

% ***** 上面代码的功能：计算比热容 cp ****************************************************
% ****************************************************************************************

% ***** 下面代码的功能：计算导热系数lambda *************************************************
% ******************************************************************************************
T_lambda = 100*(1:12);
lambda_Set = [55.6 52.7 48.5 45.0 40.8 37.1 34.2 30.1 27.3 27.7 28.5 29.8
              49.3 48.1 45.6 42.4 39.1 35.7 32.4 26.2 26.0 26.9 28.0 29.5
              46.5 44.0 40.8 37.7 35.0 32.3 29.2 24.1 25.2 26.5 27.9 29.4];

if averagePlateXPosTemp >= 1200
    if plateCategoryNumber == 1
        lambda_PlateXPos = lambda_Set(1,end);
    elseif plateCategoryNumber == 2
        lambda_PlateXPos = lambda_Set(2,end);
    else
        lambda_PlateXPos = lambda_Set(3,end);
    end
elseif averagePlateXPosTemp <= 100
    if plateCategoryNumber == 1
        lambda_PlateXPos = lambda_Set(1,1);
    elseif plateCategoryNumber == 2
        lambda_PlateXPos = lambda_Set(2,1);
    else
        lambda_PlateXPos = lambda_Set(3,1);
    end
else
    temp2 = (averagePlateXPosTemp - T_lambda) >= 0;
    index4 = sum(temp2);
    index5 = index4 + 1;
    lambda_PlateXPos = lambda_Set(plateCategoryNumber,index4) +...
        (averagePlateXPosTemp - T_lambda(index4))*...
        (lambda_Set(plateCategoryNumber,index5) - lambda_Set(plateCategoryNumber,index4) + 1e-10)/...
        (T_lambda(index5) - T_lambda(index4) + 1e-10);
end
% ***** 上面代码的功能：计算导热系数lambda *************************************************
% ******************************************************************************************
end

%% 判断钢种类别
function [categoryNumber] = checkPlateCategory(plateGrade)
% categoryNumber = 1, 低碳钢；
% categoryNumber = 2, 中碳钢；
% categoryNumber = 3, 高碳钢。

plateGradeSet1 = ["Q235","Q345","IS2041 R355","ASME SA537 CL-1",...
                   "ASME SA387 Gr11","ASME SA387 Gr22","ASME SA387 Gr12",...
                   "EN-10028-3 P355NH","EN-10028-3 P460NH","EN-10028-3 16Mo 3",...
                   "EN-10028-3 P265GH","IS2002 GRADE 2","BSEN 10225 S355 G2",...
                   "BSEN 10225 S355 G7+N","BSEN 10225 S355 G8+N","ASTM A572 Gr 50",...
                   "CSA G 40.21 44W","E250 BR","E250 C","E250 B0","E300BR",...
                   "E350 BR","E350 C","E350 B0","E410 BR","E410 B0","E410 C",...
                   "E450 BR","E420 N","API 2H GR 50","API 5L Grade PSL-2",...
                   "LR DH36","ABS EH 36","ASTM A1 31 DH 36"];
plateGradeSet2 = ["ASME SA516 Gr70","ASME SA516 Gr60","ASME SA516 Gr65",...
                   "ASME 515Gr70","ASTM A 572 Grade 65 Type 3","ASTM A36",...
                   "API 5L Grade X-70"];
if sum(ismember(plateGradeSet1, plateGrade)) == 1
    categoryNumber = 1;
elseif sum(ismember(plateGradeSet2, plateGrade)) == 1
    categoryNumber = 2;
else
    categoryNumber = 3;
end
end