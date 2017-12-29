(* ::Package:: *)

(*bowPath[] function accept matrix form of data;
n: indication of notes;
t: time spent [t accumulate is time axis];
s: string [G:4, D:3, A:2, E:1] for violin, count from right to left starting from 1 (string number>3);
l: position of bow [root:0, end:1]*)
bowPath[data_]:=Module[{title,tIndex,tData,changeStringControlAngle,stringname,maxindex,tAccumulateData,colorfunction,lIndex,lDataPrep,lDataPrep1,lData,lengthFunction,sIndex,sData,nIndex,nData,rootMargin,n,d,bAng,bowAngle,aData,angleData,lengthData,angleFunction,path,speed,noteTextPrep,noteTextCoordinate,lDirection,stringplot,pathplot,angleplot,angleData2,angleData3,angleTurnPre,angleTurnNow,stringangle,p2,indicatorcoordinate,theta},
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
(*color function of path*)colorfunction[x_]:=ColorData["Rainbow"][x];
(*colorfunction[x_]:=GrayLevel[1-x];*)
(*margin from origin point as root of bow [assumption: strings are tiny comparing with length of bow]*)rootMargin=0.2;
(*sample points for unit time of 1*)n=40;
(*length division*)d=4;
(*second deirivitive peak percentage*)p2=0.3;
(*string name*)stringname={"G","D","A","E"};
(*(*viola*)stringname={"C","G","D","A"};*)(*(*cello*)stringname={"A","D","G","C"};*)(*(*bass*)stringname={"E","A","D","G"};*)(*(*Cello da spalla*)stringname={"C","G","D","A","E"};*)
(*string total angle: total degrees of the largest changing angle difference*)stringangle=50;
(*max showing index*)maxindex=30;
(****end: initilize system parameters****)

(****start: calculate control point for interpolation function****)
(*stringangle: string angle between strings*)
stringangle/=(Length[stringname]-2);
(*bow angle: degree*)
bAng=-Table[(i-.5(Length[stringname]-1))*stringangle,{i,0,Length[stringname]-1}];
(*changing angle between strings*)
changeStringControlAngle=Reverse[Table[bAng[[i-1]]+bAng[[i]],{i,2,Length[bAng]}]/2];
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
stringplot=Show[{ListLinePlot[angleData3,PlotStyle->Directive[Gray,Dashed],PlotRange->All,Axes->False],Graphics[Flatten@{Black,Table[Text[nData[[i]],angleData[[i]],Background->White],{i,1,Length[nData]}]}]},Frame->True,AspectRatio->1/4,Axes->False,FrameLabel->{"t","angle"},ImageSize->800];
(*b. bow angle plot*)
lengthData=Table[{t*1.,lengthFunction[t]},{t,tAccumulateData[[1]],tAccumulateData[[-1]],1/n}];
angleplot=Show[{ListLinePlot[lengthData, PlotStyle -> Directive[Gray, Dashed],PlotRange->All,Axes->False],Graphics[Flatten@{Black,Dashing[None],Table[Text[nData[[i]],{tAccumulateData[[i]],lData[[i]]},Background->White],{i,1,Length[nData]}]},PlotRange->All]},Frame->True,AspectRatio->1/4,Axes->False,FrameLabel->{"t","bow position"},ImageSize->800];
(*c. bow path plot*)
(*plot path prepare*)
path=Table[{x*1.,(lengthFunction[x]+rootMargin)*{Cos[angleFunction[x]*\[Pi]/360],Sin[angleFunction[x]*\[Pi]/360]}},{x,1,tAccumulateData[[-1]],1/n}];
speed=Norm/@Differences[path[[;;,2]]];speed/=Max[speed];
noteTextPrep={Transpose[angleData][[-1]],lData};
noteTextCoordinate=Table[(rootMargin+noteTextPrep[[2,i]])*{Cos[noteTextPrep[[1,i]]*\[Pi]/360],Sin[noteTextPrep[[1,i]]*\[Pi]/360]},{i,Length[tData]}];
lDirection=Differences[Append[lData,0]];
(*plot bow path*)
pathplot=Show[Flatten@{Graphics[Flatten@{GrayLevel[.97],Table[{PointSize[.07*1.3^(-i*20/n)],Point[path[[i,2]]]},{i,If[Length[path]>n/2,n/2,Length[path]]}]}],
(*string angle*)Table[ListLinePlot[{0.8*rootMargin*{Cos[\[Pi]/360*changeStringControlAngle[[i]]],Sin[\[Pi]/360*changeStringControlAngle[[i]]]},(1.02+rootMargin) {Cos[\[Pi]/360*changeStringControlAngle[[i]]],Sin[\[Pi]/360*changeStringControlAngle[[i]]]}},PlotStyle->Directive[LightGray,Dashed]],{i,Length[changeStringControlAngle]}],Graphics[{LightGray,Table[Style[Text[stringname[[i]],(.9*rootMargin) {Cos[\[Pi]/360*bAng[[i]]],Sin[\[Pi]/360*bAng[[i]]]}],20],{i,Length[bAng]}]}],
(*bow length*)Graphics[Flatten@{Dashed,LightGray,Table[Circle[{0,0},rootMargin+i/d,{-(Max[bAng]+1)*\[Pi]/360,(Max[bAng]+1)*\[Pi]/360}],{i,1,d-1}],Gray,Table[Circle[{0,0},rootMargin+i/d,{-(Max[bAng]+1)*\[Pi]/360,(Max[bAng]+1)*\[Pi]/360}],{i,{0,d}}]}],Graphics[{LightGray,Table[Style[Text[ToString[InputForm[(i-1)/d]],((i-1)/d+rootMargin) {Cos[\[Pi]/360*(Max[bAng]+1)],If[OddQ[i],1,-1]*Sin[\[Pi]/360*(Max[bAng]+1)]}+{-0.01,If[OddQ[i],1,-1]*0.02}],20],{i,1,d+1}]}],
(*Path*)Graphics[Flatten@{Opacity[If[Length[tData]>maxindex,.4,.8]],Thick,Table[{colorfunction[speed[[i]]],Line[{path[[i,2]],path[[i+1,2]]}]},{i,Length[speed]}]}],
(*time*)
If[Length[tData]>maxindex,{},
Graphics[Flatten@{Dashed,Gray,
Table[
(*set the distance depend by i thus it is less likely to overlap*)
theta=RandomReal[2*Pi];
indicatorcoordinate=noteTextCoordinate[[i]]+.01*Sqrt[i]*{Cos[theta],Sin[theta]};
{Line[{noteTextCoordinate[[i]],indicatorcoordinate}],Style[Text[ToString[tAccumulateData[[i]]]<>If[nData[[i]]=="","",":"]<>nData[[i]],indicatorcoordinate],Italic,If[lDirection[[i]]>0,Red,Blue],Background->White]}
,{i,Length[nData],1,-1}]
},AspectRatio->1]]
},PlotRange->All,Axes->False,ImageSize->1600];
(****end: plot section****)

(****show result of plots****)
Column[{pathplot,Grid[{{stringplot,angleplot}},ItemSize->Full]},Frame->True]];


(*export function to export the result:
a. use it outside the bowPath[] function;
b. results location: the same directory of notebook you are using and you can find folder 'exports' contains the files of results*)
export[x_]:=Module[{},Quiet[CreateDirectory[NotebookDirectory[]<>"exports"]];Column@{Export[NotebookDirectory[]<>"exports/"<>ToString[UnixTime[]]<>".png",x],Export[NotebookDirectory[]<>"exports/"<>ToString[UnixTime[]]<>".pdf",x]}];
