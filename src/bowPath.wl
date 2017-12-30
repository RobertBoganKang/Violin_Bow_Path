(* ::Package:: *)

(*bowPath[] function accept matrix form of data;
n: indication of notes;
t: time spent [t accumulate is time axis];
s: string [G:4, D:3, A:2, E:1] for violin, count from right to left starting from 1 (string number>3);
l: position of bow [root:0, end:1]. 1 is effective bow length, every length measurement will based on this*)
bowPath[data_]:=Module[{aData,angleData,angleData2,angleData3,angleFunction,angleplot,bAng,bowlengthlonger,bowAngle,changeStringControlAngle,colorfunction,d,indicatorcoordinate,lData,lDataPrep,lDataPrep1,lDirection,lengthData,lengthFunction,lift,liftfunc,liftradius,lIndex,maxindex,n,nData,nIndex,noteTextCoordinate,noteTextPrep,p2,path,pathplot,rootMargin,sData,sIndex,speed,stringangle,stringname,positionplot,tAccumulateData,tData,temp,theta,tIndex,title},
(****start: data prepare****)
(*a. title of data*)
title=data[[1]];
(*re-oganize data: find data*)
(*b. find time*)
tIndex=First@First@Position[title,"t"];
tData=data[[2;;,tIndex]];
(*sum up time span to build timestamp*)
tAccumulateData=Accumulate[tData];
(*c. find bow position*)
lIndex=First@First@Position[title,"l"];
lDataPrep=data[[2;;,lIndex]];
(*ignore the missing data, then use interpolation to fill data; bow position function built here*)
lDataPrep1=Table[If[lDataPrep[[i]]!="",{tAccumulateData[[i]],lDataPrep[[i]]},{}],{i,Length[lDataPrep]}];
lDataPrep1=DeleteCases[lDataPrep1,{}];
(*append the same position point at the begining and end of data to make interpolation function calculate this position at the speed of bow at 0*)
PrependTo[lDataPrep1,{0,lDataPrep1[[1,2]]}];
AppendTo[lDataPrep1,{lDataPrep1[[-1,1]]+1,lDataPrep1[[-1,2]]}];
lengthFunction=Interpolation[lDataPrep1, Method->"Spline",InterpolationOrder->2];
lData=Table[lengthFunction[tAccumulateData[[i]]],{i,Length[lDataPrep]}];
(*d. find string index*)
sIndex=First@First@Position[title,"s"];
sData=data[[2;;,sIndex]];
(*e. find indicator strings*)
(*if no indication given, set to empty*)
If[Position[title,"n"]!={},nIndex=First@First@Position[title,"n"];
nData=data[[2;;,nIndex]];,nData=Table["",{i,Length[lData]}]];
(****end: data prepare****)

(****start: initilize system parameters****)
(*a. system parameters*)
(*margin from origin point as root of bow [assumption: strings are tiny comparing with length of bow]*)rootMargin=0.2;
(*second deirivitive peak percentage of string angle*)p2=0.3;
(*string name*)stringname={"G","D","A","E"};
(*(*viola*)stringname={"C","G","D","A"};*)(*(*cello*)stringname={"A","D","G","C"};*)(*(*bass*)stringname={"E","A","D","G"};*)(*(*Cello da spalla*)stringname={"C","G","D","A","E"};*)
(*string total angle: total degrees of the largest changing angle difference*)stringangle=40;
(*lift radius: when turning, there is a lift for strings which approximate the geometric location of string.
strings are on the circle of and liftradius are the radius of this circle*)liftradius=1/8.;
(*b. UI parameters*)
(*max showing index*)maxindex=30;
(*bow length percentage of longer*)bowlengthlonger=1.1;
(*length division*)d=4;
(*color function of path*)colorfunction[x_]:=ColorData["Rainbow"][x];
(*colorfunction[x_]:=GrayLevel[1-x];*)
(*sample points for shortest time of notes*)n=40;
(****end: initilize system parameters****)

(****start: calculate control point for interpolation function****)
(*convert n to unit time of 1*)n/=Min[tData];
(*stringangle: string angle between strings*)
stringangle/=(Length[stringname]-1);
(*bow angle: degree*)
bAng=-Table[(i-.5(Length[stringname]-1))*stringangle,{i,0,Length[stringname]-1}];
(*changing angle between strings*)
changeStringControlAngle=Reverse[Table[bAng[[i-1]]+bAng[[i]],{i,2,Length[bAng]}]/2];
(*calculate lift function: lift is the function of the distance of left most string to the line of bow with specific angle theta. 
set the lift of leftmost string is 0*)
lift[theta_]:=(Sin[(theta-90)*Pi/180]+1)*liftradius;
liftfunc[angle_]:=(lift[angle-changeStringControlAngle[[-1]]]*{-Sin[Pi/180*angle],Cos[Pi/180*angle]});
bowAngle=Table[i->Reverse[bAng][[i]],{i,Length[bAng]}];
aData=sData/.bowAngle;
angleData={{tAccumulateData[[1]],aData[[1]]}};
(*algorithm for building control point for angle function: similar to differential function method*)
(*1st derivitive control points: 
[1] if change the string, set the angle at the changing angle of these two strings;
[2] if not change the string, set the angle at the ideal position -- the middle of two changing angle*)
Do[AppendTo[angleData,{tAccumulateData[[i]],Which[aData[[i]]-aData[[i-1]]<0,changeStringControlAngle[[sData[[i]]]],aData[[i]]-aData[[i-1]]>0,changeStringControlAngle[[sData[[i]]-1]],True,aData[[i]]]}],{i,2,Length[tAccumulateData]}];
angleData2=angleData;
(*2nd derivitive control points (overcome the peak point of changing string is too small):
[method] if the situation of changing back to the string, such as G\[Rule]D\[Rule]G (change back to G; the angle two process of them is in the changing string angle of [G&D]), 
increase this peak by seting the control point between them to make sure the bow is on the specific string*)
Do[If[(aData[[i]]-aData[[i-1]])*(aData[[i+1]]-aData[[i]])<0,AppendTo[angleData2,{(tAccumulateData[[i]]+tAccumulateData[[i+1]])/2,angleData[[i,2]]+Sign[aData[[i]]-aData[[i-1]]]*p2*stringangle}]],{i,2,Length[tAccumulateData]-1}];
angleData2=Sort[angleData2];
angleFunction=Interpolation[angleData2,Method->"Spline",InterpolationOrder->2];
(****end: calculate control point for interpolation function****)

(****start: plot section****)
(*a. string plot*)
angleData3=Table[{t,angleFunction[t]},{t,tAccumulateData[[1]],tAccumulateData[[-1]],1/n}];
angleplot=Show[{ListLinePlot[(angleData3+bAng[[1]])/stringangle+1,PlotStyle->Directive[Gray,Dashed],PlotRange->All,Axes->False],
Graphics[Flatten@{Black,Table[Text[nData[[i]],(angleData[[i]]+bAng[[1]])/stringangle+1,Background->White],{i,1,Length[nData]}]}]},Frame->True,AspectRatio->1/4,Axes->False,FrameLabel->{"t","angle"},ImageSize->800,PlotRange->All];
(*b. bow position plot*)
lengthData=Table[{t*1.,lengthFunction[t]},{t,tAccumulateData[[1]],tAccumulateData[[-1]],1/n}];
positionplot=Show[{ListLinePlot[lengthData, PlotStyle -> Directive[Gray, Dashed],PlotRange->All,Axes->False],
Graphics[Flatten@{Black,Dashing[None],Table[Text[nData[[i]],{tAccumulateData[[i]],lData[[i]]},Background->White],{i,1,Length[nData]}]},PlotRange->All]},Frame->True,AspectRatio->1/4,Axes->False,FrameLabel->{"t","bow position"},ImageSize->800,PlotRange->All];
(*c. bow path plot*)
(*plot path prepare*)
path=Table[(lengthFunction[x]+rootMargin)*{Cos[angleFunction[x]*\[Pi]/180],Sin[angleFunction[x]*\[Pi]/180]}+liftfunc[angleFunction[x]],{x,tAccumulateData[[1]],tAccumulateData[[-1]],1/n}];
speed=Norm/@Differences[path];speed/=Max[speed];
noteTextCoordinate=Table[noteTextPrep={angleFunction[tAccumulateData[[i]]],lengthFunction[tAccumulateData[[i]]]};(rootMargin+noteTextPrep[[2]])*{Cos[noteTextPrep[[1]]*\[Pi]/180],Sin[noteTextPrep[[1]]*\[Pi]/180]}+liftfunc[noteTextPrep[[1]]],{i,Length[tAccumulateData]}];
(*change string direction*)lDirection=Differences[Append[lData,0]];
(*plot bow path*)
pathplot=Show[Flatten@{Graphics[Flatten@{GrayLevel[.97],Table[{PointSize[.07*40^(-i/n)],Point[path[[i]]]},{i,tData[[1]]*n}]}],
(*string angle*)Table[ListLinePlot[temp=liftfunc[changeStringControlAngle[[i]]];{0.8*rootMargin*{Cos[\[Pi]/180*changeStringControlAngle[[i]]],Sin[\[Pi]/180*changeStringControlAngle[[i]]]}+temp,(1.04+rootMargin) {Cos[\[Pi]/180*changeStringControlAngle[[i]]],Sin[\[Pi]/180*changeStringControlAngle[[i]]]}+temp},PlotStyle->Directive[LightGray,Dashed]],{i,Length[changeStringControlAngle]}],
Graphics[{LightGray,Table[Style[Text[stringname[[i]],(.89*rootMargin) {Cos[\[Pi]/180*bAng[[i]]],Sin[\[Pi]/180*bAng[[i]]]}+liftfunc[bAng[[i]]]],20],{i,Length[bAng]}]}],
Graphics[{LightGray,Table[Style[Text["("<>ToString[Length[bAng]-i+1]<>")",(.95*rootMargin) {Cos[\[Pi]/180*bAng[[i]]],Sin[\[Pi]/180*bAng[[i]]]}+liftfunc[bAng[[i]]]],12],{i,Length[bAng]}]}],
(*bow length*)
Table[ListLinePlot[Table[(i/d+rootMargin) {Cos[\[Pi]/180*angle],Sin[\[Pi]/180*angle]}+liftfunc[angle],{angle,bowlengthlonger*bAng[[-1]],bowlengthlonger*bAng[[1]]}],PlotStyle->Directive[Gray,Dashed]],{i,{0,d}}],
Table[ListLinePlot[Table[(i/d+rootMargin) {Cos[\[Pi]/180*angle],Sin[\[Pi]/180*angle]}+liftfunc[angle],{angle,bowlengthlonger*bAng[[-1]],bowlengthlonger*bAng[[1]]}],PlotStyle->Directive[LightGray,Dashed]],{i,1,d-1}],
Graphics[{LightGray,Table[Style[Text[ToString[InputForm[(i-1)/d]],((i-1)/d+rootMargin) {Cos[\[Pi]/180*(bowlengthlonger*bAng[[1]])],Sin[\[Pi]/180*(bowlengthlonger*bAng[[If[OddQ[i],1,-1]]])]}+liftfunc[(bAng[[If[OddQ[i],1,-1]]]+1)]+{-0.01,If[OddQ[i],1,-1]*0.02}],20],{i,1,d+1}]}],
(*Path*)Graphics[Flatten@{Opacity[If[Length[tData]>maxindex,.4,.8]],Thick,Table[{colorfunction[speed[[i]]],Line[{path[[i]],path[[i+1]]}]},{i,Length[speed]}]}],
(*time*)
If[Length[tData]>maxindex,{},
Graphics[Flatten@{Dashed,Gray,
Table[
(*set the distance depend by i thus it is less likely to overlap; the sqrt function is because of the area of circle is proportional to radius^2*)
theta=RandomReal[2*Pi];
indicatorcoordinate=noteTextCoordinate[[i]]+.01*Sqrt[i]*{Cos[theta],Sin[theta]};
{Line[{indicatorcoordinate,noteTextCoordinate[[i]]}],Style[Text[ToString[tAccumulateData[[i]]]<>If[nData[[i]]=="","",":"]<>nData[[i]],indicatorcoordinate],Italic,If[lDirection[[i]]>0,Red,Blue],Background->White]}
,{i,Length[nData],1,-1}]
},AspectRatio->1]]
},PlotRange->All,Axes->False,ImageSize->1600];
(****end: plot section****)

(****show result of plots****)
Column[{pathplot,Grid[{{angleplot,positionplot}},ItemSize->Full]},Frame->True]];


(*export function to export the result:
a. use it outside the bowPath[] function;
b. results location: the same directory of notebook you are using and you can find folder 'exports' contains the files of results*)
export[x_]:=Module[{},Quiet[CreateDirectory[NotebookDirectory[]<>"exports"]];Column@{Export[NotebookDirectory[]<>"exports/"<>ToString[Round[AbsoluteTime[]*100]]<>".png",x],Export[NotebookDirectory[]<>"exports/"<>ToString[Round[AbsoluteTime[]*100]]<>".pdf",x]}];
