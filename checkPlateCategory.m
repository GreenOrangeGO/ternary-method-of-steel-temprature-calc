function categoryNumber = checkPlateCategory(plateGrade)
%% 该函数作用：基于输入的钢板牌号，给出钢板类别编号

%  (1) Input
%      plateGrade:             string类型，钢板的牌号

%  (2) Output
%      categoryNumber：        int类型，钢板的类别编号

%% 以下为函数程序
 
% ***** 在使用时，下面程序需根据实际情况进行修正 ************************************
% **********************************************************************************
% ----- 下面代码的功能：按钢种进行分类----------------------------------------------
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
plateGradeSet3 = ["xx","高碳钢组"];
plateGradeSet4 = ["304","不锈钢组"];

% ----- 注意1：如果实际钢种分组情况发生变化，下面程序也需做相应修改-----------------

% ***** 在使用时，上面程序需根据实际情况进行修正 ************************************
% **********************************************************************************

% ***** 下面代码的功能：根据输入的钢种，判断钢板类别编号 *****************
% ***********************************************************************
if sum(ismember(plateGradeSet1, plateGrade)) == 1
    categoryNumber = 1;           % 低碳钢
elseif sum(ismember(plateGradeSet2, plateGrade)) == 1
    categoryNumber = 2;           % 中碳钢
elseif sum(ismember(plateGradeSet3, plateGrade)) == 1
    categoryNumber = 3;           % 高碳钢
elseif sum(ismember(plateGradeSet4, plateGrade)) == 1
    categoryNumber = 4;           % 不锈钢 
end
% ***** 上面代码的功能：根据输入的钢种，判断钢板类别编号 *****************
% ***********************************************************************

end