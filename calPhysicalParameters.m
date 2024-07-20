function [cp_PlateXPos, lambda_PlateXPos] = ...
    calPhysicalParameters(plateCategoryNumber, PlateXPosTemp)
%% 该函数作用：基于钢板类别编号和当前温度，给出钢板在当前温度下的物性参数

%  (1) Input
%      plateCategoryNumber:   int类型，钢板类别编号
%      PlateXPosTemp:         double类型，钢板当前温度（℃）

%  (2) Output
%      cp_PlateXPos：         double类型，钢板当前温度下比热容[J/(kg*℃)]
%      lambda_PlateXPos：     double类型，钢板当前温度下导热系数[W/(m*℃)]

%% 以下为函数程序

% ***** 在使用时，下面程序需根据实际情况进行修正 **************************
% ************************************************************************

% ------ 与下面比热容数组相对应的温度向量（℃）----------------------------
T_cp = [100*(1:12) 1250];    

% ------ 下面比热容数组中，前8列对应于不同含碳百分数的碳钢（依次为 --------
% ------ 0.090, 0.224, 0.300, 0.540, 0.610, 0.795, 0.950, 1.410），-------
% ------ 参考资料：王秉铨. 工业炉设计手册（第3版）[M]. 机械工业出版 -------
% ------ 社, P102；-------------------------------------------------------
% ------ 第9列对应于不锈钢304（注：参考资料中给出的只有[100*(1:12)]共 -----
% ------ 12个温度对应的数值，而没有1250℃时的数值，但在下面数组中为了------
% ------ 跟碳钢比热容数组大小一致，将1250℃时的数值记为1200℃时的数 -------
% ------ 值），参考资料：不锈钢304高温热物理性能汇编. P4. -----------------
cp_Set = ...
    [0.465 0.465 0.469 0.473 0.477 0.482 0.494 0.486 0.506
     0.477 0.477 0.482 0.482 0.486 0.486 0.502 0.494 0.522
     0.494 0.498 0.502 0.507 0.511 0.515 0.519 0.515 0.537
     0.515 0.515 0.515 0.523 0.523 0.528 0.536 0.528 0.553
     0.532 0.532 0.536 0.536 0.540 0.544 0.553 0.544 0.569
     0.565 0.565 0.565 0.573 0.574 0.574 0.582 0.578 0.583
     0.599 0.599 0.603 0.603 0.607 0.607 0.615 0.607 0.600
     0.666 0.678 0.691 0.691 0.687 0.678 0.687 0.682 0.615
     0.708 0.703 0.699 0.691 0.687 0.678 0.670 0.674 0.631
     0.708 0.703 0.699 0.691 0.687 0.678 0.653 0.674 0.647
     0.708 0.703 0.699 0.691 0.691 0.682 0.662 0.678 0.662
     0.708 0.708 0.703 0.695 0.691 0.687 0.662 0.678 0.678
     0.708 0.708 0.699 0.695 0.695 0.687 0.662 0.678 0.678];

cp_Set = cp_Set(:,[2 3 6 9])';

% ------ 与下面热导率数组相对应的温度向量（℃）----------------------------
T_lambda = 100*(1:12);

% ------ 下面热导率数组中，前三行依次对应于低碳钢、中碳钢、高碳钢，--------
% ------ 第四行对应于不锈钢 304；列代表从100℃到1200℃，间隔为100℃ -------
% ------ 参考资料同上面的比热容参考资料。 --------------------------------
lambda_Set = [55.6 52.7 48.5 45.0 40.8 37.1 34.2 30.1 27.3 27.7 28.5 29.8
              49.3 48.1 45.6 42.4 39.1 35.7 32.4 26.2 26.0 26.9 28.0 29.5
              46.5 44.0 40.8 37.7 35.0 32.3 29.2 24.1 25.2 26.5 27.9 29.4
              16.0 17.5 18.9 20.3 21.7 23.1 24.5 25.9 27.4 28.7 30.2 31.6]; 

% ----- 注意1：如果实际钢种分组情况、上面温度向量、比热容数组、导热率 ------
% -----        数组发生变化，下面程序也可能需做相应修改 --------------------

% ***** 在使用时，上面程序需根据实际情况进行修正 **************************
% ************************************************************************


% ***** 下面代码的功能：计算钢板比热容 cp *********************************************
% ************************************************************************************

% ----- 下面代码的功能：基于线性插值和钢板类别编号，计算钢板给定温度下的比热容 -------
if PlateXPosTemp >= 1250
    if plateCategoryNumber == 1
        cp_PlateXPos = cp_Set(1,end);
    elseif plateCategoryNumber == 2
        cp_PlateXPos = cp_Set(2,end);
    elseif plateCategoryNumber == 3
        cp_PlateXPos = cp_Set(3,end);
    else 
        cp_PlateXPos = cp_Set(4,end);
    end
elseif PlateXPosTemp <= 100
    if plateCategoryNumber == 1
        cp_PlateXPos = cp_Set(1,1);
    elseif plateCategoryNumber == 2
        cp_PlateXPos = cp_Set(2,1);
    elseif plateCategoryNumber == 3
        cp_PlateXPos = cp_Set(3,1);
    else 
        cp_PlateXPos = cp_Set(4,1);
    end
else
    temp1 = (PlateXPosTemp - T_cp) >= 0;
    index1 = sum(temp1);
    index2 = index1 + 1;
    cp_PlateXPos = cp_Set(plateCategoryNumber,index1) + ...
        (PlateXPosTemp - T_cp(index1))*...
        (cp_Set(plateCategoryNumber,index2) - cp_Set(plateCategoryNumber,index1))/...
        (T_cp(index2) - T_cp(index1));
end

% ----- 注：上面表格中比热容 cp 的单位是 kJ/(kg*℃)，而计算时需要的是J/(kg*℃) -------
cp_PlateXPos = 1000*cp_PlateXPos;

% ***** 上面代码的功能：计算钢板比热容 cp *********************************************
% ************************************************************************************


% ***** 下面代码的功能：计算钢板导热系数 lambda ***************************************
% ************************************************************************************

% ----- 下面代码功能：基于线性插值和钢板类别编号，计算钢板给定温度下的导热系数 -------
if PlateXPosTemp >= 1200
    if plateCategoryNumber == 1
        lambda_PlateXPos = lambda_Set(1,end);
    elseif plateCategoryNumber == 2
        lambda_PlateXPos = lambda_Set(2,end);
    elseif plateCategoryNumber == 3
        lambda_PlateXPos = lambda_Set(3,end);
    else 
        lambda_PlateXPos = lambda_Set(4,end);
    end
elseif PlateXPosTemp <= 100
    if plateCategoryNumber == 1
        lambda_PlateXPos = lambda_Set(1,1);
    elseif plateCategoryNumber == 2
        lambda_PlateXPos = lambda_Set(2,1);
    elseif plateCategoryNumber == 3
        lambda_PlateXPos = lambda_Set(3,1);
    else 
        lambda_PlateXPos = lambda_Set(4,1);
    end
else
    temp1 = (PlateXPosTemp - T_lambda) >= 0;
    index3 = sum(temp1);
    index4 = index3 + 1;
    lambda_PlateXPos = lambda_Set(plateCategoryNumber, index3) + ...
        (PlateXPosTemp - T_lambda(index3))*...
        (lambda_Set(plateCategoryNumber, index4) - lambda_Set(plateCategoryNumber, index3))/...
        (T_lambda(index4) - T_lambda(index3));
end

% ***** 上面代码的功能：计算钢板导热系数 lambda *********************************************
% ******************************************************************************************

end